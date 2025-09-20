import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_file/open_file.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/task.dart';
import '../services/task_service.dart';
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
    final taskService = Provider.of<TaskService>(context, listen: false);

    try {
      final response = await taskService.getTaskLogs(widget.task.id);

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في جلب سجل المهمة: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(Icons.history, color: Colors.blue[700], size: 28),
                const SizedBox(width: 12),
                Text(
                  'سجل المهمة #${widget.task.id}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
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
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'لا يوجد سجل للمهمة',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  _getStatusIcon(status),
                  color: Colors.blue[700],
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      TaskStatusExtension.fromString(status).displayName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      _formatDateTime(timestamp),
                      style: TextStyle(
                        color: Colors.grey[600],
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
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      Icons.attach_file,
                      color: Colors.green[600],
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
              style: const TextStyle(fontSize: 14),
            ),
          ],
          if (hasFile && fileName != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.attach_file,
                    size: 16,
                    color: Colors.blue[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    fileName,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[700],
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
              'إضافة ملاحظة',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),

            // Note Input
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'اكتب ملاحظتك هنا...',
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
                    label: Text(_selectedFileName ?? 'إرفاق ملف'),
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
                    label: Text(_isAddingNote ? 'جاري الإضافة...' : 'إضافة'),
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

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في اختيار الملف: $e')),
        );
      }
    }
  }

  Future<void> _addNote() async {
    if (_noteController.text.trim().isEmpty) {
      if (mounted) {
        // إغلاق النافذة أولاً ثم عرض الرسالة
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يرجى كتابة ملاحظة')),
        );
      }
      return;
    }

    setState(() {
      _isAddingNote = true;
    });

    try {
      final taskService = Provider.of<TaskService>(context, listen: false);
      final response = await taskService.addTaskNote(
        widget.task.id,
        _noteController.text.trim(),
        filePath: _selectedFilePath,
      );

      if (mounted) {
        setState(() {
          _isAddingNote = false;
        });

        // إغلاق النافذة أولاً
        Navigator.of(context).pop();

        if (response.isSuccess) {
          // عرض رسالة النجاح في الصفحة الرئيسية
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('تم إضافة الملاحظة بنجاح'),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
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
          // عرض رسالة الخطأ في الصفحة الرئيسية
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      response.errorMessage.isNotEmpty
                          ? response.errorMessage
                          : 'فشل في إضافة الملاحظة',
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAddingNote = false;
        });

        // إغلاق النافذة أولاً
        Navigator.of(context).pop();

        // عرض رسالة الخطأ في الصفحة الرئيسية
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('خطأ في إضافة الملاحظة: $e'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في فتح المرفق: $e')),
        );
      }
    }
  }

  Widget _buildAttachmentDialog(
      String? fileName, String fileUrl, String filePath) {
    final isImage = _isImageFile(filePath);
    final displayName = fileName ?? _getFileNameFromPath(filePath);

    return Dialog(
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
                color: Colors.blue[50],
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(8)),
              ),
              child: Row(
                children: [
                  Icon(
                    isImage ? Icons.image : Icons.insert_drive_file,
                    color: Colors.blue[700],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      displayName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
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
                    label: const Text('تحميل'),
                  ),
                  if (!isImage)
                    ElevatedButton.icon(
                      onPressed: () => _openExternalFile(fileUrl),
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('فتح'),
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
            Text('خطأ في تحميل الصورة: $error'),
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
            color: Colors.blue[600],
          ),
          const SizedBox(height: 16),
          Text(
            fileName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'اضغط على "فتح" لعرض الملف',
            style: TextStyle(
              color: Colors.grey[600],
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
      case 'txt':
        return Icons.text_snippet;
      case 'zip':
      case 'rar':
        return Icons.archive;
      default:
        return Icons.insert_drive_file;
    }
  }

  Future<void> _downloadFile(String fileUrl, String fileName) async {
    try {
      final uri = Uri.parse(fileUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $fileUrl';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تحميل الملف: $e')),
        );
      }
    }
  }

  Future<void> _openExternalFile(String fileUrl) async {
    try {
      final uri = Uri.parse(fileUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $fileUrl';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في فتح الملف: $e')),
        );
      }
    }
  }
}
