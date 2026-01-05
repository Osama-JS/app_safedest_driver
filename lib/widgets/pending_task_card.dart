import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controllers/TaskController.dart';
import '../Controllers/NotificationController.dart';
import '../models/task.dart';
import 'dart:async';

class PendingTaskCard extends StatefulWidget {
  const PendingTaskCard({super.key});

  @override
  State<PendingTaskCard> createState() => _PendingTaskCardState();
}

class _PendingTaskCardState extends State<PendingTaskCard>
    with TickerProviderStateMixin {
  late Worker _worker;
  Timer? _countdownTimer;
  int _remainingSeconds = 180;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  final TaskController _taskController = Get.find<TaskController>();
  final NotificationController _notifController = Get.find<NotificationController>();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    _pulseController.repeat(reverse: true);

    // Reactive timer handling
    _worker = ever(_taskController.pendingTask, (task) {
      if (task != null) {
        _resetAndStartTimer();
      } else {
        _stopTimer();
      }
    });

    if (_taskController.pendingTask.value != null) {
      _resetAndStartTimer();
    }
  }

  @override
  void dispose() {
    _worker.dispose();
    _stopTimer();
    _pulseController.dispose();
    super.dispose();
  }

  void _resetAndStartTimer() {
    _stopTimer();
    _remainingSeconds = 180;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        if (mounted) {
          setState(() {
            _remainingSeconds--;
          });
        }
      } else {
        _stopTimer();
        _handleTimeout();
      }
    });
  }

  void _stopTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  void _handleTimeout() {
    // Only handle if there is still a task
    if (_taskController.pendingTask.value == null) return;

    _taskController.rejectPendingTask();

    // Show internal notification
    _notifController.showSimpleNotification(
      title: 'task_transferred_title'.tr,
      body: 'task_expired_transferred'.tr,
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final pendingTask = _taskController.pendingTask.value;

      if (pendingTask == null) {
        return const SizedBox.shrink();
      }

      return AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.orange[400]!,
                    Colors.orange[600]!,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Card(
                elevation: 0,
                color: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with countdown
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.notification_important,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'newTask'.tr,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'respondWithin'.trParams({'time': _formatTime(_remainingSeconds)}),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _formatTime(_remainingSeconds),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Task details
                      _buildTaskDetails(pendingTask),

                      const SizedBox(height: 16),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _showTaskDetails(pendingTask),
                              icon: const Icon(Icons.visibility),
                              label: Text('view_details'.tr),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.orange[600],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _acceptTask(pendingTask),
                              icon: const Icon(Icons.check),
                              label: Text('accept'.tr),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () => _rejectTask(pendingTask),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.all(12),
                            ),
                            child: const Icon(Icons.close),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildTaskDetails(Task task) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.location_on,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'from'.trParams({'address': task.pickupAddress ?? 'not_specified'.tr}),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.flag,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'to'.trParams({'address': task.deliveryAddress ?? 'not_specified'.tr}),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.attach_money,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'amount'.trParams({'amount': task.totalPrice.toStringAsFixed(2)}),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showTaskDetails(Task task) {
    Get.bottomSheet(
      TaskDetailsBottomSheet(task: task),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void _acceptTask(Task task) {
    _countdownTimer?.cancel();
    _taskController.acceptPendingTask();

    Get.snackbar(
      'successTitle'.tr,
      'task_accepted_successfully'.tr,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _rejectTask(Task task) {
    _countdownTimer?.cancel();
    _taskController.rejectPendingTask();

    Get.snackbar(
      'errorTitle'.tr,
      'task_rejected'.tr,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}

class TaskDetailsBottomSheet extends StatelessWidget {
  final Task task;

  const TaskDetailsBottomSheet({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'taskDetails'.tr,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          const Divider(),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('task_id'.tr, task.id.toString()),
                  _buildDetailRow(
                      'paymentMethod'.tr, task.paymentMethod ?? 'not_specified'.tr),
                  _buildDetailRow('status'.tr, task.status),
                  _buildDetailRow(
                      'pickup_address'.tr, task.pickupAddress ?? 'not_specified'.tr),
                  _buildDetailRow(
                      'delivery_address'.tr, task.deliveryAddress ?? 'not_specified'.tr),
                  _buildDetailRow('total_amount'.tr,
                      '${task.totalPrice.toStringAsFixed(2)} ${'sar'.tr}'),
                  _buildDetailRow(
                      'commission'.tr, '${task.commission.toStringAsFixed(2)} ${'sar'.tr}'),
                  _buildDetailRow('creationDate'.tr, task.createdAt.toString()),
                  if (task.notes != null && task.notes!.isNotEmpty)
                    _buildDetailRow('notes'.tr, task.notes!),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
