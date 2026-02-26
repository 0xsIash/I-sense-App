import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:isense/core/utils/app_assets.dart';
import 'package:isense/core/utils/app_colors.dart';
import 'package:isense/core/widgets/custom_svg_wrapper.dart';
import 'package:isense/features/home/models/scan_item_model.dart';
import 'package:isense/features/home/widgets/extracted_item_card.dart'; 
import 'package:isense/features/home/widgets/similar_items_sheet.dart';

class ItemDetailsView extends StatelessWidget {
  final ScanItemModel item;

  const ItemDetailsView({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final extractedList = item.extractedItems ?? [];

    final double totalPrice = extractedList.fold(0, (sum, item) => sum + item.price);

    final List<String> tags = extractedList.map((e) => e.name).toSet().toList();

    ImageProvider? headerImage;
    if (item.imageFile != null) {
      headerImage = FileImage(item.imageFile!);
    } else if (item.imageUrl != null) {
      headerImage = NetworkImage(item.imageUrl!);
    }

    return Scaffold(
      backgroundColor: AppColors.primaryBackgrond,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  child: CustomSvgWrapper(path: AppAssets.arrowBack),
                ),
              ),

              Container(
                margin: EdgeInsets.symmetric(horizontal: 20.w),
                height: 350.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  color: Colors.grey[200], 
                  image: headerImage != null
                      ? DecorationImage(
                          image: headerImage,
                          fit: BoxFit.cover,
                        )
                      : null, 
                ),
                child: headerImage == null
                    ? Icon(Icons.image, size: 50.sp, color: Colors.grey[400])
                    : null,
              ),
              
              SizedBox(height: 15.h),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Tags",
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: AppColors.primary,
                        fontFamily: 'Kreon',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    
                    tags.isEmpty 
                    ? Text("No tags detected", style: TextStyle(color: Colors.grey, fontSize: 12.sp))
                    : Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: tags.map((tag) => Chip(
                        label: Text(
                          tag,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontFamily: 'Kreon',
                          ),
                        ),
                        backgroundColor: AppColors.primary,
                        padding: EdgeInsets.zero,
                        labelPadding: EdgeInsets.symmetric(horizontal: 10.w),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        side: BorderSide.none,
                      )).toList(),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 15.h),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  children: [
                    Text(
                      "Total Estimated Cost",
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: AppColors.primary,
                        fontFamily: 'Kreon',
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      "${totalPrice.toInt()} EGP",
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        fontFamily: 'Kreon',
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 5.h),
                width: 100.w,
                height: 2.h,
                color: const Color(0xffE5E8F3),
              ),

              SizedBox(height: 15.h),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Text(
                  "Extracted Items",
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.primary,
                    fontFamily: 'Kreon',
                  ),
                ),
              ),

              SizedBox(height: 10.h),

              extractedList.isEmpty 
              ? Padding(
                  padding: EdgeInsets.all(20.h),
                  child: Center(child: Text("No items detected yet.")),
                )
              : GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  itemCount: extractedList.length, 
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15.w,
                    mainAxisSpacing: 15.h,
                    childAspectRatio: 0.70,
                  ),
                  itemBuilder: (context, index) {
                    final extractedItem = extractedList[index];

                    return ExtractedItemCard(
                      item: extractedItem,
                      
                      mainImageFile: item.imageFile, 
                      
                      onFindSimilar: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder: (context) => const SimilarItemsSheet(),
                        );
                      },
                    );
                  },
                ),

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}