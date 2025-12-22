import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controllers/SettingsController.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsController settingsController = Get.find<SettingsController>();

    return Obx(() {
      final isArabic = settingsController.currentLanguage.value == 'ar';

      return Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).primaryColor,
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => _changeLanguage(settingsController),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                isArabic ? 'English' : 'عربي',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  void _changeLanguage(SettingsController settingsController) {
    final isArabic = settingsController.currentLanguage.value == 'ar';
    final newLanguageCode = isArabic ? 'en' : 'ar';

    // Change language directly without confirmation
    settingsController.changeLanguage(newLanguageCode);
  }
}
