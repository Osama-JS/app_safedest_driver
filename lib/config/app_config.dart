class AppConfig {
  // API Configuration
  // static const String baseUrl = 'http://192.168.0.186/safedestssss/public/api'; // For Devlober
  // static const String baseUrl = 'https://tester.safedest.com/admin/tasks/api'; // For Tester
  static const String baseUrl = 'https://o.safedest.com/api'; // For Production

  // App Information
  static const String appName = 'SafeDests Driver';
  static const String appVersion = '1.0.0';

  // API Endpoints
  static const String loginEndpoint = '/driver/login';
  static const String logoutEndpoint = '/driver/logout';
  static const String profileEndpoint = '/driver/profile';
  static const String updateProfileEndpoint = '/driver/profile';
  static const String additionalDataEndpoint =
      '/driver/profile/additional-data';
  static const String changePasswordEndpoint = '/driver/change-password';
  static const String refreshTokenEndpoint = '/driver/refresh-token';
  static const String forgotPasswordEndpoint = '/driver/forgot-password';
  static const String registrationDataEndpoint = '/driver/registration-data';
  static const String registerEndpoint = '/driver/register';
  static const String resendVerificationEndpoint =
      '/driver/resend-verification';

  // Tasks Endpoints
  static const String tasksEndpoint = '/driver/tasks';
  static const String taskDetailsEndpoint = '/driver/tasks';
  static const String acceptTaskEndpoint = '/driver/tasks';
  static const String rejectTaskEndpoint = '/driver/tasks';
  static const String updateTaskStatusEndpoint = '/driver/tasks';
  static const String taskHistoryEndpoint = '/driver/tasks/history/completed';

  // Location Endpoints
  static const String updateLocationEndpoint = '/driver/location';
  static const String updateStatusEndpoint = '/driver/status';
  static const String getCurrentStatusEndpoint = '/driver/location/status';
  static const String updateFcmTokenEndpoint = '/driver/fcm-token';

  // Wallet Endpoints
  static const String walletEndpoint = '/driver/wallet';
  static const String transactionsEndpoint = '/driver/wallet/transactions';
  static const String earningsStatsEndpoint = '/driver/wallet/earnings/stats';

  // Notifications Endpoints
  static const String notificationsEndpoint = '/driver/notifications';
  static const String markNotificationReadEndpoint = '/driver/notifications';
  static const String markAllNotificationsReadEndpoint =
      '/driver/notifications/read-all';
  static const String notificationSettingsEndpoint =
      '/driver/notifications/settings';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String driverDataKey = 'driver_data';
  static const String fcmTokenKey = 'fcm_token';
  static const String deviceIdKey = 'device_id';

  // Location Settings
  static const double locationUpdateInterval = 180.0; // seconds (3 minutes)
  static const double minDistanceFilter = 10.0; // meters

  // UI Settings
  static const int splashDuration = 3; // seconds
  static const int requestTimeout = 30; // seconds

  // Map Settings
  static const double defaultZoom = 15.0;
  static const double trackingZoom = 18.0;

  // Notification Settings
  static const String notificationChannelId = 'safedests_driver_channel';
  static const String notificationChannelName =
      'SafeDests Driver Notifications';
  static const String notificationChannelDescription =
      'Notifications for SafeDests driver app';

  // Colors - Red Theme
  static const int primaryColorValue = 0xFFd40019; // Red
  static const int secondaryColorValue = 0xFFFF5722; // Deep Orange
  static const int errorColorValue = 0xFFB71C1C; // Dark Red
  static const int successColorValue = 0xFF4CAF50; // Green (keep for success)
  static const int warningColorValue = 0xFFFF9800; // Orange (keep for warning)

  // Task Status Colors - Red Theme
  static const int pendingColorValue = 0xFFFF9800; // Orange
  static const int acceptedColorValue = 0xFFd40019; // Red
  static const int inProgressColorValue = 0xFFE91E63; // Pink
  static const int completedColorValue = 0xFF4CAF50; // Green
  static const int cancelledColorValue = 0xFFB71C1C; // Dark Red

  // Environment Check
  static bool get isDebug {
    bool inDebugMode = false;
    assert(inDebugMode = true);
    return inDebugMode;
  }

  static bool get isProduction => !isDebug;

  // Get full API URL
  static String getApiUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }

  // Get task endpoint with ID
  static String getTaskEndpoint(int taskId, String action) {
    return '$tasksEndpoint/$taskId/$action';
  }

  // Get notification endpoint with ID
  static String getNotificationEndpoint(int notificationId, String action) {
    return '$markNotificationReadEndpoint/$notificationId/$action';
  }

  // Get storage URL for files
  static String getStorageUrl(String filePath) {
    // إزالة /api من baseUrl للحصول على رابط الملفات
    final storageBaseUrl = baseUrl.replaceAll('/api', '');

    if (filePath.startsWith('storage/')) {
      return '$storageBaseUrl/$filePath';
    } else {
      return '$storageBaseUrl/storage/$filePath';
    }
  }
}
