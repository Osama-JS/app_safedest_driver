import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controllers/AuthController.dart';
import '../Controllers/LocationController.dart';

class DriverStatusCard extends StatelessWidget {
  const DriverStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final LocationController locationController = Get.find<LocationController>();

    return Obx(() {
      final driver = authController.currentDriver.value;

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
                      color: locationController.isOnline.value
                          ? Colors.green
                          : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    locationController.isOnline.value
                        ? 'online'.tr
                        : 'offline'.tr,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: locationController.isOnline.value
                              ? Colors.green
                              : Colors.grey,
                        ),
                  ),
                  const Spacer(),
                  Switch(
                    value: locationController.isOnline.value,
                    onChanged: (value) async {
                      if (value) {
                        await locationController.goOnline();
                      } else {
                        await locationController.goOffline();
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Location Test Button
              if (locationController.isOnline.value)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ElevatedButton.icon(
                    onPressed: () => _sendLocationManually(context, locationController),
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

                // Driver Info
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

  Future<void> _sendLocationManually(BuildContext context, LocationController locationController) async {
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
      Get.back(); // Close dialog

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
      Get.back(); // Close dialog
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
            _buildDetailRow('latitude'.tr, '${data['latitude']?.toStringAsFixed(6)}'),
            _buildDetailRow('longitude'.tr, '${data['longitude']?.toStringAsFixed(6)}'),
            _buildDetailRow('accuracy'.tr, '${data['accuracy']?.toStringAsFixed(2)} m'),
            _buildDetailRow('time'.tr, '${data['timestamp']}'),
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
        Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
