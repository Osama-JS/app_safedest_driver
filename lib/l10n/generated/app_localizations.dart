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

  /// نص الإشعارات
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
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

  /// كلمة الإصدار
  ///
  /// In ar, this message translates to:
  /// **'الإصدار'**
  String get version;

  /// شروط الخدمة
  ///
  /// In ar, this message translates to:
  /// **'شروط الخدمة'**
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

  /// إلغاء
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

  /// عنوان شاشة إعلانات المهام
  ///
  /// In ar, this message translates to:
  /// **'إعلانات المهام'**
  String get taskAds;

  /// وصف قسم إعلانات المهام
  ///
  /// In ar, this message translates to:
  /// **'تصفح الإعلانات المتاحة وقدم عروضك'**
  String get taskAdsDescription;

  /// تبويب الإعلانات المتاحة
  ///
  /// In ar, this message translates to:
  /// **'الإعلانات المتاحة'**
  String get availableAds;

  /// تبويب عروضي
  ///
  /// In ar, this message translates to:
  /// **'عروضي'**
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

  /// زر الخروج من التطبيق
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

  /// حدث خطأ غير متوقع
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ غير متوقع: {error}'**
  String unexpectedError(String error);

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

  /// عنوان سجل المعاملات
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

  /// حجم المركبة
  ///
  /// In ar, this message translates to:
  /// **'حجم المركبة'**
  String get vehicleSize;

  /// البيانات الإضافية
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

  /// الحالة
  ///
  /// In ar, this message translates to:
  /// **'الحالة'**
  String get status;

  /// تسمية نوع المركبة
  ///
  /// In ar, this message translates to:
  /// **'نوع المركبة'**
  String get vehicleType;

  /// نص عندما تكون القيمة غير محددة
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

  /// نص التفاصيل
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

  /// حدث خطأ
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ'**
  String get errorOccurred;

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

  /// نص عرض جميع المهام
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

  /// في الانتظار
  ///
  /// In ar, this message translates to:
  /// **'في الانتظار'**
  String get pending;

  /// مقبول
  ///
  /// In ar, this message translates to:
  /// **'مقبول'**
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

  /// الآن
  ///
  /// In ar, this message translates to:
  /// **'الآن'**
  String get now;

  /// نص نقطة الاستلام
  ///
  /// In ar, this message translates to:
  /// **'نقطة الاستلام'**
  String get pickupPoint;

  /// نص نقطة التسليم
  ///
  /// In ar, this message translates to:
  /// **'نقطة التسليم'**
  String get deliveryPoint;

  /// العناصر
  ///
  /// In ar, this message translates to:
  /// **'العناصر'**
  String get items;

  /// مستحقات السائق
  ///
  /// In ar, this message translates to:
  /// **'مستحقاتك'**
  String get yourEarnings;

  /// عرض التفاصيل
  ///
  /// In ar, this message translates to:
  /// **'عرض التفاصيل'**
  String get viewDetails;

  /// زر رفض
  ///
  /// In ar, this message translates to:
  /// **'رفض'**
  String get reject;

  /// زر قبول
  ///
  /// In ar, this message translates to:
  /// **'قبول'**
  String get accept;

  /// زر وصلت لنقطة الاستلام
  ///
  /// In ar, this message translates to:
  /// **'وصلت لنقطة الاستلام'**
  String get arrivedAtPickup;

  /// بدء التحميل
  ///
  /// In ar, this message translates to:
  /// **'بدء التحميل'**
  String get startLoading;

  /// في الطريق
  ///
  /// In ar, this message translates to:
  /// **'في الطريق'**
  String get onTheWay;

  /// زر وصلت لنقطة التسليم
  ///
  /// In ar, this message translates to:
  /// **'وصلت لنقطة التسليم'**
  String get arrivedAtDelivery;

  /// بدء التفريغ
  ///
  /// In ar, this message translates to:
  /// **'بدء التفريغ'**
  String get startUnloading;

  /// إكمال المهمة
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

  /// لا توجد معاملات
  ///
  /// In ar, this message translates to:
  /// **'لا توجد معاملات'**
  String get noTransactions;

  /// وصف عدم وجود معاملات
  ///
  /// In ar, this message translates to:
  /// **'لم يتم تسجيل أي معاملات مالية بعد'**
  String get noTransactionsRecorded;

  /// جاري تحميل المعاملات
  ///
  /// In ar, this message translates to:
  /// **'جاري تحميل المعاملات...'**
  String get loadingTransactions;

  /// رسالة عدم وجود معاملات حالياً
  ///
  /// In ar, this message translates to:
  /// **'لا توجد معاملات حالياً'**
  String get noTransactionsCurrently;

  /// إيداع
  ///
  /// In ar, this message translates to:
  /// **'إيداع'**
  String get deposit;

  /// سحب
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

  /// السحوبات
  ///
  /// In ar, this message translates to:
  /// **'السحوبات'**
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

  /// المبلغ
  ///
  /// In ar, this message translates to:
  /// **'المبلغ'**
  String get amount;

  /// تم قبول المهمة بنجاح
  ///
  /// In ar, this message translates to:
  /// **'تم قبول المهمة بنجاح'**
  String get taskAcceptedSuccessfully;

  /// تفاصيل المهمة
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

  /// تاريخ الإنشاء
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الإنشاء'**
  String get creationDate;

  /// تسمية الملاحظات
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات'**
  String get notes;

  /// عرضي
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

  /// حساب صافي المستحقات
  ///
  /// In ar, this message translates to:
  /// **'حساب صافي المستحقات'**
  String get netEarningsCalculation;

  /// سعر العرض
  ///
  /// In ar, this message translates to:
  /// **'سعر العرض'**
  String get offerPrice;

  /// عمولة الخدمة
  ///
  /// In ar, this message translates to:
  /// **'عمولة الخدمة'**
  String get serviceCommission;

  /// تسمية ضريبة القيمة المضافة
  ///
  /// In ar, this message translates to:
  /// **'ضريبة القيمة المضافة'**
  String get vat;

  /// صافي المستحقات
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

  /// النطاق السعري
  ///
  /// In ar, this message translates to:
  /// **'النطاق السعري'**
  String get priceRange;

  /// عدد العروض
  ///
  /// In ar, this message translates to:
  /// **'عدد العروض'**
  String get offersCount;

  /// تم قبول عرض
  ///
  /// In ar, this message translates to:
  /// **'تم قبول عرض'**
  String get offerAccepted;

  /// تقديم عرض
  ///
  /// In ar, this message translates to:
  /// **'تقديم عرض'**
  String get submitOffer;

  /// قبول المهمة
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

  /// تلميح سجل المهمة
  ///
  /// In ar, this message translates to:
  /// **'سجل المهمة'**
  String get taskHistory;

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

  /// زر إضافة
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

  /// زر تحميل
  ///
  /// In ar, this message translates to:
  /// **'تحميل'**
  String get download;

  /// زر فتح
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

  /// رسالة التحميل
  ///
  /// In ar, this message translates to:
  /// **'جاري التحميل...'**
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

  /// نص رقم الواتساب
  ///
  /// In ar, this message translates to:
  /// **'رقم الواتساب'**
  String get whatsappNumber;

  /// تسمية متوسط المهمة
  ///
  /// In ar, this message translates to:
  /// **'متوسط المهمة'**
  String get averagePerTask;

  /// عنوان شاشة الإشعارات
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get notificationsTitle;

  /// تلميح زر تحديد جميع الإشعارات كمقروءة
  ///
  /// In ar, this message translates to:
  /// **'تحديد الكل كمقروء'**
  String get markAllAsRead;

  /// رسالة عدم وجود إشعارات
  ///
  /// In ar, this message translates to:
  /// **'لا توجد إشعارات'**
  String get noNotifications;

  /// وصف عدم وجود إشعارات
  ///
  /// In ar, this message translates to:
  /// **'ستظهر الإشعارات الجديدة هنا'**
  String get newNotificationsWillAppearHere;

  /// شارة الإشعار الجديد
  ///
  /// In ar, this message translates to:
  /// **'جديد'**
  String get newBadge;

  /// زر إغلاق الحوار
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get closeDialog;

  /// رسالة نجاح تحديد جميع الإشعارات كمقروءة
  ///
  /// In ar, this message translates to:
  /// **'تم تحديد جميع الإشعارات كمقروءة'**
  String get allNotificationsMarkedAsRead;

  /// رسالة فشل تحديث الإشعارات
  ///
  /// In ar, this message translates to:
  /// **'فشل في تحديث الإشعارات'**
  String get failedToUpdateNotifications;

  /// وحدة يوم مضى
  ///
  /// In ar, this message translates to:
  /// **'يوم مضى'**
  String get dayAgo;

  /// منذ أيام
  ///
  /// In ar, this message translates to:
  /// **'منذ {days} يوم'**
  String daysAgo(int days);

  /// وحدة ساعة مضت
  ///
  /// In ar, this message translates to:
  /// **'ساعة مضت'**
  String get hourAgo;

  /// منذ ساعات
  ///
  /// In ar, this message translates to:
  /// **'منذ {hours} ساعة'**
  String hoursAgo(int hours);

  /// وحدة دقيقة مضت
  ///
  /// In ar, this message translates to:
  /// **'دقيقة مضت'**
  String get minuteAgo;

  /// منذ دقائق
  ///
  /// In ar, this message translates to:
  /// **'منذ {minutes} دقيقة'**
  String minutesAgo(int minutes);

  /// الآن - للوقت الحالي
  ///
  /// In ar, this message translates to:
  /// **'الآن'**
  String get justNow;

  /// كلمة مضت
  ///
  /// In ar, this message translates to:
  /// **'مضت'**
  String get ago;

  /// كلمة منذ
  ///
  /// In ar, this message translates to:
  /// **'منذ'**
  String get since;

  /// رسالة خطأ جلب تفاصيل المهمة
  ///
  /// In ar, this message translates to:
  /// **'خطأ في جلب تفاصيل المهمة'**
  String get taskDetailError;

  /// عنوان خطأ
  ///
  /// In ar, this message translates to:
  /// **'خطأ'**
  String get errorTitle;

  /// رسالة عدم العثور على المهمة
  ///
  /// In ar, this message translates to:
  /// **'لم يتم العثور على المهمة'**
  String get taskNotFound;

  /// التنقل السريع
  ///
  /// In ar, this message translates to:
  /// **'التنقل السريع'**
  String get quickNavigation;

  /// نقطة الاستلام
  ///
  /// In ar, this message translates to:
  /// **'نقطة الاستلام'**
  String get pickupLocation;

  /// نقطة التسليم
  ///
  /// In ar, this message translates to:
  /// **'نقطة التسليم'**
  String get deliveryLocation;

  /// اسم المسؤول
  ///
  /// In ar, this message translates to:
  /// **'اسم المسؤول'**
  String get contactPersonName;

  /// فتح في خرائط جوجل
  ///
  /// In ar, this message translates to:
  /// **'فتح في خرائط جوجل'**
  String get openInGoogleMaps;

  /// عنصر غير محدد
  ///
  /// In ar, this message translates to:
  /// **'عنصر غير محدد'**
  String get unspecifiedItem;

  /// الكمية
  ///
  /// In ar, this message translates to:
  /// **'الكمية'**
  String get quantity;

  /// في انتظار الموافقة
  ///
  /// In ar, this message translates to:
  /// **'في انتظار الموافقة'**
  String get awaitingApproval;

  /// نص بدء المهمة
  ///
  /// In ar, this message translates to:
  /// **'بدء المهمة'**
  String get startTask;

  /// وصلت لنقطة الاستلام
  ///
  /// In ar, this message translates to:
  /// **'وصلت لنقطة الاستلام'**
  String get arrivedAtPickupPoint;

  /// زر بدء التحميل
  ///
  /// In ar, this message translates to:
  /// **'بدء التحميل'**
  String get startLoadingGoods;

  /// زر في الطريق
  ///
  /// In ar, this message translates to:
  /// **'في الطريق'**
  String get onTheWayToDelivery;

  /// وصلت لنقطة التسليم
  ///
  /// In ar, this message translates to:
  /// **'وصلت لنقطة التسليم'**
  String get arrivedAtDeliveryPoint;

  /// زر بدء التفريغ
  ///
  /// In ar, this message translates to:
  /// **'بدء التفريغ'**
  String get startUnloadingGoods;

  /// زر إكمال المهمة
  ///
  /// In ar, this message translates to:
  /// **'إكمال المهمة'**
  String get completeTaskButton;

  /// لا يمكن فتح خرائط جوجل
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن فتح خرائط جوجل'**
  String get cannotOpenGoogleMaps;

  /// حدث خطأ في فتح الخريطة
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ في فتح الخريطة'**
  String get mapOpenError;

  /// تأكيد تحديث الحالة
  ///
  /// In ar, this message translates to:
  /// **'تأكيد تحديث الحالة'**
  String get confirmStatusUpdate;

  /// رسالة تأكيد تحديث الحالة
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من تحديث حالة المهمة إلى:'**
  String get confirmStatusUpdateMessage;

  /// تحذير عدم إمكانية التراجع
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن التراجع عن هذا الإجراء.'**
  String get cannotUndoAction;

  /// زر التأكيد
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get confirmButton;

  /// جاري تحديث حالة المهمة
  ///
  /// In ar, this message translates to:
  /// **'جاري تحديث حالة المهمة...'**
  String get updatingTaskStatus;

  /// رسالة خطأ غير متوقع
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.'**
  String get unexpectedErrorOccurred;

  /// رسالة نجاح التحديث
  ///
  /// In ar, this message translates to:
  /// **'تم التحديث بنجاح'**
  String get updateSuccessful;

  /// تم تحديث حالة المهمة إلى
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث حالة المهمة إلى: {status}'**
  String taskStatusUpdatedTo(String status);

  /// زر موافق
  ///
  /// In ar, this message translates to:
  /// **'موافق'**
  String get okButton;

  /// فشل في التحديث
  ///
  /// In ar, this message translates to:
  /// **'فشل في التحديث'**
  String get updateFailed;

  /// فشل في تحميل تفاصيل الإعلان
  ///
  /// In ar, this message translates to:
  /// **'فشل في تحميل تفاصيل الإعلان'**
  String get failedToLoadAdDetails;

  /// تلميح زر التحديث
  ///
  /// In ar, this message translates to:
  /// **'تحديث'**
  String get refreshTooltip;

  /// تبويب تفاصيل الإعلان
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الإعلان'**
  String get adDetailsTab;

  /// تبويب العروض المقدمة
  ///
  /// In ar, this message translates to:
  /// **'العروض المقدمة'**
  String get submittedOffersTab;

  /// جاري تحميل التفاصيل
  ///
  /// In ar, this message translates to:
  /// **'جاري تحميل التفاصيل...'**
  String get loadingDetails;

  /// زر إعادة المحاولة
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get retryButton;

  /// رسالة عدم وجود بيانات للعرض
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بيانات للعرض'**
  String get noDataToDisplay;

  /// رسالة عدم إمكانية عرض العروض المقدمة
  ///
  /// In ar, this message translates to:
  /// **'لا يمكنك عرض العروض المقدمة'**
  String get cannotViewSubmittedOffers;

  /// يجب تقديم عرض أولاً لعرض العروض الأخرى
  ///
  /// In ar, this message translates to:
  /// **'يجب تقديم عرض أولاً لعرض العروض الأخرى'**
  String get mustSubmitOfferFirst;

  /// لا توجد عروض مقدمة
  ///
  /// In ar, this message translates to:
  /// **'لا توجد عروض مقدمة'**
  String get noOffersSubmitted;

  /// وصف عدم وجود عروض مقدمة
  ///
  /// In ar, this message translates to:
  /// **'لم يتم تقديم أي عروض لهذا الإعلان بعد'**
  String get noOffersSubmittedYet;

  /// تعديل العرض
  ///
  /// In ar, this message translates to:
  /// **'تعديل العرض'**
  String get editOffer;

  /// عنوان تأكيد قبول المهمة
  ///
  /// In ar, this message translates to:
  /// **'قبول المهمة'**
  String get acceptTaskConfirmTitle;

  /// رسالة تأكيد قبول المهمة
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من رغبتك في قبول هذه المهمة؟'**
  String get acceptTaskConfirmMessage;

  /// زر القبول
  ///
  /// In ar, this message translates to:
  /// **'قبول'**
  String get acceptButton;

  /// فشل في قبول المهمة
  ///
  /// In ar, this message translates to:
  /// **'فشل في قبول المهمة'**
  String get failedToAcceptTask;

  /// حالة جاري
  ///
  /// In ar, this message translates to:
  /// **'جاري'**
  String get statusRunning;

  /// حالة مغلق
  ///
  /// In ar, this message translates to:
  /// **'مغلق'**
  String get statusClosed;

  /// وصف المهمة
  ///
  /// In ar, this message translates to:
  /// **'وصف المهمة'**
  String get taskDescription;

  /// من السعر
  ///
  /// In ar, this message translates to:
  /// **'من {price} ر.س'**
  String fromPrice(String price);

  /// إلى السعر
  ///
  /// In ar, this message translates to:
  /// **'إلى {price} ر.س'**
  String toPrice(String price);

  /// معلومات العمولة والضرائب
  ///
  /// In ar, this message translates to:
  /// **'معلومات العمولة والضرائب'**
  String get commissionAndTaxInfo;

  /// ضريبة القيمة المضافة
  ///
  /// In ar, this message translates to:
  /// **'ضريبة القيمة المضافة'**
  String get vatTax;

  /// حالة في الانتظار
  ///
  /// In ar, this message translates to:
  /// **'في الانتظار'**
  String get statusPending;

  /// حالة مقبول
  ///
  /// In ar, this message translates to:
  /// **'مقبول'**
  String get statusAccepted;

  /// حالة مرفوض
  ///
  /// In ar, this message translates to:
  /// **'مرفوض'**
  String get statusRejected;

  /// السعر المقترح
  ///
  /// In ar, this message translates to:
  /// **'السعر المقترح'**
  String get proposedPrice;

  /// الوصف
  ///
  /// In ar, this message translates to:
  /// **'الوصف'**
  String get description;

  /// فشل في تحميل الإعلانات
  ///
  /// In ar, this message translates to:
  /// **'فشل في تحميل الإعلانات'**
  String get failedToLoadAds;

  /// عنوان شاشة إعلانات المهام
  ///
  /// In ar, this message translates to:
  /// **'إعلانات المهام'**
  String get taskAdsTitle;

  /// تلميح زر الفلترة
  ///
  /// In ar, this message translates to:
  /// **'فلترة'**
  String get filterTooltip;

  /// تبويب الإعلانات المتاحة
  ///
  /// In ar, this message translates to:
  /// **'الإعلانات المتاحة'**
  String get availableAdsTab;

  /// تبويب عروضي
  ///
  /// In ar, this message translates to:
  /// **'عروضي'**
  String get myOffersTab;

  /// نص البحث في الإعلانات
  ///
  /// In ar, this message translates to:
  /// **'البحث في الإعلانات...'**
  String get searchInAds;

  /// إجمالي الإعلانات
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الإعلانات'**
  String get totalAds;

  /// متوسط السعر
  ///
  /// In ar, this message translates to:
  /// **'متوسط السعر'**
  String get averagePrice;

  /// جاري تحميل الإعلانات
  ///
  /// In ar, this message translates to:
  /// **'جاري تحميل الإعلانات...'**
  String get loadingAds;

  /// رسالة عدم وجود إعلانات متاحة
  ///
  /// In ar, this message translates to:
  /// **'لا توجد إعلانات متاحة'**
  String get noAvailableAds;

  /// وصف عدم وجود إعلانات متاحة
  ///
  /// In ar, this message translates to:
  /// **'لا توجد إعلانات مهام متاحة في الوقت الحالي'**
  String get noAvailableAdsDescription;

  /// فلترة الإعلانات
  ///
  /// In ar, this message translates to:
  /// **'فلترة الإعلانات'**
  String get filterAds;

  /// أقل سعر
  ///
  /// In ar, this message translates to:
  /// **'أقل سعر'**
  String get minPrice;

  /// أعلى سعر
  ///
  /// In ar, this message translates to:
  /// **'أعلى سعر'**
  String get maxPrice;

  /// ترتيب حسب
  ///
  /// In ar, this message translates to:
  /// **'ترتيب حسب'**
  String get sortBy;

  /// ترتيب حسب تاريخ الإنشاء
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الإنشاء'**
  String get sortByCreationDate;

  /// ترتيب حسب أقل سعر
  ///
  /// In ar, this message translates to:
  /// **'أقل سعر'**
  String get sortByLowestPrice;

  /// ترتيب حسب أعلى سعر
  ///
  /// In ar, this message translates to:
  /// **'أعلى سعر'**
  String get sortByHighestPrice;

  /// ترتيب حسب عدد العروض
  ///
  /// In ar, this message translates to:
  /// **'عدد العروض'**
  String get sortByOffersCount;

  /// ترتيب
  ///
  /// In ar, this message translates to:
  /// **'ترتيب'**
  String get sortOrder;

  /// تنازلي
  ///
  /// In ar, this message translates to:
  /// **'تنازلي'**
  String get descending;

  /// تصاعدي
  ///
  /// In ar, this message translates to:
  /// **'تصاعدي'**
  String get ascending;

  /// مسح الفلاتر
  ///
  /// In ar, this message translates to:
  /// **'مسح الفلاتر'**
  String get clearFilters;

  /// زر تطبيق الفلاتر
  ///
  /// In ar, this message translates to:
  /// **'تطبيق'**
  String get applyFilters;

  /// تم تحديث العرض بنجاح
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث العرض بنجاح'**
  String get offerUpdatedSuccessfully;

  /// تم تقديم العرض بنجاح
  ///
  /// In ar, this message translates to:
  /// **'تم تقديم العرض بنجاح'**
  String get offerSubmittedSuccessfully;

  /// فشل في تقديم العرض
  ///
  /// In ar, this message translates to:
  /// **'فشل في تقديم العرض'**
  String get failedToSubmitOffer;

  /// عنوان تعديل العرض
  ///
  /// In ar, this message translates to:
  /// **'تعديل العرض'**
  String get editOfferTitle;

  /// عنوان تقديم عرض
  ///
  /// In ar, this message translates to:
  /// **'تقديم عرض'**
  String get submitOfferTitle;

  /// ملخص الإعلان
  ///
  /// In ar, this message translates to:
  /// **'ملخص الإعلان'**
  String get adSummary;

  /// تسمية النطاق السعري
  ///
  /// In ar, this message translates to:
  /// **'النطاق السعري'**
  String get priceRangeLabel;

  /// السعر المقترح مطلوب
  ///
  /// In ar, this message translates to:
  /// **'السعر المقترح *'**
  String get proposedPriceRequired;

  /// أدخل السعر المقترح
  ///
  /// In ar, this message translates to:
  /// **'أدخل السعر المقترح'**
  String get enterProposedPrice;

  /// يرجى إدخال السعر المقترح
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال السعر المقترح'**
  String get pleaseEnterProposedPrice;

  /// يرجى إدخال سعر صحيح
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال سعر صحيح'**
  String get pleaseEnterValidPrice;

  /// يجب أن يكون السعر أكبر من صفر
  ///
  /// In ar, this message translates to:
  /// **'يجب أن يكون السعر أكبر من صفر'**
  String get priceMustBeGreaterThanZero;

  /// السعر أقل من الحد الأدنى
  ///
  /// In ar, this message translates to:
  /// **'السعر أقل من الحد الأدنى'**
  String get priceBelowMinimum;

  /// السعر أعلى من الحد الأقصى
  ///
  /// In ar, this message translates to:
  /// **'السعر أعلى من الحد الأقصى'**
  String get priceAboveMaximum;

  /// النطاق المسموح
  ///
  /// In ar, this message translates to:
  /// **'النطاق المسموح'**
  String get allowedRange;

  /// وصف العرض اختياري
  ///
  /// In ar, this message translates to:
  /// **'وصف العرض (اختياري)'**
  String get offerDescriptionOptional;

  /// نص إضافة وصف للعرض
  ///
  /// In ar, this message translates to:
  /// **'أضف وصفاً لعرضك (اختياري)'**
  String get addOfferDescription;

  /// زر تحديث العرض
  ///
  /// In ar, this message translates to:
  /// **'تحديث العرض'**
  String get updateOfferButton;

  /// تقديم العرض
  ///
  /// In ar, this message translates to:
  /// **'تقديم العرض'**
  String get submitOfferButton;

  /// رسالة خطأ غير متوقع مع طلب المحاولة مرة أخرى
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.'**
  String get unexpectedErrorTryAgain;

  /// عنوان خطأ تسجيل الدخول
  ///
  /// In ar, this message translates to:
  /// **'خطأ في تسجيل الدخول'**
  String get loginError;

  /// زر الموافقة
  ///
  /// In ar, this message translates to:
  /// **'موافق'**
  String get agreeButton;

  /// رسالة الترحيب في تطبيق السائقين
  ///
  /// In ar, this message translates to:
  /// **'مرحباً بك في تطبيق السائقين'**
  String get welcomeToDriverApp;

  /// تسمية البريد الإلكتروني أو اسم المستخدم
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني أو اسم المستخدم'**
  String get emailOrUsername;

  /// نص إدخال البريد الإلكتروني أو اسم المستخدم
  ///
  /// In ar, this message translates to:
  /// **'أدخل بريدك الإلكتروني أو اسم المستخدم'**
  String get enterEmailOrUsername;

  /// رسالة خطأ عند عدم إدخال البريد الإلكتروني
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال البريد الإلكتروني'**
  String get pleaseEnterEmail;

  /// تسمية كلمة المرور
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get passwordLabel;

  /// نص إدخال كلمة المرور
  ///
  /// In ar, this message translates to:
  /// **'أدخل كلمة المرور'**
  String get enterPassword;

  /// رسالة خطأ عدم إدخال كلمة المرور
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال كلمة المرور'**
  String get pleaseEnterPassword;

  /// رسالة خطأ طول كلمة المرور الأدنى
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور يجب أن تكون 6 أحرف على الأقل'**
  String get passwordMinLength;

  /// زر تسجيل الدخول
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get loginButton;

  /// تذكرني
  ///
  /// In ar, this message translates to:
  /// **'تذكرني'**
  String get rememberMe;

  /// نص نسيت كلمة المرور
  ///
  /// In ar, this message translates to:
  /// **'نسيت كلمة المرور'**
  String get forgotPassword;

  /// ليس لديك حساب
  ///
  /// In ar, this message translates to:
  /// **'ليس لديك حساب؟'**
  String get dontHaveAccount;

  /// نص إنشاء حساب جديد
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب جديد'**
  String get createNewAccount;

  /// بتسجيل الدخول أنت توافق على
  ///
  /// In ar, this message translates to:
  /// **'بتسجيل الدخول، أنت توافق على'**
  String get byLoggingInYouAgree;

  /// حرف العطف و
  ///
  /// In ar, this message translates to:
  /// **' و '**
  String get and;

  /// رقم الإصدار
  ///
  /// In ar, this message translates to:
  /// **'الإصدار {version}'**
  String versionNumber(String version);

  /// عنوان خطأ تسجيل الدخول
  ///
  /// In ar, this message translates to:
  /// **'خطأ في تسجيل الدخول'**
  String get loginErrorTitle;

  /// تسمية حقل البريد الإلكتروني أو اسم المستخدم
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني أو اسم المستخدم'**
  String get emailOrUsernameLabel;

  /// تلميح حقل البريد الإلكتروني أو اسم المستخدم
  ///
  /// In ar, this message translates to:
  /// **'أدخل بريدك الإلكتروني أو اسم المستخدم'**
  String get enterEmailOrUsernameHint;

  /// رسالة خطأ عدم إدخال البريد الإلكتروني
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال البريد الإلكتروني'**
  String get pleaseEnterEmailError;

  /// تسمية حقل كلمة المرور
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get passwordFieldLabel;

  /// تلميح حقل كلمة المرور
  ///
  /// In ar, this message translates to:
  /// **'أدخل كلمة المرور'**
  String get enterPasswordHint;

  /// رسالة خطأ عدم إدخال كلمة المرور
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال كلمة المرور'**
  String get pleaseEnterPasswordError;

  /// رسالة خطأ طول كلمة المرور الأدنى
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور يجب أن تكون 6 أحرف على الأقل'**
  String get passwordMinLengthError;

  /// نص زر تسجيل الدخول
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get loginButtonText;

  /// نص تذكرني
  ///
  /// In ar, this message translates to:
  /// **'تذكرني'**
  String get rememberMeText;

  /// نص نسيت كلمة المرور
  ///
  /// In ar, this message translates to:
  /// **'نسيت كلمة المرور؟'**
  String get forgotPasswordText;

  /// نص ليس لديك حساب
  ///
  /// In ar, this message translates to:
  /// **'ليس لديك حساب؟'**
  String get dontHaveAccountText;

  /// نص إنشاء حساب جديد
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب جديد'**
  String get createNewAccountText;

  /// نص الموافقة على الشروط
  ///
  /// In ar, this message translates to:
  /// **'بتسجيل الدخول، أنت توافق على'**
  String get byLoggingInYouAgreeText;

  /// نص شروط الخدمة
  ///
  /// In ar, this message translates to:
  /// **'شروط الخدمة'**
  String get termsOfServiceText;

  /// حرف العطف و
  ///
  /// In ar, this message translates to:
  /// **' و '**
  String get andText;

  /// نص سياسة الخصوصية
  ///
  /// In ar, this message translates to:
  /// **'سياسة الخصوصية'**
  String get privacyPolicyText;

  /// نص الكل
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get allText;

  /// عنوان تواصل معنا
  ///
  /// In ar, this message translates to:
  /// **'تواصل معنا'**
  String get supportContact;

  /// تسمية البريد الإلكتروني للتواصل
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get contactEmail;

  /// تسمية الموقع الإلكتروني
  ///
  /// In ar, this message translates to:
  /// **'الموقع الإلكتروني'**
  String get contactWebsite;

  /// تسمية اتصل بنا
  ///
  /// In ar, this message translates to:
  /// **'اتصل بنا'**
  String get contactUs;

  /// رسالة حساب غير نشط
  ///
  /// In ar, this message translates to:
  /// **'حساب غير نشط'**
  String get accountInactive;

  /// رسالة تفصيلية لحساب غير نشط
  ///
  /// In ar, this message translates to:
  /// **'تم إيقاف حسابك. يرجى التواصل مع الإدارة للمزيد من المعلومات.'**
  String get accountInactiveMessage;

  /// رسالة حساب محظور
  ///
  /// In ar, this message translates to:
  /// **'حساب محظور'**
  String get accountBlocked;

  /// رسالة تفصيلية لحساب محظور
  ///
  /// In ar, this message translates to:
  /// **'تم حظر حسابك. يرجى التواصل مع الإدارة.'**
  String get accountBlockedMessage;

  /// زر حذف الحساب
  ///
  /// In ar, this message translates to:
  /// **'حذف الحساب'**
  String get deleteAccount;

  /// عنوان تحذير حذف الحساب
  ///
  /// In ar, this message translates to:
  /// **'تحذير: حذف الحساب'**
  String get deleteAccountWarning;

  /// رسالة تأكيد حذف الحساب
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من رغبتك في حذف حسابك؟ هذا الإجراء لا يمكن التراجع عنه وسيتم حذف جميع بياناتك.'**
  String get deleteAccountMessage;

  /// رسالة إدخال كلمة المرور لحذف الحساب
  ///
  /// In ar, this message translates to:
  /// **'أدخل كلمة المرور لتأكيد حذف الحساب'**
  String get enterPasswordToDelete;

  /// رسالة كتابة نص التأكيد لحذف الحساب
  ///
  /// In ar, this message translates to:
  /// **'اكتب \'DELETE_MY_ACCOUNT\' للتأكيد'**
  String get typeDeleteConfirmation;

  /// زر تأكيد الحذف
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الحذف'**
  String get confirmDelete;

  /// رسالة نجاح حذف الحساب
  ///
  /// In ar, this message translates to:
  /// **'تم حذف الحساب بنجاح'**
  String get accountDeletedSuccessfully;

  /// رسالة خطأ عند وجود مهام نشطة
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن حذف الحساب مع وجود مهام نشطة'**
  String get cannotDeleteAccountWithActiveTasks;

  /// رسالة خطأ كلمة مرور خاطئة
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور غير صحيحة'**
  String get invalidPasswordForDelete;

  /// رسالة خطأ عام في حذف الحساب
  ///
  /// In ar, this message translates to:
  /// **'فشل في حذف الحساب'**
  String get failedToDeleteAccount;

  /// رسالة خطأ عند فشل تحميل بيانات التسجيل
  ///
  /// In ar, this message translates to:
  /// **'فشل في تحميل بيانات التسجيل'**
  String get failedToLoadRegistrationData;

  /// رسالة خطأ عند فشل التسجيل
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ أثناء التسجيل'**
  String get registrationError;

  /// رسالة نجاح التسجيل
  ///
  /// In ar, this message translates to:
  /// **'تم التسجيل بنجاح!'**
  String get registrationSuccess;

  /// رسالة إرسال رابط التحقق
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال رابط التحقق إلى بريدك الإلكتروني.'**
  String get verificationLinkSent;

  /// نص تسجيل الدخول
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get login;

  /// نص زر السابق
  ///
  /// In ar, this message translates to:
  /// **'السابق'**
  String get previous;

  /// رسالة انتهاء مهلة المهمة
  ///
  /// In ar, this message translates to:
  /// **'انتهت مهلة الاستجابة، تم تحويل المهمة لسائق آخر'**
  String get taskExpiredTransferred;

  /// نص خطأ
  ///
  /// In ar, this message translates to:
  /// **'خطأ'**
  String get error;

  /// زر موافق
  ///
  /// In ar, this message translates to:
  /// **'موافق'**
  String get ok;

  /// أقل سعر
  ///
  /// In ar, this message translates to:
  /// **'أقل سعر'**
  String get lowestPrice;

  /// أعلى سعر
  ///
  /// In ar, this message translates to:
  /// **'أعلى سعر'**
  String get highestPrice;

  /// نص ترتيب
  ///
  /// In ar, this message translates to:
  /// **'ترتيب'**
  String get sort;

  /// تطبيق
  ///
  /// In ar, this message translates to:
  /// **'تطبيق'**
  String get apply;

  /// رسالة تأكيد قبول المهمة
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من رغبتك في قبول هذه المهمة؟'**
  String get confirmAcceptTask;

  /// نص إغلاق
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get close;

  /// رسالة تحديد جميع الإشعارات كمقروءة
  ///
  /// In ar, this message translates to:
  /// **'تم تحديد جميع الإشعارات كمقروءة'**
  String get allNotificationsMarkedRead;

  /// نص تعديل الملف الشخصي
  ///
  /// In ar, this message translates to:
  /// **'تعديل الملف الشخصي'**
  String get editProfile;

  /// نص تغيير كلمة المرور
  ///
  /// In ar, this message translates to:
  /// **'تغيير كلمة المرور'**
  String get changePassword;

  /// رسالة نجاح تغيير كلمة المرور
  ///
  /// In ar, this message translates to:
  /// **'تم تغيير كلمة المرور بنجاح'**
  String get passwordChangedSuccessfully;

  /// رسالة نجاح تحديث الملف الشخصي
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث الملف الشخصي بنجاح'**
  String get profileUpdatedSuccessfully;

  /// نص تحديث الموقع الجغرافي
  ///
  /// In ar, this message translates to:
  /// **'تحديث الموقع الجغرافي'**
  String get updateLocationGPS;

  /// عرض
  ///
  /// In ar, this message translates to:
  /// **'عرض'**
  String get view;

  /// عنوان فلترة المعاملات
  ///
  /// In ar, this message translates to:
  /// **'فلترة المعاملات'**
  String get filterTransactions;

  /// رسالة خطأ تهيئة التطبيق
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ أثناء تهيئة التطبيق. يرجى المحاولة مرة أخرى.'**
  String get appInitializationError;

  /// جاري تحميل العروض
  ///
  /// In ar, this message translates to:
  /// **'جاري تحميل العروض...'**
  String get loadingOffers;

  /// رسالة تحميل بيانات التسجيل
  ///
  /// In ar, this message translates to:
  /// **'جاري تحميل بيانات التسجيل...'**
  String get loadingRegistrationData;

  /// رسالة إرسال الموقع
  ///
  /// In ar, this message translates to:
  /// **'جاري إرسال الموقع...'**
  String get sendingLocation;

  /// فشل في تحميل الصورة
  ///
  /// In ar, this message translates to:
  /// **'فشل في تحميل الصورة'**
  String get failedToLoadImage;

  /// رسالة فشل اختيار الصورة
  ///
  /// In ar, this message translates to:
  /// **'فشل في اختيار الصورة'**
  String get failedToSelectImage;

  /// رسالة فشل اختيار الملف
  ///
  /// In ar, this message translates to:
  /// **'فشل في اختيار الملف'**
  String get failedToSelectFile;

  /// نص عنصر غير محدد
  ///
  /// In ar, this message translates to:
  /// **'عنصر غير محدد'**
  String get undefinedItem;

  /// رسالة عدم القدرة على الوصول لتفاصيل الإعلان
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن الوصول لتفاصيل الإعلان'**
  String get cannotAccessAdDetails;

  /// رسالة نجاح اختيار الملف
  ///
  /// In ar, this message translates to:
  /// **'تم اختيار الملف: {fileName}'**
  String fileSelectedSuccessfully(String fileName);

  /// نص رقم الهاتف هو نفسه الواتساب
  ///
  /// In ar, this message translates to:
  /// **'رقم هاتفي هو نفسه رقم الواتساب'**
  String get phoneIsWhatsApp;

  /// رسالة تصحيح أخطاء البيانات الأساسية
  ///
  /// In ar, this message translates to:
  /// **'يرجى تصحيح الأخطاء في البيانات الأساسية'**
  String get correctBasicDataErrors;

  /// رسالة اختيار المركبة ونوعها وحجمها
  ///
  /// In ar, this message translates to:
  /// **'يرجى اختيار المركبة ونوعها وحجمها'**
  String get selectVehicleTypeSize;

  /// رسالة ملء جميع الحقول الإضافية
  ///
  /// In ar, this message translates to:
  /// **'يرجى ملء جميع الحقول المطلوبة في المعلومات الإضافية'**
  String get fillAllAdditionalFields;

  /// رسالة خطأ جلب تفاصيل المهمة
  ///
  /// In ar, this message translates to:
  /// **'خطأ في جلب تفاصيل المهمة: {error}'**
  String taskDetailsError(String error);

  /// رسالة خطأ أثناء التسجيل
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ أثناء التسجيل'**
  String get registrationErrorOccurred;

  /// رسالة خطأ تحديث الملف الشخصي
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ أثناء تحديث الملف الشخصي'**
  String get profileUpdateError;

  /// رسالة خطأ تغيير كلمة المرور
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ أثناء تغيير كلمة المرور'**
  String get passwordChangeError;

  /// رسالة خطأ إرسال الموقع
  ///
  /// In ar, this message translates to:
  /// **'خطأ في إرسال الموقع'**
  String locationSendError(String error);

  /// نص تفاصيل الموقع المرسل
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الموقع المرسل'**
  String get sentLocationDetails;

  /// رسالة خطأ جلب سجل المهمة
  ///
  /// In ar, this message translates to:
  /// **'خطأ في جلب سجل المهمة: {error}'**
  String taskHistoryError(String error);

  /// رسالة خطأ اختيار الملف
  ///
  /// In ar, this message translates to:
  /// **'خطأ في اختيار الملف: {error}'**
  String fileSelectionError(String error);

  /// رسالة نجاح إضافة الملاحظة
  ///
  /// In ar, this message translates to:
  /// **'تم إضافة الملاحظة بنجاح'**
  String get noteAddedSuccessfully;

  /// رسالة خطأ إضافة الملاحظة
  ///
  /// In ar, this message translates to:
  /// **'خطأ في إضافة الملاحظة: {error}'**
  String noteAddError(String error);

  /// رسالة خطأ فتح المرفق
  ///
  /// In ar, this message translates to:
  /// **'خطأ في فتح المرفق: {error}'**
  String attachmentOpenError(String error);

  /// خطأ في تحميل الصورة
  ///
  /// In ar, this message translates to:
  /// **'خطأ في تحميل الصورة'**
  String get imageLoadError;

  /// خطأ في تحميل الملف
  ///
  /// In ar, this message translates to:
  /// **'خطأ في تحميل الملف'**
  String get fileDownloadError;

  /// خطأ في فتح الملف
  ///
  /// In ar, this message translates to:
  /// **'خطأ في فتح الملف'**
  String get fileOpenError;

  /// تم فتح الملف للتحميل
  ///
  /// In ar, this message translates to:
  /// **'تم فتح الملف للتحميل'**
  String get fileOpenedForDownload;

  /// متطلبات كلمة المرور
  ///
  /// In ar, this message translates to:
  /// **'• 8 أحرف على الأقل\n• حرف كبير واحد على الأقل (A-Z)\n• حرف صغير واحد على الأقل (a-z)\n• رقم واحد على الأقل (0-9)'**
  String get passwordRequirements;

  /// نصائح أمان كلمة المرور
  ///
  /// In ar, this message translates to:
  /// **'• لا تشارك كلمة المرور مع أي شخص\n• استخدم كلمة مرور قوية وفريدة\n• غير كلمة المرور بانتظام\n• لا تستخدم معلومات شخصية في كلمة المرور'**
  String get passwordSecurityTips;

  /// رسالة عارض الملفات قريباً
  ///
  /// In ar, this message translates to:
  /// **'عارض الملفات قريباً'**
  String get fileViewerComingSoon;

  /// رسالة فتح الرابط قريباً
  ///
  /// In ar, this message translates to:
  /// **'فتح الرابط قريباً'**
  String get linkOpenComingSoon;

  /// رسالة قبول العرض للمهمة
  ///
  /// In ar, this message translates to:
  /// **'تم قبول عرضك لهذه المهمة!\n\nهل تريد قبول المهمة والبدء في تنفيذها؟\n\nبعد القبول ستصبح المهمة مسندة إليك رسمياً وستظهر في قائمة مهامك الحالية.'**
  String get taskOfferAccepted;

  /// عنوان البيانات الأساسية
  ///
  /// In ar, this message translates to:
  /// **'البيانات الأساسية'**
  String get basicData;

  /// عنوان المعلومات التكميلية
  ///
  /// In ar, this message translates to:
  /// **'المعلومات التكميلية'**
  String get additionalInfo;

  /// عنوان المراجعة والتأكيد
  ///
  /// In ar, this message translates to:
  /// **'المراجعة والتأكيد'**
  String get reviewAndConfirm;

  /// تسمية الاسم الكامل
  ///
  /// In ar, this message translates to:
  /// **'الاسم الكامل'**
  String get fullName;

  /// رسالة خطأ الاسم الكامل مطلوب
  ///
  /// In ar, this message translates to:
  /// **'الاسم الكامل مطلوب'**
  String get fullNameRequired;

  /// تسمية اسم المستخدم
  ///
  /// In ar, this message translates to:
  /// **'اسم المستخدم'**
  String get username;

  /// رسالة خطأ اسم المستخدم مطلوب
  ///
  /// In ar, this message translates to:
  /// **'اسم المستخدم مطلوب'**
  String get usernameRequired;

  /// رسالة خطأ البريد الإلكتروني مطلوب
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني مطلوب'**
  String get emailRequired;

  /// رسالة خطأ البريد الإلكتروني غير صحيح
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني غير صحيح'**
  String get invalidEmail;

  /// رسالة خطأ رقم الهاتف مطلوب
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف مطلوب'**
  String get phoneRequired;

  /// تسمية كلمة المرور
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get password;

  /// رسالة خطأ كلمة المرور مطلوبة
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور مطلوبة'**
  String get passwordRequired;

  /// رسالة خطأ طول كلمة المرور 8 أحرف
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور يجب أن تكون 8 أحرف على الأقل'**
  String get passwordMinLength8;

  /// تسمية تأكيد كلمة المرور
  ///
  /// In ar, this message translates to:
  /// **'تأكيد كلمة المرور'**
  String get confirmPassword;

  /// رسالة خطأ تأكيد كلمة المرور مطلوب
  ///
  /// In ar, this message translates to:
  /// **'تأكيد كلمة المرور مطلوب'**
  String get confirmPasswordRequired;

  /// رسالة خطأ كلمات المرور غير متطابقة
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور غير متطابقة'**
  String get passwordsDoNotMatch;

  /// رسالة خطأ العنوان مطلوب
  ///
  /// In ar, this message translates to:
  /// **'العنوان مطلوب'**
  String get addressRequired;

  /// تسمية المركبة
  ///
  /// In ar, this message translates to:
  /// **'المركبة'**
  String get vehicle;

  /// نص اختيار المركبة
  ///
  /// In ar, this message translates to:
  /// **'اختر المركبة'**
  String get selectVehicle;

  /// رسالة خطأ اختيار المركبة مطلوب
  ///
  /// In ar, this message translates to:
  /// **'اختيار المركبة مطلوب'**
  String get vehicleRequired;

  /// نص اختيار نوع المركبة
  ///
  /// In ar, this message translates to:
  /// **'اختر نوع المركبة'**
  String get selectVehicleType;

  /// رسالة خطأ اختيار نوع المركبة مطلوب
  ///
  /// In ar, this message translates to:
  /// **'اختيار نوع المركبة مطلوب'**
  String get vehicleTypeRequired;

  /// نص اختيار حجم المركبة
  ///
  /// In ar, this message translates to:
  /// **'اختر حجم المركبة'**
  String get selectVehicleSize;

  /// رسالة خطأ اختيار حجم المركبة مطلوب
  ///
  /// In ar, this message translates to:
  /// **'اختيار حجم المركبة مطلوب'**
  String get vehicleSizeRequired;

  /// نص اختيار الفريق الاختياري
  ///
  /// In ar, this message translates to:
  /// **'اختر فريق (اختياري)'**
  String get selectTeamOptional;

  /// نص واتساب
  ///
  /// In ar, this message translates to:
  /// **'واتساب'**
  String get whatsapp;

  /// نص رقم الهاتف هو واتساب
  ///
  /// In ar, this message translates to:
  /// **'رقم هاتفي هو نفسه رقم الواتساب'**
  String get phoneIsWhatsAppNumber;

  /// رسالة إدخال واتساب أو اختيار الهاتف
  ///
  /// In ar, this message translates to:
  /// **'الرجاء إدخال رقم واتساب أو اختيار أن الهاتف هو واتساب'**
  String get enterWhatsAppOrSelectPhone;

  /// عنوان المعلومات التكميلية المطلوبة
  ///
  /// In ar, this message translates to:
  /// **'المعلومات التكميلية مطلوبة'**
  String get requiredAdditionalInfo;

  /// رسالة خطأ حقل مطلوب
  ///
  /// In ar, this message translates to:
  /// **'{fieldName} مطلوب'**
  String fieldRequired(String fieldName);

  /// رسالة خطأ يجب أن يكون رقم صحيح
  ///
  /// In ar, this message translates to:
  /// **'يجب أن يكون رقماً صحيحاً'**
  String get mustBeValidNumber;

  /// رسالة خطأ الرابط غير صحيح
  ///
  /// In ar, this message translates to:
  /// **'الرابط غير صحيح'**
  String get invalidUrl;

  /// نص اختيار خيار
  ///
  /// In ar, this message translates to:
  /// **'اختر {fieldName}'**
  String selectOption(String fieldName);

  /// رسالة تم اختيار الملف
  ///
  /// In ar, this message translates to:
  /// **'تم اختيار الملف'**
  String get fileSelected;

  /// نص اختيار ملف
  ///
  /// In ar, this message translates to:
  /// **'اضغط لاختيار ملف'**
  String get selectFile;

  /// عنوان مراجعة البيانات
  ///
  /// In ar, this message translates to:
  /// **'مراجعة البيانات'**
  String get dataReview;

  /// عنوان الحقول الإضافية
  ///
  /// In ar, this message translates to:
  /// **'الحقول الإضافية'**
  String get additionalFields;

  /// نص الموافقة على الشروط
  ///
  /// In ar, this message translates to:
  /// **'بالضغط على \"إنشاء الحساب\" فإنك توافق على شروط الاستخدام وسياسة الخصوصية'**
  String get agreeToTerms;

  /// نص إرسال رابط التحقق
  ///
  /// In ar, this message translates to:
  /// **'سيتم إرسال رابط التحقق إلى بريدك الإلكتروني لتفعيل حسابك'**
  String get verificationEmailSent;

  /// نص إنشاء الحساب
  ///
  /// In ar, this message translates to:
  /// **'إنشاء الحساب'**
  String get createAccount;

  /// نص التالي
  ///
  /// In ar, this message translates to:
  /// **'التالي'**
  String get next;

  /// رسالة فشل التسجيل
  ///
  /// In ar, this message translates to:
  /// **'فشل في التسجيل'**
  String get registrationFailed;

  /// رسالة التحقق من البريد وتفعيل الحساب
  ///
  /// In ar, this message translates to:
  /// **'يرجى التحقق من بريدك الإلكتروني وتفعيل حسابك، ثم العودة لتسجيل الدخول.'**
  String get checkEmailAndActivate;

  /// نص تسجيل الدخول
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get loginText;

  /// رسالة خطأ عند عدم تطابق كلمة المرور
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور غير متطابقة'**
  String get passwordMismatch;

  /// رسالة خطأ عند عدم اختيار المركبة
  ///
  /// In ar, this message translates to:
  /// **'اختيار المركبة مطلوب'**
  String get selectVehicleRequired;

  /// رسالة خطأ عند عدم اختيار نوع المركبة
  ///
  /// In ar, this message translates to:
  /// **'اختيار نوع المركبة مطلوب'**
  String get selectVehicleTypeRequired;

  /// رسالة خطأ عند عدم اختيار حجم المركبة
  ///
  /// In ar, this message translates to:
  /// **'اختيار حجم المركبة مطلوب'**
  String get selectVehicleSizeRequired;

  /// نص اختيار الفريق
  ///
  /// In ar, this message translates to:
  /// **'اختر الفريق'**
  String get selectTeam;

  /// رسالة خطأ عند عدم اختيار الفريق
  ///
  /// In ar, this message translates to:
  /// **'اختيار الفريق مطلوب'**
  String get selectTeamRequired;

  /// نص رقم واتساب الاختياري
  ///
  /// In ar, this message translates to:
  /// **'رقم واتساب للتواصل (اختياري)'**
  String get whatsappNumberOptional;

  /// نص رقم الهاتف هو نفسه رقم الواتساب
  ///
  /// In ar, this message translates to:
  /// **'رقم هاتفي هو نفسه رقم الواتساب'**
  String get phoneIsWhatsapp;

  /// رسالة خطأ عند عدم إدخال رقم واتساب
  ///
  /// In ar, this message translates to:
  /// **'الرجاء إدخال رقم واتساب أو اختيار أن الهاتف هو واتساب'**
  String get whatsappRequired;

  /// نص المعلومات التكميلية المطلوبة
  ///
  /// In ar, this message translates to:
  /// **'المعلومات التكميلية مطلوبة'**
  String get additionalInfoRequired;

  /// نص placeholder لحقل رقم الهاتف
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف'**
  String get phoneNumberPlaceholder;

  /// نص placeholder لحقل رقم الواتساب
  ///
  /// In ar, this message translates to:
  /// **'رقم الواتساب'**
  String get whatsappNumberPlaceholder;

  /// رسالة نجح الإرسال
  ///
  /// In ar, this message translates to:
  /// **'تم الإرسال بنجاح'**
  String get sentSuccessfully;

  /// رسالة إرسال رابط إعادة التعيين
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال رابط إعادة تعيين كلمة المرور إلى:'**
  String get resetLinkSentTo;

  /// تعليمات إدخال البريد الإلكتروني
  ///
  /// In ar, this message translates to:
  /// **'أدخل بريدك الإلكتروني وسنرسل لك رابط إعادة تعيين كلمة المرور'**
  String get enterEmailForReset;

  /// نص placeholder البريد الإلكتروني
  ///
  /// In ar, this message translates to:
  /// **'أدخل بريدك الإلكتروني'**
  String get enterYourEmail;

  /// نص زر إرسال رابط إعادة التعيين
  ///
  /// In ar, this message translates to:
  /// **'إرسال رابط إعادة التعيين'**
  String get sendResetLink;

  /// رسالة خطأ عند إدخال بريد إلكتروني غير صحيح
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال بريد إلكتروني صحيح'**
  String get pleaseEnterValidEmail;

  /// نص الموافقة على الشروط والخصوصية
  ///
  /// In ar, this message translates to:
  /// **'بالضغط على \"إنشاء الحساب\" فإنك توافق على شروط الاستخدام وسياسة الخصوصية'**
  String get termsAndPrivacyAgreement;

  /// نص زر العودة إلى تسجيل الدخول
  ///
  /// In ar, this message translates to:
  /// **'العودة لتسجيل الدخول'**
  String get backToLogin;

  /// رسالة إرسال رابط التحقق
  ///
  /// In ar, this message translates to:
  /// **'سيتم إرسال رابط التحقق إلى بريدك الإلكتروني لتفعيل حسابك'**
  String get verificationLinkWillBeSent;

  /// كلمة الكل
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get all;

  /// الإيداعات
  ///
  /// In ar, this message translates to:
  /// **'الإيداعات'**
  String get deposits;

  /// مع مرفقات
  ///
  /// In ar, this message translates to:
  /// **'مع مرفقات'**
  String get withAttachments;

  /// النوع
  ///
  /// In ar, this message translates to:
  /// **'النوع'**
  String get type;

  /// التاريخ
  ///
  /// In ar, this message translates to:
  /// **'التاريخ'**
  String get date;

  /// الوقت
  ///
  /// In ar, this message translates to:
  /// **'الوقت'**
  String get time;

  /// اختيار فترة زمنية
  ///
  /// In ar, this message translates to:
  /// **'اختيار فترة زمنية'**
  String get selectDateRange;

  /// رقم المرجع
  ///
  /// In ar, this message translates to:
  /// **'رقم المرجع'**
  String get referenceNumber;

  /// تاريخ الاستحقاق
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الاستحقاق'**
  String get maturityDate;

  /// المرفق
  ///
  /// In ar, this message translates to:
  /// **'المرفق'**
  String get attachment;

  /// اضغط للعرض
  ///
  /// In ar, this message translates to:
  /// **'اضغط للعرض'**
  String get tapToView;

  /// لا توجد معاملات مع مرفقات
  ///
  /// In ar, this message translates to:
  /// **'لا توجد معاملات مع مرفقات'**
  String get noTransactionsWithAttachments;

  /// اضغط على فتح لعرض الملف
  ///
  /// In ar, this message translates to:
  /// **'اضغط على \"فتح\" لعرض الملف'**
  String get tapOpenToViewFile;

  /// نص البحث في المعاملات
  ///
  /// In ar, this message translates to:
  /// **'البحث في المعاملات...'**
  String get searchInTransactions;

  /// لا توجد معاملات تطابق البحث
  ///
  /// In ar, this message translates to:
  /// **'لم يتم العثور على معاملات تطابق البحث'**
  String get noTransactionsFound;

  /// لا توجد معاملات من نوع معين
  ///
  /// In ar, this message translates to:
  /// **'لا توجد معاملات من نوع'**
  String get noTransactionsOfType;

  /// وصف عدم وجود معاملات مع مرفقات
  ///
  /// In ar, this message translates to:
  /// **'لم يتم العثور على معاملات تحتوي على صور أو ملفات'**
  String get noTransactionsWithAttachmentsDescription;

  /// تسمية المرفق
  ///
  /// In ar, this message translates to:
  /// **'مرفق'**
  String get attachmentLabel;

  /// تسمية رقم المرجع
  ///
  /// In ar, this message translates to:
  /// **'رقم المرجع'**
  String get referenceNumberLabel;

  /// فلترة
  ///
  /// In ar, this message translates to:
  /// **'فلترة'**
  String get filter;

  /// تحديث
  ///
  /// In ar, this message translates to:
  /// **'تحديث'**
  String get refresh;

  /// لا توجد إعلانات متاحة
  ///
  /// In ar, this message translates to:
  /// **'لا توجد إعلانات متاحة'**
  String get noAdsAvailable;

  /// وصف عدم وجود إعلانات متاحة
  ///
  /// In ar, this message translates to:
  /// **'لا توجد إعلانات مهام متاحة في الوقت الحالي'**
  String get noAdsAvailableDescription;

  /// تفاصيل الإعلان
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الإعلان'**
  String get adDetails;

  /// العروض المقدمة
  ///
  /// In ar, this message translates to:
  /// **'العروض المقدمة'**
  String get submittedOffers;

  /// لا يمكنك عرض العروض المقدمة
  ///
  /// In ar, this message translates to:
  /// **'لا يمكنك عرض العروض المقدمة'**
  String get cannotViewOffers;

  /// لم يتم تقديم أي عروض لهذا الإعلان بعد
  ///
  /// In ar, this message translates to:
  /// **'لم يتم تقديم أي عروض لهذا الإعلان بعد'**
  String get noOffersSubmittedDescription;

  /// تأكيد قبول المهمة
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من رغبتك في قبول هذه المهمة؟'**
  String get acceptTaskConfirmation;

  /// اسم المسؤول
  ///
  /// In ar, this message translates to:
  /// **'اسم المسؤول'**
  String get contactName;

  /// الشخص المسؤول
  ///
  /// In ar, this message translates to:
  /// **'الشخص المسؤول'**
  String get contactPerson;

  /// في انتظار الموافقة
  ///
  /// In ar, this message translates to:
  /// **'في انتظار الموافقة'**
  String get pendingApproval;

  /// لا يمكن التراجع عن هذا الإجراء
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن التراجع عن هذا الإجراء.'**
  String get cannotUndo;

  /// تم التحديث بنجاح
  ///
  /// In ar, this message translates to:
  /// **'تم التحديث بنجاح'**
  String get updatedSuccessfully;

  /// عنوان رسالة عدم وجود اتصال بالإنترنت
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد اتصال بالإنترنت'**
  String get noInternetConnection;

  /// رسالة توضيحية لضرورة الاتصال بالإنترنت
  ///
  /// In ar, this message translates to:
  /// **'يحتاج التطبيق إلى الاتصال بالإنترنت للعمل بشكل صحيح. يرجى التأكد من اتصالك بالإنترنت ثم المحاولة مرة أخرى.'**
  String get internetConnectionRequired;

  /// عنوان خطأ التهيئة
  ///
  /// In ar, this message translates to:
  /// **'خطأ في التهيئة'**
  String get initializationError;

  /// رسالة خطأ التهيئة
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ أثناء تهيئة التطبيق. يرجى المحاولة مرة أخرى.'**
  String get initializationErrorMessage;

  /// وصف التطبيق
  ///
  /// In ar, this message translates to:
  /// **'تطبيق السائقين'**
  String get driversApp;

  /// مرفوض
  ///
  /// In ar, this message translates to:
  /// **'مرفوض'**
  String get rejected;

  /// فشل في تحميل العروض
  ///
  /// In ar, this message translates to:
  /// **'فشل في تحميل العروض'**
  String get failedToLoadOffers;

  /// تحديث العرض
  ///
  /// In ar, this message translates to:
  /// **'تحديث العرض'**
  String get updateOffer;

  /// عنوان سجل المهمة
  ///
  /// In ar, this message translates to:
  /// **'سجل المهمة #{taskId}'**
  String taskHistoryTitle(String taskId);

  /// رسالة خطأ جلب سجل المهمة
  ///
  /// In ar, this message translates to:
  /// **'خطأ في جلب سجل المهمة: {error}'**
  String errorLoadingTaskHistory(String error);

  /// رسالة فشل إضافة الملاحظة
  ///
  /// In ar, this message translates to:
  /// **'فشل في إضافة الملاحظة'**
  String get failedToAddNote;

  /// رسالة اضغط على فتح لعرض الملف
  ///
  /// In ar, this message translates to:
  /// **'اضغط على \"فتح\" لعرض الملف'**
  String get clickOpenToViewFile;

  /// حالة المهمة: مخصصة
  ///
  /// In ar, this message translates to:
  /// **'مخصصة'**
  String get taskStatusAssign;

  /// حالة المهمة: بدأت
  ///
  /// In ar, this message translates to:
  /// **'بدأت'**
  String get taskStatusStarted;

  /// حالة المهمة: في نقطة الاستلام
  ///
  /// In ar, this message translates to:
  /// **'في نقطة الاستلام'**
  String get taskStatusInPickupPoint;

  /// حالة المهمة: جاري التحميل
  ///
  /// In ar, this message translates to:
  /// **'جاري التحميل'**
  String get taskStatusLoading;

  /// حالة المهمة: في الطريق
  ///
  /// In ar, this message translates to:
  /// **'في الطريق'**
  String get taskStatusInTheWay;

  /// حالة المهمة: في نقطة التسليم
  ///
  /// In ar, this message translates to:
  /// **'في نقطة التسليم'**
  String get taskStatusInDeliveryPoint;

  /// حالة المهمة: جاري التفريغ
  ///
  /// In ar, this message translates to:
  /// **'جاري التفريغ'**
  String get taskStatusUnloading;

  /// حالة المهمة: مكتملة
  ///
  /// In ar, this message translates to:
  /// **'مكتملة'**
  String get taskStatusCompleted;

  /// حالة المهمة: ملغية
  ///
  /// In ar, this message translates to:
  /// **'ملغية'**
  String get taskStatusCancelled;

  /// No description provided for @updateLocation.
  ///
  /// In ar, this message translates to:
  /// **'تحديث الموقع الجغرافي'**
  String get updateLocation;

  /// No description provided for @locationSent.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال الموقع'**
  String get locationSent;

  /// No description provided for @importantNotes.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات مهمة:'**
  String get importantNotes;

  /// No description provided for @checkInboxAndSpam.
  ///
  /// In ar, this message translates to:
  /// **'• تحقق من صندوق البريد الوارد والرسائل المزعجة'**
  String get checkInboxAndSpam;

  /// No description provided for @linkValidOneHour.
  ///
  /// In ar, this message translates to:
  /// **'• الرابط صالح لمدة ساعة واحدة فقط'**
  String get linkValidOneHour;

  /// No description provided for @noEmailRetry.
  ///
  /// In ar, this message translates to:
  /// **'• إذا لم تستلم الرسالة خلال 5 دقائق، يمكنك المحاولة مرة أخرى'**
  String get noEmailRetry;

  /// No description provided for @taskAssignedToDriver.
  ///
  /// In ar, this message translates to:
  /// **'تم تخصيص المهمة للسائق'**
  String get taskAssignedToDriver;

  /// No description provided for @driverStartedTask.
  ///
  /// In ar, this message translates to:
  /// **'بدأ السائق في تنفيذ المهمة'**
  String get driverStartedTask;

  /// No description provided for @driverArrivedPickup.
  ///
  /// In ar, this message translates to:
  /// **'وصل السائق لنقطة الاستلام'**
  String get driverArrivedPickup;

  /// No description provided for @loadingGoods.
  ///
  /// In ar, this message translates to:
  /// **'يتم تحميل البضائع'**
  String get loadingGoods;

  /// No description provided for @driverOnWayDelivery.
  ///
  /// In ar, this message translates to:
  /// **'السائق في طريقه لنقطة التسليم'**
  String get driverOnWayDelivery;

  /// No description provided for @driverArrivedDelivery.
  ///
  /// In ar, this message translates to:
  /// **'وصل السائق لنقطة التسليم'**
  String get driverArrivedDelivery;

  /// No description provided for @unloadingGoods.
  ///
  /// In ar, this message translates to:
  /// **'يتم تفريغ البضائع'**
  String get unloadingGoods;

  /// No description provided for @taskCompletedSuccessfully.
  ///
  /// In ar, this message translates to:
  /// **'تم إكمال المهمة بنجاح'**
  String get taskCompletedSuccessfully;

  /// No description provided for @newLabel.
  ///
  /// In ar, this message translates to:
  /// **'جديد'**
  String get newLabel;

  /// No description provided for @daysAgoPlural.
  ///
  /// In ar, this message translates to:
  /// **'أيام مضت'**
  String get daysAgoPlural;

  /// No description provided for @hoursAgoPlural.
  ///
  /// In ar, this message translates to:
  /// **'ساعات مضت'**
  String get hoursAgoPlural;

  /// No description provided for @minutesAgoPlural.
  ///
  /// In ar, this message translates to:
  /// **'دقائق مضت'**
  String get minutesAgoPlural;
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
