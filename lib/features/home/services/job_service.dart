import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wujidt/core/utils/api_constants.dart';
import 'package:wujidt/features/home/models/similar_product_model.dart';
import 'package:wujidt/features/home/models/extracted_item_model.dart';
import 'package:wujidt/features/home/models/scan_item_model.dart';

class JobService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  JobService() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        options.headers['Accept'] = 'application/json';
        return handler.next(options);
      },
    ));
  }

  Future<String> checkJobStatus(int jobId) async {
    final response = await _dio.get(ApiConstants.getJobStatusEndpoint(jobId));
    return response.data['status'];
  }

  Future<List<ExtractedItemModel>> getImageObjects(int imageId) async {
    final response = await _dio.get(ApiConstants.getImageObjectsEndpoint(imageId));
    if (response.data is Map && response.data['objects'] != null) {
      return (response.data['objects'] as List)
          .map((json) => ExtractedItemModel.fromJson(json))
          .toList();
    }
    return [];
  }

  Future<List<ScanItemModel>> getPublishedImages() async {
    final response = await _dio.get(ApiConstants.getPublishedImages);
    List data = response.data is List ? response.data : (response.data['images'] ?? []);
    return data.map((e) => ScanItemModel.fromJson(e)).toList();
  }

  Future<bool> unPublishImage(int imageId) async {
    try {
      final response = await _dio.post(ApiConstants.unpublishImage(imageId), data: {});
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> publishImage(int imageId) async {
    try {
      final response = await _dio.post(
        ApiConstants.publishImage(imageId),
        data: {"latitude": 0, "longitude": 0, "location_name": "", "description": ""},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<List<ScanItemModel>> getUserHistory() async {
    try {
      final response = await _dio.get(ApiConstants.getAllImagesEndpoint);
      if (response.data['images'] != null) {
        return (response.data['images'] as List)
            .map((json) => ScanItemModel.fromHistoryJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<void> deleteImage(int imageId) async {
    await _dio.delete(ApiConstants.deleteImageEndpoint(imageId));
  }

  Future<List<SimilarProductModel>> getSimilarProducts(int imageId, int objId) async {
    try {
      final response = await _dio.get(ApiConstants.getSimilarProductsEndpoint(imageId, objId));
      List productsJson = response.data['products'] ?? [];
      return productsJson.map((json) => SimilarProductModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }
}