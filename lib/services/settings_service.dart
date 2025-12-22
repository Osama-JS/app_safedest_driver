import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService extends ChangeNotifier {
  static const String _languageKey = 'app_language';
  static const String _themeModeKey = 'theme_mode';
  static const String _taskNotificationsKey = 'task_notifications';
  static const String _walletNotificationsKey = 'wallet_notifications';
  static const String _systemNotificationsKey = 'system_notifications';

  // Default values
  String _currentLanguage = 'ar';
  ThemeMode _themeMode = ThemeMode.light;
  bool _taskNotificationsEnabled = true;
  bool _walletNotificationsEnabled = true;
  bool _systemNotificationsEnabled = true;

  // Getters
  String get currentLanguage => _currentLanguage;
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get taskNotificationsEnabled => _taskNotificationsEnabled;
  bool get walletNotificationsEnabled => _walletNotificationsEnabled;
  bool get systemNotificationsEnabled => _systemNotificationsEnabled;

  /// Initialize settings from SharedPreferences
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      _currentLanguage = prefs.getString(_languageKey) ?? 'ar';

      final themeModeIndex =
          prefs.getInt(_themeModeKey) ?? ThemeMode.system.index;
      _themeMode = ThemeMode.values[themeModeIndex];

      _taskNotificationsEnabled = prefs.getBool(_taskNotificationsKey) ?? true;
      _walletNotificationsEnabled =
          prefs.getBool(_walletNotificationsKey) ?? true;
      _systemNotificationsEnabled =
          prefs.getBool(_systemNotificationsKey) ?? true;

      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing settings: $e');
    }
  }

  /// Change app language
  Future<void> changeLanguage(String languageCode) async {
    if (_currentLanguage == languageCode) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);

      _currentLanguage = languageCode;
      notifyListeners();

      debugPrint('Language changed to: $languageCode');
    } catch (e) {
      debugPrint('Error changing language: $e');
    }
  }

  /// Change theme mode
  Future<void> changeThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeModeKey, mode.index);

      _themeMode = mode;
      notifyListeners();

      debugPrint('Theme mode changed to: $mode');
    } catch (e) {
      debugPrint('Error changing theme mode: $e');
    }
  }

  /// Set task notifications
  Future<void> setTaskNotifications(bool enabled) async {
    if (_taskNotificationsEnabled == enabled) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_taskNotificationsKey, enabled);

      _taskNotificationsEnabled = enabled;
      notifyListeners();

      debugPrint('Task notifications ${enabled ? 'enabled' : 'disabled'}');
    } catch (e) {
      debugPrint('Error setting task notifications: $e');
    }
  }

  /// Set wallet notifications
  Future<void> setWalletNotifications(bool enabled) async {
    if (_walletNotificationsEnabled == enabled) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_walletNotificationsKey, enabled);

      _walletNotificationsEnabled = enabled;
      notifyListeners();

      debugPrint('Wallet notifications ${enabled ? 'enabled' : 'disabled'}');
    } catch (e) {
      debugPrint('Error setting wallet notifications: $e');
    }
  }

  /// Set system notifications
  Future<void> setSystemNotifications(bool enabled) async {
    if (_systemNotificationsEnabled == enabled) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_systemNotificationsKey, enabled);

      _systemNotificationsEnabled = enabled;
      notifyListeners();

      debugPrint('System notifications ${enabled ? 'enabled' : 'disabled'}');
    } catch (e) {
      debugPrint('Error setting system notifications: $e');
    }
  }

  /// Reset all settings to defaults
  Future<void> resetToDefaults() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Remove all settings keys
      await prefs.remove(_languageKey);
      await prefs.remove(_themeModeKey);
      await prefs.remove(_taskNotificationsKey);
      await prefs.remove(_walletNotificationsKey);
      await prefs.remove(_systemNotificationsKey);

      // Reset to defaults
      _currentLanguage = 'ar';
      _themeMode = ThemeMode.light;
      _taskNotificationsEnabled = true;
      _walletNotificationsEnabled = true;
      _systemNotificationsEnabled = true;

      notifyListeners();

      debugPrint('Settings reset to defaults');
    } catch (e) {
      debugPrint('Error resetting settings: $e');
    }
  }

  /// Get locale from language code
  Locale getLocale() {
    switch (_currentLanguage) {
      case 'ar':
        return const Locale('ar', 'SA');
      case 'en':
        return const Locale('en', 'US');
      case 'ur':
        return const Locale('ur', 'PK');
      case 'zh':
        return const Locale('zh', 'CN');
      default:
        return const Locale('ar', 'SA');
    }
  }

  /// Check if current language is RTL
  bool get isRTL => _currentLanguage == 'ar';

  /// Get language display name
  String getLanguageDisplayName() {
    switch (_currentLanguage) {
      case 'ar':
        return 'العربية';
      case 'en':
        return 'English';
      case 'ur':
        return 'اردو';
      case 'zh':
        return '中文';
      default:
        return 'العربية';
    }
  }

  /// Get theme mode display name
  String getThemeModeDisplayName() {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'الوضع الفاتح';
      case ThemeMode.dark:
        return 'الوضع الداكن';
      case ThemeMode.system:
        return 'تلقائي (حسب النظام)';
    }
  }

  /// Export settings as JSON
  Map<String, dynamic> exportSettings() {
    return {
      'language': _currentLanguage,
      'theme_mode': _themeMode.index,
      'task_notifications': _taskNotificationsEnabled,
      'wallet_notifications': _walletNotificationsEnabled,
      'system_notifications': _systemNotificationsEnabled,
    };
  }

  /// Import settings from JSON
  Future<void> importSettings(Map<String, dynamic> settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (settings.containsKey('language')) {
        final language = settings['language'] as String;
        await prefs.setString(_languageKey, language);
        _currentLanguage = language;
      }

      if (settings.containsKey('theme_mode')) {
        final themeModeIndex = settings['theme_mode'] as int;
        await prefs.setInt(_themeModeKey, themeModeIndex);
        _themeMode = ThemeMode.values[themeModeIndex];
      }

      if (settings.containsKey('task_notifications')) {
        final enabled = settings['task_notifications'] as bool;
        await prefs.setBool(_taskNotificationsKey, enabled);
        _taskNotificationsEnabled = enabled;
      }

      if (settings.containsKey('wallet_notifications')) {
        final enabled = settings['wallet_notifications'] as bool;
        await prefs.setBool(_walletNotificationsKey, enabled);
        _walletNotificationsEnabled = enabled;
      }

      if (settings.containsKey('system_notifications')) {
        final enabled = settings['system_notifications'] as bool;
        await prefs.setBool(_systemNotificationsKey, enabled);
        _systemNotificationsEnabled = enabled;
      }

      notifyListeners();

      debugPrint('Settings imported successfully');
    } catch (e) {
      debugPrint('Error importing settings: $e');
    }
  }
}
