import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/generated/app_localizations.dart';

import '../../services/registration_service.dart';
import '../../models/registration_data.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/phone_input_field.dart';
import 'package:file_picker/file_picker.dart';
import '../../utils/debug_helper.dart';
import 'login_screen.dart';
import 'dart:convert';
import 'dart:io';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();

  // Controllers for basic info
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _addressController = TextEditingController();
  final _whatsappController = TextEditingController();

  // State variables
  int _currentStep = 0;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _phoneIsWhatsapp = false;

  String? _selectedPhoneCode = '+966';
  String? _selectedWhatsappCode;
  String? _selectedVehicleId;
  String? _selectedVehicleTypeId;
  String? _selectedVehicleSizeId;
  String? _selectedTeamId;

  List<VehicleType> _availableVehicleTypes = [];
  List<VehicleSize> _availableVehicleSizes = [];

  RegistrationData? _registrationData;
  Map<String, dynamic> _additionalFieldsData = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRegistrationData();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _addressController.dispose();
    _whatsappController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadRegistrationData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final registrationService =
          Provider.of<RegistrationService>(context, listen: false);
      final data = await registrationService.getRegistrationData();

      if (data != null) {
        setState(() {
          _registrationData = data;
        });
      }
    } catch (e) {
      DebugHelper.log('Error loading registration data: $e', tag: 'REGISTER');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                AppLocalizations.of(context)!.failedToLoadRegistrationData),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final registrationService =
          Provider.of<RegistrationService>(context, listen: false);

      final registrationRequest = <String, dynamic>{
        'name': _nameController.text,
        'username': _usernameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'phone_code': _selectedPhoneCode,
        'password': _passwordController.text,
        'password_confirmation': _confirmPasswordController.text,
        'address': _addressController.text,
        'vehicle_size_id': _selectedVehicleSizeId,
        'team_id': _selectedTeamId,
        'phone_is_whatsapp': _phoneIsWhatsapp,
        'whatsapp_country_code':
            _phoneIsWhatsapp ? _selectedPhoneCode : _selectedWhatsappCode,
        'whatsapp_number':
            _phoneIsWhatsapp ? _phoneController.text : _whatsappController.text,
        'template_id': _registrationData?.driverTemplate?.id,
      };

      // Add additional fields data in the correct format expected by API
      Map<String, dynamic> additionalFields = {};
      Map<String, dynamic> additionalFiles = {};

      _additionalFieldsData.forEach((key, value) {
        // Handle special field types that need specific formatting
        if (key.endsWith('_expiration')) {
          // This is handled as part of file_expiration_date or file_with_text
          final baseFieldName = key.replaceAll('_expiration', '');
          additionalFields['${baseFieldName}_expiration'] = value;
        } else if (key.endsWith('_text')) {
          // This is handled as part of file_with_text
          final baseFieldName = key.replaceAll('_text', '');
          additionalFields['${baseFieldName}_text'] = value;
        } else {
          // Regular fields and files
          if (value is PlatformFile) {
            // For file fields, check if it's part of a complex field type
            final fieldInfo = _getFieldInfo(key);
            if (fieldInfo != null) {
              if (fieldInfo.type == 'file_expiration_date') {
                additionalFiles['additional_fields.${key}_file'] = value;
              } else if (fieldInfo.type == 'file_with_text') {
                additionalFiles['additional_fields.${key}_file'] = value;
              } else {
                additionalFiles['additional_fields.$key'] = value;
              }
            } else {
              additionalFiles['additional_fields.$key'] = value;
            }
          } else {
            additionalFields[key] = value;
          }
        }
      });

      // Add the structured additional_fields to the request
      if (additionalFields.isNotEmpty) {
        registrationRequest['additional_fields'] = additionalFields;
      }

      // Add files separately for multipart handling
      additionalFiles.forEach((key, value) {
        registrationRequest[key] = value;
      });

      final response = await registrationService.register(registrationRequest);

      if (mounted) {
        if (response.isSuccess) {
          _showSuccessDialog();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.errorMessage ?? 'فشل في التسجيل'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      DebugHelper.log('Error during registration: $e', tag: 'REGISTER');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.registrationError),
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

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.email_outlined,
          size: 64,
          color: Colors.green,
        ),
        title: Text(AppLocalizations.of(context)!.registrationSuccess),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'تم إرسال رابط التحقق إلى بريدك الإلكتروني.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              'يرجى التحقق من بريدك الإلكتروني وتفعيل حسابك، ثم العودة لتسجيل الدخول.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            child: const Text('تسجيل الدخول'),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    // Validate current step before moving to next
    if (_currentStep == 0) {
      // Validate basic info
      if (!_formKey.currentState!.validate()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يرجى تصحيح الأخطاء في البيانات الأساسية'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    } else if (_currentStep == 1) {
      // Validate vehicle selection (mandatory)
      if (_selectedVehicleId == null ||
          _selectedVehicleTypeId == null ||
          _selectedVehicleSizeId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يرجى اختيار المركبة ونوعها وحجمها'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Validate additional info if needed
      if (_registrationData?.driverFields.isNotEmpty == true) {
        bool hasErrors = false;
        for (final field in _registrationData!.driverFields) {
          if (field.required == true) {
            final fieldName = field.name;
            final value = _additionalFieldsData[fieldName];
            if (value == null || value.toString().isEmpty) {
              hasErrors = true;
              break;
            }
          }
        }
        if (hasErrors) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('يرجى ملء جميع الحقول المطلوبة في المعلومات الإضافية'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }
    }

    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _registrationData == null) {
      return Scaffold(
        appBar:
            AppBar(title: Text(AppLocalizations.of(context)!.createNewAccount)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(AppLocalizations.of(context)!.loadingRegistrationData),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.createNewAccount),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                for (int i = 0; i < 3; i++) ...[
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: i <= _currentStep
                            ? Theme.of(context).primaryColor
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  if (i < 2) const SizedBox(width: 8),
                ],
              ],
            ),
          ),

          // Step titles
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.basicData,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        _currentStep == 0 ? FontWeight.bold : FontWeight.normal,
                    color: _currentStep == 0
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                  ),
                ),
                Text(
                  AppLocalizations.of(context)!.additionalInfo,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        _currentStep == 1 ? FontWeight.bold : FontWeight.normal,
                    color: _currentStep == 1
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                  ),
                ),
                Text(
                  AppLocalizations.of(context)!.reviewAndConfirm,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        _currentStep == 2 ? FontWeight.bold : FontWeight.normal,
                    color: _currentStep == 2
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Form content
          Expanded(
            child: Form(
              key: _formKey,
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentStep = index;
                  });
                },
                children: [
                  _buildBasicInfoStep(),
                  _buildAdditionalInfoStep(),
                  _buildReviewStep(),
                ],
              ),
            ),
          ),

          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousStep,
                      child: Text(AppLocalizations.of(context)!.previous),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 16),
                Expanded(
                  child: CustomButton(
                    text: _currentStep == 2
                        ? AppLocalizations.of(context)!.createAccount
                        : AppLocalizations.of(context)!.next,
                    onPressed: _currentStep == 2 ? _register : _nextStep,
                    isLoading: _isLoading,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          AppLocalizations.of(context)!.basicData,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 24),

        CustomTextField(
          controller: _nameController,
          label: AppLocalizations.of(context)!.fullName,
          prefixIcon: Icons.person,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppLocalizations.of(context)!.fullNameRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        CustomTextField(
          controller: _usernameController,
          label: AppLocalizations.of(context)!.username,
          prefixIcon: Icons.alternate_email,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppLocalizations.of(context)!.usernameRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        CustomTextField(
          controller: _emailController,
          label: AppLocalizations.of(context)!.email,
          prefixIcon: Icons.email,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppLocalizations.of(context)!.emailRequired;
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return AppLocalizations.of(context)!.invalidEmail;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Phone number with country code
        PhoneInputField(
          controller: _phoneController,
          label: "${AppLocalizations.of(context)!.phoneNumber} (Optional)",
          selectedCountryCode: _selectedPhoneCode,
          countryCodes: _registrationData?.phoneCodes ?? [],
          onCountryCodeChanged: (value) {
            setState(() {
              _selectedPhoneCode = value;
            });
          },
          prefixIcon: Icons.phone,
          validator: (value) {
            // Phone is now optional to comply with Apple policies
            return null;
          },
        ),
        const SizedBox(height: 16),

        CustomTextField(
          controller: _passwordController,
          label: AppLocalizations.of(context)!.password,
          prefixIcon: Icons.lock,
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppLocalizations.of(context)!.passwordRequired;
            }
            if (value.length < 8) {
              return AppLocalizations.of(context)!.passwordMinLength;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        CustomTextField(
          controller: _confirmPasswordController,
          label: AppLocalizations.of(context)!.confirmPassword,
          prefixIcon: Icons.lock_outline,
          obscureText: _obscureConfirmPassword,
          suffixIcon: IconButton(
            icon: Icon(_obscureConfirmPassword
                ? Icons.visibility
                : Icons.visibility_off),
            onPressed: () {
              setState(() {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              });
            },
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppLocalizations.of(context)!.confirmPasswordRequired;
            }
            if (value != _passwordController.text) {
              return AppLocalizations.of(context)!.passwordMismatch;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        CustomTextField(
          controller: _addressController,
          label: AppLocalizations.of(context)!.address,
          prefixIcon: Icons.location_on,
          maxLines: 2,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppLocalizations.of(context)!.addressRequired;
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAdditionalInfoStep() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          AppLocalizations.of(context)!.additionalInfo,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 24),

        // Vehicle selection
        if (_registrationData?.vehicles.isNotEmpty == true) ...[
          Text(
            AppLocalizations.of(context)!.vehicle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),

          CustomDropdown<String>(
            value: _selectedVehicleId,
            items: _registrationData!.vehicles.map((vehicle) {
              return DropdownMenuItem<String>(
                value: vehicle.id.toString(),
                child: Text(vehicle.name),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedVehicleId = value;
                _selectedVehicleTypeId = null;
                _selectedVehicleSizeId = null;

                // Update available types
                if (value != null) {
                  final selectedVehicle = _registrationData!.vehicles
                      .firstWhere((v) => v.id.toString() == value);
                  _availableVehicleTypes = selectedVehicle.types;
                } else {
                  _availableVehicleTypes = [];
                }
                _availableVehicleSizes = [];
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppLocalizations.of(context)!.selectVehicleRequired;
              }
              return null;
            },
            hint: AppLocalizations.of(context)!.selectVehicle,
          ),
          const SizedBox(height: 16),

          // Vehicle type selection
          if (_availableVehicleTypes.isNotEmpty) ...[
            CustomDropdown<String>(
              value: _selectedVehicleTypeId,
              items: _availableVehicleTypes.map((type) {
                return DropdownMenuItem<String>(
                  value: type.id.toString(),
                  child: Text(type.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedVehicleTypeId = value;
                  _selectedVehicleSizeId = null;

                  // Update available sizes
                  if (value != null) {
                    final selectedType = _availableVehicleTypes
                        .firstWhere((t) => t.id.toString() == value);
                    _availableVehicleSizes = selectedType.sizes;
                  } else {
                    _availableVehicleSizes = [];
                  }
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.of(context)!
                      .selectVehicleTypeRequired;
                }
                return null;
              },
              hint: AppLocalizations.of(context)!.selectVehicleType,
            ),
            const SizedBox(height: 16),
          ],

          // Vehicle size selection
          if (_availableVehicleSizes.isNotEmpty) ...[
            CustomDropdown<String>(
              value: _selectedVehicleSizeId,
              items: _availableVehicleSizes.map((size) {
                return DropdownMenuItem<String>(
                  value: size.id.toString(),
                  child: Text(size.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedVehicleSizeId = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.of(context)!
                      .selectVehicleSizeRequired;
                }
                return null;
              },
              hint: AppLocalizations.of(context)!.selectVehicleSize,
            ),
            const SizedBox(height: 16),
          ],
        ],

        // Team selection
        if (_registrationData?.publicTeams.isNotEmpty == true) ...[
          Text(
            AppLocalizations.of(context)!.team,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          CustomDropdown<String>(
            value: _selectedTeamId,
            items: _registrationData!.publicTeams.map((team) {
              return DropdownMenuItem<String>(
                value: team.id.toString(),
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(
                    maxHeight: 60, // تحديد أقصى ارتفاع لتجنب overflow
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          team.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      if (team.address != null && team.address!.isNotEmpty)
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              team.address!,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedTeamId = value;
              });
            },
            hint: AppLocalizations.of(context)!.selectTeamOptional,
          ),
          const SizedBox(height: 24),
        ],

        // WhatsApp section
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.chat, color: Colors.green[600]),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)!.whatsapp,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: Text(AppLocalizations.of(context)!.phoneIsWhatsapp),
                  value: _phoneIsWhatsapp,
                  onChanged: (value) {
                    setState(() {
                      _phoneIsWhatsapp = value ?? false;
                      if (_phoneIsWhatsapp) {
                        _whatsappController.clear();
                        _selectedWhatsappCode = null;
                      }
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),

                // إذا لم يحدد أن الهاتف هو واتساب → يطلب إدخال الرقم
                if (!_phoneIsWhatsapp) ...[
                  const SizedBox(height: 16),
                  PhoneInputField(
                    controller: _whatsappController,
                    label: AppLocalizations.of(context)!.whatsappNumber,
                    selectedCountryCode: _selectedWhatsappCode,
                    countryCodes: _registrationData?.phoneCodes ?? [],
                    onCountryCodeChanged: (value) {
                      setState(() {
                        _selectedWhatsappCode = value;
                      });
                    },
                    prefixIcon: Icons.chat,
                    isWhatsApp: true,
                    validator: (value) {
                      if (!_phoneIsWhatsapp) {
                        if ((value == null || value.isEmpty) ||
                            _selectedWhatsappCode == null) {
                          return AppLocalizations.of(context)!.whatsappRequired;
                        }
                      }
                      return null;
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Dynamic fields from template
        if (_registrationData?.driverFields.isNotEmpty == true) ...[
          Text(
            AppLocalizations.of(context)!.additionalInfoRequired,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          ..._registrationData!.driverFields.map((field) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildDynamicField(field),
            );
          }).toList(),
        ],
      ],
    );
  }

  Widget _buildDynamicField(dynamic field) {
    final fieldName = field.name;
    final fieldLabel = field.label;
    final fieldType = field.type;
    final isRequired = field.required == true || field.required == 1;
    final fieldValue = field.value;

    switch (fieldType) {
      case 'text':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              controller: TextEditingController(
                  text: _additionalFieldsData[fieldName] ?? ''),
              label: fieldLabel + (isRequired ? ' *' : ''),
              onChanged: (value) {
                _additionalFieldsData[fieldName] = value;
              },
              validator: isRequired
                  ? (value) {
                      if (value == null || value.isEmpty) {
                        return '$fieldLabel مطلوب';
                      }
                      return null;
                    }
                  : null,
            ),
          ],
        );

      case 'number':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              controller: TextEditingController(
                  text: _additionalFieldsData[fieldName] ?? ''),
              label: fieldLabel + (isRequired ? ' *' : ''),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _additionalFieldsData[fieldName] = value;
              },
              validator: isRequired
                  ? (value) {
                      if (value == null || value.isEmpty) {
                        return '$fieldLabel مطلوب';
                      }
                      if (double.tryParse(value) == null) {
                        return 'يجب أن يكون رقماً صحيحاً';
                      }
                      return null;
                    }
                  : null,
            ),
          ],
        );

      case 'date':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              label: fieldLabel + (isRequired ? ' *' : ''),
              readOnly: true,
              suffixIcon: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  final dateString =
                      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                  _additionalFieldsData[fieldName] = dateString;
                  setState(() {});
                }
              },
              controller: TextEditingController(
                text: _additionalFieldsData[fieldName] ?? '',
              ),
              validator: isRequired
                  ? (value) {
                      if (value == null || value.isEmpty) {
                        return '$fieldLabel مطلوب';
                      }
                      return null;
                    }
                  : null,
            ),
          ],
        );

      case 'url':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              controller: TextEditingController(
                  text: _additionalFieldsData[fieldName] ?? ''),
              label: fieldLabel + (isRequired ? ' *' : ''),
              keyboardType: TextInputType.url,
              onChanged: (value) {
                _additionalFieldsData[fieldName] = value;
              },
              validator: (value) {
                if (isRequired && (value == null || value.isEmpty)) {
                  return '$fieldLabel مطلوب';
                }
                if (value != null && value.isNotEmpty) {
                  final uri = Uri.tryParse(value);
                  if (uri?.hasAbsolutePath != true) {
                    return 'الرابط غير صحيح';
                  }
                }
                return null;
              },
            ),
          ],
        );

      case 'select':
        // Parse options from JSON (list of maps)
        final List<dynamic> options = fieldValue != null
            ? List<Map<String, dynamic>>.from(jsonDecode(fieldValue))
            : [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomDropdown<String>(
              value: _additionalFieldsData[fieldName],
              items: options.map<DropdownMenuItem<String>>((option) {
                return DropdownMenuItem<String>(
                  value: option['value'], // القيمة الحقيقية
                  child: Text(option['name']), // النص المعروض للمستخدم
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _additionalFieldsData[fieldName] = value;
                });
              },
              label: fieldLabel + (isRequired ? ' *' : ''),
              hint: 'اختر ${fieldLabel.toLowerCase()}',
              validator: isRequired
                  ? (value) {
                      if (value == null || value.isEmpty) {
                        return '$fieldLabel مطلوب';
                      }
                      return null;
                    }
                  : null,
            ),
          ],
        );

      case 'file':
      case 'image':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              fieldLabel + (isRequired ? ' *' : ''),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _pickFile(fieldName, fieldType),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      _additionalFieldsData[fieldName] != null
                          ? Icons.check_circle_outline
                          : Icons.cloud_upload_outlined,
                      size: 48,
                      color: _additionalFieldsData[fieldName] != null
                          ? Colors.green[600]
                          : Colors.grey[600],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _additionalFieldsData[fieldName] != null
                          ? 'تم اختيار الملف'
                          : 'اضغط لاختيار ملف',
                      style: TextStyle(
                        color: _additionalFieldsData[fieldName] != null
                            ? Colors.green[600]
                            : Colors.grey[600],
                        fontWeight: _additionalFieldsData[fieldName] != null
                            ? FontWeight.w500
                            : FontWeight.normal,
                      ),
                    ),
                    if (_additionalFieldsData[fieldName] != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _getFileName(_additionalFieldsData[fieldName]),
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );

      case 'file_expiration_date':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              fieldLabel + (isRequired ? ' *' : ''),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 8),

            // File upload
            InkWell(
              onTap: () => _pickFile(fieldName, 'file'),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      _additionalFieldsData[fieldName] != null
                          ? Icons.check_circle_outline
                          : Icons.cloud_upload_outlined,
                      size: 48,
                      color: _additionalFieldsData[fieldName] != null
                          ? Colors.green[600]
                          : Colors.grey[600],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _additionalFieldsData[fieldName] != null
                          ? 'تم اختيار الملف'
                          : 'اضغط لاختيار ملف',
                      style: TextStyle(
                        color: _additionalFieldsData[fieldName] != null
                            ? Colors.green[600]
                            : Colors.grey[600],
                        fontWeight: _additionalFieldsData[fieldName] != null
                            ? FontWeight.w500
                            : FontWeight.normal,
                      ),
                    ),
                    if (_additionalFieldsData[fieldName] != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _getFileName(_additionalFieldsData[fieldName]),
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Expiration date
            CustomTextField(
              label: (fieldValue ?? '') + (isRequired ? ' *' : ''),
              readOnly: true,
              suffixIcon: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  final dateString =
                      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                  _additionalFieldsData['${fieldName}_expiration'] = dateString;
                  setState(() {});
                }
              },
              controller: TextEditingController(
                text: _additionalFieldsData['${fieldName}_expiration'] ?? '',
              ),
            ),
          ],
        );

      case 'file_with_text':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              fieldLabel + (isRequired ? ' *' : ''),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 8),

            // File upload
            InkWell(
              onTap: () => _pickFile(fieldName, 'file'),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      _additionalFieldsData[fieldName] != null
                          ? Icons.check_circle_outline
                          : Icons.cloud_upload_outlined,
                      size: 48,
                      color: _additionalFieldsData[fieldName] != null
                          ? Colors.green[600]
                          : Colors.grey[600],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _additionalFieldsData[fieldName] != null
                          ? 'تم اختيار الملف'
                          : 'اضغط لاختيار ملف',
                      style: TextStyle(
                        color: _additionalFieldsData[fieldName] != null
                            ? Colors.green[600]
                            : Colors.grey[600],
                        fontWeight: _additionalFieldsData[fieldName] != null
                            ? FontWeight.w500
                            : FontWeight.normal,
                      ),
                    ),
                    if (_additionalFieldsData[fieldName] != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _getFileName(_additionalFieldsData[fieldName]),
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Text field
            CustomTextField(
              label: fieldValue + (isRequired ? ' *' : ''),
              suffixIcon: const Icon(Icons.text_fields_outlined),
              controller: TextEditingController(
                text: _additionalFieldsData['${fieldName}_text'] ?? '',
              ),
              onChanged: (value) {
                _additionalFieldsData['${fieldName}_text'] = value;
              },
            ),
          ],
        );

      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              controller: TextEditingController(
                  text: _additionalFieldsData[fieldName] ?? ''),
              label: fieldLabel + (isRequired ? ' *' : ''),
              onChanged: (value) {
                _additionalFieldsData[fieldName] = value;
              },
              validator: isRequired
                  ? (value) {
                      if (value == null || value.isEmpty) {
                        return '$fieldLabel مطلوب';
                      }
                      return null;
                    }
                  : null,
            ),
          ],
        );
    }
  }

  Widget _buildReviewStep() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          AppLocalizations.of(context)!.reviewAndConfirm,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 24),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.basicData,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                _buildReviewItem(AppLocalizations.of(context)!.fullName,
                    _nameController.text),
                _buildReviewItem(AppLocalizations.of(context)!.username,
                    _usernameController.text),
                _buildReviewItem(
                    AppLocalizations.of(context)!.email, _emailController.text),
                _buildReviewItem(AppLocalizations.of(context)!.phoneNumber,
                    '$_selectedPhoneCode ${_phoneController.text}'),
                _buildReviewItem(AppLocalizations.of(context)!.address,
                    _addressController.text),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        if (_selectedVehicleId != null ||
            _selectedTeamId != null ||
            !_phoneIsWhatsapp) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.additionalInfo,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  if (_selectedVehicleSizeId != null) ...[
                    _buildReviewItem(AppLocalizations.of(context)!.vehicle,
                        _getVehicleDisplayText()),
                  ],
                  if (_selectedTeamId != null) ...[
                    _buildReviewItem(
                        AppLocalizations.of(context)!.team,
                        _registrationData?.publicTeams
                                .firstWhere(
                                    (t) => t.id.toString() == _selectedTeamId)
                                .name ??
                            ''),
                  ],
                  if (!_phoneIsWhatsapp &&
                      _whatsappController.text.isNotEmpty) ...[
                    _buildReviewItem(
                        AppLocalizations.of(context)!.whatsappNumber,
                        '$_selectedWhatsappCode ${_whatsappController.text}'),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        if (_additionalFieldsData.isNotEmpty) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الحقول الإضافية',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  for (final entry in _additionalFieldsData.entries) ...[
                    () {
                      dynamic field;
                      try {
                        field = _registrationData?.driverFields.firstWhere(
                          (f) => f.name == entry.key,
                        );
                      } catch (e) {
                        field = null;
                      }
                      final label = field?.label ?? entry.key;
                      final fieldType = field?.type ?? 'text';
                      return _buildReviewItemForField(
                          label, entry.value, fieldType);
                    }(),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Terms and conditions
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(
                Icons.info_outline,
                color: Theme.of(context).colorScheme.primary,
                size: 32,
              ),
              const SizedBox(height: 12),
              Text(
                AppLocalizations.of(context)!.termsAndPrivacyAgreement,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                AppLocalizations.of(context)!.verificationLinkWillBeSent,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value.isNotEmpty
                  ? value
                  : AppLocalizations.of(context)!.notSpecified,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: value.isNotEmpty ? null : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build review item for files and images
  Widget _buildReviewItemForField(
      String label, dynamic value, String fieldType) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildFieldValueWidget(value, fieldType),
          ),
        ],
      ),
    );
  }

  // Build appropriate widget based on field type and value
  Widget _buildFieldValueWidget(dynamic value, String fieldType) {
    if (value == null) {
      return Text(
        AppLocalizations.of(context)!.notSpecified,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      );
    }

    // Handle PlatformFile (uploaded files/images)
    if (value is PlatformFile) {
      if (fieldType == 'image' || _isImageFile(value.name)) {
        return _buildImagePreview(value);
      } else {
        return _buildFilePreview(value);
      }
    }

    // Handle regular text values
    return Text(
      value.toString().isNotEmpty
          ? value.toString()
          : AppLocalizations.of(context)!.notSpecified,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        color: value.toString().isNotEmpty ? null : Colors.grey,
      ),
    );
  }

  // Check if file is an image based on extension
  bool _isImageFile(String fileName) {
    final imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'];
    final extension = fileName.split('.').last.toLowerCase();
    return imageExtensions.contains(extension);
  }

  // Build image preview widget
  Widget _buildImagePreview(PlatformFile file) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: file.path != null
                ? Image.file(
                    File(file.path!),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[100],
                        child: const Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                          size: 40,
                        ),
                      );
                    },
                  )
                : Container(
                    color: Colors.grey[100],
                    child: const Icon(
                      Icons.image,
                      color: Colors.grey,
                      size: 40,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          file.name,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // Build file preview widget
  Widget _buildFilePreview(PlatformFile file) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color:
                Theme.of(context).colorScheme.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            _getFileIcon(file.name),
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (file.size > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    _formatFileSize(file.size),
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.8),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Get appropriate icon for file type
  IconData _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'txt':
        return Icons.text_snippet;
      case 'csv':
        return Icons.grid_on;
      default:
        return Icons.insert_drive_file;
    }
  }

  // Format file size in human readable format
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  // Pick file for dynamic fields
  Future<void> _pickFile(String fieldName, String fieldType) async {
    try {
      FilePickerResult? result;

      if (fieldType == 'image' || fieldType == 'file') {
        if (fieldType == 'image') {
          result = await FilePicker.platform.pickFiles(
            type: FileType.image,
            allowMultiple: false,
          );
        } else {
          result = await FilePicker.platform.pickFiles(
            type: FileType.any,
            allowMultiple: false,
          );
        }

        if (result != null && result.files.isNotEmpty) {
          final file = result.files.first;
          DebugHelper.log('File picked: ${file.name}, Size: ${file.size}',
              tag: 'REGISTER');

          setState(() {
            _additionalFieldsData[fieldName] = file;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('تم اختيار الملف: ${file.name}'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      }
    } catch (e) {
      DebugHelper.log('Error picking file: $e', tag: 'REGISTER');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('فشل في اختيار الملف'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Get file name from PlatformFile
  String _getFileName(dynamic file) {
    if (file is PlatformFile) {
      return file.name;
    }
    return 'ملف محدد';
  }

  // Get field info by name
  dynamic _getFieldInfo(String fieldName) {
    if (_registrationData?.driverFields != null) {
      try {
        return _registrationData!.driverFields.firstWhere(
          (field) => field.name == fieldName,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Get vehicle display text (Vehicle > Type > Size)
  String _getVehicleDisplayText() {
    if (_selectedVehicleId == null ||
        _selectedVehicleTypeId == null ||
        _selectedVehicleSizeId == null) {
      return '';
    }

    try {
      final vehicle = _registrationData?.vehicles.firstWhere(
        (v) => v.id.toString() == _selectedVehicleId,
      );

      final vehicleType = _availableVehicleTypes.firstWhere(
        (t) => t.id.toString() == _selectedVehicleTypeId,
      );

      final vehicleSize = _availableVehicleSizes.firstWhere(
        (s) => s.id.toString() == _selectedVehicleSizeId,
      );

      return '${vehicle?.name} - ${vehicleType.name} - ${vehicleSize.name}';
    } catch (e) {
      return AppLocalizations.of(context)!.notSpecified;
    }
  }
}
