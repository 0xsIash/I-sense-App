import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:isense/core/utils/app_assets.dart';
import 'package:isense/core/utils/app_colors.dart';
import 'package:isense/core/utils/validators.dart';
import 'package:isense/core/widgets/custom_btn.dart';
import 'package:isense/core/widgets/custom_text_form_field.dart';
import 'package:isense/features/auth/services/auth_service.dart';
import 'package:isense/features/auth/widgets/custom_checkbox.dart';
import 'package:isense/features/auth/widgets/custom_text.dart';
import 'package:isense/features/auth/widgets/custom_title.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isRememberMe = false;

  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColors.primaryBackgrond,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 70.h),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: CustomTitle(text: "Log In"),
                ),
                SizedBox(height: 40.h),

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

                SizedBox(height: 240.h),
                Center(
                  child: Column(
                    children: [
                      CustomBtn(
                        text: _isLoading ? "Loading..." : "Login",
                        
                        btnWidth: 244.w,
                        btnHeight: 32.h,
                        weight: FontWeight.w600,
                        size: 16.sp,
                        eleveation: 8,
                        fontFamily: 'Nunito Sans',
                        
                        onPressed: _isLoading ? () {} : () async { 
                          if (_formKey.currentState!.validate()) {
                            
                            setState(() {
                              _isLoading = true;
                            });

                            try {
                              await _authService.login(
                                emailController.text.trim(), 
                                passwordController.text,
                              );
                              
                              String userName = await _authService.login(
                                emailController.text.trim(),
                                passwordController.text,
                              );

                              if (context.mounted) {
                                Navigator.pushReplacementNamed(context, "home",arguments: userName);
                              }

                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      e.toString().replaceAll("Exception: ", ""), 
                                      style: const TextStyle(color: Colors.white),
                                    ),
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
                          question: "Don’t have an account ? ",
                          text: "create one!",
                          onTap: () {
                            Navigator.pushReplacementNamed(context, "signup");
                          },
                        ),
                      ),
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
