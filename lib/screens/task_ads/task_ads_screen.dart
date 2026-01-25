import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../services/task_ads_service.dart';
import '../../models/task_ad.dart';
import '../../models/api_response.dart';
import '../../widgets/task_ad_card.dart';
import 'task_ad_details_screen.dart';
import 'my_offers_screen.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // Tutorial Keys
  final GlobalKey _filterKey = GlobalKey();
  final GlobalKey _refreshKey = GlobalKey();
  final GlobalKey _tabsKey = GlobalKey();
  final GlobalKey _searchKey = GlobalKey();
  final GlobalKey _helpKey = GlobalKey();

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
    _checkTutorial();
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

      if (response.success && response.data != null) {
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
      await _refreshTaskAds();
    } else {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.taskAds),
        actions: [
          IconButton(
            key: _filterKey,
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: AppLocalizations.of(context)!.filter,
          ),
          IconButton(
            key: _refreshKey,
            icon: const Icon(Icons.refresh),
            onPressed: _refreshCurrentTab,
            tooltip: AppLocalizations.of(context)!.refresh,
          ),
          IconButton(
            key: _helpKey,
            icon: const Icon(Icons.help_outline),
            onPressed: _viewTutorial,
            tooltip: "help".tr,
          ),
        ],
        bottom: TabBar(
          key: _tabsKey,
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          indicatorColor: Colors.white,
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
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            key: _searchKey,
            controller: _searchController,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.searchInAds,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                        _refreshTaskAds();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (_) {
              setState(() {});
              _refreshTaskAds();
            },
            onSubmitted: (_) => _refreshTaskAds(),
          ),
        ),
        if (_taskAds.isNotEmpty) _buildQuickStats(),
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
            const SizedBox(height: 16),
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
                  const Icon(Icons.campaign_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
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

  // --- Tutorial Methods ---

  TutorialCoachMark? tutorialCoachMark;

  void _checkTutorial() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasSeen = prefs.getBool('hasSeenTaskAdsTutorial') ?? false;

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
    await prefs.setBool('hasSeenTaskAdsTutorial', true);
  }

  List<TargetFocus> _createTargets() {
    List<TargetFocus> targets = [];

    targets.add(
      TargetFocus(
        identify: "search_bar",
        keyTarget: _searchKey,
        shape: ShapeLightFocus.RRect,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: _buildTutorialItem(
              title: "tutorial_ads_search_title".tr,
              description: "tutorial_ads_search_desc".tr,
            ),
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "filter_btn",
        keyTarget: _filterKey,
        shape: ShapeLightFocus.Circle,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: _buildTutorialItem(
              title: "tutorial_ads_filter_title".tr,
              description: "tutorial_ads_filter_desc".tr,
            ),
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "refresh_btn",
        keyTarget: _refreshKey,
        shape: ShapeLightFocus.Circle,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: _buildTutorialItem(
              title: "tutorial_ads_refresh_title".tr,
              description: "tutorial_ads_refresh_desc".tr,
            ),
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "ads_tabs",
        keyTarget: _tabsKey,
        shape: ShapeLightFocus.RRect,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: _buildTutorialItem(
              title: "tutorial_ads_tabs_title".tr,
              description: "tutorial_ads_tabs_desc".tr,
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
