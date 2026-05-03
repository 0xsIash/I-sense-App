import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:isense/core/utils/app_assets.dart';
import 'package:isense/core/utils/app_colors.dart';
import 'package:isense/core/widgets/custom_svg_wrapper.dart';

class FirstPage extends StatelessWidget {
  const FirstPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30.w),
      child: Column(
        children: [
          SizedBox(height: 10.h),
          Text("Wujidt", style: TextStyle(fontSize: 80.sp, color: AppColors.primary, fontFamily: "combo")),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(width: 220.w, height: 220.w, decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 40, offset: const Offset(0, 10))])),
              CustomSvgWrapper(path: AppAssets.onboarding1, iconWidth: 0.8.sw),
            ],
          ),
          Text("Welcome to Wujidt", textAlign: TextAlign.center, style: TextStyle(fontSize: 26.sp, fontWeight: FontWeight.bold, color: AppColors.primary, fontFamily: 'IBMPlexSans')),
          SizedBox(height: 10.h),
          Text("Help pilgrims and Umrah performers\nrecover their lost belongings using\nartificial intelligence technology", textAlign: TextAlign.center, style: TextStyle(fontSize: 14.sp, color: AppColors.primary, height: 1.6, fontWeight: FontWeight.w500, fontFamily: 'IBMPlexSans')),
          SizedBox(height: 6.h),
          Text("Your quick guide to using the lost and found system", textAlign: TextAlign.center, style: TextStyle(fontSize: 12.sp, color: AppColors.primary, fontWeight: FontWeight.w500, fontFamily: 'IBMPlexSans')),
        ],
      ),
    );
  }
}

class CameraPage extends StatelessWidget {
  final AnimationController animationController;
  const CameraPage({super.key, required this.animationController});

  @override
  Widget build(BuildContext context) {
    final handAnimation = Tween<double>(begin: 0, end: 12).animate(CurvedAnimation(parent: animationController, curve: Curves.easeInOut));
    final circleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(CurvedAnimation(parent: animationController, curve: Curves.easeInOut));

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          SizedBox(height: 20.h),
          _StepHeader(number: "1", title: "How to report a missing item"),
          SizedBox(height: 30.h),
          _MobileFrame(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: handAnimation,
                  builder: (context, child) => Transform.translate(offset: Offset(0, handAnimation.value), child: Transform.rotate(angle: 3.14, child: const Icon(Icons.touch_app, color: Colors.orange, size: 40))),
                ),
                SizedBox(height: 18.h),
                _ClickHereLabel(),
                SizedBox(height: 20.h),
                _AnimatedCameraBtn(animation: circleAnimation),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          _InfoCard(text: "Press the camera button to take a picture of the missing item or choose a photo from the photo gallery."),
        ],
      ),
    );
  }
}

class AIProcessingPage extends StatelessWidget {
  final AnimationController animationController;
  const AIProcessingPage({super.key, required this.animationController});

  @override
  Widget build(BuildContext context) {
    final scanLineAnimation = Tween<double>(begin: 0, end: 140.h).animate(CurvedAnimation(parent: animationController, curve: Curves.linear));

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          SizedBox(height: 20.h),
          _StepHeader(number: "2", title: "AI Processing"),
          SizedBox(height: 30.h),
          _MobileFrame(
            showDivider: false,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 250.w, height: 150.h,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(15.r)),
                  child: Stack(
                    children: [
                      Positioned(top: 20.h, left: 30.w, child: _BoundingBox(label: "bag", color: Colors.green)),
                      Positioned(top: 50.h, right: 40.w, child: _BoundingBox(label: "passport", color: Colors.red[300]!)),
                      AnimatedBuilder(
                        animation: scanLineAnimation,
                        builder: (context, child) => Positioned(top: scanLineAnimation.value, left: 0, right: 0, child: Container(height: 2.h, color: AppColors.primary.withValues(alpha: 0.5))),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30.h),
                _AnalyzingStatus(),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          _InfoCard(text: "The system will automatically analyze the image and identify the elements within it."),
        ],
      ),
    );
  }
}

class FindItemsPage extends StatelessWidget {
  final AnimationController animationController;
  const FindItemsPage({super.key, required this.animationController});

  @override
  Widget build(BuildContext context) {
    final handAnimation = Tween<double>(begin: 0, end: 12).animate(CurvedAnimation(parent: animationController, curve: Curves.easeInOut));

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          SizedBox(height: 20.h),
          _StepHeader(number: "3", title: "Find missing items"),
          SizedBox(height: 30.h),
          Stack(
            clipBehavior: Clip.none,
            children: [
              _MobileFrame(
                showDivider: false,
                child: Column(
                  children: [
                    SizedBox(height: 15.h),
                    _SearchBar(),
                    SizedBox(height: 15.h),
                    _TabSwitcher(),
                    SizedBox(height: 15.h),
                    _ItemsGrid(),
                  ],
                ),
              ),
              Positioned(
                top: 60.h, left: 125.w,
                child: AnimatedBuilder(
                  animation: handAnimation,
                  builder: (context, child) => Transform.translate(offset: Offset(0, handAnimation.value), child: const Icon(Icons.touch_app, color: Colors.orange, size: 40)),
                ),
              ),
            ],
          ),
          SizedBox(height: 25.h),
          _InfoCard(text: "Use the search by description or image, or browse the map to find matching items."),
        ],
      ),
    );
  }
}

