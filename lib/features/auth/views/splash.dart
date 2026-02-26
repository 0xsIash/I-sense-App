import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:isense/core/utils/app_assets.dart';
import 'package:isense/core/utils/app_colors.dart';
import 'package:isense/core/widgets/custom_btn.dart';
import 'package:isense/core/widgets/custom_svg_wrapper.dart';
import 'package:isense/features/auth/widgets/custom_text.dart';

class Splash extends StatelessWidget {
  const Splash({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackgrond,
      body: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomSvgWrapper(
              path: AppAssets.splash_1,
              iconWidth: 1.0.sw,
            ),
          ),
          SafeArea(
            child: SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  Text(
                    "I Sense",
                    style: TextStyle(
                      fontSize: 80.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.primary,
                      fontFamily: "MervaleScript",
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(flex: 1),
                  CustomSvgWrapper(
                    path: AppAssets.splash_2,
                    iconWidth: 0.7.sw,
                  ),
                  const Spacer(flex: 1),
                  CustomBtn(
                    text: "Login",
                    onPressed: () {
                      Navigator.pushNamed(context, "login");
                    },
                    btnWidth: 244.w,
                    btnHeight: 32.h,
                    weight: FontWeight.w600,
                    size: 16.sp,
                    eleveation: 8,
                    fontFamily: 'Nunito Sans',
                  ),
                  SizedBox(height: 15.h),
                  SizedBox(
                    width: 244.w,
                    child: CustomText(
                      question: "Don’t have an account ? ",
                      text: "create one!",
                      onTap: () {
                        Navigator.pushNamed(context, "signup");
                      },
                    ),
                  ),
                  const Spacer(flex: 4),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
