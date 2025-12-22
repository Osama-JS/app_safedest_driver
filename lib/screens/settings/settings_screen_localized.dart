import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/settings_service.dart';
import '../../widgets/custom_button.dart';
import '../../l10n/generated/app_localizations.dart';

/// مثال على شاشة الإعدادات باستخدام نظام الترجمة الجديد
class SettingsScreenLocalized extends StatefulWidget {
  const SettingsScreenLocalized({super.key});

  @override
  State<SettingsScreenLocalized> createState() => _SettingsScreenLocalizedState();
}

class _SettingsScreenLocalizedState extends State<SettingsScreenLocalized> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings), // استخدام الترجمة بدلاً من النص المباشر
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
              _buildLanguageCard(settingsService, l10n),
              const SizedBox(height: 16),

              // Theme Setting
              _buildThemeCard(settingsService, l10n),
              const SizedBox(height: 32),

              // Notification Settings Section
              _buildSectionHeader(l10n.notifications),
              const SizedBox(height: 16),

              _buildNotificationCard(settingsService, l10n),
              const SizedBox(height: 32),

              // About Section
              _buildSectionHeader(l10n.about),
              const SizedBox(height: 16),

              _buildAboutCard(l10n),
              const SizedBox(height: 32),

              // Reset Settings
              _buildResetCard(settingsService, l10n),
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

  Widget _buildLanguageCard(SettingsService settingsService, AppLocalizations l10n) {
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
                    color: Colors.blue.withOpacity(0.1),
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
                        l10n.language, // استخدام الترجمة
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.chooseLanguage, // استخدام الترجمة
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
                  l10n.arabic, // استخدام الترجمة
                  'ar',
                  '🇸🇦',
                ),
                const SizedBox(height: 8),
                _buildLanguageOption(
                  settingsService,
                  l10n.english, // استخدام الترجمة
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
              ? Theme.of(context).primaryColor.withOpacity(0.1)
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

  Widget _buildThemeCard(SettingsService settingsService, AppLocalizations l10n) {
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
                    color: Colors.purple.withOpacity(0.1),
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
                        l10n.theme, // استخدام الترجمة
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.chooseTheme, // استخدام الترجمة
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
                  l10n.lightMode, // استخدام الترجمة
                  false,
                  Icons.light_mode,
                  Colors.orange,
                ),
                const SizedBox(height: 8),
                _buildThemeOption(
                  settingsService,
                  l10n.darkMode, // استخدام الترجمة
                  true,
                  Icons.dark_mode,
                  Colors.indigo,
                ),
                const SizedBox(height: 8),
                _buildThemeOption(
                  settingsService,
                  l10n.systemMode, // استخدام الترجمة
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
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
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

  Widget _buildNotificationCard(SettingsService settingsService, AppLocalizations l10n) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildNotificationTile(
              settingsService,
              l10n.taskNotifications, // استخدام الترجمة
              l10n.taskNotificationsDesc, // استخدام الترجمة
              Icons.task_alt,
              Colors.blue,
              settingsService.taskNotificationsEnabled,
              (value) => settingsService.setTaskNotifications(value),
            ),
            const Divider(),
            _buildNotificationTile(
              settingsService,
              l10n.walletNotifications, // استخدام الترجمة
              l10n.walletNotificationsDesc, // استخدام الترجمة
              Icons.account_balance_wallet,
              Colors.green,
              settingsService.walletNotificationsEnabled,
              (value) => settingsService.setWalletNotifications(value),
            ),
            const Divider(),
            _buildNotificationTile(
              settingsService,
              l10n.systemNotifications, // استخدام الترجمة
              l10n.systemNotificationsDesc, // استخدام الترجمة
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
          color: color.withOpacity(0.1),
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

  Widget _buildAboutCard(AppLocalizations l10n) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          _buildAboutTile(
            l10n.version, // استخدام الترجمة
            '1.0.0',
            Icons.info_outline,
            Colors.blue,
          ),
          const Divider(height: 1),
          _buildAboutTile(
            l10n.termsOfService, // استخدام الترجمة
            l10n.termsOfServiceDesc, // استخدام الترجمة
            Icons.description,
            Colors.green,
            () {
              // TODO: Show terms of service
            },
          ),
          const Divider(height: 1),
          _buildAboutTile(
            l10n.privacyPolicy, // استخدام الترجمة
            l10n.privacyPolicyDesc, // استخدام الترجمة
            Icons.privacy_tip,
            Colors.purple,
            () {
              // TODO: Show privacy policy
            },
          ),
          const Divider(height: 1),
          _buildAboutTile(
            l10n.helpSupport, // استخدام الترجمة
            l10n.helpSupportDesc, // استخدام الترجمة
            Icons.help,
            Colors.green,
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${l10n.helpSupport} قريباً')),
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
          color: color.withOpacity(0.1),
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

  Widget _buildResetCard(SettingsService settingsService, AppLocalizations l10n) {
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
                    color: Colors.red.withOpacity(0.1),
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
                        l10n.resetSettings, // استخدام الترجمة
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.resetSettingsDesc, // استخدام الترجمة
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
              text: l10n.reset, // استخدام الترجمة
              onPressed: () => _showResetDialog(settingsService, l10n),
              backgroundColor: Colors.red,
              textColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  void _showResetDialog(SettingsService settingsService, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.resetConfirmTitle), // استخدام الترجمة
        content: Text(l10n.resetConfirmMessage), // استخدام الترجمة
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel), // استخدام الترجمة
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              settingsService.resetToDefaults();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.resetSuccess), // استخدام الترجمة
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.reset, style: const TextStyle(color: Colors.white)), // استخدام الترجمة
          ),
        ],
      ),
    );
  }
}
