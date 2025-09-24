import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/settings_service.dart';
import '../../widgets/custom_button.dart';
import '../../l10n/generated/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
      // Fallback or error handling
      return const SizedBox.shrink();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        elevation: 0,
      ),
      body: Consumer<SettingsService>(
        builder: (context, settingsService, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // App Settings Section
              _buildSectionHeader(l10n.appSettings),
              const SizedBox(height: 16),

              // Language Setting
              _buildLanguageCard(settingsService),
              const SizedBox(height: 16),

              // Theme Setting
              _buildThemeCard(settingsService),
              const SizedBox(height: 32),

              // Notification Settings Section
              // _buildSectionHeader(l10n.notifications),
              // const SizedBox(height: 16),

              // _buildNotificationCard(settingsService),
              // const SizedBox(height: 32),

              // Account Settings Section
              // _buildSectionHeader('إعدادات الحساب'),
              // const SizedBox(height: 16),

              // _buildAccountCard(),
              // const SizedBox(height: 32),

              // About Section
              _buildSectionHeader(l10n.about),
              const SizedBox(height: 16),

              _buildAboutCard(),
              const SizedBox(height: 32),

              // Reset Settings
              _buildResetCard(settingsService),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
    );
  }

  Widget _buildLanguageCard(SettingsService settingsService) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
      // Fallback or error handling
      return const SizedBox.shrink();
    }
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.language,
                    color: Colors.blue[600],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.language,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.chooseLanguage,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Language Options
            Column(
              children: [
                _buildLanguageOption(
                  settingsService,
                  'العربية',
                  'ar',
                  '🇸🇦',
                ),
                const SizedBox(height: 8),
                _buildLanguageOption(
                  settingsService,
                  'English',
                  'en',
                  '🇺🇸',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    SettingsService settingsService,
    String title,
    String languageCode,
    String flag,
  ) {
    final isSelected = settingsService.currentLanguage == languageCode;

    return InkWell(
      onTap: () => settingsService.changeLanguage(languageCode),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
          ),
        ),
        child: Row(
          children: [
            Text(
              flag,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? Theme.of(context).primaryColor : null,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeCard(SettingsService settingsService) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
      // Fallback or error handling
      return const SizedBox.shrink();
    }
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    settingsService.isDarkMode
                        ? Icons.dark_mode
                        : Icons.light_mode,
                    color: Colors.purple[600],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.theme,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.chooseTheme,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Theme Options
            Column(
              children: [
                _buildThemeOption(
                  settingsService,
                  l10n.lightMode,
                  false,
                  Icons.light_mode,
                  Colors.orange,
                ),
                const SizedBox(height: 8),
                _buildThemeOption(
                  settingsService,
                  l10n.darkMode,
                  true,
                  Icons.dark_mode,
                  Colors.indigo,
                ),
                const SizedBox(height: 8),
                _buildThemeOption(
                  settingsService,
                  l10n.systemMode,
                  null,
                  Icons.auto_mode,
                  Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    SettingsService settingsService,
    String title,
    bool? isDark,
    IconData icon,
    Color color,
  ) {
    final isSelected = settingsService.themeMode ==
        (isDark == null
            ? ThemeMode.system
            : isDark
                ? ThemeMode.dark
                : ThemeMode.light);

    return InkWell(
      onTap: () => settingsService.changeThemeMode(isDark == null
          ? ThemeMode.system
          : isDark
              ? ThemeMode.dark
              : ThemeMode.light),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey[600],
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? color : null,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: color,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(SettingsService settingsService) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildNotificationTile(
              settingsService,
              'إشعارات المهام',
              'تلقي إشعارات عند وصول مهام جديدة',
              Icons.task_alt,
              Colors.blue,
              settingsService.taskNotificationsEnabled,
              (value) => settingsService.setTaskNotifications(value),
            ),
            const Divider(),
            _buildNotificationTile(
              settingsService,
              'إشعارات المحفظة',
              'تلقي إشعارات عند تحديث المحفظة',
              Icons.account_balance_wallet,
              Colors.green,
              settingsService.walletNotificationsEnabled,
              (value) => settingsService.setWalletNotifications(value),
            ),
            const Divider(),
            _buildNotificationTile(
              settingsService,
              'إشعارات النظام',
              'تلقي إشعارات النظام والتحديثات',
              Icons.notifications,
              Colors.orange,
              settingsService.systemNotificationsEnabled,
              (value) => settingsService.setSystemNotifications(value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTile(
    SettingsService settingsService,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    bool value,
    Function(bool) onChanged,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: color,
      ),
    );
  }

  // Widget _buildAccountCard() {
  //   return Card(
  //     elevation: 2,
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //     child: Column(
  //       children: [
  //         _buildAccountTile(
  //           'تغيير كلمة المرور',
  //           'تحديث كلمة المرور الخاصة بك',
  //           Icons.lock_outline,
  //           Colors.red,
  //           () => Navigator.pushNamed(context, '/change-password'),
  //         ),
  //         const Divider(height: 1),
  //         _buildAccountTile(
  //           'تسجيل الخروج',
  //           'الخروج من الحساب الحالي',
  //           Icons.logout,
  //           Colors.red,
  //           _showLogoutDialog,
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildAccountTile(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
      ),
      trailing: const Icon(Icons.chevron_right),
    );
  }

  Widget _buildAboutCard() {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
      // Fallback or error handling
      return const SizedBox.shrink();
    }
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          _buildAboutTile(
            l10n.version,
            '1.0.0',
            Icons.info_outline,
            Colors.blue,
          ),
          const Divider(height: 1),
          _buildAboutTile(
            l10n.termsOfService,
            l10n.termsOfServiceDesc,
            Icons.description,
            Colors.green,
            () {
              // TODO: Show terms of service
            },
          ),
          const Divider(height: 1),
          _buildAboutTile(
            l10n.privacyPolicy,
            l10n.privacyPolicyDesc,
            Icons.privacy_tip,
            Colors.purple,
            () {
              // TODO: Show privacy policy
            },
          ),
          const Divider(height: 1),
          _buildAboutTile(
            l10n.helpSupport,
            l10n.helpSupportDesc,
            Icons.description,
            Colors.green,
            () {
              // TODO: Navigate to help
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('المساعدة والدعم قريباً')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutTile(
    String title,
    String subtitle,
    IconData icon,
    Color color, [
    VoidCallback? onTap,
  ]) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
      ),
      trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
    );
  }

  Widget _buildResetCard(SettingsService settingsService) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
      // Fallback or error handling
      return const SizedBox.shrink();
    }
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.restore,
                    color: Colors.red[600],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.resetSettings,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.resetSettingsDesc,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: l10n.reset,
              onPressed: () => _showResetDialog(settingsService),
              backgroundColor: Colors.red,
              textColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من أنك تريد تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement logout
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('تسجيل الخروج',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(SettingsService settingsService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).resetSettings),
        content: Text(
          AppLocalizations.of(context).resetConfirmMessage,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              settingsService.resetToDefaults();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text(AppLocalizations.of(context).resetConfirmMessage),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(AppLocalizations.of(context).reset,
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
