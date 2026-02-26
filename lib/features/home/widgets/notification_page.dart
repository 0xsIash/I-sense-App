import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:isense/core/utils/app_colors.dart';

class NotificationPage extends StatelessWidget {
  final int processingCount;
  final int historyCount;

  const NotificationPage({
    super.key,
    required this.processingCount,
    required this.historyCount,
  });

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
          "Notifications",
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
            fontFamily: 'Nunito Sans',
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: Column(
          children: [
            if (processingCount > 0)
              _buildNotificationCard(
                text: "Processing $processingCount items...",
                isCompleted: false,
              )
            else
              _buildNotificationCard(
                text: "No items currently processing",
                isCompleted: false, 
              ),

            SizedBox(height: 15.h),

            if (historyCount > 0)
              _buildNotificationCard(
                text: "Completed processing $historyCount items !",
                isCompleted: true,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard({required String text, required bool isCompleted}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: isCompleted ? const Color(0xFFD9D9D9).withValues(alpha: 0.5) : Colors.white,
        border: isCompleted 
            ? null 
            : Border.all(color: AppColors.primary.withValues(alpha: 0.5), width: 1.5),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.primary, 
          fontWeight: FontWeight.bold,
          fontSize: 16.sp,
          fontFamily: 'Kreon', 
        ),
      ),
    );
  }
}