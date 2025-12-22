import 'dart:ui';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageController extends GetxController {
  Locale selectedLang = const Locale('ar', 'SA');

  @override
  void onInit() {
    super.onInit();
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLang = prefs.getString('language');
    if (savedLang != null) {
      selectedLang = Locale(savedLang);
      Get.updateLocale(selectedLang);
    }
  }

  Future<void> changeLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', languageCode);

    Locale newLocale = Locale(languageCode);
    selectedLang = newLocale;
    Get.updateLocale(newLocale);
  }
}
