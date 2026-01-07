import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../models/notification.dart';
import '../../Controllers/NotificationController.dart';
import '../../Controllers/AuthController.dart';
import '../../config/app_config.dart';
import 'package:flutter/services.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> with SingleTickerProviderStateMixin {
  final NotificationController _notificationController = Get.find<NotificationController>();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        switch (_tabController.index) {
          case 0:
            _notificationController.setFilter('all');
            break;
          case 1:
            _notificationController.setFilter('unread');
            break;
          case 2:
            _notificationController.setFilter('read');
            break;
        }
      }
    });

    // Initial load
    _loadNotifications();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    if (_notificationController.notifications.isEmpty) {
        try {
            final authController = Get.find<AuthController>();
            if (authController.currentDriver.value != null) {
                await _notificationController.loadNotificationsForUser(authController.currentDriver.value!.id);
            }
        } catch (e) {
            // Ignore if AuthController not found (testing/preview)
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background
      appBar: AppBar(
        title: Text(
          'notifications_and_alerts'.tr,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.black),
        systemOverlayStyle: SystemUiOverlayStyle.dark, // Ensure dark icons on white status bar
        actions: [
          Obx(() => _notificationController.unreadCount.value > 0
              ? IconButton(
                  icon: const Icon(Icons.mark_email_read_outlined, color: Colors.black),
                  onPressed: () => _notificationController.markAllAsRead(),
                  tooltip: 'mark_all_as_read'.tr,
                )
              : const SizedBox.shrink()),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).primaryColor,
          tabs: [
            Tab(text: 'all'.tr),
            Tab(text: 'unread'.tr),
            Tab(text: 'read'.tr),
          ],
        ),
      ),
      body: Column(
        children: [
          // Type Filters
          _buildTypeFilter(),

          // Notifications List
          Expanded(
            child: Obx(() {
              if (_notificationController.isLoading.value &&
                  _notificationController.notifications.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              final notifications = _notificationController.filteredNotifications;

              if (notifications.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                onRefresh: () async {
                     final authController = Get.find<AuthController>();
                     if (authController.currentDriver.value != null) {
                         await _notificationController.loadNotificationsForUser(authController.currentDriver.value!.id);
                     }
                },
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: notifications.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _buildNotificationCard(notifications[index]);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
           Padding(
             padding: const EdgeInsets.symmetric(horizontal: 4),
             child: Obx(() {
                final isSelected = _notificationController.selectedType.value == null;
                return ChoiceChip(
                  label: Text('all'.tr),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) _notificationController.setTypeFilter(null);
                  },
                  selectedColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  labelStyle: TextStyle(
                    color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  backgroundColor: Colors.white,
                  side: isSelected ? BorderSide(color: Theme.of(context).primaryColor) : const BorderSide(color: Colors.grey, width: 0.5),
                );
             }),
           ),
           ...NotificationType.values.map((type) {
             // Optional: Filter out types that shouldn't be shown if needed
             if (type == NotificationType.general) return const SizedBox.shrink();

             return Padding(
               padding: const EdgeInsets.symmetric(horizontal: 4),
               child: Obx(() {
                  final isSelected = _notificationController.selectedType.value == type;
                  return ChoiceChip(
                    label: Text(type.displayName.tr), // Use translated displayName
                    avatar: Icon(type.iconNameIcon, size: 16, color: isSelected ? type.color : Colors.grey),
                    selected: isSelected,
                    onSelected: (selected) {
                      _notificationController.setTypeFilter(selected ? type : null);
                    },
                    selectedColor: type.color.withOpacity(0.1),
                    backgroundColor: Colors.white,
                    side: isSelected ? BorderSide(color: type.color) : const BorderSide(color: Colors.grey, width: 0.5),
                     labelStyle: TextStyle(
                      color: isSelected ? type.color : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  );
               }),
             );
           }).toList(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'no_notifications'.tr,
            style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(AppNotification notification) {
    final type = NotificationTypeExtension.fromString(notification.type);
    final isUnread = !notification.isRead;

    return Dismissible(
      key: Key(notification.id),
      background: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: AlignmentDirectional.centerEnd,
        decoration: BoxDecoration(
           color: Colors.red[100],
           borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.delete_outline, color: Colors.red[700]),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
          // Add delete logic if supported by controller/DB
          // For now just hide or mark read?
          // Since delete isn't fully in DB yet for single item (only clear all), let's just mark read visually
          _notificationController.markAsRead(notification.id);
      },
      child: InkWell(
        onTap: () => _handleNotificationClick(notification),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
            border: isUnread
                ? Border.all(color: type.color.withOpacity(0.5), width: 1.5)
                : Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Bubble
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: type.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(type.iconNameIcon, color: type.color, size: 24),
              ),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isUnread)
                           Container(
                             margin: const EdgeInsets.only(left: 8), // Flip for RTL if needed
                             padding: const EdgeInsets.all(4),
                             decoration: BoxDecoration(
                               color: type.color,
                               shape: BoxShape.circle,
                             ),
                           ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notification.body,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded, size: 14, color: Colors.grey[400]),
                        const SizedBox(width: 4),
                        Text(
                          _formatTime(notification.receivedAt), // Use receivedAt
                          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
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

  // Improved Time Formatting
  String _formatTime(DateTime time) {
    try {
        // Use standard intl formatting first
        // If relative time is needed, implement custom robust logic
        final now = DateTime.now();
        final diff = now.difference(time);

        if (diff.inSeconds < 60) {
          return 'now'.tr;
        } else if (diff.inMinutes < 60) {
          return 'minutes_ago'.trParams({'count': diff.inMinutes.toString()});
        } else if (diff.inHours < 24) {
           return 'hours_ago'.trParams({'count': diff.inHours.toString()});
        } else if (diff.inDays < 7) {
           return 'days_ago'.trParams({'count': diff.inDays.toString()});
        } else {
           return DateFormat('yyyy-MM-dd hh:mm a', 'en').format(time); // Fallback to EN locale format if AR fails
        }
    } catch (e) {
        return DateFormat('yyyy-MM-dd HH:mm').format(time);
    }
  }

  Future<void> _handleNotificationClick(AppNotification notification) async {
    if (!notification.isRead) {
      _notificationController.markAsRead(notification.id);
    }

    final type = NotificationTypeExtension.fromString(notification.type);

    // Show details for info types, or navigate for actionable types
    if (type == NotificationType.general ||
        type == NotificationType.systemAnnouncement ||
        type == NotificationType.marketing) {
      _showNotificationDetails(notification);
    } else {
      _notificationController.handleNotificationTap(notification);
    }
  }

  void _showNotificationDetails(AppNotification notification) {
    final type = NotificationTypeExtension.fromString(notification.type);

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(type.iconNameIcon, color: type.color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                notification.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.body, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  _formatTime(notification.receivedAt),
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('close'.tr, style: TextStyle(color: Theme.of(context).primaryColor)),
          ),
        ],
      ),
    );
  }
}

// Helpers for UI
extension NotificationTypeUI on NotificationType {
  Color get color {
     switch (this) {
       case NotificationType.newTask: return const Color(0xFF2196F3); // Blue
       case NotificationType.taskUpdate: return const Color(0xFFFF9800); // Orange
       case NotificationType.taskAccepted: return const Color(0xFF4CAF50); // Green
       case NotificationType.taskCompleted: return const Color(0xFF009688); // Teal
       case NotificationType.taskCancelled: return const Color(0xFFF44336); // Red
       case NotificationType.payment: return const Color(0xFF9C27B0); // Purple
       case NotificationType.systemAnnouncement: return const Color(0xFF3F51B5); // Indigo
       case NotificationType.marketing: return const Color(0xFFE91E63); // Pink
       default: return Colors.grey;
     }
  }

  IconData get iconNameIcon {
      switch (this) {
       case NotificationType.newTask: return Icons.add_task_rounded;
       case NotificationType.taskUpdate: return Icons.update_rounded;
       case NotificationType.taskAccepted: return Icons.check_circle_outline_rounded;
       case NotificationType.taskCompleted: return Icons.done_all_rounded;
       case NotificationType.taskCancelled: return Icons.cancel_outlined;
       case NotificationType.payment: return Icons.monetization_on_outlined;
       case NotificationType.systemAnnouncement: return Icons.campaign_outlined;
       case NotificationType.marketing: return Icons.local_offer_outlined;
       default: return Icons.notifications_none_rounded;
     }
  }
}
