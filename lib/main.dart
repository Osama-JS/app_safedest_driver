import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:safedest_driver/services/api_service.dart';
import 'package:safedest_driver/shared_prff.dart';
import 'Controllers/LocationController.dart';
import 'firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/generated/app_localizations.dart';
import 'config/app_config.dart';
import 'theme/app_theme.dart';
import 'services/auth_service.dart';
import 'services/task_service.dart';
import 'services/location_service.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/onboarding_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/main/main_screen.dart';
import 'screens/profile/edit_profile_screen.dart';
import 'screens/profile/change_password_screen.dart';
import 'screens/profile/additional_data_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'services/registration_service.dart';
import 'services/settings_service.dart';
import 'services/task_ads_stats_service.dart';

// GetX Imports
import 'package:get/get.dart';
import 'package:safedest_driver/Services/InitialService.dart';
import 'package:safedest_driver/Languages/LanguageController.dart';
import 'package:safedest_driver/Languages/Messages.dart';
import 'package:safedest_driver/Globals/global.dart' as globals;
// import 'package:safedest_driver/shared_prff.dart';

// Global navigation key for handling authentication errors
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize all SharedPreferences helpers first
  await Selected_Language.init();
  await Theme_pref.init();
  await Token_pref.init();
  await User_pref.init();
  await Bool_pref.init();
  // Initialize Firebase with proper error handling
  try {
    debugPrint('🔥 Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase initialized successfully');

    // Test Firebase connection
    try {
      final messaging = FirebaseMessaging.instance;
      debugPrint('🔔 Firebase Messaging instance created');
    } catch (e) {
      debugPrint('⚠️ Firebase Messaging initialization warning: $e');
    }
  } catch (e, stackTrace) {
    debugPrint('❌ Firebase initialization failed: $e');
    debugPrint('Stack trace: $stackTrace');
    // Don't continue - Firebase is critical for notifications
    return;
  }

  final api = ApiService();
  await api.initialize();

  // Initialize GetX Services
  await Get.putAsync(() => InitialService().init());
  // LanguageController is now initialized in InitialService


  // ✅ تفعيل تسجيل الخروج التلقائي عند انتهاء التوكن
  ApiService.setAuthenticationErrorCallback(() async {
    debugPrint("🔴 Token invalid — logging out user...");

    // نحذف بيانات المستخدم
    final authService = AuthService();
    await authService.logout(); // إن كانت موجودة في كودك

    // نعيد التوجيه إلى شاشة تسجيل الدخول باستخدام GetX
    Get.offAllNamed('/login');
  });

  runApp(const SafeDestsDriverApp());
}

class SafeDestsDriverApp extends StatefulWidget {
  const SafeDestsDriverApp({super.key});

  @override
  State<SafeDestsDriverApp> createState() => _SafeDestsDriverAppState();
}

class _SafeDestsDriverAppState extends State<SafeDestsDriverApp> {
  late SettingsService _settingsService;

  @override
  void initState() {
    super.initState();
    _settingsService = SettingsService();
    _settingsService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => TaskService()),
        ChangeNotifierProvider(create: (_) => LocationService()),
        ChangeNotifierProvider(create: (_) => RegistrationService()),
        ChangeNotifierProvider(create: (_) => TaskAdsStatsService()),
        ChangeNotifierProvider.value(value: _settingsService),
      ],
      child: Consumer<SettingsService>(
        builder: (context, settingsService, child) {
          final LanguageController languageController = Get.find();

          return GetMaterialApp(
            navigatorKey: navigatorKey,
            title: AppConfig.appName,
            theme: AppTheme.lightTheme,
            themeMode: ThemeMode.light,
            debugShowCheckedModeBanner: false,

            // GetX Localization - use selectedLang directly like customer app
            locale: languageController.selectedLang,
            fallbackLocale: const Locale('ar', 'SA'),
            translations: Messages(),

            // Fallback to current localization logic if needed for existing widgets
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('ar', 'SA'),
              Locale('en', 'US'),
              // Locale('ur', 'PK'),
              // Locale('zh', 'CN'),
            ],

            // GetPages instead of simple routes
            initialRoute: '/',
            getPages: [
              GetPage(name: '/', page: () => const SplashScreen()),
              GetPage(name: '/onboarding', page: () => const OnboardingScreen()),
              GetPage(name: '/login', page: () => const LoginScreen()),
              GetPage(name: '/register', page: () => const RegisterScreen()),
              GetPage(name: '/forgot-password', page: () => const ForgotPasswordScreen()),
              GetPage(name: '/main', page: () => const MainScreen()),
              GetPage(name: '/edit-profile', page: () => const EditProfileScreen()),
              GetPage(name: '/change-password', page: () => const ChangePasswordScreen()),
              GetPage(name: '/additional-data', page: () => const AdditionalDataScreen()),
              GetPage(name: '/settings', page: () => const SettingsScreen()),
            ],

            // Route generator for dynamic routes
            onGenerateRoute: (settings) {
              switch (settings.name) {
                default:
                  return MaterialPageRoute(
                    builder: (context) => const SplashScreen(),
                  );
              }
            },

            // Global error handling
            builder: (context, child) {
              return Directionality(
                textDirection: settingsService.isRTL
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                child: child ?? const SizedBox(),
              );
            },
          );
        },
      ),
    );
  }
}
