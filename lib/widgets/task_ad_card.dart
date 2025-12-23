import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/task_ad.dart';
import '../models/task_offer.dart';
import '../services/task_ads_service.dart';

class TaskAdCard extends StatelessWidget {
  final TaskAd taskAd;
  final VoidCallback? onTap;

  const TaskAdCard({
    super.key,
    required this.taskAd,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final taskAdsService = TaskAdsService();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(context),

              const SizedBox(height: 12),

              // Description
              if (taskAd.description.isNotEmpty) _buildDescription(context),

              // Addresses
              if (taskAd.task != null) _buildAddresses(context),

              const SizedBox(height: 12),

              // Price range
              _buildPriceRange(context),

              const SizedBox(height: 12),

              // Offers info
              _buildOffersInfo(context),

              // My offer status
              if (taskAd.myOffer != null) _buildMyOfferStatus(context),

              // Action buttons
              const SizedBox(height: 12),
              _buildActionButtons(context, taskAdsService),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'ad_number'.tr + '${taskAd.id}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getStatusColor(),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            _getStatusText(),
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

  Widget _buildDescription(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Text(
        taskAd.description,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[700],
            ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildAddresses(BuildContext context) {
    final task = taskAd.task!;

    return Column(
      children: [
        if (task.pickup != null)
          _buildAddressRow(
            context,
            Icons.location_on,
            'pickup_point'.tr,
            task.pickup!.address,
            Colors.green,
          ),
        if (task.pickup != null && task.delivery != null)
          const SizedBox(height: 8),
        if (task.delivery != null)
          _buildAddressRow(
            context,
            Icons.location_on,
            'delivery_point'.tr,
            task.delivery!.address,
            Colors.red,
          ),
      ],
    );
  }

  Widget _buildAddressRow(
    BuildContext context,
    IconData icon,
    String label,
    String address,
    Color color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
              ),
              Text(
                address,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRange(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.monetization_on, color: Colors.blue, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'price_range'.tr + ': ${taskAd.lowestPrice.toStringAsFixed(0)} - ${taskAd.highestPrice.toStringAsFixed(0)} ' + 'sar'.tr,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[700],
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOffersInfo(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.local_offer, size: 16, color: Colors.orange[700]),
        const SizedBox(width: 8),
        Text(
          'offers_count'.tr + ': ${taskAd.offersCount}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.orange[700],
                fontWeight: FontWeight.w500,
              ),
        ),
        if (taskAd.hasAcceptedOffer) ...[
          const SizedBox(width: 16),
          Icon(Icons.check_circle, size: 16, color: Colors.green[700]),
          const SizedBox(width: 4),
          Text(
            'offer_accepted'.tr,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.green[700],
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ],
    );
  }

  Widget _buildMyOfferStatus(BuildContext context) {
    final offer = taskAd.myOffer!;
    final status = offer.status;

    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (status) {
      case TaskOfferStatus.pending:
        statusColor = Colors.orange;
        statusText = 'offer_pending'.tr;
        statusIcon = Icons.schedule;
        break;
      case TaskOfferStatus.accepted:
        statusColor = Colors.green;
        statusText = 'offer_accepted_status'.tr;
        statusIcon = Icons.check_circle;
        break;
      case TaskOfferStatus.rejected:
        statusColor = Colors.red;
        statusText = 'offer_rejected'.tr;
        statusIcon = Icons.cancel;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                ),
                Text(
                  'offer_price'.tr + ': ${offer.price.toStringAsFixed(2)} ' + 'sar'.tr,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ),
          // Add confirm task button if offer is accepted and task not yet assigned
          if (offer.status == TaskOfferStatus.accepted &&
              taskAd.hasAcceptedOffer &&
              taskAd.status == 'running') ...[
            const SizedBox(width: 12),
            // Add explanatory text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'offer_congratulations'.tr,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'tap_to_accept_task'.tr,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                          fontSize: 11,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () => _showConfirmTaskDialog(context),
                icon: const Icon(Icons.check_circle, size: 18),
                label: Text(
                  'accept_task'.tr,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(
      BuildContext context, TaskAdsService taskAdsService) {
    return Column(
      children: [
        // الصف الأول: زر عرض التفاصيل
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.visibility, size: 18),
            label: Text(
              'view_details'.tr,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),

        // الصف الثاني: أزرار الإجراءات
        if (taskAdsService.canSubmitOffer(taskAd) ||
            taskAdsService.canAcceptTask(taskAd)) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              if (taskAdsService.canSubmitOffer(taskAd)) ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(
                      'submit_offer'.tr,
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
              if (taskAdsService.canAcceptTask(taskAd)) ...[
                if (taskAdsService.canSubmitOffer(taskAd))
                  const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showAcceptTaskDialog(context),
                    icon: const Icon(Icons.check, size: 18),
                    label: Text(
                      'accept_task'.tr,
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }

  void _showAcceptTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('accept_task'.tr),
        content: Text('confirm_accept_task'.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _acceptTask(context);
            },
            child: Text('accept_task'.tr),
          ),
        ],
      ),
    );
  }

  void _showConfirmTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('accept_task'.tr),
        content: Text('confirm_task_dialog_message'.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _confirmTask(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text('accept_task'.tr),
          ),
        ],
      ),
    );
  }

  void _confirmTask(BuildContext context) async {
    if (taskAd.myOffer == null) return;

    final taskAdsService = TaskAdsService();

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final response =
          await taskAdsService.assignTaskByOffer(taskAd.myOffer!.id);

      if (context.mounted) {
        Navigator.pop(context); // Close loading

        if (response.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('task_assigned_successfully'.tr),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 4),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? 'failed_to_accept_task'.tr),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('error_occurred'.tr + ': $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _acceptTask(BuildContext context) async {
    if (taskAd.myOffer == null) return;

    final taskAdsService = TaskAdsService();

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final response = await taskAdsService.acceptTask(taskAd.myOffer!.id);

      if (context.mounted) {
        Navigator.pop(context); // Close loading

        if (response.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('task_accepted_successfully'.tr),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? 'failed_to_accept_task'.tr),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('error_occurred'.tr + ': $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _getStatusColor() {
    switch (taskAd.status.toLowerCase()) {
      case 'running':
        return Colors.green;
      case 'closed':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  String _getStatusText() {
    switch (taskAd.status.toLowerCase()) {
      case 'running':
        return 'status_running'.tr;
      case 'closed':
        return 'status_closed'.tr;
      default:
        return taskAd.status;
    }
  }
}
