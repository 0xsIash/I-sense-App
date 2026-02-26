import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:isense/core/utils/app_colors.dart';
import 'package:isense/features/home/models/scan_item_model.dart';
import 'package:isense/features/home/widgets/scan_item_card.dart';
import 'package:isense/features/home/widgets/item_details_view.dart';

class HistoryTab extends StatelessWidget {
  final List<ScanItemModel> items;
  final Function(ScanItemModel item) onDelete;

  const HistoryTab({super.key, required this.items, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          "No history yet.",
          style: TextStyle(
            color: AppColors.unActive,
            fontSize: 16.sp,
          ),
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
        childAspectRatio: 0.75,
      ),
      itemBuilder: (context, index) {
        final item = items[index];

        List<String> tagsList = ["Processing..."];
        if (item.extractedItems != null && item.extractedItems!.isNotEmpty) {
          tagsList = item.extractedItems!
              .map((e) => e.category) 
              .toSet() 
              .take(2) 
              .toList();
        } else if (item.status == 'completed') {
           tagsList = ["No items"];
        }

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ItemDetailsView(item: item),
              ),
            );
          },
          child: ScanItemCard(
            imageFile: item.imageFile, 
            imageUrl: item.imageUrl, 
            
            onDelete: () => onDelete(item),
            
            bottomContent: SizedBox(
              height: 24.h,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: tagsList.map((tag) => Container(
                  margin: EdgeInsets.only(right: 5.w),
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      tag,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                      ),
                    ),
                  ),
                )).toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}