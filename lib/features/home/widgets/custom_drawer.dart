import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:isense/core/utils/app_colors.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({
    super.key,
    required this.userName,
  });

  final String userName;

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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22.r,
                  backgroundColor: AppColors.secondaryBackgorud,
                  child: Icon(Icons.person, color: AppColors.primary),
                ),
                const SizedBox(width: 15),
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5A5A89),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 30),
            
            InkWell(
              onTap: () {
                _confirmLogout(context);
              },
              child: const Row(
                children: [
                  Text(
                    "Log out",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.logout, color: Colors.red),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}