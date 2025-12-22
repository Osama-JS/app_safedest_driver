import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/task.dart';
import '../screens/tasks/task_detail_screen.dart';
import '../theme/app_theme.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final Function(Task)? onAccept;
  final Function(Task)? onReject;
  final Function(Task, String)? onStatusUpdate;
  final bool isCompleted;

  const TaskCard({
    super.key,
    required this.task,
    this.onAccept,
    this.onReject,
    this.onStatusUpdate,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = AppTheme.getTaskStatusColor(task.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.greenAccent.withOpacity(0.1),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(context, statusColor),

            const SizedBox(height: 12),

            // Addresses
            _buildAddresses(context),

            const SizedBox(height: 12),

            // Items (if available)
            if (task.items != null && task.items!.isNotEmpty)
              _buildItems(context),

            // Price and Commission
            _buildPriceInfo(context),

            const SizedBox(height: 16),

            // Actions
            if (isCompleted)
              _buildCompletedTaskActions(context)
            else
              _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color statusColor) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'taskNumber'.trParams({'id': task.id.toString()}),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            _getStatusText(context, task.status),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddresses(BuildContext context) {
    return Column(
      children: [
        if (task.pickupAddress != null)
          _buildAddressRow(
            context,
            'pickupPoint'.tr,
            task.pickupAddress!,
            Icons.location_on,
            Colors.blue,
          ),
        if (task.pickupAddress != null && task.deliveryAddress != null)
          const SizedBox(height: 8),
        if (task.deliveryAddress != null)
          _buildAddressRow(
            context,
            'deliveryPoint'.tr,
            task.deliveryAddress!,
            Icons.flag,
            Colors.green,
          ),
      ],
    );
  }

  Widget _buildAddressRow(
    BuildContext context,
    String label,
    String address,
    IconData icon,
    Color color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: color,
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                address,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItems(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'items'.tr,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...task.items!.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '• ${item.description} (${item.quantity})',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildPriceInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.monetization_on,
            color: Colors.green,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${'yourEarnings'.tr}: ${task.driverEarnings.toStringAsFixed(2)} ${'sar'.tr}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          Text(
            _formatDate(context, task.createdAt),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedTaskActions(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _viewTaskDetails(context),
        icon: const Icon(Icons.visibility, size: 18),
        label: Text('view_details'.tr),
        style: OutlinedButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.primary,
          side: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      children: [
        // View Details Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _viewTaskDetails(context),
            icon: const Icon(Icons.visibility, size: 18),
            label: Text('view_details'.tr),
          ),
        ),
        const SizedBox(height: 8),
        // Action Button
        _buildActionButton(context),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context) {
    // أزرار القبول والرفض تظهر للمهام المتاحة (التي لها pending_driver_id ولكن driver_id فارغ)
    bool isAvailableTask =
        (task.pendingDriverId != null && task.driverId == null) ||
            (task.status == 'pending') ||
            (task.status == 'in_progress' &&
                task.driverId == null &&
                task.pendingDriverId != null);

    if (isAvailableTask && onAccept != null && onReject != null) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => onReject!(task),
              icon: const Icon(Icons.close, size: 18),
              label: Text('reject'.tr),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () => onAccept!(task),
              icon: const Icon(Icons.check, size: 18),
              label: Text('accept'.tr),
            ),
          ),
        ],
      );
    }

    // للمهام الأخرى، عرض أزرار تحديث الحالة
    if (task.status == TaskStatus.assign.value) {
    } else if (task.status == TaskStatus.started.value) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onStatusUpdate != null
              ? () => onStatusUpdate!(task, TaskStatus.inPickupPoint.value)
              : null,
          icon: const Icon(Icons.location_on, size: 18),
          label: Text('arrivedAtPickupPoint'.tr),
        ),
      );
    } else if (task.status == TaskStatus.inPickupPoint.value) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onStatusUpdate != null
              ? () => onStatusUpdate!(task, TaskStatus.loading.value)
              : null,
          icon: const Icon(Icons.upload, size: 18),
          label: Text('startLoading'.tr),
        ),
      );
    } else if (task.status == TaskStatus.loading.value) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onStatusUpdate != null
              ? () => onStatusUpdate!(task, TaskStatus.inTheWay.value)
              : null,
          icon: const Icon(Icons.local_shipping, size: 18),
          label: Text('onTheWay'.tr),
        ),
      );
    } else if (task.status == TaskStatus.inTheWay.value) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onStatusUpdate != null
              ? () => onStatusUpdate!(task, TaskStatus.inDeliveryPoint.value)
              : null,
          icon: const Icon(Icons.location_on, size: 18),
          label: Text('arrivedAtDeliveryPoint'.tr),
        ),
      );
    } else if (task.status == TaskStatus.inDeliveryPoint.value) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onStatusUpdate != null
              ? () => onStatusUpdate!(task, TaskStatus.unloading.value)
              : null,
          icon: const Icon(Icons.download, size: 18),
          label: Text('startUnloading'.tr),
        ),
      );
    } else if (task.status == TaskStatus.unloading.value) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onStatusUpdate != null
              ? () => onStatusUpdate!(task, TaskStatus.completed.value)
              : null,
          icon: const Icon(Icons.done, size: 18),
          label: Text('completeTask'.tr),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  void _viewTaskDetails(BuildContext context) {
    Get.to(() => TaskDetailScreen(task: task));
  }

  String _getStatusText(BuildContext context, String status) {
    switch (status.toLowerCase()) {
      case 'assign':
        return 'taskStatusAssign'.tr;
      case 'started':
        return 'taskStatusStarted'.tr;
      case 'in pickup point':
        return 'taskStatusInPickupPoint'.tr;
      case 'loading':
        return 'taskStatusLoading'.tr;
      case 'in the way':
        return 'taskStatusInTheWay'.tr;
      case 'in delivery point':
        return 'taskStatusInDeliveryPoint'.tr;
      case 'unloading':
        return 'taskStatusUnloading'.tr;
      case 'completed':
        return 'taskStatusCompleted'.tr;
      case 'cancelled':
        return 'taskStatusCancelled'.tr;
      default:
        return 'taskStatusAssign'.tr;
    }
  }

  String _formatDate(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return 'days_ago'.trParams({'count': difference.inDays.toString()});
    } else if (difference.inHours > 0) {
      return 'hours_ago'.trParams({'count': difference.inHours.toString()});
    } else if (difference.inMinutes > 0) {
      return 'minutes_ago'.trParams({'count': difference.inMinutes.toString()});
    } else {
      return 'now'.tr;
    }
  }
}
