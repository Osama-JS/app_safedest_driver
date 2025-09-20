import 'package:flutter/foundation.dart';
import '../models/api_response.dart';
import '../models/task_ad.dart';
import '../models/task_offer.dart';
import 'api_service.dart';

class TaskAdsService {
  static final TaskAdsService _instance = TaskAdsService._internal();
  factory TaskAdsService() => _instance;
  TaskAdsService._internal();

  final ApiService _apiService = ApiService();

  /// Get list of task advertisements
  Future<ApiResponse<TaskAdListResponse>> getTaskAds({
    int page = 1,
    int perPage = 10,
    String? search,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (minPrice != null) {
        queryParams['min_price'] = minPrice.toString();
      }
      if (maxPrice != null) {
        queryParams['max_price'] = maxPrice.toString();
      }
      if (sortBy != null && sortBy.isNotEmpty) {
        queryParams['sort_by'] = sortBy;
      }
      if (sortOrder != null && sortOrder.isNotEmpty) {
        queryParams['sort_order'] = sortOrder;
      }

      debugPrint('TaskAdsService: Getting task ads with params: $queryParams');
      debugPrint(
          'TaskAdsService: Individual params - search: $search, minPrice: $minPrice, maxPrice: $maxPrice, sortBy: $sortBy, sortOrder: $sortOrder');

      final response = await _apiService.get<TaskAdListResponse>(
        '/driver/task-ads',
        queryParams: queryParams,
        fromJson: (json) {
          debugPrint('TaskAdsService: Raw JSON response: $json');
          final result = TaskAdListResponse.fromJson(json);
          debugPrint('TaskAdsService: Parsed ads count: ${result.data.length}');
          return result;
        },
      );

      debugPrint('TaskAdsService: Final response success: ${response.success}');
      debugPrint('TaskAdsService: Final response message: ${response.message}');
      return response;
    } catch (e) {
      debugPrint('Error getting task ads: $e');
      return ApiResponse<TaskAdListResponse>(
        success: false,
        message: 'Failed to load task advertisements: $e',
      );
    }
  }

  /// Get task advertisement details
  Future<ApiResponse<TaskAd>> getTaskAdDetails(int adId) async {
    try {
      debugPrint('Getting task ad details for ID: $adId');

      final response = await _apiService.get<TaskAd>(
        '/driver/task-ads/$adId',
        fromJson: (json) => TaskAd.fromJson(json['data'] ?? json),
      );

      debugPrint('Task ad details response: ${response.success}');
      return response;
    } catch (e) {
      debugPrint('Error getting task ad details: $e');
      return ApiResponse<TaskAd>(
        success: false,
        message: 'Failed to load advertisement details: $e',
      );
    }
  }

  /// Get offers for a specific task advertisement
  Future<ApiResponse<TaskOfferListResponse>> getAdOffers(int adId) async {
    try {
      debugPrint('Getting offers for ad ID: $adId');

      final response = await _apiService.get<TaskOfferListResponse>(
        '/driver/task-ads/$adId/offers',
        fromJson: (json) => TaskOfferListResponse.fromJson(json),
      );

      debugPrint('Ad offers response: ${response.success}');
      return response;
    } catch (e) {
      debugPrint('Error getting ad offers: $e');
      return ApiResponse<TaskOfferListResponse>(
        success: false,
        message: 'Failed to load offers: $e',
      );
    }
  }

  /// Submit an offer for a task advertisement
  Future<ApiResponse<TaskOffer>> submitOffer({
    required int adId,
    required double price,
    required String description,
  }) async {
    try {
      debugPrint('Submitting offer for ad ID: $adId, price: $price');

      final body = {
        'price': price,
        'description': description,
      };

      final response = await _apiService.post<TaskOffer>(
        '/driver/task-ads/$adId/offers',
        body: body,
        fromJson: (json) => TaskOffer.fromJson(json['data'] ?? json),
      );

      debugPrint('Submit offer response: ${response.success}');
      return response;
    } catch (e) {
      debugPrint('Error submitting offer: $e');
      return ApiResponse<TaskOffer>(
        success: false,
        message: 'Failed to submit offer: $e',
      );
    }
  }

  /// Update an existing offer
  Future<ApiResponse<TaskOffer>> updateOffer({
    required int offerId,
    required double price,
    required String description,
  }) async {
    try {
      debugPrint('Updating offer ID: $offerId, new price: $price');

      final body = {
        'price': price,
        'description': description,
      };

      final response = await _apiService.put<TaskOffer>(
        '/driver/offers/$offerId',
        body: body,
        fromJson: (json) => TaskOffer.fromJson(json['data'] ?? json),
      );

      debugPrint('Update offer response: ${response.success}');
      return response;
    } catch (e) {
      debugPrint('Error updating offer: $e');
      return ApiResponse<TaskOffer>(
        success: false,
        message: 'Failed to update offer: $e',
      );
    }
  }

