import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../Controllers/WalletController.dart';
import '../../models/wallet.dart';

class WithdrawalHistoryScreen extends StatefulWidget {
  const WithdrawalHistoryScreen({super.key});

  @override
  State<WithdrawalHistoryScreen> createState() => _WithdrawalHistoryScreenState();
}

class _WithdrawalHistoryScreenState extends State<WithdrawalHistoryScreen> {
  final WalletController _walletController = Get.find<WalletController>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _walletController.fetchWithdrawalHistory(refresh: true);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        // Load more logic could go here if pagination is implemented in controller
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تاريخ طلبات السحب'),
      ),
      body: Obx(() {
        if (_walletController.isLoading.value && _walletController.withdrawalRequests.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_walletController.withdrawalRequests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history_outlined, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text('لا توجد طلبات سحب سابقة', style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => _walletController.fetchWithdrawalHistory(refresh: true),
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _walletController.withdrawalRequests.length,
            itemBuilder: (context, index) {
              final request = _walletController.withdrawalRequests[index];
              return _buildRequestCard(request);
            },
          ),
        );
      }),
    );
  }

  Widget _buildRequestCard(WithdrawalRequest request) {
    Color statusColor;
    IconData statusIcon;

    switch (request.status) {
      case 'completed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      case 'cancelled':
        statusColor = Colors.grey;
        statusIcon = Icons.remove_circle;
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.access_time_filled;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Icon(statusIcon, color: statusColor, size: 24),
        ),
        title: Text(
          '${request.amountRequested.toStringAsFixed(2)} ${_walletController.currency}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          DateFormat('yyyy-MM-dd HH:mm').format(request.createdAt),
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            request.statusDisplay,
            style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (request.paymentMethod != null)
                  _buildDetailRow('وسيلة الدفع', request.paymentMethod!),
                if (request.amountPaid != null)
                  _buildDetailRow('المبلغ المصروف', '${request.amountPaid!.toStringAsFixed(2)} ${_walletController.currency}'),
                if (request.processedAt != null)
                  _buildDetailRow('تاريخ المعالجة', DateFormat('yyyy-MM-dd HH:mm').format(request.processedAt!)),
                if (request.adminNotes != null)
                   _buildDetailRow('ملاحظات الإدارة', request.adminNotes!),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
        ],
      ),
    );
  }
}
