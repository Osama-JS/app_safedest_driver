import 'dart:io';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../Helpers/UserHelper.dart';
import '../models/driver.dart';
import '../models/api_response.dart';
import '../shared_prff.dart';
import '../Globals/global.dart' as globals;
import '../services/api_service.dart';
import '../services/auth_service.dart';

import 'NotificationController.dart';

class AuthController extends GetxController {
  final UserHelper _userHelper = UserHelper();
  final ApiService _apiService = ApiService();

  // Reactive state
  final Rxn<Driver> _currentDriver = Rxn<Driver>();
  final RxBool _isAuthenticated = false.obs;
  final RxBool _isLoading = false.obs;

  // Getters
  Rxn<Driver> get currentDriver => _currentDriver;
  RxBool get isAuthenticated => _isAuthenticated;
  RxBool get isLoading => _isLoading;

  @override
  void onInit() {
    super.onInit();
    // Load local data on initialization
    _loadLocalData();
  }

  // Load data from shared preferences
  void _loadLocalData() {
    final String? driverJson = User_pref.getUser();
    if (driverJson != null && driverJson.isNotEmpty) {
      try {
        final Map<String, dynamic> driverData = jsonDecode(driverJson);
        _currentDriver.value = Driver.fromJson(driverData);
        _isAuthenticated.value = Token_pref.getToken() != null;

        globals.token = Token_pref.getToken();
        globals.user = driverData;
        globals.userName = _currentDriver.value?.name ?? "";
        globals.userId = _currentDriver.value?.id ?? 0;
      } catch (e) {
        debugPrint("Error decoding driver data: $e");
      }
    }
  }

  // Login
  Future<ApiResponse<LoginResponse>> login(
    String login,
    String password, {
    String deviceName = "Mobile Device",
    String? deviceId,
    String? fcmToken,
  }) async {
    _isLoading.value = true;
    try {
      // Try to get FCM token from NotificationController if not provided
      if (fcmToken == null || fcmToken.isEmpty) {
        try {
          if (Get.isRegistered<NotificationController>()) {
             final notificationController = Get.find<NotificationController>();
             fcmToken = notificationController.fcmToken.value;
             debugPrint("🔑 AuthController: Fetched FCM Token from controller: $fcmToken");
          } else {
             debugPrint("⚠️ AuthController: NotificationController not registered yet.");
          }
        } catch (e) {
          debugPrint("⚠️ AuthController: Error getting FCM token: $e");
        }
      }

      if (fcmToken != null) {
          debugPrint("🚀 LOGIN: Sending request with FCM Token: $fcmToken");
      } else {
          debugPrint("⚠️ LOGIN: FCM Token is NULL");
      }

      final response = await _userHelper.login(
        login: login,
        password: password,
        deviceName: deviceName,
        deviceId: deviceId,
        fcmToken: fcmToken,
      );

      if (response.isSuccess && response.data != null) {
        final loginData = response.data!;
        if (loginData.token != null && loginData.driver != null) {
          // Save token
          await Token_pref.setToken(loginData.token!);
          await _apiService.setAuthToken(loginData.token!);

          // Save User data
          final String driverJson = jsonEncode(loginData.driver!.toJson());
          await User_pref.setUser(driverJson);

          // Update state
          _currentDriver.value = loginData.driver;
          _isAuthenticated.value = true;

          // Sync with Provider-based AuthService
          await AuthService().syncWithStorage();

          // Update globals
          globals.token = loginData.token;
          globals.user = loginData.driver!.toJson();
          globals.userName = loginData.driver!.name;
          globals.userId = loginData.driver!.id;

          // Load notifications for the logged-in user
          if (Get.isRegistered<NotificationController>()) {
             final notificationController = Get.find<NotificationController>();
             await notificationController.loadNotificationsForUser(loginData.driver!.id);
          }
        }
      }
      return response;
    } finally {
      _isLoading.value = false;
    }
  }

  // Logout
  Future<void> logout() async {
    _isLoading.value = true;
    try {
      await _userHelper.logout();
    } catch (e) {
      debugPrint("Logout API error: $e");
    } finally {
      // Clear data regardless of API success
      await _clearAuthData();

      // Sync with Provider-based AuthService
      await AuthService().forceLogout();

      // Reset notifications
      if (Get.isRegistered<NotificationController>()) {
         Get.find<NotificationController>().reset();
      }

      _isLoading.value = false;
      Get.offAllNamed('/login');
    }
  }

  // Refresh Profile
  Future<void> refreshProfile() async {
    final response = await _userHelper.getProfile();
    if (response.isSuccess && response.data != null) {
      _currentDriver.value = response.data;
      final String driverJson = jsonEncode(response.data!.toJson());
      await User_pref.setUser(driverJson);
      globals.user = response.data!.toJson();
      globals.userName = response.data!.name;
      globals.userId = response.data!.id;
    }
  }

  // Alias for backward compatibility or UI expectations
  Future<void> refreshDriverData() async => await refreshProfile();

  // Force Logout (e.g. on 401)
  void forceLogout() {
    _clearAuthData();
    AuthService().forceLogout();

    // Reset notifications
    if (Get.isRegistered<NotificationController>()) {
        Get.find<NotificationController>().reset();
    }

    Get.offAllNamed('/login');
  }

  Future<void> _clearAuthData() async {
    await Token_pref.removeToken();
    await User_pref.removeUser();
    await _apiService.clearAuthToken();

    _currentDriver.value = null;
    _isAuthenticated.value = false;

    globals.token = null;
    globals.user = {};
    globals.userName = "";
    globals.userId = 0;
  }

  // Update Profile
  Future<ApiResponse<Driver>> updateProfile(
    Map<String, dynamic> data, {
    File? imageFile,
  }) async {
    _isLoading.value = true;
    try {
      final response = await _userHelper.updateProfile(data, imageFile: imageFile);
      if (response.isSuccess && response.data != null) {
        _currentDriver.value = response.data;
        final String driverJson = jsonEncode(response.data!.toJson());
        await User_pref.setUser(driverJson);
        globals.user = response.data!.toJson();
        globals.userName = response.data!.name;
        globals.userId = response.data!.id;
      }
      return response;
    } finally {
      _isLoading.value = false;
    }
  }
}
