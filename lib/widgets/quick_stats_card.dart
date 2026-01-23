import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controllers/TaskController.dart';
import '../Controllers/WalletController.dart';
import '../models/task.dart';

class QuickStatsCard extends StatelessWidget {
  final Key? balanceKey;
  final Key? availableTasksKey;
  final Key? activeTasksKey;
  final Key? totalEarningsKey;
  
  const QuickStatsCard({
    super.key, 
    this.balanceKey,
    this.availableTasksKey,
    this.activeTasksKey,
    this.totalEarningsKey,
  });

  @override
  Widget build(BuildContext context) {
    final TaskController taskController = Get.find<TaskController>();
    final WalletController walletController = Get.find<WalletController>();

    return Obx(() {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.analytics,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'quick_stats'.tr,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      key: availableTasksKey,
                      child: _buildStatItem(
                        context,
                        'available_tasks'.tr,
                        '${taskController.getTaskCountByStatus('assign')}',
                        Icons.assignment_outlined,
                        Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      key: activeTasksKey,
                      child: _buildStatItem(
                        context,
                        'active_tasks'.tr,
                        '${taskController.activeTasks.length}',
                        Icons.work_outline,
                        Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      key: balanceKey,
                      child: _buildStatItem(
                        context,
                        'current_balance'.tr,
                        '${walletController.currentBalance.toStringAsFixed(2)} ${walletController.currency}',
                        Icons.account_balance_wallet_outlined,
                        Colors.green,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      key: totalEarningsKey,
                      child: _buildStatItem(
                        context,
                        'total_earnings'.tr,
                        '${walletController.totalEarnings.toStringAsFixed(2)} ${walletController.currency}',
                        Icons.trending_up,
                        Colors.purple,
                      ),
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

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 20,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.trending_up,
                  color: color,
                  size: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
          ),
        ],
      ),
    );
  }
}
