import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Controllers/AuthController.dart';
import '../../Controllers/TaskController.dart';
import '../../Controllers/LocationController.dart';
import '../../Controllers/WalletController.dart';
import '../../Controllers/NotificationController.dart';
import '../../Controllers/TaskAdsController.dart';
import '../../widgets/driver_status_card.dart';
import '../../widgets/quick_stats_card.dart';
import '../../widgets/recent_tasks_card.dart';
import '../../widgets/pending_task_card.dart';
import '../../widgets/earnings_summary_card.dart';
import '../task_ads/task_ads_screen.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthController _authController = Get.find<AuthController>();
  final TaskController _taskController = Get.find<TaskController>();
  final WalletController _walletController = Get.find<WalletController>();
  final LocationController _locationController = Get.find<LocationController>();
  final NotificationController _notificationController = Get.find<NotificationController>();
  final TaskAdsController _taskAdsController = Get.find<TaskAdsController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    try {
      debugPrint('Home data loading...');

      await Future.wait([
        if (_locationController.isOnline.value) _locationController.startTracking(),
        _taskController.fetchTasks(page: 1, perPage: 5),
        _taskController.checkPendingTasks(),
        _walletController.fetchWallet(),
        _walletController.fetchEarningsStats(),
        _walletController.fetchTransactions(page: 1, perPage: 10),
        _locationController.fetchCurrentStatus(),
        _taskAdsController.loadStats(),
      ]);

      debugPrint('Home data loaded successfully');
    } catch (e) {
      debugPrint('Error loading home data: $e');
    }
  }

  Future<void> _refreshData() async {
    try {
      debugPrint('Starting data refresh...');

      // Refresh driver profile data
      await _authController.refreshDriverData();

      // Reload all data
      await _loadData();

      debugPrint('Data refresh completed successfully');

      Get.snackbar(
        'success'.tr,
        'data_refresh_success'.tr,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint('Error refreshing data: $e');
      Get.snackbar(
        'error'.tr,
        'data_refresh_failed'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Widget _buildTaskAdsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.withOpacity(0.1),
              Colors.blue.withOpacity(0.1),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => Get.to(() => const TaskAdsScreen()),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.campaign,
                        color: Colors.purple,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'task_ads'.tr,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple[700],
                                ),
                          ),
                          Text(
                            'task_ads_description'.tr,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.purple,
                      size: 16,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Obx(() => Row(
                children: [
                  Expanded(
                    child: _buildQuickStatItem(
                      'available_ads'.tr,
                      _taskAdsController.isLoading.value ? '...' : '${_taskAdsController.availableAds.value}',
                      Icons.assignment_outlined,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickStatItem(
                      'my_offers'.tr,
                      _taskAdsController.isLoading.value ? '...' : '${_taskAdsController.myOffers.value}',
                      Icons.local_offer_outlined,
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickStatItem(
                      'accepted_offers'.tr,
                      _taskAdsController.isLoading.value ? '...' : '${_taskAdsController.acceptedOffers.value}',
                      Icons.check_circle_outline,
                      Colors.green,
                    ),
                  ),
                ],
              )),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.to(() => const TaskAdsScreen()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'browse_ads'.tr,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStatItem(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Pending Task Card (if any)
                  const PendingTaskCard(),

                  // Driver Status Card
                  const DriverStatusCard(),

                  const SizedBox(height: 16),

                  // Quick Stats
                  const QuickStatsCard(),

                  const SizedBox(height: 16),

                  // Task Ads Section
                  _buildTaskAdsSection(),

                  const SizedBox(height: 16),

                  // Earnings Summary
                  const EarningsSummaryCard(),

                  const SizedBox(height: 16),

                  // Recent Tasks
                  const RecentTasksCard(),

                  const SizedBox(
                      height: 100), // Bottom padding for navigation bar
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      backgroundColor: Theme.of(context).colorScheme.primary,
      flexibleSpace: FlexibleSpaceBar(
        title: Obx(() {
          final driver = _authController.currentDriver.value;
          return Text(
            'welcomeDriver'.trParams({
              'driverName': driver?.name ?? 'driver'.tr
            }),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          );
        }),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary.withOpacity(0.8),
              ],
            ),
          ),
        ),
      ),
      actions: [
        Obx(() => _notificationController.unreadCount.value > 0
            ? IconButton(
                icon: const Icon(Icons.mark_email_read_outlined, color: Colors.white),
                onPressed: () => _notificationController.markAllAsRead(),
                tooltip: 'mark_all_as_read'.tr,
              )
            : const SizedBox.shrink()),

        // Notifications
        Obx(() => IconButton(
          icon: Stack(
            children: [
              const Icon(Icons.notifications_outlined, color: Colors.white),
              if (_notificationController.unreadCount.value > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${_notificationController.unreadCount.value}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          onPressed: () => Get.to(() => const NotificationsScreen()),
        )),

        // Settings
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Colors.white),
          onPressed: () => Get.toNamed('/settings'),
        ),
      ],
    );
  }
}
