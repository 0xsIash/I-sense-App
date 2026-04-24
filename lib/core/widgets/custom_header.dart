import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:isense/core/utils/app_colors.dart';
import 'package:isense/features/home/widgets/notification_page.dart';

class CustomHeader extends StatelessWidget {
  final String userName;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final int processingCount;
  final int historyCount;

  const CustomHeader({
    super.key,
    required this.userName,
    required this.scaffoldKey,
    required this.processingCount,
    required this.historyCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => scaffoldKey.currentState!.openDrawer(),
                child: Icon(Icons.menu, color: AppColors.primary, size: 28.sp),
              ),
              SizedBox(width: 12.w),
              Text(
                "Hello $userName !",
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationPage(
                    processingCount: processingCount,
                    historyCount: historyCount,
                  ),
                ),
              );
            },
            child: Icon(
              Icons.notifications_none,
              color: AppColors.primary,
              size: 28.sp,
            ),
          ),
        ],
      ),
    );
  }
}