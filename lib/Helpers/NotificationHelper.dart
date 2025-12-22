import '../services/api_service.dart';
import '../config/app_config.dart';
import '../models/api_response.dart';
import '../models/notification.dart';

class NotificationHelper {
  final ApiService _apiService = ApiService();

  // Get notifications
  Future<ApiResponse<AppNotificationResponse>> getNotifications({
    int page = 1,
    int perPage = 20,
    bool unreadOnly = false,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'per_page': perPage.toString(),
      'unread_only': unreadOnly.toString(),
    };

    return await _apiService.get<AppNotificationResponse>(
      AppConfig.notificationsEndpoint,
      queryParams: queryParams,
      fromJson: (data) => AppNotificationResponse.fromJson(data),
    );
  }

  // Mark notification as read
  Future<ApiResponse<void>> markAsRead(String notificationId) async {
    return await _apiService.post<void>(
      '${AppConfig.notificationsEndpoint}/$notificationId/read',
      fromJson: (data) => null,
    );
  }

  // Mark all notifications as read
  Future<ApiResponse<void>> markAllAsRead() async {
    return await _apiService.post<void>(
      '${AppConfig.notificationsEndpoint}/read-all',
      fromJson: (data) => null,
    );
  }

  // Update FCM token
  Future<ApiResponse<void>> updateFcmToken(String token) async {
    return await _apiService.post<void>(
      AppConfig.updateFcmTokenEndpoint,
      body: {'fcm_token': token},
      fromJson: (data) => null,
    );
  }

  // Get settings
  Future<ApiResponse<AppNotificationSettings>> getSettings() async {
    return await _apiService.get<AppNotificationSettings>(
      AppConfig.notificationSettingsEndpoint,
      fromJson: (data) => AppNotificationSettings.fromJson(data['settings']),
    );
  }

  // Update settings
  Future<ApiResponse<AppNotificationSettings>> updateSettings(AppNotificationSettings settings) async {
    return await _apiService.put<AppNotificationSettings>(
      AppConfig.notificationSettingsEndpoint,
      body: settings.toJson(),
      fromJson: (data) => AppNotificationSettings.fromJson(data['settings']),
    );
  }
}
