import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:safedest_driver/services/api_service.dart';
import 'firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/generated/app_localizations.dart';
import 'config/app_config.dart';
import 'theme/app_theme.dart';
import 'services/auth_service.dart';
import 'services/task_service.dart';
import 'services/location_service.dart';
import 'services/wallet_service.dart';
import 'services/notification_service.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
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

// Global navigation key for handling authentication errors
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  // ✅ تفعيل تسجيل الخروج التلقائي عند انتهاء التوكن
  ApiService.setAuthenticationErrorCallback(() async {
    debugPrint("🔴 Token invalid — logging out user...");

    // نحذف بيانات المستخدم
    final authService = AuthService();
    await authService.logout(); // إن كانت موجودة في كودك

    // نعيد التوجيه إلى شاشة تسجيل الدخول
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/login',
          (route) => false,
    );
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
        ChangeNotifierProvider(create: (_) => WalletService()),
        ChangeNotifierProvider(create: (_) => NotificationService()),
        ChangeNotifierProvider(create: (_) => RegistrationService()),
        ChangeNotifierProvider(create: (_) => TaskAdsStatsService()),
        ChangeNotifierProvider.value(value: _settingsService),
      ],
      child: Consumer<SettingsService>(
        builder: (context, settingsService, child) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            title: AppConfig.appName,
            theme: AppTheme.lightTheme, // استخدام الثيم النهاري فقط
            themeMode: ThemeMode.light, // تعطيل الوضع الليلي

            // theme: AppTheme.lightTheme,
            // darkTheme: AppTheme.darkTheme,
            // themeMode: settingsService.themeMode,
            debugShowCheckedModeBanner: false,

            // Localization
            // locale: settingsService.getLocale(),
            locale: const Locale('ar', 'SA'),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('ar', 'SA'), // Arabic
              // Locale('en', 'US'), // English
            ],

            // Routes
            initialRoute: '/',
            routes: {
              '/': (context) => const SplashScreen(),
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/forgot-password': (context) => const ForgotPasswordScreen(),
              '/main': (context) => const MainScreen(),
              '/edit-profile': (context) => const EditProfileScreen(),
              '/change-password': (context) => const ChangePasswordScreen(),
              '/additional-data': (context) => const AdditionalDataScreen(),
              '/settings': (context) => const SettingsScreen(),
            },

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
