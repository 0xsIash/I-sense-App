import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wujidt/core/utils/app_colors.dart';
import 'package:wujidt/features/home/services/job_service.dart';
import 'package:wujidt/features/home/models/similar_product_model.dart';

class SimilarItemsSheet extends StatefulWidget {
  final int imageId;
  final int objId;

  const SimilarItemsSheet({super.key, required this.imageId, required this.objId});

  @override
  State<SimilarItemsSheet> createState() => _SimilarItemsSheetState();
}

class _SimilarItemsSheetState extends State<SimilarItemsSheet> {
  final JobService _jobService = JobService();
  List<SimilarProductModel> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      final results = await _jobService.getSimilarProducts(widget.imageId, widget.objId);

      if (!mounted) return;

      setState(() {
        products = results;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _launchUrl(String url) async {
    final messenger = ScaffoldMessenger.of(context); // ✅ ناخده قبل await

    final Uri uri = Uri.parse(url);

    final bool launched = await launchUrl(uri);

    if (!mounted) return;

    if (!launched) {
      messenger.showSnackBar(
        const SnackBar(content: Text("Could not open link")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.45,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackgorud,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.r),
          topRight: Radius.circular(25.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: 15.h),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          ),

          Text(
            "Similar Products",
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              fontFamily: 'Nunito Sans',
            ),
          ),
          SizedBox(height: 15.h),

          if (isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (products.isEmpty)
            const Expanded(child: Center(child: Text("No similar products found.")))
          else
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.only(bottom: 20.h),
                itemCount: products.length,
                itemBuilder: (context, index) => _buildStoreRow(products[index]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStoreRow(SimilarProductModel product) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: Image.network(
              product.thumbnail,
              width: 60.w,
              height: 60.w,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Icon(Icons.storefront, size: 30.sp, color: AppColors.primary),
            ),
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Text(
              product.vendorName,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => _launchUrl(product.productUrl),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            child: Text(
              "Buy",
              style: TextStyle(color: Colors.white, fontSize: 13.sp),
            ),
          )
        ],
      ),
    );
  }
}