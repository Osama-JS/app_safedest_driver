import 'package:flutter/material.dart';
import '../../services/task_ads_service.dart';
import '../../models/task_ad.dart';
import '../../models/task_offer.dart';
import '../../widgets/offer_card.dart';
import 'submit_offer_screen.dart';

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
          _errorMessage = adResponse.message ?? 'فشل في تحميل تفاصيل الإعلان';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'حدث خطأ غير متوقع: $e';
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
        title: Text('إعلان #${widget.adId}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'تحديث',
          ),
        ],
        bottom: _taskAd != null
            ? TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'تفاصيل الإعلان'),
                  Tab(text: 'العروض المقدمة'),
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
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('جاري تحميل التفاصيل...'),
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
              _errorMessage ?? 'حدث خطأ غير متوقع',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshData,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (_taskAd == null) {
      return const Center(
        child: Text('لا توجد بيانات للعرض'),
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

            // Commission info
            if (_taskAd!.commission != null) _buildCommissionCard(),

            // My offer status
            if (_taskAd!.myOffer != null) _buildMyOfferCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildOffersTab() {
    if (!_taskAd!.canViewDetails) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'لا يمكنك عرض العروض المقدمة',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'يجب تقديم عرض أولاً لعرض العروض الأخرى',
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
            const Center(
              child: Column(
                children: [
                  Icon(Icons.local_offer_outlined,
                      size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'لا توجد عروض مقدمة',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'لم يتم تقديم أي عروض لهذا الإعلان بعد',
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
                    'إعلان #${_taskAd!.id}',
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
                  'تاريخ الإنشاء: ${_formatDate(_taskAd!.createdAt)}',
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
                  'عدد العروض: ${_taskAd!.offersCount}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                if (_taskAd!.hasAcceptedOffer) ...[
                  const SizedBox(width: 16),
                  Icon(Icons.check_circle, size: 16, color: Colors.green[600]),
                  const SizedBox(width: 4),
                  Text(
                    'تم قبول عرض',
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
              color: Colors.black.withValues(alpha: 0.1),
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
              onPressed: _navigateToSubmitOffer,
              icon: Icon(
                _taskAd!.myOffer != null
                    ? Icons.edit_outlined
                    : Icons.add_circle_outline,
                size: 24,
              ),
              label: Text(
                _taskAd!.myOffer != null ? 'تعديل العرض' : 'تقديم عرض',
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
                    Theme.of(context).primaryColor.withValues(alpha: 0.3),
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

    if (taskAdsService.canAcceptTask(_taskAd!)) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
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
              label: const Text(
                'قبول المهمة',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: Colors.green.withValues(alpha: 0.3),
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
        title: const Text('قبول المهمة'),
        content: const Text('هل أنت متأكد من رغبتك في قبول هذه المهمة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _acceptTask();
            },
            child: const Text('قبول'),
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
            const SnackBar(
              content: Text('تم قبول المهمة بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
          _refreshData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? 'فشل في قبول المهمة'),
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
            content: Text('حدث خطأ: $e'),
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
        return 'جاري';
      case 'closed':
        return 'مغلق';
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
              'وصف المهمة',
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
              'نطاق الأسعار',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.monetization_on, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'من ${_taskAd!.lowestPrice.toStringAsFixed(2)} ر.س',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue[700],
                                  ),
                        ),
                        Text(
                          'إلى ${_taskAd!.highestPrice.toStringAsFixed(2)} ر.س',
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
              'تفاصيل المهمة',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // Vehicle size
            if (task.vehicleSize != null)
              _buildDetailRow(
                Icons.local_shipping,
                'حجم المركبة',
                task.vehicleSize!,
                Colors.purple,
              ),

            // Pickup point
            if (task.pickup != null) ...[
              const SizedBox(height: 12),
              _buildAddressDetail(
                'نقطة الاستلام',
                task.pickup!,
                Colors.green,
              ),
            ],

            // Delivery point
            if (task.delivery != null) ...[
              const SizedBox(height: 12),
              _buildAddressDetail(
                'نقطة التسليم',
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

  Widget _buildCommissionCard() {
    final commission = _taskAd!.commission!;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'معلومات العمولة والضرائب',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _buildCommissionRow(
              'عمولة الخدمة',
              commission.serviceCommissionType == 'fixed'
                  ? '${commission.serviceCommission.toStringAsFixed(2)} ر.س'
                  : '${commission.serviceCommission.toStringAsFixed(1)}%',
            ),
            const SizedBox(height: 8),
            _buildCommissionRow(
              'ضريبة القيمة المضافة',
              '${commission.vatCommission.toStringAsFixed(1)}%',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommissionRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
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
        statusText = 'في الانتظار';
        statusIcon = Icons.schedule;
        break;
      case TaskOfferStatus.accepted:
        statusColor = Colors.green;
        statusText = 'مقبول';
        statusIcon = Icons.check_circle;
        break;
      case TaskOfferStatus.rejected:
        statusColor = Colors.red;
        statusText = 'مرفوض';
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
                  'عرضي',
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
              'السعر المقترح: ${offer.price.toStringAsFixed(2)} ر.س',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[700],
                  ),
            ),
            if (offer.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'الوصف: ${offer.description}',
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
