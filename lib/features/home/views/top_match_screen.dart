import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wujidt/core/utils/app_colors.dart';
import 'package:wujidt/features/home/models/top_match_model.dart';
import 'package:wujidt/features/home/services/search_service.dart';
import 'package:wujidt/features/home/widgets/contact_finder_sheet.dart';

class TopMatchScreen extends StatefulWidget {
  final File searchImage;

  const TopMatchScreen({super.key, required this.searchImage});

  @override
  State<TopMatchScreen> createState() => _TopMatchScreenState();
}

class _TopMatchScreenState extends State<TopMatchScreen> {
  final SearchService _searchService = SearchService();
  bool isLoading = true;
  TopMatchResponse? responseData;

  @override
  void initState() {
    super.initState();
    _performSearch();
  }

  Future<void> _performSearch() async {
    final result = await _searchService.searchByImage(widget.searchImage);
    if (mounted) {
      setState(() {
        responseData = result;
        isLoading = false;
      });
    }
  }

  void _openContactFinder(TopMatchItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (sheetContext) => ContactFinderSheet(
        uploaderName: item.publisherUsername,
        phoneNumber: item.publisherPhone,
        locationName: item.locationName,
        onMapPressed: () {
          // TODO: Implement map navigation logic here
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Top match",
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            fontFamily: 'Kreon',
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : responseData == null
              ? const Center(child: Text("Error performing search"))
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15.r),
                    child: Image.file(
                      widget.searchImage,
                      height: 250.h,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  "Tags",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                    fontFamily: 'Kreon',
                  ),
                ),
                SizedBox(height: 8.h),
                Chip(
                  label: Text(
                    responseData!.detectedLabel,
                    style: TextStyle(color: AppColors.primary, fontFamily: 'Kreon', fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    side: BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
                SizedBox(height: 10.h),
                Divider(color: Colors.grey[300], thickness: 1.5),
                SizedBox(height: 10.h),
                Text(
                  "Found ${responseData!.totalFound} matches",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                    fontFamily: 'Kreon',
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 15.h,
              crossAxisSpacing: 15.w,
              childAspectRatio: 0.75,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = responseData!.results[index];
                return _buildMatchCard(item);
              },
              childCount: responseData!.results.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMatchCard(TopMatchItem item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(15.r)),
              child: Container(
                color: Colors.grey[100],
                child: Image.network(
                  item.segmentedImageUrl.isNotEmpty ? item.segmentedImageUrl : item.originalImageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Icon(Icons.image_not_supported, color: Colors.grey, size: 40.sp),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.w),
            child: Column(
              children: [
                Text(
                  item.objectLabel,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                    fontFamily: 'Kreon',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  "${(item.similarity * 100).toStringAsFixed(1)}% Match",
                  style: TextStyle(
                    color: Colors.green[700],
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.h),
                SizedBox(
                  width: double.infinity,
                  height: 30.h,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.r)),
                    ),
                    onPressed: () => _openContactFinder(item),
                    icon: Icon(Icons.phone, size: 14.sp, color: Colors.white),
                    label: Text(
                      "Contact Finder",
                      style: TextStyle(fontSize: 11.sp, color: Colors.white, fontFamily: 'Kreon'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}