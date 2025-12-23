import 'dart:ui';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../shared_prff.dart';

class LanguageController extends GetxController {
  // Make selectedLang reactive but initialize it immediately
  final Rx<Locale> _selectedLang = _getInitialLocale().obs;

  Locale get selectedLang => _selectedLang.value;

  // Static method to get initial locale
  static Locale _getInitialLocale() {
    final savedLang = Selected_Language.getLanguage();
    debugPrint('🌍 Loading initial language: $savedLang');

    if (savedLang == null || savedLang.isEmpty) {
      debugPrint('🌍 No saved language, using default: en');
      return const Locale('en', 'US');
    }

    Locale locale;
    switch (savedLang) {
      case 'ar':
        locale = const Locale('ar', 'SA');
        break;
      case 'en':
        locale = const Locale('en', 'US');
        break;
      case 'ur':
        locale = const Locale('ur', 'PK');
        break;
      case 'zh':
        locale = const Locale('zh', 'CN');
        break;
      default:
        locale = const Locale('en', 'US');
    }

    debugPrint('🌍 Initial locale set to: ${locale.languageCode}');
    return locale;
  }

  void changeLanguage(String languageCode) {
    debugPrint('🌍 Changing language to: $languageCode');

    Locale newLocale;
    switch (languageCode) {
      case 'ar':
        newLocale = const Locale('ar', 'SA');
        break;
      case 'en':
        newLocale = const Locale('en', 'US');
        break;
      case 'ur':
        newLocale = const Locale('ur', 'PK');
        break;
      case 'zh':
        newLocale = const Locale('zh', 'CN');
        break;
      default:
        newLocale = const Locale('en', 'US');
    }

    Selected_Language.setLanguage(languageCode);
    _selectedLang.value = newLocale;
    Get.updateLocale(newLocale);
    update(); // Notify GetBuilder widgets
    debugPrint('🌍 Language changed to: ${newLocale.languageCode}');
  }
}
