import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

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

      // Schedule tutorial
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted)     _checkTutorial();

      });
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
          controller: _singleScrollController,
          slivers: [
            _buildAppBar(),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Pending Task Card (if any)
                  const SizedBox(height: 16),

                  // Recent Tasks (Pending)
                  Container(
                    // key: _recentTasksKey,
                    child: const PendingTaskCard(),
                  ),

                  // Driver Status Card
                  DriverStatusCard(
                    onlineSwitchKey: _onlineSwitchKey,
                    busyStatusKey: _busyStatusKey,
                  ),

                  const SizedBox(height: 16),

                  // Quick Stats
                  QuickStatsCard(
                    availableTasksKey: _availableTasksKey,
                    activeTasksKey: _activeTasksKey,
                    balanceKey: _balanceKey,
                    totalEarningsKey: _totalEarningsKey,
                  ),

                  const SizedBox(height: 16),

                  // Task Ads Section
                  Container(
                    key: _adsKey,
                    child: _buildTaskAdsSection(),
                  ),

                  const SizedBox(height: 16),

                  // Earnings Summary
                  Container(
                    key: _earningsCardKey,
                    child: const EarningsSummaryCard(),
                  ),

                  const SizedBox(height: 16),

                  // Recent Tasks
                     RecentTasksCard(
                    key: _recentTasksKey,

                  ),

                  const SizedBox(
                      height: 100), // Bottom padding for navigation bar
                ]),
              ),
            ),
          ],
        ),
      ),
        // floatingActionButton: FloatingActionButton(
        //   key: _helpKey,
        //   backgroundColor: Colors.red.shade900,
        //   onPressed: () async {
        //     _reviewTutorial();
        //     // _viewTutorial();
        //     // _createTutorial();
        //     // tutorialCoachMark?.show(context: context);
        //
        //   },
        //   child: const Icon(Icons.help_outline, color: Colors.white),
        // )

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

        // Help
        IconButton(
          key: _helpKey,
          icon: const Icon(Icons.help_outline, color: Colors.white),
          tooltip: 'help'.tr,
          onPressed: _reviewTutorial,
        ),

        // Settings
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Colors.white),
          onPressed: () => Get.toNamed('/settings'),
        ),
      ],
    );
  }





  final ScrollController _singleScrollController = ScrollController();



  final GlobalKey _onlineSwitchKey = GlobalKey();
  final GlobalKey _busyStatusKey = GlobalKey();
  final GlobalKey _availableTasksKey = GlobalKey();
  final GlobalKey _activeTasksKey = GlobalKey();
  final GlobalKey _balanceKey = GlobalKey();
  final GlobalKey _totalEarningsKey = GlobalKey();
  final GlobalKey _adsKey = GlobalKey();
  final GlobalKey _earningsCardKey = GlobalKey();
  final GlobalKey _recentTasksKey = GlobalKey();
  final GlobalKey _helpKey = GlobalKey();

  TutorialCoachMark? tutorialCoachMark;


  Future<void> _checkTutorial() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasSeen = prefs.getBool('hasSeenHomeScreen') ?? false;

    if (!hasSeen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _viewTutorial();
      });
    }
  }

  void _reviewTutorial() {
    if (_onlineSwitchKey.currentContext == null) {
      _singleScrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      ).then((_) => _viewTutorial());
    } else {
      _viewTutorial();
    }
  }

  void _viewTutorial() {

    int counter = 0;
    List<TargetFocus> targets = _createTargets();
    Scrollable.ensureVisible(
      targets[counter].keyTarget?.currentContext ?? context,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );

    tutorialCoachMark = TutorialCoachMark(
        targets: _createTargets(),
        colorShadow: Colors.red.shade500,
        textSkip: "skip".tr,
        paddingFocus: 10,
        opacityShadow: 0.9,
        onFinish: () {
          _markTutorialAsSeen();
        },
        onSkip: () {
          _markTutorialAsSeen();
          return true;
        },
        onClickTarget: (target) {
          counter++;
          if (counter < targets.length) {
            Scrollable.ensureVisible(
              targets[counter].keyTarget?.currentContext ?? context,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              alignment: 0.5,
            );
          }
        });


    Future.delayed(const Duration(milliseconds: 500), () {
      tutorialCoachMark?.show(context: context);
    });
  }







  void _createTutorial() {
    int counter=0;
    _singleScrollController.animateTo(_singleScrollController.position.minScrollExtent,duration: const Duration(milliseconds:1),curve: Curves.easeOut);
    _scrollToKey(_onlineSwitchKey.currentContext);

    tutorialCoachMark = TutorialCoachMark(
        targets: _createTargets(),
        colorShadow: Colors.red.shade500,
        textSkip: "تخطي",
        paddingFocus: 10,
        opacityShadow: 0.9,
        onFinish: () {
          _markTutorialAsSeen();
        },
        onSkip: () {
          _markTutorialAsSeen();
          return true;
        },

        onClickTarget: (target) {
          // _scrollToKey(target.keyTarget?.currentContext);
          // setState(() {
          print(counter);
          counter++;
          if(counter==1) {
            _singleScrollController.animateTo(_singleScrollController.position.maxScrollExtent,duration: const Duration(milliseconds:500),curve: Curves.ease);
          } else if(counter==2) {
            _singleScrollController.animateTo(_singleScrollController.position.maxScrollExtent,duration: const Duration(milliseconds:500),curve: Curves.ease);
          }
          // });
        }
    );
  }

  void _scrollToKey(BuildContext? context) {
    // final context = key.currentContext;
    if (context != null) {
      // This ensures the widget associated with the key is visible in its parent scrollable
      Scrollable.ensureVisible(
        context,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.5, // Optional: centers the widget in the viewport
      );
    }
  }


  void _markTutorialAsSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenHomeScreen', true);
  }

  List<TargetFocus> _createTargets() {
    List<TargetFocus> targets = [];



    targets.add(
      TargetFocus(
        identify: "online_switch",
        keyTarget: _onlineSwitchKey,
        shape: ShapeLightFocus.RRect,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: _buildTutorialItem(
            title: "tutorial_online_title".tr,
            description: "tutorial_online_desc".tr,
            ),
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "busy_status",
        keyTarget: _busyStatusKey,
        shape: ShapeLightFocus.RRect,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: _buildTutorialItem(
              title: "tutorial_busy_title".tr,
              description: "tutorial_busy_desc".tr,
            ),
          ),
        ],
      ),
    );


    targets.add(
      TargetFocus(
        identify: "available_tasks",
        keyTarget: _availableTasksKey,
        shape: ShapeLightFocus.RRect,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: _buildTutorialItem(
              title: "tutorial_available_title".tr,
              description: "tutorial_available_desc".tr,
            ),
          ),
        ],
      ),
    );



    targets.add(
      TargetFocus(
        identify: "active_tasks",
        keyTarget: _activeTasksKey,
        shape: ShapeLightFocus.RRect,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: _buildTutorialItem(
              title: "tutorial_active_title".tr,
              description: "tutorial_active_desc".tr,
            ),
          ),
        ],
      ),
    );


    targets.add(
      TargetFocus(
        identify: "current_balance",
        keyTarget: _balanceKey,
        shape: ShapeLightFocus.RRect,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: _buildTutorialItem(
              title: "tutorial_balance_title".tr,
              description: "tutorial_balance_desc".tr,
            ),
          ),
        ],
      ),
    );


    targets.add(
    TargetFocus(
    identify: "total_earnings",
    keyTarget: _totalEarningsKey,
    shape: ShapeLightFocus.RRect,
    contents: [
    TargetContent(
    align: ContentAlign.top,
    child: _buildTutorialItem(
    title: "tutorial_total_title".tr,
    description: "tutorial_total_desc".tr,
    ),
    ),
    ],
    ),
    );


    targets.add(
    TargetFocus(
    identify: "ads_section",
    keyTarget: _adsKey,
    shape: ShapeLightFocus.RRect,
    contents: [
    TargetContent(
    align: ContentAlign.top,
    child: _buildTutorialItem(
    title: "tutorial_ads_title".tr,
    description: "tutorial_ads_desc".tr,
    ),
    ),
    ],
    ),
    );

    targets.add(
    TargetFocus(
    identify: "earnings_summary",
    keyTarget: _earningsCardKey,
    shape: ShapeLightFocus.RRect,
    contents: [
    TargetContent(
    align: ContentAlign.top,
    child: _buildTutorialItem(
    title: "tutorial_earnings_card_title".tr,
    description: "tutorial_earnings_card_desc".tr,
    ),
    ),
    ],
    ),
    );




    targets.add(
    TargetFocus(
    identify: "recent_tasks",
    keyTarget: _recentTasksKey,
    shape: ShapeLightFocus.RRect,
    contents: [
    TargetContent(
    align: ContentAlign.top,
    child: _buildTutorialItem(
    title: "tutorial_recent_title".tr,
    description: "tutorial_recent_desc".tr,
    ),
    ),
    ],
    ),
    );



    targets.add(
      TargetFocus(
        identify: "tutorial_home_page_help",
        keyTarget: _helpKey,
        shape: ShapeLightFocus.RRect,
        radius: 10,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: Container(
              constraints: BoxConstraints(
                maxHeight: 300,
                maxWidth: Get.width*0.8,
              ),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(100),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "replay_instructions".tr,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "tap_to_rewatch".tr,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),

          ),
        ],
      ),
    );
    return targets;
  }

  Widget _buildTutorialItem({required String title, required String description}) {
    return Container(
      constraints: BoxConstraints(maxWidth: Get.width * 0.8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(150),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(description, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        ],
      ),
    );
  }

}
