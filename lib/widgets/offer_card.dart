import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/task_offer.dart';

class OfferCard extends StatelessWidget {
  final TaskOffer offer;
  final VoidCallback? onTap;

  const OfferCard({
    super.key,
    required this.offer,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 12),
              _buildDriverInfo(),
              const SizedBox(height: 12),
              _buildPriceAndDescription(),
            ],
          ),
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
      case TaskOfferStatus.accepted:
        statusColor = Colors.green;
        statusText = offer.isMyOffer ? 'offer_accepted_status'.tr : 'offer_accepted_neutral'.tr;
        statusIcon = Icons.check_circle;
        break;
      case TaskOfferStatus.rejected:
        statusColor = Colors.red;
        statusText = offer.isMyOffer ? 'offer_rejected'.tr : 'offer_rejected_neutral'.tr;
        statusIcon = Icons.cancel;
        break;
      case TaskOfferStatus.pending:
      default:
        statusColor = Colors.orange;
        statusText = offer.isMyOffer ? 'offer_pending'.tr : 'offer_pending_neutral'.tr;
        statusIcon = Icons.schedule;
        break;
    }

    return Row(
      children: [
        Icon(statusIcon, color: statusColor, size: 20),
        const SizedBox(width: 8),
        Text(
          statusText,
          style: TextStyle(
            color: statusColor,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const Spacer(),
        Text(
          offer.createdAt.toString().split(' ')[0],
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildDriverInfo() {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.blue.withOpacity(0.1),
          child: const Icon(Icons.person, color: Colors.blue),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                offer.isMyOffer ? 'my_offers'.tr : (offer.driverName ?? 'driver'.tr),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              if (!offer.isMyOffer && offer.driverPhone != null)
                Text(
                  offer.driverPhone!,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceAndDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'proposed_price'.tr,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            Text(
              '${offer.price} ${'sar'.tr}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        if (offer.description.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            offer.description,
            style: const TextStyle(fontSize: 14),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}
