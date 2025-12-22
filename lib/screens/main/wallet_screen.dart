import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Controllers/WalletController.dart';
import '../../widgets/wallet_balance_card.dart';
import '../../widgets/earnings_chart_card.dart';
import '../../widgets/transaction_list_card.dart';
import '../wallet/advanced_transactions_screen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final WalletController _walletController = Get.find<WalletController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWalletData();
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
            icon: const Icon(Icons.receipt_long),
            tooltip: 'transaction_history'.tr,
            onPressed: () => Get.to(() => const TransactionsScreen()),
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
                const WalletBalanceCard(),

                const SizedBox(height: 16),

                // Earnings Chart
                const EarningsChartCard(),

                const SizedBox(height: 16),

                // Recent Transactions
                const TransactionListCard(),

                const SizedBox(height: 100), // Bottom padding
              ],
            ),
          );
        }),
      ),
    );
  }
}
