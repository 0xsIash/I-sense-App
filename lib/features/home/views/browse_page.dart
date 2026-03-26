import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:isense/core/utils/app_colors.dart';
import 'package:isense/features/home/views/home_page.dart';
import 'package:isense/features/home/models/scan_item_model.dart';
import 'package:isense/features/home/widgets/scan_item_card.dart';
import 'package:isense/features/home/widgets/custom_drawer.dart';
import 'package:isense/features/home/widgets/item_details_view.dart';

class BrowsePage extends StatefulWidget {
  final GlobalKey<HomePageState> homeKey;

  const BrowsePage({super.key, required this.homeKey});

  @override
  State<BrowsePage> createState() => _BrowsePageState();
}

class _BrowsePageState extends State<BrowsePage> {
  bool isBrowseMode = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // الدالة دي بتوزع صورك كدبابيس على الخريطة بشكل عشوائي حوالين القاهرة مؤقتاً
  List<Marker> _buildMarkers(List<ScanItemModel> history) {
    final random = Random();
    final double baseLat = 30.0444; 
    final double baseLng = 31.2357; 

    return history.map((item) {
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
              MaterialPageRoute(builder: (context) => ItemDetailsView(item: item)),
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
                    BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
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
    final userName = ModalRoute.of(context)!.settings.arguments as String;
    List<ScanItemModel> userHistory = widget.homeKey.currentState?.historyList ?? [];

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: CustomDrawer(userName: userName),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 15.h),
            
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _scaffoldKey.currentState!.openDrawer(),
                        child: Icon(Icons.menu, color: AppColors.primary, size: 28.sp),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        "Hello $userName !",
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  Icon(Icons.notifications_none, color: AppColors.primary, size: 28.sp),
                ],
              ),
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
                            color: isBrowseMode ? AppColors.primary.withValues(alpha: 0.15) : Colors.transparent,
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
              child: isBrowseMode ? _buildBrowseGrid(userHistory) : _buildRealMap(userHistory),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrowseGrid(List<ScanItemModel> userHistory) {
    if (userHistory.isEmpty) {
      return Center(
        child: Text("No items found", style: TextStyle(color: Colors.grey, fontSize: 16.sp)),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      itemCount: userHistory.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15.w,
        mainAxisSpacing: 15.h,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (context, index) {
        final item = userHistory[index];
        
        Widget bottomWidget;
        if (item.extractedItems != null && item.extractedItems!.isNotEmpty) {
           bottomWidget = ListView(
             scrollDirection: Axis.horizontal,
             children: item.extractedItems!.map((e) => e.category).toSet().take(2).map((tag) => Container(
               margin: EdgeInsets.only(right: 5.w),
               padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
               decoration: BoxDecoration(
                 color: AppColors.primary,
                 borderRadius: BorderRadius.circular(4),
               ),
               child: Center(
                 child: Text(tag, style: TextStyle(color: Colors.white, fontSize: 10.sp)),
               ),
             )).toList(),
           );
        } else {
           bottomWidget = Center(child: Text("Completed", style: TextStyle(color: Colors.grey, fontSize: 12.sp)));
        }

        return GestureDetector(
          onTap: () {
             Navigator.push(
               context,
               MaterialPageRoute(builder: (context) => ItemDetailsView(item: item)),
             );
          },
          child: ScanItemCard(
            imageFile: item.imageFile,
            imageUrl: item.imageUrl,
            bottomContent: bottomWidget,
          ),
        );
      },
    );
  }

  // ده كود الخريطة الحقيقية التفاعلية
  Widget _buildRealMap(List<ScanItemModel> userHistory) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: const LatLng(30.0444, 31.2357), // احداثيات افتراضية
        initialZoom: 13.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.isense.app', 
        ),
        MarkerLayer(
          markers: _buildMarkers(userHistory),
        ),
      ],
    );
  }
}