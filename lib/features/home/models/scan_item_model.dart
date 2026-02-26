import 'dart:io';
import 'package:isense/core/utils/api_constants.dart';
import 'package:isense/features/home/models/extracted_item_model.dart';

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
  });

  bool get isCompleted => status == 'completed';
  
  set isCompleted(bool value) {
    status = value ? 'completed' : 'pending';
  }

  factory ScanItemModel.fromJson(Map<String, dynamic> json) {
    String? fullImageUrl;
    String? rawPath = json['file_name'] ?? json['image_url'] ?? json['url'] ?? json['original_url'];

    if (rawPath != null) {
      if (rawPath.startsWith('http')) {
        fullImageUrl = rawPath;
      } else {
        String cleanPath = rawPath.startsWith('/') ? rawPath.substring(1) : rawPath;
        fullImageUrl = "${ApiConstants.baseUrl}/$cleanPath";
      }
    }

    List<ExtractedItemModel> items = [];
    if (json['objects'] != null) {
      items = (json['objects'] as List)
          .map((e) => ExtractedItemModel.fromJson(e))
          .toList();
    }

    String serverStatus = json['status'] ?? 'pending';

    return ScanItemModel(
      id: json['id'],
      imageId: json['image_id'],
      jobId: json['job_id'],
      imageUrl: fullImageUrl,
      
      status: serverStatus,
      progress: serverStatus == 'completed' ? 1.0 : 0.0,
      isDeleted: false,
      
      extractedItems: items,
    );
  }

  factory ScanItemModel.fromHistoryJson(Map<String, dynamic> json) {
    String? fullImageUrl;
    String? rawPath = json['original_url']; 

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
          : (json['total_cost'] as double);
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
      
      extractedItems: [], 
    );
  }
}