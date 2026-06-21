import 'package:wujidt/core/utils/api_constants.dart';

class TopMatchResponse {
  final List<TopMatchItem> results;
  final int totalFound;
  final String detectedLabel;

  TopMatchResponse({
    required this.results,
    required this.totalFound,
    required this.detectedLabel,
  });

  factory TopMatchResponse.fromJson(Map<String, dynamic> json) {
    return TopMatchResponse(
      results: (json['results'] as List?)
              ?.map((e) => TopMatchItem.fromJson(e))
              .toList() ??
          [],
      totalFound: json['total_found'] ?? 0,
      detectedLabel: json['detected_label'] ?? 'Unknown',
    );
  }
}

class TopMatchItem {
  final String segmentedImageUrl;
  final String originalImageUrl;
  final String objectLabel;
  final double similarity;
  final String publisherUsername;
  final String publisherPhone;
  final String locationName;

  TopMatchItem({
    required this.segmentedImageUrl,
    required this.originalImageUrl,
    required this.objectLabel,
    required this.similarity,
    required this.publisherUsername,
    required this.publisherPhone,
    required this.locationName,
  });

  factory TopMatchItem.fromJson(Map<String, dynamic> json) {
    final obj = json['object'] ?? {};
    
    String getFullUrl(String? path) {
      if (path == null || path.isEmpty) return "";
      if (path.startsWith('http')) return path;
      return "${ApiConstants.baseUrl}$path";
    }

    return TopMatchItem(
      segmentedImageUrl: getFullUrl(obj['segmented_image_url']),
      originalImageUrl: getFullUrl(json['original_image_url']),
      objectLabel: obj['object_label'] ?? 'Unknown',
      similarity: (json['similarity'] as num?)?.toDouble() ?? 0.0,
      publisherUsername: json['publisher_username'] ?? 'Unknown User',
      publisherPhone: json['publisher_phone'] ?? '',
      locationName: json['location_name'] ?? 'Unknown Location',
    );
  }
}