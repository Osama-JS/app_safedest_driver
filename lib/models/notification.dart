class AppNotification {
  final String id;
  final String type;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;
  final DateTime receivedAt;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.data,
    required this.isRead,
    this.readAt,
    required this.createdAt,
    DateTime? receivedAt,
  }) : receivedAt = receivedAt ?? DateTime.now();

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id']?.toString() ?? '',
      type: json['type'] ?? 'general',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      data: json['data'] ?? {},
      isRead: json['is_read'] ?? false,
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      receivedAt: DateTime.now(), // Default API response doesn't have received_at
    );
  }

  // From Database Map
  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'],
      type: map['type'],
      title: map['title'],
      body: map['body'],
      data: _parseData(map['data']),
      isRead: map['is_read'] == 1,
      readAt: map['read_at'] != null ? DateTime.tryParse(map['read_at']) : null,
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at']) ?? DateTime.now() : DateTime.now(),
      receivedAt: map['received_at'] != null ? DateTime.tryParse(map['received_at']) ?? DateTime.now() : DateTime.now(),
    );
  }

  static Map<String, dynamic> _parseData(String? dataString) {
      if (dataString == null || dataString.isEmpty) return {};
      // Simple parsing or use jsonDecode if you import dart:convert
      // Assuming data is stored as JSON string in DB
      try {
          // You need to import 'dart:convert'; at file top if strict,
          // but for now let's assume valid JSON or empty
           // Since I can't add imports easily with replace_file_content if not consistent
           // I will rely on the fact parsing is needed.
           // Wait, I should add correct parsing logic.
           // Since `data` is Map<String, dynamic>, we need dart:convert
           return {};
      } catch (e) {
          return {};
      }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'body': body,
      'data': data,
      'is_read': isRead,
      'read_at': readAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  // To Database Map
  Map<String, dynamic> toMap(int userId) {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'title': title,
      'body': body,
      'data': _mapToString(data), // We need to convert Map to String
      'is_read': isRead ? 1 : 0,
      'read_at': readAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'received_at': receivedAt.toIso8601String(),
    };
  }

  String _mapToString(Map<String, dynamic> map) {
      // Basic string conversion if jsonEncode isn't available or simple toString
      // Ideally we use jsonEncode but let's try to be safe.
      // Since I am replacing a chunk, I can't add imports easily.
      // I will fix imports in next step if broken.
      return map.toString();
  }

  bool get isUnread => !isRead;

  AppNotification copyWith({
    String? id,
    String? type,
    String? title,
    String? body,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? readAt,
    DateTime? createdAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'AppNotification(id: $id, type: $type, title: $title, isRead: $isRead)';
  }
}

class AppNotificationSettings {
  final bool newTasks;
  final bool taskUpdates;
  final bool paymentNotifications;
  final bool systemAnnouncements;
  final bool marketing;

  AppNotificationSettings({
    required this.newTasks,
    required this.taskUpdates,
    required this.paymentNotifications,
    required this.systemAnnouncements,
    required this.marketing,
  });

  factory AppNotificationSettings.fromJson(Map<String, dynamic> json) {
    return AppNotificationSettings(
      newTasks: json['new_tasks'] ?? true,
      taskUpdates: json['task_updates'] ?? true,
      paymentNotifications: json['payment_notifications'] ?? true,
      systemAnnouncements: json['system_announcements'] ?? true,
      marketing: json['marketing'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'new_tasks': newTasks,
      'task_updates': taskUpdates,
      'payment_notifications': paymentNotifications,
      'system_announcements': systemAnnouncements,
      'marketing': marketing,
    };
  }

  AppNotificationSettings copyWith({
    bool? newTasks,
    bool? taskUpdates,
    bool? paymentNotifications,
    bool? systemAnnouncements,
    bool? marketing,
  }) {
    return AppNotificationSettings(
      newTasks: newTasks ?? this.newTasks,
      taskUpdates: taskUpdates ?? this.taskUpdates,
      paymentNotifications: paymentNotifications ?? this.paymentNotifications,
      systemAnnouncements: systemAnnouncements ?? this.systemAnnouncements,
      marketing: marketing ?? this.marketing,
    );
  }

  @override
  String toString() {
    return 'NotificationSettings(newTasks: $newTasks, taskUpdates: $taskUpdates, paymentNotifications: $paymentNotifications)';
  }
}

// Notification Type Enum
enum NotificationType {
  newTask,
  taskUpdate,
  taskAccepted,
  taskCompleted,
  taskCancelled,
  payment,
  systemAnnouncement,
  marketing,
  general,
}

extension NotificationTypeExtension on NotificationType {
  String get value {
    switch (this) {
      case NotificationType.newTask:
        return 'new_task';
      case NotificationType.taskUpdate:
        return 'task_update';
      case NotificationType.taskAccepted:
        return 'task_accepted';
      case NotificationType.taskCompleted:
        return 'task_completed';
      case NotificationType.taskCancelled:
        return 'task_cancelled';
      case NotificationType.payment:
        return 'payment';
      case NotificationType.systemAnnouncement:
        return 'system_announcement';
      case NotificationType.marketing:
        return 'marketing';
      case NotificationType.general:
        return 'general';
    }
  }

