import 'dart:io';
import 'package:dio/dio.dart';
import 'package:wujidt/core/utils/api_constants.dart';
import 'package:wujidt/features/home/models/top_match_model.dart';

class SearchService {
  final Dio _dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));

  Future<TopMatchResponse?> searchByImage(File imageFile) async {
    try {
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(imageFile.path),
      });

      final response = await _dio.post(
        ApiConstants.searchByImage,
        data: formData,
        queryParameters: {
          'limit': 10,
          'threshold': 0.5,
          'filter_by_label': true, 
        },
      );

      if (response.statusCode == 200) {
        return TopMatchResponse.fromJson(response.data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}