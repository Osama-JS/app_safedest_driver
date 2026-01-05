import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../services/auth_service.dart';
import '../../models/driver.dart';
import '../../config/app_config.dart';
import '../../utils/debug_helper.dart';
import '../profile/edit_profile_screen.dart';
import '../profile/additional_data_screen.dart';
import '../../l10n/generated/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    // Refresh profile data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshProfileData();
    });
  }

  Future<void> _refreshProfileData() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.refreshDriverData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحديث البيانات: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfileScreen(),
                ),
              );

              // Refresh profile data if update was successful
              if (result == true && mounted) {
                final authService =
                    Provider.of<AuthService>(context, listen: false);
                await authService.refreshDriverData();
              }
            },
          ),
        ],
      ),
      body: Consumer<AuthService>(
        builder: (context, authService, child) {
          final driver = authService.currentDriver;

          if (driver == null) {
            return Center(
              child: Text(l10n.noDriverData),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshProfileData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Refresh indicator
                  if (_isRefreshing)
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'جاري تحديث البيانات...',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ],
                      ),
                    ),

                  // Profile Header
                  _buildProfileHeader(driver, l10n),

                  const SizedBox(height: 24),

                  // Profile Information
                  _buildProfileInfo(driver, l10n),

                  const SizedBox(height: 24),

                  // Settings Section
                  _buildSettingsSection(l10n),

                  const SizedBox(height: 24),

                  // Logout Button
                  _buildLogoutButton(authService, l10n),

                  const SizedBox(height: 100), // Bottom padding
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(Driver driver, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).colorScheme.primary,
              backgroundImage: driver.image != null && driver.image!.isNotEmpty
                  ? NetworkImage(AppConfig.getStorageUrl(driver.image!))
                  : null,
              child: driver.image == null || driver.image!.isEmpty
                  ? Text(
                      driver.name.isNotEmpty
                          ? driver.name[0].toUpperCase()
                          : 'S',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),

            const SizedBox(height: 16),

            // Driver Name
            Text(
              driver.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 8),

            // Driver Status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: driver.status == 'active'
                    ? Colors.green.withOpacity(0.2)
                    : Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                driver.status == 'active' ? l10n.active : l10n.inactive,
                style: TextStyle(
                  color:
                      driver.status == 'active' ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Online/Offline Status
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  driver.online ? Icons.circle : Icons.circle_outlined,
                  color: driver.online ? Colors.green : Colors.grey,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  driver.online ? l10n.online : l10n.offline,
                  style: TextStyle(
                    color: driver.online ? Colors.green : Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfo(Driver driver, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.accountInfo,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(l10n.email, driver.email, Icons.email),
            // عرض username إذا كان موجود
            if (driver.username != null && driver.username!.isNotEmpty)
              _buildInfoRow(
                  'اسم المستخدم', driver.username!, Icons.account_circle),
            _buildInfoRow(l10n.phone, driver.phone, Icons.phone),
            _buildInfoRow(
                l10n.address, driver.address ?? l10n.notSpecified, Icons.map),
            if (driver.team != null)
              _buildInfoRow(l10n.team, driver.team?.name ?? '', Icons.group),
            if (driver.vehicleSize != null)
              _buildInfoRow(l10n.vehicleSize, driver.vehicleSize?.name ?? '',
                  Icons.local_shipping),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                ),
                Text(
                  value.isNotEmpty ? value : '-',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(AppLocalizations l10n) {
    return Card(
      child: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.info_outline,
            title: l10n.additionalData,
            subtitle: l10n.additionalDataDescription,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdditionalDataScreen(),
                ),
              );
            },
          ),

          // Debug option (only in debug mode)
          // if (AppConfig.isDebug)
          //   _buildSettingsTile(
          //     icon: Icons.bug_report,
          //     title: l10n.systemDiagnostics,
          //     subtitle: l10n.systemDiagnosticsDescription,
          //     onTap: () {
          //       DebugHelper.showDebugDialog(context);
          //     },
          //   ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton(AuthService authService, AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed:
            authService.isLoading ? null : () => _handleLogout(authService),
        icon: authService.isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.logout),
        label: Text(authService.isLoading ? l10n.loggingOut : l10n.logout),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Future<void> _handleLogout(AuthService authService) async {
    final confirmed = await _showLogoutConfirmation();
    if (!confirmed) return;

    final response = await authService.logout();

    if (response.isSuccess) {
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/login',
            (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.errorMessage)),
      );
    }
  }


  Future<bool> _showLogoutConfirmation() async {
    final l10n = AppLocalizations.of(context)!;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.logoutConfirmation),
        content: Text(l10n.logoutConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.logout),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  void _showAboutDialog() {
    final l10n = AppLocalizations.of(context)!;

    showAboutDialog(
      context: context,
      applicationName: AppConfig.appName,
      applicationVersion: AppConfig.appVersion,
      applicationIcon: const Icon(
        Icons.local_shipping,
        size: 48,
        color: Color(AppConfig.primaryColorValue),
      ),
      children: [
        Text(l10n.safeDriveApp),
        const SizedBox(height: 16),
        Text(l10n.appDescription),
      ],
    );
  }
}
