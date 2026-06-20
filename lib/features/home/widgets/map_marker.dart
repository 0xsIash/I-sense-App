import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:widget_to_marker/widget_to_marker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wujidt/features/home/models/scan_item_model.dart';

class MapMarker {
  static Future<BitmapDescriptor> buildCustomMarker({
    required ScanItemModel item,
    required bool isSelected,
  }) async {
    final double size = isSelected ? 95.w : 75.w;

    return await Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? Colors.blueAccent : Colors.white, 
          width: 4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipOval(
        child: item.imageUrl != null
            ? CachedNetworkImage(
                imageUrl: item.imageUrl!,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => _buildPlaceholder(),
              )
            : _buildPlaceholder(),
      ),
    ).toBitmapDescriptor(
      logicalSize: Size(size, size),
      imageSize: Size(isSelected ? 250 : 200, isSelected ? 250 : 200),
    );
  }

  static Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: const Icon(Icons.image),
    );
  }
}