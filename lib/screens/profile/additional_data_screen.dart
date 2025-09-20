import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';

class AdditionalDataScreen extends StatefulWidget {
  const AdditionalDataScreen({super.key});

  @override
  State<AdditionalDataScreen> createState() => _AdditionalDataScreenState();
}

class _AdditionalDataScreenState extends State<AdditionalDataScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('البيانات الإضافية'),
        elevation: 0,
      ),
      body: Consumer<AuthService>(
        builder: (context, authService, child) {
          final driver = authService.currentDriver;

          if (driver == null) {
            return const Center(
              child: Text('لا توجد بيانات للسائق'),
            );
          }

          // Parse additional data
          Map<String, dynamic> additionalData = {};
          debugPrint('Driver additional data: ${driver.additionalData}');

          if (driver.additionalData != null &&
              driver.additionalData!.isNotEmpty) {
            try {
              additionalData =
                  Map<String, dynamic>.from(driver.additionalData!);
              debugPrint('Parsed additional data: $additionalData');
            } catch (e) {
              debugPrint('Error parsing additional data: $e');
            }
          } else {
            debugPrint('No additional data found for driver');
          }

          if (additionalData.isEmpty) {
            return _buildEmptyState();
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header
              Card(
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
                              color: Theme.of(context)
                                  .primaryColor
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.info_outline,
                              color: Theme.of(context).primaryColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'البيانات الإضافية',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'المعلومات التكميلية المسجلة في ملفك الشخصي',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Additional data fields
              ...additionalData.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildDataField(entry.key, entry.value),
                );
              }),

              const SizedBox(height: 32),

              // Update button
              CustomButton(
                text: 'تحديث البيانات',
                onPressed: () {
                  // TODO: Navigate to update additional data screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('ميزة تحديث البيانات قريباً'),
                      backgroundColor: Colors.blue,
                    ),
                  );
                },
                backgroundColor: Theme.of(context).primaryColor,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.info_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد بيانات إضافية',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'لم يتم تسجيل أي بيانات إضافية في ملفك الشخصي',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
          const SizedBox(height: 32),
          CustomButton(
            text: 'العودة للملف الشخصي',
            onPressed: () => Navigator.pop(context),
            backgroundColor: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildDataField(String key, dynamic value) {
    if (value == null) return const SizedBox.shrink();

    // Handle different data types
    if (value is Map<String, dynamic>) {
      return _buildComplexField(key, value);
    } else {
      return _buildSimpleField(key, value.toString());
    }
  }

  Widget _buildSimpleField(String key, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getFieldLabel(key),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Text(
                value.isNotEmpty ? value : 'غير محدد',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: value.isNotEmpty ? null : Colors.grey[500],
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComplexField(String key, Map<String, dynamic> fieldData) {
    final label = fieldData['label'] ?? _getFieldLabel(key);
    final value = fieldData['value'];
    final type = fieldData['type'] ?? 'text';
    final expiration = fieldData['expiration'];
    final text = fieldData['text'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  ),
            ),
            const SizedBox(height: 12),

            // Handle different field types
            if (type == 'file' || type == 'image') ...[
              _buildFileField(value, type),
            ] else if (type == 'file_expiration_date') ...[
              _buildFileWithExpirationField(value, expiration),
            ] else if (type == 'file_with_text') ...[
              _buildFileWithTextField(value, text),
            ] else if (type == 'date') ...[
              _buildDateField(value),
            ] else ...[
              _buildTextValue(value),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFileField(dynamic value, String type) {
    if (value == null || value.toString().isEmpty) {
      return _buildEmptyValue();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(
            type == 'image' ? Icons.image : Icons.attach_file,
            color: Colors.blue[600],
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type == 'image' ? 'صورة مرفقة' : 'ملف مرفق',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.toString().split('/').last,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // TODO: Open file/image viewer
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('عارض الملفات قريباً'),
                ),
              );
            },
            icon: Icon(
              Icons.open_in_new,
              color: Colors.blue[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileWithExpirationField(dynamic value, dynamic expiration) {
    return Column(
      children: [
        if (value != null) _buildFileField(value, 'file'),
        if (value != null && expiration != null) const SizedBox(height: 12),
        if (expiration != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange[200]!),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: Colors.orange[600],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'تاريخ انتهاء الصلاحية: $expiration',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.orange[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFileWithTextField(dynamic value, dynamic text) {
    return Column(
      children: [
        if (value != null) _buildFileField(value, 'file'),
        if (value != null && text != null) const SizedBox(height: 12),
        if (text != null) _buildTextValue(text),
      ],
    );
  }

  Widget _buildDateField(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return _buildEmptyValue();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today,
            color: Colors.green[600],
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            value.toString(),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.green[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextValue(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return _buildEmptyValue();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Text(
        value.toString(),
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }

  Widget _buildEmptyValue() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Text(
        'غير محدد',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
              fontStyle: FontStyle.italic,
            ),
      ),
    );
  }

  String _getFieldLabel(String key) {
    // Convert field key to readable Arabic label
    switch (key.toLowerCase()) {
      case 'license_number':
        return 'رقم الرخصة';
      case 'license_expiry':
        return 'تاريخ انتهاء الرخصة';
      case 'id_number':
        return 'رقم الهوية';
      case 'vehicle_registration':
        return 'استمارة المركبة';
      case 'insurance_policy':
        return 'وثيقة التأمين';
      case 'medical_certificate':
        return 'الشهادة الطبية';
      case 'criminal_record':
        return 'صحيفة الحالة الجنائية';
      case 'bank_account':
        return 'رقم الحساب البنكي';
      case 'emergency_contact':
        return 'جهة الاتصال للطوارئ';
      case 'address_proof':
        return 'إثبات العنوان';
      default:
        return key
            .replaceAll('_', ' ')
            .split(' ')
            .map((word) => word.isNotEmpty
                ? word[0].toUpperCase() + word.substring(1)
                : word)
            .join(' ');
    }
  }
}
