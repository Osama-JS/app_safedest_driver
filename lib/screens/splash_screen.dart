import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/generated/app_localizations.dart';
import '../config/app_config.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../services/location_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    debugPrint('SplashScreen: initState called');
    _initializeAnimations();
    debugPrint('SplashScreen: Starting initialization...');
    _initializeApp();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.forward();
  }

  Future<void> _initializeApp() async {
    try {
      debugPrint('=== SplashScreen: Starting app initialization ===');

      // Get services
      final authService = Provider.of<AuthService>(context, listen: false);
      final notificationService =
          Provider.of<NotificationService>(context, listen: false);
      final locationService =
          Provider.of<LocationService>(context, listen: false);

      debugPrint('SplashScreen: Services obtained successfully');

      // فحص الاتصال بالـ API مع timeout قصير
      debugPrint('SplashScreen: Checking API connectivity...');

      bool shouldShowConnectivityDialog = false;
      try {
        final isConnected = await authService
            .checkApiConnectivity()
            .timeout(const Duration(seconds: 30));

        debugPrint('SplashScreen: API connectivity result: $isConnected');

        if (!isConnected) {
          shouldShowConnectivityDialog = true;
        }
      } catch (e) {
        debugPrint('SplashScreen: API connectivity check failed: $e');
        shouldShowConnectivityDialog = true;
      }

      // إذا لم يكن هناك اتصال، اعرض الـ dialog
      if (shouldShowConnectivityDialog) {
        debugPrint(
            'SplashScreen: No API connection, showing connectivity dialog');
        if (mounted) {
          await _showConnectivityDialog();
        }
        return; // توقف هنا ولا تكمل التهيئة
      }

      // ✅ يوجد اتصال → نكمل التهيئة
      debugPrint('SplashScreen: API connected, initializing services...');

      // Initialize services
      await authService.initialize();
      debugPrint('SplashScreen: AuthService initialized');

      await notificationService.initialize();
      debugPrint('SplashScreen: NotificationService initialized');

      await locationService.initialize();
      debugPrint('SplashScreen: LocationService initialized');

      // Check initial permission status for debugging
      debugPrint('SplashScreen: Checking initial permission status...');
      await locationService.getDetailedPermissionStatus();

      // Request GPS permission immediately after LocationService initialization
      debugPrint('SplashScreen: Requesting GPS permission...');
      await _requestGPSPermission(locationService);

      // Check final permission status
      debugPrint('SplashScreen: Checking final permission status...');
      await locationService.getDetailedPermissionStatus();

      // انتظار مدة الـ Splash
      debugPrint('SplashScreen: Waiting for splash duration...');
      await Future.delayed(Duration(seconds: AppConfig.splashDuration));

      // Navigate based on authentication status
      if (mounted) {
        debugPrint('SplashScreen: Ready to navigate');
        debugPrint(
            'SplashScreen: isAuthenticated = ${authService.isAuthenticated}');

        if (authService.isAuthenticated) {
          // Additional check for driver status
          final driver = authService.currentDriver;
          if (driver != null && driver.status != 'active') {
            debugPrint(
                'SplashScreen: Driver status is not active: ${driver.status}');

            // Show dialog explaining why account is blocked
            await _showAccountStatusDialog(driver.status);

            // Force logout and navigate to login
            await authService.forceLogout();
            if (mounted) {
              Navigator.of(context).pushReplacementNamed('/login');
            }
          } else {
            debugPrint('SplashScreen: Navigating to /main');
            Navigator.of(context).pushReplacementNamed('/main');
          }
        } else {
          debugPrint('SplashScreen: Navigating to /login');
          Navigator.of(context).pushReplacementNamed('/login');
        }
      } else {
        debugPrint('SplashScreen: Widget not mounted, skipping navigation');
      }
    } catch (e, stackTrace) {
      debugPrint('SplashScreen: App initialization error: $e');
      debugPrint('SplashScreen: Stack trace: $stackTrace');
      if (mounted) {
        _showErrorAndNavigate();
      }
    }
  }

  // Request GPS permission during app startup with comprehensive diagnosis
  Future<void> _requestGPSPermission(LocationService locationService) async {
    try {
      debugPrint(
          '🚀 SplashScreen: Starting comprehensive GPS permission diagnosis...');

      // Step 1: Get detailed status first for debugging
      final detailedStatus =
          await locationService.getDetailedPermissionStatus();
      debugPrint('📊 SplashScreen: Initial detailed status: $detailedStatus');

      // Step 2: Check if this is a manifest issue
      if (detailedStatus['manifestConfigured'] == false) {
        debugPrint('🚨 SplashScreen: CRITICAL MANIFEST ISSUE DETECTED!');
        debugPrint(
            '🔧 SplashScreen: Manifest error: ${detailedStatus['manifestError']}');
        debugPrint('🔧 SplashScreen: IMMEDIATE ACTION REQUIRED:');
        debugPrint('   1. STOP the app completely');
        debugPrint('   2. Run: flutter clean');
        debugPrint('   3. Run: flutter pub get');
        debugPrint('   4. Completely rebuild and reinstall the app');
        debugPrint('   5. Check AndroidManifest.xml has location permissions');
        debugPrint(
            '🚨 SplashScreen: App will continue but location features will NOT work!');
        return; // Don't attempt permission requests if manifest is broken
      }

      // Step 3: Show diagnosis
      debugPrint('💡 SplashScreen: Diagnosis: ${detailedStatus['diagnosis']}');

      // Step 4: Try multiple permission request strategies
      bool hasPermission = false;
      int attempts = 0;
      const maxAttempts = 3;

      while (!hasPermission && attempts < maxAttempts) {
        attempts++;
        debugPrint(
            '🔄 SplashScreen: Permission attempt $attempts/$maxAttempts');

        // Request permission with enhanced method
        hasPermission = await locationService.requestGPSPermissionOnly();

        if (!hasPermission && attempts < maxAttempts) {
          debugPrint('⏳ SplashScreen: Waiting before next attempt...');
          await Future.delayed(const Duration(seconds: 2));

          // Get updated status
          final updatedStatus =
              await locationService.getDetailedPermissionStatus();
          debugPrint(
              '📊 SplashScreen: Updated status after attempt $attempts: ${updatedStatus['diagnosis']}');
        }
      }

      // Step 5: Final verification
      if (hasPermission) {
        debugPrint('✅ SplashScreen: GPS permission granted successfully');

        // Try to get initial location to verify everything works
        try {
          final response = await locationService.sendLocationManually();
          if (response.isSuccess) {
            debugPrint(
                '✅ SplashScreen: Location access fully verified and working');
          } else {
            debugPrint(
                '⚠️ SplashScreen: Permission granted but location sending failed: ${response.message}');
          }
        } catch (e) {
          debugPrint('⚠️ SplashScreen: Location verification failed: $e');
        }
      } else {
        debugPrint(
            '❌ SplashScreen: Failed to get GPS permission after $maxAttempts attempts');

        // Get final comprehensive status for debugging
        final finalStatus = await locationService.getDetailedPermissionStatus();
        debugPrint(
            '📊 SplashScreen: FINAL DIAGNOSIS: ${finalStatus['diagnosis']}');
        debugPrint('📊 SplashScreen: Complete final status: $finalStatus');

        // Provide specific guidance based on final status
        if (finalStatus['isPermanentlyDenied'] == true) {
          debugPrint(
              '🔧 SplashScreen: USER ACTION REQUIRED: Open app settings and grant location permission');
        } else if (finalStatus['serviceEnabled'] == false) {
          debugPrint(
              '🔧 SplashScreen: USER ACTION REQUIRED: Enable GPS/Location services in device settings');
        } else {
          debugPrint(
              '🔧 SplashScreen: DEVELOPER ACTION REQUIRED: Check app configuration and rebuild');
        }
      }
    } catch (e) {
      debugPrint('💥 SplashScreen: GPS permission request error: $e');

      // Even on error, try to get diagnostic info
      try {
        final errorStatus = await locationService.getDetailedPermissionStatus();
        debugPrint(
            '📊 SplashScreen: Error diagnosis: ${errorStatus['diagnosis']}');
      } catch (e2) {
        debugPrint('💥 SplashScreen: Could not get error diagnosis: $e2');
      }
    }
  }

  // Dialog عند انقطاع الاتصال
  Future<void> _showConnectivityDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 16,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Theme.of(context).colorScheme.surface,
            border: Border.all(
              color: isDark
                  ? Colors.red.withValues(alpha: 0.3)
                  : Colors.red.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // أيقونة
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.red.withValues(alpha: 0.2)
                      : Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withValues(alpha: 0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.wifi_off_rounded,
                  size: 40,
                  color: isDark ? Colors.red[400] : Colors.red[600],
                ),
              ),
              const SizedBox(height: 24),

              Text(
                l10n.noInternetConnection,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.red[400] : Colors.red[700],
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              Text(
                l10n.internetConnectionRequired,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.8),
                      height: 1.5,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // الأزرار
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _initializeApp(); // إعادة المحاولة
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text(l10n.retry),
                      style: OutlinedButton.styleFrom(
                        foregroundColor:
                            isDark ? Colors.blue[400] : Colors.blue[600],
                        side: BorderSide(
                          color: isDark ? Colors.blue[400]! : Colors.blue[600]!,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // ❌ إغلاق التطبيق فوري
                        exit(0);
                      },
                      icon: const Icon(Icons.exit_to_app_rounded),
                      label: Text(l10n.exit),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isDark ? Colors.red[600] : Colors.red[500],
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorAndNavigate() {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          l10n.initializationError,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        content: Text(
          l10n.initializationErrorMessage,
          style: TextStyle(
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/login');
            },
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // شعار التطبيق
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/icons/Icon.png',
                        width: 60,
                        height: 60,
                        // اختياري إذا تبغى تغيّر لون الصورة (يعمل فقط مع الصور بصيغة PNG شفافة أو SVG)
                      ),
                    ),

                    const SizedBox(height: 30),

                    // اسم التطبيق
                    Text(
                      AppConfig.appName,
                      style:
                          Theme.of(context).textTheme.headlineLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                    ),

                    const SizedBox(height: 10),

                    // الوصف
                    Text(
                      l10n.driversApp,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                    ),

                    const SizedBox(height: 50),

                    const SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 3,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      l10n.loading,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),

      // معلومات الإصدار أسفل الشاشة
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        child: Text(
          '${l10n.version} ${AppConfig.appVersion}',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.6),
              ),
        ),
      ),
    );
  }

  // عرض حوار حالة الحساب
  Future<void> _showAccountStatusDialog(String status) async {
    final l10n = AppLocalizations.of(context)!;

    String title;
    String message;
    IconData icon;
    Color color;

    switch (status) {
      case 'blocked':
        title = l10n.accountBlocked;
        message = l10n.accountBlockedMessage;
        icon = Icons.block;
        color = Colors.red;
        break;
      case 'pending':
        title = l10n.accountInactive;
        message = 'حسابك قيد المراجعة. يرجى انتظار موافقة الإدارة.';
        icon = Icons.pending;
        color = Colors.orange;
        break;
      case 'suspended':
        title = l10n.accountInactive;
        message = 'تم تعليق حسابك مؤقتاً. يرجى التواصل مع الإدارة.';
        icon = Icons.pause_circle;
        color = Colors.orange;
        break;
      default:
        title = l10n.accountInactive;
        message = l10n.accountInactiveMessage;
        icon = Icons.info;
        color = Colors.grey;
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              l10n.ok,
              style: TextStyle(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
