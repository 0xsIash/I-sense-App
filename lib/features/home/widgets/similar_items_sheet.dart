import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:isense/core/utils/app_assets.dart';
import 'package:isense/core/utils/app_colors.dart';
import 'package:isense/core/widgets/custom_svg_wrapper.dart';

class SimilarItemsSheet extends StatelessWidget {
  const SimilarItemsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackgorud,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.r),
          topRight: Radius.circular(25.r),
        ),
        border: Border(
          top: BorderSide(color: Colors.transparent, width: 2),
          left: BorderSide(color: Colors.transparent, width: 2),
          right: BorderSide(color: Colors.transparent, width: 2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Similar",
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              fontFamily: 'Nunito Sans',
            ),
          ),
          SizedBox(height: 15.h),
          _buildStoreRow("Ikea", "1000\$"),
          _buildStoreRow("Amazon", "1500\$"),
          _buildStoreRow("Ikea", "1000\$"),
          _buildStoreRow("Amazon", "1500\$"),
        ],
      ),
    );
  }

  Widget _buildStoreRow(String storeName, String price) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      child: Row(
        children: [
          Icon(
            Icons.storefront_outlined,
            color: AppColors.primary,
            size: 24.sp,
          ),
          SizedBox(width: 10.w),
          Text(
            storeName,
            style: TextStyle(
              fontSize: 16.sp,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            price,
            style: TextStyle(
              fontSize: 16.sp,
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 10.w),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: Size(60.w, 30.h),
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: Row(
              children: [
                Text(
                  "Buy",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                  ),
                ),
                SizedBox(width: 4.w),
                CustomSvgWrapper(path: AppAssets.arrowBack)
              ],
            ),
          )
        ],
      ),
    );
  }
}
