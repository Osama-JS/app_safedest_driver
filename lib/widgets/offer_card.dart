import 'package:flutter/material.dart';
import '../models/task_offer.dart';
import '../models/task_ad.dart';
import 'package:get/get.dart';

class OfferCard extends StatelessWidget {
  final TaskOffer offer;
  final TaskAd taskAd;

  const OfferCard({
    super.key,
    required this.offer,
    required this.taskAd,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: offer.isMyOffer ? 3 : 1,
      color: offer.isMyOffer
          ? Theme.of(context).colorScheme.primary.withOpacity(0.05)
          : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with driver info and status
            _buildHeader(context),

            const SizedBox(height: 12),

            // Price and description
            _buildOfferDetails(context),

            // Net earnings calculation for my offer
            if (offer.isMyOffer && taskAd.commission != null) ...[
              const SizedBox(height: 12),
              _buildNetEarningsInfo(context),
            ],

            // Timestamps
            const SizedBox(height: 8),
            _buildTimestamps(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final status = offer.status;
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (status) {
      case TaskOfferStatus.pending:
        statusColor = Colors.orange;
        statusText = 'offer_pending'.tr;
        statusIcon = Icons.schedule;
        break;
      case TaskOfferStatus.accepted:
        statusColor = Colors.green;
        statusText = 'offer_accepted_status'.tr;
        statusIcon = Icons.check_circle;
        break;
      case TaskOfferStatus.rejected:
        statusColor = Colors.red;
        statusText = 'offer_rejected'.tr;
        statusIcon = Icons.cancel;
        break;
    }

    return Row(
      children: [
        // Driver info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    offer.isMyOffer ? Icons.person : Icons.person_outline,
                    size: 16,
                    color: offer.isMyOffer
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    offer.isMyOffer ? 'my_offer'.tr : (offer.driverName ?? 'driver'.tr),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: offer.isMyOffer
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: offer.isMyOffer
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                  ),
                ],
              ),
              if (!offer.isMyOffer && offer.driverPhone != null) ...[
                const SizedBox(height: 4),
                Text(
                  offer.driverPhone!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ],
          ),
        ),

        // Status badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(statusIcon, color: Colors.white, size: 14),
              const SizedBox(width: 4),
              Text(
                statusText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOfferDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Price
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.green.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.monetization_on, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Text(
                'proposed_price'.tr + ': ${offer.price.toStringAsFixed(2)} ' + 'sar'.tr,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
              ),
            ],
          ),
        ),

        // Description
        if (offer.description.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'offer_description'.tr + ':',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  offer.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNetEarningsInfo(BuildContext context) {
    final commission = taskAd.commission!;
    final netEarnings = commission.calculateDriverNet(offer.price);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.blue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calculate, color: Colors.blue, size: 16),
              const SizedBox(width: 8),
              Text(
                'net_earnings_calculation'.tr + ':',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildCalculationRow(
            context,
            'offer_price'.tr,
            '${offer.price.toStringAsFixed(2)} ' + 'sar'.tr,
          ),
          _buildCalculationRow(
            context,
            'taxes_and_fees'.tr,
            '- ${((commission.serviceCommissionType == 'fixed' ? commission.serviceCommission : (offer.price * commission.serviceCommission / 100)) + (offer.price * commission.vatCommission / 100)).toStringAsFixed(2)} ' + 'sar'.tr,
          ),
          const Divider(height: 16),
          _buildCalculationRow(
            context,
            'net_earnings'.tr,
            '${netEarnings.toStringAsFixed(2)} ' + 'sar'.tr,
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildCalculationRow(
    BuildContext context,
    String label,
    String value, {
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                  color: isTotal ? Colors.green[700] : null,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimestamps(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          'submitted_at'.tr + ': ${_formatDateTime(offer.createdAt)}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        if (offer.updatedAt != offer.createdAt) ...[
          const SizedBox(width: 16),
          Icon(Icons.edit, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            'last_update'.tr + ': ${_formatDateTime(offer.updatedAt)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
