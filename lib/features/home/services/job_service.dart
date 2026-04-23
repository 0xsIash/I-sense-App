import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:isense/features/home/models/similar_product_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:isense/core/utils/api_constants.dart';
import 'package:isense/features/home/models/extracted_item_model.dart';
import 'package:isense/features/home/models/scan_item_model.dart';

class JobService {
  final Dio _dio = Dio();

  Future<String> checkJobStatus(int jobId) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final String url = "${ApiConstants.baseUrl}${ApiConstants.getJobStatusEndpoint(jobId)}";
    

    final response = await _dio.get(
      url, 
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );

    if (response.statusCode == 200) {
      return response.data['status'];
    } else {
      throw Exception("Failed to check status.");
    }
  }

  Future<List<ExtractedItemModel>> getImageObjects(int imageId) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final String url = "${ApiConstants.baseUrl}${ApiConstants.getImageObjectsEndpoint(imageId)}";
    

    final response = await _dio.get(
      url, 
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );

    if (response.statusCode == 200) {
      if (response.data is Map<String, dynamic> && response.data['objects'] != null) {
        List<dynamic> listData = response.data['objects'];
        return listData.map((json) => ExtractedItemModel.fromJson(json)).toList();
      } 
      else if (response.data is List) {
        return (response.data as List).map((json) => ExtractedItemModel.fromJson(json)).toList();
      }

      return [];
    } else {
      throw Exception("Failed to get objects.");
    }
  }

  Future<List<ScanItemModel>> getPublishedImages() async {
  final response = await _dio.get(ApiConstants.getPublishedImages);

  if (response.statusCode == 200) {
    List data = response.data;

    return data.map((e) => ScanItemModel.fromJson(e)).toList();
  } else {
    throw Exception("Failed to load images");
  }
}

  Future<List<ScanItemModel>> getUserHistory() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final String url = "${ApiConstants.baseUrl}/images/"; 

    try {
      final response = await _dio.get(
        url,
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = response.data;
        
        if (data['images'] != null && data['images'] is List) {
           List<dynamic> imagesList = data['images'];
           
           return imagesList
              .map((json) => ScanItemModel.fromHistoryJson(json))
              .toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint("⚠️ Error fetching history: $e");
      return [];
    }
  }

  

  Future<void> deleteImage(int imageId) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final String url = "${ApiConstants.baseUrl}${ApiConstants.deleteImageEndpoint(imageId)}";
    
    await _dio.delete(
      url, 
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
  }
  // الدالة دي وظيفتها تجيب التوكن من الـ SharedPreferences عشان نبعته في الـ Headers
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // داخل ملف job_service.dart
  Future<List<SimilarProductModel>> getSimilarProducts(int imageId, int objId) async {
    try {
      final token = await _getToken();
      // الرابط حسب Swagger
      final String url = "${ApiConstants.baseUrl}/similar_products/$imageId/$objId/similar-products";
      
      final response = await _dio.get(url, options: Options(headers: {"Authorization": "Bearer $token"}));

      if (response.statusCode == 200) {
        List<dynamic> productsJson = response.data['products'] ?? [];
        return productsJson.map((json) => SimilarProductModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("🔴 Error fetching similar products: $e");
      return [];
    }
  }


  // job_service.dart
Future<bool> publishImage(int imageId) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final String url = "${ApiConstants.baseUrl}${ApiConstants.publishImage(imageId)}";

    final response = await _dio.post(
      url,
      data: {
        "latitude": 0,
        "longitude": 0,
        "location_name": "",
        "description": "",
      },
      options: Options(
        headers: {"Authorization": "Bearer $token"},
      ),
    );

    // لو الكود 200 يبقى نجح
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  } catch (e) {
    debugPrint("Failed to publish image: $e");
    return false;
  }
}
}