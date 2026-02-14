import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'home_screen.dart';
import 'tasks_screen.dart';
import 'available_tasks_screen.dart';
import 'wallet_screen.dart';
import 'profile_screen.dart';
import '../../Controllers/AuthController.dart';
import '../../Controllers/NotificationController.dart';
import '../../widgets/support_fab.dart';

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

  @override
  void initState() {
    super.initState();
    _initializeAndCheckAuth();
  }

  Future<void> _initializeAndCheckAuth() async {
    final authController = Get.find<AuthController>();

    if (authController.isLoading.value) {
      await Future.delayed(const Duration(milliseconds: 500));
    }

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });

      if (!authController.isAuthenticated.value || authController.currentDriver.value == null) {
        Get.offAllNamed('/login');
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
          children: [
            const HomeScreen(),
            _currentIndex == 1 ? const AvailableTasksScreen() : const SizedBox.shrink(),
            _currentIndex == 2 ? const TasksScreen() : const SizedBox.shrink(),
            _currentIndex == 3 ? const WalletScreen() : const SizedBox.shrink(),
            _currentIndex == 4 ? const ProfileScreen() : const SizedBox.shrink(),
          ],
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
        floatingActionButton: const SupportFAB(),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
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
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home),
              label: 'home'.tr,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.gps_fixed_outlined),
              activeIcon: const Icon(Icons.gps_fixed),
              label: 'broadcastTasks'.tr,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.assignment_outlined),
              activeIcon: const Icon(Icons.assignment),
              label: 'tasks'.tr,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.account_balance_wallet_outlined),
              activeIcon: const Icon(Icons.account_balance_wallet),
              label: 'wallet'.tr,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outlined),
              activeIcon: const Icon(Icons.person),
              label: 'profile'.tr,
            ),
          ],
        );
      },
    );
  }

  Future<void> _showExitDialog(BuildContext context) {
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
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.exit_to_app, color: Colors.orange[600], size: 24),
            ),
            const SizedBox(width: 12),
            Text('exitConfirmation'.tr),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('exitConfirmMessage'.tr, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('exitConfirmDescription'.tr, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('cancel'.tr, style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              SystemNavigator.pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[600], foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: Text('exit'.tr, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
