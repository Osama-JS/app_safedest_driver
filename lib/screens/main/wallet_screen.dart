import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/wallet_service.dart';
import '../../widgets/wallet_balance_card.dart';
import '../../widgets/earnings_chart_card.dart';
import '../../widgets/transaction_list_card.dart';
import '../wallet/advanced_transactions_screen.dart';
import '../../l10n/generated/app_localizations.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWalletData();
    });
    // _loadWalletData();
  }

  Future<void> _loadWalletData() async {
    final walletService = Provider.of<WalletService>(context, listen: false);
    await Future.wait([
      walletService.getWallet(),
      walletService.getTransactions(),
      walletService.getEarningsStats(),
    ]);
  }

  Future<void> _refreshWalletData() async {
    await _loadWalletData();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.wallet),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long),
            tooltip: l10n.transactionHistory,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TransactionsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshWalletData,
        child: Consumer<WalletService>(
          builder: (context, walletService, child) {
            if (walletService.isLoading && walletService.wallet == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Wallet Balance Card
                  const WalletBalanceCard(),

                  const SizedBox(height: 16),

                  // Earnings Chart
                  const EarningsChartCard(),

                  // const SizedBox(height: 16),

                  // // Quick Actions
                  // _buildQuickActions(),

                  const SizedBox(height: 16),

                  // Recent Transactions
                  const TransactionListCard(),

                  const SizedBox(height: 100), // Bottom padding
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.quickActions,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.account_balance,
                    label: l10n.cashWithdrawal,
                    onTap: () {
                      // TODO: Implement withdrawal
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.withdrawalComingSoon)),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.receipt_long,
                    label: l10n.accountStatement,
                    onTap: () {
                      // TODO: Generate statement
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.statementComingSoon)),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.support_agent,
                    label: l10n.support,
                    onTap: () {
                      // TODO: Contact support
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.supportComingSoon)),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
