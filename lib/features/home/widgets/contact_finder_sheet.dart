import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wujidt/core/utils/app_colors.dart';

class ContactFinderSheet extends StatelessWidget {
  final String uploaderName;
  final String phoneNumber;
  final String locationName;
  final VoidCallback onMapPressed;

  const ContactFinderSheet({
    super.key,
    required this.uploaderName,
    required this.phoneNumber,
    required this.locationName,
    required this.onMapPressed,
  });

  Future<void> _makePhoneCall(String number) async {
    if (number.isEmpty || number == "No Phone Provided") return;
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: number,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              "Contact Finder",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                fontFamily: 'Kreon',
              ),
            ),
            SizedBox(height: 20.h),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Icon(Icons.person_outline, color: AppColors.primary),
              ),
              title: Text(
                "Uploaded By",
                style: TextStyle(fontSize: 12.sp, color: Colors.grey, fontFamily: 'Kreon'),
              ),
              subtitle: Text(
                uploaderName.isNotEmpty ? uploaderName : "Unknown User",
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: Colors.black, fontFamily: 'Kreon'),
              ),
            ),
            Divider(height: 1.h, color: Colors.grey[200]),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Icon(Icons.phone_outlined, color: AppColors.primary),
              ),
              title: Text(
                "Phone Number",
                style: TextStyle(fontSize: 12.sp, color: Colors.grey, fontFamily: 'Kreon'),
              ),
              subtitle: Text(
                phoneNumber.isNotEmpty ? phoneNumber : "No Phone Provided",
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: Colors.black, fontFamily: 'Kreon'),
              ),
              onTap: () => _makePhoneCall(phoneNumber),
            ),
            Divider(height: 1.h, color: Colors.grey[200]),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Icon(Icons.location_on_outlined, color: AppColors.primary),
              ),
              title: Text(
                "Location",
                style: TextStyle(fontSize: 12.sp, color: Colors.grey, fontFamily: 'Kreon'),
              ),
              subtitle: Text(
                locationName.isNotEmpty ? locationName : "Unknown Location",
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: Colors.black, fontFamily: 'Kreon'),
              ),
              onTap: onMapPressed,
            ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }
}