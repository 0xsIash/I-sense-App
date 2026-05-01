import 'package:isense/core/utils/api_constants.dart';

class ExtractedItemModel {
  final int? id;
  final String name;
  final String category;
  final double price;
  final String? imageUrl;
  final double? bbX;
  final double? bbY;
  final double? bbWidth;
  final double? bbHeight;

  ExtractedItemModel({
    this.id,
    required this.name,
    required this.category,
    required this.price,
    this.imageUrl,
    this.bbX,
    this.bbY,
    this.bbWidth,
    this.bbHeight,
  });

  factory ExtractedItemModel.fromJson(Map<String, dynamic> json) {
    String? fullImageUrl;
    if (json['segmented_image_url'] != null) {
      String path = json['segmented_image_url'];
      fullImageUrl = path.startsWith('http') ? path : "${ApiConstants.baseUrl}$path";
    }

    Map<String, dynamic>? geminiData;
    if (json['object_metadata'] != null && json['object_metadata']['gemini'] != null) {
      var gemini = json['object_metadata']['gemini'];
      if (gemini is Map<String, dynamic>) {
        geminiData = gemini;
      }
    }

    String categoryName = json['object_category'] ?? json['object_label'] ?? 'Object';

    String specificName = geminiData?['name']?.toString() ?? categoryName;

    double itemPrice = 0.0;

    if (geminiData != null && geminiData['price'] != null) {
      var priceRaw = geminiData['price'];
      if (priceRaw is num) {
        itemPrice = priceRaw.toDouble();
      } else if (priceRaw is String) {
        String cleanPrice = priceRaw.replaceAll(RegExp(r'[^0-9.]'), '');
        itemPrice = double.tryParse(cleanPrice) ?? 0.0;
      }
    } else if (json['price'] != null) {
      itemPrice = (json['price'] is num) ? (json['price'] as num).toDouble() : 0.0;
    }

    final bbox = json['bounding_box'];

    return ExtractedItemModel(
      id: json['object_id'] ?? json['id'],
      name: specificName,
      category: categoryName,
      price: itemPrice,
      imageUrl: fullImageUrl,
      bbX: (bbox?['x'] as num?)?.toDouble(),
      bbY: (bbox?['y'] as num?)?.toDouble(),
      bbWidth: (bbox?['width'] as num?)?.toDouble(),
      bbHeight: (bbox?['height'] as num?)?.toDouble(),
    );
  }
}