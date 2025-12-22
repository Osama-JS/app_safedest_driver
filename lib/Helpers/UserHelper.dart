import 'dart:io';
import '../services/api_service.dart';
import '../config/app_config.dart';
import '../models/api_response.dart';
import '../models/driver.dart';

class UserHelper {
  final ApiService _apiService = ApiService();

  // Login
  Future<ApiResponse<LoginResponse>> login({
    required String login,
    required String password,
    required String deviceName,
    String? deviceId,
    String? fcmToken,
  }) async {
    return await _apiService.post<LoginResponse>(
      AppConfig.loginEndpoint,
      body: {
        'login': login,
        'password': password,
        'device_name': deviceName,
        'device_id': deviceId,
        'fcm_token': fcmToken,
        'app_version': AppConfig.appVersion,
      },
      fromJson: (data) => LoginResponse.fromJson(data),
      requiresAuth: false,
    );
  }

  // Logout
  Future<ApiResponse<void>> logout() async {
    return await _apiService.post<void>(
      AppConfig.logoutEndpoint,
      fromJson: (data) => null,
    );
  }

  // Get Profile
  Future<ApiResponse<Driver>> getProfile() async {
    return await _apiService.get<Driver>(
      AppConfig.profileEndpoint,
      fromJson: (data) => Driver.fromJson(data['driver'] ?? data),
    );
  }

  // Check Status
  Future<ApiResponse<Driver>> checkStatus() async {
    return await _apiService.get<Driver>(
      AppConfig.checkStatusEndpoint,
      fromJson: (data) => Driver.fromJson(data['driver'] ?? data),
    );
  }

  // Update Profile
  Future<ApiResponse<Driver>> updateProfile(
    Map<String, dynamic> data, {
    File? imageFile,
  }) async {
    if (imageFile != null) {
      return await _apiService.putWithFile<Driver>(
        AppConfig.updateProfileEndpoint,
        body: data,
        files: {'image': imageFile},
        fromJson: (data) => Driver.fromJson(data['driver'] ?? data),
      );
    } else {
      return await _apiService.put<Driver>(
        AppConfig.updateProfileEndpoint,
        body: data,
        fromJson: (data) => Driver.fromJson(data['driver'] ?? data),
      );
    }
  }

  // Change Password
  Future<ApiResponse<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    return await _apiService.post<void>(
      AppConfig.changePasswordEndpoint,
      body: {
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': newPassword,
      },
      fromJson: (data) => null,
    );
  }

  // Forgot Password
  Future<ApiResponse<void>> forgotPassword(String email) async {
    return await _apiService.post<void>(
      AppConfig.forgotPasswordEndpoint,
      body: {'email': email},
      fromJson: (data) => null,
      requiresAuth: false,
    );
  }

  // Get Additional Data
  Future<ApiResponse<Map<String, dynamic>>> getAdditionalData() async {
    return await _apiService.get<Map<String, dynamic>>(
      AppConfig.additionalDataEndpoint,
      fromJson: (data) => Map<String, dynamic>.from(data),
    );
  }
}
