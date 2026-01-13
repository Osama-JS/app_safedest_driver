import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class AdditionalDataController extends GetxController {
  final _isLoading = false.obs;
  final _additionalData = <String, dynamic>{}.obs;
  final _errorMessage = RxnString();
  final _hasTemplate = false.obs;
  final _templateName = RxnString();

  bool get isLoading => _isLoading.value;
  Map<String, dynamic> get additionalData => _additionalData;
  String? get errorMessage => _errorMessage.value;
  bool get hasTemplate => _hasTemplate.value;
  String? get templateName => _templateName.value;

  @override
  void onInit() {
    super.onInit();
    loadAdditionalData();
  }

  Future<void> loadAdditionalData() async {
    _isLoading.value = true;
    _errorMessage.value = null;

    try {
      // Use Provider context-less access if possible, or Get.find if it was a GetService
      // Since AuthService is a ChangeNotifierProvider, we might need a workaround
      // or just use Get.find if it's also registered in GetX.
      // Looking at main.dart, AuthService is in MultiProvider.

      final authService = AuthService(); // It's a singleton factory
      final response = await authService.getAdditionalData();

      if (response.isSuccess && response.data != null) {
        final rawData = response.data!['additional_data'];
        if (rawData is Map<String, dynamic>) {
          _additionalData.value = rawData;
        } else if (rawData is Map) {
          _additionalData.value = Map<String, dynamic>.from(rawData);
        } else {
          // If it's a List or null, clear it
          _additionalData.clear();
        }

        _hasTemplate.value = response.data!['has_template'] ?? false;
        _templateName.value = response.data!['template_name'];
        _isLoading.value = false;
        debugPrint('Additional data loaded: $_additionalData');
      } else {
        debugPrint('API Error loading additional data: ${response.message}');
        _errorMessage.value = 'error_loading_additional_data'.tr;
        _isLoading.value = false;
      }
    } catch (e) {
      debugPrint('Exception loading additional data: $e');
      _errorMessage.value = 'error_loading_additional_data'.tr;
      _isLoading.value = false;
    }
  }
}
