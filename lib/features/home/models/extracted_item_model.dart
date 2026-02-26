import 'package:isense/core/utils/api_constants.dart';

class ExtractedItemModel {
  final int? id;
  final String name;      
  final String category;  
  final double price;     
  final String? imageUrl;

  ExtractedItemModel({
    this.id,
    required this.name,
    required this.category,
    required this.price,
    this.imageUrl,
  });

  factory ExtractedItemModel.fromJson(Map<String, dynamic> json) {
    String? fullImageUrl;
    if (json['segmented_image_url'] != null) {
      String path = json['segmented_image_url'];
      fullImageUrl = path.startsWith('http') ? path : "${ApiConstants.baseUrl}$path";
    }

    Map<String, dynamic>? geminiData;
    if (json['object_metadata'] != null && json['object_metadata']['gemini'] != null) {
      geminiData = json['object_metadata']['gemini'];
    }

    String categoryName = json['object_category'] ?? json['object_label'] ?? 'Object';

    String specificName = categoryName;
    if (geminiData != null && geminiData['product_name'] != null) {
      specificName = geminiData['product_name'].toString();
    }

    double itemPrice = 0.0;
    if (geminiData != null && geminiData['average_price_EGP'] != null) {
      var priceRaw = geminiData['average_price_EGP'];
      if (priceRaw is num) {
        itemPrice = priceRaw.toDouble();
      } else if (priceRaw is String) {
        String cleanPrice = priceRaw.replaceAll(RegExp(r'[^0-9.]'), '');
        itemPrice = double.tryParse(cleanPrice) ?? 0.0;
      }
    } else if (json['price'] != null) {
      itemPrice = (json['price'] is num) ? (json['price'] as num).toDouble() : 0.0;
    }

    return ExtractedItemModel(
      id: json['object_id'] ?? json['id'],
      name: specificName,   
      category: categoryName, 
      price: itemPrice,     
      imageUrl: fullImageUrl,
    );
  }
}