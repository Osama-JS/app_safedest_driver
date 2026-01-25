import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Controllers/WalletController.dart';
import '../../widgets/wallet_balance_card.dart';
import '../../widgets/earnings_chart_card.dart';
import '../../widgets/transaction_list_card.dart';
import '../wallet/advanced_transactions_screen.dart';
import '../../l10n/generated/app_localizations.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final WalletController _walletController = Get.find<WalletController>();

  // Tutorial Keys
  final GlobalKey _balanceKey = GlobalKey();
  final GlobalKey _chartKey = GlobalKey();
  final GlobalKey _recentKey = GlobalKey();
  final GlobalKey _historyKey = GlobalKey();
  final GlobalKey _helpKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWalletData();
      _checkTutorial();
    });
  }

  Future<void> _loadWalletData() async {
    await Future.wait([
      _walletController.fetchWallet(),
      _walletController.fetchTransactions(refresh: true),
      _walletController.fetchEarningsStats(),
    ]);
  }

  Future<void> _refreshWalletData() async {
    await _loadWalletData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('wallet'.tr),
        actions: [
          IconButton(
            key: _historyKey,
            icon: const Icon(Icons.receipt_long),
            tooltip: 'transaction_history'.tr,
            onPressed: () => Get.to(() => const TransactionsScreen()),
          ),
          IconButton(
            key: _helpKey,
            icon: const Icon(Icons.help_outline),
            tooltip: 'help'.tr,
            onPressed: _viewTutorial,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshWalletData,
        child: Obx(() {
          if (_walletController.isLoading.value && _walletController.wallet.value == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Wallet Balance Card
                Container(key: _balanceKey, child: const WalletBalanceCard()),

                const SizedBox(height: 16),

                // Earnings Chart
                Container(key: _chartKey, child: const EarningsChartCard()),

                const SizedBox(height: 16),

                // Recent Transactions
                Container(key: _recentKey, child: const TransactionListCard()),

                const SizedBox(height: 100), // Bottom padding
              ],
            ),
          );
        }),
      ),
    );
  }

  // --- Tutorial Methods ---

  TutorialCoachMark? tutorialCoachMark;

  void _checkTutorial() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasSeen = prefs.getBool('hasSeenWalletTutorial') ?? false;

    if (!hasSeen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _viewTutorial();
      });
    }
  }

  void _viewTutorial() {
    tutorialCoachMark = TutorialCoachMark(
      targets: _createTargets(),
      colorShadow: Colors.red.shade500,
      textSkip: "tutorial_skip".tr,
      paddingFocus: 10,
      opacityShadow: 0.9,
      onFinish: _markTutorialAsSeen,
      onClickTarget: (target) {},
      onSkip: () {
        _markTutorialAsSeen();
        return true;
      },
    );

    tutorialCoachMark?.show(context: context);
  }

  void _markTutorialAsSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenWalletTutorial', true);
  }

  List<TargetFocus> _createTargets() {
    List<TargetFocus> targets = [];

    targets.add(
      TargetFocus(
        identify: "balance_card",
        keyTarget: _balanceKey,
        shape: ShapeLightFocus.RRect,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: _buildTutorialItem(
              title: "tutorial_wallet_balance_title".tr,
              description: "tutorial_wallet_balance_desc".tr,
            ),
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "chart_card",
        keyTarget: _chartKey,
        shape: ShapeLightFocus.RRect,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: _buildTutorialItem(
              title: "tutorial_wallet_chart_title".tr,
              description: "tutorial_wallet_chart_desc".tr,
            ),
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "history_btn",
        keyTarget: _historyKey,
        shape: ShapeLightFocus.Circle,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: _buildTutorialItem(
              title: "tutorial_wallet_history_title".tr,
              description: "tutorial_wallet_history_desc".tr,
            ),
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "help_btn",
        keyTarget: _helpKey,
        shape: ShapeLightFocus.Circle,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: _buildTutorialItem(
              title: "replay_instructions".tr,
              description: "tap_to_rewatch".tr,
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
        mainAxisSize: MainAxisSize.min,
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
