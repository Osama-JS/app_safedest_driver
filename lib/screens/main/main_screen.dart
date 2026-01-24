import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../Controllers/AuthController.dart';
import '../../Controllers/NotificationController.dart'; // Added
import '../../l10n/generated/app_localizations.dart';
// import '../../l10n/generated/app_localizations.dart';
import 'home_screen.dart';
import 'tasks_screen.dart';
import 'wallet_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool _isInitialized = false;

  final List<Widget> _screens = [
    const HomeScreen(),
    const TasksScreen(),
    const WalletScreen(),
    const ProfileScreen(),
  ];

  // Tutorial Keys
/*  final GlobalKey _homeKey = GlobalKey();
  final GlobalKey _tasksKey = GlobalKey();
  final GlobalKey _walletKey = GlobalKey();
  final GlobalKey _profileKey = GlobalKey();*/

  @override
  void initState() {
    super.initState();
    _initializeAndCheckAuth();
  }


  Future<void> _initializeAndCheckAuth() async {
    final authController = Get.find<AuthController>();

    // Wait for auth controller to be fully initialized if needed
    // In GetX, onInit usually runs immediately, but we can check isLoading
    if (authController.isLoading.value) {
      await Future.delayed(const Duration(milliseconds: 500));
    }

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });

      // Start tutorial after UI is built with a small delay to ensure keys are ready
      /*WidgetsBinding.instance.addPostFrameCallback((_) {
         debugPrint('MainScreen: Scheduling tutorial...');
         Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
               debugPrint('MainScreen: Starting tutorial now.');
               _startTutorial();
            }
         });
      });*/

      // Check authentication status
      debugPrint('MainScreen: Checking auth status via AuthController');
      debugPrint(
          'MainScreen: Is authenticated: ${authController.isAuthenticated.value}');
      debugPrint(
          'MainScreen: Current driver: ${authController.currentDriver.value?.name}');

      // Use Obx or simple check since we are in initState logic
      if (!authController.isAuthenticated.value || authController.currentDriver.value == null) {
        debugPrint('MainScreen: Not authenticated, navigating to login');
        // Use Get.offAllNamed to clear stack and go to login
        //TODO SAEEEEEEED RETURN
        // Get.offAllNamed('/login');
      } else {
        debugPrint('MainScreen: Authenticated, staying on main screen');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        await _showExitDialog(context);
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
      // Fallback or error handling
      return const SizedBox.shrink();
    }

    // Using GetX for NotificationController updates if needed, primarily for badge
    // which seems to be missing in the original code but good to have prepared.
    return GetBuilder<NotificationController>(
      builder: (controller) {
        return BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),//, key: _homeKey),
              activeIcon: const Icon(Icons.home),
              label: l10n.home,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_outlined),//, key: _tasksKey),
              activeIcon: const Icon(Icons.assignment),
              label: l10n.tasks,
              backgroundColor: _currentIndex == 1
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                  : null,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_outlined),//, key: _walletKey),
              activeIcon: const Icon(Icons.account_balance_wallet),
              label: l10n.wallet,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outlined),//, key: _profileKey),
              activeIcon: const Icon(Icons.person),
              label: l10n.profile,
            ),
          ],
        );
      },
    );
  }

  // Show exit confirmation dialog
  Future<void> _showExitDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.exit_to_app,
                color: Colors.orange[600],
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(l10n.exitConfirmation),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.exitConfirmMessage,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.exitConfirmDescription,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              l10n.cancel,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog first
              SystemNavigator.pop(); // Exit app completely
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              l10n.exit,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
