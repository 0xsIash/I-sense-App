import 'dart:io';
import 'package:wujidt/core/utils/api_constants.dart';
import 'package:wujidt/features/home/models/extracted_item_model.dart';

class ScanItemModel {
  int? id;
  int? imageId;
  int? jobId;
  
  final String? imageUrl; 
  final File? imageFile;   
  
  String status;
  
  double progress;   
  bool isDeleted;    
  double? totalCost; 

  List<ExtractedItemModel>? extractedItems;
  bool isPublic;

  final double? latitude;
  final double? longitude;
  
  ScanItemModel({
    this.id,
    this.imageId,
    this.jobId,
    this.imageUrl,
    this.imageFile,
    required this.status,
    this.extractedItems,
    this.progress = 0.0,    
    this.isDeleted = false, 
    this.totalCost,
    this.isPublic = false,
    this.latitude, 
    this.longitude, 
  });

  bool get isCompleted => status == 'completed';
  
  set isCompleted(bool value) {
    status = value ? 'completed' : 'pending';
  }

  factory ScanItemModel.fromJson(Map<String, dynamic> json) {
    String? fullImageUrl;
    String? rawPath = json['original_url'] ?? json['file_name'] ?? json['url'];

    if (rawPath != null) {
      if (rawPath.startsWith('http')) {
        fullImageUrl = rawPath;
      } else {
        String cleanPath = rawPath.startsWith('/') ? rawPath.substring(1) : rawPath;
        fullImageUrl = "${ApiConstants.baseUrl}/$cleanPath";
      }
    }

    List<ExtractedItemModel> items = [];
    var objectsData = json['objects'] ?? json['extracted_items'];
    if (objectsData != null) {
      items = (objectsData as List)
          .map((e) => ExtractedItemModel.fromJson(e))
          .toList();
    }

    String serverStatus = json['status'] ?? 'pending';
    bool publicStatus = json['is_public'] ?? false;

    return ScanItemModel(
      id: json['id'],
      imageId: json['image_id'] ?? json['id'],
      jobId: json['job_id'],
      imageUrl: fullImageUrl,
      status: serverStatus,
      progress: serverStatus == 'completed' ? 1.0 : 0.0,
      isDeleted: false,
      isPublic: publicStatus,
      extractedItems: items,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  factory ScanItemModel.fromFeedJson(Map<String, dynamic> json, String baseUrl) {
    String? fullImageUrl;
    String? rawPath = json['original_url'] ?? json['image_url'];

    if (rawPath != null) {
      if (rawPath.startsWith('http')) {
        fullImageUrl = rawPath;
      } else {
        String cleanBase = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
        String cleanPath = rawPath.startsWith('/') ? rawPath : '/$rawPath';
        fullImageUrl = "$cleanBase$cleanPath";
      }
    }

    List<ExtractedItemModel> items = [];
    var objectsData = json['objects'] ?? json['extracted_items'];
    if (objectsData != null) {
      items = (objectsData as List)
          .map((e) => ExtractedItemModel.fromJson(e))
          .toList();
    }

    return ScanItemModel(
      id: json['image_id'] ?? json['id'],
      imageId: json['image_id'] ?? json['id'],
      imageUrl: fullImageUrl,
      status: 'completed',
      isPublic: true,
      progress: 1.0,
      extractedItems: items,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  factory ScanItemModel.fromHistoryJson(Map<String, dynamic> json) {
    String? fullImageUrl;
    String? rawPath = json['original_url'] ?? json['annotated_url'];

    if (rawPath != null) {
      if (rawPath.startsWith('http')) {
        fullImageUrl = rawPath;
      } else {
        String cleanPath = rawPath.startsWith('/') ? rawPath.substring(1) : rawPath;
        fullImageUrl = "${ApiConstants.baseUrl}/$cleanPath";
      }
    }

    double? cost;
    if (json['total_cost'] != null) {
      cost = (json['total_cost'] is int) 
          ? (json['total_cost'] as int).toDouble() 
          : double.tryParse(json['total_cost'].toString());
    }

    return ScanItemModel(
      id: json['id'],
      imageId: json['id'], 
      jobId: json['id'],
      imageUrl: fullImageUrl, 
      imageFile: null,
      status: 'completed', 
      progress: 1.0,       
      isDeleted: false,
      totalCost: cost,
      isPublic: json['is_public'] ?? false,
      extractedItems: [], 
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }
}