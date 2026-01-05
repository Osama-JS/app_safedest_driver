import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/task.dart';
import '../../Controllers/TaskController.dart';
import '../../widgets/task_status_stepper.dart';
import '../../widgets/task_history_sheet.dart';
import '../../config/app_config.dart';
import '../../services/mapbox_service.dart';
import '../../Controllers/LocationController.dart';

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
  final RxBool _isLoading = false.obs;
  final LocationController _locationController = Get.find<LocationController>();

  final Rxn<double> _distancePickupToDelivery = Rxn<double>();
  final Rxn<double> _distanceDriverToPickup = Rxn<double>();
  final Rxn<double> _distanceDriverToDelivery = Rxn<double>();

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
        _calculateDistances();
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

                    if (task.conditions != null && task.conditions!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildConditionsCard(),
                    ],

                    const SizedBox(height: 16),
                    _buildDistancesCard(),

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.info_outline,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'additionalData'.tr,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ...task.additionalData!.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildDataField(entry.key, entry.value),
          );
        }),
      ],
    );
  }

  Widget _buildDataField(String key, dynamic value) {
    if (value == null) return const SizedBox.shrink();

    // Handle different data types
    if (value is Map<String, dynamic>) {
      return _buildComplexField(key, value);
    } else {
      return _buildSimpleField(key, value.toString());
    }
  }

  Widget _buildSimpleField(String key, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getFieldLabel(key),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? Theme.of(context).colorScheme.surface.withOpacity(0.5)
                    : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                ),
              ),
              child: Text(
                value.isNotEmpty ? value : 'not_specified'.tr,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: value.isNotEmpty
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.5),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComplexField(String key, Map<String, dynamic> fieldData) {
    final label = fieldData['label'] ?? _getFieldLabel(key);
    final value = fieldData['value'];
    final type = fieldData['type'] ?? 'text';
    final expiration = fieldData['expiration'];
    final text = fieldData['text'];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Field label with type indicator
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColor,
                        ),
                  ),
                ),
                _buildTypeIndicator(type),
              ],
            ),
            const SizedBox(height: 12),

            // Handle different field types
            if (type == 'file' || type == 'image') ...[
              _buildFileField(value, type, label),
            ] else if (type == 'file_expiration_date') ...[
              _buildFileWithExpirationField(value, expiration, label),
            ] else if (type == 'file_with_text') ...[
              _buildFileWithTextField(value, text, label),
            ] else if (type == 'date') ...[
              _buildDateField(value),
            ] else if (type == 'number') ...[
              _buildNumberField(value),
            ] else if (type == 'email') ...[
              _buildEmailField(value),
            ] else if (type == 'phone') ...[
              _buildPhoneField(value),
            ] else if (type == 'url') ...[
              _buildUrlField(value),
            ] else ...[
              _buildTextValue(value),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTypeIndicator(String type) {
    IconData icon;
    Color color;
    String tooltip;

    switch (type) {
      case 'file':
        icon = Icons.attach_file;
        color = Colors.blue;
        tooltip = 'file_type_file'.tr;
        break;
      case 'image':
        icon = Icons.image;
        color = Colors.green;
        tooltip = 'file_type_image'.tr;
        break;
      case 'date':
        icon = Icons.calendar_today;
        color = Colors.orange;
        tooltip = 'file_type_date'.tr;
        break;
      case 'number':
        icon = Icons.numbers;
        color = Colors.purple;
        tooltip = 'file_type_number'.tr;
        break;
      case 'email':
        icon = Icons.email;
        color = Colors.red;
        tooltip = 'email'.tr;
        break;
      case 'phone':
        icon = Icons.phone;
        color = Colors.teal;
        tooltip = 'phone'.tr;
        break;
      case 'url':
        icon = Icons.link;
        color = Colors.indigo;
        tooltip = 'file_type_url'.tr;
        break;
      case 'file_expiration_date':
        icon = Icons.schedule;
        color = Colors.amber;
        tooltip = 'file_type_file_expiration'.tr;
        break;
      case 'file_with_text':
        icon = Icons.description;
        color = Colors.cyan;
        tooltip = 'file_type_file_text'.tr;
        break;
      default:
        icon = Icons.text_fields;
        color = Colors.grey;
        tooltip = 'file_type_text'.tr;
    }

    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(
          icon,
          size: 16,
          color: color,
        ),
      ),
    );
  }

  bool _isImage(String path) {
    if (path.isEmpty) return false;
    final extension = path.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'webp', 'heic'].contains(extension);
  }

  void _showImageDialog(String imageUrl, String label) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                ),
              ],
            ),
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
                maxWidth: MediaQuery.of(context).size.width * 0.9,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(20),
                    child: const Icon(Icons.broken_image, size: 50, color: Colors.red),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                label,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFileField(dynamic value, String type, String label) {
    if (value == null || value.toString().isEmpty) {
      return _buildEmptyValue();
    }

    final imageUrl = AppConfig.getStorageUrl(value.toString());
    final isImageFile = type == 'image' || _isImage(imageUrl);
    final primaryColor = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isImageFile)
          GestureDetector(
            onTap: () => _showImageDialog(imageUrl, label),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primaryColor.withOpacity(0.3)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.broken_image, color: Colors.red),
                        const SizedBox(height: 8),
                        Text('errorLoadingImage'.tr, style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

        // Only show file details if NOT an image
        if (!isImageFile)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? primaryColor.withOpacity(0.1)
                  : primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: primaryColor.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.attach_file,
                  color: primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'attached_file'.tr,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value.toString().split('/').last,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    final url = Uri.parse(imageUrl);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    } else {
                      Get.snackbar('error'.tr, 'errorOpeningAttachment'.trParams({'error': ''}));
                    }
                  },
                  icon: Icon(
                    Icons.open_in_new,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildFileWithExpirationField(dynamic value, dynamic expiration, String label) {
    return Column(
      children: [
        if (value != null) _buildFileField(value, 'file', label),
        if (value != null && expiration != null) const SizedBox(height: 12),
        if (expiration != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .errorContainer
                  .withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color:
                    Theme.of(context).colorScheme.error.withOpacity(0.5),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: Theme.of(context).colorScheme.error,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'expiration_date_label'.trParams({'date': expiration.toString()}),
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFileWithTextField(dynamic value, dynamic text, String label) {
    return Column(
      children: [
        if (value != null) _buildFileField(value, 'file', label),
        if (value != null && text != null) const SizedBox(height: 12),
        if (text != null) _buildTextValue(text),
      ],
    );
  }

  Widget _buildDateField(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return _buildEmptyValue();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final successColor = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? successColor.withOpacity(0.1)
            : successColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: successColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today,
            color: successColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            value.toString(),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextValue(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return _buildEmptyValue();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? Theme.of(context).colorScheme.surface.withOpacity(0.5)
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Text(
        value.toString(),
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
      ),
    );
  }

  Widget _buildNumberField(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return _buildEmptyValue();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple[200]!),
      ),
      child: Row(
        children: [
          Icon(
            Icons.numbers,
            color: Colors.purple[600],
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            value.toString(),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.purple[800],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailField(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return _buildEmptyValue();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(
            Icons.email,
            color: Colors.red[600],
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value.toString(),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.red[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneField(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return _buildEmptyValue();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.teal[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.teal[200]!),
      ),
      child: Row(
        children: [
          Icon(
            Icons.phone,
            color: Colors.teal[600],
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value.toString(),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.teal[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrlField(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return _buildEmptyValue();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.indigo[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.indigo[200]!),
      ),
      child: Row(
        children: [
          Icon(
            Icons.link,
            color: Colors.indigo[600],
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value.toString(),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.indigo[800],
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          IconButton(
            onPressed: () async {
              final url = Uri.parse(value.toString());
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
            icon: Icon(
              Icons.open_in_new,
              color: Colors.indigo[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyValue() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? Theme.of(context).colorScheme.surface.withOpacity(0.3)
            : Theme.of(context).colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Text(
        'not_specified'.tr,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withOpacity(0.5),
            ),
      ),
    );
  }

  String _getFieldLabel(String key) {
    return key;
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

  Future<void> _calculateDistances() async {
    final task = _currentTask.value;
    if (task == null) return;

    // 1. Pickup to Delivery
    if (task.pickupPoint != null && task.deliveryPoint != null) {
      final distance = await MapboxService.getDrivingDistance(
        task.pickupPoint!.latitude,
        task.pickupPoint!.longitude,
        task.deliveryPoint!.latitude,
        task.deliveryPoint!.longitude,
      );
      _distancePickupToDelivery.value = distance;
    }

    // 2. Driver to Pickup
    final currentPos = _locationController.currentPosition.value;
    if (currentPos != null && task.pickupPoint != null) {
      final distance = await MapboxService.getDrivingDistance(
        currentPos.latitude,
        currentPos.longitude,
        task.pickupPoint!.latitude,
        task.pickupPoint!.longitude,
      );
      _distanceDriverToPickup.value = distance;
    }

    // 3. Driver to Delivery
    if (currentPos != null && task.deliveryPoint != null) {
      final distance = await MapboxService.getDrivingDistance(
        currentPos.latitude,
        currentPos.longitude,
        task.deliveryPoint!.latitude,
        task.deliveryPoint!.longitude,
      );
      _distanceDriverToDelivery.value = distance;
    }
  }

  Widget _buildConditionsCard() {
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
                Icon(Icons.gavel, color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                Text(
                  'conditions'.tr,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _currentTask.value?.conditions ?? '',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDistancesCard() {
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
                Icon(Icons.straighten, color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                Text(
                  'distances'.tr,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDistanceRow(
              'distancePickupToDelivery'.tr,
              _distancePickupToDelivery.value,
            ),
            const Divider(),
            _buildDistanceRow(
              'distanceDriverToPickup'.tr,
              _distanceDriverToPickup.value,
            ),
            const Divider(),
            _buildDistanceRow(
              'distanceDriverToDelivery'.tr,
              _distanceDriverToDelivery.value,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDistanceRow(String label, double? distance) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          if (distance != null)
            Text(
              '${distance.toStringAsFixed(2)} ${'km'.tr}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            )
          else
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    );
  }
}
