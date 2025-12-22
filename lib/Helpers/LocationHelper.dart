import 'package:geolocator/geolocator.dart';
import '../services/api_service.dart';
import '../config/app_config.dart';
import '../models/api_response.dart';

class LocationHelper {
  final ApiService _apiService = ApiService();

  // Get current status from server
  Future<ApiResponse<Map<String, dynamic>>> getCurrentStatus() async {
    return await _apiService.get<Map<String, dynamic>>(
      AppConfig.getCurrentStatusEndpoint,
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  // Update location on server
  Future<ApiResponse<void>> updateLocation(Position position) async {
    return await _apiService.post<void>(
      AppConfig.updateLocationEndpoint,
      body: {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
        'speed': position.speed,
        'heading': position.heading,
        'timestamp': DateTime.now().toIso8601String(),
      },
      fromJson: (data) => null,
    );
  }

  // Update online/offline status
  Future<ApiResponse<void>> updateDriverStatus({required bool online, String? status}) async {
    return await _apiService.post<void>(
      AppConfig.updateStatusEndpoint,
      body: {'online': online, if (status != null) 'status': status},
      fromJson: (data) => null,
    );
  }
}
