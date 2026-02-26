import 'package:flutter/material.dart';
import 'package:isense/core/utils/app_colors.dart';

class CustomText extends StatelessWidget {
  const CustomText({super.key, required this.question, required this.text, required this.onTap});

  final String question;
  final String text;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center, 
      children: [
        Text(
          question,
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 14,
              fontWeight: FontWeight.w600,
          ),
        ),

        GestureDetector(
          onTap: onTap,
          child: Text(
            text,
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
              fontSize: 14,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],

    );
  }
}
