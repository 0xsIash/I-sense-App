import 'package:flutter/material.dart';
import 'package:isense/core/utils/app_colors.dart';
import 'package:isense/core/widgets/custom_svg_wrapper.dart';

class CustomTextFormField extends StatefulWidget {
  const CustomTextFormField({
    super.key,
    required this.label,
    required this.prefixIcon,
    this.controller,
    required this.isPassword,
    required this.keyboardType,
    required this.iconWidth,
    required this.iconHeight,
    this.validator,
  });

  final String label;
  final String prefixIcon;
  final TextEditingController? controller;
  final bool isPassword;
  final TextInputType keyboardType;
  final double iconWidth;
  final double iconHeight;
  final String? Function(String?)? validator;

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField>
    with TickerProviderStateMixin {
  bool _obscureText = true;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  String? _validate(String? value) {
    final result = widget.validator?.call(value);

    setState(() {
      _errorText = result;
    });

    return result == null ? null : '';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomSvgWrapper(
                path: widget.prefixIcon,
                iconWidth: widget.iconWidth,
                iconHeight: widget.iconHeight,
              ),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: widget.controller,
            validator: _validate,
            cursorColor: AppColors.primary,
            obscureText: widget.isPassword ? _obscureText : false,
            keyboardType: widget.keyboardType,
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              errorStyle: const TextStyle(height: 0, fontSize: 0),
              suffixIcon: widget.isPassword
                  ? IconButton(
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                      icon: Icon(
                        _obscureText
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppColors.primary,
                      ),
                    )
                  : null,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: Colors.red, width: 2),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: Colors.red, width: 2),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: Visibility(
              visible: _errorText != null,
              maintainState: true,
              maintainAnimation: true,
              maintainSize: true,
              child: Padding(
                padding: const EdgeInsets.only(top: 3, left: 12),
                child: Text(
                  _errorText ?? '',
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
