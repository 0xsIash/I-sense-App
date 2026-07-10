import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wujidt/core/utils/app_assets.dart';
import 'package:wujidt/core/utils/app_colors.dart';
import 'package:wujidt/features/auth/views/settings_screen.dart';
import 'package:wujidt/features/home/models/scan_item_model.dart';
import 'package:wujidt/features/home/services/job_service.dart';
import 'package:wujidt/features/home/widgets/item_details_view.dart';
import 'package:wujidt/features/home/widgets/main_layout.dart';
import 'package:wujidt/features/home/widgets/scan_item_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final JobService _jobService = JobService();
  
  int? userId;
  String? profileImageUrl; 
  List<ScanItemModel> userImages = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getInt('userId');
    final savedProfilePic = prefs.getString('profilePicture'); 

    try {
      final images = await _jobService.getMySharedImages();
      
      if (mounted) {
        setState(() {
          userId = savedId;
          profileImageUrl = savedProfilePic;
          userImages = images;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          userId = savedId;
          profileImageUrl = savedProfilePic;
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackgrond,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackgrond,
        elevation: 0,
        scrolledUnderElevation: 0, 
        surfaceTintColor: Colors.transparent, 
        leading: IconButton(
          icon: SvgPicture.asset(
            AppAssets.arrowBack,
            width: 16.w,
            height: 16.h,
            colorFilter: ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Profile",
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            fontFamily: 'Kreon',
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: AppColors.primary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              ).then((_) => _loadUserData());
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20.h),
                CircleAvatar(
                  radius: 50.r,
                  backgroundColor: AppColors.secondaryBackgorud,
                  backgroundImage: (profileImageUrl != null && profileImageUrl!.isNotEmpty)
                      ? NetworkImage(profileImageUrl!) as ImageProvider
                      : null,
                  child: (profileImageUrl == null || profileImageUrl!.isEmpty)
                      ? Icon(Icons.person, color: AppColors.primary, size: 50.r)
                      : null,
                ),
                SizedBox(height: 12.h),
                ValueListenableBuilder<String>(
                  valueListenable: MainLayout.userNameNotifier,
                  builder: (context, currentUserName, child) {
                    return Text(
                      currentUserName,
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        fontFamily: 'Kreon', 
                      ),
                    );
                  },
                ),
                SizedBox(height: 30.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Published",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                        fontFamily: 'Kreon', 
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Expanded(
                  child: userImages.isEmpty
                      ? Center(
                          child: Text(
                            "No images published yet.",
                            style: TextStyle(color: Colors.grey, fontSize: 16.sp),
                          ),
                        )
                      : GridView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                          physics: const BouncingScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 15.w,
                            mainAxisSpacing: 15.h,
                            childAspectRatio: 0.85,
                          ),
                          itemCount: userImages.length,
                          itemBuilder: (context, index) {
                            final item = userImages[index];
                            return _buildImageCard(context, item);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildImageCard(BuildContext context, ScanItemModel item) {
    Widget bottomWidget;

    if (item.extractedItems != null && item.extractedItems!.isNotEmpty) {
      bottomWidget = ListView(
        scrollDirection: Axis.horizontal,
        children: item.extractedItems!
            .map((e) => (e.category).toString()) 
            .toSet()
            .take(2) 
            .map(
              (tag) => Container(
                margin: EdgeInsets.only(right: 5.w),
                padding: EdgeInsets.symmetric(
                  horizontal: 8.w,
                  vertical: 2.h,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Center(
                  child: Text(
                    tag,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      );
    } else {
      bottomWidget = Center(
        child: Text(
          "completed",
          style: TextStyle(
            color: Colors.grey,
            fontSize: 11.sp,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ItemDetailsView(
              item: item,
              currentUserId: userId ?? 0,
            ),
          ),
        ).then((_) => _loadUserData());
      },
      child: ScanItemCard(
        imageFile: item.imageFile,
        imageUrl: item.imageUrl,
        bottomContent: bottomWidget,
      ),
    );
  }
}