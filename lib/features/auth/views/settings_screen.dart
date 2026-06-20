import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wujidt/core/utils/app_assets.dart';
import 'package:wujidt/core/utils/app_colors.dart';
import 'package:wujidt/core/utils/image_picker_helper.dart';
import 'package:wujidt/features/auth/services/auth_service.dart';
import 'package:wujidt/features/home/widgets/custom_bottom_nav.dart';
import 'package:wujidt/features/home/widgets/main_layout.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController oldPassController = TextEditingController();
  final TextEditingController newPassController = TextEditingController();
  final TextEditingController verifyPassController = TextEditingController();

  bool isOldPassHidden = true;
  bool isNewPassHidden = true;
  bool isVerifyPassHidden = true;
  bool isLoading = false;

  String? profileImageUrl;
  File? selectedImage;

  @override
  void initState() {
    super.initState();
    _fetchAndSetData();
  }

  Future<void> _fetchAndSetData() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        nameController.text = prefs.getString('userName') ?? "";
        phoneController.text = prefs.getString('phoneNumber') ?? "";
        profileImageUrl = prefs.getString('profilePicture');
      });
    }
    await _authService.fetchAndCacheProfile();
    final updatedPrefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        profileImageUrl = updatedPrefs.getString('profilePicture');
      });
    }
  }

  Future<void> _showImageOptions() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.primaryBackgrond,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library, color: AppColors.primary),
                title: const Text('Edit Profile Picture', style: TextStyle(fontFamily: 'Kreon')),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  if (context.mounted) {
                    File? image = await ImagePickerHelper.showImageSourceOptions(context);
                    if (image != null && mounted) {
                      setState(() {
                        selectedImage = image;
                      });
                    }
                  }
                },
              ),
              if (selectedImage != null || (profileImageUrl != null && profileImageUrl!.isNotEmpty))
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text('Delete Profile Picture', style: TextStyle(color: Colors.red, fontFamily: 'Kreon')),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _confirmDeleteDialog();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmDeleteDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.primaryBackgrond,
          title: const Text(
            'Confirm Delete',
            style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Kreon'),
          ),
          content: const Text('Are you sure you want to delete your profile picture?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontFamily: 'Kreon')),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontFamily: 'Kreon')),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                setState(() => isLoading = true);
                
                bool deleted = await _authService.deleteProfilePicture();
                
                setState(() => isLoading = false);
                
                if (deleted && context.mounted) {
                  setState(() {
                    selectedImage = null;
                    profileImageUrl = null;
                  });
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Profile picture removed successfully"),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (context.mounted) {
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Failed to remove profile picture"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);

    if (oldPassController.text.isNotEmpty && newPassController.text.isNotEmpty) {
      bool isPasswordSuccess = await _authService.updatePassword(oldPassController.text, newPassController.text);
      if (!isPasswordSuccess) {
        setState(() => isLoading = false);
        if (context.mounted) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Incorrect current password! Password update failed."),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
    }

    if (selectedImage != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profilePicture', selectedImage!.path);
    }

    bool success = await _authService.updateProfile(
      name: nameController.text,
      phone: phoneController.text,
      imageFile: selectedImage,
      deleteImage: false,
    );

    if (success) {
      await _authService.fetchAndCacheProfile();
      final prefs = await SharedPreferences.getInstance();
      phoneController.text = prefs.getString('phoneNumber') ?? phoneController.text;
      
      if (mounted) {
        setState(() {
          profileImageUrl = prefs.getString('profilePicture');
          selectedImage = null;
        });
      }

      oldPassController.clear();
      newPassController.clear();
      verifyPassController.clear();
    }
    setState(() => isLoading = false);

    if (context.mounted) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? "Profile updated successfully!" : "Update failed"),
          backgroundColor: success ? AppColors.primary : Colors.red,
        ),
      );
    }
  }

  ImageProvider? _getAvatarImage() {
    if (selectedImage != null) {
      return FileImage(selectedImage!);
    }
    if (profileImageUrl != null && profileImageUrl!.isNotEmpty) {
      if (profileImageUrl!.startsWith('http')) {
        return NetworkImage(profileImageUrl!);
      } else {
        return FileImage(File(profileImageUrl!));
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackgrond,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackgrond,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        title: Text(
          "settings", 
          style: TextStyle(
            color: AppColors.primary, 
            fontSize: 20.sp, 
            fontWeight: FontWeight.w600, 
            fontFamily: 'Kreon'
          )
        ),
        leading: IconButton(
          icon: SvgPicture.asset(AppAssets.arrowBack, width: 16.w, height: 16.h, colorFilter: ColorFilter.mode(AppColors.primary, BlendMode.srcIn)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight, 
                  children: [
                    CircleAvatar(
                      radius: 55.r, 
                      backgroundColor: AppColors.secondaryBackgorud, 
                      backgroundImage: _getAvatarImage(),
                      child: _getAvatarImage() == null
                          ? Icon(Icons.person, color: AppColors.primary, size: 55.r)
                          : null,
                    ),
                    GestureDetector(
                      onTap: _showImageOptions, 
                      child: CircleAvatar(
                        radius: 16.r, 
                        backgroundColor: AppColors.primary, 
                        child: Icon(Icons.edit, color: Colors.white, size: 16.r)
                      )
                    ),
                  ]
                ),
              ),
              _buildLabelRow(Icon(Icons.person_outline, color: AppColors.primary, size: 20.sp), "Name"),
              _buildTextField(controller: nameController),
              _buildLabelRow(SvgPicture.asset(AppAssets.phone, width: 20.w, height: 20.h, colorFilter: ColorFilter.mode(AppColors.primary, BlendMode.srcIn)), "Phone number"),
              _buildTextField(controller: phoneController),
              _buildLabelRow(Icon(Icons.lock_outline, color: AppColors.primary, size: 20.sp), "Old Password"),
              _buildTextField(controller: oldPassController, isPassword: true, isHidden: isOldPassHidden, onToggle: () => setState(() => isOldPassHidden = !isOldPassHidden)),
              _buildLabelRow(Icon(Icons.lock_outline, color: AppColors.primary, size: 20.sp), "New Password"),
              _buildTextField(
                controller: newPassController, 
                isPassword: true, 
                isHidden: isNewPassHidden, 
                onToggle: () => setState(() => isNewPassHidden = !isNewPassHidden),
                validator: (val) {
                  if (val != null && val.isNotEmpty) {
                    if (val.length < 6) {
                      return "Password must be at least 6 characters";
                    }
                    if (val == oldPassController.text) {
                      return "New password cannot be the same as old password";
                    }
                  }
                  return null;
                },
              ),
              _buildLabelRow(Icon(Icons.lock_outline, color: AppColors.primary, size: 20.sp), "Verify Password"),
              _buildTextField(
                controller: verifyPassController, 
                isPassword: true, 
                isHidden: isVerifyPassHidden, 
                onToggle: () => setState(() => isVerifyPassHidden = !isVerifyPassHidden),
                validator: (val) {
                  if (newPassController.text.isNotEmpty && (val == null || val.isEmpty)) {
                    return "Please confirm your new password";
                  }
                  if (val != newPassController.text) {
                    return "Passwords do not match";
                  }
                  return null;
                },
              ),
              SizedBox(height: 30.h),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r))),
                  onPressed: isLoading ? null : _handleUpdate,
                  child: isLoading ? const CircularProgressIndicator(color: Colors.white) : Text("Update", style: TextStyle(fontSize: 18.sp, color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Kreon')),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 0, 
        onTap: (index) { 
          MainLayout.navigationTrigger.value = index; 
          if (context.mounted) {
            Navigator.pop(context); 
          }
        }
      ),
    );
  }

  Widget _buildLabelRow(Widget icon, String text) => Padding(padding: EdgeInsets.only(bottom: 8.h, top: 15.h), child: Row(children: [icon, SizedBox(width: 8.w), Text(text, style: TextStyle(color: AppColors.primary, fontSize: 14.sp, fontWeight: FontWeight.w600, fontFamily: 'Kreon'))]));

  Widget _buildTextField({required TextEditingController controller, bool isPassword = false, bool isHidden = false, VoidCallback? onToggle, String? Function(String?)? validator}) => TextFormField(
    controller: controller,
    obscureText: isHidden,
    validator: validator,
    decoration: InputDecoration(
      contentPadding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
      suffixIcon: isPassword ? IconButton(icon: Icon(isHidden ? Icons.visibility_off : Icons.visibility, color: AppColors.primary), onPressed: onToggle) : null,
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: BorderSide(color: AppColors.primary, width: 1.5)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: BorderSide(color: AppColors.primary, width: 2)),
    ),
  );
}