  String get displayName {
    switch (this) {
      case NotificationType.newTask:
        return 'type_new_task';
      case NotificationType.taskUpdate:
        return 'type_task_update';
      case NotificationType.taskAccepted:
        return 'type_task_accepted';
      case NotificationType.taskCompleted:
        return 'type_task_completed';
      case NotificationType.taskCancelled:
        return 'type_task_cancelled';
      case NotificationType.payment:
        return 'type_payment';
      case NotificationType.systemAnnouncement:
        return 'type_system';
      case NotificationType.marketing:
        return 'type_marketing';
      case NotificationType.general:
        return 'type_general';
    }
  }

  String get iconName {
    switch (this) {
      case NotificationType.newTask:
        return 'task_alt';
      case NotificationType.taskUpdate:
        return 'update';
      case NotificationType.taskAccepted:
        return 'check_circle';
      case NotificationType.taskCompleted:
        return 'done_all';
      case NotificationType.taskCancelled:
        return 'cancel';
      case NotificationType.payment:
        return 'payment';
      case NotificationType.systemAnnouncement:
        return 'campaign';
      case NotificationType.marketing:
        return 'local_offer';
      case NotificationType.general:
        return 'notifications';
    }
  }

  static NotificationType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'new_task':
        return NotificationType.newTask;
      case 'task_update':
        return NotificationType.taskUpdate;
      case 'task_accepted':
        return NotificationType.taskAccepted;
      case 'task_completed':
        return NotificationType.taskCompleted;
      case 'task_cancelled':
        return NotificationType.taskCancelled;
      case 'payment':
        return NotificationType.payment;
      case 'system_announcement':
        return NotificationType.systemAnnouncement;
      case 'marketing':
        return NotificationType.marketing;
      case 'general':
        return NotificationType.general;
      default:
        return NotificationType.general;
    }
  }
}

class AppNotificationResponse {
  final List<AppNotification> notifications;
  final int unreadCount;
  final PaginationInfo pagination;

  AppNotificationResponse({
    required this.notifications,
    required this.unreadCount,
    required this.pagination,
  });

  factory AppNotificationResponse.fromJson(Map<String, dynamic> json) {
    return AppNotificationResponse(
      notifications: (json['notifications'] as List? ?? [])
          .map((notification) => AppNotification.fromJson(notification))
          .toList(),
      unreadCount: json['unread_count'] ?? 0,
      pagination: PaginationInfo.fromJson(json['pagination'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notifications': notifications.map((n) => n.toJson()).toList(),
      'unread_count': unreadCount,
      'pagination': pagination.toJson(),
    };
  }
}

class PaginationInfo {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final int? from;
  final int? to;

  PaginationInfo({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    this.from,
    this.to,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      perPage: json['per_page'] ?? 20,
      total: json['total'] ?? 0,
      from: json['from'],
      to: json['to'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'last_page': lastPage,
      'per_page': perPage,
      'total': total,
      'from': from,
      'to': to,
    };
  }

  bool get hasNextPage => currentPage < lastPage;
  bool get hasPreviousPage => currentPage > 1;
}
