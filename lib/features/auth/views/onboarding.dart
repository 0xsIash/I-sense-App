import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wujidt/core/utils/app_colors.dart';
import 'package:wujidt/core/widgets/custom_btn.dart';
import 'package:wujidt/features/auth/widgets/onboarding_pages.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  bool isLastPage = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String userName =
        (ModalRoute.of(context)?.settings.arguments as String?) ?? "User";

    return Scaffold(
      backgroundColor: AppColors.primaryBackgrond,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackgrond,
        elevation: 0,
        actions: [
          if (!isLastPage)
            TextButton(
              onPressed: () => _pageController.animateToPage(
                5,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              ),
              child: Text(
                "Skip",
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'IBMPlexSans',
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) =>
                  setState(() => isLastPage = index == 5),
              children: [
                const FirstPage(),
                CameraPage(animationController: _animationController),
                AIProcessingPage(animationController: _animationController),
                FindItemsPage(animationController: _animationController),
                const DetailsPage(),
                GetStartedPage(animationController: _animationController),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            child: Column(
              children: [
                SmoothPageIndicator(
                  controller: _pageController,
                  count: 6,
                  effect: ExpandingDotsEffect(
                    activeDotColor: AppColors.primary,
                    dotColor: Colors.grey.shade300,
                    dotHeight: 8.h,
                    dotWidth: 8.w,
                    expansionFactor: 4,
                  ),
                ),
                SizedBox(height: 30.h),
                CustomBtn(
                  text: isLastPage ? "Get Started" : "Next  >",
                  onPressed: () {
                    if (isLastPage) {
                      Navigator.pushReplacementNamed(
                        context,
                        "home",
                        arguments: userName,
                      );
                    } else {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  btnWidth: double.infinity,
                  btnHeight: 48.h,
                  size: 16.sp,
                  weight: FontWeight.w600,
                  fontFamily: 'IBMPlexSans',
                  eleveation: 8,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}