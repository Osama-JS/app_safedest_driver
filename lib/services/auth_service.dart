import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../config/app_config.dart';
import '../models/api_response.dart';
import '../models/driver.dart';
import 'api_service.dart';
import 'notification_service.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService _apiService = ApiService();
  final _storage = const FlutterSecureStorage();
  final NotificationService _notificationService = NotificationService();

  Driver? _currentDriver;
  bool _isAuthenticated = false;
  bool _isLoading = false;

  // Getters
  Driver? get currentDriver => _currentDriver;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;

  // Check API connectivity
  Future<bool> checkApiConnectivity() async {
    try {
      return await _apiService.checkConnectivity();
    } catch (e) {
      debugPrint('API connectivity check error: $e');
      return false;
    }
  }

  // Initialize service
  Future<void> initialize() async {
    _setLoading(true);

    try {
      await _apiService.initialize();

      if (_apiService.isAuthenticated) {
        await _loadDriverData();
        if (_currentDriver != null) {
          _isAuthenticated = true;
          debugPrint('Auth initialized: User is authenticated');
        } else {
          // Token exists but driver data is invalid, clear auth
          await _clearAuthData();
          debugPrint('Auth initialized: Invalid driver data, cleared auth');
        }
      } else {
        _isAuthenticated = false;
        debugPrint('Auth initialized: User is not authenticated');
      }
    } catch (e) {
      debugPrint('Auth initialization error: $e');
      _isAuthenticated = false;
    } finally {
      _setLoading(false);
      notifyListeners(); // Ensure UI is updated
    }
  }

  // Login
  Future<ApiResponse<LoginResponse>> login({
    required String login,
    required String password,
    required String deviceName,
    String? deviceId,
    String? fcmToken,
  }) async {
    _setLoading(true);

    try {
      // Initialize NotificationService to get FCM token
      debugPrint(
          'AuthService: Initializing NotificationService for FCM token...');
      await _notificationService.initialize();

      // Get FCM token from NotificationService if not provided
      String? finalFcmToken = fcmToken ?? _notificationService.fcmToken;

      // If still null, try to get it directly with timeout
      if (finalFcmToken == null) {
        debugPrint(
            'AuthService: FCM token is null, trying to get it directly...');
        try {
          finalFcmToken = await FirebaseMessaging.instance
              .getToken()
              .timeout(const Duration(seconds: 5));
          debugPrint(
              'AuthService: Got FCM token directly: ${finalFcmToken?.substring(0, 20)}...');
        } catch (e) {
          debugPrint('AuthService: Failed to get FCM token directly: $e');
        }
      }

      debugPrint(
          'Login attempt with FCM token: ${finalFcmToken?.substring(0, 20) ?? 'NULL'}...');

      final response = await _apiService.post<LoginResponse>(
        AppConfig.loginEndpoint,
        body: {
          'login': login,
          'password': password,
          'device_name': deviceName,
          'device_id': deviceId ?? await _getDeviceId(),
          'fcm_token': finalFcmToken,
          'app_version': AppConfig.appVersion,
        },
        fromJson: (data) => LoginResponse.fromJson(data),
        requiresAuth: false,
      );

      if (response.isSuccess) {
        if (response.data != null) {
          final loginData = response.data!;

          if (loginData.token != null && loginData.driver != null) {
            try {
              // Save token first
              await _apiService.setAuthToken(loginData.token!);
              debugPrint(
                  'Auth token saved: ${loginData.token!.substring(0, 10)}...');

              // Save driver data
              await _saveDriverData(loginData.driver!);
              debugPrint('Driver data saved: ${loginData.driver!.name}');

              // Update local state
              _currentDriver = loginData.driver;
              _isAuthenticated = true;

              debugPrint('Login successful: User authenticated');
              debugPrint('Current driver: ${_currentDriver?.name}');
              debugPrint('Is authenticated: $_isAuthenticated');

              // Update FCM token after successful login if we have one
              if (finalFcmToken != null) {
                try {
                  final fcmResponse =
                      await _notificationService.updateFcmToken(finalFcmToken);
                  if (fcmResponse.isSuccess) {
                    debugPrint('FCM token updated successfully after login');
                  } else {
                    debugPrint(
                        'Failed to update FCM token: ${fcmResponse.errorMessage}');
                  }
                } catch (e) {
                  debugPrint('Error updating FCM token: $e');
                }
              }

              notifyListeners();
            } catch (e) {
              debugPrint('Error saving login data: $e');
              // Reset state on error
              _currentDriver = null;
              _isAuthenticated = false;
              await _apiService.clearAuthToken();
              // Update response to reflect the error
              return ApiResponse<LoginResponse>(
                success: false,
                message: 'فشل في حفظ بيانات تسجيل الدخول',
              );
            }
          } else {
            debugPrint('Login response missing token or driver data');
            debugPrint('Token present: ${loginData.token != null}');
            debugPrint('Driver present: ${loginData.driver != null}');
            return ApiResponse<LoginResponse>(
              success: false,
              message: 'استجابة غير مكتملة من الخادم',
            );
          }
        } else {
          debugPrint('Login response data is null');
          return ApiResponse<LoginResponse>(
            success: false,
            message: 'لم يتم استلام بيانات من الخادم',
          );
        }
      } else {
        debugPrint('Login failed: ${response.errorMessage}');
      }

      return response;
    } catch (e) {
      return ApiResponse<LoginResponse>(
        success: false,
        message: 'حدث خطأ أثناء تسجيل الدخول: $e',
      );
    } finally {
      _setLoading(false);
    }
  }

  // Logout
  Future<ApiResponse<void>> logout() async {
    _setLoading(true);

    try {
      // Call logout API
      final response = await _apiService.post<void>(
        AppConfig.logoutEndpoint,
        fromJson: null,
      );

      // Clear local data regardless of API response
      await _clearAuthData();

      return response;
    } catch (e) {
      // Clear local data even if API call fails
      await _clearAuthData();

      return ApiResponse<void>(
        success: true,
        message: 'تم تسجيل الخروج محلياً',
      );
    } finally {
      _setLoading(false);
    }
  }

  // Get profile
  Future<ApiResponse<Driver>> getProfile() async {
    final response = await _apiService.get<Driver>(
      AppConfig.profileEndpoint,
      fromJson: (data) => Driver.fromJson(data['driver']),
    );

    if (response.isSuccess && response.data != null) {
      _currentDriver = response.data;
      await _saveDriverData(_currentDriver!);
      notifyListeners();
    }

    return response;
  }

  // Refresh token
  Future<ApiResponse<String>> refreshToken() async {
    final response = await _apiService.refreshToken();

    if (response.isSuccess) {
      notifyListeners();
    }

    return response;
  }

  // Update driver data
  Future<void> updateDriverData(Driver driver) async {
    _currentDriver = driver;
    await _saveDriverData(driver);
    notifyListeners();
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> _loadDriverData() async {
    try {
      final driverJson = await _storage.read(key: AppConfig.driverDataKey);
      if (driverJson != null && driverJson.isNotEmpty) {
        final driverData = json.decode(driverJson);
        if (driverData != null && driverData is Map<String, dynamic>) {
          _currentDriver = Driver.fromJson(driverData);
          debugPrint(
              'Driver data loaded successfully: ${_currentDriver?.name}');
        } else {
          debugPrint('Invalid driver data format');
          _currentDriver = null;
        }
      } else {
        debugPrint('No driver data found in storage');
        _currentDriver = null;
      }
    } catch (e) {
      debugPrint('Error loading driver data: $e');
      _currentDriver = null;
    }
  }

  Future<void> _saveDriverData(Driver driver) async {
    try {
      final driverJson = json.encode(driver.toJson());
      await _storage.write(key: AppConfig.driverDataKey, value: driverJson);

      // Verify data was saved
      final savedData = await _storage.read(key: AppConfig.driverDataKey);
      if (savedData != null && savedData.isNotEmpty) {
        debugPrint('Driver data verified in storage');
      } else {
        throw Exception('Failed to verify saved driver data');
      }
    } catch (e) {
      debugPrint('Error saving driver data: $e');
      rethrow; // Re-throw to handle in login method
    }
  }

  Future<void> _clearAuthData() async {
    try {
      await _apiService.clearAuthToken();
      await _storage.delete(key: AppConfig.driverDataKey);

      _currentDriver = null;
      _isAuthenticated = false;

      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing auth data: $e');
    }
  }

  Future<String> _getDeviceId() async {
    String? deviceId = await _storage.read(key: AppConfig.deviceIdKey);

    if (deviceId == null) {
      // Generate a simple device ID
      deviceId = 'flutter_${DateTime.now().millisecondsSinceEpoch}';
      await _storage.write(key: AppConfig.deviceIdKey, value: deviceId);
    }

    return deviceId;
  }

  // Refresh driver data from server
  Future<ApiResponse<Driver>> refreshDriverData() async {
    try {
      debugPrint('Refreshing driver data from server...');

      final response = await _apiService.get<Driver>(
        AppConfig.profileEndpoint,
        fromJson: (data) => Driver.fromJson(data['driver']),
      );

      if (response.isSuccess && response.data != null) {
        final newDriverData = response.data!;
        final hasChanges = _compareDriverData(_currentDriver, newDriverData);

        if (hasChanges) {
          debugPrint('Driver data has changes, updating local storage...');
          _currentDriver = newDriverData;

          // Save updated driver data to secure storage
          await _saveDriverData(_currentDriver!);

          debugPrint(
              'Driver data updated successfully: ${_currentDriver?.name}');
          notifyListeners();
        } else {
          debugPrint('No changes in driver data');
        }
      } else {
        debugPrint('Failed to refresh driver data: ${response.errorMessage}');
      }

      return response;
    } catch (e) {
      debugPrint('Error refreshing driver data: $e');
      return ApiResponse<Driver>(
        success: false,
        message: 'فشل في تحديث بيانات السائق: $e',
      );
    }
  }

  // Compare driver data to detect changes
  bool _compareDriverData(Driver? oldData, Driver newData) {
    if (oldData == null) return true;

    // Compare key fields that might change
    return oldData.name != newData.name ||
        oldData.email != newData.email ||
        oldData.phone != newData.phone ||
        oldData.image != newData.image ||
        oldData.status != newData.status ||
        oldData.online != newData.online ||
        oldData.free != newData.free ||
        oldData.walletBalance != newData.walletBalance ||
        oldData.address != newData.address ||
        oldData.commissionValue != newData.commissionValue ||
        oldData.appVersion != newData.appVersion;
  }

  // Check if token is expired (basic check)
  bool isTokenExpired() {
    // Since Sanctum tokens don't have expiration by default,
    // we can implement a simple time-based check or API call
    return false;
  }

  // Auto-refresh token if needed
  Future<bool> ensureValidToken() async {
    if (!_isAuthenticated) return false;

    if (isTokenExpired()) {
      final response = await refreshToken();
      return response.isSuccess;
    }

    return true;
  }

  // Update driver profile
  Future<ApiResponse<Driver>> updateProfile(
    Map<String, dynamic> updateData, {
    File? imageFile,
  }) async {
    try {
      debugPrint('Updating driver profile...');

      Map<String, dynamic> requestData = Map.from(updateData);

      ApiResponse<Driver> response;

      // Handle image upload if provided
      if (imageFile != null) {
        debugPrint('Uploading image file: ${imageFile.path}');
        response = await _apiService.putWithFile<Driver>(
          AppConfig.updateProfileEndpoint,
          body: requestData,
          files: {'image': imageFile},
          fromJson: (data) => Driver.fromJson(data['driver'] ?? data),
        );
      } else {
        response = await _apiService.put<Driver>(
          AppConfig.updateProfileEndpoint,
          body: requestData,
          fromJson: (data) => Driver.fromJson(data['driver'] ?? data),
        );
      }

      if (response.isSuccess && response.data != null) {
        _currentDriver = response.data;
        await _saveDriverData(_currentDriver!);
        debugPrint('Profile updated successfully');
        notifyListeners();
      } else {
        debugPrint('Failed to update profile: ${response.errorMessage}');
      }

      return response;
    } catch (e) {
      debugPrint('Error updating profile: $e');
      return ApiResponse<Driver>(
        success: false,
        message: 'فشل في تحديث الملف الشخصي: $e',
      );
    }
  }

  // Change password
  Future<ApiResponse<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      debugPrint('Changing password...');

      final response = await _apiService.post<void>(
        AppConfig.changePasswordEndpoint,
        body: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': newPassword,
        },
        fromJson: (data) {},
      );

      if (response.isSuccess) {
        debugPrint('Password changed successfully');
      } else {
        debugPrint('Failed to change password: ${response.errorMessage}');
      }

      return response;
    } catch (e) {
      debugPrint('Error changing password: $e');
      return ApiResponse<void>(
        success: false,
        message: 'فشل في تغيير كلمة المرور: $e',
      );
    }
  }

  // Forgot password - send reset link to email
  Future<ApiResponse<void>> forgotPassword({
    required String email,
  }) async {
    try {
      debugPrint('Sending password reset email to: $email');

      final response = await _apiService.post<void>(
        AppConfig.forgotPasswordEndpoint,
        body: {
          'email': email,
        },
        fromJson: (data) {},
        requiresAuth: false,
      );

      if (response.isSuccess) {
        debugPrint('Password reset email sent successfully');
      } else {
        debugPrint(
            'Failed to send password reset email: ${response.errorMessage}');
      }

      return response;
    } catch (e) {
      debugPrint('Error sending password reset email: $e');
      return ApiResponse<void>(
        success: false,
        message: 'فشل في إرسال رابط إعادة تعيين كلمة المرور: $e',
      );
    }
  }
}
