import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/task_ads_service.dart';
import '../../models/task_ad.dart';
import '../../models/api_response.dart';
import '../../widgets/task_ad_card.dart';
import 'task_ad_details_screen.dart';
import 'my_offers_screen.dart';
import '../../l10n/generated/app_localizations.dart';

class TaskAdsScreen extends StatefulWidget {
  const TaskAdsScreen({super.key});

  @override
  State<TaskAdsScreen> createState() => _TaskAdsScreenState();
}

class _TaskAdsScreenState extends State<TaskAdsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TaskAdsService _taskAdsService = TaskAdsService();
  final GlobalKey<MyOffersScreenState> _myOffersKey =
      GlobalKey<MyOffersScreenState>();

  // State variables
  List<TaskAd> _taskAds = [];
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMorePages = false;

  // Search and filter
  final TextEditingController _searchController = TextEditingController();
  double? _minPrice;
  double? _maxPrice;
  String _sortBy = 'created_at';
  String _sortOrder = 'desc';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTaskAds();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTaskAds({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _taskAds.clear();
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      final response = await _taskAdsService.getTaskAds(
        page: _currentPage,
        perPage: 10,
        search:
            _searchController.text.isNotEmpty ? _searchController.text : null,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        sortBy: _sortBy,
        sortOrder: _sortOrder,
      );

      debugPrint('TaskAdsScreen: Response success: ${response.success}');
      debugPrint('TaskAdsScreen: Response data: ${response.data}');
      debugPrint('TaskAdsScreen: Response message: ${response.message}');

      if (response.success && response.data != null) {
        debugPrint('TaskAdsScreen: Ads count: ${response.data!.data.length}');
        setState(() {
          if (refresh) {
            _taskAds = response.data!.data;
          } else {
            _taskAds.addAll(response.data!.data);
          }
          _hasMorePages = response.data!.pagination?.hasMorePages ?? false;
          _currentPage++;
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _errorMessage =
              response.message ?? AppLocalizations.of(context)!.failedToLoadAds;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = '${AppLocalizations.of(context)!.unexpectedError}: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshTaskAds() async {
    await _loadTaskAds(refresh: true);
  }

  Future<void> _refreshCurrentTab() async {
    if (_tabController.index == 0) {
      // الإعلانات المتاحة
      await _refreshTaskAds();
    } else {
      // عروضي - تحديث العروض
      _myOffersKey.currentState?.refreshOffers();
    }
  }

  void _loadMoreTaskAds() {
    if (!_isLoading && _hasMorePages) {
      _loadTaskAds();
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => _FilterDialog(
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        sortBy: _sortBy,
        sortOrder: _sortOrder,
        onApply: (minPrice, maxPrice, sortBy, sortOrder) {
          setState(() {
            _minPrice = minPrice;
            _maxPrice = maxPrice;
            _sortBy = sortBy;
            _sortOrder = sortOrder;
          });
          _refreshTaskAds();
        },
      ),
    );
  }

  void _navigateToAdDetails(TaskAd ad) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskAdDetailsScreen(adId: ad.id),
      ),
    );
  }

  void _navigateToMyOffers() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MyOffersScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.taskAds),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: AppLocalizations.of(context)!.filter,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshCurrentTab,
            tooltip: AppLocalizations.of(context)!.refresh,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white, // لون النص للتبويب المحدد
          unselectedLabelColor: Colors.white
              .withValues(alpha: 0.7), // لون النص للتبويبات غير المحددة
          indicatorColor: Colors.white, // لون المؤشر
          tabs: [
            Tab(text: AppLocalizations.of(context)!.availableAds),
            Tab(text: AppLocalizations.of(context)!.myOffers),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTaskAdsList(),
          MyOffersScreen(key: _myOffersKey),
        ],
      ),
    );
  }

  Widget _buildTaskAdsList() {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.searchInAds,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _refreshTaskAds();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (_) {
              // تحديث فوري عند تغيير النص
              setState(() {}); // لتحديث suffixIcon
              _refreshTaskAds();
            },
            onSubmitted: (_) => _refreshTaskAds(),
          ),
        ),

        // Quick stats
        if (_taskAds.isNotEmpty) _buildQuickStats(),

        // Task ads list
        Expanded(
          child: _buildTaskAdsContent(),
        ),
      ],
    );
  }

  Widget _buildQuickStats() {
    final totalAds = _taskAds.length;
    final myOffersCount = _taskAds.where((ad) => ad.myOffer != null).length;
    final avgPrice = _taskAds.isNotEmpty
        ? _taskAds
                .map((ad) => (ad.lowestPrice + ad.highestPrice) / 2)
                .reduce((a, b) => a + b) /
            _taskAds.length
        : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
              AppLocalizations.of(context)!.totalAds, totalAds.toString()),
          _buildStatItem(
              AppLocalizations.of(context)!.myOffers, myOffersCount.toString()),
          _buildStatItem(AppLocalizations.of(context)!.averagePrice,
              '${avgPrice.toStringAsFixed(0)} ر.س'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
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

  Widget _buildTaskAdsContent() {
    if (_isLoading && _taskAds.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.loadingAds),
          ],
        ),
      );
    }

    if (_hasError && _taskAds.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              _errorMessage ??
                  AppLocalizations.of(context)!.unexpectedErrorOccurred,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshTaskAds,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (_taskAds.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refreshTaskAds,
        child: ListView(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.3),
            Center(
              child: Column(
                children: [
                  Icon(Icons.campaign_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.noAdsAvailable,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.noAdsAvailableDescription,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshTaskAds,
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            _loadMoreTaskAds();
          }
          return false;
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _taskAds.length + (_hasMorePages ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _taskAds.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            return TaskAdCard(
              taskAd: _taskAds[index],
              onTap: () => _navigateToAdDetails(_taskAds[index]),
            );
          },
        ),
      ),
    );
  }
}

