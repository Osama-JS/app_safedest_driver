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

                // Available/Busy Status
                Row(
                  children: [
                    Icon(
                      locationService.isFree ? Icons.check_circle : Icons.work,
                      color:
                          locationService.isFree ? Colors.green : Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      locationService.isFree
                          ? l10n.availableForTasks
                          : l10n.busy,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: locationService.isFree
                                ? Colors.green
                                : Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const Spacer(),
                    if (locationService.isOnline)
                      TextButton(
                        onPressed: () async {
                          if (locationService.isFree) {
                            await locationService.setBusy();
                          } else {
                            await locationService.setAvailable();
                          }
                        },
                        child: Text(
                          locationService.isFree
                              ? l10n.setBusy
                              : l10n.setAvailable,
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
