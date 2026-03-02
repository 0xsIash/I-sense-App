import 'package:flutter/material.dart';
import 'package:isense/features/home/views/home_page.dart';
import 'package:isense/features/home/views/browse_page.dart';
import 'package:isense/features/home/widgets/custom_bottom_nav.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  final GlobalKey<HomePageState> _homeKey = GlobalKey<HomePageState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _currentIndex == 2 ? 1 : 0,
        children: [
          HomePage(key: _homeKey),
          BrowsePage(homeKey: _homeKey),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 1) {
            _homeKey.currentState?.pickImageFromCamera();
            setState(() => _currentIndex = 0);
          } else {
            setState(() => _currentIndex = index);
          }
        },
      ),
    );
  }
}