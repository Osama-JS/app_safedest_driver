import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controllers/WalletController.dart';

class WithdrawBottomSheet extends StatefulWidget {
  const WithdrawBottomSheet({super.key});

  @override
  State<WithdrawBottomSheet> createState() => _WithdrawBottomSheetState();
}

class _WithdrawBottomSheetState extends State<WithdrawBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final WalletController _walletController = Get.find<WalletController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                   Icon(Icons.account_balance_wallet_outlined, color: Theme.of(context).colorScheme.primary),
                   const SizedBox(width: 10),
                   Text(
                    'request_cash_withdrawal'.tr,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'withdrawal_desc'.tr,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              const SizedBox(height: 25),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'withdraw_limit_error'.tr,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              Text(
                '${'current_balance'.tr}: ${_walletController.currentBalance.toStringAsFixed(2)} ${_walletController.currency}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'withdraw_amount'.tr,
                  hintText: 'enter_amount'.tr,
                  suffixText: _walletController.currency,
                  prefixIcon: const Icon(Icons.attach_money),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'enter_amount'.tr;
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) return 'enter_valid_price'.tr;
                  if (amount > _walletController.currentBalance) return 'insufficient_balance'.tr;
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: 'withdrawal_notes'.tr,
                  prefixIcon: const Icon(Icons.note_alt_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: Obx(() => ElevatedButton(
                  onPressed: _walletController.isWithdrawLoading.value ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _walletController.isWithdrawLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'send_withdrawal_request'.tr,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text);
      final success = await _walletController.requestWithdrawal(amount, notes: _notesController.text);
      if (success) {
        Get.back();
        Get.snackbar(
          'successTitle'.tr,
          'task_assigned_successfully'.tr, // Reusing a success message or I could add a specific one
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          margin: const EdgeInsets.all(15),
          borderRadius: 10,
        );
      } else {
        Get.snackbar(
          'errorTitle'.tr,
          _walletController.errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: const EdgeInsets.all(15),
          borderRadius: 10,
        );
      }
    }
  }
}
