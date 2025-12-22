import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../Helpers/NotificationHelper.dart';
import '../models/notification.dart';
import '../models/api_response.dart';
import '../config/app_config.dart';

class NotificationController extends GetxController {
  final NotificationHelper _notificationHelper = NotificationHelper();
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  // Reactive state
  final RxList<AppNotification> notifications = <AppNotification>[].obs;
  final RxInt unreadCount = 0.obs;
  final RxBool isLoading = false.obs;
  final RxString fcmToken = "".obs;

  @override
  void onInit() {
    super.onInit();
    _initNotificationSystem();
  }

  Future<void> _initNotificationSystem() async {
    try {
      await _initializeLocalNotifications();
      await _initializeFirebaseMessaging();
      fetchNotifications();
    } catch (e) {
      debugPrint("NotificationController init error: $e");
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        debugPrint("Local notification tapped: ${response.payload}");
      },
    );

    final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();

      const channel = AndroidNotificationChannel(
        AppConfig.notificationChannelId,
        AppConfig.notificationChannelName,
        description: AppConfig.notificationChannelDescription,
        importance: Importance.high,
      );
      await androidPlugin.createNotificationChannel(channel);
    }
  }

  Future<void> _initializeFirebaseMessaging() async {
    final messaging = FirebaseMessaging.instance;

    // Request permission
    await messaging.requestPermission(alert: true, badge: true, sound: true);

    // Get token
    final token = await messaging.getToken().timeout(const Duration(seconds: 10));
    if (token != null) {
      fcmToken.value = token;
      await _notificationHelper.updateFcmToken(token);
    }

    messaging.onTokenRefresh.listen((newToken) {
      fcmToken.value = newToken;
      _notificationHelper.updateFcmToken(newToken);
    });

    // Handle messages
    FirebaseMessaging.onMessage.listen((message) {
      _showLocalNotification(message);
      _addFromRemote(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      // Handle navigation
    });
  }

  void _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const androidDetails = AndroidNotificationDetails(
      AppConfig.notificationChannelId,
      AppConfig.notificationChannelName,
      channelDescription: AppConfig.notificationChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      message.hashCode,
      notification.title,
      notification.body,
      details,
      payload: message.data.toString(),
    );
  }

  void _addFromRemote(RemoteMessage message) {
    final notification = AppNotification(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      type: message.data['type'] ?? 'general',
      title: message.notification?.title ?? 'إشعار جديد',
      body: message.notification?.body ?? 'لديك إشعار جديد',
      data: message.data,
      isRead: false,
      createdAt: DateTime.now(),
    );
    notifications.insert(0, notification);
    unreadCount.value++;
  }

  // API operations
  Future<void> fetchNotifications({int page = 1, bool refresh = false}) async {
    if (page == 1) isLoading.value = true;
    try {
      final response = await _notificationHelper.getNotifications(page: page);
      if (response.isSuccess && response.data != null) {
        if (page == 1 || refresh) {
          notifications.assignAll(response.data!.notifications);
        } else {
          notifications.addAll(response.data!.notifications);
        }
        unreadCount.value = response.data!.unreadCount;
      }
    } finally {
      if (page == 1) isLoading.value = false;
    }
  }

  Future<void> markAsRead(String id) async {
    final response = await _notificationHelper.markAsRead(id);
    if (response.isSuccess) {
      final index = notifications.indexWhere((n) => n.id == id);
      if (index != -1 && !notifications[index].isRead) {
        notifications[index] = notifications[index].copyWith(isRead: true);
        unreadCount.value = (unreadCount.value - 1).clamp(0, 9999);
      }
    }
  }

  Future<void> markAllAsRead() async {
    final response = await _notificationHelper.markAllAsRead();
    if (response.isSuccess) {
      notifications.assignAll(notifications.map((n) => n.copyWith(isRead: true)).toList());
      unreadCount.value = 0;
    }
  }

  void reset() {
    notifications.clear();
    unreadCount.value = 0;
  }
}
