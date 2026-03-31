import 'package:isense/features/home/models/extracted_item_model.dart';
class DraggableObject {
  final String imageUrl;
  final String label;
  final double width;
  final double height;
  double x;
  double y;

  DraggableObject({
    required this.imageUrl,
    required this.label,
    required this.width,
    required this.height,
    required this.x,
    required this.y,
  });

  // Convert from ExtractedItemModel
  factory DraggableObject.fromExtractedItem(ExtractedItemModel item, {
    required double x,
    required double y,
    required double width,
    required double height,
  }) {
    return DraggableObject(
      imageUrl: item.imageUrl ?? '',
      label: item.name,
      x: x,
      y: y,
      width: width,
      height: height,
    );
  }
}