class DetailsPage extends StatelessWidget {
  const DetailsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          SizedBox(height: 20.h),
          _StepHeader(number: "4", title: "View details and match"),
          SizedBox(height: 30.h),
          _MobileFrame(
            showDivider: false,
            child: Column(
              children: [
                Container(
                  height: 150.h, 
                  width: double.infinity, 
                  margin: EdgeInsets.all(10.w), 
                  decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(18.r)), 
                  child: Center(child: Container(width: 50.w, height: 50.w, decoration: BoxDecoration(border: Border.all(color: Colors.greenAccent, width: 2), borderRadius: BorderRadius.circular(12.r))))
                ),
                _DetailsCard(),
                SizedBox(height: 10.h),
                _ExtractedInfo(),
                SizedBox(height: 10.h),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          _InfoCard(text: "Click on any item to see full details and similar items."),
        ],
      ),
    );
  }
}

class GetStartedPage extends StatelessWidget {
  final AnimationController animationController;
  const GetStartedPage({super.key, required this.animationController});

  @override
  Widget build(BuildContext context) {
    final pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeInOut),
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: pulseAnimation,
              builder: (context, child) => Transform.scale(
                scale: pulseAnimation.value,
                child: Container(
                  width: 220.w,
                  height: 220.w,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.04),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            AnimatedBuilder(
              animation: pulseAnimation,
              builder: (context, child) => Transform.scale(
                scale: pulseAnimation.value * 0.9,
                child: Container(
                  width: 170.w,
                  height: 170.w,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            Container(
              width: 110.w,
              height: 110.w,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 25,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                Icons.check_circle_rounded, 
                color: AppColors.primary,
                size: 70.sp,
              ),
            ),
          ],
        ),
        SizedBox(height: 40.h),
        Text(
          "Ready to get started!",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 32.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            fontFamily: 'IBMPlexSans',
          ),
        ),
        SizedBox(height: 15.h),
        Text(
          "Now you are ready to use it and help others.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.teal[800],
            fontFamily: 'IBMPlexSans',
          ),
        ),
        const SizedBox(height: 100),
      ],
    );
  }
}


class _StepHeader extends StatelessWidget {
  final String number, title;
  const _StepHeader({required this.number, required this.title});
  @override
  Widget build(BuildContext context) => Row(children: [Container(padding: EdgeInsets.all(10.w), decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle), child: Text(number, style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold, fontFamily: 'IBMPlexSans'))), SizedBox(width: 12.w), Text(title, style: TextStyle(color: AppColors.primary, fontSize: 18.sp, fontWeight: FontWeight.bold, fontFamily: 'IBMPlexSans'))]);
}

class _MobileFrame extends StatelessWidget {
  final Widget child;
  final bool showDivider;
  const _MobileFrame({required this.child, this.showDivider = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 380.h,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.primary, width: 2.5), borderRadius: BorderRadius.circular(24.r)),
      child: Column(children: [
        Padding(padding: EdgeInsets.symmetric(vertical: 12.h), child: Text("Home", style: TextStyle(color: AppColors.primary, fontSize: 16.sp, fontWeight: FontWeight.bold, fontFamily: 'IBMPlexSans'))),
        if (showDivider) const Divider(color: AppColors.primary, thickness: 1),
        Expanded(child: SingleChildScrollView(physics: const BouncingScrollPhysics(), child: child)),
      ]),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String text;
  const _InfoCard({required this.text});
  @override
  Widget build(BuildContext context) => Container(width: double.infinity, padding: EdgeInsets.all(14.w), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r), border: Border.all(color: Colors.white, width: 2), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 15, offset: const Offset(0, 5))]), child: Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 15.sp, color: AppColors.primary, fontWeight: FontWeight.w500, height: 1.5, fontFamily: 'IBMPlexSans')));
}

