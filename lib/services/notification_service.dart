import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../config/app_config.dart';
import '../models/api_response.dart';
import '../models/notification.dart';
import 'api_service.dart';

class NotificationService extends ChangeNotifier {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final ApiService _apiService = ApiService();
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  List<AppNotification> _notifications = [];
  AppNotificationSettings? _settings;
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _fcmToken;

  // Getters
  List<AppNotification> get notifications => _notifications;
  AppNotificationSettings? get settings => _settings;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get fcmToken => _fcmToken;

  // Initialize notification service
  Future<bool> initialize() async {
    try {
      debugPrint('Initializing NotificationService with Firebase...');

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Initialize Firebase Messaging
      await _initializeFirebaseMessaging();

      // Get notification settings
      await getNotificationSettings();

      debugPrint('NotificationService initialized successfully');
      return true;
    } catch (e) {
      debugPrint('Notification service initialization error: $e');
      return false;
    }
  }

  // Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request notification permissions for Android 13+
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }

    // Create notification channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      AppConfig.notificationChannelId,
      AppConfig.notificationChannelName,
      description: AppConfig.notificationChannelDescription,
      importance: Importance.high,
    );

    await androidImplementation?.createNotificationChannel(channel);
  }

  // Initialize Firebase Messaging
  Future<void> _initializeFirebaseMessaging() async {
    try {
      // Request permission for notifications
      NotificationSettings settings =
          await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('User granted permission');
      } else {
        debugPrint('User declined or has not accepted permission');
      }

      // Get FCM token with timeout
      debugPrint('Getting FCM token...');
      _fcmToken = await FirebaseMessaging.instance
          .getToken()
          .timeout(const Duration(seconds: 10));

      debugPrint('FCM Token obtained: ${_fcmToken?.substring(0, 20)}...');

      // Update token on server if available
      if (_fcmToken != null) {
        debugPrint('Updating FCM token on server...');
        await updateFcmToken(_fcmToken!);
      } else {
        debugPrint(
            '⚠️ FCM Token is null - Firebase may not be properly initialized');
      }

      // Listen for token refresh
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        debugPrint('FCM Token refreshed: ${newToken.substring(0, 20)}...');
        _fcmToken = newToken;
        updateFcmToken(newToken);
      });
    } catch (e) {
      debugPrint('❌ Error initializing Firebase Messaging: $e');
      // Don't throw error - app should continue working without FCM
    }

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

    // Handle notification taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
  }

  // Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Received foreground message: ${message.messageId}');

    // Show local notification
    _showLocalNotification(message);

    // Add to notifications list
    _addNotificationFromRemoteMessage(message);
  }

  // Handle background messages (static function required)
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    debugPrint('Received background message: ${message.messageId}');
  }

  // Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('Notification tapped: ${message.messageId}');
    // Handle navigation based on notification data
  }

  // Handle local notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Local notification tapped: ${response.payload}');
    // Handle navigation based on payload
  }

  // Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      AppConfig.notificationChannelId,
      AppConfig.notificationChannelName,
      channelDescription: AppConfig.notificationChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'إشعار جديد',
      message.notification?.body ?? 'لديك إشعار جديد',
      platformChannelSpecifics,
      payload: message.data.toString(),
    );
  }

  // Add notification from remote message
  void _addNotificationFromRemoteMessage(RemoteMessage message) {
    final notification = AppNotification(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      type: message.data['type'] ?? 'general',
      title: message.notification?.title ?? 'إشعار جديد',
      body: message.notification?.body ?? 'لديك إشعار جديد',
      data: message.data,
      createdAt: DateTime.now(),
      readAt: null,
    );

    _notifications.insert(0, notification);
    _unreadCount++;
    notifyListeners();
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Get notifications from server
  Future<ApiResponse<AppNotificationResponse>> getNotifications({
    int page = 1,
    int perPage = 20,
    bool unreadOnly = false,
  }) async {
    _setLoading(true);

    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'per_page': perPage.toString(),
        'unread_only': unreadOnly.toString(),
      };

      final response = await _apiService.get<AppNotificationResponse>(
        AppConfig.notificationsEndpoint,
        queryParams: queryParams,
        fromJson: (data) => AppNotificationResponse.fromJson(data),
      );

      debugPrint(
          '🔔 NotificationService: API response - success: ${response.isSuccess}, message: ${response.message}');

      if (response.isSuccess && response.data != null) {
        debugPrint(
            '🔔 NotificationService: Got ${response.data!.notifications.length} notifications, unread: ${response.data!.unreadCount}');
        debugPrint(
            '🔔 NotificationService: First notification: ${response.data!.notifications.isNotEmpty ? response.data!.notifications.first.title : 'none'}');
        if (page == 1) {
          _notifications = response.data!.notifications;
        } else {
          _notifications.addAll(response.data!.notifications);
        }
        _unreadCount = response.data!.unreadCount;
        debugPrint(
            '🔔 NotificationService: Updated local state - notifications: ${_notifications.length}, unread: $_unreadCount');
        notifyListeners();
      } else {
        debugPrint(
            '🔔 NotificationService: API call failed or no data - response.data is null: ${response.data == null}');
      }

      return response;
    } catch (e) {
      debugPrint('🔔 NotificationService: Exception occurred: $e');
      return ApiResponse<AppNotificationResponse>(
        success: false,
        message: 'فشل في جلب الإشعارات: $e',
      );
    } finally {
      _setLoading(false);
    }
  }

  // Mark notification as read
  Future<ApiResponse<void>> markAsRead(String notificationId) async {
    try {
      final response = await _apiService.post<void>(
        '${AppConfig.notificationsEndpoint}/$notificationId/read',
        fromJson: (data) {},
      );

      if (response.isSuccess) {
        // Update local notification
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1 && !_notifications[index].isRead) {
          _notifications[index] =
              _notifications[index].copyWith(readAt: DateTime.now());
          _unreadCount = (_unreadCount - 1).clamp(0, _unreadCount);
          notifyListeners();
        }
      }

      return response;
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        message: 'فشل في تحديد الإشعار كمقروء: $e',
      );
    }
  }

  // Mark all notifications as read
  Future<ApiResponse<void>> markAllAsRead() async {
    try {
      final response = await _apiService.post<void>(
        '${AppConfig.notificationsEndpoint}/read-all',
        fromJson: (data) {},
      );

      if (response.isSuccess) {
        // Update all local notifications
        _notifications = _notifications
            .map((n) => n.copyWith(readAt: DateTime.now()))
            .toList();
        _unreadCount = 0;
        notifyListeners();
      }

      return response;
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        message: 'فشل في تحديد جميع الإشعارات كمقروءة: $e',
      );
    }
  }

  // Get notification settings
  Future<ApiResponse<AppNotificationSettings>> getNotificationSettings() async {
    try {
      final response = await _apiService.get<AppNotificationSettings>(
        AppConfig.notificationSettingsEndpoint,
        fromJson: (data) => AppNotificationSettings.fromJson(data['settings']),
      );

      if (response.isSuccess && response.data != null) {
        _settings = response.data;
        notifyListeners();
      }

      return response;
    } catch (e) {
      return ApiResponse<AppNotificationSettings>(
        success: false,
        message: 'فشل في جلب إعدادات الإشعارات: $e',
      );
    }
  }

  // Update notification settings
  Future<ApiResponse<AppNotificationSettings>> updateNotificationSettings(
    AppNotificationSettings settings,
  ) async {
    try {
      final response = await _apiService.put<AppNotificationSettings>(
        AppConfig.notificationSettingsEndpoint,
        body: settings.toJson(),
        fromJson: (data) => AppNotificationSettings.fromJson(data['settings']),
      );

      if (response.isSuccess && response.data != null) {
        _settings = response.data;
        notifyListeners();
      }

      return response;
    } catch (e) {
      return ApiResponse<AppNotificationSettings>(
        success: false,
        message: 'فشل في تحديث إعدادات الإشعارات: $e',
      );
    }
  }

  // Update FCM token on server
  Future<ApiResponse<void>> updateFcmToken(String token) async {
    try {
      final response = await _apiService.post<void>(
        AppConfig.updateFcmTokenEndpoint,
        body: {'fcm_token': token},
        fromJson: (data) {},
      );

      if (response.isSuccess) {
        _fcmToken = token;
      }

      return response;
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        message: 'فشل في تحديث رمز الإشعارات: $e',
      );
    }
  }

  // Add a test notification (for development)
  void addTestNotification() {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: 'test',
      title: 'إشعار تجريبي',
      body: 'هذا إشعار تجريبي للاختبار',
      data: {'test': 'true'},
      createdAt: DateTime.now(),
      readAt: null, // null means unread
    );

    _notifications.insert(0, notification);
    _unreadCount++;
    notifyListeners();
  }

  // Clear all notifications
  void clearNotifications() {
    _notifications.clear();
    _unreadCount = 0;
    notifyListeners();
  }
}
