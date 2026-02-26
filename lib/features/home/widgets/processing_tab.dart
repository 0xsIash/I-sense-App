import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:isense/core/utils/app_colors.dart';
import 'package:isense/features/home/models/scan_item_model.dart';
import 'package:isense/features/home/widgets/scan_item_card.dart';

class ProcessingTab extends StatelessWidget {
  final List<ScanItemModel> items;
  final Function(ScanItemModel item) onDelete;

  const ProcessingTab({super.key, required this.items, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          "No items processing...",
          style: TextStyle(color: AppColors.unActive),
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15.w,
        mainAxisSpacing: 15.h,
        childAspectRatio: 155 / 175,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return ScanItemCard(
          imageFile: item.imageFile,
          onDelete: () => onDelete(item),
          bottomContent: Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: item.progress,
                    backgroundColor: AppColors.secondaryBackgorud,
                    color: AppColors.primary,
                    minHeight: 4.h,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                "${(item.progress * 100).toInt()}%",
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  fontFamily: 'Nunito Sans',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
