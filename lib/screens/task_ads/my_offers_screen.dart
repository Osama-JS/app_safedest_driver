import 'package:flutter/material.dart';
import '../../services/task_ads_service.dart';
import '../../models/task_offer.dart';
import '../../widgets/offer_card.dart';
import 'task_ad_details_screen.dart';

class MyOffersScreen extends StatefulWidget {
  final VoidCallback? onRefresh;

  const MyOffersScreen({super.key, this.onRefresh});

  @override
  State<MyOffersScreen> createState() => MyOffersScreenState();
}

class MyOffersScreenState extends State<MyOffersScreen> {
  final TaskAdsService _taskAdsService = TaskAdsService();

  List<TaskOffer> _offers = [];
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMorePages = false;

  @override
  void initState() {
    super.initState();
    _loadOffers();
  }

  Future<void> _loadOffers({bool refresh = false}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
      if (refresh) {
        _currentPage = 1;
        _offers.clear();
      }
    });

    try {
      final response = await _taskAdsService.getMyOffers(
        page: _currentPage,
        perPage: 20,
      );

      debugPrint('MyOffersScreen: Response success: ${response.success}');
      debugPrint('MyOffersScreen: Response data: ${response.data}');
      debugPrint('MyOffersScreen: Response message: ${response.message}');

      if (response.success && response.data != null) {
        debugPrint(
            'MyOffersScreen: Offers count: ${response.data!.data.length}');
        setState(() {
          if (refresh) {
            _offers = response.data!.data;
          } else {
            _offers.addAll(response.data!.data);
          }
          _hasMorePages = response.data!.pagination?.hasMorePages ?? false;
          _currentPage++;
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = response.message ?? 'فشل في تحميل العروض';
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

  Future<void> _refreshOffers() async {
    await _loadOffers(refresh: true);
    widget.onRefresh?.call();
  }

  // Public method to refresh from parent
  Future<void> refreshOffers() async {
    await _refreshOffers();
  }

  void _navigateToAdDetails(TaskOffer offer) {
    if (offer.ad?.id != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TaskAdDetailsScreen(adId: offer.ad!.id),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا يمكن الوصول لتفاصيل الإعلان'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _loadMoreOffers() {
    if (_hasMorePages && !_isLoading) {
      _loadOffers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildBody();
  }

  Widget _buildBody() {
    if (_isLoading && _offers.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('جاري تحميل العروض...'),
          ],
        ),
      );
    }

    if (_hasError && _offers.isEmpty) {
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
              onPressed: _refreshOffers,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (_offers.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refreshOffers,
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
                    'لم تقم بتقديم أي عروض بعد',
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
      onRefresh: _refreshOffers,
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            _loadMoreOffers();
          }
          return false;
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _offers.length + (_hasMorePages ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _offers.length) {
              return _buildLoadingIndicator();
            }

            final offer = _offers[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                elevation: 2,
                child: InkWell(
                  onTap: () => _navigateToAdDetails(offer),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Ad info
                        Row(
                          children: [
                            const Icon(Icons.campaign, color: Colors.blue),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'إعلان #${offer.ad?.id ?? 'غير محدد'}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                            _buildStatusBadge(offer.status),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Price
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.monetization_on,
                                  color: Colors.green),
                              const SizedBox(width: 8),
                              Text(
                                'السعر المقترح: ${offer.price.toStringAsFixed(2)} ر.س',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
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
                          Text(
                            'الوصف: ${offer.description}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],

                        const SizedBox(height: 8),

                        // Timestamps
                        Row(
                          children: [
                            Icon(Icons.access_time,
                                size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              'تم التقديم: ${_formatDateTime(offer.createdAt)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusBadge(TaskOfferStatus status) {
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

    return Container(
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
    );
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
