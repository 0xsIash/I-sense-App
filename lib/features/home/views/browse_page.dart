import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:wujidt/features/home/widgets/browse_tab.dart';
import 'package:wujidt/features/home/widgets/item_details_view.dart';
import 'package:wujidt/core/utils/app_colors.dart';
import 'package:wujidt/features/home/widgets/custom_drawer.dart';
import 'package:wujidt/features/home/views/home_page.dart';
import 'package:wujidt/core/widgets/custom_header.dart';
import 'package:wujidt/features/home/models/scan_item_model.dart';

class BrowsePage extends StatefulWidget {
  final GlobalKey<HomePageState> homeKey;

  const BrowsePage({super.key, required this.homeKey});

  @override
  State<BrowsePage> createState() => _BrowsePageState();
}

class _BrowsePageState extends State<BrowsePage> with TickerProviderStateMixin {
  bool isBrowseMode = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final MapController _mapController = MapController();
  List<ScanItemModel> browseItems = [];

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    final latTween = Tween<double>(
        begin: _mapController.camera.center.latitude,
        end: destLocation.latitude);
    final lngTween = Tween<double>(
        begin: _mapController.camera.center.longitude,
        end: destLocation.longitude);
    final zoomTween =
        Tween<double>(begin: _mapController.camera.zoom, end: destZoom);

    final controller = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    final animation =
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    controller.addListener(() {
      _mapController.move(
          LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
          zoomTween.evaluate(animation));
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  Future<void> _goToCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    Position? lastPosition = await Geolocator.getLastKnownPosition();
    if (lastPosition != null) {
      _animatedMapMove(LatLng(lastPosition.latitude, lastPosition.longitude), 15.0);
    }

    Position currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.low,
      timeLimit: const Duration(seconds: 5),
    );
    
    _animatedMapMove(LatLng(currentPosition.latitude, currentPosition.longitude), 15.0);
  }

  List<Marker> _buildMarkers() {
    return browseItems
        .where((item) => item.latitude != null && item.longitude != null)
        .map((item) {
      return Marker(
        point: LatLng(item.latitude!, item.longitude!),
        width: 60.w,
        height: 70.h,
        child: GestureDetector(
          onTap: () async {
            _animatedMapMove(LatLng(item.latitude!, item.longitude!), 16.0);
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ItemDetailsView(item: item),
              ),
            );
            setState(() {});
          },
          child: Column(
            children: [
              Container(
                width: 45.w,
                height: 45.w,
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: AppColors.primary, width: 2),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 3))
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: item.imageUrl != null
                      ? Image.network(
                          item.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.image_not_supported),
                        )
                      : const Icon(Icons.image),
                ),
              ),
              Icon(Icons.location_pin, color: AppColors.primary, size: 22.sp),
            ],
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    String userName =
        (ModalRoute.of(context)!.settings.arguments as String?) ?? "User";

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: CustomDrawer(userName: userName),
      floatingActionButton: !isBrowseMode
          ? FloatingActionButton(
              onPressed: _goToCurrentLocation,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.my_location, color: Colors.white),
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 15.h),
            CustomHeader(
              userName: userName,
              scaffoldKey: _scaffoldKey,
              processingCount:
                  widget.homeKey.currentState?.processingList.length ?? 0,
              historyCount:
                  widget.homeKey.currentState?.historyList.length ?? 0,
            ),
            SizedBox(height: 25.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Container(
                height: 45.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25.r),
                  border: Border.all(color: AppColors.primary),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => isBrowseMode = true),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isBrowseMode
                                ? AppColors.primary.withOpacity(0.15)
                                : Colors.transparent,
                            borderRadius: BorderRadius.horizontal(
                                left: Radius.circular(24.r)),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "Browse",
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: isBrowseMode
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 16.sp,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(width: 1, color: AppColors.primary),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => isBrowseMode = false),
                        child: Container(
                          decoration: BoxDecoration(
                            color: !isBrowseMode
                                ? AppColors.primary.withOpacity(0.15)
                                : Colors.transparent,
                            borderRadius: BorderRadius.horizontal(
                                right: Radius.circular(24.r)),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "Map",
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: !isBrowseMode
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 16.sp,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Expanded(
              child: Stack(
                children: [
                  Offstage(
                    offstage: !isBrowseMode,
                    child: BrowseTab(
                      onDataLoaded: (items) {
                        setState(() {
                          browseItems = items;
                        });
                      },
                    ),
                  ),
                  Offstage(
                    offstage: isBrowseMode,
                    child: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: const LatLng(30.0444, 31.2357),
                        initialZoom: 6.0,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.all,
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                          subdomains: const ['a', 'b', 'c', 'd'],
                          userAgentPackageName: 'com.isense.app',
                        ),
                        MarkerLayer(
                          key: ValueKey(browseItems.length),
                          markers: _buildMarkers(),
                        ),
                      ],
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