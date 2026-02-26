import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:isense/core/utils/app_assets.dart';
import 'package:isense/core/utils/app_colors.dart';
import 'package:isense/core/widgets/custom_svg_wrapper.dart';

class CustomBottomNav extends StatelessWidget {
  const CustomBottomNav({super.key, required this.onCameraTap});

  final VoidCallback onCameraTap;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),

        border: Border.all(
          color: AppColors.primary,
          width: 2,
        ),
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
            _buildNavItem(
            iconPath: AppAssets.camera, label: 'Detect',onTap: () {onCameraTap();})

        ],
      ),
    );
  }
}

Widget _buildNavItem({
  required String iconPath,
    required String label,
    VoidCallback? onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ColorFiltered(
          colorFilter: ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
          child: CustomSvgWrapper(
            path: iconPath,
            iconWidth: 24.w,
            iconHeight: 24.h,
            ),
          ),

          SizedBox(height: 5.h),
          Text(
            label,
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              fontFamily: "Kreon"
            ),

          ),
          
        
      ],
    ),
  );
}