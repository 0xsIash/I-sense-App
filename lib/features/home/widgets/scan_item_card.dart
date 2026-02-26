import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:isense/core/utils/app_assets.dart';
import 'package:isense/core/utils/app_colors.dart';
import 'package:isense/core/widgets/custom_svg_wrapper.dart';

class ScanItemCard extends StatelessWidget {
  final File? imageFile;
  final String? imageUrl;
  final VoidCallback onDelete;
  final Widget bottomContent;

  const ScanItemCard({
    super.key,
    this.imageFile,
    this.imageUrl,
    required this.onDelete,
    required this.bottomContent,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null) {
      debugPrint("🖼️ ScanItemCard IMAGE URL: $imageUrl");
    }
    if (imageFile != null) {
      debugPrint("📁 ScanItemCard IMAGE FILE: ${imageFile!.path}");
    }

    ImageProvider? imageProvider;
    
    if (imageFile != null) {
      imageProvider = FileImage(imageFile!);
      debugPrint("✅ Using FileImage");
    } 
    else if (imageUrl != null && imageUrl!.isNotEmpty) {
      imageProvider = NetworkImage(imageUrl!);
      debugPrint("✅ Using NetworkImage: $imageUrl");
    }
    else {
      debugPrint("❌ No image available!");
    }

    return Container(
      width: 155.w,
      height: 165.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 10.h,
            right: 10.w,
            child: InkWell(
              onTap: onDelete,
              child: CustomSvgWrapper(
                path: AppAssets.delete,
                iconWidth: 18.w,
                iconHeight: 18.h,
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 15.h),

                Container(
                  width: 103.w,
                  height: 103.w,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryBackgorud,
                    borderRadius: BorderRadius.circular(16.r),
                    image: imageProvider != null
                        ? DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: imageProvider == null
                      ? Icon(
                          Icons.image_not_supported,
                          color: Colors.grey[400],
                          size: 30.sp,
                        )
                      : null,
                ),

                SizedBox(height: 10.h),

                bottomContent,
              ],
            ),
          ),
        ],
      ),
    );
  }
}