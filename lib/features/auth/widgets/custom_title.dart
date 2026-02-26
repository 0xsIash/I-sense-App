import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:isense/core/utils/app_colors.dart';

class CustomTitle extends StatelessWidget {
  const CustomTitle({super.key, required this.text});

  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: AppColors.primary,
        fontWeight: FontWeight.w600,
        fontSize: 56.sp,
        fontFamily: "Nunito Sans",
      ),
    );
  }
}