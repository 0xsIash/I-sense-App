import 'package:flutter/material.dart';
import 'package:wujidt/core/widgets/custom_header.dart';
import 'package:wujidt/features/home/widgets/browse_controller.dart';
import 'package:wujidt/features/home/widgets/browse_map_view.dart';
import 'package:wujidt/features/home/widgets/browse_tab.dart';
import 'package:wujidt/features/home/widgets/browse_toggle_bar.dart';
import 'package:wujidt/features/home/widgets/custom_drawer.dart';

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

  @override
  Widget build(BuildContext context) {
    final String userName =
        (ModalRoute.of(context)?.settings.arguments as String?) ?? "User";

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