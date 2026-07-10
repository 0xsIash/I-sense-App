import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wujidt/core/utils/app_colors.dart';
import 'package:wujidt/features/auth/views/profile_screen.dart';
import 'package:wujidt/features/auth/views/settings_screen.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({
    super.key,
    required this.userName,
  });

  final String userName;

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        profileImageUrl = prefs.getString('profilePicture');
      });
    }
  }

  Future<void> _confirmLogout(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Confirm Logout',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
              onPressed: () {
                Navigator.of(context).pop(); 
              },
            ),
            TextButton(
              child: const Text(
                'Log out',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.of(context).pop(); 
                Navigator.pushNamedAndRemoveUntil(context, "login", (route) => false);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 60.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22.r,
                    backgroundColor: AppColors.secondaryBackgorud,
                    backgroundImage: (profileImageUrl != null && profileImageUrl!.isNotEmpty)
                        ? NetworkImage(profileImageUrl!) as ImageProvider
                        : null,
                    child: (profileImageUrl == null || profileImageUrl!.isEmpty)
                        ? Icon(Icons.person, color: AppColors.primary, size: 22.r)
                        : null,
                  ),
                  SizedBox(width: 15.w),
                  Text(
                    widget.userName,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 40.h),
            
            InkWell(
              onTap: () {
                Navigator.pop(context); 
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                ).then((_) => _loadProfileImage());
              },
              child: Row(
                children: [
                  Text(
                    "Settings",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.settings_outlined, color: AppColors.primary),
                ],
              ),
            ),

            SizedBox(height: 30.h),
            
            InkWell(
              onTap: () {
                _confirmLogout(context);
              },
              child: Row(
                children: [
                  Text(
                    "Log out",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.logout, color: Colors.red),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}