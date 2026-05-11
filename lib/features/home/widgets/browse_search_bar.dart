import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wujidt/core/utils/app_colors.dart';
import 'package:wujidt/core/utils/app_assets.dart';
import 'package:wujidt/core/widgets/custom_svg_wrapper.dart';

class BrowseSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSearch;
  final VoidCallback onCameraTap;

  const BrowseSearchBar({
    super.key,
    required this.controller,
    required this.onSearch,
    required this.onCameraTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 40.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.primary, 
                  width: 1.5, 
                ),
              ),
              child: TextField(
                controller: controller,
                onChanged: onSearch,
                style: TextStyle(fontSize: 14.sp),
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  hintText: "Search for items...",
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 13.sp),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.primary,
                    size: 20.sp,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(bottom: 12.h), 
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          GestureDetector(
            onTap: onCameraTap,
            child: CustomSvgWrapper(
              path: AppAssets.searchCamera,
              iconWidth: 28.w, 
              iconHeight: 28.h,
              color: AppColors.primary, 
            ),
          ),
        ],
      ),
    );
  }
}