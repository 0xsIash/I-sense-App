import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wujidt/core/utils/app_colors.dart';

class BrowseToggleBar extends StatelessWidget {
  final bool isBrowseMode;
  final VoidCallback onBrowseTap;
  final VoidCallback onMapTap;

  const BrowseToggleBar({
    super.key,
    required this.isBrowseMode,
    required this.onBrowseTap,
    required this.onMapTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
      child: Container(
        height: 45.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.r),
          border: Border.all(color: AppColors.primary),
        ),
        child: Row(
          children: [
            Expanded(
              child: _ToggleButton(
                label: "Browse",
                isActive: isBrowseMode,
                isLeft: true,
                onTap: onBrowseTap,
              ),
            ),
            Container(width: 1, color: AppColors.primary),
            Expanded(
              child: _ToggleButton(
                label: "Map",
                isActive: !isBrowseMode,
                isLeft: false,
                onTap: onMapTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool isLeft;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.label,
    required this.isActive,
    required this.isLeft,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.horizontal(
            left: isLeft ? Radius.circular(24.r) : Radius.zero,
            right: isLeft ? Radius.zero : Radius.circular(24.r),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 16.sp,
          ),
        ),
      ),
    );
  }
}