import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wujidt/core/utils/app_colors.dart';
import 'package:wujidt/core/utils/app_assets.dart';
import 'package:wujidt/core/widgets/custom_svg_wrapper.dart';

class HomeSelectionBottomBar extends StatelessWidget {
  final int selectedCount;
  final bool isDeleting;
  final bool isSharing;
  final VoidCallback onDelete;
  final VoidCallback onShare;

  const HomeSelectionBottomBar({
    super.key,
    required this.selectedCount,
    required this.isDeleting,
    required this.isSharing,
    required this.onDelete,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.withValues(alpha: 0.2))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$selectedCount Selected",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          Row(
            children: [
              _buildActionButton(
                label: "Delete",
                color: Colors.red,
                iconPath: AppAssets.delete,
                isLoading: isDeleting,
                onTap: selectedCount > 0 && !isDeleting ? onDelete : null,
              ),
              SizedBox(width: 20.w),
              _buildActionButton(
                label: "Public",
                color: AppColors.primary,
                iconData: Icons.public,
                isLoading: isSharing,
                onTap: selectedCount > 0 && !isSharing ? onShare : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color color,
    String? iconPath,
    IconData? iconData,
    required bool isLoading,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoading)
            SizedBox(
              width: 24.w,
              height: 24.h,
              child: const CircularProgressIndicator(strokeWidth: 2),
            )
          else if (iconPath != null)
            CustomSvgWrapper(
              path: iconPath,
              iconWidth: 24.w,
              iconHeight: 24.h,
              color: onTap != null ? color : Colors.grey,
            )
          else
            Icon(
              iconData,
              color: onTap != null ? color : Colors.grey,
              size: 24.sp,
            ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              color: onTap != null ? color : Colors.grey,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }
}