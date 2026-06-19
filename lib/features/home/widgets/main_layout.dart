import 'package:flutter/material.dart';
import 'package:wujidt/features/auth/services/auth_service.dart';
import 'package:wujidt/features/auth/views/profile_screen.dart';
import 'package:wujidt/features/home/views/home_page.dart';
import 'package:wujidt/features/home/views/browse_page.dart';
import 'package:wujidt/features/home/widgets/custom_bottom_nav.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  static final ValueNotifier<int?> navigationTrigger = ValueNotifier<int?>(null);
  static final ValueNotifier<String> userNameNotifier = ValueNotifier<String>("User");

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  final AuthService _authService = AuthService();
  int _currentIndex = 0;
  final GlobalKey<HomePageState> _homeKey = GlobalKey<HomePageState>();

  @override
  void initState() {
    super.initState();
    MainLayout.navigationTrigger.addListener(_handleExternalNavigation);
    
    _authService.fetchAndCacheProfile();
  }

  @override
  void dispose() {
    MainLayout.navigationTrigger.removeListener(_handleExternalNavigation);
    super.dispose();
  }

  void _handleExternalNavigation() async {
    final index = MainLayout.navigationTrigger.value;
    if (index != null) {
      if (index == 1) {
        bool imagePicked = await _homeKey.currentState?.pickImage() ?? false;
        if (imagePicked && mounted) {
          setState(() => _currentIndex = 0);
        }
      } else {
        if (mounted) setState(() => _currentIndex = index);
      }
      MainLayout.navigationTrigger.value = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    int stackIndex = 0;
    if (_currentIndex == 2) {
      stackIndex = 1;
    } else if (_currentIndex == 3) {
      stackIndex = 2;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: stackIndex,
        children: [
          HomePage(key: _homeKey),
          BrowsePage(homeKey: GlobalKey()),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex == 3 ? 1 : _currentIndex,
        onTap: (index) async {
          if (index == 1) {
            bool imagePicked = await _homeKey.currentState?.pickImage() ?? false;
            if (imagePicked && mounted) {
              setState(() => _currentIndex = 0);
            }
          } else {
            setState(() => _currentIndex = index);
          }
        },
      ),
    );
  }
}