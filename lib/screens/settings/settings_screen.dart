import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/settings_service.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';
import '../../l10n/generated/app_localizations.dart';
import '../auth/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
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
              // _buildSectionHeader(l10n.appSettings),
              // const SizedBox(height: 16),
              //
              // Language Setting
              _buildLanguageCard(settingsService),
              const SizedBox(height: 16),
              //
              // // Theme Setting
              // _buildThemeCard(settingsService),
              // const SizedBox(height: 32),

              // About Section
              _buildSectionHeader(l10n.about),
              const SizedBox(height: 16),

              _buildAboutCard(),
              const SizedBox(height: 32),

               _buildAccountCard(),
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
        color: Theme.of(context).textTheme.titleLarge?.color,
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
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                !isSelected ? Colors.transparent : Colors.grey[300]!,
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
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).textTheme.bodyMedium?.color,
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
              ),
              const SizedBox(height: 8),
              _buildThemeOption(
                settingsService,
                l10n.darkMode,
                true,
                Icons.dark_mode,
              ),
              const SizedBox(height: 8),
              _buildThemeOption(
                settingsService,
                l10n.systemMode,
                null,
                Icons.auto_mode,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    SettingsService settingsService,
    String title,
    bool? isDark,
    IconData icon,
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
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.grey[300]!  : Colors.transparent  ,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Theme.of(context).textTheme.bodyMedium?.color  ,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? Theme.of(context).textTheme.bodyMedium?.color : null,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).textTheme.bodyMedium?.color,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

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
            () => _openTermsOfService(),
          ),
          const Divider(height: 1),
          _buildAboutTile(
            l10n.privacyPolicy,
            l10n.privacyPolicyDesc,
            Icons.privacy_tip,
            Colors.purple,
            () => _openPrivacyPolicy(),
          ),
          const Divider(height: 1),
          _buildAboutTile(
            l10n.helpSupport,
            l10n.helpSupportDesc,
            Icons.support_agent,
            Colors.orange,
            () => _showSupportDialog(),
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

  // فتح شروط الخدمة
  Future<void> _openTermsOfService() async {
    const url =
        'https://safedest.com/%d8%b3%d9%8a%d8%a7%d8%b3%d8%a9-%d8%a7%d9%84%d8%ae%d8%b5%d9%88%d8%b5%d9%8a%d8%a9/';
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('لا يمكن فتح الرابط: $url')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في فتح الرابط: $e')),
        );
      }
    }
  }

  // فتح سياسة الخصوصية
  Future<void> _openPrivacyPolicy() async {
    const url =
        'https://safedest.com/%d8%b3%d9%8a%d8%a7%d8%b3%d8%a9-%d8%a7%d9%84%d8%ae%d8%b5%d9%88%d8%b5%d9%8a%d8%a9/';
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('لا يمكن فتح الرابط: $url')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في فتح الرابط: $e')),
        );
      }
    }
  }

  // عرض حوار المساعدة والدعم
  void _showSupportDialog() {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.support_agent,
                color: Colors.orange[600],
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              l10n.supportContact,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // البريد الإلكتروني
            _buildContactItem(
              icon: Icons.email,
              label: l10n.contactEmail,
              value: 'info@safedest.com',
              onTap: () => _launchEmail('info@safedest.com'),
              color: Colors.blue,
            ),
            const SizedBox(height: 16),

            // الموقع الإلكتروني
            _buildContactItem(
              icon: Icons.language,
              label: l10n.contactWebsite,
              value: 'www.safedest.com',
              onTap: () => _launchWebsite('https://www.safedest.com'),
              color: Colors.green,
            ),
            const SizedBox(height: 16),

            // أرقام الهاتف
            Text(
              l10n.contactUs,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),

            _buildContactItem(
              icon: Icons.phone,
              label: '',
              value: '0545366466',
              onTap: () => _launchPhone('0545366466'),
              color: Colors.orange,
            ),
            const SizedBox(height: 8),

            _buildContactItem(
              icon: Icons.phone,
              label: '',
              value: '0556978782',
              onTap: () => _launchPhone('0556978782'),
              color: Colors.orange,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.closeDialog),
          ),
        ],
      ),
    );
  }

  // بناء عنصر التواصل
  Widget _buildContactItem({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (label.isNotEmpty)
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  Text(
                    value,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.open_in_new,
              color: color,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  // فتح البريد الإلكتروني
  Future<void> _launchEmail(String email) async {
    final uri = Uri(scheme: 'mailto', path: email);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('لا يمكن فتح تطبيق البريد الإلكتروني')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في فتح البريد الإلكتروني: $e')),
        );
      }
    }
  }

  // فتح الموقع الإلكتروني
  Future<void> _launchWebsite(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('لا يمكن فتح الموقع الإلكتروني')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في فتح الموقع: $e')),
        );
      }
    }
  }

  // الاتصال بالهاتف
  Future<void> _launchPhone(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('لا يمكن فتح تطبيق الهاتف')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في الاتصال: $e')),
        );
      }
    }
  }

  // بناء بطاقة إعدادات الحساب
  Widget _buildAccountCard() {
    final l10n = AppLocalizations.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          _buildAccountTile(
            l10n.deleteAccount,
            l10n.deleteAccountDescription,
            Icons.delete_forever,
            Colors.red,
            _showDeleteAccountDialog,
          ),
        ],
      ),
    );
  }

  // عرض حوار حذف الحساب
  void _showDeleteAccountDialog() {
    final l10n = AppLocalizations.of(context);
    final passwordController = TextEditingController();
    final confirmationController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.warning, color: Colors.red, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.deleteAccountWarning,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.deleteAccountMessage,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.enterPasswordToDelete,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: l10n.password,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.lock),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.typeDeleteConfirmation,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: confirmationController,
                    decoration: InputDecoration(
                      hintText: 'DELETE_MY_ACCOUNT',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.edit),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed:
                    _isLoading ? null : () => Navigator.of(context).pop(),
                child: Text(l10n.cancel),
              ),
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () => _deleteAccount(
                          context,
                          passwordController.text,
                          confirmationController.text,
                          setDialogState,
                        ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(l10n.confirmDelete),
              ),
            ],
          );
        },
      ),
    );
  }

  // تنفيذ حذف الحساب
  Future<void> _deleteAccount(
      BuildContext dialogContext,
      String password,
      String confirmation,
      StateSetter setDialogState,
      ) async {
    final l10n = AppLocalizations.of(context);

    // التحقق من صحة البيانات
    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يرجى إدخال كلمة المرور')),
      );
      return;
    }

    if (confirmation != 'DELETE_MY_ACCOUNT') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يرجى كتابة "DELETE_MY_ACCOUNT" بالضبط')),
      );
      return;
    }

    setDialogState(() {});
    if (mounted) setState(() => _isLoading = true);

    try {
      final apiService = ApiService();
      final response = await apiService.deleteAccount(
        password: password,
        confirmation: confirmation,
      );

      debugPrint('🔍 Full response structure:');
      debugPrint('  - isSuccess: ${response.isSuccess}');
      debugPrint('  - statusCode: ${response.statusCode}');
      debugPrint('  - message: ${response.message}');
      debugPrint('  - data: ${response.data}');

      final bool isSuccess = response.statusCode == 200;

      if (isSuccess) {
        // ✅ 1. إغلاق الحوار فوراً
        Navigator.of(dialogContext, rootNavigator: true).pop();

        // ✅ 2. إظهار رسالة النجاح
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.accountDeletedSuccessfully),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // ✅ 3. تسجيل الخروج مع تنظيف كامل
        final authService = AuthService();
        await authService.forceLogout();

        // ✅ 4. الانتقال لشاشة تسجيل الدخول بعد تأخير بسيط
        Future.delayed(const Duration(milliseconds: 500), () {
          Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => LoginScreen()),
                (route) => false,
          );
        });

      } else {
        // معالجة الأخطاء
        setDialogState(() {});
        if (mounted) setState(() => _isLoading = false);

        String errorMessage = l10n.failedToDeleteAccount;
        if (response.message?.contains('Invalid password') == true) {
          errorMessage = l10n.invalidPasswordForDelete;
        } else if (response.message?.contains('active tasks') == true) {
          errorMessage = l10n.cannotDeleteAccountWithActiveTasks;
        } else if (response.message != null) {
          errorMessage = response.message!;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setDialogState(() {});
      if (mounted) setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.failedToDeleteAccount}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
