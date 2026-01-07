// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:provider/provider.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
// import 'config/app_config.dart';
// import 'theme/app_theme.dart';
// import 'services/auth_service.dart';
// import 'services/task_service.dart';
// import 'services/location_service.dart';
// import 'services/wallet_service.dart';
// import 'services/notification_service.dart';
// import 'screens/splash_screen.dart';
// import 'screens/auth/login_screen.dart';
// import 'screens/auth/forgot_password_screen.dart';
// import 'screens/main/main_screen.dart';
// import 'screens/profile/edit_profile_screen.dart';
// import 'screens/profile/change_password_screen.dart';
// import 'screens/profile/additional_data_screen.dart';
//
// import 'screens/auth/register_screen.dart';
// import 'screens/settings/settings_screen.dart';
// import 'services/registration_service.dart';
// import 'services/settings_service.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   debugPrint('=== Starting SafeDests Driver App ===');
//
//   // Initialize Firebase (with error handling)
//   try {
//     await Firebase.initializeApp();
//     debugPrint('✅ Firebase initialized successfully');
//   } catch (e) {
//     debugPrint('❌ Firebase initialization failed: $e');
//     // Continue without Firebase - app can still work
//   }
//
//   // Initialize NotificationService early (with error handling)
//   try {
//     final notificationService = NotificationService();
//     await notificationService.initialize();
//     debugPrint('✅ NotificationService initialized in main()');
//   } catch (e) {
//     debugPrint('❌ Failed to initialize NotificationService in main(): $e');
//     // Continue without notifications - app can still work
//   }
//
//   debugPrint('🚀 Running SafeDests Driver App...');
//   runApp(const SafeDestsDriverApp());
// }
//
// class SafeDestsDriverApp extends StatefulWidget {
//   const SafeDestsDriverApp({super.key});
//
//   @override
//   State<SafeDestsDriverApp> createState() => _SafeDestsDriverAppState();
// }
//
// class _SafeDestsDriverAppState extends State<SafeDestsDriverApp> {
//   late SettingsService _settingsService;
//
//   @override
//   void initState() {
//     super.initState();
//     debugPrint('🔧 Initializing SafeDestsDriverApp...');
//
//     try {
//       _settingsService = SettingsService();
//       _settingsService.initialize();
//       debugPrint('✅ SettingsService initialized');
//     } catch (e) {
//       debugPrint('❌ SettingsService initialization failed: $e');
//       // Create a fallback settings service
//       _settingsService = SettingsService();
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => AuthService()),
//         ChangeNotifierProvider(create: (_) => TaskService()),
//         ChangeNotifierProvider(create: (_) => LocationService()),
//         ChangeNotifierProvider(create: (_) => WalletService()),
//         ChangeNotifierProvider(create: (_) => NotificationService()),
//         ChangeNotifierProvider(create: (_) => RegistrationService()),
//         ChangeNotifierProvider.value(value: _settingsService),
//       ],
//       child: Consumer<SettingsService>(
//         builder: (context, settingsService, child) {
//           return MaterialApp(
//             title: AppConfig.appName,
//             theme: AppTheme.lightTheme,
//             darkTheme: AppTheme.darkTheme,
//             themeMode: settingsService.themeMode,
//             debugShowCheckedModeBanner: false,
//
//             // Localization
//             locale: settingsService.getLocale(),
//             localizationsDelegates: const [
//               GlobalMaterialLocalizations.delegate,
//               GlobalWidgetsLocalizations.delegate,
//               GlobalCupertinoLocalizations.delegate,
//             ],
//             supportedLocales: const [
//               Locale('ar', 'SA'), // Arabic
//               Locale('en', 'US'), // English
//             ],
//
//             // Routes
//             initialRoute: '/',
//             routes: {
//               '/': (context) => const SplashScreen(),
//               '/login': (context) => const LoginScreen(),
//               '/register': (context) => const RegisterScreen(),
//               '/forgot-password': (context) => const ForgotPasswordScreen(),
//               '/main': (context) => const MainScreen(),
//               '/edit-profile': (context) => const EditProfileScreen(),
//               '/change-password': (context) => const ChangePasswordScreen(),
//               '/additional-data': (context) => const AdditionalDataScreen(),
//               '/settings': (context) => const SettingsScreen(),
//             },
//
//             // Route generator for dynamic routes
//             onGenerateRoute: (settings) {
//               switch (settings.name) {
//                 default:
//                   return MaterialPageRoute(
//                     builder: (context) => const SplashScreen(),
//                   );
//               }
//             },
//
//             // Global error handling
//             builder: (context, child) {
//               return Directionality(
//                 textDirection: settingsService.isRTL
//                     ? TextDirection.rtl
//                     : TextDirection.ltr,
//                 child: child ?? const SizedBox(),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
