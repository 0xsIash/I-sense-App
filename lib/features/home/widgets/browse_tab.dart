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
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  // الدالة المسؤولة عن جلب البيانات وتحديث القائمة
  Future<void> _loadImages() async {
    try {
      // نستخدم getPublicFeedEndpoint الذي أضفناه سابقاً في ApiConstants
      final response = await _dio.get(ApiConstants.getPublishedImages);

      if (response.statusCode == 200) {
        List data = response.data;

        if (mounted) {
          setState(() {
            // استخدام fromFeedJson لضمان تركيب روابط الصور بشكل صحيح
            items = data.map((e) => ScanItemModel.fromFeedJson(e, ApiConstants.baseUrl)).toList();
            isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading public images: $e");
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // إضافة RefreshIndicator للسماح بتحديث الصفحة عند السحب لأسفل
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadImages, // ربط السحب بدالة جلب البيانات
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (items.isEmpty) {
      // استخدام ListView هنا ضروري ليتمكن المستخدم من السحب لأسفل حتى لو القائمة فارغة
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.3),
          Center(
            child: Column(
              children: [
                Icon(Icons.image_not_supported_outlined, size: 50.sp, color: Colors.grey),
                SizedBox(height: 10.h),
                Text(
                  "No public items found",
                  style: TextStyle(color: Colors.grey, fontSize: 16.sp),
                ),
                Text(
                  "Pull down to refresh",
                  style: TextStyle(color: Colors.grey[400], fontSize: 12.sp),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return GridView.builder(
      // AlwaysScrollableScrollPhysics تجعل الـ Grid قابلاً للسحب حتى لو كان عدد العناصر قليلاً
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15.w,
        mainAxisSpacing: 15.h,
        childAspectRatio: 0.82,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildItemCard(item);
      },
    );
  }

  Widget _buildItemCard(ScanItemModel item) {
    Widget bottomWidget;

    if (item.extractedItems != null && item.extractedItems!.isNotEmpty) {
      bottomWidget = SizedBox(
        height: 25.h,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: item.extractedItems!
              .map((e) => e.category.toString())
              .toSet()
              .take(2)
              .map((tag) => Container(
                    margin: EdgeInsets.only(right: 5.w),
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Center(
                      child: Text(
                        tag,
                        style: TextStyle(color: Colors.white, fontSize: 10.sp),
                      ),
                    ),
                  ))
              .toList(),
        ),
      );
    } else {
      bottomWidget = Center(
        child: Text(
          "completed",
          style: TextStyle(color: Colors.grey, fontSize: 11.sp, fontStyle: FontStyle.italic),
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
  }
}