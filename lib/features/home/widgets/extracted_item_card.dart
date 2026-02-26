import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart'; 
import 'package:isense/core/utils/app_colors.dart';
import 'package:isense/features/home/models/extracted_item_model.dart';

class ExtractedItemCard extends StatelessWidget {
  final ExtractedItemModel item;
  final File? mainImageFile;
  final VoidCallback onFindSimilar;

  const ExtractedItemCard({
    super.key,
    required this.item,
    this.mainImageFile,
    required this.onFindSimilar,
  });

  @override
  Widget build(BuildContext context) {

    ImageProvider? imageProvider;
    if (item.imageUrl != null) {
      imageProvider = CachedNetworkImageProvider(item.imageUrl!); 
    } else if (mainImageFile != null) {
      imageProvider = FileImage(mainImageFile!);
    }

    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                color: AppColors.secondaryBackgorud,
                image: imageProvider != null
                    ? DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: imageProvider == null
                  ? Icon(Icons.image_not_supported, color: Colors.grey[400])
                  : null,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(width: 5.w),
              Text(
                "${item.price.toInt()} EGP",
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          SizedBox(
            width: double.infinity,
            height: 28.h,
            child: ElevatedButton(
              onPressed: onFindSimilar,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.r),
                ),
              ),
              child: Text(
                "Find Similar",
                style: TextStyle(color: Colors.white, fontSize: 10.sp),
              ),
            ),
          )
        ],
      ),
    );
  }
}