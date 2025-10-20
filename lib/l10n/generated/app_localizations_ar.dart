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
  String get notifications => 'الإشعارات';

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
  String get termsOfService => 'شروط الخدمة';

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
  String get myOffers => 'عروضي';

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
  String unexpectedError(String error) {
    return 'حدث خطأ غير متوقع: $error';
  }

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
  String get errorOccurred => 'حدث خطأ';

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
  String get accepted => 'مقبول';

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
  String get yourEarnings => 'مستحقاتك';

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
  String get withdrawals => 'السحوبات';

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
  String get amount => 'المبلغ';

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
  String get netEarningsCalculation => 'حساب صافي المستحقات';

  @override
  String get offerPrice => 'سعر العرض';

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
  String get priceRange => 'النطاق السعري';

  @override
  String get offersCount => 'عدد العروض';

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
  String get taskHistory => 'سجل المهمة';

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
  String get loading => 'جاري التحميل...';

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

  @override
  String get notificationsTitle => 'الإشعارات';

  @override
  String get markAllAsRead => 'تحديد الكل كمقروء';

  @override
  String get noNotifications => 'لا توجد إشعارات';

  @override
  String get newNotificationsWillAppearHere => 'ستظهر الإشعارات الجديدة هنا';

  @override
  String get newBadge => 'جديد';

  @override
  String get closeDialog => 'إغلاق';

  @override
  String get allNotificationsMarkedAsRead => 'تم تحديد جميع الإشعارات كمقروءة';

  @override
  String get failedToUpdateNotifications => 'فشل في تحديث الإشعارات';

  @override
  String get dayAgo => 'يوم مضى';

  @override
  String daysAgo(int days) {
    return 'منذ $days يوم';
  }

  @override
  String get hourAgo => 'ساعة مضت';

  @override
  String hoursAgo(int hours) {
    return 'منذ $hours ساعة';
  }

  @override
  String get minuteAgo => 'دقيقة مضت';

  @override
  String minutesAgo(int minutes) {
    return 'منذ $minutes دقيقة';
  }

  @override
  String get justNow => 'الآن';

  @override
  String get ago => 'مضت';

  @override
  String get since => 'منذ';

  @override
  String get taskDetailError => 'خطأ في جلب تفاصيل المهمة';

  @override
  String get errorTitle => 'خطأ';

  @override
  String get taskNotFound => 'لم يتم العثور على المهمة';

  @override
  String get quickNavigation => 'التنقل السريع';

  @override
  String get pickupLocation => 'نقطة الاستلام';

  @override
  String get deliveryLocation => 'نقطة التسليم';

  @override
  String get contactPersonName => 'اسم المسؤول';

  @override
  String get openInGoogleMaps => 'فتح في خرائط جوجل';

  @override
  String get unspecifiedItem => 'عنصر غير محدد';

  @override
  String get quantity => 'الكمية';

  @override
  String get awaitingApproval => 'في انتظار الموافقة';

  @override
  String get startTask => 'بدء المهمة';

  @override
  String get arrivedAtPickupPoint => 'وصلت لنقطة الاستلام';

  @override
  String get startLoadingGoods => 'بدء التحميل';

  @override
  String get onTheWayToDelivery => 'في الطريق';

  @override
  String get arrivedAtDeliveryPoint => 'وصلت لنقطة التسليم';

  @override
  String get startUnloadingGoods => 'بدء التفريغ';

  @override
  String get completeTaskButton => 'إكمال المهمة';

  @override
  String get cannotOpenGoogleMaps => 'لا يمكن فتح خرائط جوجل';

  @override
  String get mapOpenError => 'حدث خطأ في فتح الخريطة';

  @override
  String get confirmStatusUpdate => 'تأكيد تحديث الحالة';

  @override
  String get confirmStatusUpdateMessage =>
      'هل أنت متأكد من تحديث حالة المهمة إلى:';

  @override
  String get cannotUndoAction => 'لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get confirmButton => 'تأكيد';

  @override
  String get updatingTaskStatus => 'جاري تحديث حالة المهمة...';

  @override
  String get unexpectedErrorOccurred =>
      'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.';

  @override
  String get updateSuccessful => 'تم التحديث بنجاح';

  @override
  String taskStatusUpdatedTo(String status) {
    return 'تم تحديث حالة المهمة إلى: $status';
  }

  @override
  String get okButton => 'موافق';

  @override
  String get updateFailed => 'فشل في التحديث';

  @override
  String get failedToLoadAdDetails => 'فشل في تحميل تفاصيل الإعلان';

  @override
  String get refreshTooltip => 'تحديث';

  @override
  String get adDetailsTab => 'تفاصيل الإعلان';

  @override
  String get submittedOffersTab => 'العروض المقدمة';

  @override
  String get loadingDetails => 'جاري تحميل التفاصيل...';

  @override
  String get retryButton => 'إعادة المحاولة';

  @override
  String get noDataToDisplay => 'لا توجد بيانات للعرض';

  @override
  String get cannotViewSubmittedOffers => 'لا يمكنك عرض العروض المقدمة';

  @override
  String get mustSubmitOfferFirst => 'يجب تقديم عرض أولاً لعرض العروض الأخرى';

  @override
  String get noOffersSubmitted => 'لا توجد عروض مقدمة';

  @override
  String get noOffersSubmittedYet => 'لم يتم تقديم أي عروض لهذا الإعلان بعد';

  @override
  String get editOffer => 'تعديل العرض';

  @override
  String get acceptTaskConfirmTitle => 'قبول المهمة';

  @override
  String get acceptTaskConfirmMessage =>
      'هل أنت متأكد من رغبتك في قبول هذه المهمة؟';

  @override
  String get acceptButton => 'قبول';

  @override
  String get failedToAcceptTask => 'فشل في قبول المهمة';

  @override
  String get statusRunning => 'جاري';

  @override
  String get statusClosed => 'مغلق';

  @override
  String get taskDescription => 'وصف المهمة';

  @override
  String fromPrice(String price) {
    return 'من $price ر.س';
  }

  @override
  String toPrice(String price) {
    return 'إلى $price ر.س';
  }

  @override
  String get commissionAndTaxInfo => 'معلومات العمولة والضرائب';

  @override
  String get vatTax => 'ضريبة القيمة المضافة';

  @override
  String get statusPending => 'في الانتظار';

  @override
  String get statusAccepted => 'مقبول';

  @override
  String get statusRejected => 'مرفوض';

  @override
  String get proposedPrice => 'السعر المقترح';

  @override
  String get description => 'الوصف';

  @override
  String get failedToLoadAds => 'فشل في تحميل الإعلانات';

  @override
  String get taskAdsTitle => 'إعلانات المهام';

  @override
  String get filterTooltip => 'فلترة';

  @override
  String get availableAdsTab => 'الإعلانات المتاحة';

  @override
  String get myOffersTab => 'عروضي';

  @override
  String get searchInAds => 'البحث في الإعلانات...';

  @override
  String get totalAds => 'إجمالي الإعلانات';

  @override
  String get averagePrice => 'متوسط السعر';

  @override
  String get loadingAds => 'جاري تحميل الإعلانات...';

  @override
  String get noAvailableAds => 'لا توجد إعلانات متاحة';

  @override
  String get noAvailableAdsDescription =>
      'لا توجد إعلانات مهام متاحة في الوقت الحالي';

  @override
  String get filterAds => 'فلترة الإعلانات';

  @override
  String get minPrice => 'أقل سعر';

  @override
  String get maxPrice => 'أعلى سعر';

  @override
  String get sortBy => 'ترتيب حسب';

  @override
  String get sortByCreationDate => 'تاريخ الإنشاء';

  @override
  String get sortByLowestPrice => 'أقل سعر';

  @override
  String get sortByHighestPrice => 'أعلى سعر';

  @override
  String get sortByOffersCount => 'عدد العروض';

  @override
  String get sortOrder => 'ترتيب';

  @override
  String get descending => 'تنازلي';

  @override
  String get ascending => 'تصاعدي';

  @override
  String get clearFilters => 'مسح الفلاتر';

  @override
  String get applyFilters => 'تطبيق';

  @override
  String get offerUpdatedSuccessfully => 'تم تحديث العرض بنجاح';

  @override
  String get offerSubmittedSuccessfully => 'تم تقديم العرض بنجاح';

  @override
  String get failedToSubmitOffer => 'فشل في تقديم العرض';

  @override
  String get editOfferTitle => 'تعديل العرض';

  @override
  String get submitOfferTitle => 'تقديم عرض';

  @override
  String get adSummary => 'ملخص الإعلان';

  @override
  String get priceRangeLabel => 'النطاق السعري';

  @override
  String get proposedPriceRequired => 'السعر المقترح *';

  @override
  String get enterProposedPrice => 'أدخل السعر المقترح';

  @override
  String get pleaseEnterProposedPrice => 'يرجى إدخال السعر المقترح';

  @override
  String get pleaseEnterValidPrice => 'يرجى إدخال سعر صحيح';

  @override
  String get priceMustBeGreaterThanZero => 'يجب أن يكون السعر أكبر من صفر';

  @override
  String get priceBelowMinimum => 'السعر أقل من الحد الأدنى';

  @override
  String get priceAboveMaximum => 'السعر أعلى من الحد الأقصى';

  @override
  String get allowedRange => 'النطاق المسموح';

  @override
  String get offerDescriptionOptional => 'وصف العرض (اختياري)';

  @override
  String get addOfferDescription => 'أضف وصفاً لعرضك (اختياري)';

  @override
  String get updateOfferButton => 'تحديث العرض';

  @override
  String get submitOfferButton => 'تقديم العرض';

  @override
  String get unexpectedErrorTryAgain =>
      'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.';

  @override
  String get loginError => 'خطأ في تسجيل الدخول';

  @override
  String get agreeButton => 'موافق';

  @override
  String get welcomeToDriverApp => 'مرحباً بك في تطبيق السائقين';

  @override
  String get emailOrUsername => 'البريد الإلكتروني أو اسم المستخدم';

  @override
  String get enterEmailOrUsername => 'أدخل بريدك الإلكتروني أو اسم المستخدم';

  @override
  String get pleaseEnterEmail => 'يرجى إدخال البريد الإلكتروني';

  @override
  String get passwordLabel => 'كلمة المرور';

  @override
  String get enterPassword => 'أدخل كلمة المرور';

  @override
  String get pleaseEnterPassword => 'يرجى إدخال كلمة المرور';

  @override
  String get passwordMinLength => 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';

  @override
  String get loginButton => 'تسجيل الدخول';

  @override
  String get rememberMe => 'تذكرني';

  @override
  String get forgotPassword => 'نسيت كلمة المرور';

  @override
  String get dontHaveAccount => 'ليس لديك حساب؟';

  @override
  String get createNewAccount => 'إنشاء حساب جديد';

  @override
  String get byLoggingInYouAgree => 'بتسجيل الدخول، أنت توافق على';

  @override
  String get and => ' و ';

  @override
  String versionNumber(String version) {
    return 'الإصدار $version';
  }

  @override
  String get loginErrorTitle => 'خطأ في تسجيل الدخول';

  @override
  String get emailOrUsernameLabel => 'البريد الإلكتروني أو اسم المستخدم';

  @override
  String get enterEmailOrUsernameHint =>
      'أدخل بريدك الإلكتروني أو اسم المستخدم';

  @override
  String get pleaseEnterEmailError => 'يرجى إدخال البريد الإلكتروني';

  @override
  String get passwordFieldLabel => 'كلمة المرور';

  @override
  String get enterPasswordHint => 'أدخل كلمة المرور';

  @override
  String get pleaseEnterPasswordError => 'يرجى إدخال كلمة المرور';

  @override
  String get passwordMinLengthError =>
      'كلمة المرور يجب أن تكون 6 أحرف على الأقل';

  @override
  String get loginButtonText => 'تسجيل الدخول';

  @override
  String get rememberMeText => 'تذكرني';

  @override
  String get forgotPasswordText => 'نسيت كلمة المرور؟';

  @override
  String get dontHaveAccountText => 'ليس لديك حساب؟';

  @override
  String get createNewAccountText => 'إنشاء حساب جديد';

  @override
  String get byLoggingInYouAgreeText => 'بتسجيل الدخول، أنت توافق على';

  @override
  String get termsOfServiceText => 'شروط الخدمة';

  @override
  String get andText => ' و ';

  @override
  String get privacyPolicyText => 'سياسة الخصوصية';

  @override
  String get allText => 'الكل';

  @override
  String get supportContact => 'تواصل معنا';

  @override
  String get contactEmail => 'البريد الإلكتروني';

  @override
  String get contactWebsite => 'الموقع الإلكتروني';

  @override
  String get contactUs => 'اتصل بنا';

  @override
  String get accountInactive => 'حساب غير نشط';

  @override
  String get accountInactiveMessage =>
      'تم إيقاف حسابك. يرجى التواصل مع الإدارة للمزيد من المعلومات.';

  @override
  String get accountBlocked => 'حساب محظور';

  @override
  String get accountBlockedMessage => 'تم حظر حسابك. يرجى التواصل مع الإدارة.';

  @override
  String get deleteAccount => 'حذف الحساب';

  @override
  String get deleteAccountWarning => 'تحذير: حذف الحساب';

  @override
  String get deleteAccountMessage =>
      'هل أنت متأكد من رغبتك في حذف حسابك؟ هذا الإجراء لا يمكن التراجع عنه وسيتم حذف جميع بياناتك.';

  @override
  String get enterPasswordToDelete => 'أدخل كلمة المرور لتأكيد حذف الحساب';

  @override
  String get typeDeleteConfirmation => 'اكتب \'DELETE_MY_ACCOUNT\' للتأكيد';

  @override
  String get confirmDelete => 'تأكيد الحذف';

  @override
  String get accountDeletedSuccessfully => 'تم حذف الحساب بنجاح';

  @override
  String get cannotDeleteAccountWithActiveTasks =>
      'لا يمكن حذف الحساب مع وجود مهام نشطة';

  @override
  String get invalidPasswordForDelete => 'كلمة المرور غير صحيحة';

  @override
  String get failedToDeleteAccount => 'فشل في حذف الحساب';

  @override
  String get failedToLoadRegistrationData => 'فشل في تحميل بيانات التسجيل';

  @override
  String get registrationError => 'حدث خطأ أثناء التسجيل';

  @override
  String get registrationSuccess => 'تم التسجيل بنجاح!';

  @override
  String get verificationLinkSent =>
      'تم إرسال رابط التحقق إلى بريدك الإلكتروني.';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get previous => 'السابق';

  @override
  String get taskExpiredTransferred =>
      'انتهت مهلة الاستجابة، تم تحويل المهمة لسائق آخر';

  @override
  String get error => 'خطأ';

  @override
  String get ok => 'موافق';

  @override
  String get lowestPrice => 'أقل سعر';

  @override
  String get highestPrice => 'أعلى سعر';

  @override
  String get sort => 'ترتيب';

  @override
  String get apply => 'تطبيق';

  @override
  String get confirmAcceptTask => 'هل أنت متأكد من رغبتك في قبول هذه المهمة؟';

  @override
  String get close => 'إغلاق';

  @override
  String get allNotificationsMarkedRead => 'تم تحديد جميع الإشعارات كمقروءة';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get changePassword => 'تغيير كلمة المرور';

  @override
  String get passwordChangedSuccessfully => 'تم تغيير كلمة المرور بنجاح';

  @override
  String get profileUpdatedSuccessfully => 'تم تحديث الملف الشخصي بنجاح';

  @override
  String get updateLocationGPS => 'تحديث الموقع الجغرافي';

  @override
  String get view => 'عرض';

  @override
  String get filterTransactions => 'فلترة المعاملات';

  @override
  String get appInitializationError =>
      'حدث خطأ أثناء تهيئة التطبيق. يرجى المحاولة مرة أخرى.';

  @override
  String get loadingOffers => 'جاري تحميل العروض...';

  @override
  String get loadingRegistrationData => 'جاري تحميل بيانات التسجيل...';

  @override
  String get sendingLocation => 'جاري إرسال الموقع...';

  @override
  String get failedToLoadImage => 'فشل في تحميل الصورة';

  @override
  String get failedToSelectImage => 'فشل في اختيار الصورة';

  @override
  String get failedToSelectFile => 'فشل في اختيار الملف';

  @override
  String get undefinedItem => 'عنصر غير محدد';

  @override
  String get cannotAccessAdDetails => 'لا يمكن الوصول لتفاصيل الإعلان';

  @override
  String fileSelectedSuccessfully(String fileName) {
    return 'تم اختيار الملف: $fileName';
  }

  @override
  String get phoneIsWhatsApp => 'رقم هاتفي هو نفسه رقم الواتساب';

  @override
  String get correctBasicDataErrors =>
      'يرجى تصحيح الأخطاء في البيانات الأساسية';

  @override
  String get selectVehicleTypeSize => 'يرجى اختيار المركبة ونوعها وحجمها';

  @override
  String get fillAllAdditionalFields =>
      'يرجى ملء جميع الحقول المطلوبة في المعلومات الإضافية';

  @override
  String taskDetailsError(String error) {
    return 'خطأ في جلب تفاصيل المهمة: $error';
  }

  @override
  String get registrationErrorOccurred => 'حدث خطأ أثناء التسجيل';

  @override
  String get profileUpdateError => 'حدث خطأ أثناء تحديث الملف الشخصي';

  @override
  String get passwordChangeError => 'حدث خطأ أثناء تغيير كلمة المرور';

  @override
  String locationSendError(String error) {
    return 'خطأ في إرسال الموقع';
  }

  @override
  String get sentLocationDetails => 'تفاصيل الموقع المرسل';

  @override
  String taskHistoryError(String error) {
    return 'خطأ في جلب سجل المهمة: $error';
  }

  @override
  String fileSelectionError(String error) {
    return 'خطأ في اختيار الملف: $error';
  }

  @override
  String get noteAddedSuccessfully => 'تم إضافة الملاحظة بنجاح';

  @override
  String noteAddError(String error) {
    return 'خطأ في إضافة الملاحظة: $error';
  }

  @override
  String attachmentOpenError(String error) {
    return 'خطأ في فتح المرفق: $error';
  }

  @override
  String get imageLoadError => 'خطأ في تحميل الصورة';

  @override
  String get fileDownloadError => 'خطأ في تحميل الملف';

  @override
  String get fileOpenError => 'خطأ في فتح الملف';

  @override
  String get fileOpenedForDownload => 'تم فتح الملف للتحميل';

  @override
  String get passwordRequirements =>
      '• 8 أحرف على الأقل\n• حرف كبير واحد على الأقل (A-Z)\n• حرف صغير واحد على الأقل (a-z)\n• رقم واحد على الأقل (0-9)';

  @override
  String get passwordSecurityTips =>
      '• لا تشارك كلمة المرور مع أي شخص\n• استخدم كلمة مرور قوية وفريدة\n• غير كلمة المرور بانتظام\n• لا تستخدم معلومات شخصية في كلمة المرور';

  @override
  String get fileViewerComingSoon => 'عارض الملفات قريباً';

  @override
  String get linkOpenComingSoon => 'فتح الرابط قريباً';

  @override
  String get taskOfferAccepted =>
      'تم قبول عرضك لهذه المهمة!\n\nهل تريد قبول المهمة والبدء في تنفيذها؟\n\nبعد القبول ستصبح المهمة مسندة إليك رسمياً وستظهر في قائمة مهامك الحالية.';

  @override
  String get basicData => 'البيانات الأساسية';

  @override
  String get additionalInfo => 'المعلومات التكميلية';

  @override
  String get reviewAndConfirm => 'المراجعة والتأكيد';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get fullNameRequired => 'الاسم الكامل مطلوب';

  @override
  String get username => 'اسم المستخدم';

  @override
  String get usernameRequired => 'اسم المستخدم مطلوب';

  @override
  String get emailRequired => 'البريد الإلكتروني مطلوب';

  @override
  String get invalidEmail => 'البريد الإلكتروني غير صحيح';

  @override
  String get phoneRequired => 'رقم الهاتف مطلوب';

  @override
  String get password => 'كلمة المرور';

  @override
  String get passwordRequired => 'كلمة المرور مطلوبة';

  @override
  String get passwordMinLength8 => 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get confirmPasswordRequired => 'تأكيد كلمة المرور مطلوب';

  @override
  String get passwordsDoNotMatch => 'كلمة المرور غير متطابقة';

  @override
  String get addressRequired => 'العنوان مطلوب';

  @override
  String get vehicle => 'المركبة';

  @override
  String get selectVehicle => 'اختر المركبة';

  @override
  String get vehicleRequired => 'اختيار المركبة مطلوب';

  @override
  String get selectVehicleType => 'اختر نوع المركبة';

  @override
  String get vehicleTypeRequired => 'اختيار نوع المركبة مطلوب';

  @override
  String get selectVehicleSize => 'اختر حجم المركبة';

  @override
  String get vehicleSizeRequired => 'اختيار حجم المركبة مطلوب';

  @override
  String get selectTeamOptional => 'اختر فريق (اختياري)';

  @override
  String get whatsapp => 'واتساب';

  @override
  String get phoneIsWhatsAppNumber => 'رقم هاتفي هو نفسه رقم الواتساب';

  @override
  String get enterWhatsAppOrSelectPhone =>
      'الرجاء إدخال رقم واتساب أو اختيار أن الهاتف هو واتساب';

  @override
  String get requiredAdditionalInfo => 'المعلومات التكميلية مطلوبة';

  @override
  String fieldRequired(String fieldName) {
    return '$fieldName مطلوب';
  }

  @override
  String get mustBeValidNumber => 'يجب أن يكون رقماً صحيحاً';

  @override
  String get invalidUrl => 'الرابط غير صحيح';

  @override
  String selectOption(String fieldName) {
    return 'اختر $fieldName';
  }

  @override
  String get fileSelected => 'تم اختيار الملف';

  @override
  String get selectFile => 'اضغط لاختيار ملف';

  @override
  String get dataReview => 'مراجعة البيانات';

  @override
  String get additionalFields => 'الحقول الإضافية';

  @override
  String get agreeToTerms =>
      'بالضغط على \"إنشاء الحساب\" فإنك توافق على شروط الاستخدام وسياسة الخصوصية';

  @override
  String get verificationEmailSent =>
      'سيتم إرسال رابط التحقق إلى بريدك الإلكتروني لتفعيل حسابك';

  @override
  String get createAccount => 'إنشاء الحساب';

  @override
  String get next => 'التالي';

  @override
  String get registrationFailed => 'فشل في التسجيل';

  @override
  String get checkEmailAndActivate =>
      'يرجى التحقق من بريدك الإلكتروني وتفعيل حسابك، ثم العودة لتسجيل الدخول.';

  @override
  String get loginText => 'تسجيل الدخول';

  @override
  String get passwordMismatch => 'كلمة المرور غير متطابقة';

  @override
  String get selectVehicleRequired => 'اختيار المركبة مطلوب';

  @override
  String get selectVehicleTypeRequired => 'اختيار نوع المركبة مطلوب';

  @override
  String get selectVehicleSizeRequired => 'اختيار حجم المركبة مطلوب';

  @override
  String get selectTeam => 'اختر الفريق';

  @override
  String get selectTeamRequired => 'اختيار الفريق مطلوب';

  @override
  String get whatsappNumberOptional => 'رقم واتساب للتواصل (اختياري)';

  @override
  String get phoneIsWhatsapp => 'رقم هاتفي هو نفسه رقم الواتساب';

  @override
  String get whatsappRequired =>
      'الرجاء إدخال رقم واتساب أو اختيار أن الهاتف هو واتساب';

  @override
  String get additionalInfoRequired => 'المعلومات التكميلية مطلوبة';

  @override
  String get phoneNumberPlaceholder => 'رقم الهاتف';

  @override
  String get whatsappNumberPlaceholder => 'رقم الواتساب';

  @override
  String get sentSuccessfully => 'تم الإرسال بنجاح';

  @override
  String get resetLinkSentTo => 'تم إرسال رابط إعادة تعيين كلمة المرور إلى:';

  @override
  String get enterEmailForReset =>
      'أدخل بريدك الإلكتروني وسنرسل لك رابط إعادة تعيين كلمة المرور';

  @override
  String get enterYourEmail => 'أدخل بريدك الإلكتروني';

  @override
  String get sendResetLink => 'إرسال رابط إعادة التعيين';

  @override
  String get pleaseEnterValidEmail => 'يرجى إدخال بريد إلكتروني صحيح';

  @override
  String get termsAndPrivacyAgreement =>
      'بالضغط على \"إنشاء الحساب\" فإنك توافق على شروط الاستخدام وسياسة الخصوصية';

  @override
  String get backToLogin => 'العودة لتسجيل الدخول';

  @override
  String get verificationLinkWillBeSent =>
      'سيتم إرسال رابط التحقق إلى بريدك الإلكتروني لتفعيل حسابك';

  @override
  String get all => 'الكل';

  @override
  String get deposits => 'الإيداعات';

  @override
  String get withAttachments => 'مع مرفقات';

  @override
  String get type => 'النوع';

  @override
  String get date => 'التاريخ';

  @override
  String get time => 'الوقت';

  @override
  String get selectDateRange => 'اختيار فترة زمنية';

  @override
  String get referenceNumber => 'رقم المرجع';

  @override
  String get maturityDate => 'تاريخ الاستحقاق';

  @override
  String get attachment => 'المرفق';

  @override
  String get tapToView => 'اضغط للعرض';

  @override
  String get noTransactionsWithAttachments => 'لا توجد معاملات مع مرفقات';

  @override
  String get tapOpenToViewFile => 'اضغط على \"فتح\" لعرض الملف';

  @override
  String get searchInTransactions => 'البحث في المعاملات...';

  @override
  String get noTransactionsFound => 'لم يتم العثور على معاملات تطابق البحث';

  @override
  String get noTransactionsOfType => 'لا توجد معاملات من نوع';

  @override
  String get noTransactionsWithAttachmentsDescription =>
      'لم يتم العثور على معاملات تحتوي على صور أو ملفات';

  @override
  String get attachmentLabel => 'مرفق';

  @override
  String get referenceNumberLabel => 'رقم المرجع';

  @override
  String get filter => 'فلترة';

  @override
  String get refresh => 'تحديث';

  @override
  String get noAdsAvailable => 'لا توجد إعلانات متاحة';

  @override
  String get noAdsAvailableDescription =>
      'لا توجد إعلانات مهام متاحة في الوقت الحالي';

  @override
  String get adDetails => 'تفاصيل الإعلان';

  @override
  String get submittedOffers => 'العروض المقدمة';

  @override
  String get cannotViewOffers => 'لا يمكنك عرض العروض المقدمة';

  @override
  String get noOffersSubmittedDescription =>
      'لم يتم تقديم أي عروض لهذا الإعلان بعد';

  @override
  String get acceptTaskConfirmation =>
      'هل أنت متأكد من رغبتك في قبول هذه المهمة؟';

  @override
  String get contactName => 'اسم المسؤول';

  @override
  String get contactPerson => 'الشخص المسؤول';

  @override
  String get pendingApproval => 'في انتظار الموافقة';

  @override
  String get cannotUndo => 'لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get updatedSuccessfully => 'تم التحديث بنجاح';

  @override
  String get noInternetConnection => 'لا يوجد اتصال بالإنترنت';

  @override
  String get internetConnectionRequired =>
      'يحتاج التطبيق إلى الاتصال بالإنترنت للعمل بشكل صحيح. يرجى التأكد من اتصالك بالإنترنت ثم المحاولة مرة أخرى.';

  @override
  String get initializationError => 'خطأ في التهيئة';

  @override
  String get initializationErrorMessage =>
      'حدث خطأ أثناء تهيئة التطبيق. يرجى المحاولة مرة أخرى.';

  @override
  String get driversApp => 'تطبيق السائقين';

  @override
  String get rejected => 'مرفوض';

  @override
  String get failedToLoadOffers => 'فشل في تحميل العروض';

  @override
  String get updateOffer => 'تحديث العرض';

  @override
  String taskHistoryTitle(String taskId) {
    return 'سجل المهمة #$taskId';
  }

  @override
  String errorLoadingTaskHistory(String error) {
    return 'خطأ في جلب سجل المهمة: $error';
  }

  @override
  String get failedToAddNote => 'فشل في إضافة الملاحظة';

  @override
  String get clickOpenToViewFile => 'اضغط على \"فتح\" لعرض الملف';

  @override
  String get taskStatusAssign => 'مخصصة';

  @override
  String get taskStatusStarted => 'بدأت';

  @override
  String get taskStatusInPickupPoint => 'في نقطة الاستلام';

  @override
  String get taskStatusLoading => 'جاري التحميل';

  @override
  String get taskStatusInTheWay => 'في الطريق';

  @override
  String get taskStatusInDeliveryPoint => 'في نقطة التسليم';

  @override
  String get taskStatusUnloading => 'جاري التفريغ';

  @override
  String get taskStatusCompleted => 'مكتملة';

  @override
  String get taskStatusCancelled => 'ملغية';

  @override
  String get updateLocation => 'تحديث الموقع الجغرافي';

  @override
  String get locationSent => 'تم إرسال الموقع';

  @override
  String get importantNotes => 'ملاحظات مهمة:';

  @override
  String get checkInboxAndSpam =>
      '• تحقق من صندوق البريد الوارد والرسائل المزعجة';

  @override
  String get linkValidOneHour => '• الرابط صالح لمدة ساعة واحدة فقط';

  @override
  String get noEmailRetry =>
      '• إذا لم تستلم الرسالة خلال 5 دقائق، يمكنك المحاولة مرة أخرى';

  @override
  String get taskAssignedToDriver => 'تم تخصيص المهمة للسائق';

  @override
  String get driverStartedTask => 'بدأ السائق في تنفيذ المهمة';

  @override
  String get driverArrivedPickup => 'وصل السائق لنقطة الاستلام';

  @override
  String get loadingGoods => 'يتم تحميل البضائع';

  @override
  String get driverOnWayDelivery => 'السائق في طريقه لنقطة التسليم';

  @override
  String get driverArrivedDelivery => 'وصل السائق لنقطة التسليم';

  @override
  String get unloadingGoods => 'يتم تفريغ البضائع';

  @override
  String get taskCompletedSuccessfully => 'تم إكمال المهمة بنجاح';

  @override
  String get newLabel => 'جديد';

  @override
  String get daysAgoPlural => 'أيام مضت';

  @override
  String get hoursAgoPlural => 'ساعات مضت';

  @override
  String get minutesAgoPlural => 'دقائق مضت';
}
