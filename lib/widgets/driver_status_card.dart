import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/location_service.dart';
import '../l10n/generated/app_localizations.dart';

class DriverStatusCard extends StatelessWidget {
  const DriverStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer2<AuthService, LocationService>(
      builder: (context, authService, locationService, child) {
        final driver = authService.currentDriver;

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
                      l10n.driverStatus,
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
                        color: locationService.isOnline
                            ? Colors.green
                            : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      locationService.isOnline
                          ? l10n.connected
                          : l10n.disconnected,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: locationService.isOnline
                                ? Colors.green
                                : Colors.grey,
                          ),
                    ),
                    const Spacer(),
                    Switch(
                      value: locationService.isOnline,
                      onChanged: (value) async {
                        if (value) {
                          await locationService.goOnline();
                        } else {
                          await locationService.goOffline();
                        }
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Location Test Button (for testing GPS and location sending)
                if (locationService.isOnline)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _sendLocationManually(context, locationService),
                      icon: const Icon(Icons.gps_fixed, size: 18),
                      label: Text(AppLocalizations.of(context)!.updateLocation),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),

                // Available/Busy Status (Read-only - controlled by system)
                Row(
                  children: [
                    Icon(
                      driver?.free == true ? Icons.check_circle : Icons.work,
                      color:
                          driver?.free == true ? Colors.green : Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      driver?.free == true ? l10n.availableForTasks : l10n.busy,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: driver?.free == true
                                ? Colors.green
                                : Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'يتحكم به النظام',
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
                          l10n.name,
                          driver.name,
                          Icons.person_outline,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildInfoItem(
                          context,
                          l10n.status,
                          driver.status == 'active'
                              ? l10n.active
                              : l10n.inactive,
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
                          l10n.team,
                          driver.team?.name ?? l10n.notSpecified,
                          Icons.group_outlined,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildInfoItem(
                          context,
                          l10n.vehicleType,
                          driver.vehicleSize?.name ?? l10n.notSpecified,
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
      },
    );
  }

  // Send location manually for testing
  Future<void> _sendLocationManually(
    BuildContext context,
    LocationService locationService,
  ) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(AppLocalizations.of(context)!.sendingLocation),
          ],
        ),
      ),
    );

    try {
      final response = await locationService.sendLocationManually();

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show result
      if (context.mounted) {
        if (response.isSuccess && response.data != null) {
          // Success case
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text((response.message?.toString() ??
                  AppLocalizations.of(context)!.locationSent)),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
              action: SnackBarAction(
                label: 'التفاصيل',
                textColor: Colors.white,
                onPressed: () {
                  _showLocationDetails(context, response.data!);
                },
              ),
            ),
          );
        } else {
          // Error case - show simple SnackBar without dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text((response.message?.toString() ??
                  AppLocalizations.of(context)!.locationSendError.toString())),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show error
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${AppLocalizations.of(context)!.locationSendError.toString()}: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Show location details dialog
  void _showLocationDetails(BuildContext context, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تفاصيل الموقع المرسل'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(
                'خط العرض:', '${data['latitude']?.toStringAsFixed(6)}'),
            _buildDetailRow(
                'خط الطول:', '${data['longitude']?.toStringAsFixed(6)}'),
            _buildDetailRow(
                'الدقة:', '${data['accuracy']?.toStringAsFixed(2)} متر'),
            _buildDetailRow('الوقت:', '${data['timestamp']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  // Build detail row for location info
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
