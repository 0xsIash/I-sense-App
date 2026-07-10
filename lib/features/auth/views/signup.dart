import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:dio/dio.dart';
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
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

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
  bool _showPhoneError = false;
  DateTime? _lastBackPressed;
  String _countryCode = 'EG';

    @override
    void initState() {
      super.initState();
      getCurrentCountry();
    }

  Future<void> getCurrentCountry() async {
  try {
    LocationPermission permission =
        await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    Position position =
        await Geolocator.getCurrentPosition();

    List<Placemark> placemarks =
        await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isNotEmpty) {
      setState(() {
        _countryCode =
            placemarks.first.isoCountryCode ?? 'EG';
      });
    }
  } catch (e) {
    debugPrint(e.toString());
  }
}


  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        final now = DateTime.now();

        if (_lastBackPressed == null ||
            now.difference(_lastBackPressed!) > const Duration(seconds: 2)) {
          _lastBackPressed = now;

          ScaffoldMessenger.of(context).hideCurrentSnackBar();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Press back again to exit'),
              duration: Duration(seconds: 2),
            ),
          );

          return;
        }

        SystemNavigator.pop();
      },
      child: Scaffold(
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
                  SizedBox(height: 15.h),
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
                  SizedBox(height: 15.h),
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
                              colorFilter: ColorFilter.mode(
                                AppColors.primary,
                                BlendMode.srcIn,
                              ),
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
                          initialCountryCode: _countryCode,
                          disableLengthCheck: false,
                          dropdownIconPosition: IconPosition.trailing,
                          flagsButtonPadding: EdgeInsets.only(
                            left: 12.w,
                            right: 8.w,
                          ),
                          dropdownIcon: Icon(
                            Icons.keyboard_arrow_down,
                            color: AppColors.primary,
                          ),
                          style: TextStyle(
                            fontSize: 14.sp,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.primaryBackgrond,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 12.h,
                              horizontal: 12.w,
                            ),
                            errorText: _showPhoneError
                                ? "Phone number is required"
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: const BorderSide(
                                color: Colors.red,
                                width: 2,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: const BorderSide(
                                color: Colors.red,
                                width: 2,
                              ),
                            ),
                          ),
                          onChanged: (phone) {
                            if (phone.number.isNotEmpty && _showPhoneError) {
                              setState(() {
                                _showPhoneError = false;
                              });
                            }

                            completePhoneNumber = phone.completeNumber;
                          },
                        ),
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
                  SizedBox(height: 8.h),
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
                  SizedBox(height: 8.h),
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
                                  if (phoneController.text.trim().isEmpty) {
                                    setState(() {
                                      _showPhoneError = true;
                                    });
                                  }

                                  bool isFormValid =
                                      _formKey.currentState!.validate();

                                  if (phoneController.text.trim().isEmpty ||
                                      !isFormValid) {
                                    return;
                                  }

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
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Account created successfully! Please Login.",
                                          ),
                                          backgroundColor: Colors.green,
                                          behavior:
                                              SnackBarBehavior.floating,
                                        ),
                                      );

                                      Navigator.pushReplacementNamed(
                                        context,
                                        "login",
                                      );
                                    }
                                  } catch (e) {
                                    String errorMsg =
                                        "Signup failed, please try again";

                                    if (e is DioException) {
                                      if (e.response?.statusCode == 400 ||
                                          e.response?.statusCode == 409) {
                                        errorMsg =
                                            "Email already exists!";
                                      } else if (e.type ==
                                              DioExceptionType
                                                  .connectionTimeout ||
                                          e.type ==
                                              DioExceptionType
                                                  .connectionError) {
                                        errorMsg =
                                            "No internet connection";
                                      }
                                    } else {
                                      if (e.toString().contains("400") ||
                                          e.toString().contains("409")) {
                                        errorMsg =
                                            "Email already exists!";
                                      }
                                    }

                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(errorMsg),
                                          backgroundColor: Colors.red,
                                          behavior:
                                              SnackBarBehavior.floating,
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
                                },
                        ),
                        SizedBox(height: 8.h),
                        SizedBox(
                          width: 244.w,
                          child: CustomText(
                            question: "have an account ? ",
                            text: "Login!",
                            onTap: () {
                              Navigator.pushReplacementNamed(
                                context,
                                "login",
                              );
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
      ),
    );
  }
}