class _FilterDialog extends StatefulWidget {
  final double? minPrice;
  final double? maxPrice;
  final String sortBy;
  final String sortOrder;
  final Function(double?, double?, String, String) onApply;

  const _FilterDialog({
    this.minPrice,
    this.maxPrice,
    required this.sortBy,
    required this.sortOrder,
    required this.onApply,
  });

  @override
  State<_FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<_FilterDialog> {
  late TextEditingController _minPriceController;
  late TextEditingController _maxPriceController;
  late String _selectedSortBy;
  late String _selectedSortOrder;

  @override
  void initState() {
    super.initState();
    _minPriceController = TextEditingController(
      text: widget.minPrice?.toString() ?? '',
    );
    _maxPriceController = TextEditingController(
      text: widget.maxPrice?.toString() ?? '',
    );
    _selectedSortBy = widget.sortBy;
    _selectedSortOrder = widget.sortOrder;
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.filterAds),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Price range
            const Text('نطاق الأسعار',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minPriceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.minPrice,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _maxPriceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.maxPrice,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Sort by
            Text(AppLocalizations.of(context)!.sortBy,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedSortBy,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(
                    value: 'created_at',
                    child: Text(AppLocalizations.of(context)!.creationDate)),
                DropdownMenuItem(
                    value: 'lowest_price',
                    child: Text(AppLocalizations.of(context)!.lowestPrice)),
                DropdownMenuItem(
                    value: 'highest_price',
                    child: Text(AppLocalizations.of(context)!.highestPrice)),
                DropdownMenuItem(
                    value: 'offers_count',
                    child: Text(AppLocalizations.of(context)!.offersCount)),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedSortBy = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Sort order
            Text(AppLocalizations.of(context)!.sortOrder,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedSortOrder,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'desc', child: Text('تنازلي')),
                DropdownMenuItem(value: 'asc', child: Text('تصاعدي')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedSortOrder = value!;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            // Clear filters
            _minPriceController.clear();
            _maxPriceController.clear();
            _selectedSortBy = 'created_at';
            _selectedSortOrder = 'desc';
            widget.onApply(null, null, _selectedSortBy, _selectedSortOrder);
            Navigator.pop(context);
          },
          child: Text(AppLocalizations.of(context)!.clearFilters),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            final minPrice = _minPriceController.text.isNotEmpty
                ? double.tryParse(_minPriceController.text)
                : null;
            final maxPrice = _maxPriceController.text.isNotEmpty
                ? double.tryParse(_maxPriceController.text)
                : null;

            widget.onApply(
                minPrice, maxPrice, _selectedSortBy, _selectedSortOrder);
            Navigator.pop(context);
          },
          child: Text(AppLocalizations.of(context)!.apply),
        ),
      ],
    );
  }
}
