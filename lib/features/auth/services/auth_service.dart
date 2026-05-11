import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wujidt/core/utils/api_constants.dart';

class AuthService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        ApiConstants.loginEndpoint,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        final String userName = data['user']['user_name'];
        final int userId = data['user']['id'];
        final String token = data['access_token'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setInt('userId', userId);
        await prefs.setString('userName', userName);

        debugPrint("Login Success: User $userName (ID: $userId)");

        return {
          'name': userName,
          'id': userId,
        };
      } else {
        throw Exception('Login failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow; 
    }
  }

  Future<void> signup({
    required String userName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.signupEndpoint,
        data: {
          'email': email,
          'password': password,
          'user_name': userName,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("Signup Success");
      } else {
        throw Exception('Signup failed');
      }
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  void _handleDioError(DioException e) {
    if (e.response != null) {
      final statusCode = e.response?.statusCode;
      final data = e.response?.data;

      if (statusCode == 401 || statusCode == 404) {
        throw Exception("Incorrect email or password.");
      } else if (statusCode == 400) {
        throw Exception(data['detail'] ?? "Email already exists.");
      } else if (statusCode == 422) {
        throw Exception("Invalid data format. Please check your inputs.");
      } else {
        throw Exception(data['detail'] ?? "An unexpected error occurred. Try again.");
      }
    } else {
      throw Exception("Connection Error. Please check your internet and try again.");
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');
    await prefs.remove('userName');
    debugPrint("User logged out and data cleared.");
  }
}