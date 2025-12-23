import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/settings_service.dart';
import '../../widgets/custom_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('settings'.tr),
        elevation: 0,
      ),
      body: Consumer<SettingsService>(
        builder: (context, settingsService, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Language Setting
              _buildLanguageCard(settingsService),
              const SizedBox(height: 16),

              // About Section
              _buildSectionHeader('about'.tr),
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
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
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
        title: Text(
          'language'.tr,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        subtitle: Text(
          'chooseLanguage'.tr,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        trailing: GestureDetector(
          onTap: () => _showLanguageBottomSheet(context, settingsService),
          child: CircleAvatar(
            radius: 15,
            backgroundImage: AssetImage(
              'assets/flags/${settingsService.currentLanguage}.png',
            ),
          ),
        ),
      ),
    );
  }

  void _showLanguageBottomSheet(BuildContext context, SettingsService settingsService) {
    showModalBottomSheet(
      backgroundColor: Theme.of(context).cardColor,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageListTile(context, "ar", "AE", settingsService),
              const SizedBox(height: 10),
              _buildLanguageListTile(context, "en", "US", settingsService),
              const SizedBox(height: 10),
              _buildLanguageListTile(context, "ur", "PK", settingsService),
              const SizedBox(height: 10),
              _buildLanguageListTile(context, "zh", "CN", settingsService),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageListTile(BuildContext context, String languageCode, String countryCode, SettingsService settingsService) {
    final isSelected = settingsService.currentLanguage == languageCode;
    return ListTile(
      leading: ClipOval(
        child: Image.asset(
          'assets/flags/$languageCode.png',
          width: 32,
          height: 32,
          fit: BoxFit.cover,
        ),
      ),
      title: Text(
        languageCode == "ar" ? "العربية" :
        languageCode == "en" ? "English" :
        languageCode == "ur" ? "اردو" : "中文",
      ),
      trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
      onTap: () {
        settingsService.changeLanguage(languageCode);

        // Ensure GetX locale is also updated
        Locale locale;
        switch (languageCode) {
          case 'ar': locale = const Locale('ar', 'SA'); break;
          case 'en': locale = const Locale('en', 'US'); break;
          case 'ur': locale = const Locale('ur', 'PK'); break;
          case 'zh': locale = const Locale('zh', 'CN'); break;
          default: locale = const Locale('en', 'US');
        }
        Get.updateLocale(locale);

        Navigator.pop(context);
      },
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
      trailing: const Icon(Icons.chevron_right),
    );
  }

  Widget _buildAboutCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          _buildAboutTile(
            'version'.tr,
            '1.0.0',
            Icons.info_outline,
            Colors.blue,
          ),
          const Divider(height: 1),
          _buildAboutTile(
            'termsOfService'.tr,
            'termsOfServiceDesc'.tr,
            Icons.description,
            Colors.green,
            () => _openTermsOfService(),
          ),
          const Divider(height: 1),
          _buildAboutTile(
            'privacyPolicy'.tr,
            'privacyPolicyDesc'.tr,
            Icons.privacy_tip,
            Colors.purple,
            () => _openPrivacyPolicy(),
          ),
          const Divider(height: 1),
          _buildAboutTile(
            'helpSupport'.tr,
            'helpSupportDesc'.tr,
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

  Widget _buildResetCard(SettingsService settingsService) {
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
                        'resetSettings'.tr,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'resetSettingsDesc'.tr,
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
              text: 'reset'.tr,
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
        title: Text('resetSettings'.tr),
        content: Text('resetConfirmMessage'.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              settingsService.resetToDefaults();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('resetConfirmMessage'.tr),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('reset'.tr, style: TextStyle(color: Colors.white)),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
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
              'supportContact'.tr,
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
              label: 'contactEmail'.tr,
              value: 'info@safedest.com',
              onTap: () => _launchEmail('info@safedest.com'),
              color: Colors.blue,
            ),
            const SizedBox(height: 16),

            // الموقع الإلكتروني
            _buildContactItem(
              icon: Icons.language,
              label: 'contactWebsite'.tr,
              value: 'www.safedest.com',
              onTap: () => _launchWebsite('https://www.safedest.com'),
              color: Colors.green,
            ),
            const SizedBox(height: 16),

            // أرقام الهاتف
            Text(
              'contactUs'.tr,
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
            child: Text('closeDialog'.tr),
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
          border: Border.all(color: color.withOpacity(0.3)),
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
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          _buildAccountTile(
            'deleteAccount'.tr,
            'deleteAccountDescription'.tr,
            Icons.delete_forever,
            Colors.red,
            () {
              // TODO: Implement delete account logic
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Feature coming soon')),
              );
            },
          ),
        ],
      ),
    );
  }
}
