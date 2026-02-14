import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controllers/WalletController.dart';
import '../models/wallet.dart';

class WalletBalanceCard extends StatelessWidget {
  const WalletBalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final walletController = Get.find<WalletController>();

    return Obx(() {
      final wallet = walletController.wallet.value;

      return Card(
        elevation: 4,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.account_balance_wallet,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'walletBalance'.tr,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      walletController.isBalanceVisible.value
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.white.withOpacity(0.8),
                      size: 24,
                    ),
                    onPressed: walletController.toggleBalanceVisibility,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Main Balance
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          walletController.isBalanceVisible.value
                              ? '${wallet?.balance.toStringAsFixed(2) ?? '0.00'} ${wallet?.currency ?? 'sar'.tr}'
                              : '****',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'availableBalance'.tr,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white.withOpacity(0.8),
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              if (walletController.isBalanceVisible.value &&
                  wallet != null &&
                  (wallet.pendingWithdrawal ?? 0) > 0) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer_outlined, color: Colors.white, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        '${'pending'.tr}: ${wallet.pendingWithdrawal.toStringAsFixed(2)} ${wallet.currency}',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Additional Info
              Row(
                children: [
                  Expanded(
                    child: _buildBalanceInfo(
                      context,
                      'withdrawals'.tr,
                      walletController.isBalanceVisible.value
                          ? '${wallet?.pendingAmount.toStringAsFixed(2) ?? '0.00'}'
                          : '****',
                      Icons.trending_up,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  Expanded(
                    child: _buildBalanceInfo(
                      context,
                      'income'.tr,
                      walletController.isBalanceVisible.value
                          ? '${wallet?.totalEarnings.toStringAsFixed(2) ?? '0.00'}'
                          : '****',
                      Icons.trending_down,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }


  Widget _buildBalanceInfo(
    BuildContext context,
    String label,
    String amount,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(0.8),
          size: 20,
        ),
        const SizedBox(height: 8),
        Text(
          amount,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
