import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../models/task_ad.dart';
import '../../models/task_offer.dart';
import '../../services/task_ads_service.dart';
import '../../widgets/offer_card.dart';

class TaskAdDetailsScreen extends StatefulWidget {
  final int adId;

  const TaskAdDetailsScreen({super.key, required this.adId});

  @override
  State<TaskAdDetailsScreen> createState() => _TaskAdDetailsScreenState();
}

class _TaskAdDetailsScreenState extends State<TaskAdDetailsScreen> {
  final TaskAdsService _taskAdsService = TaskAdsService();
  TaskAd? _taskAd;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _taskAdsService.getAdDetails(widget.adId);
      if (response.success && response.data != null) {
        setState(() {
          _taskAd = response.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.message ?? 'failed_to_load_task_details'.tr;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('ad_details'.tr)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text('ad_details'.tr)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainCenter,
            children: [
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadData,
                child: Text('retry'.tr),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('ad_details'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAdHeader(),
            const Divider(height: 32),
            _buildLocations(),
            const Divider(height: 32),
            _buildPriceAndVehicle(),
            const Divider(height: 32),
            _buildCommissionDetails(),
            const Divider(height: 32),
            _buildDescription(),
            const SizedBox(height: 80), // Space for FAB
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildAdHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${'task'.tr} #${_taskAd?.taskId}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            _buildStatusChip(),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '${'created_at'.tr}: ${_taskAd?.createdAt.toString().split('.')[0]}',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildStatusChip() {
    final status = _taskAd?.status ?? 'running';
    final isRunning = status == 'running';
    return Chip(
      label: Text(
        isRunning ? 'active'.tr : 'closed'.tr,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: isRunning ? Colors.green : Colors.grey,
    );
  }

  Widget _buildLocations() {
    final pickup = _taskAd?.task?.pickup;
    final delivery = _taskAd?.task?.delivery;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLocationItem(
          icon: Icons.location_on,
          color: Colors.blue,
          title: 'pickup'.tr,
          address: pickup?.address ?? 'not_specified'.tr,
          contact: pickup?.contactName,
        ),
        const SizedBox(height: 16),
        _buildLocationItem(
          icon: Icons.location_searching,
          color: Colors.orange,
          title: 'delivery'.tr,
          address: delivery?.address ?? 'not_specified'.tr,
          contact: delivery?.contactName,
        ),
      ],
    );
  }

  Widget _buildLocationItem({
    required IconData icon,
    required Color color,
    required String title,
    required String address,
    String? contact,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                address,
                style: const TextStyle(fontSize: 16),
              ),
              if (contact != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    contact,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceAndVehicle() {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            icon: Icons.money,
            title: 'price_range'.tr,
            value: '${_taskAd?.lowestPrice} - ${_taskAd?.highestPrice} ${'sar'.tr}',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInfoCard(
            icon: Icons.local_shipping,
            title: 'vehicle_size'.tr,
            value: _taskAd?.task?.vehicleSize ?? 'not_specified'.tr,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildCommissionDetails() {
    final commission = _taskAd?.commission;
    if (commission == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'commission_details'.tr,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('vat_commission'.tr),
            Text('${commission.vatCommission}%'),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('service_commission'.tr),
            Text(
              commission.serviceCommissionType == 'fixed'
                  ? '${commission.serviceCommission} ${'sar'.tr}'
                  : '${commission.serviceCommission}%',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'description'.tr,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          _taskAd?.description ?? 'no_description'.tr,
          style: const TextStyle(fontSize: 15, height: 1.5),
        ),
      ],
    );
  }

  Widget? _buildFloatingActionButton() {
    if (_taskAd == null) return null;

    final canSubmit = _taskAdsService.canSubmitOffer(_taskAd!);
    final canEdit = _taskAdsService.canEditOffer(_taskAd!);
    final canAccept = _taskAdsService.canAcceptTask(_taskAd!);

    if (canSubmit || canEdit) {
      return SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: FloatingActionButton.extended(
          onPressed: () => _showOfferDialog(isUpdate: canEdit),
          label: Text(canEdit ? 'update_offer'.tr : 'submit_offer'.tr),
          icon: Icon(canEdit ? Icons.edit : Icons.add),
          backgroundColor: Theme.of(context).primaryColor,
        ),
      );
    }

    if (canAccept) {
      return SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _showAcceptTaskDialog,
                icon: const Icon(Icons.check),
                label: Text('accept_task'.tr),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _showRejectTaskDialog,
                icon: const Icon(Icons.close),
                label: Text('reject_task'.tr),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return null;
  }

  void _showOfferDialog({bool isUpdate = false}) {
    final priceController = TextEditingController(
      text: isUpdate ? _taskAd?.myOffer?.price.toString() : '',
    );
    final descController = TextEditingController(
      text: isUpdate ? _taskAd?.myOffer?.description : '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isUpdate ? 'update_offer'.tr : 'submit_offer'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: priceController,
              decoration: InputDecoration(
                labelText: 'proposed_price'.tr,
                suffixText: 'sar'.tr,
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: InputDecoration(
                labelText: 'offer_description'.tr,
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () {
              final price = double.tryParse(priceController.text);
              if (price == null || price <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('invalid_price'.tr)),
                );
                return;
              }
              Navigator.pop(context);
              _submitOrUpdateOffer(price, descController.text, isUpdate);
            },
            child: Text(isUpdate ? 'update'.tr : 'confirm'.tr),
          ),
        ],
      ),
    );
  }

  void _submitOrUpdateOffer(double price, String desc, bool isUpdate) async {
    _showLoadingDialog();

    try {
      final response = isUpdate
          ? await _taskAdsService.updateOffer(_taskAd!.myOffer!.id, price, desc)
          : await _taskAdsService.submitOffer(_taskAd!.id, price, desc);

      if (mounted) {
        Navigator.pop(context); // Close loading
        if (response.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isUpdate
                  ? 'offer_updated_successfully'.tr
                  : 'offer_submitted_successfully'.tr),
              backgroundColor: Colors.green,
            ),
          );
          _loadData();
        } else {
          _showErrorSnackBar(response.message);
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        _showErrorSnackBar(e.toString());
      }
    }
  }

  void _showAcceptTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('accept_task'.tr),
        content: Text('confirm_accept_task'.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _acceptTask();
            },
            child: Text('confirm'.tr),
          ),
        ],
      ),
    );
  }

  void _acceptTask() async {
    _showLoadingDialog();

    try {
      final response = await _taskAdsService.acceptTask(_taskAd!.myOffer!.id);
      if (mounted) {
        Navigator.pop(context);
        if (response.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('task_accepted_successfully'.tr),
              backgroundColor: Colors.green,
            ),
          );
          _loadData();
        } else {
          _showErrorSnackBar(response.message);
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        _showErrorSnackBar(e.toString());
      }
    }
  }

  void _showRejectTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('reject_task'.tr),
        content: Text('confirm_reject_task'.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _rejectTask();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('confirm'.tr),
          ),
        ],
      ),
    );
  }

  void _rejectTask() async {
    _showLoadingDialog();

    try {
      final response = await _taskAdsService.rejectTask(_taskAd!.myOffer!.id);
      if (mounted) {
        Navigator.pop(context);
        if (response.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('task_rejected_successfully'.tr),
              backgroundColor: Colors.green,
            ),
          );
          _loadData();
        } else {
          _showErrorSnackBar(response.message ?? 'failed_to_reject_task'.tr);
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        _showErrorSnackBar(e.toString());
      }
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
  }

  void _showErrorSnackBar(String? message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message ?? 'something_wrong'.tr),
        backgroundColor: Colors.red,
      ),
    );
  }
}
