import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/notification.dart';
import '../../services/notification_service.dart';
import '../../config/app_config.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
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
    debugPrint('📱 NotificationsScreen: Loading notifications...');
    final notificationService =
        Provider.of<NotificationService>(context, listen: false);
    final response =
        await notificationService.getNotifications(page: 1, perPage: 20);
    debugPrint(
        '📱 NotificationsScreen: Load response - success: ${response.isSuccess}, notifications count: ${notificationService.notifications.length}');
    _currentPage = 1;
    _hasMoreData = true;
  }

  Future<void> _loadMoreNotifications() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    final notificationService =
        Provider.of<NotificationService>(context, listen: false);
    final response = await notificationService.getNotifications(
      page: _currentPage + 1,
      perPage: 20,
    );

    if (response.isSuccess && response.data != null) {
      if (response.data!.notifications.isEmpty) {
        _hasMoreData = false;
      } else {
        _currentPage++;
      }
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
      return '${difference.inDays} ${difference.inDays == 1 ? 'يوم' : 'أيام'} مضت';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'ساعة' : 'ساعات'} مضت';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'دقيقة' : 'دقائق'} مضت';
    } else {
      return 'الآن';
    }
  }

  Future<void> _showNotificationDetails(AppNotification notification) async {
    // Show notification details dialog
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              _buildNotificationIcon(
                NotificationTypeExtension.fromString(notification.type),
                notification.isUnread,
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
                if (notification.isUnread) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(AppConfig.primaryColorValue).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'جديد',
                      style: TextStyle(
                        fontSize: 10,
                        color: const Color(AppConfig.primaryColorValue),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إغلاق'),
            ),
          ],
        );
      },
    );

    // Mark as read if it was unread
    if (!notification.isRead) {
      final notificationService =
          Provider.of<NotificationService>(context, listen: false);
      await notificationService.markAsRead(notification.id);
    }
  }

  Future<void> _markAllAsRead() async {
    final notificationService =
        Provider.of<NotificationService>(context, listen: false);
    final response = await notificationService.markAllAsRead();

    if (response.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تحديد جميع الإشعارات كمقروءة'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message ?? 'فشل في تحديث الإشعارات'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات'),
        backgroundColor: const Color(AppConfig.primaryColorValue),
        foregroundColor: Colors.white,
        actions: [
          Consumer<NotificationService>(
            builder: (context, notificationService, child) {
              if (notificationService.unreadCount > 0) {
                return IconButton(
                  icon: const Icon(Icons.mark_email_read),
                  onPressed: _markAllAsRead,
                  tooltip: 'تحديد الكل كمقروء',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<NotificationService>(
        builder: (context, notificationService, child) {
          if (notificationService.isLoading &&
              notificationService.notifications.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(AppConfig.primaryColorValue),
              ),
            );
          }

          if (notificationService.notifications.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: _refreshNotifications,
            color: const Color(AppConfig.primaryColorValue),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: notificationService.notifications.length +
                  (_isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == notificationService.notifications.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(
                        color: Color(AppConfig.primaryColorValue),
                      ),
                    ),
                  );
                }

                final notification = notificationService.notifications[index];
                return _buildNotificationCard(notification);
              },
            ),
          );
        },
      ),
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
            'لا توجد إشعارات',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ستظهر الإشعارات الجديدة هنا',
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
      elevation: notification.isUnread ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: notification.isUnread
            ? const BorderSide(
                color: Color(AppConfig.primaryColorValue), width: 0.5)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => _showNotificationDetails(notification),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: notification.isUnread
                ? const Color(AppConfig.primaryColorValue).withOpacity(0.08) // لون أغمق للإشعارات غير المقروءة
                : Colors.grey.withOpacity(0.03), // لون أفتح للإشعارات المقروءة
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildNotificationIcon(notificationType, notification.isUnread),
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
                              fontWeight: notification.isUnread
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              color: notification.isUnread
                                  ? Colors.black87
                                  : Colors.black54,
                            ),
                          ),
                        ),
                        if (notification.isUnread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(AppConfig.primaryColorValue),
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
                        color: notification.isUnread
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
        color:
            _getNotificationTypeColor(type).withOpacity(isUnread ? 0.15 : 0.1),
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
      return 'الآن';
    } else if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} يوم';
    } else {
      return DateFormat('dd/MM/yyyy HH:mm', 'ar').format(dateTime);
    }
  }
}
