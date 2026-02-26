import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:isense/core/utils/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10), 
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  // log in function
  Future<String> login(String email, String password) async {
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
        String userName = data['user']['user_name']; 
        String token = data['access_token'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token); 
        
        debugPrint("Login Success: ${response.data}");
        return userName; 
      }else {
        throw Exception('Login failed');
      }


    } on DioException catch (e) {
      if (e.response != null) {
        final statusCode = e.response?.statusCode;

        if (statusCode == 401 || statusCode == 404) {
          throw Exception("Incorrect email or password.");
        } 
        else if (statusCode == 422) {
          throw Exception("Invalid data format.");
        } 
        else {
          final errorMsg = e.response?.data['detail'] ?? 'Login failed';
          throw Exception(errorMsg);
        }
      } 
      else {
        throw Exception("Connection Error. Please check your internet.");
      }
    }
  }

  // sign up function
  Future<void> signup({required String userName, required String email, required String password}) async {
    try {
      final response = await _dio.post(
        ApiConstants.signupEndpoint,
        data: {
          'email': email,
          'password': password,
          'user_name': userName, 
        },
      );

      if (response.statusCode == 200) {
        debugPrint("Signup Success");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final data = e.response?.data;
        String errorMessage = data['detail'] ?? 'Signup failed';
        
        if (e.response?.statusCode == 400) {
           throw Exception("Email already exists.");
        } else {
           throw Exception(errorMessage);
        }
      } else {
        throw Exception("Connection Error. Please check your internet.");
      }
    }
  }
}