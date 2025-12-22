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
  bool _isLoading = false;
  Map<String, dynamic>? _additionalData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAdditionalData();
  }

  Future<void> _loadAdditionalData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final response = await authService.getAdditionalData();

      if (response.isSuccess && response.data != null) {
        setState(() {
          _additionalData = response.data!['additional_data'] ?? {};
          _isLoading = false;
        });
        debugPrint('Additional data loaded: $_additionalData');
      } else {
        setState(() {
          _errorMessage =
              response.errorMessage ?? 'فشل في جلب البيانات الإضافية';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'حدث خطأ أثناء جلب البيانات: $e';
        _isLoading = false;
      });
      debugPrint('Error loading additional data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('البيانات الإضافية'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _errorMessage != null
              ? _buildErrorState()
              : _additionalData == null || _additionalData!.isEmpty
                  ? _buildEmptyState()
                  : _buildDataContent(),
    );
  }

  Widget _buildErrorState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final errorColor = Theme.of(context).colorScheme.error;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: errorColor,
          ),
          const SizedBox(height: 16),
          Text(
            'حدث خطأ',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: errorColor,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.7),
                ),
          ),
          const SizedBox(height: 32),
          CustomButton(
            text: 'إعادة المحاولة',
            onPressed: _loadAdditionalData,
            backgroundColor: errorColor,
          ),
        ],
      ),
    );
  }

  Widget _buildDataContent() {
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
                            .withOpacity(0.1),
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
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.6),
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
        ..._additionalData!.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildDataField(entry.key, entry.value),
          );
        }),

        const SizedBox(height: 32),

        // Refresh button
        CustomButton(
          text: 'تحديث البيانات',
          onPressed: _loadAdditionalData,
          backgroundColor: Theme.of(context).primaryColor,
        ),
      ],
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
            color:
                Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد بيانات إضافية',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.7),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'لم يتم تسجيل أي بيانات إضافية في ملفك الشخصي',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.6),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                color: isDark
                    ? Theme.of(context)
                        .colorScheme
                        .surface
                        .withOpacity(0.5)
                    : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .outline
                      .withOpacity(0.3),
                ),
              ),
              child: Text(
                value.isNotEmpty ? value : 'غير محدد',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: value.isNotEmpty
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.5),
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
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Field label with type indicator
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColor,
                        ),
                  ),
                ),
                _buildTypeIndicator(type),
              ],
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
            ] else if (type == 'number') ...[
              _buildNumberField(value),
            ] else if (type == 'email') ...[
              _buildEmailField(value),
            ] else if (type == 'phone') ...[
              _buildPhoneField(value),
            ] else if (type == 'url') ...[
              _buildUrlField(value),
            ] else ...[
              _buildTextValue(value),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTypeIndicator(String type) {
    IconData icon;
    Color color;
    String tooltip;

    switch (type) {
      case 'file':
        icon = Icons.attach_file;
        color = Colors.blue;
        tooltip = 'ملف';
        break;
      case 'image':
        icon = Icons.image;
        color = Colors.green;
        tooltip = 'صورة';
        break;
      case 'date':
        icon = Icons.calendar_today;
        color = Colors.orange;
        tooltip = 'تاريخ';
        break;
      case 'number':
        icon = Icons.numbers;
        color = Colors.purple;
        tooltip = 'رقم';
        break;
      case 'email':
        icon = Icons.email;
        color = Colors.red;
        tooltip = 'بريد إلكتروني';
        break;
      case 'phone':
        icon = Icons.phone;
        color = Colors.teal;
        tooltip = 'هاتف';
        break;
      case 'url':
        icon = Icons.link;
        color = Colors.indigo;
        tooltip = 'رابط';
        break;
      case 'file_expiration_date':
        icon = Icons.schedule;
        color = Colors.amber;
        tooltip = 'ملف مع تاريخ انتهاء';
        break;
      case 'file_with_text':
        icon = Icons.description;
        color = Colors.cyan;
        tooltip = 'ملف مع نص';
        break;
      default:
        icon = Icons.text_fields;
        color = Colors.grey;
        tooltip = 'نص';
    }

    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(
          icon,
          size: 16,
          color: color,
        ),
      ),
    );
  }

  Widget _buildFileField(dynamic value, String type) {
    if (value == null || value.toString().isEmpty) {
      return _buildEmptyValue();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? primaryColor.withOpacity(0.1)
            : primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: primaryColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            type == 'image' ? Icons.image : Icons.attach_file,
            color: primaryColor,
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
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.toString().split('/').last,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
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
              color: primaryColor,
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
              color: Theme.of(context)
                  .colorScheme
                  .errorContainer
                  .withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color:
                    Theme.of(context).colorScheme.error.withOpacity(0.5),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: Theme.of(context).colorScheme.error,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'تاريخ انتهاء الصلاحية: $expiration',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onErrorContainer,
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

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final successColor = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? successColor.withOpacity(0.1)
            : successColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: successColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today,
            color: successColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            value.toString(),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
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

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? Theme.of(context).colorScheme.surface.withOpacity(0.5)
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Text(
        value.toString(),
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
      ),
    );
  }

  Widget _buildNumberField(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return _buildEmptyValue();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple[200]!),
      ),
      child: Row(
        children: [
          Icon(
            Icons.numbers,
            color: Colors.purple[600],
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            value.toString(),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.purple[800],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailField(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return _buildEmptyValue();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(
            Icons.email,
            color: Colors.red[600],
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value.toString(),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.red[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneField(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return _buildEmptyValue();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.teal[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.teal[200]!),
      ),
      child: Row(
        children: [
          Icon(
            Icons.phone,
            color: Colors.teal[600],
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value.toString(),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.teal[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrlField(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return _buildEmptyValue();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.indigo[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.indigo[200]!),
      ),
      child: Row(
        children: [
          Icon(
            Icons.link,
            color: Colors.indigo[600],
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value.toString(),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.indigo[800],
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              // TODO: Open URL in browser
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('فتح الرابط قريباً'),
                ),
              );
            },
            icon: Icon(
              Icons.open_in_new,
              color: Colors.indigo[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyValue() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? Theme.of(context).colorScheme.surface.withOpacity(0.3)
            : Theme.of(context).colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Text(
        'غير محدد',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withOpacity(0.5),
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
