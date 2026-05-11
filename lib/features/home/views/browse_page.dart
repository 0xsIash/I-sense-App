import 'dart:io';
import 'package:flutter/material.dart';
import 'package:wujidt/core/widgets/custom_header.dart';
import 'package:wujidt/core/utils/image_picker_helper.dart';
import 'package:wujidt/features/home/widgets/browse_controller.dart';
import 'package:wujidt/features/home/widgets/browse_map_view.dart';
import 'package:wujidt/features/home/widgets/browse_tab.dart';
import 'package:wujidt/features/home/widgets/browse_toggle_bar.dart';
import 'package:wujidt/features/home/widgets/custom_drawer.dart';
import 'package:wujidt/features/home/widgets/browse_search_bar.dart';

class BrowsePage extends StatefulWidget {
  final GlobalKey homeKey;

  const BrowsePage({super.key, required this.homeKey});

  @override
  State<BrowsePage> createState() => _BrowsePageState();
}

class _BrowsePageState extends State<BrowsePage> {
  final BrowseController _controller = BrowseController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<BrowseTabState> _browseTabKey = GlobalKey<BrowseTabState>();
  final TextEditingController _searchController = TextEditingController();

  bool _isBrowseMode = true;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerUpdate);
    _controller.getCurrentLocation();
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onControllerUpdate() => setState(() {});

  Future<void> _switchToMap() async {
    setState(() => _isBrowseMode = false);
    _controller.resetMapState();
    await _browseTabKey.currentState?.reloadImages();
    await _controller.getCurrentLocation();
  }

  void _switchToBrowse() {
    setState(() => _isBrowseMode = true);
    _controller.resetBrowseMode();
  }

  Future<void> _handleCameraTap() async {
    File? imageFile = await ImagePickerHelper.showImageSourceOptions(context);
    if (imageFile != null) {
      debugPrint("Selected image for search: ${imageFile.path}");
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = 
        (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?) ?? {};
    
    final String userName = args['userName'] ?? "User";
    final int currentUserId = args['userId'] ?? 0;

    return Scaffold(
      key: _scaffoldKey,
      drawer: CustomDrawer(userName: userName),
      body: SafeArea(
        child: Column(
          children: [
            CustomHeader(
              userName: userName,
              scaffoldKey: _scaffoldKey,
              processingCount: 0,
              historyCount: 0,
            ),
            BrowseSearchBar(
              controller: _searchController,
              onSearch: (query) {
                debugPrint("Searching for: $query");
              },
              onCameraTap: _handleCameraTap,
            ),
            BrowseToggleBar(
              isBrowseMode: _isBrowseMode,
              onBrowseTap: _switchToBrowse,
              onMapTap: _switchToMap,
            ),
            Expanded(
              child: Stack(
                children: [
                  Offstage(
                    offstage: !_isBrowseMode,
                    child: BrowseTab(
                      key: _browseTabKey,
                      currentUserId: currentUserId,
                      onDataLoaded: (items) {
                        _controller.browseItems = items;
                        _controller.updateMarkers();
                      },
                    ),
                  ),
                  Offstage(
                    offstage: _isBrowseMode,
                    child: BrowseMapView(
                      controller: _controller,
                      currentUserId: currentUserId,
                      onMapCreated: _controller.getCurrentLocation,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}