class _AnalyzingStatus extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30.r), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))]), child: Row(mainAxisSize: MainAxisSize.min, children: [SizedBox(width: 15.w, height: 15.w, child: const CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)), SizedBox(width: 12.w), Text("Analyzing...", style: TextStyle(color: AppColors.primary, fontSize: 14.sp, fontWeight: FontWeight.w600, fontFamily: 'IBMPlexSans'))]));
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(margin: EdgeInsets.symmetric(horizontal: 12.w), padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h), decoration: BoxDecoration(color: Colors.yellow[100], borderRadius: BorderRadius.circular(10.r)), child: Row(children: [Icon(Icons.search, color: AppColors.primary, size: 22.sp), SizedBox(width: 8.w), Expanded(child: Text("Search for items...", style: TextStyle(color: Colors.grey, fontSize: 13.sp, fontFamily: 'IBMPlexSans'))), Icon(Icons.camera_alt, color: AppColors.primary, size: 22.sp)]));
}

class _TabSwitcher extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Row(mainAxisAlignment: MainAxisAlignment.center, children: [_Tab(label: "Browse", isSelected: true), SizedBox(width: 10.w), _Tab(label: "Map", isSelected: false)]);
}

class _Tab extends StatelessWidget {
  final String label;
  final bool isSelected;
  const _Tab({required this.label, required this.isSelected});
  @override
  Widget build(BuildContext context) => Container(width: 110.w, height: 35.h, decoration: BoxDecoration(color: isSelected ? AppColors.primary : Colors.white, border: isSelected ? null : Border.all(color: AppColors.primary), borderRadius: BorderRadius.circular(8.r)), alignment: Alignment.center, child: Text(label, style: TextStyle(color: isSelected ? Colors.white : AppColors.primary, fontSize: 13.sp, fontFamily: 'IBMPlexSans')));
}

class _ItemsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) => GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), padding: EdgeInsets.symmetric(horizontal: 15.w), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 10.h, crossAxisSpacing: 10.w, childAspectRatio: 1.1), itemCount: 4, itemBuilder: (context, index) => Container(decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12.r)), padding: EdgeInsets.all(8.w), child: Column(children: [Expanded(child: Container(decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(8.r)))), SizedBox(height: 6.h), Container(height: 8.h, width: 50.w, color: Colors.grey[400])])));
}

class _DetailsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(margin: EdgeInsets.symmetric(horizontal: 10.w), padding: EdgeInsets.all(12.w), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15.r), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [_Tag(label: "bag"), SizedBox(width: 8.w), _Tag(label: "passport")]), SizedBox(height: 10.h), Text("The Sacred Mosque - First Floor", style: TextStyle(color: AppColors.primary, fontSize: 14.sp, fontWeight: FontWeight.bold, fontFamily: 'IBMPlexSans')), Text("Two days ago", style: TextStyle(color: Colors.grey, fontSize: 11.sp, fontFamily: 'IBMPlexSans'))]));
}

class _Tag extends StatelessWidget {
  final String label;
  const _Tag({required this.label});
  @override
  Widget build(BuildContext context) => Container(padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h), decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(6.r)), child: Text(label, style: TextStyle(color: Colors.white, fontSize: 10.sp, fontFamily: 'IBMPlexSans')));
}

class _ExtractedInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(margin: EdgeInsets.symmetric(horizontal: 10.w), padding: EdgeInsets.all(12.w), decoration: BoxDecoration(color: Colors.yellow[50], borderRadius: BorderRadius.circular(15.r), border: Border.all(color: Colors.yellow[200]!)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("extracted", style: TextStyle(color: Colors.teal[800], fontSize: 12.sp, fontWeight: FontWeight.bold, fontFamily: 'IBMPlexSans')), SizedBox(height: 8.h), Row(children: [Expanded(child: _ExtractedBox()), SizedBox(width: 10.w), Expanded(child: _ExtractedBox())])]));
}

class _ExtractedBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(height: 45.h, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8.r)));
}

class _BoundingBox extends StatelessWidget {
  final String label;
  final Color color;
  const _BoundingBox({required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h), decoration: BoxDecoration(color: color.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(4.r)), child: Text(label, style: TextStyle(color: Colors.white, fontSize: 8.sp, fontFamily: 'IBMPlexSans'))), Container(width: 50.w, height: 40.h, decoration: BoxDecoration(border: Border.all(color: color, width: 1.5), borderRadius: BorderRadius.circular(4.r)))]);
}

class _AnimatedCameraBtn extends StatelessWidget {
  final Animation<double> animation;
  const _AnimatedCameraBtn({required this.animation});
  @override
  Widget build(BuildContext context) => Stack(alignment: Alignment.center, children: [AnimatedBuilder(animation: animation, builder: (context, child) => Transform.scale(scale: animation.value, child: Container(width: 120.w, height: 120.w, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary.withValues(alpha: 0.15))))), Container(width: 70.w, height: 70.w, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle), child: Icon(Icons.camera_alt_outlined, color: Colors.white, size: 30.sp))]);
}

class _ClickHereLabel extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Transform.translate(offset: const Offset(0, 10), child: Container(padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h), decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20.r)), child: Text("click here", style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w600, fontFamily: 'IBMPlexSans'))));
}