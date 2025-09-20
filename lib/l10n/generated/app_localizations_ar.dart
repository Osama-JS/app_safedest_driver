// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'سيف ديستس - السائق';

  @override
  String get settings => 'الإعدادات';

  @override
  String get appSettings => 'إعدادات التطبيق';

  @override
  String get language => 'لغة التطبيق';

  @override
  String get chooseLanguage => 'اختر لغة واجهة التطبيق';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'English';

  @override
  String get theme => 'مظهر التطبيق';

  @override
  String get chooseTheme => 'اختر بين الوضع الفاتح والداكن';

  @override
  String get lightMode => 'الوضع الفاتح';

  @override
  String get darkMode => 'الوضع الداكن';

  @override
  String get systemMode => 'تلقائي (حسب النظام)';

  @override
  String get notifications => 'إعدادات الإشعارات';

  @override
  String get taskNotifications => 'إشعارات المهام';

  @override
  String get taskNotificationsDesc => 'تلقي إشعارات عند وصول مهام جديدة';

  @override
  String get walletNotifications => 'إشعارات المحفظة';

  @override
  String get walletNotificationsDesc => 'تلقي إشعارات عند تحديث المحفظة';

  @override
  String get systemNotifications => 'إشعارات النظام';

  @override
  String get systemNotificationsDesc => 'تلقي إشعارات النظام والتحديثات';

  @override
  String get about => 'حول التطبيق';

  @override
  String get version => 'الإصدار';

  @override
  String get termsOfService => 'شروط الاستخدام';

  @override
  String get termsOfServiceDesc => 'اقرأ شروط استخدام التطبيق';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get privacyPolicyDesc => 'اقرأ سياسة الخصوصية';

  @override
  String get helpSupport => 'المساعدة والدعم';

  @override
  String get helpSupportDesc => 'الحصول على المساعدة';

  @override
  String get resetSettings => 'إعادة تعيين الإعدادات';

  @override
  String get resetSettingsDesc => 'إعادة جميع الإعدادات إلى القيم الافتراضية';

  @override
  String get reset => 'إعادة تعيين';

  @override
  String get cancel => 'إلغاء';

  @override
  String get confirm => 'تأكيد';

  @override
  String get resetConfirmTitle => 'إعادة تعيين الإعدادات';

  @override
  String get resetConfirmMessage =>
      'هل أنت متأكد من أنك تريد إعادة جميع الإعدادات إلى القيم الافتراضية؟\n\nلا يمكن التراجع عن هذا الإجراء.';

  @override
  String get resetSuccess => 'تم إعادة تعيين الإعدادات بنجاح';

  @override
  String get home => 'الرئيسية';

  @override
  String get tasks => 'المهام';

  @override
  String get wallet => 'المحفظة';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String welcomeDriver(String driverName) {
    return 'مرحباً $driverName';
  }

  @override
  String get driver => 'سائق';

  @override
  String get dataRefreshSuccess => 'تم تحديث البيانات بنجاح';

  @override
  String get dataRefreshFailed => 'فشل في تحديث البيانات';

  @override
  String get taskAds => 'إعلانات المهام';

  @override
  String get taskAdsDescription => 'تصفح الإعلانات المتاحة وقدم عروضك';

  @override
  String get availableAds => 'الإعلانات المتاحة';

  @override
  String get myOffers => 'عروضي المقدمة';

  @override
  String get acceptedOffers => 'العروض المقبولة';

  @override
  String get browseAds => 'تصفح الإعلانات';

  @override
  String get notificationsComingSoon => 'شاشة الإشعارات قريباً';

  @override
  String get exitConfirmation => 'تأكيد الخروج';

  @override
  String get exitConfirmMessage =>
      'هل أنت متأكد من أنك تريد الخروج من التطبيق؟';

  @override
  String get exitConfirmDescription => 'سيتم إغلاق التطبيق نهائياً.';

  @override
  String get exit => 'خروج';

  @override
  String get refreshTasks => 'تحديث المهام';

  @override
  String get availableTasks => 'المتاحة';

  @override
  String get currentTasks => 'الحالية';

  @override
  String get completedTasks => 'المكتملة';

  @override
  String get loadingTasks => 'جاري تحميل المهام...';

  @override
  String get unexpectedError => 'حدث خطأ غير متوقع';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get noAvailableTasks => 'لا توجد مهام متاحة';

  @override
  String get noAvailableTasksDescription =>
      'لا توجد مهام متاحة للقبول في الوقت الحالي';

  @override
  String get noCurrentTasks => 'لا توجد مهام حالية';

  @override
  String get noCompletedTasks => 'لا توجد مهام مكتملة';

  @override
  String get taskAcceptedSuccess => 'تم قبول المهمة بنجاح';

  @override
  String get taskRejected => 'تم رفض المهمة';

  @override
  String get taskStatusUpdated => 'تم تحديث حالة المهمة';

  @override
  String get transactionHistory => 'سجل المعاملات';

  @override
  String get quickActions => 'إجراءات سريعة';

  @override
  String get cashWithdrawal => 'سحب نقدي';

  @override
  String get accountStatement => 'كشف حساب';

  @override
  String get support => 'الدعم';

  @override
  String get withdrawalComingSoon => 'ميزة السحب النقدي قريباً';

  @override
  String get statementComingSoon => 'كشف الحساب قريباً';

  @override
  String get supportComingSoon => 'الدعم الفني قريباً';

  @override
  String get noDriverData => 'لا توجد بيانات للسائق';

  @override
  String get active => 'نشط';

  @override
  String get inactive => 'غير نشط';

  @override
  String get online => 'متصل';

  @override
  String get offline => 'غير متصل';

  @override
  String get accountInfo => 'معلومات الحساب';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get phone => 'رقم الهاتف';

  @override
  String get address => 'العنوان';

  @override
  String get team => 'الفريق';

  @override
  String get vehicleSize => 'حجم المركبة';

  @override
  String get additionalData => 'البيانات الإضافية';

  @override
  String get additionalDataDescription => 'عرض المعلومات التكميلية';

  @override
  String get systemDiagnostics => 'تشخيص النظام';

  @override
  String get systemDiagnosticsDescription => 'فحص حالة التطبيق والاتصالات';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get loggingOut => 'جاري تسجيل الخروج...';

  @override
  String get logoutConfirmation => 'تسجيل الخروج';

  @override
  String get logoutConfirmMessage => 'هل أنت متأكد من رغبتك في تسجيل الخروج؟';

  @override
  String get safeDriveApp => 'تطبيق SafeDests للسائقين';

  @override
  String get appDescription => 'تطبيق مخصص لإدارة المهام والتوصيل للسائقين';

  @override
  String get driverStatus => 'حالة السائق';

  @override
  String get connected => 'متصل';

  @override
  String get disconnected => 'غير متصل';

  @override
  String get availableForTasks => 'متاح للمهام';

  @override
  String get busy => 'مشغول';

  @override
  String get setBusy => 'تعيين كمشغول';

  @override
  String get setAvailable => 'تعيين كمتاح';

  @override
  String get name => 'الاسم';

  @override
  String get status => 'الحالة';

  @override
  String get vehicleType => 'نوع المركبة';

  @override
  String get notSpecified => 'غير محدد';

  @override
  String get earningsStatistics => 'إحصائيات الأرباح';

  @override
  String get today => 'اليوم';

  @override
  String get week => 'الأسبوع';

  @override
  String get month => 'الشهر';

  @override
  String get year => 'السنة';

  @override
  String periodSelected(String period) {
    return 'تم اختيار فترة: $period';
  }

  @override
  String get earningsChart => 'الرسم البياني للأرباح';

  @override
  String get comingSoon => 'قريباً';

  @override
  String get highestEarning => 'أعلى ربح';

  @override
  String get dailyAverage => 'متوسط يومي';

  @override
  String get totalEarnings => 'إجمالي الأرباح';

  @override
  String get noTransactionsYet => 'لا توجد معاملات مالية بعد';

  @override
  String get earningsSummary => 'ملخص الأرباح';

  @override
  String get details => 'التفاصيل';

  @override
  String get earningsDetailsComingSoon => 'تفاصيل الأرباح قريباً';

  @override
  String get noEarningsData => 'لا توجد بيانات أرباح حالياً';

  @override
  String get thisMonth => 'هذا الشهر';

  @override
  String get totalTasks => 'عدد المهام';

  @override
  String get averageEarningPerTask => 'متوسط الربح لكل مهمة';

  @override
  String get totalPeriod => 'إجمالي الفترة';

  @override
  String errorOccurred(String error) {
    return 'حدث خطأ: $error';
  }

  @override
  String get quickStats => 'إحصائيات سريعة';

  @override
  String get activeTasks => 'المهام النشطة';

  @override
  String get currentBalance => 'الرصيد الحالي';

  @override
  String get recentTasks => 'المهام الأخيرة';

  @override
  String get viewAll => 'عرض الكل';

  @override
  String get viewAllTasks => 'عرض جميع المهام';

  @override
  String get noTasksCurrently => 'لا توجد مهام حالياً';

  @override
  String taskNumber(String taskId) {
    return 'مهمة #$taskId';
  }

  @override
  String get pending => 'في الانتظار';

  @override
  String get accepted => 'مقبولة';

  @override
  String get pickedUp => 'تم الاستلام';

  @override
  String get inTransit => 'في الطريق';

  @override
  String get delivered => 'تم التسليم';

  @override
  String get cancelled => 'ملغية';

  @override
  String get days => 'يوم';

  @override
  String get hours => 'ساعة';

  @override
  String get minutes => 'دقيقة';

  @override
  String get now => 'الآن';

  @override
  String get pickupPoint => 'نقطة الاستلام';

  @override
  String get deliveryPoint => 'نقطة التسليم';

  @override
  String get items => 'العناصر';

  @override
  String yourEarnings(String amount) {
    return 'مستحقاتك: $amount ر.س';
  }

  @override
  String get viewDetails => 'عرض التفاصيل';

  @override
  String get reject => 'رفض';

  @override
  String get accept => 'قبول';

  @override
  String get arrivedAtPickup => 'وصلت لنقطة الاستلام';

  @override
  String get startLoading => 'بدء التحميل';

  @override
  String get onTheWay => 'في الطريق';

  @override
  String get arrivedAtDelivery => 'وصلت لنقطة التسليم';

  @override
  String get startUnloading => 'بدء التفريغ';

  @override
  String get completeTask => 'إكمال المهمة';

  @override
  String get recentTransactions => 'المعاملات الأخيرة';

  @override
  String get allTransactionsComingSoon => 'جميع المعاملات قريباً';

  @override
  String get noTransactions => 'لا توجد معاملات';

  @override
  String get noTransactionsRecorded => 'لم يتم تسجيل أي معاملات مالية بعد';

  @override
  String get loadingTransactions => 'جاري تحميل المعاملات...';

  @override
  String get noTransactionsCurrently => 'لا توجد معاملات حالياً';

  @override
  String get deposit => 'إيداع';

  @override
  String get withdrawal => 'سحب';

  @override
  String get commission => 'عمولة';

  @override
  String get cashDeposit => 'إيداع نقدي';

  @override
  String get completed => 'مكتمل';

  @override
  String get failed => 'فاشل';

  @override
  String get walletBalance => 'رصيد المحفظة';

  @override
  String get availableBalance => 'الرصيد المتاح';

  @override
  String get withdrawals => 'السحب';

  @override
  String get income => 'الدخل';

  @override
  String get newTask => 'مهمة جديدة!';

  @override
  String respondWithin(String time) {
    return 'الرد خلال: $time';
  }

  @override
  String get responseTimeExpired =>
      'انتهت مهلة الاستجابة، تم تحويل المهمة لسائق آخر';

  @override
  String from(String address) {
    return 'من: $address';
  }

  @override
  String to(String address) {
    return 'إلى: $address';
  }

  @override
  String amount(String amount) {
    return 'المبلغ: $amount ر.س';
  }

  @override
  String get taskAcceptedSuccessfully => 'تم قبول المهمة بنجاح';

  @override
  String get taskDetails => 'تفاصيل المهمة';

  @override
  String get taskId => 'رقم المهمة';

  @override
  String get paymentMethod => 'طريقة الدفع';

  @override
  String get pickupAddress => 'عنوان الاستلام';

  @override
  String get deliveryAddress => 'عنوان التسليم';

  @override
  String get totalAmount => 'المبلغ الإجمالي';

  @override
  String get creationDate => 'تاريخ الإنشاء';

  @override
  String get notes => 'ملاحظات';

  @override
  String get myOffer => 'عرضي';

  @override
  String get myOfferPending => 'عرضي في الانتظار';

  @override
  String get myOfferAccepted => 'تم قبول عرضي';

  @override
  String get myOfferRejected => 'تم رفض عرضي';

  @override
  String suggestedPrice(String price) {
    return 'السعر المقترح: $price ر.س';
  }

  @override
  String get offerDescription => 'وصف العرض:';

  @override
  String get netEarningsCalculation => 'حساب صافي المستحقات:';

  @override
  String offerPrice(String price) {
    return 'سعر العرض: $price ر.س';
  }

  @override
  String get serviceCommission => 'عمولة الخدمة';

  @override
  String get vat => 'ضريبة القيمة المضافة';

  @override
  String get netEarnings => 'صافي المستحقات';

  @override
  String submittedOn(String date) {
    return 'تم التقديم: $date';
  }

  @override
  String lastUpdated(String date) {
    return 'آخر تحديث: $date';
  }

  @override
  String adNumber(String adId) {
    return 'إعلان #$adId';
  }

  @override
  String get running => 'جاري';

  @override
  String get closed => 'مغلق';

  @override
  String get pickup => 'الاستلام';

  @override
  String get delivery => 'التسليم';

  @override
  String priceRange(String min, String max) {
    return 'نطاق الأسعار: $min - $max ر.س';
  }

  @override
  String offersCount(String count) {
    return 'عدد العروض: $count';
  }

  @override
  String get offerAccepted => 'تم قبول عرض';

  @override
  String get submitOffer => 'تقديم عرض';

  @override
  String get acceptTask => 'قبول المهمة';

  @override
  String get acceptTaskConfirm => 'هل أنت متأكد من رغبتك في قبول هذه المهمة؟';

  @override
  String get taskAcceptFailed => 'فشل في قبول المهمة';

  @override
  String taskHistory(String taskId) {
    return 'سجل المهمة #$taskId';
  }

  @override
  String get noTaskHistory => 'لا يوجد سجل للمهمة';

  @override
  String get addNote => 'إضافة ملاحظة';

  @override
  String get writeNoteHere => 'اكتب ملاحظتك هنا...';

  @override
  String get attachFile => 'إرفاق ملف';

  @override
  String get adding => 'جاري الإضافة...';

  @override
  String get add => 'إضافة';

  @override
  String get pleaseWriteNote => 'يرجى كتابة ملاحظة';

  @override
  String get noteAddedSuccess => 'تم إضافة الملاحظة بنجاح';

  @override
  String get noteAddFailed => 'فشل في إضافة الملاحظة';

  @override
  String errorAddingNote(String error) {
    return 'خطأ في إضافة الملاحظة: $error';
  }

  @override
  String errorSelectingFile(String error) {
    return 'خطأ في اختيار الملف: $error';
  }

  @override
  String errorOpeningAttachment(String error) {
    return 'خطأ في فتح المرفق: $error';
  }

  @override
  String errorLoadingImage(String error) {
    return 'خطأ في تحميل الصورة: $error';
  }

  @override
  String get clickOpenToView => 'اضغط على \"فتح\" لعرض الملف';

  @override
  String get download => 'تحميل';

  @override
  String get open => 'فتح';

  @override
  String errorDownloadingFile(String error) {
    return 'خطأ في تحميل الملف: $error';
  }

  @override
  String errorOpeningFile(String error) {
    return 'خطأ في فتح الملف: $error';
  }

  @override
  String get taskStages => 'مراحل المهمة';

  @override
  String get assigned => 'مخصصة';

  @override
  String get assignedDescription => 'تم تخصيص المهمة للسائق';

  @override
  String get started => 'بدأت';

  @override
  String get startedDescription => 'بدأ السائق في تنفيذ المهمة';

  @override
  String get inPickupPoint => 'في نقطة الاستلام';

  @override
  String get inPickupPointDescription => 'وصل السائق لنقطة الاستلام';

  @override
  String get loading => 'جاري التحميل';

  @override
  String get loadingDescription => 'يتم تحميل البضائع';

  @override
  String get inTheWay => 'في الطريق';

  @override
  String get inTheWayDescription => 'السائق في طريقه لنقطة التسليم';

  @override
  String get inDeliveryPoint => 'في نقطة التسليم';

  @override
  String get inDeliveryPointDescription => 'وصل السائق لنقطة التسليم';

  @override
  String get unloading => 'جاري التفريغ';

  @override
  String get unloadingDescription => 'يتم تفريغ البضائع';

  @override
  String get taskCompleted => 'مكتملة';

  @override
  String get taskCompletedDescription => 'تم إكمال المهمة بنجاح';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get whatsappNumber => 'رقم الواتساب';

  @override
  String get averagePerTask => 'متوسط المهمة';
}
