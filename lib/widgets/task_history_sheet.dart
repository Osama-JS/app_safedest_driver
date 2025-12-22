import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_file/open_file.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/task.dart';
import '../Controllers/TaskController.dart';
import '../config/app_config.dart';

class TaskHistorySheet extends StatefulWidget {
  final Task task;

  const TaskHistorySheet({
    super.key,
    required this.task,
  });

  @override
  State<TaskHistorySheet> createState() => _TaskHistorySheetState();
}

class _TaskHistorySheetState extends State<TaskHistorySheet> {
  final TaskController _taskController = Get.find<TaskController>();
  final TextEditingController _noteController = TextEditingController();
  String? _selectedFilePath;
  String? _selectedFileName;
  List<TaskLog> _taskLogs = [];
  bool _isLoading = true;
  bool _isAddingNote = false;

  @override
  void initState() {
    super.initState();
    _loadTaskLogs();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadTaskLogs() async {
    try {
      final response = await _taskController.getTaskLogs(widget.task.id);

      if (mounted) {
        setState(() {
          if (response.isSuccess && response.data != null) {
            _taskLogs = response.data!;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        Get.snackbar(
          'error'.tr,
          'errorLoadingTaskHistory'.trParams({'error': e.toString()}),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[600] : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(Icons.history,
                    color: Theme.of(context).colorScheme.primary, size: 28),
                const SizedBox(width: 12),
                Text(
                  'taskHistoryTitle'.trParams({'id': widget.task.id.toString()}),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(
                    Icons.close,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),

          const Divider(),

          // Content
          Expanded(
            child: Column(
              children: [
                // History List
                Expanded(
                  child: _buildHistoryList(),
                ),

                const Divider(),

                // Add Note Section
                _buildAddNoteSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_taskLogs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history,
                size: 64,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'noTaskHistory'.tr,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _taskLogs.length,
      itemBuilder: (context, index) {
        final log = _taskLogs[index];
        return _buildHistoryItem(log);
      },
    );
  }

  Widget _buildHistoryItem(TaskLog log) {
    final timestamp = log.createdAt;
    final status = log.status;
    final note = log.note ?? '';
    final hasFile = log.fileName != null;
    final fileName = log.fileName;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Theme.of(context).colorScheme.surfaceVariant
            : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isDark
                ? Theme.of(context).colorScheme.outline.withOpacity(0.3)
                : Theme.of(context).colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isDark
                      ? Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.2)
                      : Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  _getStatusIcon(status),
                  color: Theme.of(context).colorScheme.primary,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getStatusDisplayName(status),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      _formatDateTime(timestamp),
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasFile)
                GestureDetector(
                  onTap: () => _openAttachment(fileName, log),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.green.withOpacity(0.2)
                          : Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      Icons.attach_file,
                      color: isDark ? Colors.green[300] : Colors.green[600],
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
          if (note.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              note,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
          if (hasFile && fileName != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isDark
                    ? Theme.of(context)
                        .colorScheme
                        .primary
                        .withOpacity(0.2)
                    : Theme.of(context)
                        .colorScheme
                        .primary
                        .withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.attach_file,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    fileName,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddNoteSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'addNote'.tr,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 12),

            // Note Input
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'writeNoteHere'.tr,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),

            const SizedBox(height: 12),

            // File Selection and Submit
            Column(
              children: [
                // File Selection Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isAddingNote ? null : _selectFile,
                    icon: const Icon(Icons.attach_file, size: 18),
                    label: Text(_selectedFileName ?? 'attachFile'.tr),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isAddingNote ? null : _addNote,
                    icon: _isAddingNote
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.add, size: 18),
                    label: Text(_isAddingNote ? 'adding'.tr : 'add'.tr),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'assign':
        return Icons.assignment;
      case 'started':
        return Icons.play_arrow;
      case 'in pickup point':
        return Icons.location_on;
      case 'loading':
        return Icons.upload;
      case 'in the way':
        return Icons.local_shipping;
      case 'in delivery point':
        return Icons.flag;
      case 'unloading':
        return Icons.download;
      case 'completed':
        return Icons.done_all;
      default:
        return Icons.circle;
    }
  }

  String _getStatusDisplayName(String status) {
    switch (status.toLowerCase()) {
      case 'assign':
        return 'taskStatusAssign'.tr;
      case 'started':
        return 'taskStatusStarted'.tr;
      case 'in pickup point':
        return 'taskStatusInPickupPoint'.tr;
      case 'loading':
        return 'taskStatusLoading'.tr;
      case 'in the way':
        return 'taskStatusInTheWay'.tr;
      case 'in delivery point':
        return 'taskStatusInDeliveryPoint'.tr;
      case 'unloading':
        return 'taskStatusUnloading'.tr;
      case 'completed':
        return 'taskStatusCompleted'.tr;
      case 'cancelled':
        return 'taskStatusCancelled'.tr;
      default:
        return status;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return 'minutes_ago'.trParams({'count': difference.inMinutes.toString()});
    } else if (difference.inHours < 24) {
      return 'hours_ago'.trParams({'count': difference.inHours.toString()});
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  Future<void> _selectFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty && mounted) {
        setState(() {
          _selectedFilePath = result.files.first.path;
          _selectedFileName = result.files.first.name;
        });
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'error'.tr,
          e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  Future<void> _addNote() async {
    if (_noteController.text.trim().isEmpty) {
      Get.snackbar(
        'warning'.tr,
        'pleaseWriteNote'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      _isAddingNote = true;
    });

    try {
      final response = await _taskController.addTaskNote(
        widget.task.id,
        _noteController.text.trim(),
        filePath: _selectedFilePath,
      );

      if (mounted) {
        setState(() {
          _isAddingNote = false;
        });

        if (response.isSuccess) {
          Get.back();
          Get.snackbar(
            'success'.tr,
            'noteAddedSuccessfully'.tr,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );

          // Clear form
          _noteController.clear();
          setState(() {
            _selectedFilePath = null;
            _selectedFileName = null;
          });

          // Reload logs
          _loadTaskLogs();
        } else {
          Get.snackbar(
            'error'.tr,
            response.errorMessage.isNotEmpty
                ? response.errorMessage
                : 'failedToAddNote'.tr,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAddingNote = false;
        });
        Get.snackbar(
          'error'.tr,
          'errorAddingNote'.trParams({'error': e.toString()}),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  Future<void> _openAttachment(String? fileName, TaskLog log) async {
    if (log.filePath == null) return;

    try {
      final fileUrl = AppConfig.getStorageUrl(log.filePath!);

      // Show attachment dialog
      showDialog(
        context: context,
        builder: (context) =>
            _buildAttachmentDialog(fileName, fileUrl, log.filePath!),
      );
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'error'.tr,
          'errorOpeningAttachment'.trParams({'error': e.toString()}),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  Widget _buildAttachmentDialog(
      String? fileName, String fileUrl, String filePath) {
    final isImage = _isImageFile(filePath);
    final displayName = fileName ?? _getFileNameFromPath(filePath);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? Theme.of(context)
                        .colorScheme
                        .primary
                        .withOpacity(0.2)
                    : Theme.of(context)
                        .colorScheme
                        .primary
                        .withOpacity(0.1),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(8)),
              ),
              child: Row(
                children: [
                  Icon(
                    isImage ? Icons.image : Icons.insert_drive_file,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      displayName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(
                      Icons.close,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: isImage
                    ? _buildImageViewer(fileUrl)
                    : _buildFileViewer(displayName, fileUrl),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _downloadFile(fileUrl, displayName),
                    icon: const Icon(Icons.download),
                    label: Text('download'.tr),
                  ),
                  if (!isImage)
                    ElevatedButton.icon(
                      onPressed: () => _openExternalFile(fileUrl),
                      icon: const Icon(Icons.open_in_new),
                      label: Text('open'.tr),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageViewer(String imageUrl) {
    return Center(
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.contain,
        placeholder: (context, url) => const CircularProgressIndicator(),
        errorWidget: (context, url, error) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'errorLoadingImage'.trParams({'error': error.toString()}),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileViewer(String fileName, String fileUrl) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getFileIcon(fileName),
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            fileName,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'clickOpenToViewFile'.tr,
            style: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withOpacity(0.6),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  bool _isImageFile(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension);
  }

  String _getFileNameFromPath(String filePath) {
    return filePath.split('/').last;
  }

  IconData _getFileIcon(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      default:
        return Icons.insert_drive_file;
    }
  }

  Future<void> _downloadFile(String url, String fileName) async {
    _openExternalFile(url);
  }

  Future<void> _openExternalFile(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        'error'.tr,
        'checkInternet'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
