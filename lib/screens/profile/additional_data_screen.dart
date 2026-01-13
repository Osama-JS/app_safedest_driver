import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/AdditionalDataController.dart';
import '../../widgets/custom_button.dart';
import '../../config/app_config.dart';

class AdditionalDataScreen extends StatelessWidget {
  const AdditionalDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    final controller = Get.put(AdditionalDataController());

    return Scaffold(
      appBar: AppBar(
        title: Text('additionalData'.tr),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: controller.loadAdditionalData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.errorMessage != null) {
          return _buildErrorState(context, controller);
        }

        if (controller.additionalData.isEmpty) {
          return _buildEmptyState(context);
        }

        return _buildDataContent(context, controller);
      }),
    );
  }

  Widget _buildErrorState(BuildContext context, AdditionalDataController controller) {
    final errorColor = Theme.of(context).colorScheme.error;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: errorColor,
            ),
            const SizedBox(height: 24),
            Text(
              'error_occurred_title'.tr,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: errorColor,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              controller.errorMessage!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: 'retry'.tr,
                onPressed: controller.loadAdditionalData,
                backgroundColor: errorColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                size: 80,
                color: Theme.of(context).primaryColor.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'no_additional_data'.tr,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'no_additional_data_desc'.tr,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: 'back_to_profile'.tr,
                onPressed: () => Get.back(),
                backgroundColor: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataContent(BuildContext context, AdditionalDataController controller) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header
        Card(
          elevation: 0,
          color: Theme.of(context).primaryColor.withOpacity(0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.1)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  Icons.assignment_ind_outlined,
                  color: Theme.of(context).primaryColor,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.templateName ?? 'additionalData'.tr,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'supplementary_info_desc'.tr,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Additional data fields
        ...controller.additionalData.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _DataFieldWidget(labelKey: entry.key, value: entry.value),
          );
        }),

        const SizedBox(height: 24),
      ],
    );
  }
}

class _DataFieldWidget extends StatelessWidget {
  final String labelKey;
  final dynamic value;

  const _DataFieldWidget({required this.labelKey, required this.value});

  @override
  Widget build(BuildContext context) {
    if (value == null) return const SizedBox.shrink();

    if (value is Map<String, dynamic>) {
      return _buildComplexField(context, labelKey, value);
    } else {
      return _buildSimpleField(context, labelKey, value.toString());
    }
  }

