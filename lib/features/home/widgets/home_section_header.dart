import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wujidt/core/utils/app_colors.dart';
import 'package:wujidt/core/widgets/custom_btn.dart';

class HomeSectionHeader extends StatelessWidget {
  final bool isSelectionMode;
  final VoidCallback onToggleSelection;

  const HomeSectionHeader({
    super.key,
    required this.isSelectionMode,
    required this.onToggleSelection,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.history, color: AppColors.primary, size: 24.sp),
              SizedBox(width: 8.w),
              Text(
                "Recent Uploads",
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          CustomBtn(
            text: isSelectionMode ? "Cancel" : "Select",
            btnWidth: 90.w,
            btnHeight: 35.h,
            onPressed: onToggleSelection,
            weight: FontWeight.bold,
            size: 14.sp,
            fontFamily: 'Nunito Sans',
            eleveation: 0,
          ),
        ],
      ),
    );
  }
}