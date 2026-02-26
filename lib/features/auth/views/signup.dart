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

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

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
                        
                        // تنسيقات الزر (كما هي)
                        btnWidth: 244.w,
                        btnHeight: 32.h,
                        weight: FontWeight.w600,
                        size: 16.sp,
                        eleveation: 8,
                        fontFamily: 'Nunito Sans',
                        
                        // 2. منطق التشغيل
                        onPressed: _isLoading ? () {} : () async {
                          // التأكد من صحة البيانات (بما فيها تطابق الباسورد الموجود في الـ TextFields)
                          if (_formKey.currentState!.validate()) {
                            
                            // بدء التحميل
                            setState(() {
                              _isLoading = true;
                            });

                            try {
                              // 3. إرسال البيانات للسيرفر
                              await _authService.signup(
                                userName: nameController.text.trim(), // الاسم
                                email: emailController.text.trim(),   // الإيميل
                                password: passwordController.text,    // الباسورد
                              );

                              // 4. في حالة النجاح
                              if (context.mounted) {
                                // إظهار رسالة نجاح خضراء
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Account created successfully! Please Login."),
                                    backgroundColor: Colors.green,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                
                                // الانتقال لصفحة تسجيل الدخول
                                Navigator.pushReplacementNamed(context, "login");
                              }

                            } catch (e) {
                              // 5. في حالة الفشل (مثلاً الإيميل مكرر)
                              // تنظيف نص الخطأ من كلمة Exception
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
                              // 6. إيقاف التحميل في كل الأحوال
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
