import 'dart:io';
import 'package:dio/dio.dart';
import 'package:wujidt/core/utils/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImageService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      validateStatus: (status) => true,
    ),
  );

  Future<Map<String, dynamic>> uploadImage(
    File imageFile, {
    double? latitude,
    double? longitude,
    String? locationName,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        throw Exception("Authentication Error: Please login again.");
      }

      String fileName = imageFile.path.split('/').last;

      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
        "latitude": latitude,
        "longitude": longitude,
        "location_name": locationName,
      });

      Response response = await _dio.post(
        ApiConstants.uploadImageEndpoint,
        data: formData,
        options: Options(
          headers: {
            "Content-Type": "multipart/form-data",
            "Authorization": "Bearer $token"
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception("Server Error: ${response.statusCode} - ${response.data}");
      }
    } catch (e) {
      throw Exception("Upload Failed: $e");
    }
  }
}