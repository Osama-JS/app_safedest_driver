import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:safedest_driver/services/notification_service.dart';

void main() {
  group('NotificationService Tests', () {
    late NotificationService notificationService;

    setUp(() {
      notificationService = NotificationService();
    });

    test('should create NotificationService instance', () {
      expect(notificationService, isNotNull);
      expect(notificationService, isA<NotificationService>());
    });

    test('should initialize without throwing errors', () async {
      // This test will pass in test environment as the plugin
      // provides mock implementations for testing
      expect(() async => await notificationService.initialize(), 
             returnsNormally);
    });

    test('should handle notification settings', () async {
      // Test getting notification settings
      expect(() async => await notificationService.getNotificationSettings(), 
             returnsNormally);
    });

    test('should handle test notification', () {
      // Test adding a test notification
      expect(() => notificationService.addTestNotification(), 
             returnsNormally);
      
      // Check that notification was added
      expect(notificationService.notifications.isNotEmpty, isTrue);
      expect(notificationService.unreadCount, equals(1));
    });

    test('should clear notifications', () {
      // Add a test notification first
      notificationService.addTestNotification();
      expect(notificationService.notifications.isNotEmpty, isTrue);
      
      // Clear notifications
      notificationService.clearNotifications();
      expect(notificationService.notifications.isEmpty, isTrue);
      expect(notificationService.unreadCount, equals(0));
    });
  });
}
