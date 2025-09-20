import 'package:flutter/foundation.dart';
import '../models/api_response.dart';
import 'api_service.dart';

class TaskAdsStatsService extends ChangeNotifier {
  static final TaskAdsStatsService _instance = TaskAdsStatsService._internal();
  factory TaskAdsStatsService() => _instance;
  TaskAdsStatsService._internal();

  final ApiService _apiService = ApiService();

  // Stats data
  int _availableAds = 0;
  int _myOffers = 0;
  int _acceptedOffers = 0;
  bool _isLoading = false;
  String? _error;

  // Getters
  int get availableAds => _availableAds;
  int get myOffers => _myOffers;
  int get acceptedOffers => _acceptedOffers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load task ads statistics
  Future<void> loadStats() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('Loading task ads statistics...');

      final response = await _apiService.get<Map<String, dynamic>>(
        '/driver/task-ads/stats',
        fromJson: (json) => json['data'] ?? json,
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        
        _availableAds = _parseToInt(data['available_ads']) ?? 0;
        _myOffers = _parseToInt(data['my_offers']) ?? 0;
        _acceptedOffers = _parseToInt(data['accepted_offers']) ?? 0;

        debugPrint('Task ads stats loaded: Available: $_availableAds, My Offers: $_myOffers, Accepted: $_acceptedOffers');
      } else {
        _error = response.message ?? 'Failed to load statistics';
        debugPrint('Error loading task ads stats: $_error');
      }
    } catch (e) {
      _error = 'Failed to load statistics: $e';
      debugPrint('Exception loading task ads stats: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh statistics
  Future<void> refreshStats() async {
    await loadStats();
  }

  /// Clear statistics
  void clearStats() {
    _availableAds = 0;
    _myOffers = 0;
    _acceptedOffers = 0;
    _error = null;
    notifyListeners();
  }

  /// Update stats after submitting an offer
  void incrementMyOffers() {
    _myOffers++;
    notifyListeners();
  }

  /// Update stats after offer is accepted
  void incrementAcceptedOffers() {
    _acceptedOffers++;
    if (_myOffers > 0) {
      _myOffers--; // Move from pending to accepted
    }
    notifyListeners();
  }

  /// Update stats after offer is rejected
  void decrementMyOffers() {
    if (_myOffers > 0) {
      _myOffers--;
    }
    notifyListeners();
  }

  /// Helper method for safe integer parsing
  static int? _parseToInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  /// Get formatted stats for display
  Map<String, String> getFormattedStats() {
    return {
      'available_ads': _availableAds.toString(),
      'my_offers': _myOffers.toString(),
      'accepted_offers': _acceptedOffers.toString(),
    };
  }

  /// Check if stats are empty (all zeros)
  bool get hasStats => _availableAds > 0 || _myOffers > 0 || _acceptedOffers > 0;

  /// Get total activity count
  int get totalActivity => _availableAds + _myOffers + _acceptedOffers;
}
