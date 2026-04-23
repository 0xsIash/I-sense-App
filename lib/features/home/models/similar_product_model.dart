class SimilarProductModel {
  final String vendorName;
  final String productUrl;
  final String thumbnail;

  SimilarProductModel({
    required this.vendorName,
    required this.productUrl,
    required this.thumbnail,
  });

  factory SimilarProductModel.fromJson(Map<String, dynamic> json) {
    return SimilarProductModel(
      vendorName: json['vendor_name'] ?? 'Unknown Store',
      productUrl: json['product_url'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
    );
  }
}