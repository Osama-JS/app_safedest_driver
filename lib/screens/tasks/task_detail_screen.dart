import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/task.dart';
import '../../Controllers/TaskController.dart';
import '../../widgets/task_status_stepper.dart';
import '../../widgets/task_history_sheet.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task task;

  const TaskDetailScreen({
    super.key,
    required this.task,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final TaskController _taskController = Get.find<TaskController>();
  final Rxn<Task> _currentTask = Rxn<Task>();
  final RxBool _isLoading = true.obs;

  @override
  void initState() {
    super.initState();
    _currentTask.value = widget.task;
    _loadTaskDetails();
  }

  Future<void> _loadTaskDetails() async {
    _isLoading.value = true;
    try {
      final response = await _taskController.getTaskDetails(widget.task.id);
      if (response.isSuccess && response.data != null) {
        _currentTask.value = response.data;
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'taskDetailsError'.trParams({'error': e.toString()}),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_isLoading.value && _currentTask.value == null) {
        return Scaffold(
          appBar: AppBar(title: Text('task_details'.tr)),
          body: const Center(child: CircularProgressIndicator()),
        );
      }

      if (_currentTask.value == null) {
        return Scaffold(
          appBar: AppBar(title: Text('error'.tr)),
          body: Center(child: Text('taskNotFound'.tr)),
        );
      }

      final task = _currentTask.value!;

      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: CustomScrollView(
          slivers: [
            // Modern App Bar
            SliverAppBar(
              expandedHeight: 250,
              floating: false,
              pinned: true,
              backgroundColor: Theme.of(context).primaryColor,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Get.back(),
              ),
              actions: [
                IconButton(
                  onPressed: () => _showTaskHistory(),
                  icon: const Icon(Icons.receipt_long, color: Colors.white),
                  tooltip: 'taskHistory'.tr,
                ),
                IconButton(
                  onPressed: _loadTaskDetails,
                  icon: const Icon(Icons.refresh, color: Colors.white),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'taskNumber'.trParams({'id': task.id.toString()}),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.8),
                        Colors.blue[600]!,
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Background Pattern
                      Positioned(
                        top: -50,
                        right: -50,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -30,
                        left: -30,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.05),
                          ),
                        ),
                      ),
                      // Content
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 60),
                            // Status Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getStatusIcon(task.status),
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _getStatusDisplayName(task.status),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Earnings
                            Column(
                              children: [
                                Text(
                                  'yourEarnings'.tr,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${task.driverEarnings.toStringAsFixed(2)} ${'sar'.tr}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
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
            ),

            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Quick Actions Card
                    _buildQuickActionsCard(),

                    const SizedBox(height: 16),

                    // Task Status Stepper
                    TaskStatusStepper(task: task),

                    const SizedBox(height: 16),

                    // Action Buttons
                    _buildActionButtons(),
                    const SizedBox(height: 16),

                    // Pickup Point Card
                    if (task.pickupPoint != null) _buildPickupPointCard(),

                    const SizedBox(height: 16),

                    // Delivery Point Card
                    if (task.deliveryPoint != null) _buildDeliveryPointCard(),

                    const SizedBox(height: 16),

                    // Items Card
                    if (task.items != null && task.items!.isNotEmpty)
                      _buildItemsCard(),

                    const SizedBox(height: 16),

                    // Additional Data Card
                    if (task.additionalData != null &&
                        task.additionalData!.isNotEmpty)
                      _buildAdditionalDataCard(),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildQuickActionsCard() {
    final task = _currentTask.value!;

    if (task.pickupPoint == null && task.deliveryPoint == null) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.navigation,
                    color: Colors.blue[700],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'quickNavigation'.tr,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (task.pickupPoint != null)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _openGoogleMaps(
                        task.pickupPoint!.latitude,
                        task.pickupPoint!.longitude,
                        'pickupPoint'.tr,
                      ),
                      icon: const Icon(Icons.location_on, size: 20),
                      label: Text('pickupPoint'.tr),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                if (task.pickupPoint != null && task.deliveryPoint != null)
                  const SizedBox(width: 12),
                if (task.deliveryPoint != null)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _openGoogleMaps(
                        task.deliveryPoint!.latitude,
                        task.deliveryPoint!.longitude,
                        'deliveryPoint'.tr,
                      ),
                      icon: const Icon(Icons.flag, size: 20),
                      label: Text('deliveryPoint'.tr),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickupPointCard() {
    final task = _currentTask.value!;
    final point = task.pickupPoint!;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.location_on,
                    color: Colors.green[700],
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'pickupPoint'.tr,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        point.address,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),
            if (task.status != 'assign') ...[
              if (point.contactName != null) ...[
                _buildContactRow(
                    Icons.person, 'contactName'.tr, point.contactName!),
                const SizedBox(height: 12),
              ],
              if (point.contactPhone != null) ...[
                _buildContactRow(
                    Icons.phone, 'phoneNumber'.tr, point.contactPhone!),
                const SizedBox(height: 12),
              ],
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openGoogleMaps(
                  point.latitude,
                  point.longitude,
                  'pickupPoint'.tr,
                ),
                icon: const Icon(Icons.navigation, size: 20),
                label: Text('openInGoogleMaps'.tr),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryPointCard() {
    final task = _currentTask.value!;
    final point = task.deliveryPoint!;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.flag,
                    color: Colors.red[700],
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'deliveryPoint'.tr,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.red[700],
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        point.address,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),
            if (task.status != 'assign') ...[
              if (point.contactName != null) ...[
                _buildContactRow(
                    Icons.person, 'contactName'.tr, point.contactName!),
                const SizedBox(height: 12),
              ],
              if (point.contactPhone != null) ...[
                _buildContactRow(
                    Icons.phone, 'phoneNumber'.tr, point.contactPhone!),
                const SizedBox(height: 12),
              ],
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openGoogleMaps(
                  point.latitude,
                  point.longitude,
                  'deliveryPoint'.tr,
                ),
                icon: const Icon(Icons.navigation, size: 20),
                label: Text('openInGoogleMaps'.tr),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'assign':
        return Icons.assignment;
      case 'started':
        return Icons.play_arrow;
      case 'in pickup point':
        return Icons.location_on;
      case 'loading':
        return Icons.upload;
      case 'in the way':
        return Icons.local_shipping;
      case 'in delivery point':
        return Icons.flag;
      case 'unloading':
        return Icons.download;
      case 'completed':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.pending;
    }
  }

  String _getStatusDisplayName(String status) {
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
        return status;
    }
  }

  void _showTaskHistory() {
    Get.bottomSheet(
      TaskHistorySheet(task: _currentTask.value!),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildItemsCard() {
    final task = _currentTask.value!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'items'.tr,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...task.items!.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(item.description.isNotEmpty
                            ? item.description
                            : 'unspecifiedItem'.tr),
                      ),
                      Text('${'quantity'.tr}: ${item.quantity}'),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalDataCard() {
    final task = _currentTask.value!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'additionalData'.tr,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...task.additionalData!.entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          entry.key,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 3,
                        child: Text(
                          entry.value?.toString() ?? '',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    final task = _currentTask.value!;
    return _getActionButtonForStatus(task.status);
  }

  Widget _getActionButtonForStatus(String status) {
    switch (status) {
      case 'pending':
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.pending, color: Colors.orange[700]),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'pendingApproval'.tr,
                  style: TextStyle(
                    color: Colors.orange[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      case 'assign':
        return _buildStatusButton('started', Icons.play_arrow, 'startTask'.tr);
      case 'started':
        return _buildStatusButton(
            'in pickup point', Icons.location_on, 'arrivedAtPickupPoint'.tr);
      case 'in pickup point':
        return _buildStatusButton('loading', Icons.upload, 'startLoading'.tr);
      case 'loading':
        return _buildStatusButton(
            'in the way', Icons.local_shipping, 'onTheWay'.tr);
      case 'in the way':
        return _buildStatusButton(
            'in delivery point', Icons.location_on, 'arrivedAtDeliveryPoint'.tr);
      case 'in delivery point':
        return _buildStatusButton('unloading', Icons.download, 'startUnloading'.tr);
      case 'unloading':
        return _buildStatusButton('completed', Icons.done, 'completeTask'.tr,
            color: Colors.green);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStatusButton(String status, IconData icon, String label,
      {Color? color}) {
    return ElevatedButton.icon(
      onPressed: () => _updateTaskStatus(status),
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: color != null ? Colors.white : null,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _updateTaskStatus(String newStatus) async {
    // Show confirmation
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text('confirmStatusUpdate'.tr),
        content: Text('confirmStatusUpdateMessage'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: Text('confirm'.tr),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      final response = await _taskController.updateStatus(_currentTask.value!.id, newStatus);
      Get.back(); // Close loading

      if (response.isSuccess && response.data != null) {
        _currentTask.value = response.data;
        Get.snackbar(
          'success'.tr,
          'statusUpdatedSuccessfully'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'error'.tr,
          response.errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.back(); // Close loading
      Get.snackbar(
        'error'.tr,
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _openGoogleMaps(
      double latitude, double longitude, String label) async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        'error'.tr,
        'couldNotOpenMaps'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
