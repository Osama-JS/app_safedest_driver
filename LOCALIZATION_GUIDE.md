# دليل نظام الترجمة في تطبيق SafeDests Driver

## 📋 نظرة عامة

تم إنشاء نظام ترجمة شامل لتطبيق SafeDests Driver يدعم اللغتين العربية والإنجليزية مع إمكانية إضافة لغات أخرى بسهولة.

## 🏗️ هيكل النظام

### 1. ملفات التكوين

#### `pubspec.yaml`
```yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: 0.20.2

flutter:
  generate: true
```

#### `l10n.yaml`
```yaml
arb-dir: lib/l10n
template-arb-file: app_ar.arb
output-localization-file: app_localizations.dart
output-class: AppLocalizations
output-dir: lib/l10n/generated
```

### 2. ملفات الترجمة

#### `lib/l10n/app_ar.arb` - الترجمة العربية
```json
{
  "@@locale": "ar",
  "appName": "سيف ديستس - السائق",
  "settings": "الإعدادات",
  "language": "لغة التطبيق"
}
```

#### `lib/l10n/app_en.arb` - الترجمة الإنجليزية
```json
{
  "@@locale": "en",
  "appName": "SafeDests - Driver",
  "settings": "Settings",
  "language": "App Language"
}
```

### 3. الملفات المولدة تلقائياً

- `lib/l10n/generated/app_localizations.dart` - الكلاس الأساسي
- `lib/l10n/generated/app_localizations_ar.dart` - الترجمة العربية
- `lib/l10n/generated/app_localizations_en.dart` - الترجمة الإنجليزية

## 🔧 التكوين في التطبيق

### `main.dart`
```dart
import 'l10n/generated/app_localizations.dart';

MaterialApp(
  locale: settingsService.getLocale(),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
)
```

### `settings_service.dart`
```dart
class SettingsService extends ChangeNotifier {
  String _currentLanguage = 'ar'; // اللغة الافتراضية

  Future<void> changeLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
    _currentLanguage = languageCode;
    notifyListeners(); // إعادة بناء التطبيق بالترجمة الجديدة
  }

  Locale getLocale() {
    switch (_currentLanguage) {
      case 'ar': return const Locale('ar', 'SA');
      case 'en': return const Locale('en', 'US');
      default: return const Locale('ar', 'SA');
    }
  }

  bool get isRTL => _currentLanguage == 'ar';
}
```

## 📱 الاستخدام في الشاشات

### الطريقة الصحيحة
```dart
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings), // ✅ استخدام الترجمة
      ),
      body: Column(
        children: [
          Text(l10n.language), // ✅ استخدام الترجمة
          Text(l10n.chooseLanguage), // ✅ استخدام الترجمة
        ],
      ),
    );
  }
}
```

### الطريقة الخاطئة (تجنبها)
```dart
// ❌ لا تستخدم النصوص المباشرة
Text('الإعدادات'), // خطأ
Text('Settings'), // خطأ

// ❌ لا تستخدم الشروط للترجمة
Text(isArabic ? 'الإعدادات' : 'Settings'), // خطأ
```

## 🔄 آلية تغيير اللغة

### 1. في واجهة المستخدم
```dart
InkWell(
  onTap: () => settingsService.changeLanguage('ar'),
  child: Row(
    children: [
      Text('🇸🇦'),
      Text(l10n.arabic),
      if (settingsService.currentLanguage == 'ar')
        Icon(Icons.check_circle),
    ],
  ),
)
```

### 2. التدفق الكامل
1. المستخدم ينقر على خيار اللغة
2. `settingsService.changeLanguage()` يتم استدعاؤها
3. اللغة الجديدة تُحفظ في `SharedPreferences`
4. `notifyListeners()` تُستدعى
5. `Consumer<SettingsService>` يعيد بناء التطبيق
6. `MaterialApp` يحصل على `locale` جديد
7. جميع النصوص تتحدث بالترجمة الجديدة

## 📝 إضافة ترجمات جديدة

### 1. إضافة نص جديد
في `app_ar.arb`:
```json
{
  "newText": "النص الجديد",
  "@newText": {
    "description": "وصف النص الجديد"
  }
}
```

في `app_en.arb`:
```json
{
  "newText": "New Text",
  "@newText": {
    "description": "Description of new text"
  }
}
```

### 2. إعادة توليد الملفات
```bash
flutter packages get
flutter gen-l10n
```

### 3. الاستخدام
```dart
Text(l10n.newText)
```

## 🌍 إضافة لغة جديدة

### 1. إنشاء ملف الترجمة
`lib/l10n/app_fr.arb`:
```json
{
  "@@locale": "fr",
  "appName": "SafeDests - Chauffeur",
  "settings": "Paramètres"
}
```

### 2. تحديث الإعدادات
في `settings_service.dart`:
```dart
Locale getLocale() {
  switch (_currentLanguage) {
    case 'ar': return const Locale('ar', 'SA');
    case 'en': return const Locale('en', 'US');
    case 'fr': return const Locale('fr', 'FR'); // جديد
    default: return const Locale('ar', 'SA');
  }
}
```

### 3. إضافة خيار في الواجهة
```dart
_buildLanguageOption(
  settingsService,
  'Français',
  'fr',
  '🇫🇷',
),
```

## 🚀 الخطوات التالية

### 1. تطبيق النظام على جميع الشاشات
- استبدال جميع النصوص المباشرة بالترجمات
- استخدام `AppLocalizations.of(context)!` في كل شاشة

### 2. إضافة ترجمات شاملة
- ترجمة جميع النصوص في التطبيق
- إضافة رسائل الخطأ والتأكيد
- ترجمة التنبيهات والإشعارات

### 3. اختبار النظام
- اختبار تغيير اللغة في جميع الشاشات
- التأكد من عمل اتجاه النص (RTL/LTR)
- اختبار حفظ واستعادة اللغة المختارة

## 🔍 استكشاف الأخطاء

### مشكلة: `AppLocalizations.of(context)` يعيد null
**الحل**: تأكد من إضافة `AppLocalizations.localizationsDelegates` في `MaterialApp`

### مشكلة: الترجمة لا تتغير فوراً
**الحل**: تأكد من استخدام `Consumer<SettingsService>` أو `Provider.of<SettingsService>(context)`

### مشكلة: النص لا يظهر بالترجمة الصحيحة
**الحل**: تأكد من وجود الترجمة في ملفات `.arb` وإعادة توليد الملفات

## 📚 مراجع مفيدة

- [Flutter Internationalization Guide](https://docs.flutter.dev/development/accessibility-and-localization/internationalization)
- [ARB File Format](https://github.com/google/app-resource-bundle/wiki/ApplicationResourceBundleSpecification)
- [Intl Package Documentation](https://pub.dev/packages/intl)

---

**ملاحظة**: هذا النظام يوفر أساساً قوياً لترجمة التطبيق ويمكن توسيعه بسهولة لإضافة المزيد من اللغات والترجمات.
