import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Controllers/AuthController.dart';

class SupportHelper {
  static final AuthController _authController = Get.find<AuthController>();

  // Open Email
  static Future<void> launchEmail(BuildContext context, String email) async {
    final uri = Uri(scheme: 'mailto', path: email);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showSnackBar(context, 'لا يمكن فتح تطبيق البريد الإلكتروني');
      }
    } catch (e) {
      _showSnackBar(context, 'خطأ في فتح البريد الإلكتروني: $e');
    }
  }

  // Open Website
  static Future<void> launchWebsite(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showSnackBar(context, 'لا يمكن فتح الموقع الإلكتروني');
      }
    } catch (e) {
      _showSnackBar(context, 'خطأ في فتح الموقع: $e');
    }
  }

  // Open WhatsApp
  static Future<void> launchWhatsApp(BuildContext context, String phoneNumber) async {
    final driverName = _authController.currentDriver.value?.name ?? 'driver'.tr;
    final message = 'whatsapp_support_message'.trParams({
      'driverName': driverName,
    });

    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanNumber.startsWith('0')) {
      cleanNumber = '966${cleanNumber.substring(1)}';
    } else if (!cleanNumber.startsWith('966')) {
      cleanNumber = '966$cleanNumber';
    }

    final url = "https://wa.me/$cleanNumber?text=${Uri.encodeComponent(message)}";
    final uri = Uri.parse(url);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showSnackBar(context, 'couldNotOpenWhatsApp'.tr);
      }
    } catch (e) {
      _showSnackBar(context, 'errorOpeningWhatsApp'.tr + ': $e');
    }
  }

  static void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Show Support Dialog
  static void showSupportDialog(BuildContext context) {
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
            _buildContactItem(
              icon: Icons.email,
              label: 'contactEmail'.tr,
              value: 'info@safedest.com',
              onTap: () => launchEmail(context, 'info@safedest.com'),
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            _buildContactItem(
              icon: Icons.language,
              label: 'contactWebsite'.tr,
              value: 'www.safedest.com',
              onTap: () => launchWebsite(context, 'https://www.safedest.com'),
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            Text(
              'contactUs'.tr,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            _buildContactItem(
              icon: Icons.chat_outlined,
              label: '',
              value: '+966540587001',
              onTap: () => launchWhatsApp(context, '+966540587001'),
              color: const Color(0xFF25D366),
            ),
            const SizedBox(height: 8),
            _buildContactItem(
              icon: Icons.chat_outlined,
              label: '',
              value: '+966560915723',
              onTap: () => launchWhatsApp(context, '+966560915723'),
              color: const Color(0xFF25D366),
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

  static Widget _buildContactItem({
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
}
