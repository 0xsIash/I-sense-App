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
import 'dart:math';

class BrowsePage extends StatefulWidget {
  final GlobalKey<HomePageState> homeKey;

  const BrowsePage({super.key, required this.homeKey});

  @override
  State<BrowsePage> createState() => _BrowsePageState();
}

class _BrowsePageState extends State<BrowsePage> {
  bool isBrowseMode = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Marker> _buildMarkers() {
    final random = Random();
    final double baseLat = 30.0444;
    final double baseLng = 31.2357;

    final userHistory = widget.homeKey.currentState?.historyList ?? [];

    return userHistory.map((item) {
      double latOffset = (random.nextDouble() - 0.5) * 0.02;
      double lngOffset = (random.nextDouble() - 0.5) * 0.02;

      return Marker(
        point: LatLng(baseLat + latOffset, baseLng + lngOffset),
        width: 50.w,
        height: 55.h,
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ItemDetailsView(item: item),
              ),
            );
          },
          child: Column(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: AppColors.primary, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6.r),
                  child: item.imageFile != null
                      ? Image.file(item.imageFile!, fit: BoxFit.cover)
                      : (item.imageUrl != null
                          ? Image.network(item.imageUrl!, fit: BoxFit.cover)
                          : const Icon(Icons.image, size: 20)),
                ),
              ),
              Icon(Icons.arrow_drop_down, color: AppColors.primary, size: 15.sp),
            ],
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    String userName = (ModalRoute.of(context)!.settings.arguments as String?) ?? "User";

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
              processingCount: widget.homeKey.currentState?.processingList.length ?? 0,
              historyCount: widget.homeKey.currentState?.historyList.length ?? 0,
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
                            color: isBrowseMode ? AppColors.primary.withValues(alpha:0.15) : Colors.transparent,
                            borderRadius: BorderRadius.horizontal(left: Radius.circular(24.r)),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "Browse",
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: isBrowseMode ? FontWeight.bold : FontWeight.normal,
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
                            color: !isBrowseMode ? AppColors.primary.withValues(alpha: 0.15) : Colors.transparent,
                            borderRadius: BorderRadius.horizontal(right: Radius.circular(24.r)),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "Map",
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: !isBrowseMode ? FontWeight.bold : FontWeight.normal,
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

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 45.h,
                      padding: EdgeInsets.symmetric(horizontal: 15.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25.r),
                        border: Border.all(color: AppColors.primary),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: Colors.grey, size: 22.sp),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: "search for items",
                                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 15.w),
                  GestureDetector(
                    onTap: () {
                      if (isBrowseMode) {
                        widget.homeKey.currentState?.pickImageFromCamera();
                      }
                    },
                    child: Icon(
                      isBrowseMode ? Icons.camera_alt : Icons.tune,
                      color: AppColors.primary,
                      size: 28.sp,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            Expanded(
              child: isBrowseMode
                  ? const BrowseTab() 
                  : FlutterMap(
                      options: MapOptions(
                        initialCenter: const LatLng(30.0444, 31.2357),
                        initialZoom: 13.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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