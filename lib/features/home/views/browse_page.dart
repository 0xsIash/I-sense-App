import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:isense/core/utils/app_colors.dart';
import 'package:isense/features/home/views/home_page.dart';
import 'package:isense/features/home/models/scan_item_model.dart';
import 'package:isense/features/home/widgets/scan_item_card.dart';
import 'package:isense/features/home/widgets/custom_drawer.dart';

class BrowsePage extends StatefulWidget {
  final GlobalKey<HomePageState> homeKey;

  const BrowsePage({super.key, required this.homeKey});

  @override
  State<BrowsePage> createState() => _BrowsePageState();
}

class _BrowsePageState extends State<BrowsePage> {
  bool isBrowseMode = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    String userName = "aya";
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
              child: isBrowseMode ? _buildBrowseGrid(userHistory) : _buildMapPlaceholder(userHistory),
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

        return ScanItemCard(
          imageFile: item.imageFile,
          imageUrl: item.imageUrl,
          bottomContent: bottomWidget,
        );
      },
    );
  }

  Widget _buildMapPlaceholder(List<ScanItemModel> userHistory) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFE0E6ED),
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.4,
              child: Image.network(
                'https://static.vecteezy.com/system/resources/previews/000/153/588/original/vector-roadmap-location-map.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          ...List.generate(userHistory.length > 5 ? 5 : userHistory.length, (index) {
            final item = userHistory[index];
            return Positioned(
              left: 50.w + (index * 40.w),
              top: 80.h + (index * 60.h % 200.h),
              child: Container(
                width: 40.w,
                height: 40.w,
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: AppColors.primary, width: 2),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: const Offset(0, 2))],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6.r),
                  child: item.imageFile != null 
                      ? Image.file(item.imageFile!, fit: BoxFit.cover)
                      : (item.imageUrl != null ? Image.network(item.imageUrl!, fit: BoxFit.cover) : const Icon(Icons.image, size: 20)),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}