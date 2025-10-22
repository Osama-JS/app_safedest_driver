import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/task.dart';
import '../../services/task_service.dart';
import '../../widgets/task_status_stepper.dart';
import '../../widgets/task_history_sheet.dart';
import '../../l10n/generated/app_localizations.dart';

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
  Task? _currentTask;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentTask = widget.task;
    _loadTaskDetails();
  }

  Future<void> _loadTaskDetails() async {
    final taskService = Provider.of<TaskService>(context, listen: false);

    try {
      final response = await taskService.getTaskDetails(widget.task.id);

      if (mounted) {
        setState(() {
          if (response.isSuccess && response.data != null) {
            _currentTask = response.data!;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.taskDetailsError(e.toString()))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_currentTask == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: Text(l10n.error),
        ),
        body: Center(
          child: Text(l10n.taskNotFound),
        ),
      );
    }

    final task = _currentTask!;

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
            actions: [
              IconButton(
                onPressed: () => _showTaskHistory(),
                icon: const Icon(Icons.receipt_long, color: Colors.white),
                tooltip: l10n.taskHistory,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                l10n.taskNumber(task.id.toString()),
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
                      Theme.of(context).primaryColor.withValues(alpha: 0.8),
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
                          color: Colors.white.withValues(alpha: 0.1),
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
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                    ),
                    // Content
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 60),
                          // Status Badge - يتم تحديثه تلقائياً عند تغيير _currentTask
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getStatusIcon(_currentTask!.status),
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  TaskStatusExtension.fromString(
                                          _currentTask!.status)
                                      .displayName,
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
                                l10n.yourEarnings,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_currentTask!.driverEarnings.toStringAsFixed(2)} ر.س',
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

                  // Task Status Stepper - يتم تحديثه تلقائياً عند تغيير _currentTask
                  TaskStatusStepper(task: _currentTask!),

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
  }

  Widget _buildQuickActionsCard() {
    final task = _currentTask!;
    final l10n = AppLocalizations.of(context)!;

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
                  l10n.quickNavigation,
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
                        l10n.pickupPoint,
                      ),
                      icon: const Icon(Icons.location_on, size: 20),
                      label: Text(l10n.pickupPoint),
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
                        l10n.deliveryPoint,
                      ),
                      icon: const Icon(Icons.flag, size: 20),
                      label: Text(l10n.deliveryPoint),
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
    final task = _currentTask!;
    final point = task.pickupPoint!;
    final l10n = AppLocalizations.of(context)!;

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
                        l10n.pickupPoint,
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
            // إخفاء معلومات الاتصال للمهام المتاحة (assign status)
            if (task.status != 'assign') ...[
              if (point.contactName != null) ...[
                _buildContactRow(
                    Icons.person, l10n.contactName, point.contactName!),
                const SizedBox(height: 12),
              ],
              if (point.contactPhone != null) ...[
                _buildContactRow(
                    Icons.phone, l10n.phoneNumber, point.contactPhone!),
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
                  l10n.pickupPoint,
                ),
                icon: const Icon(Icons.navigation, size: 20),
                label: Text(l10n.openInGoogleMaps),
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
    final task = _currentTask!;
    final point = task.deliveryPoint!;
    final l10n = AppLocalizations.of(context)!;

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
                        l10n.deliveryPoint,
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
            // إخفاء معلومات الاتصال للمهام المتاحة (assign status)
            if (task.status != 'assign') ...[
              if (point.contactName != null) ...[
                _buildContactRow(
                    Icons.person, l10n.contactName, point.contactName!),
                const SizedBox(height: 12),
              ],
              if (point.contactPhone != null) ...[
                _buildContactRow(
                    Icons.phone, l10n.phoneNumber, point.contactPhone!),
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
                  l10n.deliveryPoint,
                ),
                icon: const Icon(Icons.navigation, size: 20),
                label: Text(l10n.openInGoogleMaps),
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

  void _showTaskHistory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TaskHistorySheet(task: _currentTask!),
    );
  }

  Widget _buildItemsCard() {
    final task = _currentTask!;
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.items,
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
                            : l10n.unspecifiedItem),
                      ),
                      Text('${l10n.quantity}: ${item.quantity}'),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalDataCard() {
    final task = _currentTask!;
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.additionalData,
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
    return Consumer<TaskService>(
      builder: (context, taskService, child) {
        return _getActionButtonForStatus(_currentTask!.status, taskService);
      },
    );
  }

  Widget _getActionButtonForStatus(String status, TaskService taskService) {
    final l10n = AppLocalizations.of(context)!;

    switch (status) {
      case 'pending':
        // أزرار القبول والرفض تظهر فقط في المهام المتاحة
        // هنا نعرض فقط معلومات الحالة
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
                  l10n.pendingApproval,
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
        return ElevatedButton.icon(
          onPressed: () => _updateTaskStatus(taskService, 'started'),
          icon: const Icon(Icons.play_arrow),
          label: Text(l10n.startTask),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        );
      case 'started':
        return ElevatedButton.icon(
          onPressed: () => _updateTaskStatus(taskService, 'in pickup point'),
          icon: const Icon(Icons.location_on),
          label: Text(l10n.arrivedAtPickupPoint),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        );
      case 'in pickup point':
        return ElevatedButton.icon(
          onPressed: () => _updateTaskStatus(taskService, 'loading'),
          icon: const Icon(Icons.upload),
          label: Text(l10n.startLoading),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        );
      case 'loading':
        return ElevatedButton.icon(
          onPressed: () => _updateTaskStatus(taskService, 'in the way'),
          icon: const Icon(Icons.local_shipping),
          label: Text(l10n.onTheWay),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        );
      case 'in the way':
        return ElevatedButton.icon(
          onPressed: () => _updateTaskStatus(taskService, 'in delivery point'),
          icon: const Icon(Icons.location_on),
          label: Text(l10n.arrivedAtDeliveryPoint),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        );
      case 'in delivery point':
        return ElevatedButton.icon(
          onPressed: () => _updateTaskStatus(taskService, 'unloading'),
          icon: const Icon(Icons.download),
          label: Text(l10n.startUnloading),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        );
      case 'unloading':
        return ElevatedButton.icon(
          onPressed: () => _updateTaskStatus(taskService, 'completed'),
          icon: const Icon(Icons.done),
          label: Text(l10n.completeTask),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            minimumSize: const Size(double.infinity, 48),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _openGoogleMaps(
      double latitude, double longitude, String label) async {
    final l10n = AppLocalizations.of(context)!;
    final url =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.cannotOpenGoogleMaps)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.mapOpenError)),
        );
      }
    }
  }

  Future<bool> _showStatusUpdateConfirmation(String newStatus) async {
    final l10n = AppLocalizations.of(context)!;
    final statusName = TaskStatusExtension.fromString(newStatus).displayName;

    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Icon(
                  Icons.help_outline,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.confirmStatusUpdate,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.confirmStatusUpdateMessage,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    statusName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.cannotUndo,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  l10n.cancel,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  l10n.confirm,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _updateTaskStatus(
      TaskService taskService, String newStatus) async {
    final l10n = AppLocalizations.of(context)!;

    // Show confirmation dialog first
    final confirmed = await _showStatusUpdateConfirmation(newStatus);
    if (!confirmed) return;

    // Check if context is still mounted before showing loading dialog
    if (!mounted) return;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(l10n.updatingTaskStatus),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final response =
          await taskService.updateTaskStatus(_currentTask!.id, newStatus);

      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        if (response.isSuccess) {
          // Update current task status immediately
          setState(() {
            _currentTask = _currentTask!.copyWith(status: newStatus);
          });

          // Show success animation with updated status
          _showStatusUpdateSuccess(newStatus);

          // Refresh task data in background
          await taskService.getTasks();
        } else {
          _showStatusUpdateError(response.errorMessage);
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        _showStatusUpdateError(l10n.unexpectedError(e.toString()));
      }
    }
  }

  void _showStatusUpdateSuccess(String newStatus) {
    final l10n = AppLocalizations.of(context)!;
    final statusName = TaskStatusExtension.fromString(newStatus).displayName;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check,
                color: Colors.green[700],
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.updatedSuccessfully,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.taskStatusUpdatedTo(statusName),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  void _showStatusUpdateError(String errorMessage) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error,
                color: Colors.red[700],
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.updateFailed,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }
}
