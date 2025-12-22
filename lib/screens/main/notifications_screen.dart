import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../models/notification.dart';
import '../../Controllers/NotificationController.dart';
import '../../config/app_config.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationController _notificationController = Get.find<NotificationController>();
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMoreData) {
      _loadMoreNotifications();
    }
  }

  Future<void> _loadNotifications() async {
    await _notificationController.fetchNotifications(page: 1, refresh: true);
    _currentPage = 1;
    _hasMoreData = true;
  }

  Future<void> _loadMoreNotifications() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    final previousCount = _notificationController.notifications.length;
    await _notificationController.fetchNotifications(page: _currentPage + 1);

    if (_notificationController.notifications.length == previousCount) {
      _hasMoreData = false;
    } else {
      _currentPage++;
    }

    setState(() {
      _isLoadingMore = false;
    });
  }

  Future<void> _refreshNotifications() async {
    await _loadNotifications();
  }

  String _formatNotificationTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return 'days_ago'.trParams({'days': difference.inDays.toString()});
    } else if (difference.inHours > 0) {
      return 'hours_ago'.trParams({'hours': difference.inHours.toString()});
    } else if (difference.inMinutes > 0) {
      return 'minutes_ago'.trParams({'minutes': difference.inMinutes.toString()});
    } else {
      return 'now'.tr;
    }
  }

  Future<void> _showNotificationDetails(AppNotification notification) async {
    await Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            _buildNotificationIcon(
              NotificationTypeExtension.fromString(notification.type),
              !notification.isRead,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                notification.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                notification.body,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatNotificationTime(notification.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('close'.tr),
          ),
        ],
      ),
    );

    if (!notification.isRead) {
      await _notificationController.markAsRead(notification.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('notifications'.tr),
        actions: [
          Obx(() => _notificationController.unreadCount.value > 0
              ? IconButton(
                  icon: const Icon(Icons.mark_email_read),
                  onPressed: () => _notificationController.markAllAsRead(),
                  tooltip: 'mark_all_as_read'.tr,
                )
              : const SizedBox.shrink()),
        ],
      ),
      body: Obx(() {
        if (_notificationController.isLoading.value &&
            _notificationController.notifications.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (_notificationController.notifications.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: _refreshNotifications,
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _notificationController.notifications.length +
                (_isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _notificationController.notifications.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final notification = _notificationController.notifications[index];
              return _buildNotificationCard(notification);
            },
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'no_notifications'.tr,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'no_notifications_description'.tr,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(AppNotification notification) {
    final notificationType =
        NotificationTypeExtension.fromString(notification.type);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: !notification.isRead ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: !notification.isRead
            ? BorderSide(
                color: Theme.of(context).primaryColor, width: 0.5)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => _showNotificationDetails(notification),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: !notification.isRead
                ? Theme.of(context).primaryColor.withOpacity(0.05)
                : Colors.transparent,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildNotificationIcon(notificationType, !notification.isRead),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: !notification.isRead
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              color: !notification.isRead
                                  ? Colors.black87
                                  : Colors.black54,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: TextStyle(
                        fontSize: 14,
                        color: !notification.isRead
                            ? Colors.black87
                            : Colors.black54,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDateTime(notification.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getNotificationTypeColor(notificationType)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            notificationType.displayName,
                            style: TextStyle(
                              fontSize: 10,
                              color:
                                  _getNotificationTypeColor(notificationType),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(NotificationType type, bool isUnread) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: _getNotificationTypeColor(type)
            .withOpacity(isUnread ? 0.15 : 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        _getNotificationTypeIcon(type),
        color: _getNotificationTypeColor(type),
        size: 20,
      ),
    );
  }

  IconData _getNotificationTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.newTask:
        return Icons.task_alt;
      case NotificationType.taskUpdate:
        return Icons.update;
      case NotificationType.taskAccepted:
        return Icons.check_circle;
      case NotificationType.taskCompleted:
        return Icons.done_all;
      case NotificationType.taskCancelled:
        return Icons.cancel;
      case NotificationType.payment:
        return Icons.payment;
      case NotificationType.systemAnnouncement:
        return Icons.campaign;
      case NotificationType.marketing:
        return Icons.local_offer;
      case NotificationType.general:
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.newTask:
        return Colors.blue;
      case NotificationType.taskUpdate:
        return Colors.orange;
      case NotificationType.taskAccepted:
        return Colors.green;
      case NotificationType.taskCompleted:
        return Colors.teal;
      case NotificationType.taskCancelled:
        return Colors.red;
      case NotificationType.payment:
        return Colors.purple;
      case NotificationType.systemAnnouncement:
        return Colors.indigo;
      case NotificationType.marketing:
        return Colors.pink;
      case NotificationType.general:
      default:
        return Colors.grey;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'now'.tr;
    } else if (difference.inMinutes < 60) {
      return 'minutes_ago'.trParams({'minutes': difference.inMinutes.toString()});
    } else if (difference.inHours < 24) {
      return 'hours_ago'.trParams({'hours': difference.inHours.toString()});
    } else if (difference.inDays < 7) {
      return 'days_ago'.trParams({'days': difference.inDays.toString()});
    } else {
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    }
  }
}
