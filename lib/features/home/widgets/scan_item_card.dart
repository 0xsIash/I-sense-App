import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:isense/core/utils/app_colors.dart';

class ScanItemCard extends StatelessWidget {
  final File? imageFile;
  final String? imageUrl;
  final Widget bottomContent;
  final bool isSelectionMode;
  final bool isSelected;

  const ScanItemCard({
    super.key,
    this.imageFile,
    this.imageUrl,
    required this.bottomContent,
    this.isSelectionMode = false,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;
    if (imageFile != null) {
      imageProvider = FileImage(imageFile!);
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      imageProvider = CachedNetworkImageProvider(imageUrl!);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.grey.withValues(alpha: 0.2),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: Padding(
                  padding: EdgeInsets.all(12.w), 
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: imageProvider != null
                        ? Image(image: imageProvider, fit: BoxFit.contain) 
                        : Icon(Icons.image_not_supported, color: Colors.grey[300], size: 40),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                  child: bottomContent,
                ),
              ),
            ],
          ),
          if (isSelectionMode)
            Positioned(
              top: 8.h,
              right: 8.w,
              child: Container(
                width: 20.w,
                height: 20.w,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(4.r),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.grey.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                child: isSelected
                    ? Icon(Icons.check, color: Colors.white, size: 14.sp)
                    : null,
              ),
            ),
        ],
      ),
    );
  }
}