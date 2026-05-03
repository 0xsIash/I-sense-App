import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:wujidt/core/utils/app_colors.dart';
import 'package:wujidt/features/home/models/scan_item_model.dart';
import 'package:wujidt/features/home/widgets/item_details_view.dart';
import 'package:latlong2/latlong.dart';


class MapTab extends StatelessWidget {
  final List<ScanItemModel> userHistory;

  const MapTab({super.key, required this.userHistory});

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: const MapOptions(
        initialCenter: LatLng(30.0444, 31.2357),
        initialZoom: 13.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.isense.app',
        ),
        MarkerLayer(markers: _buildMarkers(context, userHistory)),
      ],
    );
  }

  List<Marker> _buildMarkers(BuildContext context, List<ScanItemModel> history) {
    final random = Random();
    return history.map((item) {
      double latOffset = (random.nextDouble() - 0.5) * 0.02;
      double lngOffset = (random.nextDouble() - 0.5) * 0.02;

      return Marker(
        point: LatLng(30.0444 + latOffset, 31.2357 + lngOffset),
        width: 50.w,
        height: 55.h,
        child: GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ItemDetailsView(item: item)),
          ),
          child: _buildMarkerWidget(item),
        ),
      );
    }).toList();
  }

  Widget _buildMarkerWidget(ScanItemModel item) {
    return Column(
      children: [
        Container(
          width: 40.w, height: 40.w,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: AppColors.primary, width: 2),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: item.imageFile != null
                ? Image.file(item.imageFile!, fit: BoxFit.cover)
                : (item.imageUrl != null 
                    ? Image.network(item.imageUrl!, fit: BoxFit.cover) 
                    : const Icon(Icons.image, size: 20)),
          ),
        ),
        Icon(Icons.arrow_drop_down, color: AppColors.primary, size: 15.sp),
      ],
    );
  }
}