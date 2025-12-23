import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../models/api_response.dart';

import '../services/task_ads_service.dart';

class TaskAdsController extends GetxController {
  final ApiService _apiService = ApiService();
  final TaskAdsService _taskAdsService = TaskAdsService();

  // Reactive state
  final RxInt availableAds = 0.obs;
  final RxInt myOffers = 0.obs;
  final RxInt acceptedOffers = 0.obs;
  final RxBool isLoading = false.obs;
  final RxnString error = RxnString();

  @override
  void onInit() {
    super.onInit();
    // loadStats();
  }

  /// Load task ads statistics
  Future<void> loadStats() async {
    if (isLoading.value) return;

    isLoading.value = true;
    error.value = null;

    try {
      debugPrint('Loading task ads statistics...');

      final response = await _apiService.get<Map<String, dynamic>>(
        '/driver/task-ads/stats',
        fromJson: (json) => json['data'] ?? json,
      );

      if (response.success && response.data != null) {
        final data = response.data!;

        availableAds.value = _parseToInt(data['available_ads']) ?? 0;
        myOffers.value = _parseToInt(data['my_offers']) ?? 0;
        acceptedOffers.value = _parseToInt(data['accepted_offers']) ?? 0;

        debugPrint('Task ads stats loaded: Available: ${availableAds.value}, My Offers: ${myOffers.value}, Accepted: ${acceptedOffers.value}');
      } else {
        error.value = response.message ?? 'Failed to load statistics';
        debugPrint('Error loading task ads stats: ${error.value}');
      }
    } catch (e) {
      error.value = 'Failed to load statistics: $e';
      debugPrint('Exception loading task ads stats: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh statistics
  Future<void> refreshStats() async {
    await loadStats();
  }

  /// Clear statistics
  void clearStats() {
    availableAds.value = 0;
    myOffers.value = 0;
    acceptedOffers.value = 0;
    error.value = null;
  }

  /// Update stats after submitting an offer
  void incrementMyOffers() {
    myOffers.value++;
  }

  /// Update stats after offer is accepted
  void incrementAcceptedOffers() {
    acceptedOffers.value++;
    if (myOffers.value > 0) {
      myOffers.value--; // Move from pending to accepted
    }
  }

  /// Update stats after offer is rejected
  void decrementMyOffers() {
    if (myOffers.value > 0) {
      myOffers.value--;
    }
  }

  /// Delete an offer
  Future<ApiResponse<void>> deleteOffer(int offerId) async {
    isLoading.value = true;
    error.value = null;

    try {
      final response = await _taskAdsService.deleteOffer(offerId);

      if (response.success) {
        decrementMyOffers();
        return response;
      } else {
        error.value = response.message ?? 'Failed to delete offer';
        return response;
      }
    } catch (e) {
      error.value = 'Exception deleting offer: $e';
      return ApiResponse<void>(
        success: false,
        message: 'Exception deleting offer: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Helper method for safe integer parsing
  static int? _parseToInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  /// Check if stats are empty (all zeros)
  bool get hasStats => availableAds.value > 0 || myOffers.value > 0 || acceptedOffers.value > 0;

  /// Get total activity count
  int get totalActivity => availableAds.value + myOffers.value + acceptedOffers.value;
}
