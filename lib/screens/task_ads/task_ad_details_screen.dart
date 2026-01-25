import 'package:flutter/material.dart';
import '../../services/task_ads_service.dart';
import '../../models/task_ad.dart';
import '../../models/task_offer.dart';
import '../../widgets/offer_card.dart';
import 'submit_offer_screen.dart';
import 'package:get/get.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // Tutorial Keys
  final GlobalKey _infoKey = GlobalKey();
  final GlobalKey _submitKey = GlobalKey();
  final GlobalKey _helpKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAdDetails();
    _checkTutorial();
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
      final adResponse = await _taskAdsService.getTaskAdDetails(widget.adId);

      if (adResponse.success && adResponse.data != null) {
        setState(() {
          _taskAd = adResponse.data!;
        });

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
          IconButton(
            key: _helpKey,
            icon: const Icon(Icons.help_outline),
            tooltip: 'help'.tr,
            onPressed: _viewTutorial,
          ),
        ],
        bottom: _taskAd != null
            ? TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white.withOpacity(0.7),
                indicatorColor: Colors.white,
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
            Container(key: _infoKey, child: _buildStatusCard()),
            const SizedBox(height: 16),
            if (_taskAd!.description.isNotEmpty) _buildDescriptionCard(),
            _buildPriceRangeCard(),
            const SizedBox(height: 16),
            if (_taskAd!.task != null) _buildTaskDetailsCard(),
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
                    _taskAd!.myOffer?.accepted == true
                        ? 'your_offer_accepted'.tr
                        : 'ad_offer_accepted'.tr,
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
        key: _submitKey,
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
        key: _submitKey,
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
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _showAcceptTaskDialog,
                    icon: const Icon(
                      Icons.check_circle_outline,
                      size: 24,
                    ),
                    label: Text(
                      'accept_task'.tr,
                      style: const TextStyle(
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _showRejectTaskDialog,
                    icon: const Icon(
                      Icons.cancel_outlined,
                      size: 24,
                    ),
                    label: Text(
                      'reject_task'.tr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: Colors.red.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                    ),
                  ),
                ),
              ),
            ],
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
            child:
                Text('reject_task'.tr, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _rejectTask() async {
    if (_taskAd?.myOffer == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

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
          _refreshData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? 'failed_to_reject_task'.tr),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('error_occurred'.tr + ': $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _acceptTask() async {
    if (_taskAd?.myOffer == null) return;

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
        Navigator.pop(context);

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
        Navigator.pop(context);
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
        Navigator.pop(context);

        if (response.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('offer_deleted_successfully'.tr),
              backgroundColor: Colors.green,
            ),
          );
          _refreshData();
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
        Navigator.pop(context);
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
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPriceItem('lowest_price'.tr, _taskAd!.lowestPrice),
                const Icon(Icons.arrow_forward, color: Colors.grey),
                _buildPriceItem('highest_price'.tr, _taskAd!.highestPrice),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceItem(String label, double value) {
    return Column(
      children: [
        Text(
          '${value.toStringAsFixed(2)} ر.س',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
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
              'task_info'.tr,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(Icons.location_on, 'pickup_point'.tr, task.pickup?.address ?? '-'),
            const SizedBox(height: 12),
            _buildDetailRow(Icons.flag, 'delivery_point'.tr, task.delivery?.address ?? '-'),
            if (_taskAd!.commission != null) ...[
              const SizedBox(height: 12),
              _buildDetailRow(Icons.monetization_on, 'commission'.tr, '${_taskAd!.commission!.serviceCommission} ر.س'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMyOfferCard() {
    final offer = _taskAd!.myOffer!;
    return Card(
      color: Theme.of(context).primaryColor.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_offer, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'your_offer'.tr,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                ),
                const Spacer(),
                _buildOfferStatusBadge(offer.status),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${offer.price.toStringAsFixed(2)} ر.س',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (offer.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                offer.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOfferStatusBadge(TaskOfferStatus status) {
    Color color;
    String text;

    switch (status) {
      case TaskOfferStatus.pending:
        color = Colors.orange;
        text = 'status_pending'.tr;
        break;
      case TaskOfferStatus.accepted:
        color = Colors.green;
        text = 'status_accepted'.tr;
        break;
      case TaskOfferStatus.rejected:
        color = Colors.red;
        text = 'status_rejected'.tr;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // --- Tutorial Methods ---

  TutorialCoachMark? tutorialCoachMark;

  void _checkTutorial() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasSeen = prefs.getBool('hasSeenAdDetailsTutorial') ?? false;

    if (!hasSeen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _viewTutorial();
      });
    }
  }

  void _viewTutorial() {
    tutorialCoachMark = TutorialCoachMark(
      targets: _createTargets(),
      colorShadow: Colors.red.shade500,
      textSkip: "tutorial_skip".tr,
      paddingFocus: 10,
      opacityShadow: 0.9,
      onFinish: _markTutorialAsSeen,
      onClickTarget: (target) {},
      onSkip: () {
        _markTutorialAsSeen();
        return true;
      },
    );

    tutorialCoachMark?.show(context: context);
  }

  void _markTutorialAsSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenAdDetailsTutorial', true);
  }

  List<TargetFocus> _createTargets() {
    List<TargetFocus> targets = [];

    targets.add(
      TargetFocus(
        identify: "ad_info",
        keyTarget: _infoKey,
        shape: ShapeLightFocus.RRect,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: _buildTutorialItem(
              title: "tutorial_ad_details_info_title".tr,
              description: "tutorial_ad_details_info_desc".tr,
            ),
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "submit_offer",
        keyTarget: _submitKey,
        shape: ShapeLightFocus.RRect,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: _buildTutorialItem(
              title: "tutorial_ad_details_offer_title".tr,
              description: "tutorial_ad_details_offer_desc".tr,
            ),
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "help_btn",
        keyTarget: _helpKey,
        shape: ShapeLightFocus.Circle,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: _buildTutorialItem(
              title: "replay_instructions".tr,
              description: "tap_to_rewatch".tr,
            ),
          ),
        ],
      ),
    );

    return targets;
  }

  Widget _buildTutorialItem({required String title, required String description}) {
    return Container(
      constraints: BoxConstraints(maxWidth: Get.width * 0.8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(150),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(description, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        ],
      ),
    );
  }
}
