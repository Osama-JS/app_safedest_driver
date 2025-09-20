import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert';
import '../models/registration_data.dart';
import '../models/api_response.dart';
import '../config/app_config.dart';
import 'api_service.dart';

class RegistrationService extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  String? _errorMessage;
  bool _hasError = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _hasError;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    _hasError = error != null;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    _hasError = false;
  }

  /// Get registration data (vehicles, templates, teams, phone codes)
  Future<RegistrationData?> getRegistrationData() async {
    _setLoading(true);
    _clearError();

    try {
      debugPrint('Fetching registration data...');

      final response = await _apiService.get<RegistrationData>(
        AppConfig.registrationDataEndpoint,
        fromJson: (data) => RegistrationData.fromJson(data['data'] ?? data),
      );

      if (response.isSuccess && response.data != null) {
        debugPrint('Registration data loaded successfully');
        return response.data;
      } else {
        final errorMsg =
            response.errorMessage ?? 'Failed to load registration data';
        debugPrint('Failed to load registration data: $errorMsg');
        _setError(errorMsg);
        return null;
      }
    } catch (e) {
      final errorMsg = 'Error loading registration data: $e';
      debugPrint(errorMsg);
      _setError(errorMsg);
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Register new driver
  Future<ApiResponse<Map<String, dynamic>>> register(
      Map<String, dynamic> registrationData) async {
    _setLoading(true);
    _clearError();

    try {
      debugPrint('Registering driver...');

      // Separate files from regular data
      Map<String, File> files = {};
      Map<String, dynamic> bodyData = {};

      registrationData.forEach((key, value) {
        if (value is PlatformFile) {
          // Convert PlatformFile to File
          if (value.path != null) {
            files[key] = File(value.path!);
          }
        } else if (key == 'additional_fields' &&
            value is Map<String, dynamic>) {
          // Handle additional_fields as JSON string for API
          bodyData[key] = jsonEncode(value);
        } else {
          bodyData[key] = value;
        }
      });

      ApiResponse<Map<String, dynamic>> response;

      if (files.isNotEmpty) {
        // Use postWithFile for multipart request
        response = await _apiService.postWithFile<Map<String, dynamic>>(
          AppConfig.registerEndpoint,
          body: bodyData,
          files: files,
          fromJson: (data) => data,
        );
      } else {
        // Use regular post for JSON request
        response = await _apiService.post<Map<String, dynamic>>(
          AppConfig.registerEndpoint,
          body: bodyData,
          fromJson: (data) => data,
        );
      }

      if (response.isSuccess) {
        debugPrint('Driver registered successfully');
      } else {
        debugPrint('Registration failed: ${response.errorMessage}');
      }

      return response;
    } catch (e) {
      final errorMsg = 'Registration error: $e';
      debugPrint(errorMsg);
      _setError(errorMsg);

      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: errorMsg,
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Resend verification email
  Future<ApiResponse<void>> resendVerificationEmail(String email) async {
    _setLoading(true);
    _clearError();

    try {
      debugPrint('Resending verification email to: $email');

      final response = await _apiService.post<void>(
        AppConfig.resendVerificationEndpoint,
        body: {'email': email},
        fromJson: (data) {},
      );

      if (response.isSuccess) {
        debugPrint('Verification email sent successfully');
      } else {
        debugPrint(
            'Failed to send verification email: ${response.errorMessage}');
      }

      return response;
    } catch (e) {
      final errorMsg = 'Error sending verification email: $e';
      debugPrint(errorMsg);
      _setError(errorMsg);

      return ApiResponse<void>(
        success: false,
        message: errorMsg,
      );
    } finally {
      _setLoading(false);
    }
  }
}
