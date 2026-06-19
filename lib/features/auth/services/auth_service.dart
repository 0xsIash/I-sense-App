import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wujidt/core/utils/api_constants.dart';
import 'package:wujidt/features/home/widgets/main_layout.dart';

class AuthService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
  ));

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(ApiConstants.loginEndpoint, data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        final prefs = await SharedPreferences.getInstance();
        
        await prefs.setString('token', data['access_token']);
        await prefs.setInt('userId', data['user']['id']);
        
        await fetchAndCacheProfile();
        return data;
      }
      throw Exception('Login failed');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signup({
    required String userName,
    required String email,
    required String password,
    required String phoneNumber,
  }) async {
    try {
      await _dio.post(ApiConstants.signupEndpoint, data: {
        'user_name': userName,
        'email': email,
        'password': password,
        'phone_number': phoneNumber,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> fetchAndCacheProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    try {
      final response = await _dio.get(
        ApiConstants.profileEndpoint,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        await prefs.setString('userName', data['user_name']);
        await prefs.setString('phoneNumber', data['phone_number'] ?? "");
        
        String rawServerPath = data['profile_picture'] ?? "";
        String fullImageUrl = "";
        if (rawServerPath.isNotEmpty) {
          if (rawServerPath.startsWith('http')) {
            fullImageUrl = rawServerPath;
          } else {
            fullImageUrl = "${ApiConstants.baseUrl}$rawServerPath";
          }
        }
        await prefs.setString('profilePicture', fullImageUrl);
        
        MainLayout.userNameNotifier.value = data['user_name'];
      }
    } catch (e) {
      debugPrint("Profile fetch error: $e");
    }
  }

  Future<bool> updateProfile({String? name, String? phone, File? imageFile, bool deleteImage = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    FormData formData = FormData();
    
    if (name != null) formData.fields.add(MapEntry('user_name', name));
    if (phone != null) formData.fields.add(MapEntry('phone_number', phone));
    
    if (deleteImage) {
      formData.fields.add(const MapEntry('profile_picture', '')); 
    } else if (imageFile != null) {
      formData.files.add(MapEntry(
        'profile_picture',
        await MultipartFile.fromFile(imageFile.path),
      ));
    }

    try {
      final response = await _dio.put(
        ApiConstants.updateProfileEndpoint,
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      
      if (response.statusCode == 200) {
        await fetchAndCacheProfile();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updatePassword(String oldPass, String newPass) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    try {
      final response = await _dio.put(
        ApiConstants.changePasswordEndpoint,
        data: {'current_password': oldPass, 'new_password': newPass},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}