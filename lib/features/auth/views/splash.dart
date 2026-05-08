import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wujidt/core/utils/app_assets.dart';
import 'package:wujidt/core/utils/app_colors.dart';
import 'package:wujidt/core/widgets/custom_btn.dart';
import 'package:wujidt/core/widgets/custom_svg_wrapper.dart';
import 'package:wujidt/features/auth/widgets/custom_text.dart';

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
                  SizedBox(height: 80.h),
                  Text(
                    "Wujidt",
                    style: TextStyle(
                      fontSize: 80.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.primary,
                      fontFamily: "combo",
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(flex: 1),
                  Image.asset(
                    AppAssets.splash_2,
                    width: 0.99.sw,
                  ),
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
                      question: "Don't have an account ? ",
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