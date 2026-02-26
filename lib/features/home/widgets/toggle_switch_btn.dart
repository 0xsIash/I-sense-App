import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:isense/core/utils/app_colors.dart';

class ToggleSwitchBtn extends StatelessWidget {
  const ToggleSwitchBtn({super.key, required this.isProcessing, required this.onChanged});

  final bool isProcessing;
  final ValueChanged<bool> onChanged; 

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child:_buildOtionBtn(
          text: "Processing",
          isActive: isProcessing,
          onTap: () => onChanged(true),
          ),
          ),

          SizedBox(width: 15.w),

        Expanded(
          child:_buildOtionBtn(
          text: "History",
          isActive: !isProcessing,
          onTap: () => onChanged(false),
          ),
          ),

      ],
    );
  }
}

Widget _buildOtionBtn({
  required String text,
    required bool isActive,
    required VoidCallback onTap,
}){
  return GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 40.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isActive? AppColors.indigoBlue : Colors.transparent,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.primary,
          width: 1.5
        ),
      ),

      child: Text(
        text,
        style: TextStyle(
          color: AppColors.primary,
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          fontFamily: "Kreon"
        ),
      ),
      ),
  );
}