  /// Get driver's submitted offers
  Future<ApiResponse<MyOffersResponse>> getMyOffers({
    int page = 1,
    int perPage = 10,
    String? status, // pending, accepted, rejected
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      debugPrint('Getting my offers with params: $queryParams');

      final response = await _apiService.get<MyOffersResponse>(
        '/driver/my-offers',
        queryParams: queryParams,
        fromJson: (json) {
          debugPrint('TaskAdsService: Raw My Offers JSON response: $json');
          final result = MyOffersResponse.fromJson(json);
          debugPrint(
              'TaskAdsService: Parsed offers count: ${result.data.length}');
          return result;
        },
      );

      debugPrint(
          'TaskAdsService: Final my offers response success: ${response.success}');
      debugPrint(
          'TaskAdsService: Final my offers response message: ${response.message}');
      return response;
    } catch (e) {
      debugPrint('Error getting my offers: $e');
      return ApiResponse<MyOffersResponse>(
        success: false,
        message: 'Failed to load your offers: $e',
      );
    }
  }

  /// Accept a task after offer is approved by customer
  Future<ApiResponse<Map<String, dynamic>>> acceptTask(int offerId) async {
    try {
      debugPrint('Accepting task for offer ID: $offerId');

      final response = await _apiService.post<Map<String, dynamic>>(
        '/driver/offers/$offerId/accept',
        fromJson: (json) => json['data'] ?? json,
      );

      debugPrint('Accept task response: ${response.success}');
      return response;
    } catch (e) {
      debugPrint('Error accepting task: $e');
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Failed to accept task: $e',
      );
    }
  }

  /// Calculate driver net earnings from offer price and commission
  double calculateDriverNet({
    required double offerPrice,
    required double serviceCommission,
    required String serviceCommissionType,
    required double vatCommission,
  }) {
    try {
      // Calculate service commission
      double commission = serviceCommissionType == 'fixed'
          ? serviceCommission
          : (offerPrice * serviceCommission / 100);

      // Calculate VAT
      double vatAmount = offerPrice * vatCommission / 100;

      // Total deductions
      double totalDeduction = commission + vatAmount;

      // Net earnings
      double net = offerPrice - totalDeduction;

      debugPrint(
          'Price calculation: $offerPrice - $commission - $vatAmount = $net');
      return net > 0 ? net : 0;
    } catch (e) {
      debugPrint('Error calculating driver net: $e');
      return 0;
    }
  }

  /// Validate offer price against ad price range
  bool isValidOfferPrice(double price, double minPrice, double maxPrice) {
    return price >= minPrice && price <= maxPrice;
  }

  /// Format price for display
  String formatPrice(double price) {
    return '${price.toStringAsFixed(2)} ر.س';
  }

  /// Get offer status display text
  String getOfferStatusText(TaskOfferStatus status) {
    switch (status) {
      case TaskOfferStatus.pending:
        return 'في الانتظار';
      case TaskOfferStatus.accepted:
        return 'مقبول';
      case TaskOfferStatus.rejected:
        return 'مرفوض';
    }
  }

  /// Get ad status display text
  String getAdStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'running':
        return 'جاري';
      case 'closed':
        return 'مغلق';
      default:
        return status;
    }
  }

  /// Check if driver can submit offer
  bool canSubmitOffer(TaskAd ad) {
    return ad.status == 'running' &&
        ad.canSubmitOffer &&
        !ad.hasAcceptedOffer &&
        ad.myOffer == null;
  }

  /// Check if driver can edit offer
  bool canEditOffer(TaskAd ad) {
    return ad.status == 'running' &&
        ad.myOffer != null &&
        !ad.myOffer!.accepted &&
        !ad.hasAcceptedOffer;
  }

  /// Check if driver can accept task
  bool canAcceptTask(TaskAd ad) {
    return ad.myOffer != null && ad.myOffer!.accepted && ad.status == 'closed';
  }

  /// Assign task by offer (final step after offer acceptance)
  Future<ApiResponse<Map<String, dynamic>>> assignTaskByOffer(
      int offerId) async {
    try {
      debugPrint('Assigning task by offer ID: $offerId');

      final response = await _apiService.post<Map<String, dynamic>>(
        '/driver/offers/$offerId/assign-task',
      );

      debugPrint('Assign task by offer response: ${response.data}');

      return response;
    } catch (e) {
      debugPrint('Error assigning task by offer: $e');
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'فشل في تأكيد استلام المهمة: $e',
        data: null,
      );
    }
  }
}
