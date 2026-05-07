import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wujidt/core/utils/app_colors.dart';
import 'package:wujidt/core/widgets/custom_header.dart';
import 'package:wujidt/features/home/models/scan_item_model.dart';
import 'package:wujidt/features/home/widgets/browse_tab.dart';
import 'package:wujidt/features/home/widgets/custom_drawer.dart';
import 'package:wujidt/features/home/widgets/map_item_card.dart';
import 'package:wujidt/features/home/widgets/map_marker.dart';

class BrowsePage extends StatefulWidget {
  final GlobalKey homeKey;

  const BrowsePage({
    super.key,
    required this.homeKey,
  });

  @override
  State<BrowsePage> createState() => _BrowsePageState();
}

class _BrowsePageState extends State<BrowsePage> {
  bool isBrowseMode = true;

  GoogleMapController? mapController;

  List<ScanItemModel> browseItems = [];

  Set<Marker> markers = {};

  ScanItemModel? selectedItem;

  LatLng currentLocation = const LatLng(30.0444, 31.2357);

  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();

  final GlobalKey<BrowseTabState> browseTabKey =
      GlobalKey<BrowseTabState>();

  @override
  void initState() {
    super.initState();

    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled =
        await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return;
    }

    permission =
        await Geolocator.checkPermission();

    if (permission ==
        LocationPermission.denied) {
      permission =
          await Geolocator.requestPermission();

      if (permission ==
          LocationPermission.denied) {
        return;
      }
    }

    if (permission ==
        LocationPermission.deniedForever) {
      return;
    }

    Position position =
        await Geolocator.getCurrentPosition(
      locationSettings:
          const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    LatLng newLocation = LatLng(
      position.latitude,
      position.longitude,
    );

    setState(() {
      currentLocation = newLocation;
    });

    mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        newLocation,
        15,
      ),
    );
  }

  Future<void> _updateMarkers() async {
    final Set<Marker> newMarkers = {};

    for (var item in browseItems) {
      if (item.latitude == null ||
          item.longitude == null) {
        continue;
      }

      final icon =
          await MapMarker.buildCustomMarker(
        item: item,
        isSelected:
            selectedItem?.id == item.id,
      );

      newMarkers.add(
        Marker(
          markerId:
              MarkerId(item.id.toString()),
          position: LatLng(
            item.latitude!,
            item.longitude!,
          ),
          icon: icon,
          onTap: () {
            setState(() {
              selectedItem = item;
            });

            mapController?.animateCamera(
              CameraUpdate.newLatLngZoom(
                LatLng(
                  item.latitude!,
                  item.longitude!,
                ),
                16,
              ),
            );

            _updateMarkers();
          },
        ),
      );
    }

    setState(() {
      markers = newMarkers;
    });
  }

  Future<void> _refreshMapData() async {
    selectedItem = null;

    await browseTabKey.currentState
        ?.reloadImages();
  }

  @override
  Widget build(BuildContext context) {
    String userName =
        (ModalRoute.of(context)
                    ?.settings
                    .arguments
                as String?) ??
            "User";

    return Scaffold(
      key: _scaffoldKey,
      drawer: CustomDrawer(
        userName: userName,
      ),
      body: SafeArea(
        child: Column(
          children: [
            CustomHeader(
              userName: userName,
              scaffoldKey: _scaffoldKey,
              processingCount: 0,
              historyCount: 0,
            ),
            _buildToggleBar(),
            Expanded(
              child: Stack(
                children: [
                  Offstage(
                    offstage: !isBrowseMode,
                    child: BrowseTab(
                      key: browseTabKey,
                      onDataLoaded: (items) {
                        browseItems = items;
                        _updateMarkers();
                      },
                    ),
                  ),
                  Offstage(
                    offstage: isBrowseMode,
                    child: GoogleMap(
                      initialCameraPosition:
                          CameraPosition(
                        target:
                            currentLocation,
                        zoom: 12,
                      ),
                      myLocationEnabled: true,
                      myLocationButtonEnabled:
                          true,
                      markers: markers,
                      onMapCreated: (c) {
                        mapController = c;
                        _getCurrentLocation();
                      },
                      onTap: (_) {
                        setState(() {
                          selectedItem = null;
                        });

                        _updateMarkers();
                      },
                    ),
                  ),
                  if (!isBrowseMode)
                    Align(
                      alignment:
                          Alignment.bottomCenter,
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: 20.h,
                          left: 20.w,
                          right: 20.w,
                        ),
                        child: AnimatedSwitcher(
                          duration:
                              const Duration(
                            milliseconds: 300,
                          ),
                          transitionBuilder:
                              (
                                Widget child,
                                Animation<double>
                                    animation,
                              ) {
                            return FadeTransition(
                              opacity: animation,
                              child:
                                  ScaleTransition(
                                scale:
                                    Tween<double>(
                                  begin: 0.9,
                                  end: 1.0,
                                ).animate(
                                  animation,
                                ),
                                child: child,
                              ),
                            );
                          },
                          child:
                              selectedItem !=
                                      null
                                  ? MapItemCard(
                                    key: ValueKey(
                                      selectedItem!
                                          .id,
                                    ),
                                    item:
                                        selectedItem!,
                                  )
                                  : const SizedBox
                                      .shrink(),
                        ),
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

  Widget _buildToggleBar() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 20.w,
        vertical: 15.h,
      ),
      child: Container(
        height: 45.h,
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(25.r),
          border: Border.all(
            color: AppColors.primary,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    isBrowseMode = true;
                    selectedItem = null;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isBrowseMode
                        ? AppColors.primary
                            .withValues(
                            alpha: 0.15,
                          )
                        : Colors.transparent,
                    borderRadius:
                        BorderRadius.horizontal(
                      left:
                          Radius.circular(24.r),
                    ),
                  ),
                  alignment:
                      Alignment.center,
                  child: Text(
                    "Browse",
                    style: TextStyle(
                      color:
                          AppColors.primary,
                      fontWeight:
                          isBrowseMode
                              ? FontWeight
                                  .bold
                              : FontWeight
                                  .normal,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              width: 1,
              color: AppColors.primary,
            ),
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  setState(() {
                    isBrowseMode = false;
                  });

                  await _refreshMapData();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: !isBrowseMode
                        ? AppColors.primary
                            .withValues(
                            alpha: 0.15,
                          )
                        : Colors.transparent,
                    borderRadius:
                        BorderRadius.horizontal(
                      right:
                          Radius.circular(24.r),
                    ),
                  ),
                  alignment:
                      Alignment.center,
                  child: Text(
                    "Map",
                    style: TextStyle(
                      color:
                          AppColors.primary,
                      fontWeight:
                          !isBrowseMode
                              ? FontWeight
                                  .bold
                              : FontWeight
                                  .normal,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}