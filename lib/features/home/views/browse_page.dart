import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wujidt/core/utils/app_colors.dart';
import 'package:wujidt/core/widgets/custom_header.dart';
import 'package:wujidt/core/utils/image_picker_helper.dart';
import 'package:wujidt/features/home/controllers/browse_controller.dart';
import 'package:wujidt/features/home/widgets/browse_map_view.dart';
import 'package:wujidt/features/home/widgets/browse_tab.dart';
import 'package:wujidt/features/home/widgets/browse_toggle_bar.dart';
import 'package:wujidt/features/home/widgets/contact_finder_sheet.dart';
import 'package:wujidt/features/home/widgets/custom_drawer.dart';
import 'package:wujidt/features/home/widgets/browse_search_bar.dart';
import 'package:wujidt/features/home/widgets/main_layout.dart';
import 'package:wujidt/features/home/views/top_match_screen.dart';
import 'package:wujidt/features/home/models/top_match_model.dart';

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
    MainLayout.targetMapLocation.addListener(_handleTargetLocationTrigger);
  }

  @override
  void dispose() {
    MainLayout.targetMapLocation.removeListener(_handleTargetLocationTrigger);
    _controller.removeListener(_onControllerUpdate);
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onControllerUpdate() => setState(() {});

  void _handleTargetLocationTrigger() {
    if (MainLayout.targetMapLocation.value != null && mounted) {
      setState(() {
        _isBrowseMode = false;
      });
    }
  }

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
    if (imageFile != null && context.mounted) {
      Navigator.push(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
          builder: (context) => TopMatchScreen(searchImage: imageFile),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = 
        (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?) ?? {};
    
    final int currentUserId = args['userId'] ?? 0;

    return ValueListenableBuilder<String>(
      valueListenable: MainLayout.userNameNotifier,
      builder: (context, currentUserName, child) {
        return Scaffold(
          backgroundColor: AppColors.primaryBackgrond,
          key: _scaffoldKey,
          drawer: CustomDrawer(userName: currentUserName),
          body: SafeArea(
            child: Column(
              children: [
                CustomHeader(
                  userName: currentUserName,
                  scaffoldKey: _scaffoldKey,
                  processingCount: 0,
                  historyCount: 0,
                ),
                BrowseSearchBar(
                  controller: _searchController,
                  onSearch: (query) {},
                  onCameraTap: _handleCameraTap,
                  onResultTapped: (TopMatchItem matchedItem) {
                    showDialog(
                      context: context,
                      builder: (dialogContext) => Dialog(
                        backgroundColor: Colors.transparent,
                        insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.topCenter,
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: 80.h),
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(height: 70.h),
                                  Text(
                                    matchedItem.objectLabel,
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                      fontFamily: 'Kreon',
                                    ),
                                  ),
                                  ContactFinderSheet(
                                    uploaderName: matchedItem.publisherUsername,
                                    phoneNumber: matchedItem.publisherPhone,
                                    locationName: matchedItem.locationName,
                                    onMapPressed: () {},
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 0,
                              child: Container(
                                height: 140.h,
                                width: 140.w,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.15),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20.r),
                                  child: Image.network(
                                    matchedItem.segmentedImageUrl.isNotEmpty 
                                        ? matchedItem.segmentedImageUrl 
                                        : matchedItem.originalImageUrl,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
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
      },
    );
  }
}