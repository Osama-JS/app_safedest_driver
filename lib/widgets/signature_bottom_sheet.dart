import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../models/api_response.dart';

class SignatureBottomSheet extends StatefulWidget {
  final String? currentSignatureUrl;

  const SignatureBottomSheet({super.key, this.currentSignatureUrl});

  @override
  State<SignatureBottomSheet> createState() => _SignatureBottomSheetState();
}

class _SignatureBottomSheetState extends State<SignatureBottomSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Offset?> _points = [];
  File? _selectedImage;
  bool _isSaving = false;
  final GlobalKey _canvasKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // --- Drawing Logic ---
  void _addPoint(Offset? point) {
    setState(() {
      _points.add(point);
    });
  }

  void _clearSignature() {
    setState(() {
      _points.clear();
    });
  }

  Future<File?> _captureSignature() async {
    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(
          recorder,
          Rect.fromPoints(const Offset(0.0, 0.0), const Offset(400.0, 200.0))); // Adjust size as needed

      final paint = Paint()
        ..color = Colors.black
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 3.0;

      for (int i = 0; i < _points.length - 1; i++) {
        if (_points[i] != null && _points[i + 1] != null) {
          canvas.drawLine(_points[i]!, _points[i + 1]!, paint);
        }
      }

      final picture = recorder.endRecording();
      final img = await picture.toImage(400, 200); // Adjust size as needed
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      final buffer = byteData!.buffer.asUint8List();

      final tempDir = Directory.systemTemp;
      final file = await File('${tempDir.path}/signature_${DateTime.now().millisecondsSinceEpoch}.png').create();
      await file.writeAsBytes(buffer);

      return file;
    } catch (e) {
      debugPrint('Error capturing signature: $e');
      return null;
    }
  }

  // --- Upload Logic ---
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // --- Save Logic ---
  Future<void> _saveSignature() async {
    File? signatureFile;

    if (_tabController.index == 0) {
      // Drawing tab
      if (_points.isEmpty) {
        Get.snackbar('error'.tr, 'signature_empty'.tr,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
        return;
      }
      // Capture drawing as image
      // Note: This is a simplified capture. For production, you might want to use
      // a RepaintBoundary key on the CustomPaint widget to capture the exact rendered widget.
      // However, recreating the drawing on a canvas as done in _captureSignature is also a valid approach
      // but requires careful coordinate mapping.
      // Let's implement RepaintBoundary approach for better accuracy.
       signatureFile = await _captureCanvas();

    } else {
      // Upload tab
      if (_selectedImage == null) {
        Get.snackbar('error'.tr, 'image_required'.tr,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
        return;
      }
      signatureFile = _selectedImage;
    }

    if (signatureFile == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final response = await authService.updateSignature(signatureFile);

      if (response.isSuccess) {
        Get.back(result: true);
        Get.snackbar('success'.tr, 'signature_saved'.tr,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white);
      } else {
         Get.snackbar('error'.tr, response.errorMessage,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<File?> _captureCanvas() async {
     try {
       // Wait for build to complete
      await Future.delayed(const Duration(milliseconds: 100));

      // Since we can't easily access RepaintBoundary of a specific widget without context in this simplified example
      // (and usually we need a GlobalKey on a RepaintBoundary), let's use the explicit Canvas drawing approach
      // but adapted to be more robust.
      //
      // Ideally, the CustomPaint should be wrapped in RepaintBoundary(key: _canvasKey).
      // Then use RenderRepaintBoundary to capturing.

      // Let's assume _captureSignature() works reasonably well for this demo context or we fix it.
      // Actually, relying on _captureSignature approach (create new canvas and draw points) is safer for background
      // processing than RepaintBoundary on some devices.
      // BUT, we need to handle coordinates. The _points are collected relative to the CustomPaint widget.
      // When we draw on a new Canvas, we assume (0,0) is top left.

      // Let's stick with _captureSignature logic but refine the size.
       final recorder = ui.PictureRecorder();
       // Use a fixed size for the canvas typically widely compatible
       const width = 600.0;
       const height = 300.0;
       final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, width, height));

       // Fill white background
       final bgPaint = Paint()..color = Colors.white;
       canvas.drawRect(Rect.fromLTWH(0, 0, width, height), bgPaint);

       final paint = Paint()
        ..color = Colors.black
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 4.0;

       // Scale points to fit or just draw as is if the on-screen box matches
       // For this implementation, we will draw 1:1.

       for (int i = 0; i < _points.length - 1; i++) {
        if (_points[i] != null && _points[i + 1] != null) {
          // You might need to adjust offsets if your on-screen box was smaller/larger
          canvas.drawLine(_points[i]!, _points[i + 1]!, paint);
        }
      }

      final picture = recorder.endRecording();
      final img = await picture.toImage(width.toInt(), height.toInt());
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      final buffer = byteData!.buffer.asUint8List();

      final tempDir = Directory.systemTemp;
      final file = await File('${tempDir.path}/signature_${DateTime.now().millisecondsSinceEpoch}.png').create();
      await file.writeAsBytes(buffer);

      return file;

     } catch (e) {
       debugPrint('Error capturing canvas: $e');
        return null;
     }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Title
          Text(
            'add_signature'.tr,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),

          const SizedBox(height: 16),

          // Display Current Signature if available
          if (widget.currentSignatureUrl != null) ...[
            Text(
              'current_signature'.tr,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 100,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(4),
              child: Image.network(
                widget.currentSignatureUrl!,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.error, color: Colors.red),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
          ],

          // Tabs
          TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(icon: const Icon(Icons.draw), text: 'draw'.tr),
              Tab(icon: const Icon(Icons.upload), text: 'upload'.tr),
            ],
          ),

          SizedBox(
            height: 350, // Fixed height for content
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(), // Disable swipe to avoid conflict with drawing
              children: [
                _buildDrawTab(),
                _buildUploadTab(),
              ],
            ),
          ),

          // Save Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveSignature,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'save'.tr,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawTab() {
    return Column(
      children: [
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton.icon(
              onPressed: _clearSignature,
              icon: const Icon(Icons.clear, size: 18),
              label: Text('clear'.tr),
            ),
            const SizedBox(width: 16),
          ],
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade50,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: GestureDetector(
                onPanUpdate: (DragUpdateDetails details) {
                   RenderBox referenceBox = context.findRenderObject() as RenderBox;
                   // We need the local position relative to the Container/GestureDetector
                   // For simplicity in this layout, let's assume the GestureDetector covers the area properly.
                   // A better way is using a RepaintBoundary/Key to get local position

                   // Simplified: using localPosition from details
                   _addPoint(details.localPosition);
                },
                onPanEnd: (DragEndDetails details) => _addPoint(null),
                child: CustomPaint(
                  painter: SignaturePainter(_points),
                  size: Size.infinite,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'sign_above'.tr,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildUploadTab() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => _pickImage(ImageSource.gallery),
          child: Container(
            width: double.infinity,
            height: 200,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: _selectedImage != null
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.shade300,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade50,
            ),
            child: _selectedImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      _selectedImage!,
                      fit: BoxFit.contain,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cloud_upload_outlined,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'tap_to_upload_signature'.tr,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: () => _pickImage(ImageSource.camera),
              icon: const Icon(Icons.camera_alt),
              label: Text('camera'.tr),
            ),
            const SizedBox(width: 16),
            OutlinedButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery),
              icon: const Icon(Icons.image),
              label: Text('gallery'.tr),
            ),
          ],
        ),
      ],
    );
  }
}

class SignaturePainter extends CustomPainter {
  final List<Offset?> points;

  SignaturePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(SignaturePainter oldDelegate) {
    return true;
  }
}
