import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../models/driver.dart';

class BankDetailsBottomSheet extends StatefulWidget {
  const BankDetailsBottomSheet({super.key});

  @override
  State<BankDetailsBottomSheet> createState() => _BankDetailsBottomSheetState();
}

class _BankDetailsBottomSheetState extends State<BankDetailsBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _bankNameController;
  late TextEditingController _accountNumberController;
  late TextEditingController _ibanController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final driver = Provider.of<AuthService>(context, listen: false).currentDriver;
    _bankNameController = TextEditingController(text: driver?.bankName);
    _accountNumberController = TextEditingController(text: driver?.accountNumber);
    _ibanController = TextEditingController(text: driver?.ibanNumber);
  }

  @override
  void dispose() {
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _ibanController.dispose();
    super.dispose();
  }

  Future<void> _saveDetails() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final response = await authService.updateBankDetails(
        bankName: _bankNameController.text.trim(),
        accountNumber: _accountNumberController.text.trim(),
        ibanNumber: _ibanController.text.trim(),
      );

      if (response.isSuccess) {
        Get.back(result: true);
        Get.snackbar('success'.tr, 'bank_details_saved'.tr,
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
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
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
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title
              Text(
                'bank_details'.tr,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),

              const SizedBox(height: 24),

              // Bank Name
              TextFormField(
                controller: _bankNameController,
                decoration: InputDecoration(
                  labelText: 'bank_name'.tr,
                  hintText: 'enter_bank_name'.tr,
                  prefixIcon: const Icon(Icons.account_balance),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'field_required'.tr;
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Account Number
              TextFormField(
                controller: _accountNumberController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'account_number'.tr,
                  hintText: 'enter_account_number'.tr,
                  prefixIcon: const Icon(Icons.numbers),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'field_required'.tr;
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // IBAN
              TextFormField(
                controller: _ibanController,
                decoration: InputDecoration(
                  labelText: 'iban'.tr,
                  hintText: 'enter_iban'.tr,
                  prefixIcon: const Icon(Icons.credit_card),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'field_required'.tr;
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveDetails,
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

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
