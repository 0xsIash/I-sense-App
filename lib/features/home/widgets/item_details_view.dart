import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wujidt/core/utils/app_assets.dart';
import 'package:wujidt/core/utils/app_colors.dart';
import 'package:wujidt/core/widgets/custom_svg_wrapper.dart';
import 'package:wujidt/features/home/models/scan_item_model.dart';
import 'package:wujidt/features/home/services/job_service.dart';
import 'package:wujidt/features/home/widgets/contact_finder_sheet.dart';
import 'package:wujidt/features/home/widgets/main_layout.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ItemDetailsView extends StatefulWidget {
  final ScanItemModel item;
  final int currentUserId;

  const ItemDetailsView({
    super.key,
    required this.item,
    required this.currentUserId,
  });

  @override
  State<ItemDetailsView> createState() => _ItemDetailsViewState();
}

class _ItemDetailsViewState extends State<ItemDetailsView> {
  final JobService _jobService = JobService();
  bool _isActionLoading = false;

  Future<void> _handlePublishAction() async {
    setState(() => _isActionLoading = true);
    bool success;
    final int imageId = widget.item.imageId ?? widget.item.id ?? 0;

    if (widget.item.isPublic) {
      success = await _jobService.unPublishImage(imageId);
    } else {
      success = await _jobService.publishImage(imageId);
    }

    if (success && mounted) {
      setState(() {
        widget.item.isPublic = !widget.item.isPublic;
        _isActionLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.item.isPublic ? "Published Successfully" : "Unpublished Successfully"),
          backgroundColor: AppColors.primary,
        ),
      );
    } else if (mounted) {
      setState(() => _isActionLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Action Failed"), backgroundColor: Colors.red),
      );
    }
  }

  void _openContactFinder(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        return ContactFinderSheet(
          uploaderName: widget.item.userName ?? "Unknown User",
          phoneNumber: widget.item.phoneNumber ?? "No Phone Provided",
          locationName: widget.item.locationName ?? "Unknown Location",
          onMapPressed: () {
            Navigator.pop(context);
            Navigator.pop(context);
            if (widget.item.latitude != null && widget.item.longitude != null) {
              MainLayout.targetMapLocation.value = {
                'id': widget.item.id,
                'latitude': widget.item.latitude,
                'longitude': widget.item.longitude,
                'title': widget.item.locationName ?? "Image Location",
              };
              MainLayout.navigationTrigger.value = 2;
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Location coordinates not available for this image")),
              );
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final extractedList = widget.item.extractedItems ?? [];

    final bool isRealOwner = widget.item.userId != null && 
                             widget.item.userId != 0 && 
                             (widget.item.userId == widget.currentUserId || 
                              widget.item.userId.toString() == widget.currentUserId.toString());

    final bool showPublishControls = !widget.item.isPublic || isRealOwner;

    final List<String> tags = extractedList
        .map((e) => e.name.toString())
        .toSet()
        .toList()
        .cast<String>();

    ImageProvider? headerImage;
    if (widget.item.imageFile != null) {
      headerImage = FileImage(widget.item.imageFile!);
    } else if (widget.item.annotatedUrl != null) {
      headerImage = NetworkImage(widget.item.annotatedUrl!);
    }

    return Scaffold(
      backgroundColor: AppColors.primaryBackgrond,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
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
                            ? DecorationImage(image: headerImage, fit: BoxFit.cover)
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
                          Text("Tags", style: TextStyle(fontSize: 16.sp, color: AppColors.primary, fontFamily: 'Kreon', fontWeight: FontWeight.bold)),
                          SizedBox(height: 8.h),
                          tags.isEmpty
                              ? Text("No tags detected", style: TextStyle(color: Colors.grey, fontSize: 12.sp))
                              : Wrap(
                                  spacing: 8.w,
                                  runSpacing: 8.h,
                                  children: tags.map((tag) => Chip(
                                    label: Text(tag, style: TextStyle(color: Colors.white, fontSize: 12.sp, fontFamily: 'Kreon')),
                                    backgroundColor: AppColors.primary,
                                    padding: EdgeInsets.zero,
                                    labelPadding: EdgeInsets.symmetric(horizontal: 10.w),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                    side: BorderSide.none,
                                  )).toList(),
                                ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Text("Extracted Items", style: TextStyle(fontSize: 16.sp, color: AppColors.primary, fontFamily: 'Kreon', fontWeight: FontWeight.bold)),
                    ),
                    SizedBox(height: 10.h),
                    extractedList.isEmpty
                        ? Padding(padding: EdgeInsets.all(20.h), child: const Center(child: Text("No items detected yet.")))
                        : GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                            itemCount: extractedList.length,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 15.w,
                              mainAxisSpacing: 15.h,
                              childAspectRatio: 0.75,
                            ),
                            itemBuilder: (context, index) {
                              final extractedItem = extractedList[index];
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.vertical(top: Radius.circular(15.r)),
                                        child: CachedNetworkImage(
                                          imageUrl: extractedItem.imageUrl ?? "",
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => Center(
                                            child: SizedBox(
                                              width: 20.w,
                                              height: 20.w,
                                              child: const CircularProgressIndicator(strokeWidth: 2),
                                            ),
                                          ),
                                          errorWidget: (context, url, error) => const Icon(Icons.error),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(10.w),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(20.r),
                                        ),
                                        child: Text(
                                          extractedItem.category,
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 13.sp,
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
            if (!showPublishControls)
              Padding(
                padding: EdgeInsets.all(20.w),
                child: SizedBox(
                  width: double.infinity,
                  height: 45.h,
                  child: ElevatedButton.icon(
                    onPressed: () => _openContactFinder(context),
                    icon: const Icon(Icons.person_search, color: Colors.white),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                    ),
                    label: Text("Contact Finder", style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold, fontFamily: 'Kreon')),
                  ),
                ),
              ),
            if (showPublishControls)
              Padding(
                padding: EdgeInsets.all(20.w),
                child: SizedBox(
                  width: double.infinity,
                  height: 45.h,
                  child: ElevatedButton(
                    onPressed: _isActionLoading ? null : _handlePublishAction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.item.isPublic ? Colors.redAccent : AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                    ),
                    child: _isActionLoading
                        ? SizedBox(width: 20.w, height: 20.w, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(widget.item.isPublic ? "Unpublish" : "Publish", style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}