import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controllers/WalletController.dart';
import '../models/wallet.dart';
import 'error_state_widget.dart';
import '../screens/wallet/advanced_transactions_screen.dart';

class TransactionListCard extends StatelessWidget {
  const TransactionListCard({super.key});

  @override
  Widget build(BuildContext context) {
    final walletController = Get.find<WalletController>();

    return Obx(() {
      final recentTransactions = walletController.transactions.take(5).toList();
      final isLoading = walletController.isLoading.value;

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.receipt_long,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'recentTransactions'.tr,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      Get.to(() => const TransactionsScreen());
                    },
                    child: Text('view_all'.tr),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Use StateHandlerWidget for better error handling
              StateHandlerWidget<WalletTransaction>(
                isLoading: isLoading && recentTransactions.isEmpty,
                hasError: walletController.errorMessage.isNotEmpty,
                errorMessage: walletController.errorMessage.value,
                data: recentTransactions,
                onRetry: () async {
                  await walletController.fetchTransactions(refresh: true);
                },
                emptyMessage: 'noTransactions'.tr,
                emptyDescription: 'noTransactionsRecorded'.tr,
                loadingMessage: 'loadingTransactions'.tr,
                builder: (transactions) => Column(
                  children: transactions
                      .map((transaction) => _buildTransactionItem(
                          context, transaction, walletController.currency))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(
            Icons.receipt_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 12),
          Text(
            'noTransactionsCurrently'.tr,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(
    BuildContext context,
    WalletTransaction transaction,
    String currency,
  ) {
    final isCredit = transaction.isCredit;
    final color = isCredit ? Colors.green : Colors.red;
    final icon = _getTransactionIcon(transaction.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          // Transaction Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),

          const SizedBox(width: 16),

          // Transaction Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      _getTransactionTypeText(transaction.type),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Amount and Date
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isCredit ? '+' : '-'}${transaction.amount.toStringAsFixed(2)} $currency',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatDate(transaction.createdAt),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getTransactionIcon(String type) {
    switch (type.toLowerCase()) {
      case 'credit':
        return Icons.add_circle_outline;
      case 'debit':
        return Icons.remove_circle_outline;
      case 'commission':
        return Icons.monetization_on_outlined;
      case 'withdrawal':
        return Icons.account_balance_outlined;
      case 'deposit':
        return Icons.savings_outlined;
      default:
        return Icons.receipt_outlined;
    }
  }

  String _getTransactionTypeText(String type) {
    switch (type.toLowerCase()) {
      case 'credit':
        return 'deposit'.tr;
      case 'debit':
        return 'withdrawal'.tr;
      case 'commission':
        return 'commission'.tr;
      case 'deposit':
        return 'deposit'.tr;
      case 'withdrawal':
        return 'withdrawal'.tr;
      default:
        return type;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'taskStatusCompleted'.tr; // changed assuming taskStatusCompleted exists, or use completed
      case 'pending':
        return 'pending'.tr;
      case 'failed':
        return 'failed'.tr;
      default:
        return status;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} ${'day'.tr}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${'hour'.tr}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${'minute'.tr}';
    } else {
      return 'now'.tr;
    }
  }
}