  Widget _buildSimpleField(BuildContext context, String key, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    ? Theme.of(context).colorScheme.surface.withOpacity(0.5)
                    : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                ),
              ),
              child: Text(
                value.isNotEmpty ? value : 'not_specified'.tr,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: value.isNotEmpty
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComplexField(BuildContext context, String key, Map<String, dynamic> fieldData) {
    final label = fieldData['label'] ?? _getFieldLabel(key);
    final value = fieldData['value'];
    final type = fieldData['type'] ?? 'text';
    final expiration = fieldData['expiration'];
    final text = fieldData['text'];

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
            if (type == 'file' || type == 'image') ...[
              _buildFileField(context, value, type, label),
            ] else if (type == 'file_expiration_date') ...[
              _buildFileWithExpirationField(context, value, expiration, label),
            ] else if (type == 'file_with_text') ...[
              _buildFileWithTextField(context, value, text, label),
            ] else if (type == 'date') ...[
              _buildDateField(context, value),
            ] else if (type == 'number') ...[
              _buildNumberField(context, value),
            ] else if (type == 'email') ...[
              _buildEmailField(context, value),
            ] else if (type == 'phone') ...[
              _buildPhoneField(context, value),
            ] else if (type == 'url') ...[
              _buildUrlField(context, value),
            ] else ...[
              _buildTextValue(context, value),
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
        tooltip = 'file_type_file'.tr;
        break;
      case 'image':
        icon = Icons.image;
        color = Colors.green;
        tooltip = 'file_type_image'.tr;
        break;
      case 'date':
        icon = Icons.calendar_today;
        color = Colors.orange;
        tooltip = 'file_type_date'.tr;
        break;
      case 'number':
        icon = Icons.numbers;
        color = Colors.purple;
        tooltip = 'file_type_number'.tr;
        break;
      case 'email':
        icon = Icons.email;
        color = Colors.red;
        tooltip = 'email'.tr;
        break;
      case 'phone':
        icon = Icons.phone;
        color = Colors.teal;
        tooltip = 'phone'.tr;
        break;
      case 'url':
        icon = Icons.link;
        color = Colors.indigo;
        tooltip = 'file_type_url'.tr;
        break;
      case 'file_expiration_date':
        icon = Icons.schedule;
        color = Colors.amber;
        tooltip = 'file_type_file_expiration'.tr;
        break;
      case 'file_with_text':
        icon = Icons.description;
        color = Colors.cyan;
        tooltip = 'file_type_file_text'.tr;
        break;
      default:
        icon = Icons.text_fields;
        color = Colors.grey;
        tooltip = 'file_type_text'.tr;
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

  bool _isImage(String path) {
    if (path.isEmpty) return false;
    final extension = path.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'webp', 'heic'].contains(extension);
  }

  void _showImageDialog(BuildContext context, String imageUrl, String label) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                ),
              ],
            ),
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
                maxWidth: MediaQuery.of(context).size.width * 0.9,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(20),
                    child: const Icon(Icons.broken_image, size: 50, color: Colors.red),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                label,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFileField(BuildContext context, dynamic value, String type, String label) {
    if (value == null || value.toString().isEmpty) {
      return _buildEmptyValue(context);
    }

    final imageUrl = AppConfig.getStorageUrl(value.toString());
    final isImageFile = type == 'image' || _isImage(imageUrl);
    final primaryColor = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isImageFile)
          GestureDetector(
            onTap: () => _showImageDialog(context, imageUrl, label),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primaryColor.withOpacity(0.3)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.broken_image, color: Colors.red),
                        const SizedBox(height: 8),
                        Text('errorLoadingImage'.tr, style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        if (!isImageFile)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? primaryColor.withOpacity(0.1) : primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: primaryColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.attach_file, color: primaryColor, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'attached_file'.tr,
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
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    final url = Uri.parse(imageUrl);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    }
                  },
                  icon: Icon(Icons.open_in_new, color: primaryColor),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildFileWithExpirationField(BuildContext context, dynamic value, dynamic expiration, String label) {
    return Column(
      children: [
        if (value != null) _buildFileField(context, value, 'file', label),
        if (value != null && expiration != null) const SizedBox(height: 12),
        if (expiration != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Theme.of(context).colorScheme.error.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                Icon(Icons.schedule, color: Theme.of(context).colorScheme.error, size: 20),
                const SizedBox(width: 8),
                Text(
                  'expiration_date_label'.trParams({'date': expiration.toString()}),
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildFileWithTextField(BuildContext context, dynamic value, dynamic text, String label) {
    return Column(
      children: [
        if (value != null) _buildFileField(context, value, 'file', label),
        if (value != null && text != null) const SizedBox(height: 12),
        if (text != null) _buildTextValue(context, text),
      ],
    );
  }

  Widget _buildDateField(BuildContext context, dynamic value) {
    if (value == null || value.toString().isEmpty) return _buildEmptyValue(context);
    final successColor = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: successColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: successColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today, color: successColor, size: 20),
          const SizedBox(width: 12),
          Text(
            value.toString(),
            style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
          ),
        ],
      ),
    );
  }

  Widget _buildTextValue(BuildContext context, dynamic value) {
    if (value == null || value.toString().isEmpty) return _buildEmptyValue(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
      ),
      child: Text(
        value.toString(),
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }

  Widget _buildNumberField(BuildContext context, dynamic value) {
    if (value == null || value.toString().isEmpty) return _buildEmptyValue(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.numbers, color: Colors.purple[600], size: 20),
          const SizedBox(width: 12),
          Text(
            value.toString(),
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.purple[800], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailField(BuildContext context, dynamic value) {
    if (value == null || value.toString().isEmpty) return _buildEmptyValue(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.email, color: Colors.red[600], size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(value.toString(), style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red[800]))),
        ],
      ),
    );
  }

  Widget _buildPhoneField(BuildContext context, dynamic value) {
    if (value == null || value.toString().isEmpty) return _buildEmptyValue(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.teal[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.teal[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.phone, color: Colors.teal[600], size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(value.toString(), style: TextStyle(fontWeight: FontWeight.w600, color: Colors.teal[800]))),
        ],
      ),
    );
  }

  Widget _buildUrlField(BuildContext context, dynamic value) {
    if (value == null || value.toString().isEmpty) return _buildEmptyValue(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.indigo[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.indigo[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.link, color: Colors.indigo[600], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value.toString(),
              style: TextStyle(fontWeight: FontWeight.w600, color: Colors.indigo[800], decoration: TextDecoration.underline),
            ),
          ),
          IconButton(
            onPressed: () async {
              final url = Uri.parse(value.toString());
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
            icon: Icon(Icons.open_in_new, color: Colors.indigo[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyValue(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
      ),
      child: Text(
        'not_specified'.tr,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
      ),
    );
  }

  String _getFieldLabel(String key) {
    return key;
  }
}
