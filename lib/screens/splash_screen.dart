import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
            .timeout(const Duration(seconds: 20));

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

      // انتظار مدة الـ Splash
      debugPrint('SplashScreen: Waiting for splash duration...');
      await Future.delayed(Duration(seconds: AppConfig.splashDuration));

      // Navigate based on authentication status
      if (mounted) {
        debugPrint('SplashScreen: Ready to navigate');
        debugPrint(
            'SplashScreen: isAuthenticated = ${authService.isAuthenticated}');

        if (authService.isAuthenticated) {
          debugPrint('SplashScreen: Navigating to /main');
          Navigator.of(context).pushReplacementNamed('/main');
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

  // Dialog عند انقطاع الاتصال
  Future<void> _showConnectivityDialog() async {
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
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.red[50]!,
                Colors.orange[50]!,
              ],
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
                  color: Colors.red[100],
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
                  color: Colors.red[600],
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'لا يوجد اتصال بالإنترنت',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              Text(
                'يحتاج التطبيق إلى الاتصال بالإنترنت للعمل بشكل صحيح. يرجى التأكد من اتصالك بالإنترنت ثم المحاولة مرة أخرى.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
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
                      label: const Text('إعادة المحاولة'),
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
                      label: const Text('خروج'),
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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('خطأ في التهيئة'),
        content:
            const Text('حدث خطأ أثناء تهيئة التطبيق. يرجى المحاولة مرة أخرى.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/login');
            },
            child: const Text('موافق'),
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
                      'تطبيق السائقين',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white.withOpacity(0.8),
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
                      'جاري التحميل...',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.7),
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
          'الإصدار ${AppConfig.appVersion}',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withOpacity(0.6),
              ),
        ),
      ),
    );
  }
}
