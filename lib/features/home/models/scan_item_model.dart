import 'dart:io';
import 'package:wujidt/core/utils/api_constants.dart';
import 'package:wujidt/features/home/models/extracted_item_model.dart';

class ScanItemModel {
  int? id;
  int? imageId;
  int? jobId;
  final int? userId; 
  final String? userName;
  final String? phoneNumber;
  
  final String? imageUrl; 
  final File? imageFile;   
  final String? locationName; 
  final String? location;
  
  String status;
  double progress;   
  bool isDeleted;    
  double? totalCost; 

  List<ExtractedItemModel>? extractedItems;
  bool isPublic;

  final double? latitude;
  final double? longitude;
  
  ScanItemModel({
    this.userId,
    this.userName,
    this.phoneNumber,
    this.id,
    this.imageId,
    this.jobId,
    this.imageUrl,
    this.imageFile,
    this.locationName,
    this.location,
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
    String? rawPath = json['original_url'] ?? json['file_name'] ?? json['url'] ?? json['annotated_url'];

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

    double? cost;
    if (json['total_cost'] != null) {
      cost = (json['total_cost'] is int) 
          ? (json['total_cost'] as int).toDouble() 
          : double.tryParse(json['total_cost'].toString());
    }

    final int dynamicId = json['id'] ?? json['image_id'] ?? json['job_id'] ?? 0;
    final String serverStatus = json['status'] ?? 'completed';

    return ScanItemModel(
      id: dynamicId,
      userId: json['user_id'], 
      userName: json['publisher_username'] ?? json['user_name'],
      phoneNumber: json['publisher_phone'] ?? json['phone_number'],
      imageId: dynamicId,
      jobId: dynamicId,
      imageUrl: fullImageUrl,
      locationName: json['location_name'] ?? "Unknown Location",
      location: json['location_name'] ?? "Unknown Location",
      status: serverStatus,
      progress: serverStatus == 'completed' ? 1.0 : 0.0,
      isDeleted: false,
      isPublic: json['is_public'] ?? false,
      extractedItems: items,
      totalCost: cost,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }
}