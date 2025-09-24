import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/wallet_service.dart';
import '../../models/wallet.dart';
import '../../utils/debug_helper.dart';
import '../../config/app_config.dart';
import '../../l10n/generated/app_localizations.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  int _currentPage = 1;
  bool _isLoadingMore = false;
  String _searchQuery = '';
  WalletTransactionType? _selectedType;
  String? _selectedStatus;
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _scrollController.addListener(_onScroll);
    _loadTransactions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore) {
      _loadMoreTransactions();
    }
  }

  Future<void> _loadTransactions() async {
    final walletService = Provider.of<WalletService>(context, listen: false);
    await walletService.getTransactions(refresh: true);
  }

  Future<void> _loadMoreTransactions() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    final walletService = Provider.of<WalletService>(context, listen: false);
    _currentPage++;

    try {
      await walletService.getTransactions(page: _currentPage);
    } catch (e) {
      DebugHelper.log('Error loading more transactions: $e',
          tag: 'TRANSACTIONS');
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _refreshTransactions() async {
    _currentPage = 1;
    await _loadTransactions();
  }

  List<WalletTransaction> _getFilteredTransactions(
      List<WalletTransaction> transactions) {
    List<WalletTransaction> filtered = transactions;

    // تطبيق البحث
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((transaction) =>
              transaction.description
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              (transaction.referenceId
                      ?.toLowerCase()
                      .contains(_searchQuery.toLowerCase()) ??
                  false))
          .toList();
    }

    // تطبيق فلتر النوع
    if (_selectedType != null) {
      filtered = filtered
          .where((transaction) =>
              transaction.type.toLowerCase() ==
              _selectedType!.value.toLowerCase())
          .toList();
    }

    // تطبيق فلتر الحالة
    if (_selectedStatus != null) {
      filtered = filtered
          .where((transaction) =>
              transaction.status.toLowerCase() ==
              _selectedStatus!.toLowerCase())
          .toList();
    }

    // تطبيق فلتر التاريخ
    if (_selectedDateRange != null) {
      filtered = filtered.where((transaction) {
        final transactionDate = transaction.createdAt;
        return transactionDate.isAfter(
                _selectedDateRange!.start.subtract(const Duration(days: 1))) &&
            transactionDate
                .isBefore(_selectedDateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
      // Fallback or error handling
      return const SizedBox.shrink();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.transactionHistory),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              // شريط البحث
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText:
                        AppLocalizations.of(context)!.searchInTransactions,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              // التبويبات
              TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: Colors.white, // لون النص للتبويب المحدد
                unselectedLabelColor: Colors.white
                    .withValues(alpha: 0.7), // لون النص للتبويبات غير المحددة
                indicatorColor: Colors.white, // لون المؤشر
                tabs: [
                  Tab(text: AppLocalizations.of(context)!.all),
                  Tab(text: AppLocalizations.of(context)!.deposits),
                  Tab(text: AppLocalizations.of(context)!.withdrawals),
                  Tab(text: AppLocalizations.of(context)!.withAttachments),
                ],
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshTransactions,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTransactionsList(),
          _buildTransactionsList(type: WalletTransactionType.credit),
          _buildTransactionsList(type: WalletTransactionType.debit),
          _buildTransactionsWithAttachments(),
        ],
      ),
    );
  }

  Widget _buildTransactionsList({WalletTransactionType? type}) {
    return Consumer<WalletService>(
      builder: (context, walletService, child) {
        List<WalletTransaction> transactions = walletService.transactions;

        if (type != null) {
          transactions = transactions
              .where((transaction) => transaction.type == type.value)
              .toList();
        }

        // تطبيق الفلاتر
        transactions = _getFilteredTransactions(transactions);

        return RefreshIndicator(
          onRefresh: _refreshTransactions,
          child: _buildStateHandler(
            isLoading: walletService.isLoading && transactions.isEmpty,
            hasError: walletService.hasError,
            errorMessage: walletService.errorMessage,
            data: transactions,
            onRetry: _loadTransactions,
            emptyMessage: AppLocalizations.of(context)!.noTransactions,
            emptyDescription: type != null
                ? '${AppLocalizations.of(context)!.noTransactionsOfType} ${type.displayName}'
                : AppLocalizations.of(context)!.noTransactionsFound,
            loadingMessage: AppLocalizations.of(context)!.loadingTransactions,
            builder: (transactions) => ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: transactions.length + (_isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == transactions.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                return _buildAdvancedTransactionCard(transactions[index]);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildTransactionsWithAttachments() {
    return Consumer<WalletService>(
      builder: (context, walletService, child) {
        List<WalletTransaction> transactions = walletService.transactions
            .where((transaction) =>
                transaction.image != null && transaction.image!.isNotEmpty)
            .toList();

        // تطبيق الفلاتر
        transactions = _getFilteredTransactions(transactions);

        return RefreshIndicator(
          onRefresh: _refreshTransactions,
          child: _buildStateHandler(
            isLoading: walletService.isLoading && transactions.isEmpty,
            hasError: walletService.hasError,
            errorMessage: walletService.errorMessage,
            data: transactions,
            onRetry: _loadTransactions,
            emptyMessage:
                AppLocalizations.of(context)!.noTransactionsWithAttachments,
            emptyDescription: AppLocalizations.of(context)!
                .noTransactionsWithAttachmentsDescription,
            loadingMessage: AppLocalizations.of(context)!.loadingTransactions,
            builder: (transactions) => ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: transactions.length + (_isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == transactions.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                return _buildAdvancedTransactionCard(transactions[index]);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildAdvancedTransactionCard(WalletTransaction transaction) {
    final isCredit = transaction.isCredit;
    final color = isCredit ? Colors.green : Colors.red;
    final icon = _getTransactionIcon(transaction.type);
    final hasAttachment =
        transaction.image != null && transaction.image!.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showAdvancedTransactionDetails(transaction),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                transaction.description,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (hasAttachment)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _isImageFile(transaction.image!)
                                          ? Icons.image
                                          : Icons.picture_as_pdf,
                                      size: 16,
                                      color: Colors.blue,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      AppLocalizations.of(context)!
                                          .attachmentLabel,
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(transaction.status)
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                transaction.id.toString(),
                                style: TextStyle(
                                  color: _getStatusColor(transaction.status),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatDate(transaction.createdAt),
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
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${isCredit ? '+' : '-'}${transaction.amount.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: color,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        'ر.س',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ],
              ),
              if (transaction.referenceId != null) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${AppLocalizations.of(context)!.referenceNumberLabel}: ${transaction.referenceId}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                          color: Colors.grey[700],
                        ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getTransactionIcon(String type) {
    switch (type.toLowerCase()) {
      case 'credit':
      case 'deposit':
        return Icons.add_circle_outline;
      case 'debit':
      case 'withdrawal':
        return Icons.remove_circle_outline;
      case 'commission':
        return Icons.star_outline;
      default:
        return Icons.swap_horiz;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'مكتملة';
      case 'pending':
        return 'معلقة';
      case 'failed':
        return 'فاشلة';
      default:
        return status;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'اليوم ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'أمس';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} أيام';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  bool _isImageFile(String filename) {
    final imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'];
    final lowerFilename = filename.toLowerCase();
    return imageExtensions.any((ext) => lowerFilename.endsWith(ext));
  }

  void _showAdvancedTransactionDetails(WalletTransaction transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildAdvancedTransactionDetailsSheet(transaction),
    );
  }

  Widget _buildAdvancedTransactionDetailsSheet(WalletTransaction transaction) {
    final hasAttachment =
        transaction.image != null && transaction.image!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'تفاصيل المعاملة',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildDetailRow(AppLocalizations.of(context)!.amount,
              '${transaction.amount.toStringAsFixed(2)} ر.س'),
          _buildDetailRow(AppLocalizations.of(context)!.type,
              WalletTransactionType.fromString(transaction.type).displayName),
          _buildDetailRow(AppLocalizations.of(context)!.description,
              transaction.description),
          _buildDetailRow(AppLocalizations.of(context)!.date,
              '${transaction.createdAt.day}/${transaction.createdAt.month}/${transaction.createdAt.year}'),
          _buildDetailRow(AppLocalizations.of(context)!.time,
              '${transaction.createdAt.hour.toString().padLeft(2, '0')}:${transaction.createdAt.minute.toString().padLeft(2, '0')}'),
          if (transaction.referenceId != null)
            _buildDetailRow(AppLocalizations.of(context)!.referenceNumber,
                transaction.referenceId!),
          if (transaction.maturityTime != null)
            _buildDetailRow(AppLocalizations.of(context)!.maturityDate,
                '${transaction.maturityTime!.day}/${transaction.maturityTime!.month}/${transaction.maturityTime!.year}'),
          if (hasAttachment) ...[
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.attach_file,
                  color: Colors.blue[600],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.attachment,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[600],
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildAttachmentWidget(transaction.image!),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentWidget(String imageUrl) {
    final isImage = _isImageFile(imageUrl);
    final fileName = _getFileNameFromUrl(imageUrl);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // عرض معاينة المرفق قابلة للضغط
          GestureDetector(
            onTap: () => _showWalletAttachmentDialog(imageUrl, fileName),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: isImage
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          height: 200,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: 200,
                          color: Colors.grey[200],
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline,
                                    size: 48, color: Colors.grey),
                                SizedBox(height: 8),
                                Text('failed To Load Image'),
                              ],
                            ),
                          ),
                        ),
                      )
                    : Container(
                        height: 120,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _getFileIconFromUrl(imageUrl),
                                size: 48,
                                color: Colors.blue[600],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                fileName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                AppLocalizations.of(context)!.tapToView,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // أزرار الإجراءات
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () =>
                      _showWalletAttachmentDialog(imageUrl, fileName),
                  icon: const Icon(Icons.visibility),
                  label: Text(AppLocalizations.of(context)!.view),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      _downloadWalletAttachment(imageUrl, fileName),
                  icon: const Icon(Icons.download),
                  label: Text(AppLocalizations.of(context)!.download),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.filterTransactions),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<WalletTransactionType>(
                  value: _selectedType,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.type,
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: WalletTransactionType.deposit,
                      child: Text(AppLocalizations.of(context)!.deposit),
                    ),
                    DropdownMenuItem(
                      value: WalletTransactionType.withdrawal,
                      child: Text(AppLocalizations.of(context)!.withdrawal),
                    ),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      _selectedType = value;
                    });
                  },
                ),
                // const SizedBox(height: 16),
                // DropdownButtonFormField<String>(
                //   value: _selectedStatus,
                //   decoration: const InputDecoration(
                //     labelText: 'حالة المعاملة',
                //     border: OutlineInputBorder(),
                //   ),
                //   items: ['completed', 'pending', 'failed'].map((status) {
                //     return DropdownMenuItem(
                //       value: status,
                //       child: Text(_getStatusText(status)),
                //     );
                //   }).toList(),
                //   onChanged: (value) {
                //     setDialogState(() {
                //       _selectedStatus = value;
                //     });
                //   },
                // ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text(_selectedDateRange == null
                      ? AppLocalizations.of(context)!.selectDateRange
                      : '${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month} - ${_selectedDateRange!.end.day}/${_selectedDateRange!.end.month}'),
                  leading: const Icon(Icons.date_range),
                  onTap: () async {
                    final dateRange = await showDateRangePicker(
                      context: context,
                      firstDate:
                          DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now(),
                      initialDateRange: _selectedDateRange,
                    );
                    if (dateRange != null) {
                      setDialogState(() {
                        _selectedDateRange = dateRange;
                      });
                    }
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedType = null;
                _selectedStatus = null;
                _selectedDateRange = null;
              });
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
              setState(() {});
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.apply),
          ),
        ],
      ),
    );
  }

  Widget _buildStateHandler({
    required bool isLoading,
    required bool hasError,
    required String? errorMessage,
    required List<WalletTransaction> data,
    required VoidCallback onRetry,
    required String emptyMessage,
    required String emptyDescription,
    required String loadingMessage,
    required Widget Function(List<WalletTransaction>) builder,
  }) {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(loadingMessage),
          ],
        ),
      );
    }

    if (hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              errorMessage ??
                  AppLocalizations.of(context)!.unexpectedErrorOccurred,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: Text(AppLocalizations.of(context)!.retry),
            ),
          ],
        ),
      );
    }

    if (data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              emptyDescription,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return builder(data);
  }

  // دوال مساعدة للمرفقات
  String _getFileNameFromUrl(String url) {
    return url.split('/').last.split('?').first;
  }

  IconData _getFileIconFromUrl(String url) {
    final fileName = _getFileNameFromUrl(url);
    final extension = fileName.toLowerCase().split('.').last;

    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'txt':
        return Icons.text_snippet;
      case 'zip':
      case 'rar':
        return Icons.archive;
      default:
        return Icons.insert_drive_file;
    }
  }

  void _showWalletAttachmentDialog(String fileUrl, String fileName) {
    final isImage = _isImageFile(fileUrl);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(8)),
                ),
                child: Row(
                  children: [
                    Icon(
                      isImage ? Icons.image : Icons.insert_drive_file,
                      color: Colors.blue[700],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        fileName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: isImage
                      ? _buildWalletImageViewer(fileUrl)
                      : _buildWalletFileViewer(fileName, fileUrl),
                ),
              ),

              // Actions
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () =>
                          _downloadWalletAttachment(fileUrl, fileName),
                      icon: const Icon(Icons.download),
                      label: Text(AppLocalizations.of(context)!.download),
                    ),
                    if (!isImage)
                      ElevatedButton.icon(
                        onPressed: () => _openWalletAttachment(fileUrl),
                        icon: const Icon(Icons.open_in_new),
                        label: Text(AppLocalizations.of(context)!.open),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWalletImageViewer(String imageUrl) {
    return Center(
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.contain,
        placeholder: (context, url) => const CircularProgressIndicator(),
        errorWidget: (context, url, error) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('${AppLocalizations.of(context)!.imageLoadError}: $error'),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletFileViewer(String fileName, String fileUrl) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getFileIconFromUrl(fileUrl),
            size: 64,
            color: Colors.blue[600],
          ),
          const SizedBox(height: 16),
          Text(
            fileName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.tapOpenToViewFile,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadWalletAttachment(
      String fileUrl, String fileName) async {
    try {
      final uri = Uri.parse(fileUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(AppLocalizations.of(context)!.fileOpenedForDownload),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw 'Could not launch $fileUrl';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تحميل الملف: $e')),
        );
      }
    }
  }

  Future<void> _openWalletAttachment(String fileUrl) async {
    try {
      final uri = Uri.parse(fileUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $fileUrl';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في فتح الملف: $e')),
        );
      }
    }
  }
}
