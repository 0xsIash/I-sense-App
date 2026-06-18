import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:wujidt/core/utils/app_assets.dart';
import 'package:wujidt/core/utils/app_colors.dart';
import 'package:wujidt/core/utils/validators.dart';
import 'package:wujidt/core/widgets/custom_btn.dart';
import 'package:wujidt/core/widgets/custom_text_form_field.dart';
import 'package:wujidt/features/auth/services/auth_service.dart';
import 'package:wujidt/features/auth/widgets/custom_checkbox.dart';
import 'package:wujidt/features/auth/widgets/custom_text.dart';
import 'package:wujidt/features/auth/widgets/custom_title.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String completePhoneNumber = "";
  bool isRememberMe = false;
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackgrond,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 30.h),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: CustomTitle(text: "Sign Up"),
                ),
                SizedBox(height: 40.h),
                CustomTextFormField(
                  label: "Name",
                  prefixIcon: AppAssets.person,
                  controller: nameController,
                  isPassword: false,
                  keyboardType: TextInputType.text,
                  iconWidth: 16,
                  iconHeight: 16,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Name is required";
                    }
                    return null;
                  },
                ),
                CustomTextFormField(
                  label: "Email",
                  prefixIcon: AppAssets.email,
                  controller: emailController,
                  isPassword: false,
                  keyboardType: TextInputType.emailAddress,
                  iconWidth: 17,
                  iconHeight: 12,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Email is required";
                    }
                    if (!isValidEmail(value)) {
                      return "Enter a valid email";
                    }
                    return null;
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SvgPicture.asset(
                            AppAssets.phone,
                            width: 16.w,
                            height: 16.h,
                            colorFilter: ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            "Phone number",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w400,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      IntlPhoneField(
                        controller: phoneController,
                        initialCountryCode: 'EG',
                        disableLengthCheck: false,
                        dropdownIconPosition: IconPosition.trailing,
                        flagsButtonPadding: EdgeInsets.only(left: 12.w, right: 8.w),
                        dropdownIcon: Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
                        style: TextStyle(fontSize: 14.sp),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.primaryBackgrond,
                          contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide(color: AppColors.primary, width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide(color: AppColors.primary, width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide(color: AppColors.primary, width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: const BorderSide(color: Colors.red, width: 2),
                          ),
                        ),
                        onChanged: (phone) {
                          completePhoneNumber = phone.completeNumber;
                        },
                      ),
                      SizedBox(height: 10.h),
                    ],
                  ),
                ),
                CustomTextFormField(
                  label: "Password",
                  prefixIcon: AppAssets.lock,
                  controller: passwordController,
                  isPassword: true,
                  keyboardType: TextInputType.text,
                  iconWidth: 12,
                  iconHeight: 15.75,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Password is required";
                    }
                    if (value.length < 6) {
                      return "Password must be at least 6 characters";
                    }
                    return null;
                  },
                ),
                CustomTextFormField(
                  label: "Verify Password",
                  prefixIcon: AppAssets.lock,
                  controller: confirmPasswordController,
                  isPassword: true,
                  keyboardType: TextInputType.text,
                  iconWidth: 12,
                  iconHeight: 15.75,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Confirm password is required";
                    }
                    if (value != passwordController.text) {
                      return "Passwords do not match";
                    }
                    return null;
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: CustomCheckbox(
                    value: isRememberMe,
                    onChanged: (value) {
                      setState(() {
                        isRememberMe = value!;
                      });
                    },
                  ),
                ),
                SizedBox(height: 50.h),
                Center(
                  child: Column(
                    children: [
                      CustomBtn(
                        text: _isLoading ? "Creating..." : "Signup",
                        btnWidth: 244.w,
                        btnHeight: 32.h,
                        weight: FontWeight.w600,
                        size: 16.sp,
                        eleveation: 8,
                        fontFamily: 'Kreon',
                        onPressed: _isLoading
                            ? () {}
                            : () async {
                                if (_formKey.currentState!.validate()) {
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  try {
                                    await _authService.signup(
                                      userName: nameController.text.trim(),
                                      email: emailController.text.trim(),
                                      phoneNumber: completePhoneNumber,
                                      password: passwordController.text,
                                    );
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("Account created successfully! Please Login."),
                                          backgroundColor: Colors.green,
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                      Navigator.pushReplacementNamed(context, "login");
                                    }
                                  } catch (e) {
                                    String errorMsg = e.toString().replaceAll("Exception: ", "");
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(errorMsg),
                                          backgroundColor: Colors.red,
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    }
                                  } finally {
                                    if (context.mounted) {
                                      setState(() {
                                        _isLoading = false;
                                      });
                                    }
                                  }
                                }
                              },
                      ),
                      SizedBox(height: 8.h),
                      SizedBox(
                        width: 244.w,
                        child: CustomText(
                          question: "have an account ? ",
                          text: "Login!",
                          onTap: () {
                            Navigator.pushReplacementNamed(context, "login");
                          },
                        ),
                      ),
                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}