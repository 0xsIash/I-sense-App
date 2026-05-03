import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:isense/features/home/widgets/browse_tab.dart';
import 'package:isense/features/home/widgets/item_details_view.dart';
import 'package:latlong2/latlong.dart';
import 'package:isense/core/utils/app_colors.dart';
import 'package:isense/features/home/widgets/custom_drawer.dart';
import 'package:isense/features/home/views/home_page.dart';
import 'package:isense/core/widgets/custom_header.dart';
import 'package:isense/features/home/models/scan_item_model.dart';

class BrowsePage extends StatefulWidget {
  final GlobalKey<HomePageState> homeKey;

  const BrowsePage({super.key, required this.homeKey});

  @override
  State<BrowsePage> createState() => _BrowsePageState();
}

class _BrowsePageState extends State<BrowsePage> {
  bool isBrowseMode = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<ScanItemModel> browseItems = [];

  List<Marker> _buildMarkers() {
  return browseItems
      .where((item) => item.latitude != null && item.longitude != null)
      .map((item) {
        debugPrint("LAT: ${item.latitude}, LNG: ${item.longitude}");


    return Marker(
      point: LatLng(item.latitude!, item.longitude!),
      width: 55.w,
      height: 60.h,
      child: GestureDetector(
        onTap: () async {
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
              width: 42.w,
              height: 42.w,
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: AppColors.primary, width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: item.imageFile != null
                    ? Image.file(item.imageFile!, fit: BoxFit.cover)
                    : (item.imageUrl != null
                        ? Image.network(item.imageUrl!, fit: BoxFit.cover)
                        : const Icon(Icons.image)),
              ),
            ),
            Icon(Icons.location_pin,
                color: AppColors.primary, size: 18.sp),
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
                                ? AppColors.primary.withValues(alpha: 0.15)
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
                                ? AppColors.primary.withValues(alpha: 0.15)
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
              child: isBrowseMode
                  ? BrowseTab(
                      onDataLoaded: (items) {
                        setState(() {
                          browseItems = items;
                        });
                      },
                    )
                  : FlutterMap(
                      options: MapOptions(
                        initialCenter:
                            const LatLng(30.0444, 31.2357),
                        initialZoom: 13.0,
                        minZoom: 3,
                        maxZoom: 19,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.all,
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                          subdomains: const ['a', 'b', 'c', 'd'],
                          retinaMode: true, 
                          maxZoom: 20,
                          userAgentPackageName: 'com.isense.app',
                        ),

                        MarkerLayer(
                          markers: _buildMarkers(),
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