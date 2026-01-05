import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../Helpers/NotificationHelper.dart';
import '../models/notification.dart';
import '../models/api_response.dart';
import '../config/app_config.dart';
import '../screens/main/main_screen.dart';
import 'TaskController.dart';

class NotificationController extends GetxController {
  final NotificationHelper _notificationHelper = NotificationHelper();
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final FlutterTts _flutterTts = FlutterTts(); // Initialize TTS

  // Reactive state
  final RxList<AppNotification> notifications = <AppNotification>[].obs;
  final RxInt unreadCount = 0.obs;
  final RxBool isLoading = false.obs;
  final RxString fcmToken = "".obs;

  @override
  void onInit() {
    super.onInit();
    _initNotificationSystem();
    _initTts(); // Init TTS
  }

  Future<void> _initTts() async {
    try {
      await _flutterTts.setLanguage("ar-SA");
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
    } catch (e) {
      debugPrint("TTS Init Error: $e");
    }
  }

  // ... (previous init methods) ...

  void _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    // Group Key for bundling notifications
    const String groupKey = 'com.safedest.driver.NOTIFICATIONS_GROUP';

    // Individual Notification Details
    const androidDetails = AndroidNotificationDetails(
      'safedests_driver_channel_v5',
      'SafeDests Driver Notifications',
      channelDescription: 'Notifications for SafeDests driver app',
      importance: Importance.max,
      priority: Priority.max,
      sound: RawResourceAndroidNotificationSound('alert_sound'),
      playSound: true,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      category: AndroidNotificationCategory.alarm,
      fullScreenIntent: true,
      visibility: NotificationVisibility.public,
      groupKey: groupKey, // Add to group
    );
    const details = NotificationDetails(android: androidDetails);

    // Show individual notification
    await _localNotifications.show(
      message.hashCode,
      notification.title,
      notification.body,
      details,
      payload: message.data.toString(),
    );

    // Speak title after delay
    if (notification.title != null && notification.title!.isNotEmpty) {
       _speakNotificationTitle(notification.title!);
    }

    // Show/Update Summary Notification
    // ...
  }

  Future<void> showSimpleNotification({
    required String title,
    required String body,
    String? payload,
    String? channelId,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId ?? 'safedests_driver_channel_v5',
      'SafeDests Driver Notifications',
      channelDescription: 'Notifications for SafeDests driver app',
      importance: Importance.max,
      priority: Priority.max,
      sound: const RawResourceAndroidNotificationSound('alert_sound'),
      playSound: true,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      category: AndroidNotificationCategory.alarm,
      fullScreenIntent: true,
      visibility: NotificationVisibility.public,
    );
    final details = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      details,
      payload: payload,
    );
  }

  Future<void> _speakNotificationTitle(String text) async {
    try {
       // Wait for alert sound to finish (approx 2 seconds)
       await Future.delayed(const Duration(seconds: 2));
       await _flutterTts.speak(text);
    } catch (e) {
      debugPrint("TTS Speak Error: $e");
    }
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
        if (response.payload != null) {
          try {
             // Basic payload parsing if it's a simple string or JSON
             // For now, we assume we might need to handle navigation based on ID or type if available
          } catch (e) {
            debugPrint("Error parsing notification payload: $e");
          }
        }
      },
    );

    final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();

      // Updated channel with custom sound and Alarm usage for max attention
      const channel = AndroidNotificationChannel(
        'safedests_driver_channel_v5', // New Channel ID to force update
        'SafeDests Driver Notifications',
        description: 'Notifications for SafeDests driver app',
        importance: Importance.max, // Max importance
        sound: RawResourceAndroidNotificationSound('alert_sound'),
        playSound: true,
        audioAttributesUsage: AudioAttributesUsage.alarm, // Use Alarm stream (usually louder)
      );
      await androidPlugin.createNotificationChannel(channel);
    }
  }

  Future<void> _initializeFirebaseMessaging() async {
    final messaging = FirebaseMessaging.instance;

    // Request permission
    await messaging.requestPermission(alert: true, badge: true, sound: true);

    // Get token
    try {
      final token = await messaging.getToken().timeout(const Duration(seconds: 10));
      if (token != null) {
        fcmToken.value = token;
        await _notificationHelper.updateFcmToken(token);
        debugPrint("\n🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥");
        debugPrint("🔥 FCM TOKEN: $token");
        debugPrint("🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥\n");
      }
    } catch (e) {
       debugPrint("Error getting FCM token: $e");
    }

    messaging.onTokenRefresh.listen((newToken) {
      fcmToken.value = newToken;
      _notificationHelper.updateFcmToken(newToken);
      debugPrint("\n♻️♻️♻️♻️♻️♻️♻️♻️♻️♻️♻️♻️♻️♻️♻️♻️♻️♻️");
      debugPrint("♻️ FCM TOKEN REFRESHED: $newToken");
      debugPrint("♻️♻️♻️♻️♻️♻️♻️♻️♻️♻️♻️♻️♻️♻️♻️♻️♻️♻️\n");
    });

    // Handle messages
    FirebaseMessaging.onMessage.listen((message) {
      debugPrint("Foreground message received: ${message.messageId}");
      _showLocalNotification(message);
      _addFromRemote(message);

      // Update pending task if it's a new task
      final type = message.data['type'];
      final id = message.data['id'];
      if (type == 'new_task' && id != null) {
        final taskController = Get.find<TaskController>();
        taskController.getTaskDetails(int.parse(id.toString())).then((response) {
          if (response.isSuccess && response.data != null) {
            taskController.pendingTask.value = response.data;
          }
        });
      }
    });

    // Handle background notification tap
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint("Notification opened app: ${message.data}");
      _handleNavigation(message.data);
    });
  }


  Future<void> handleNotificationTap(AppNotification notification) async {
    // 1. Mark as read immediately (optimistic update or at least immediate API call)
    if (!notification.isRead) {
      markAsRead(notification.id); // Non-awaited for faster UI feel
    }

    // 2. Handle Navigation
    _handleNavigation(notification.data);
  }

  void _handleNavigation(Map<String, dynamic> data) {
    if (data.isEmpty) return;

    final type = data['type'];
    final id = data['id'];

    debugPrint("Handling navigation for type: $type, id: $id");

    if (type == 'new_task' || type == 'task_update') {
      // Set as pending task in TaskController if ID is present
      if (id != null) {
        final taskController = Get.find<TaskController>();
        taskController.getTaskDetails(int.parse(id.toString())).then((response) {
          if (response.isSuccess && response.data != null) {
            taskController.pendingTask.value = response.data;
          }
        });
      }

      // Navigate to main screen
      Get.toNamed('/main');
    } else if (type == 'wallet') {
      Get.toNamed('/wallet'); // Example route
    } else {
       // Default to notifications screen or stay on main
       // If you have a notifications screen:
       // Get.to(() => NotificationsScreen());
    }
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
