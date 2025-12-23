import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../shared_prff.dart';
import '../Languages/LanguageController.dart';

class SettingsController extends GetxController {
  // Reactive state
  final RxString currentLanguage = 'ar'.obs;
  final Rx<ThemeMode> themeMode = ThemeMode.light.obs;
  final RxBool taskNotificationsEnabled = true.obs;
  final RxBool walletNotificationsEnabled = true.obs;
  final RxBool systemNotificationsEnabled = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  void _loadSettings() {
    currentLanguage.value = Selected_Language.getLanguage() ?? 'ar';

    final theme = Theme_pref.getTheme();
    if (theme != null) {
      themeMode.value = theme == 1 ? ThemeMode.dark : ThemeMode.light;
    }

    taskNotificationsEnabled.value = Bool_pref.getBool('task_notifications') ?? true;
    walletNotificationsEnabled.value = Bool_pref.getBool('wallet_notifications') ?? true;
    systemNotificationsEnabled.value = Bool_pref.getBool('system_notifications') ?? true;
  }

  // Change language
  Future<void> changeLanguage(String langCode) async {
    if (currentLanguage.value == langCode) return;

    // Use LanguageController for consistency
    final languageController = Get.find<LanguageController>();
    languageController.changeLanguage(langCode);

    // Update current language value
    currentLanguage.value = langCode;
  }

  // Change theme
  Future<void> toggleTheme(bool isDark) async {
    final mode = isDark ? ThemeMode.dark : ThemeMode.light;
    await Theme_pref.setTheme(isDark ? 1 : 0);
    themeMode.value = mode;
    Get.changeThemeMode(mode);
  }

  // Update notification settings
  Future<void> setNotificationSetting(String key, bool enabled) async {
    await Bool_pref.setBool(key, enabled);
    if (key == 'task_notifications') taskNotificationsEnabled.value = enabled;
    if (key == 'wallet_notifications') walletNotificationsEnabled.value = enabled;
    if (key == 'system_notifications') systemNotificationsEnabled.value = enabled;
  }

  // Check if RTL
  bool get isRTL => currentLanguage.value == 'ar' || currentLanguage.value == 'ur';
}
