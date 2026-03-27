import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:isense/core/utils/app_colors.dart';
import 'package:isense/core/utils/api_constants.dart';
import 'package:isense/features/home/models/scan_item_model.dart';
import 'package:isense/features/home/widgets/item_details_view.dart';
import 'package:isense/features/home/widgets/scan_item_card.dart';
import 'package:dio/dio.dart';

class BrowseTab extends StatefulWidget {
  const BrowseTab({super.key});

  @override
  State<BrowseTab> createState() => _BrowseTabState();
}

class _BrowseTabState extends State<BrowseTab> {
  List<ScanItemModel> items = [];
  bool isLoading = true;

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    try {
      final response = await _dio.get(ApiConstants.getPublishedImages);

      if (response.statusCode == 200) {
        List data = response.data;

        setState(() {
          // خلى كل الصور public من السيرفر تظهر
          items = data.map((e) => ScanItemModel.fromJson(e)).toList();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("Error loading public images: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (items.isEmpty) {
      return Center(
        child: Text(
          "No public items found",
          style: TextStyle(color: Colors.grey, fontSize: 16.sp),
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
        childAspectRatio: 0.85,
      ),
      itemBuilder: (context, index) {
        final item = items[index];

        Widget bottomWidget;

        if (item.extractedItems != null && item.extractedItems!.isNotEmpty) {
          bottomWidget = ListView(
            scrollDirection: Axis.horizontal,
            children: item.extractedItems!
                .map((e) => e.category)
                .toSet()
                .take(2)
                .map(
                  (tag) => Container(
                    margin: EdgeInsets.only(right: 5.w),
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        tag,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          );
        } else {
          bottomWidget = Center(
            child: Text(
              "Completed",
              style: TextStyle(color: Colors.grey, fontSize: 12.sp),
            ),
          );
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
            bottomContent: bottomWidget,
          ),
        );
      },
    );
  }
}