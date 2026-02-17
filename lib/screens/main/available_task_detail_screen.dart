import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Controllers/TaskController.dart';
import '../../models/task_claim.dart';
import '../../config/app_config.dart';
import '../../services/api_service.dart';

class AvailableTaskDetailScreen extends StatefulWidget {
  final AvailableTask task;

  const AvailableTaskDetailScreen({super.key, required this.task});

  @override
  State<AvailableTaskDetailScreen> createState() => _AvailableTaskDetailScreenState();
}

class _AvailableTaskDetailScreenState extends State<AvailableTaskDetailScreen> {
  final TaskController _taskController = Get.find<TaskController>();
  final TextEditingController _noteController = TextEditingController();
  final RxBool _isSubmitting = false.obs;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submitClaim() async {
    _isSubmitting.value = true;
    try {
      final response = await _taskController.claimTask(
        widget.task.id,
        note: _noteController.text.trim(),
      );

      if (response.isSuccess) {
        Get.back();
        Get.snackbar(
          'confirm'.tr,
          'claimSubmitted'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'errorTitle'.tr,
          response.message ?? 'Failed to submit claim',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      _isSubmitting.value = false;
    }
  }

  void _showClaimBottomSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'confirmClaim'.tr,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'optionalNote'.tr,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _noteController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'writeNoteHere'.tr,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: Obx(() => ElevatedButton(
                  onPressed: _isSubmitting.value ? null : _submitClaim,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSubmitting.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'confirm'.tr,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                )),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('taskDetails'.tr),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Premium Header Info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'ID: #${task.id}',
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${task.totalPrice.toStringAsFixed(2)} SAR',
                    style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'netEarnings'.tr,
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   _buildSection(
                    'pickup_address'.tr,
                    task.pickupAddress ?? '',
                    Icons.radio_button_checked,
                    Colors.blue,
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    'delivery_address'.tr,
                    task.deliveryAddress ?? '',
                    Icons.location_on,
                    Colors.red,
                  ),

                  const Divider(height: 40),

                  if (task.vehicleSize != null) ...[
                    _buildCompactInfo(Icons.local_shipping, 'vehicleSize'.tr, task.vehicleSize!),
                    const SizedBox(height: 16),
                  ],

                  if (task.distance != null) ...[
                    _buildCompactInfo(
                      Icons.directions_run,
                      'proximity'.tr,
                      '${task.distance!.toStringAsFixed(1)} KM ${'awayFromPickup'.tr}'
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (task.additionalData != null && task.additionalData!.isNotEmpty) ...[
                    const Divider(height: 40),
                    _buildAdditionalDataCard(),
                  ],

                  if (task.conditions != null && task.conditions!.isNotEmpty) ...[
                    const Divider(height: 40),
                    _buildConditionsCard(),
                  ],

                  const SizedBox(height: 40),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: (task.claimStatus != null) ? null : _showClaimBottomSheet,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: task.claimStatus != null ? Colors.grey : Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: Theme.of(context).primaryColor.withOpacity(0.4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        task.claimStatus != null ? 'alreadyClaimed'.tr : 'claimTask'.tr,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: Text(
            content,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactInfo(IconData icon, String title, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Theme.of(context).primaryColor, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildAdditionalDataCard() {
    final task = widget.task;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.info_outline,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'additionalData'.tr,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ...task.additionalData!.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildDataField(entry.key, entry.value),
          );
        }),
      ],
    );
  }

  Widget _buildConditionsCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.gavel, color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                Text(
                  'conditions'.tr,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              widget.task.conditions ?? '',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataField(String key, dynamic value) {
    if (value == null) return const SizedBox.shrink();

    if (value is Map<String, dynamic>) {
      return _buildComplexField(key, value);
    } else {
      return _buildSimpleField(key, value.toString());
    }
  }

  Widget _buildSimpleField(String key, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              key,
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
    final label = fieldData['label'] ?? key;
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
              _buildFileField(value, type, label),
            ] else if (type == 'file_expiration_date') ...[
              _buildFileWithExpirationField(value, expiration, label),
            ] else if (type == 'file_with_text') ...[
              _buildFileWithTextField(value, text, label),
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

    switch (type) {
      case 'file': icon = Icons.attach_file; color = Colors.blue; break;
      case 'image': icon = Icons.image; color = Colors.green; break;
      case 'date': icon = Icons.calendar_today; color = Colors.orange; break;
      case 'number': icon = Icons.numbers; color = Colors.purple; break;
      case 'email': icon = Icons.email; color = Colors.red; break;
      case 'phone': icon = Icons.phone; color = Colors.teal; break;
      case 'url': icon = Icons.link; color = Colors.indigo; break;
      case 'file_expiration_date': icon = Icons.schedule; color = Colors.amber; break;
      case 'file_with_text': icon = Icons.description; color = Colors.cyan; break;
      default: icon = Icons.text_fields; color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(icon, size: 16, color: color),
    );
  }

  bool _isImage(String path) {
    if (path.isEmpty) return false;
    final extension = path.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'webp', 'heic'].contains(extension);
  }

  Widget _buildFileField(dynamic value, String type, String label) {
    if (value == null || value.toString().isEmpty) return _buildEmptyValue();

    final imageUrl = AppConfig.getStorageUrl(value.toString());
    final isImageFile = type == 'image' || _isImage(imageUrl);
    final primaryColor = Theme.of(context).primaryColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isImageFile)
          GestureDetector(
            onTap: () => _showImageDialog(imageUrl, label),
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
                ),
              ),
            ),
          ),
        if (!isImageFile)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: primaryColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.attach_file, color: primaryColor),
                const SizedBox(width: 12),
                Expanded(child: Text(value.toString().split('/').last)),
                IconButton(
                  onPressed: () async {
                    final uri = Uri.parse(imageUrl);
                    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
                  },
                  icon: Icon(Icons.open_in_new, color: primaryColor),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _showImageDialog(String imageUrl, String label) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Get.back()),
              title: Text(label, style: const TextStyle(color: Colors.white)),
            ),
            Expanded(child: Image.network(imageUrl, fit: BoxFit.contain)),
          ],
        ),
      ),
    );
  }

  Widget _buildFileWithExpirationField(dynamic value, dynamic expiration, String label) {
    return Column(
      children: [
        if (value != null) _buildFileField(value, 'file', label),
        if (expiration != null) const SizedBox(height: 8),
        if (expiration != null)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                const Icon(Icons.schedule, color: Colors.red, size: 16),
                const SizedBox(width: 8),
                Text('expiration'.tr + ': $expiration', style: const TextStyle(color: Colors.red, fontSize: 12)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildFileWithTextField(dynamic value, dynamic text, String label) {
    return Column(
      children: [
        if (value != null) _buildFileField(value, 'file', label),
        if (text != null) const SizedBox(height: 8),
        if (text != null) _buildTextValue(text),
      ],
    );
  }

  Widget _buildDateField(dynamic value) {
    return _buildSimpleIconField(Icons.calendar_today, value.toString(), Colors.orange);
  }

  Widget _buildNumberField(dynamic value) {
    return _buildSimpleIconField(Icons.numbers, value.toString(), Colors.purple);
  }

  Widget _buildEmailField(dynamic value) {
    return _buildSimpleIconField(Icons.email, value.toString(), Colors.red);
  }

  Widget _buildPhoneField(dynamic value) {
    return _buildSimpleIconField(Icons.phone, value.toString(), Colors.teal);
  }

  Widget _buildUrlField(dynamic value) {
    return _buildSimpleIconField(Icons.link, value.toString(), Colors.indigo);
  }

  Widget _buildSimpleIconField(IconData icon, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withOpacity(0.05), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withOpacity(0.3))),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTextValue(dynamic value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
      child: Text(value.toString()),
    );
  }

  Widget _buildEmptyValue() {
    return Text('not_specified'.tr, style: const TextStyle(color: Colors.grey));
  }
}
