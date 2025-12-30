import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Controllers/AuthController.dart';
import '../Controllers/LocationController.dart';

class DriverStatusCard extends StatefulWidget {
  const DriverStatusCard({super.key});

  @override
  State<DriverStatusCard> createState() => _DriverStatusCardState();
}

class _DriverStatusCardState extends State<DriverStatusCard> {
  final AuthController authController = Get.find<AuthController>();
  final LocationController locationController = Get.find<LocationController>();

  final RxBool _isChangingStatus = false.obs;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final driver = authController.currentDriver.value;
      final isOnline = locationController.isOnline.value;

      return Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.person,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'driver_status'.tr,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Online/Offline Status
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: isOnline ? Colors.green : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isOnline ? 'online'.tr : 'offline'.tr,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isOnline ? Colors.green : Colors.grey,
                    ),
                  ),
                  const Spacer(),

                  Obx(() {
                    final busy = _isChangingStatus.value;
                    return Row(
                      children: [
                        if (busy)
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        if (busy) const SizedBox(width: 10),
                        Switch(
                          value: isOnline,
                          onChanged: busy ? null : (value) => _onToggle(value),
                        ),
                      ],
                    );
                  }),
                ],
              ),

              const SizedBox(height: 16),

              // Location Test Button
              if (isOnline)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _sendLocationManually(context),
                    icon: const Icon(Icons.gps_fixed, size: 18),
                    label: Text('update_location'.tr),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Available/Busy Status
              Row(
                children: [
                  Icon(
                    driver?.free == true ? Icons.check_circle : Icons.work,
                    color: driver?.free == true ? Colors.green : Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    driver?.free == true ? 'available'.tr : 'busy'.tr,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: driver?.free == true ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'system_controlled'.tr,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),

              if (driver != null) ...[
                const Divider(height: 32),

                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        context,
                        'name'.tr,
                        driver.name,
                        Icons.person_outline,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInfoItem(
                        context,
                        'status'.tr,
                        driver.status == 'active' ? 'active'.tr : 'inactive'.tr,
                        Icons.info_outline,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        context,
                        'team'.tr,
                        driver.team?.name ?? 'not_specified'.tr,
                        Icons.group_outlined,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInfoItem(
                        context,
                        'vehicle_type'.tr,
                        driver.vehicleSize?.name ?? 'not_specified'.tr,
                        Icons.local_shipping_outlined,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  Future<void> _onToggle(bool value) async {
    _isChangingStatus.value = true;

    try {
      if (value) {
        final result = await locationController.tryGoOnline();

        switch (result) {
          case GoOnlineResult.success:
          // الحالة ستصبح Online تلقائياً لأن isOnline سيتغير داخل الكنترولر
            break;

          case GoOnlineResult.disclosureDenied:
            Get.snackbar(
              'info'.tr,
              'disclosure_required'.tr,
              snackPosition: SnackPosition.BOTTOM,
            );
            break;

          case GoOnlineResult.permissionDenied:
            Get.snackbar(
              'info'.tr,
              'location_permission_required'.tr,
              snackPosition: SnackPosition.BOTTOM,
            );
            break;

          case GoOnlineResult.serviceDisabled:
            Get.snackbar(
              'info'.tr,
              'location_service_disabled'.tr,
              snackPosition: SnackPosition.BOTTOM,
            );
            break;

          case GoOnlineResult.serverError:
            Get.snackbar(
              'error'.tr,
              'server_error_try_again'.tr,
              snackPosition: SnackPosition.BOTTOM,
            );
            break;
        }
      } else {
        await locationController.goOffline();
      }
    } catch (e) {
      Get.snackbar('error'.tr, e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      _isChangingStatus.value = false;
    }
  }

  Future<void> _sendLocationManually(BuildContext context) async {
    Get.dialog(
      AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text('sending_location'.tr),
          ],
        ),
      ),
      barrierDismissible: false,
    );

    try {
      final response = await locationController.sendLocationManually();
      Get.back();

      if (response.isSuccess && response.data != null) {
        Get.snackbar(
          'success'.tr,
          response.message ?? 'location_sent'.tr,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          mainButton: TextButton(
            onPressed: () => _showLocationDetails(response.data!),
            child: Text('details'.tr, style: const TextStyle(color: Colors.white)),
          ),
        );
      } else {
        Get.snackbar(
          'error'.tr,
          response.message ?? 'location_send_error'.tr,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.back();
      Get.snackbar('error'.tr, e.toString(), backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void _showLocationDetails(Map<String, dynamic> data) {
    Get.dialog(
      AlertDialog(
        title: Text('location_details'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('latitude'.tr, '${(data['latitude'] as num?)?.toStringAsFixed(6) ?? '-'}'),
            _buildDetailRow('longitude'.tr, '${(data['longitude'] as num?)?.toStringAsFixed(6) ?? '-'}'),
            _buildDetailRow('accuracy'.tr, '${(data['accuracy'] as num?)?.toStringAsFixed(2) ?? '-'} m'),
            _buildDetailRow('time'.tr, '${data['timestamp'] ?? '-'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('close'.tr),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
