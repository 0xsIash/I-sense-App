import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wujidt/core/utils/app_colors.dart';
import 'package:wujidt/features/home/controllers/browse_controller.dart';
import 'package:wujidt/features/home/widgets/map_item_card.dart';
import 'package:wujidt/features/home/widgets/main_layout.dart';
import 'package:wujidt/features/home/models/scan_item_model.dart';

class BrowseMapView extends StatelessWidget {
  final BrowseController controller;
  final VoidCallback onMapCreated;
  final int currentUserId;

  const BrowseMapView({
    super.key,
    required this.controller,
    required this.onMapCreated,
    required this.currentUserId,
  });

  void _checkExternalNavigation() {
    final targetData = MainLayout.targetMapLocation.value;
    if (targetData != null) {
      final double lat = targetData['latitude'];
      final double lng = targetData['longitude'];
      final int? id = targetData['id'];

      ScanItemModel? realItem;
      try {
        realItem = controller.browseItems.firstWhere(
          (item) => item.id == id || (item.latitude == lat && item.longitude == lng),
        );
      } catch (_) {
        realItem = ScanItemModel(
          id: id ?? 9999,
          status: 'completed',
          isPublic: true,
          latitude: lat,
          longitude: lng,
          locationName: targetData['title'],
        );
      }

      controller.checkAndRouteToTargetImage(realItem);
      MainLayout.targetMapLocation.value = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Map<String, dynamic>?>(
      valueListenable: MainLayout.targetMapLocation,
      builder: (context, targetLocation, child) {
        if (targetLocation != null && controller.mapController != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _checkExternalNavigation());
        }
        return Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: controller.currentLocation,
                zoom: 15,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              markers: controller.markers,
              polylines: controller.polylines,
              onMapCreated: (c) {
                controller.mapController = c;
                onMapCreated();
                if (MainLayout.targetMapLocation.value != null) {
                  _checkExternalNavigation();
                }
              },
              onTap: controller.handleMapTap,
            ),
            if (controller.travelInfo.isNotEmpty) _TravelInfoBanner(controller),
            _SelectedItemCard(controller, currentUserId),
          ],
        );
      },
    );
  }
}

class _TravelInfoBanner extends StatelessWidget {
  final BrowseController controller;

  const _TravelInfoBanner(this.controller);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 10.h,
      left: 20.w,
      right: 20.w,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.r),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 10),
          ],
        ),
        child: Text(
          controller.travelInfo,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 14.sp,
          ),
        ),
      ),
    );
  }
}

class _SelectedItemCard extends StatelessWidget {
  final BrowseController controller;
  final int currentUserId;

  const _SelectedItemCard(this.controller, this.currentUserId);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(bottom: 20.h, left: 20.w, right: 20.w),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.9, end: 1.0).animate(animation),
              child: child,
            ),
          ),
          child: controller.selectedItem != null
              ? MapItemCard(
                  key: ValueKey(controller.selectedItem!.id),
                  item: controller.selectedItem!,
                  currentUserId: currentUserId,
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}