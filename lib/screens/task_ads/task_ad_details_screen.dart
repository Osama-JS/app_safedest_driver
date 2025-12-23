import 'package:flutter/material.dart';
import '../../services/task_ads_service.dart';
import '../../models/task_ad.dart';
import '../../models/task_offer.dart';
import '../../widgets/offer_card.dart';
import 'submit_offer_screen.dart';
import 'package:get/get.dart';

class TaskAdDetailsScreen extends StatefulWidget {
  final int adId;

  const TaskAdDetailsScreen({
    super.key,
    required this.adId,
  });

  @override
  State<TaskAdDetailsScreen> createState() => _TaskAdDetailsScreenState();
}

class _TaskAdDetailsScreenState extends State<TaskAdDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TaskAdsService _taskAdsService = TaskAdsService();

  TaskAd? _taskAd;
  List<TaskOffer> _offers = [];
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAdDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAdDetails() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      // Load ad details
      final adResponse = await _taskAdsService.getTaskAdDetails(widget.adId);

      if (adResponse.success && adResponse.data != null) {
        setState(() {
          _taskAd = adResponse.data!;
        });

        // Load offers if we can view them
        if (_taskAd!.canViewDetails) {
          final offersResponse = await _taskAdsService.getAdOffers(widget.adId);

          if (offersResponse.success && offersResponse.data != null) {
            setState(() {
              _offers = offersResponse.data!.offers;
            });
          }
        }

        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
           _errorMessage = adResponse.message ?? 'loading_details'.tr;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
         _errorMessage = 'error_occurred'.tr + ': $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    await _loadAdDetails();
  }

  void _navigateToSubmitOffer() {
    if (_taskAd == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubmitOfferScreen(
          taskAd: _taskAd!,
          existingOffer: _taskAd!.myOffer,
        ),
      ),
    ).then((_) => _refreshData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         title: Text('ad_number'.tr + '${widget.adId}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
             tooltip: 'refresh'.tr,
          ),
        ],
        bottom: _taskAd != null
            ? TabBar(
                controller: _tabController,
                labelColor: Colors.white, // لون النص للتبويب المحدد
                unselectedLabelColor: Colors.white
                    .withOpacity(0.7), // لون النص للتبويبات غير المحددة
                indicatorColor: Colors.white, // لون المؤشر
                 tabs: [
                   Tab(text: 'ad_details_tab'.tr),
                   Tab(text: 'offers_tab'.tr),
                 ],
              )
            : null,
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildFloatingActionButton(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
       return Center(
         child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
             CircularProgressIndicator(),
             SizedBox(height: 16),
             Text('loading_details'.tr),
           ],
         ),
       );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
               _errorMessage ?? 'error_occurred'.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshData,
               child: Text('retry'.tr),
            ),
          ],
        ),
      );
    }

    if (_taskAd == null) {
      return Center(
         child: Text('no_data_to_display'.tr),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildAdDetailsTab(),
        _buildOffersTab(),
      ],
    );
  }

  Widget _buildAdDetailsTab() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status and basic info
            _buildStatusCard(),

            const SizedBox(height: 16),

            // Description
            if (_taskAd!.description.isNotEmpty) _buildDescriptionCard(),

            // Price range
            _buildPriceRangeCard(),

            const SizedBox(height: 16),

            // Task details
            if (_taskAd!.task != null) _buildTaskDetailsCard(),

            // My offer status
            if (_taskAd!.myOffer != null) _buildMyOfferCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildOffersTab() {
    if (!_taskAd!.canViewDetails) {
       return Center(
         child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
             Icon(Icons.lock_outline, size: 64, color: Colors.grey),
             SizedBox(height: 16),
             Text(
               'cannot_view_offers'.tr,
               style: TextStyle(fontSize: 16),
             ),
             SizedBox(height: 8),
             Text(
               'must_submit_offer_first'.tr,
               textAlign: TextAlign.center,
               style: TextStyle(color: Colors.grey),
             ),
           ],
         ),
       );
    }

    if (_offers.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refreshData,
        child: ListView(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.3),
             Center(
               child: Column(
                 children: [
                   Icon(Icons.local_offer_outlined,
                       size: 64, color: Colors.grey),
                   SizedBox(height: 16),
                   Text(
                     'no_offers_submitted'.tr,
                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                   ),
                   SizedBox(height: 8),
                   Text(
                     'no_offers_for_ad'.tr,
                     textAlign: TextAlign.center,
                     style: TextStyle(color: Colors.grey),
                   ),
                 ],
               ),
             ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _offers.length,
        itemBuilder: (context, index) {
          return OfferCard(
            offer: _offers[index],
            taskAd: _taskAd!,
          );
        },
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                     'ad_number'.tr + '${_taskAd!.id}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _getStatusText(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                   'created_date'.tr + ': ${_formatDate(_taskAd!.createdAt)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.local_offer, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                   'offers_count'.tr + ': ${_taskAd!.offersCount}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                if (_taskAd!.hasAcceptedOffer) ...[
                  const SizedBox(width: 16),
                  Icon(Icons.check_circle, size: 16, color: Colors.green[600]),
                  const SizedBox(width: 4),
                  Text(
                     'offer_accepted'.tr,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.green[600],
                        ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildFloatingActionButton() {
    if (_taskAd == null) return null;

    final taskAdsService = TaskAdsService();

    if (taskAdsService.canSubmitOffer(_taskAd!) ||
        taskAdsService.canEditOffer(_taskAd!)) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
         padding: const EdgeInsets.all(16),
         child: SafeArea(
           child: Row(
             children: [
               Expanded(
                 child: ElevatedButton.icon(
                   onPressed: _navigateToSubmitOffer,
                   icon: Icon(
                     _taskAd!.myOffer != null
                         ? Icons.edit_outlined
                         : Icons.add_circle_outline,
                     size: 24,
                   ),
                   label: Text(
                     _taskAd!.myOffer != null ? 'edit_offer'.tr : 'submit_offer'.tr,
                     style: const TextStyle(
                       fontSize: 16,
                       fontWeight: FontWeight.w600,
                     ),
                   ),
                   style: ElevatedButton.styleFrom(
                     backgroundColor: Theme.of(context).primaryColor,
                     foregroundColor: Colors.white,
                     elevation: 4,
                     shadowColor:
                         Theme.of(context).primaryColor.withOpacity(0.3),
                     shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(16),
                     ),
                     padding:
                         const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                   ),
                 ),
               ),
               if (_taskAd!.myOffer != null && _taskAd!.myOffer!.status == TaskOfferStatus.pending) ...[
                 const SizedBox(width: 12),
                 IconButton(
                   onPressed: _showDeleteOfferDialog,
                   icon: const Icon(Icons.delete_outline),
                   color: Colors.red,
                   iconSize: 28,
                   tooltip: 'delete_offer'.tr,
                   style: IconButton.styleFrom(
                     backgroundColor: Colors.red.withOpacity(0.1),
                     padding: const EdgeInsets.all(12),
                   ),
                 ),
               ],
             ],
           ),
         ),
      );
    }

    if (taskAdsService.canAcceptTask(_taskAd!)) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _showAcceptTaskDialog,
              icon: const Icon(
                Icons.check_circle_outline,
                size: 24,
              ),
               label: Text(
                 'accept_task'.tr,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: Colors.green.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
          ),
        ),
      );
    }

    return null;
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
             child: Text('accept_task'.tr),
           ),
         ],
       ),
    );
  }

  void _acceptTask() async {
    if (_taskAd?.myOffer == null) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final response = await _taskAdsService.acceptTask(_taskAd!.myOffer!.id);

      if (mounted) {
        Navigator.pop(context); // Close loading

        if (response.success) {
          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
               content: Text('task_accepted_successfully'.tr),
              backgroundColor: Colors.green,
            ),
          );
          _refreshData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
               content: Text(response.message ?? 'failed_to_accept_task'.tr),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
             content: Text('error_occurred'.tr + ': $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDeleteOfferDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('delete_offer'.tr),
        content: Text('confirm_delete_offer'.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteOffer();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('delete'.tr, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _deleteOffer() async {
    if (_taskAd?.myOffer == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final response = await _taskAdsService.deleteOffer(_taskAd!.myOffer!.id);

      if (mounted) {
        Navigator.pop(context); // Close loading

        if (response.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('offer_deleted_successfully'.tr),
              backgroundColor: Colors.green,
            ),
          );
          _refreshData(); // Refresh data to reflect the deleted offer
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? 'failed_to_delete_offer'.tr),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('error_occurred'.tr + ': $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _getStatusColor() {
    switch (_taskAd!.status.toLowerCase()) {
      case 'running':
        return Colors.green;
      case 'closed':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  String _getStatusText() {
    switch (_taskAd!.status.toLowerCase()) {
      case 'running':
         return 'status_running'.tr;
      case 'closed':
         return 'status_closed'.tr;
      default:
        return _taskAd!.status;
    }
  }

  Widget _buildDescriptionCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
               'task_description'.tr,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _taskAd!.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRangeCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
               'price_range'.tr,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.monetization_on, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                     child: _taskAd!.lowestPrice == 0 && _taskAd!.highestPrice == 0
                       ? Text(
                           'open_price'.tr,
                           style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                 fontWeight: FontWeight.w600,
                                 color: Colors.blue[700],
                               ),
                         )
                       : Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Text(
                               'from'.tr + ' ${_taskAd!.lowestPrice.toStringAsFixed(2)} ' + 'sar'.tr,
                               style:
                                   Theme.of(context).textTheme.bodyLarge?.copyWith(
                                         fontWeight: FontWeight.w600,
                                         color: Colors.blue[700],
                                       ),
                             ),
                             Text(
                               'to'.tr + ' ${_taskAd!.highestPrice.toStringAsFixed(2)} ' + 'sar'.tr,
                               style:
                                   Theme.of(context).textTheme.bodyLarge?.copyWith(
                                         fontWeight: FontWeight.w600,
                                         color: Colors.blue[700],
                                       ),
                             ),
                           ],
                         ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskDetailsCard() {
    final task = _taskAd!.task!;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
               'task_details'.tr,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // Vehicle size
            if (task.vehicleSize != null)
              _buildDetailRow(
                Icons.local_shipping,
                 'vehicle_size'.tr,
                task.vehicleSize!,
                Colors.purple,
              ),

            // Pickup point
            if (task.pickup != null) ...[
              const SizedBox(height: 12),
              _buildAddressDetail(
                 'pickup_point'.tr,
                task.pickup!,
                Colors.green,
              ),
            ],

            // Delivery point
            if (task.delivery != null) ...[
              const SizedBox(height: 12),
              _buildAddressDetail(
                 'delivery_point'.tr,
                task.delivery!,
                Colors.red,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
      IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddressDetail(String title, TaskAdPoint point, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.location_on, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(right: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                point.address,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              // إخفاء معلومات الاتصال في إعلانات المهام (لم يتم تسليم المهمة للسائق بعد)
              // if (point.contactName != null || point.contactPhone != null) ...[
              //   const SizedBox(height: 4),
              //   if (point.contactName != null)
              //     Text(
              //       'جهة الاتصال: ${point.contactName}',
              //       style: Theme.of(context).textTheme.bodySmall?.copyWith(
              //             color: Colors.grey[600],
              //           ),
              //     ),
              //   if (point.contactPhone != null)
              //     Text(
              //       'رقم الهاتف: ${point.contactPhone}',
              //       style: Theme.of(context).textTheme.bodySmall?.copyWith(
              //             color: Colors.grey[600],
              //           ),
              //     ),
              // ],
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildMyOfferCard() {
    final offer = _taskAd!.myOffer!;
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

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(statusIcon, color: statusColor),
                const SizedBox(width: 8),
                Text(
                   'my_offer'.tr,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    statusText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
               'proposed_price'.tr + ': ${offer.price.toStringAsFixed(2)} ' + 'sar'.tr,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[700],
                  ),
            ),
            if (offer.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                 'offer_description'.tr + ': ${offer.description}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
