import 'package:flutter/foundation.dart';
import '../models/api_response.dart';
import '../models/task_ad.dart';
import 'api_service.dart';

class TaskAdsService {
  static final TaskAdsService _instance = TaskAdsService._internal();
  factory TaskAdsService() => _instance;
  TaskAdsService._internal();

  final ApiService _apiService = ApiService();

  /// Get details of a specific task advertisement
  Future<ApiResponse<TaskAd>> getAdDetails(int adId) async {
    try {
      final response = await _apiService.get<TaskAd>(
        '/driver/task-ads/$adId',
        fromJson: (json) => TaskAd.fromJson(json['data'] ?? json),
      );
      return response;
    } catch (e) {
      debugPrint('Error getting ad details: $e');
      return ApiResponse<TaskAd>(success: false, message: e.toString());
    }
  }

  /// Submit an offer for a task advertisement
  Future<ApiResponse<Map<String, dynamic>>> submitOffer(
      int adId, double price, String description) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/driver/task-ads/$adId/offers',
        body: {
          'price': price,
          'description': description,
        },
        fromJson: (json) => Map<String, dynamic>.from(json),
      );
      return response;
    } catch (e) {
      debugPrint('Error submitting offer: $e');
      return ApiResponse<Map<String, dynamic>>(success: false, message: e.toString());
    }
  }

  /// Update an existing offer
  Future<ApiResponse<Map<String, dynamic>>> updateOffer(
      int offerId, double price, String description) async {
    try {
      final response = await _apiService.put<Map<String, dynamic>>(
        '/driver/task-ads/offers/$offerId',
        body: {
          'price': price,
          'description': description,
        },
        fromJson: (json) => Map<String, dynamic>.from(json),
      );
      return response;
    } catch (e) {
      debugPrint('Error updating offer: $e');
      return ApiResponse<Map<String, dynamic>>(success: false, message: e.toString());
    }
  }

  /// Delete an existing offer
  Future<ApiResponse<void>> deleteOffer(int offerId) async {
    try {
      final response = await _apiService.post<void>(
        '/driver/task-ads/offers/$offerId/delete',
        fromJson: (_) => null,
      );
      return response;
    } catch (e) {
      debugPrint('Error deleting offer: $e');
      return ApiResponse<void>(success: false, message: e.toString());
    }
  }

  /// Accept the final task assignment
  Future<ApiResponse<Map<String, dynamic>>> acceptTask(int offerId) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/driver/task-ads/offers/$offerId/accept',
        fromJson: (json) => Map<String, dynamic>.from(json),
      );
      return response;
    } catch (e) {
      debugPrint('Error accepting task: $e');
      return ApiResponse<Map<String, dynamic>>(success: false, message: e.toString());
    }
  }

  /// Reject the task assignment
  Future<ApiResponse<Map<String, dynamic>>> rejectTask(int offerId) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/driver/task-ads/offers/$offerId/reject',
        fromJson: (json) => Map<String, dynamic>.from(json),
      );
      return response;
    } catch (e) {
      debugPrint('Error rejecting task: $e');
      return ApiResponse<Map<String, dynamic>>(success: false, message: e.toString());
    }
  }

  /// Helper methods for UI logic
  bool canSubmitOffer(TaskAd ad) {
    return ad.status == 'running' && ad.myOffer == null;
  }

  bool canEditOffer(TaskAd ad) {
    return ad.status == 'running' && ad.myOffer != null && ad.myOffer!.accepted == false;
  }

  bool canAcceptTask(TaskAd ad) {
    // A driver can accept the task if:
    // 1. They have an offer on this ad
    // 2. The customer has accepted THEIR offer
    // 3. The ad is either still running or was just closed for them
    return ad.myOffer != null && ad.myOffer!.accepted == true;
  }
}
