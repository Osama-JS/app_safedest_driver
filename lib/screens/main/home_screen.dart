import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/task_service.dart';
import '../../services/location_service.dart';
import '../../services/wallet_service.dart';
import '../../services/notification_service.dart';
import '../../services/task_ads_stats_service.dart';
import '../../widgets/driver_status_card.dart';
import '../../widgets/quick_stats_card.dart';
import '../../widgets/recent_tasks_card.dart';
import '../../widgets/pending_task_card.dart';
import '../../widgets/earnings_summary_card.dart';
import '../task_ads/task_ads_screen.dart';
import 'notifications_screen.dart';
import '../../l10n/generated/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final taskService = Provider.of<TaskService>(context, listen: false);
    final walletService = Provider.of<WalletService>(context, listen: false);
    final locationService =
        Provider.of<LocationService>(context, listen: false);
    final taskAdsStatsService = TaskAdsStatsService();

    try {
      // Load initial data
      await Future.wait([
        taskService.getTasks(page: 1, perPage: 5),
        taskService.checkPendingTasks(),
        walletService.getWallet(),
        walletService.getEarningsStats(),
        walletService.getTransactions(page: 1, perPage: 10),
        locationService.getCurrentStatus(),
        taskAdsStatsService.loadStats(), // Load task ads statistics
      ]);

      debugPrint('Home data loaded successfully');
    } catch (e) {
      debugPrint('Error loading home data: $e');
    }
  }

  Future<void> _refreshData() async {
    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      debugPrint('Starting data refresh...');

      // Refresh driver profile data from server
      await authService.refreshDriverData();

      // Reload all data
      await _loadData();

      debugPrint('Data refresh completed successfully');

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.dataRefreshSuccess),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error refreshing data: $e');

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.dataRefreshFailed),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Widget _buildTaskAdsSection() {
    final l10n = AppLocalizations.of(context)!;

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
              Colors.purple.withValues(alpha: 0.1),
              Colors.blue.withValues(alpha: 0.1),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                borderRadius:
                    BorderRadius.circular(12), // عشان يظهر التأثير مع الحواف
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TaskAdsScreen(),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.purple.withValues(alpha: 0.2),
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
                            l10n.taskAds,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple[700],
                                ),
                          ),
                          Text(
                            l10n.taskAdsDescription,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
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
              Consumer<TaskAdsStatsService>(
                builder: (context, statsService, child) {
                  return Row(
                    children: [
                      Expanded(
                        child: _buildQuickStatItem(
                          l10n.availableAds,
                          statsService.isLoading
                              ? '...'
                              : '${statsService.availableAds}',
                          Icons.assignment_outlined,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickStatItem(
                          l10n.myOffers,
                          statsService.isLoading
                              ? '...'
                              : '${statsService.myOffers}',
                          Icons.local_offer_outlined,
                          Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickStatItem(
                          l10n.acceptedOffers,
                          statsService.isLoading
                              ? '...'
                              : '${statsService.acceptedOffers}',
                          Icons.check_circle_outline,
                          Colors.green,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TaskAdsScreen(),
                      ),
                    );
                  },
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
                        l10n.browseAds,
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
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
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
      backgroundColor: Theme.of(context).colorScheme.background,
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

                  // const SizedBox(height: 16),

                  // // Earnings Summary
                  // const EarningsSummaryCard(),

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
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        return SliverAppBar(
          expandedHeight: 120,
          floating: true,
          pinned: true,
          backgroundColor: Theme.of(context).colorScheme.primary,
          flexibleSpace: FlexibleSpaceBar(
            title: Consumer<AuthService>(
              builder: (context, authService, child) {
                final l10n = AppLocalizations.of(context)!;
                final driver = authService.currentDriver;
                return Text(
                  l10n.welcomeDriver(driver?.name ?? l10n.driver),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            // Notifications
            Consumer<NotificationService>(
              builder: (context, notificationService, child) {
                return IconButton(
                  icon: Stack(
                    children: [
                      const Icon(Icons.notifications_outlined,
                          color: Colors.white),
                      if (notificationService.unreadCount > 0)
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
                              '${notificationService.unreadCount}',
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationsScreen(),
                      ),
                    );
                  },
                );
              },
            ),

            // Settings
            IconButton(
              icon: const Icon(Icons.settings_outlined, color: Colors.white),
              onPressed: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
          ],
        );
      },
    );
  }
}
