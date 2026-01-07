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
import 'AuthController.dart';
import '../services/notification_database.dart';

class NotificationController extends GetxController {
  final NotificationHelper _notificationHelper = NotificationHelper();
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final FlutterTts _flutterTts = FlutterTts();
  final NotificationDatabase _database = NotificationDatabase();

  // Reactive state
  final RxList<AppNotification> notifications = <AppNotification>[].obs;
  final RxInt unreadCount = 0.obs;
  final RxBool isLoading = false.obs;
  final RxString fcmToken = "".obs;

  // Filtering
  final RxString selectedFilter = 'all'.obs; // 'all', 'unread', 'read'
  final Rxn<NotificationType> selectedType = Rxn<NotificationType>(); // null for all

  List<AppNotification> get filteredNotifications {
    return notifications.where((n) {
      // 1. Filter by Status
      if (selectedFilter.value == 'unread' && n.isRead) return false;
      if (selectedFilter.value == 'read' && !n.isRead) return false;

      // 2. Filter by Type
      if (selectedType.value != null) {
         final type = NotificationTypeExtension.fromString(n.type);
         if (type != selectedType.value) return false;
      }

      return true;
    }).toList();
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  void setTypeFilter(NotificationType? type) {
    selectedType.value = type;
  }

  // Current user ID for database operations
  int? _currentUserId;

  @override
  void onInit() {
    super.onInit();
    _initNotificationSystem();
    _initTts();
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

  void _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const String groupKey = 'com.safedest.driver.NOTIFICATIONS_GROUP';

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
      groupKey: groupKey,
    );
    const details = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      message.hashCode,
      notification.title,
      notification.body,
      details,
      payload: message.data.toString(),
    );

    if (notification.title != null && notification.title!.isNotEmpty) {
       _speakNotificationTitle(notification.title!);
    }
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
        'safedests_driver_channel_v5',
        'SafeDests Driver Notifications',
        description: 'Notifications for SafeDests driver app',
        importance: Importance.max,
        sound: RawResourceAndroidNotificationSound('alert_sound'),
        playSound: true,
        audioAttributesUsage: AudioAttributesUsage.alarm,
      );
      await androidPlugin.createNotificationChannel(channel);
    }
  }

  Future<void> _initializeFirebaseMessaging() async {
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(alert: true, badge: true, sound: true);

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

    FirebaseMessaging.onMessage.listen((message) {
      debugPrint("Foreground message received: ${message.messageId}");
      _showLocalNotification(message);
      _addFromRemote(message);

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

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint("Notification opened app: ${message.data}");
      _handleNavigation(message.data);
    });
  }

  Future<void> handleNotificationTap(AppNotification notification) async {
    if (!notification.isRead) {
      markAsRead(notification.id);
    }
    _handleNavigation(notification.data);
  }

  void _handleNavigation(Map<String, dynamic> data) {
    if (data.isEmpty) return;
    final type = data['type'];
    final id = data['id'];

    debugPrint("Handling navigation for type: $type, id: $id");

    if (type == 'new_task' || type == 'task_update') {
      if (id != null) {
        final taskController = Get.find<TaskController>();
        taskController.getTaskDetails(int.parse(id.toString())).then((response) {
          if (response.isSuccess && response.data != null) {
            taskController.pendingTask.value = response.data;
          }
        });
      }
      Get.toNamed('/main');
    } else if (type == 'wallet') {
      Get.toNamed('/wallet');
    }
  }

  void _addFromRemote(RemoteMessage message) async {
    // Only add to DB if we have a valid logged-in user
    if (_currentUserId == null) {
        try {
            // Try to get user ID if not set
            if (Get.isRegistered<AuthController>()) {
                final authController = Get.find<AuthController>();
                _currentUserId = authController.currentDriver.value?.id;
            }
        } catch(e) {
            debugPrint("Could not find AuthController to get user ID");
        }
    }

    if (_currentUserId == null) return;

    final notification = AppNotification(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      type: message.data['type'] ?? 'general',
      title: message.notification?.title ?? 'إشعار جديد',
      body: message.notification?.body ?? 'لديك إشعار جديد',
      data: message.data,
      isRead: false,
      createdAt: DateTime.now(),
      receivedAt: DateTime.now(),
    );

    // Save to local DB
    await _database.insertNotification(notification, _currentUserId!);

    // Update UI list
    notifications.insert(0, notification);
    unreadCount.value++;
  }

  // Local Storage Operations
  Future<void> loadNotificationsForUser(int userId) async {
    isLoading.value = true;
    _currentUserId = userId;
    try {
      final localNotifications = await _database.getNotifications(userId);
      notifications.assignAll(localNotifications);

      final unread = await _database.getUnreadCount(userId);
      unreadCount.value = unread;
    } catch (e) {
        debugPrint("Error loading local notifications: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Deprecated: fetchNotifications is replaced by loadNotificationsForUser
  // Kept for compatibility if called elsewhere but redirects to local logic if user set
  Future<void> fetchNotifications({int page = 1, bool refresh = false}) async {
    if (_currentUserId != null) {
        await loadNotificationsForUser(_currentUserId!);
    } else {
        // Fallback or do nothing if no user
        debugPrint("Cannot fetch notifications: No user logged in");
    }
  }

  Future<void> markAsRead(String id) async {
    if (_currentUserId == null) return;

    await _database.markAsRead(id, _currentUserId!);

    // Optimistic UI update
    final index = notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !notifications[index].isRead) {
      notifications[index] = notifications[index].copyWith(isRead: true);
      if (unreadCount.value > 0) {
          unreadCount.value--;
      }
    }

    // Sync read status with server (optional, but good for cross-device)
    // _notificationHelper.markAsRead(id);
  }

  Future<void> markAllAsRead() async {
    if (_currentUserId == null) return;

    await _database.markAllAsRead(_currentUserId!);

    notifications.assignAll(notifications.map((n) => n.copyWith(isRead: true)).toList());
    unreadCount.value = 0;

    // Sync with server
    // _notificationHelper.markAllAsRead();
  }

  void reset() {
    notifications.clear();
    unreadCount.value = 0;
    _currentUserId = null;
  }
}
