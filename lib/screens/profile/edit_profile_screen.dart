import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../services/auth_service.dart';
import '../../models/driver.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../utils/debug_helper.dart';
import '../../config/app_config.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  File? _selectedImage;
  bool _isLoading = false;
  Driver? _currentDriver;

  @override
  void initState() {
    super.initState();
    _loadDriverData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _loadDriverData() {
    final authService = Provider.of<AuthService>(context, listen: false);
    _currentDriver = authService.currentDriver;

    if (_currentDriver != null) {
      _nameController.text = _currentDriver!.name;
      _emailController.text = _currentDriver!.email;
      _usernameController.text = _currentDriver!.username ?? '';
      _phoneController.text = _currentDriver!.phone ?? '';
      _addressController.text = _currentDriver!.address ?? '';
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      DebugHelper.log('Error picking image: $e', tag: 'EDIT_PROFILE');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('فشل في اختيار الصورة'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // دالة مساعدة لإنشاء ImageProvider
  ImageProvider? _getProfileImage() {
    if (_selectedImage != null) {
      return FileImage(_selectedImage!);
    } else if (_currentDriver?.image != null &&
        _currentDriver!.image!.isNotEmpty) {
      return NetworkImage(AppConfig.getStorageUrl(_currentDriver!.image!));
    }
    return null;
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);

      final updateData = {
        'name': _nameController.text.trim(),
        // البريد الإلكتروني محذوف لأنه غير قابل للتعديل
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
      };

      final response = await authService.updateProfile(
        updateData,
        imageFile: _selectedImage,
      );

      if (mounted) {
        if (response.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تحديث الملف الشخصي بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Return true to indicate success
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(response.errorMessage ?? 'فشل في تحديث الملف الشخصي'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      DebugHelper.log('Error updating profile: $e', tag: 'EDIT_PROFILE');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('حدث خطأ أثناء تحديث الملف الشخصي'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تعديل الملف الشخصي'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _updateProfile,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'حفظ',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Profile Image Section
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[300],
                    backgroundImage:
                        _getProfileImage(), // استخدام الدالة المساعدة
                    child:
                        _selectedImage == null && _currentDriver?.image == null
                            ? const Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.grey,
                              )
                            : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: _pickImage,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Form Fields
            CustomTextField(
              controller: _nameController,
              label: 'الاسم الكامل',
              prefixIcon: Icons.person,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'الاسم مطلوب';
                }
                if (value.trim().length < 2) {
                  return 'الاسم يجب أن يكون أكثر من حرفين';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _emailController,
              label: 'البريد الإلكتروني (غير قابل للتعديل)',
              prefixIcon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              enabled: false, // منع التعديل
              validator: null, // إزالة validation لأنه غير قابل للتعديل
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _usernameController,
              label: 'اسم المستخدم (غير قابل للتعديل)',
              prefixIcon: Icons.account_circle,
              enabled: false, // منع التعديل
              validator: null, // إزالة validation لأنه غير قابل للتعديل
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _phoneController,
              label: 'رقم الهاتف',
              prefixIcon: Icons.phone,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  if (!RegExp(r'^[0-9+\-\s()]+$').hasMatch(value)) {
                    return 'رقم الهاتف غير صحيح';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _addressController,
              label: 'العنوان',
              prefixIcon: Icons.location_on,
              maxLines: 3,
              validator: (value) {
                // Address is optional
                return null;
              },
            ),
            const SizedBox(height: 32),

            // Update Button
            CustomButton(
              text: 'تحديث الملف الشخصي',
              onPressed: _isLoading ? null : _updateProfile,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 16),

            // Change Password Button
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/change-password');
              },
              icon: const Icon(Icons.lock),
              label: const Text('تغيير كلمة المرور'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: Theme.of(context).primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
