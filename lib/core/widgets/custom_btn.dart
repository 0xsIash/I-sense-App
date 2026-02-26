import 'package:flutter/material.dart';
import 'package:isense/core/utils/app_colors.dart';

class CustomBtn extends StatelessWidget {
  const CustomBtn({super.key, required this.text, required this.btnWidth, required this.btnHeight,required this.onPressed, required this.weight, required this.size, required this.fontFamily, required this.eleveation});

  final String text;
  final double btnWidth;
  final double btnHeight;
  final VoidCallback onPressed;
  final FontWeight weight;
  final double size;
  final String fontFamily;
  final double eleveation;

  

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: btnWidth,
      height: btnHeight,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.foregroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          shadowColor: Color.fromARGB(190, 0, 0, 0),
          elevation: eleveation
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
            fontWeight: weight,
            fontSize:size,
            fontFamily: fontFamily,
          ),
          )

        ),
    );
  }
}