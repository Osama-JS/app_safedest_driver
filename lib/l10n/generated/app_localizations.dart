import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// اسم التطبيق
  ///
  /// In ar, this message translates to:
  /// **'سيف ديستس - السائق'**
  String get appName;

  /// عنوان شاشة الإعدادات
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settings;

  /// قسم إعدادات التطبيق
  ///
  /// In ar, this message translates to:
  /// **'إعدادات التطبيق'**
  String get appSettings;

  /// إعداد اللغة
  ///
  /// In ar, this message translates to:
  /// **'لغة التطبيق'**
  String get language;

  /// وصف إعداد اللغة
  ///
  /// In ar, this message translates to:
  /// **'اختر لغة واجهة التطبيق'**
  String get chooseLanguage;

  /// اللغة العربية
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// اللغة الإنجليزية
  ///
  /// In ar, this message translates to:
  /// **'English'**
  String get english;

  /// إعداد المظهر
  ///
  /// In ar, this message translates to:
  /// **'مظهر التطبيق'**
  String get theme;

  /// وصف إعداد المظهر
  ///
  /// In ar, this message translates to:
  /// **'اختر بين الوضع الفاتح والداكن'**
  String get chooseTheme;

  /// الوضع الفاتح
  ///
  /// In ar, this message translates to:
  /// **'الوضع الفاتح'**
  String get lightMode;

  /// الوضع الداكن
  ///
  /// In ar, this message translates to:
  /// **'الوضع الداكن'**
  String get darkMode;

  /// الوضع التلقائي
  ///
  /// In ar, this message translates to:
  /// **'تلقائي (حسب النظام)'**
  String get systemMode;

  /// قسم الإشعارات
  ///
  /// In ar, this message translates to:
  /// **'إعدادات الإشعارات'**
  String get notifications;

  /// إشعارات المهام
  ///
  /// In ar, this message translates to:
  /// **'إشعارات المهام'**
  String get taskNotifications;

  /// وصف إشعارات المهام
  ///
  /// In ar, this message translates to:
  /// **'تلقي إشعارات عند وصول مهام جديدة'**
  String get taskNotificationsDesc;

  /// إشعارات المحفظة
  ///
  /// In ar, this message translates to:
  /// **'إشعارات المحفظة'**
  String get walletNotifications;

  /// وصف إشعارات المحفظة
  ///
  /// In ar, this message translates to:
  /// **'تلقي إشعارات عند تحديث المحفظة'**
  String get walletNotificationsDesc;

  /// إشعارات النظام
  ///
  /// In ar, this message translates to:
  /// **'إشعارات النظام'**
  String get systemNotifications;

  /// وصف إشعارات النظام
  ///
  /// In ar, this message translates to:
  /// **'تلقي إشعارات النظام والتحديثات'**
  String get systemNotificationsDesc;

  /// قسم حول التطبيق
  ///
  /// In ar, this message translates to:
  /// **'حول التطبيق'**
  String get about;

  /// إصدار التطبيق
  ///
  /// In ar, this message translates to:
  /// **'الإصدار'**
  String get version;

  /// شروط الاستخدام
  ///
  /// In ar, this message translates to:
  /// **'شروط الاستخدام'**
  String get termsOfService;

  /// وصف شروط الاستخدام
  ///
  /// In ar, this message translates to:
  /// **'اقرأ شروط استخدام التطبيق'**
  String get termsOfServiceDesc;

  /// سياسة الخصوصية
  ///
  /// In ar, this message translates to:
  /// **'سياسة الخصوصية'**
  String get privacyPolicy;

  /// وصف سياسة الخصوصية
  ///
  /// In ar, this message translates to:
  /// **'اقرأ سياسة الخصوصية'**
  String get privacyPolicyDesc;

  /// المساعدة والدعم
  ///
  /// In ar, this message translates to:
  /// **'المساعدة والدعم'**
  String get helpSupport;

  /// وصف المساعدة والدعم
  ///
  /// In ar, this message translates to:
  /// **'الحصول على المساعدة'**
  String get helpSupportDesc;

  /// إعادة تعيين الإعدادات
  ///
  /// In ar, this message translates to:
  /// **'إعادة تعيين الإعدادات'**
  String get resetSettings;

  /// وصف إعادة تعيين الإعدادات
  ///
  /// In ar, this message translates to:
  /// **'إعادة جميع الإعدادات إلى القيم الافتراضية'**
  String get resetSettingsDesc;

  /// زر إعادة التعيين
  ///
  /// In ar, this message translates to:
  /// **'إعادة تعيين'**
  String get reset;

  /// زر الإلغاء
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// زر التأكيد
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get confirm;

  /// عنوان تأكيد إعادة التعيين
  ///
  /// In ar, this message translates to:
  /// **'إعادة تعيين الإعدادات'**
  String get resetConfirmTitle;

  /// رسالة تأكيد إعادة التعيين
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من أنك تريد إعادة جميع الإعدادات إلى القيم الافتراضية؟\n\nلا يمكن التراجع عن هذا الإجراء.'**
  String get resetConfirmMessage;

  /// رسالة نجاح إعادة التعيين
  ///
  /// In ar, this message translates to:
  /// **'تم إعادة تعيين الإعدادات بنجاح'**
  String get resetSuccess;

  /// تبويب الشاشة الرئيسية
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get home;

  /// تبويب المهام
  ///
  /// In ar, this message translates to:
  /// **'المهام'**
  String get tasks;

  /// تبويب المحفظة
  ///
  /// In ar, this message translates to:
  /// **'المحفظة'**
  String get wallet;

  /// تبويب الملف الشخصي
  ///
  /// In ar, this message translates to:
  /// **'الملف الشخصي'**
  String get profile;

  /// رسالة الترحيب بالسائق
  ///
  /// In ar, this message translates to:
  /// **'مرحباً {driverName}'**
  String welcomeDriver(String driverName);

  /// كلمة سائق
  ///
  /// In ar, this message translates to:
  /// **'سائق'**
  String get driver;

  /// رسالة نجاح تحديث البيانات
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث البيانات بنجاح'**
  String get dataRefreshSuccess;

  /// رسالة فشل تحديث البيانات
  ///
  /// In ar, this message translates to:
  /// **'فشل في تحديث البيانات'**
  String get dataRefreshFailed;

  /// عنوان قسم إعلانات المهام
  ///
  /// In ar, this message translates to:
  /// **'إعلانات المهام'**
  String get taskAds;

  /// وصف قسم إعلانات المهام
  ///
  /// In ar, this message translates to:
  /// **'تصفح الإعلانات المتاحة وقدم عروضك'**
  String get taskAdsDescription;

  /// عدد الإعلانات المتاحة
  ///
  /// In ar, this message translates to:
  /// **'الإعلانات المتاحة'**
  String get availableAds;

  /// عدد العروض المقدمة
  ///
  /// In ar, this message translates to:
  /// **'عروضي المقدمة'**
  String get myOffers;

  /// عدد العروض المقبولة
  ///
  /// In ar, this message translates to:
  /// **'العروض المقبولة'**
  String get acceptedOffers;

  /// زر تصفح الإعلانات
  ///
  /// In ar, this message translates to:
  /// **'تصفح الإعلانات'**
  String get browseAds;

  /// رسالة الإشعارات قريباً
  ///
  /// In ar, this message translates to:
  /// **'شاشة الإشعارات قريباً'**
  String get notificationsComingSoon;

  /// عنوان تأكيد الخروج
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الخروج'**
  String get exitConfirmation;

  /// رسالة تأكيد الخروج
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من أنك تريد الخروج من التطبيق؟'**
  String get exitConfirmMessage;

  /// وصف تأكيد الخروج
  ///
  /// In ar, this message translates to:
  /// **'سيتم إغلاق التطبيق نهائياً.'**
  String get exitConfirmDescription;

  /// زر الخروج
  ///
  /// In ar, this message translates to:
  /// **'خروج'**
  String get exit;

  /// تلميح تحديث المهام
  ///
  /// In ar, this message translates to:
  /// **'تحديث المهام'**
  String get refreshTasks;

  /// تبويب المهام المتاحة
  ///
  /// In ar, this message translates to:
  /// **'المتاحة'**
  String get availableTasks;

  /// تبويب المهام الحالية
  ///
  /// In ar, this message translates to:
  /// **'الحالية'**
  String get currentTasks;

  /// تبويب المهام المكتملة
  ///
  /// In ar, this message translates to:
  /// **'المكتملة'**
  String get completedTasks;

  /// رسالة تحميل المهام
  ///
  /// In ar, this message translates to:
  /// **'جاري تحميل المهام...'**
  String get loadingTasks;

  /// رسالة خطأ غير متوقع
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ غير متوقع'**
  String get unexpectedError;

  /// زر إعادة المحاولة
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get retry;

  /// رسالة عدم وجود مهام متاحة
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مهام متاحة'**
  String get noAvailableTasks;

  /// وصف عدم وجود مهام متاحة
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مهام متاحة للقبول في الوقت الحالي'**
  String get noAvailableTasksDescription;

  /// رسالة عدم وجود مهام حالية
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مهام حالية'**
  String get noCurrentTasks;

  /// رسالة عدم وجود مهام مكتملة
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مهام مكتملة'**
  String get noCompletedTasks;

  /// رسالة نجاح قبول المهمة
  ///
  /// In ar, this message translates to:
  /// **'تم قبول المهمة بنجاح'**
  String get taskAcceptedSuccess;

  /// رسالة رفض المهمة
  ///
  /// In ar, this message translates to:
  /// **'تم رفض المهمة'**
  String get taskRejected;

  /// رسالة تحديث حالة المهمة
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث حالة المهمة'**
  String get taskStatusUpdated;

  /// تلميح سجل المعاملات
  ///
  /// In ar, this message translates to:
  /// **'سجل المعاملات'**
  String get transactionHistory;

  /// عنوان الإجراءات السريعة
  ///
  /// In ar, this message translates to:
  /// **'إجراءات سريعة'**
  String get quickActions;

  /// نوع معاملة سحب نقدي
  ///
  /// In ar, this message translates to:
  /// **'سحب نقدي'**
  String get cashWithdrawal;

  /// زر كشف الحساب
  ///
  /// In ar, this message translates to:
  /// **'كشف حساب'**
  String get accountStatement;

  /// زر الدعم
  ///
  /// In ar, this message translates to:
  /// **'الدعم'**
  String get support;

  /// رسالة السحب النقدي قريباً
  ///
  /// In ar, this message translates to:
  /// **'ميزة السحب النقدي قريباً'**
  String get withdrawalComingSoon;

  /// رسالة كشف الحساب قريباً
  ///
  /// In ar, this message translates to:
  /// **'كشف الحساب قريباً'**
  String get statementComingSoon;

  /// رسالة الدعم الفني قريباً
  ///
  /// In ar, this message translates to:
  /// **'الدعم الفني قريباً'**
  String get supportComingSoon;

  /// رسالة عدم وجود بيانات السائق
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بيانات للسائق'**
  String get noDriverData;

  /// حالة السائق النشط
  ///
  /// In ar, this message translates to:
  /// **'نشط'**
  String get active;

  /// حالة السائق غير النشط
  ///
  /// In ar, this message translates to:
  /// **'غير نشط'**
  String get inactive;

  /// حالة الاتصال
  ///
  /// In ar, this message translates to:
  /// **'متصل'**
  String get online;

  /// حالة عدم الاتصال
  ///
  /// In ar, this message translates to:
  /// **'غير متصل'**
  String get offline;

  /// عنوان معلومات الحساب
  ///
  /// In ar, this message translates to:
  /// **'معلومات الحساب'**
  String get accountInfo;

  /// تسمية البريد الإلكتروني
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get email;

  /// تسمية رقم الهاتف
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف'**
  String get phone;

  /// تسمية العنوان
  ///
  /// In ar, this message translates to:
  /// **'العنوان'**
  String get address;

  /// تسمية الفريق
  ///
  /// In ar, this message translates to:
  /// **'الفريق'**
  String get team;

  /// تسمية حجم المركبة
  ///
  /// In ar, this message translates to:
  /// **'حجم المركبة'**
  String get vehicleSize;

  /// عنوان البيانات الإضافية
  ///
  /// In ar, this message translates to:
  /// **'البيانات الإضافية'**
  String get additionalData;

  /// وصف البيانات الإضافية
  ///
  /// In ar, this message translates to:
  /// **'عرض المعلومات التكميلية'**
  String get additionalDataDescription;

  /// عنوان تشخيص النظام
  ///
  /// In ar, this message translates to:
  /// **'تشخيص النظام'**
  String get systemDiagnostics;

  /// وصف تشخيص النظام
  ///
  /// In ar, this message translates to:
  /// **'فحص حالة التطبيق والاتصالات'**
  String get systemDiagnosticsDescription;

  /// زر تسجيل الخروج
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get logout;

  /// رسالة جاري تسجيل الخروج
  ///
  /// In ar, this message translates to:
  /// **'جاري تسجيل الخروج...'**
  String get loggingOut;

  /// عنوان تأكيد تسجيل الخروج
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get logoutConfirmation;

  /// رسالة تأكيد تسجيل الخروج
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من رغبتك في تسجيل الخروج؟'**
  String get logoutConfirmMessage;

  /// اسم التطبيق
  ///
  /// In ar, this message translates to:
  /// **'تطبيق SafeDests للسائقين'**
  String get safeDriveApp;

  /// وصف التطبيق
  ///
  /// In ar, this message translates to:
  /// **'تطبيق مخصص لإدارة المهام والتوصيل للسائقين'**
  String get appDescription;

  /// عنوان حالة السائق
  ///
  /// In ar, this message translates to:
  /// **'حالة السائق'**
  String get driverStatus;

  /// حالة الاتصال
  ///
  /// In ar, this message translates to:
  /// **'متصل'**
  String get connected;

  /// حالة عدم الاتصال
  ///
  /// In ar, this message translates to:
  /// **'غير متصل'**
  String get disconnected;

  /// حالة متاح للمهام
  ///
  /// In ar, this message translates to:
  /// **'متاح للمهام'**
  String get availableForTasks;

  /// حالة مشغول
  ///
  /// In ar, this message translates to:
  /// **'مشغول'**
  String get busy;

  /// زر تعيين كمشغول
  ///
  /// In ar, this message translates to:
  /// **'تعيين كمشغول'**
  String get setBusy;

  /// زر تعيين كمتاح
  ///
  /// In ar, this message translates to:
  /// **'تعيين كمتاح'**
  String get setAvailable;

  /// تسمية الاسم
  ///
  /// In ar, this message translates to:
  /// **'الاسم'**
  String get name;

  /// تسمية الحالة
  ///
  /// In ar, this message translates to:
  /// **'الحالة'**
  String get status;

  /// تسمية نوع المركبة
  ///
  /// In ar, this message translates to:
  /// **'نوع المركبة'**
  String get vehicleType;

  /// قيمة غير محدد
  ///
  /// In ar, this message translates to:
  /// **'غير محدد'**
  String get notSpecified;

  /// عنوان إحصائيات الأرباح
  ///
  /// In ar, this message translates to:
  /// **'إحصائيات الأرباح'**
  String get earningsStatistics;

  /// فترة اليوم
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get today;

  /// فترة الأسبوع
  ///
  /// In ar, this message translates to:
  /// **'الأسبوع'**
  String get week;

  /// فترة الشهر
  ///
  /// In ar, this message translates to:
  /// **'الشهر'**
  String get month;

  /// فترة السنة
  ///
  /// In ar, this message translates to:
  /// **'السنة'**
  String get year;

  /// رسالة اختيار الفترة
  ///
  /// In ar, this message translates to:
  /// **'تم اختيار فترة: {period}'**
  String periodSelected(String period);

  /// عنوان الرسم البياني للأرباح
  ///
  /// In ar, this message translates to:
  /// **'الرسم البياني للأرباح'**
  String get earningsChart;

  /// رسالة قريباً
  ///
  /// In ar, this message translates to:
  /// **'قريباً'**
  String get comingSoon;

  /// تسمية أعلى ربح
  ///
  /// In ar, this message translates to:
  /// **'أعلى ربح'**
  String get highestEarning;

  /// تسمية المتوسط اليومي
  ///
  /// In ar, this message translates to:
  /// **'متوسط يومي'**
  String get dailyAverage;

  /// تسمية إجمالي الأرباح
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الأرباح'**
  String get totalEarnings;

  /// رسالة عدم وجود معاملات
  ///
  /// In ar, this message translates to:
  /// **'لا توجد معاملات مالية بعد'**
  String get noTransactionsYet;

  /// عنوان ملخص الأرباح
  ///
  /// In ar, this message translates to:
  /// **'ملخص الأرباح'**
  String get earningsSummary;

  /// زر التفاصيل
  ///
  /// In ar, this message translates to:
  /// **'التفاصيل'**
  String get details;

  /// رسالة تفاصيل الأرباح قريباً
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الأرباح قريباً'**
  String get earningsDetailsComingSoon;

  /// رسالة عدم وجود بيانات أرباح
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بيانات أرباح حالياً'**
  String get noEarningsData;

  /// فترة هذا الشهر
  ///
  /// In ar, this message translates to:
  /// **'هذا الشهر'**
  String get thisMonth;

  /// تسمية عدد المهام
  ///
  /// In ar, this message translates to:
  /// **'عدد المهام'**
  String get totalTasks;

  /// تسمية متوسط الربح لكل مهمة
  ///
  /// In ar, this message translates to:
  /// **'متوسط الربح لكل مهمة'**
  String get averageEarningPerTask;

  /// تسمية إجمالي الفترة
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الفترة'**
  String get totalPeriod;

  /// رسالة حدوث خطأ
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ: {error}'**
  String errorOccurred(String error);

  /// عنوان الإحصائيات السريعة
  ///
  /// In ar, this message translates to:
  /// **'إحصائيات سريعة'**
  String get quickStats;

  /// تسمية المهام النشطة
  ///
  /// In ar, this message translates to:
  /// **'المهام النشطة'**
  String get activeTasks;

  /// تسمية الرصيد الحالي
  ///
  /// In ar, this message translates to:
  /// **'الرصيد الحالي'**
  String get currentBalance;

  /// عنوان المهام الأخيرة
  ///
  /// In ar, this message translates to:
  /// **'المهام الأخيرة'**
  String get recentTasks;

  /// زر عرض الكل
  ///
  /// In ar, this message translates to:
  /// **'عرض الكل'**
  String get viewAll;

  /// رسالة عرض جميع المهام
  ///
  /// In ar, this message translates to:
  /// **'عرض جميع المهام'**
  String get viewAllTasks;

  /// رسالة عدم وجود مهام
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مهام حالياً'**
  String get noTasksCurrently;

  /// رقم المهمة
  ///
  /// In ar, this message translates to:
  /// **'مهمة #{taskId}'**
  String taskNumber(String taskId);

  /// حالة في الانتظار
  ///
  /// In ar, this message translates to:
  /// **'في الانتظار'**
  String get pending;

  /// حالة مقبولة
  ///
  /// In ar, this message translates to:
  /// **'مقبولة'**
  String get accepted;

  /// حالة تم الاستلام
  ///
  /// In ar, this message translates to:
  /// **'تم الاستلام'**
  String get pickedUp;

  /// حالة في الطريق
  ///
  /// In ar, this message translates to:
  /// **'في الطريق'**
  String get inTransit;

  /// حالة تم التسليم
  ///
  /// In ar, this message translates to:
  /// **'تم التسليم'**
  String get delivered;

  /// حالة ملغية
  ///
  /// In ar, this message translates to:
  /// **'ملغية'**
  String get cancelled;

  /// وحدة الأيام
  ///
  /// In ar, this message translates to:
  /// **'يوم'**
  String get days;

  /// وحدة الساعات
  ///
  /// In ar, this message translates to:
  /// **'ساعة'**
  String get hours;

  /// وحدة الدقائق
  ///
  /// In ar, this message translates to:
  /// **'دقيقة'**
  String get minutes;

  /// كلمة الآن
  ///
  /// In ar, this message translates to:
  /// **'الآن'**
  String get now;

  /// تسمية نقطة الاستلام
  ///
  /// In ar, this message translates to:
  /// **'نقطة الاستلام'**
  String get pickupPoint;

  /// تسمية نقطة التسليم
  ///
  /// In ar, this message translates to:
  /// **'نقطة التسليم'**
  String get deliveryPoint;

  /// تسمية العناصر
  ///
  /// In ar, this message translates to:
  /// **'العناصر'**
  String get items;

  /// مستحقات السائق
  ///
  /// In ar, this message translates to:
  /// **'مستحقاتك: {amount} ر.س'**
  String yourEarnings(String amount);

  /// زر عرض التفاصيل
  ///
  /// In ar, this message translates to:
  /// **'عرض التفاصيل'**
  String get viewDetails;

  /// زر الرفض
  ///
  /// In ar, this message translates to:
  /// **'رفض'**
  String get reject;

  /// زر القبول
  ///
  /// In ar, this message translates to:
  /// **'قبول'**
  String get accept;

  /// زر وصلت لنقطة الاستلام
  ///
  /// In ar, this message translates to:
  /// **'وصلت لنقطة الاستلام'**
  String get arrivedAtPickup;

  /// زر بدء التحميل
  ///
  /// In ar, this message translates to:
  /// **'بدء التحميل'**
  String get startLoading;

  /// زر في الطريق
  ///
  /// In ar, this message translates to:
  /// **'في الطريق'**
  String get onTheWay;

  /// زر وصلت لنقطة التسليم
  ///
  /// In ar, this message translates to:
  /// **'وصلت لنقطة التسليم'**
  String get arrivedAtDelivery;

  /// زر بدء التفريغ
  ///
  /// In ar, this message translates to:
  /// **'بدء التفريغ'**
  String get startUnloading;

  /// زر إكمال المهمة
  ///
  /// In ar, this message translates to:
  /// **'إكمال المهمة'**
  String get completeTask;

  /// عنوان المعاملات الأخيرة
  ///
  /// In ar, this message translates to:
  /// **'المعاملات الأخيرة'**
  String get recentTransactions;

  /// رسالة جميع المعاملات قريباً
  ///
  /// In ar, this message translates to:
  /// **'جميع المعاملات قريباً'**
  String get allTransactionsComingSoon;

  /// رسالة عدم وجود معاملات
  ///
  /// In ar, this message translates to:
  /// **'لا توجد معاملات'**
  String get noTransactions;

  /// وصف عدم وجود معاملات
  ///
  /// In ar, this message translates to:
  /// **'لم يتم تسجيل أي معاملات مالية بعد'**
  String get noTransactionsRecorded;

  /// رسالة تحميل المعاملات
  ///
  /// In ar, this message translates to:
  /// **'جاري تحميل المعاملات...'**
  String get loadingTransactions;

  /// رسالة عدم وجود معاملات حالياً
  ///
  /// In ar, this message translates to:
  /// **'لا توجد معاملات حالياً'**
  String get noTransactionsCurrently;

  /// نوع معاملة إيداع
  ///
  /// In ar, this message translates to:
  /// **'إيداع'**
  String get deposit;

  /// نوع معاملة سحب
  ///
  /// In ar, this message translates to:
  /// **'سحب'**
  String get withdrawal;

  /// نوع معاملة عمولة
  ///
  /// In ar, this message translates to:
  /// **'عمولة'**
  String get commission;

  /// نوع معاملة إيداع نقدي
  ///
  /// In ar, this message translates to:
  /// **'إيداع نقدي'**
  String get cashDeposit;

  /// حالة مكتمل
  ///
  /// In ar, this message translates to:
  /// **'مكتمل'**
  String get completed;

  /// حالة فاشل
  ///
  /// In ar, this message translates to:
  /// **'فاشل'**
  String get failed;

  /// عنوان رصيد المحفظة
  ///
  /// In ar, this message translates to:
  /// **'رصيد المحفظة'**
  String get walletBalance;

  /// تسمية الرصيد المتاح
  ///
  /// In ar, this message translates to:
  /// **'الرصيد المتاح'**
  String get availableBalance;

  /// تسمية السحب
  ///
  /// In ar, this message translates to:
  /// **'السحب'**
  String get withdrawals;

  /// تسمية الدخل
  ///
  /// In ar, this message translates to:
  /// **'الدخل'**
  String get income;

  /// عنوان مهمة جديدة
  ///
  /// In ar, this message translates to:
  /// **'مهمة جديدة!'**
  String get newTask;

  /// وقت الاستجابة المتبقي
  ///
  /// In ar, this message translates to:
  /// **'الرد خلال: {time}'**
  String respondWithin(String time);

  /// رسالة انتهاء مهلة الاستجابة
  ///
  /// In ar, this message translates to:
  /// **'انتهت مهلة الاستجابة، تم تحويل المهمة لسائق آخر'**
  String get responseTimeExpired;

  /// من العنوان
  ///
  /// In ar, this message translates to:
  /// **'من: {address}'**
  String from(String address);

  /// إلى العنوان
  ///
  /// In ar, this message translates to:
  /// **'إلى: {address}'**
  String to(String address);

  /// المبلغ بالريال السعودي
  ///
  /// In ar, this message translates to:
  /// **'المبلغ: {amount} ر.س'**
  String amount(String amount);

  /// رسالة نجاح قبول المهمة
  ///
  /// In ar, this message translates to:
  /// **'تم قبول المهمة بنجاح'**
  String get taskAcceptedSuccessfully;

  /// عنوان تفاصيل المهمة
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل المهمة'**
  String get taskDetails;

  /// تسمية رقم المهمة
  ///
  /// In ar, this message translates to:
  /// **'رقم المهمة'**
  String get taskId;

  /// تسمية طريقة الدفع
  ///
  /// In ar, this message translates to:
  /// **'طريقة الدفع'**
  String get paymentMethod;

  /// تسمية عنوان الاستلام
  ///
  /// In ar, this message translates to:
  /// **'عنوان الاستلام'**
  String get pickupAddress;

  /// تسمية عنوان التسليم
  ///
  /// In ar, this message translates to:
  /// **'عنوان التسليم'**
  String get deliveryAddress;

  /// تسمية المبلغ الإجمالي
  ///
  /// In ar, this message translates to:
  /// **'المبلغ الإجمالي'**
  String get totalAmount;

  /// تسمية تاريخ الإنشاء
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الإنشاء'**
  String get creationDate;

  /// تسمية الملاحظات
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات'**
  String get notes;

  /// تسمية عرضي
  ///
  /// In ar, this message translates to:
  /// **'عرضي'**
  String get myOffer;

  /// حالة عرضي في الانتظار
  ///
  /// In ar, this message translates to:
  /// **'عرضي في الانتظار'**
  String get myOfferPending;

  /// حالة تم قبول عرضي
  ///
  /// In ar, this message translates to:
  /// **'تم قبول عرضي'**
  String get myOfferAccepted;

  /// حالة تم رفض عرضي
  ///
  /// In ar, this message translates to:
  /// **'تم رفض عرضي'**
  String get myOfferRejected;

  /// السعر المقترح
  ///
  /// In ar, this message translates to:
  /// **'السعر المقترح: {price} ر.س'**
  String suggestedPrice(String price);

  /// تسمية وصف العرض
  ///
  /// In ar, this message translates to:
  /// **'وصف العرض:'**
  String get offerDescription;

  /// عنوان حساب صافي المستحقات
  ///
  /// In ar, this message translates to:
  /// **'حساب صافي المستحقات:'**
  String get netEarningsCalculation;

  /// سعر العرض
  ///
  /// In ar, this message translates to:
  /// **'سعر العرض: {price} ر.س'**
  String offerPrice(String price);

  /// تسمية عمولة الخدمة
  ///
  /// In ar, this message translates to:
  /// **'عمولة الخدمة'**
  String get serviceCommission;

  /// تسمية ضريبة القيمة المضافة
  ///
  /// In ar, this message translates to:
  /// **'ضريبة القيمة المضافة'**
  String get vat;

  /// تسمية صافي المستحقات
  ///
  /// In ar, this message translates to:
  /// **'صافي المستحقات'**
  String get netEarnings;

  /// تاريخ التقديم
  ///
  /// In ar, this message translates to:
  /// **'تم التقديم: {date}'**
  String submittedOn(String date);

  /// تاريخ آخر تحديث
  ///
  /// In ar, this message translates to:
  /// **'آخر تحديث: {date}'**
  String lastUpdated(String date);

  /// رقم الإعلان
  ///
  /// In ar, this message translates to:
  /// **'إعلان #{adId}'**
  String adNumber(String adId);

  /// حالة جاري
  ///
  /// In ar, this message translates to:
  /// **'جاري'**
  String get running;

  /// حالة مغلق
  ///
  /// In ar, this message translates to:
  /// **'مغلق'**
  String get closed;

  /// تسمية الاستلام
  ///
  /// In ar, this message translates to:
  /// **'الاستلام'**
  String get pickup;

  /// تسمية التسليم
  ///
  /// In ar, this message translates to:
  /// **'التسليم'**
  String get delivery;

  /// نطاق الأسعار
  ///
  /// In ar, this message translates to:
  /// **'نطاق الأسعار: {min} - {max} ر.س'**
  String priceRange(String min, String max);

  /// عدد العروض
  ///
  /// In ar, this message translates to:
  /// **'عدد العروض: {count}'**
  String offersCount(String count);

  /// رسالة تم قبول عرض
  ///
  /// In ar, this message translates to:
  /// **'تم قبول عرض'**
  String get offerAccepted;

  /// زر تقديم عرض
  ///
  /// In ar, this message translates to:
  /// **'تقديم عرض'**
  String get submitOffer;

  /// زر قبول المهمة
  ///
  /// In ar, this message translates to:
  /// **'قبول المهمة'**
  String get acceptTask;

  /// رسالة تأكيد قبول المهمة
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من رغبتك في قبول هذه المهمة؟'**
  String get acceptTaskConfirm;

  /// رسالة فشل قبول المهمة
  ///
  /// In ar, this message translates to:
  /// **'فشل في قبول المهمة'**
  String get taskAcceptFailed;

  /// عنوان سجل المهمة
  ///
  /// In ar, this message translates to:
  /// **'سجل المهمة #{taskId}'**
  String taskHistory(String taskId);

  /// رسالة عدم وجود سجل للمهمة
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد سجل للمهمة'**
  String get noTaskHistory;

  /// عنوان إضافة ملاحظة
  ///
  /// In ar, this message translates to:
  /// **'إضافة ملاحظة'**
  String get addNote;

  /// نص تلميح كتابة الملاحظة
  ///
  /// In ar, this message translates to:
  /// **'اكتب ملاحظتك هنا...'**
  String get writeNoteHere;

  /// زر إرفاق ملف
  ///
  /// In ar, this message translates to:
  /// **'إرفاق ملف'**
  String get attachFile;

  /// رسالة جاري الإضافة
  ///
  /// In ar, this message translates to:
  /// **'جاري الإضافة...'**
  String get adding;

  /// زر الإضافة
  ///
  /// In ar, this message translates to:
  /// **'إضافة'**
  String get add;

  /// رسالة يرجى كتابة ملاحظة
  ///
  /// In ar, this message translates to:
  /// **'يرجى كتابة ملاحظة'**
  String get pleaseWriteNote;

  /// رسالة نجاح إضافة الملاحظة
  ///
  /// In ar, this message translates to:
  /// **'تم إضافة الملاحظة بنجاح'**
  String get noteAddedSuccess;

  /// رسالة فشل إضافة الملاحظة
  ///
  /// In ar, this message translates to:
  /// **'فشل في إضافة الملاحظة'**
  String get noteAddFailed;

  /// رسالة خطأ إضافة الملاحظة
  ///
  /// In ar, this message translates to:
  /// **'خطأ في إضافة الملاحظة: {error}'**
  String errorAddingNote(String error);

  /// رسالة خطأ اختيار الملف
  ///
  /// In ar, this message translates to:
  /// **'خطأ في اختيار الملف: {error}'**
  String errorSelectingFile(String error);

  /// رسالة خطأ فتح المرفق
  ///
  /// In ar, this message translates to:
  /// **'خطأ في فتح المرفق: {error}'**
  String errorOpeningAttachment(String error);

  /// رسالة خطأ تحميل الصورة
  ///
  /// In ar, this message translates to:
  /// **'خطأ في تحميل الصورة: {error}'**
  String errorLoadingImage(String error);

  /// تعليمات فتح الملف
  ///
  /// In ar, this message translates to:
  /// **'اضغط على \"فتح\" لعرض الملف'**
  String get clickOpenToView;

  /// زر التحميل
  ///
  /// In ar, this message translates to:
  /// **'تحميل'**
  String get download;

  /// زر الفتح
  ///
  /// In ar, this message translates to:
  /// **'فتح'**
  String get open;

  /// رسالة خطأ تحميل الملف
  ///
  /// In ar, this message translates to:
  /// **'خطأ في تحميل الملف: {error}'**
  String errorDownloadingFile(String error);

  /// رسالة خطأ فتح الملف
  ///
  /// In ar, this message translates to:
  /// **'خطأ في فتح الملف: {error}'**
  String errorOpeningFile(String error);

  /// عنوان مراحل المهمة
  ///
  /// In ar, this message translates to:
  /// **'مراحل المهمة'**
  String get taskStages;

  /// مرحلة مخصصة
  ///
  /// In ar, this message translates to:
  /// **'مخصصة'**
  String get assigned;

  /// وصف مرحلة مخصصة
  ///
  /// In ar, this message translates to:
  /// **'تم تخصيص المهمة للسائق'**
  String get assignedDescription;

  /// مرحلة بدأت
  ///
  /// In ar, this message translates to:
  /// **'بدأت'**
  String get started;

  /// وصف مرحلة بدأت
  ///
  /// In ar, this message translates to:
  /// **'بدأ السائق في تنفيذ المهمة'**
  String get startedDescription;

  /// مرحلة في نقطة الاستلام
  ///
  /// In ar, this message translates to:
  /// **'في نقطة الاستلام'**
  String get inPickupPoint;

  /// وصف مرحلة في نقطة الاستلام
  ///
  /// In ar, this message translates to:
  /// **'وصل السائق لنقطة الاستلام'**
  String get inPickupPointDescription;

  /// مرحلة جاري التحميل
  ///
  /// In ar, this message translates to:
  /// **'جاري التحميل'**
  String get loading;

  /// وصف مرحلة جاري التحميل
  ///
  /// In ar, this message translates to:
  /// **'يتم تحميل البضائع'**
  String get loadingDescription;

  /// مرحلة في الطريق
  ///
  /// In ar, this message translates to:
  /// **'في الطريق'**
  String get inTheWay;

  /// وصف مرحلة في الطريق
  ///
  /// In ar, this message translates to:
  /// **'السائق في طريقه لنقطة التسليم'**
  String get inTheWayDescription;

  /// مرحلة في نقطة التسليم
  ///
  /// In ar, this message translates to:
  /// **'في نقطة التسليم'**
  String get inDeliveryPoint;

  /// وصف مرحلة في نقطة التسليم
  ///
  /// In ar, this message translates to:
  /// **'وصل السائق لنقطة التسليم'**
  String get inDeliveryPointDescription;

  /// مرحلة جاري التفريغ
  ///
  /// In ar, this message translates to:
  /// **'جاري التفريغ'**
  String get unloading;

  /// وصف مرحلة جاري التفريغ
  ///
  /// In ar, this message translates to:
  /// **'يتم تفريغ البضائع'**
  String get unloadingDescription;

  /// مرحلة مكتملة
  ///
  /// In ar, this message translates to:
  /// **'مكتملة'**
  String get taskCompleted;

  /// وصف مرحلة مكتملة
  ///
  /// In ar, this message translates to:
  /// **'تم إكمال المهمة بنجاح'**
  String get taskCompletedDescription;

  /// تسمية رقم الهاتف
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف'**
  String get phoneNumber;

  /// تسمية رقم الواتساب
  ///
  /// In ar, this message translates to:
  /// **'رقم الواتساب'**
  String get whatsappNumber;

  /// تسمية متوسط المهمة
  ///
  /// In ar, this message translates to:
  /// **'متوسط المهمة'**
  String get averagePerTask;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
