import 'package:flutter/material.dart';
import 'package:isense/core/utils/app_colors.dart';

class CustomCheckbox extends StatelessWidget {
  const CustomCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min, 
      children: [
        SizedBox(
          height: 24, 
          width: 24,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            checkColor: Colors.white,
            
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, 
            
            visualDensity: VisualDensity.compact,

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            side: const BorderSide(
              color: AppColors.primary,
              width: 1.5,
            ),
          ),
        ),
        
        const SizedBox(width:3), 
        
        Text(
          "Remember me",
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}