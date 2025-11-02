// import 'package:flutter/foundation.dart';
// import '../config/app_config.dart';
// import '../models/api_response.dart';
// import '../models/wallet.dart';
// import 'api_service.dart';
//
// class WalletService extends ChangeNotifier {
//   static final WalletService _instance = WalletService._internal();
//   factory WalletService() => _instance;
//   WalletService._internal();
//
//   final ApiService _apiService = ApiService();
//
//   Wallet? _wallet;
//   List<WalletTransaction> _transactions = [];
//   EarningsStats? _earningsStats;
//   bool _isLoading = false;
//   String? _errorMessage;
//   bool _hasError = false;
//
//   // Getters
//   Wallet? get wallet => _wallet;
//   List<WalletTransaction> get transactions => _transactions;
//   List<WalletTransaction> get recentTransactionsShort =>
//       _transactions.take(5).toList();
//   EarningsStats? get earningsStats => _earningsStats;
//   bool get isLoading => _isLoading;
//   String? get errorMessage => _errorMessage;
//   bool get hasError => _hasError;
//   bool get isEmpty => _transactions.isEmpty && !_isLoading;
//   bool get hasData => _transactions.isNotEmpty;
//   String get currencySymbol => 'ر.س';
//
//   // Get wallet information
//   Future<ApiResponse<WalletResponse>> getWallet() async {
//     _setLoading(true);
//
//     try {
//       final response = await _apiService.get<WalletResponse>(
//         AppConfig.walletEndpoint,
//         fromJson: (data) => WalletResponse.fromJson(data['data'] ?? data),
//       );
//
//       if (response.isSuccess && response.data != null) {
//         _wallet = response.data!.wallet;
//         notifyListeners();
//       }
//
//       return response;
//     } catch (e) {
//       return ApiResponse<WalletResponse>(
//         success: false,
//         message: 'فشل في جلب بيانات المحفظة: $e',
//       );
//     } finally {
//       _setLoading(false);
//     }
//   }
//
//   // Get wallet transactions
//   Future<ApiResponse<WalletTransactionsResponse>> getTransactions({
//     int page = 1,
//     int perPage = 20,
//     String? type,
//     String? from,
//     String? to,
//     bool refresh = false,
//   }) async {
//     if (page == 1 || refresh) {
//       _clearError();
//     }
//
//     try {
//       final queryParams = <String, String>{
//         'page': page.toString(),
//         'per_page': perPage.toString(),
//         if (type != null) 'type': type,
//         if (from != null) 'from': from,
//         if (to != null) 'to': to,
//       };
//
//       debugPrint('Fetching transactions with params: $queryParams');
//
//       final response = await _apiService.get<WalletTransactionsResponse>(
//         AppConfig.transactionsEndpoint,
//         queryParams: queryParams,
//         fromJson: (data) =>
//             WalletTransactionsResponse.fromJson(data['data'] ?? data),
//       );
//
//       if (response.isSuccess && response.data != null) {
//         final newTransactions = response.data!.transactions;
//         debugPrint('Received ${newTransactions.length} transactions from API');
//
//         if (page == 1 || refresh) {
//           _transactions = newTransactions;
//         } else {
//           _transactions.addAll(newTransactions);
//         }
//
//         _clearError();
//         notifyListeners();
//       } else {
//         _setError(response.errorMessage ?? 'فشل في جلب المعاملات المالية');
//         debugPrint('API Error: ${response.errorMessage}');
//       }
//
//       return response;
//     } catch (e) {
//       final errorMsg = 'فشل في جلب المعاملات المالية: $e';
//       _setError(errorMsg);
//       debugPrint('Exception in getTransactions: $e');
//
//       return ApiResponse<WalletTransactionsResponse>(
//         success: false,
//         message: errorMsg,
//       );
//     }
//   }
//
//   // Get earnings statistics from real transaction data
//   Future<ApiResponse<EarningsStatsResponse>> getEarningsStats({
//     EarningsPeriod period = EarningsPeriod.month,
//   }) async {
//     try {
//       // First ensure we have transaction data
//       if (_transactions.isEmpty) {
//         await getTransactions(page: 1);
//       }
//
//       // Calculate real earnings statistics from transactions
//       final realStats = _calculateRealEarningsStats(period);
//       _earningsStats = realStats;
//       notifyListeners();
//
//       return ApiResponse<EarningsStatsResponse>(
//         success: true,
//         message: 'تم جلب إحصائيات الأرباح بنجاح',
//         data: EarningsStatsResponse(
//           success: true,
//           stats: realStats,
//         ),
//       );
//
//       // TODO: Uncomment this when API is ready
//       /*
//       final queryParams = <String, String>{
//         'period': period.value,
//       };
//
//       final response = await _apiService.get<EarningsStatsResponse>(
//         AppConfig.earningsStatsEndpoint,
//         queryParams: queryParams,
//         fromJson: (data) =>
//             EarningsStatsResponse.fromJson(data['data'] ?? data),
//       );
//
//       if (response.isSuccess && response.data != null) {
//         _earningsStats = response.data!.stats;
//         notifyListeners();
//       }
//
//       return response;
//       */
//     } catch (e) {
//       return ApiResponse<EarningsStatsResponse>(
//         success: false,
//         message: 'فشل في جلب إحصائيات الأرباح: $e',
//       );
//     }
//   }
//
//   // Get transactions by type
//   Future<ApiResponse<WalletTransactionsResponse>> getTransactionsByType(
//     WalletTransactionType type, {
//     int page = 1,
//     int perPage = 20,
//   }) async {
//     return getTransactions(
//       page: page,
//       perPage: perPage,
//       type: type.value,
//     );
//   }
//
//   // Get credit transactions
//   Future<ApiResponse<WalletTransactionsResponse>> getCreditTransactions({
//     int page = 1,
//     int perPage = 20,
//   }) async {
//     return getTransactionsByType(
//       WalletTransactionType.credit,
//       page: page,
//       perPage: perPage,
//     );
//   }
//
//   // Get debit transactions
//   Future<ApiResponse<WalletTransactionsResponse>> getDebitTransactions({
//     int page = 1,
//     int perPage = 20,
//   }) async {
//     return getTransactionsByType(
//       WalletTransactionType.debit,
//       page: page,
//       perPage: perPage,
//     );
//   }
//
//   // Get commission transactions
//   Future<ApiResponse<WalletTransactionsResponse>> getCommissionTransactions({
//     int page = 1,
//     int perPage = 20,
//   }) async {
//     return getTransactionsByType(
//       WalletTransactionType.commission,
//       page: page,
//       perPage: perPage,
//     );
//   }
//
//   // Get earnings for different periods
//   Future<ApiResponse<EarningsStatsResponse>> getTodayEarnings() async {
//     return getEarningsStats(period: EarningsPeriod.today);
//   }
//
//   Future<ApiResponse<EarningsStatsResponse>> getWeekEarnings() async {
//     return getEarningsStats(period: EarningsPeriod.week);
//   }
//
//   Future<ApiResponse<EarningsStatsResponse>> getMonthEarnings() async {
//     return getEarningsStats(period: EarningsPeriod.month);
//   }
//
//   Future<ApiResponse<EarningsStatsResponse>> getYearEarnings() async {
//     return getEarningsStats(period: EarningsPeriod.year);
//   }
//
//   // Refresh wallet data
//   Future<void> refreshWallet() async {
//     await getWallet();
//   }
//
//   // Refresh transactions
//   Future<void> refreshTransactions() async {
//     await getTransactions(page: 1);
//   }
//
//   // Refresh earnings stats
//   Future<void> refreshEarningsStats() async {
//     await getEarningsStats();
//   }
//
//   // Refresh all wallet data
//   Future<void> refreshAll() async {
//     await Future.wait([
//       refreshWallet(),
//       refreshTransactions(),
//       refreshEarningsStats(),
//     ]);
//   }
//
//   // Clear wallet data
//   void clearWalletData() {
//     _wallet = null;
//     _transactions.clear();
//     _earningsStats = null;
//     notifyListeners();
//   }
//
//   // Private methods
//   void _setLoading(bool loading) {
//     _isLoading = loading;
//     notifyListeners();
//   }
//
//   void _setError(String message) {
//     _errorMessage = message;
//     _hasError = true;
//     notifyListeners();
//   }
//
//   void _clearError() {
//     _errorMessage = null;
//     _hasError = false;
//     notifyListeners();
//   }
//
//   // Helper methods
//   double get currentBalance => _wallet?.balance ?? 0.0;
//   double get totalEarnings => _wallet?.totalEarnings ?? 0.0;
//   double get pendingAmount => _wallet?.pendingAmount ?? 0.0;
//   String get currency => _wallet?.currency ?? 'SAR';
//
//   // Get transaction by ID
//   WalletTransaction? getTransactionById(int id) {
//     try {
//       return _transactions.firstWhere((transaction) => transaction.id == id);
//     } catch (e) {
//       return null;
//     }
//   }
//
//   // Get transactions by type from local list
//   List<WalletTransaction> getLocalTransactionsByType(TransactionType type) {
//     return _transactions
//         .where((transaction) => transaction.type == type.value)
//         .toList();
//   }
//
//   // Get credit transactions from local list
//   List<WalletTransaction> get localCreditTransactions {
//     return _transactions.where((transaction) => transaction.isCredit).toList();
//   }
//
//   // Get debit transactions from local list
//   List<WalletTransaction> get localDebitTransactions {
//     return _transactions.where((transaction) => transaction.isDebit).toList();
//   }
//
//   // Calculate total for transaction type
//   double getTotalForTransactionType(TransactionType type) {
//     return _transactions
//         .where((transaction) => transaction.type == type.value)
//         .fold(0.0, (sum, transaction) => sum + transaction.amount);
//   }
//
//   // Get recent transactions (last 10)
//   List<WalletTransaction> get recentTransactions {
//     final sortedTransactions = List<WalletTransaction>.from(_transactions);
//     sortedTransactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
//     return sortedTransactions.take(10).toList();
//   }
//
//   // Check if has sufficient balance
//   bool hasSufficientBalance(double amount) {
//     return currentBalance >= amount;
//   }
//
//   // Format currency
//   String formatCurrency(double amount) {
//     return '${amount.toStringAsFixed(2)} $currency';
//   }
//
//   // Get commission display text
//   String get commissionDisplayText {
//     if (_wallet?.commission == null) return '';
//     return _wallet!.commission.displayValue;
//   }
//
//   // Calculate real earnings statistics from transaction data
//   EarningsStats _calculateRealEarningsStats(EarningsPeriod period) {
//     final now = DateTime.now();
//
//     // If no transactions available, return empty stats
//     if (_transactions.isEmpty) {
//       return _createEmptyEarningsStats(period, now);
//     }
//
//     // Filter transactions based on period
//     final filteredTransactions =
//         _filterTransactionsByPeriod(_transactions, period, now);
//
//     // Get only credit transactions (earnings) - exclude withdrawals
//     final earningsTransactions = filteredTransactions
//         .where((t) => t.isCredit && t.type != 'withdrawal')
//         .toList();
//
//     // If no earnings transactions in this period, return empty stats
//     if (earningsTransactions.isEmpty) {
//       return _createEmptyEarningsStats(period, now);
//     }
//
//     // Calculate total earnings
//     final totalEarnings = earningsTransactions.fold<double>(
//       0.0,
//       (sum, transaction) => sum + transaction.amount,
//     );
//
//     // Calculate total tasks (assuming each earning transaction represents a task)
//     final totalTasks = earningsTransactions.length;
//
//     // Calculate average earning per task
//     final averageEarningPerTask =
//         totalTasks > 0 ? totalEarnings / totalTasks : 0.0;
//
//     // Group transactions by date for daily earnings
//     final dailyEarningsMap = <String, double>{};
//     final dailyTasksMap = <String, int>{};
//
//     for (final transaction in earningsTransactions) {
//       final dateKey = _formatDateKey(transaction.createdAt);
//       dailyEarningsMap[dateKey] =
//           (dailyEarningsMap[dateKey] ?? 0.0) + transaction.amount;
//       dailyTasksMap[dateKey] = (dailyTasksMap[dateKey] ?? 0) + 1;
//     }
//
//     // Create daily earnings list
//     final dailyEarnings = _createDailyEarningsList(
//       dailyEarningsMap,
//       dailyTasksMap,
//       period,
//       now,
//     );
//
//     // Calculate growth percentage (compare with previous period)
//     final growthPercentage =
//         _calculateGrowthPercentage(period, now, totalEarnings);
//
//     // Find highest and lowest day earnings
//     final amounts = dailyEarnings.map((e) => e.amount).toList();
//     final highestDayEarning =
//         amounts.isEmpty ? 0.0 : amounts.reduce((a, b) => a > b ? a : b);
//     final lowestDayEarning =
//         amounts.isEmpty ? 0.0 : amounts.reduce((a, b) => a < b ? a : b);
//
//     // Calculate period dates
//     final periodDates = _getPeriodDates(period, now);
//
//     final earningsData = EarningsData(
//       totalEarnings: totalEarnings,
//       totalTasks: totalTasks,
//       averageEarningPerTask: averageEarningPerTask,
//       periodStart: periodDates['start'],
//       periodEnd: periodDates['end'],
//       dailyEarnings: dailyEarnings,
//       growthPercentage: growthPercentage,
//       highestDayEarning: highestDayEarning,
//       lowestDayEarning: lowestDayEarning,
//     );
//
//     // Calculate all-time stats (simplified for now)
//     final allTimeData = EarningsData(
//       totalEarnings: totalEarnings * 1.5, // Mock all-time total
//       totalTasks: totalTasks * 2, // Mock all-time tasks
//       averageEarningPerTask: averageEarningPerTask,
//       periodStart: null,
//       periodEnd: null,
//       dailyEarnings: [],
//       growthPercentage: 0.0,
//       highestDayEarning: highestDayEarning,
//       lowestDayEarning: lowestDayEarning,
//     );
//
//     return EarningsStats(
//       period: period.value,
//       stats: earningsData,
//       allTime: allTimeData,
//     );
//   }
//
//   // Helper method to filter transactions by period
//   List<WalletTransaction> _filterTransactionsByPeriod(
//     List<WalletTransaction> transactions,
//     EarningsPeriod period,
//     DateTime now,
//   ) {
//     DateTime startDate;
//
//     switch (period) {
//       case EarningsPeriod.today:
//         startDate = DateTime(now.year, now.month, now.day);
//         break;
//       case EarningsPeriod.week:
//         startDate = now.subtract(Duration(days: 7));
//         break;
//       case EarningsPeriod.month:
//         startDate = now.subtract(Duration(days: 30));
//         break;
//       case EarningsPeriod.year:
//         startDate = now.subtract(Duration(days: 365));
//         break;
//     }
//
//     return transactions.where((transaction) {
//       return transaction.createdAt.isAfter(startDate) ||
//           transaction.createdAt.isAtSameMomentAs(startDate);
//     }).toList();
//   }
//
//   // Helper method to format date key for grouping
//   String _formatDateKey(DateTime date) {
//     return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
//   }
//
//   // Helper method to create daily earnings list
//   List<DailyEarning> _createDailyEarningsList(
//     Map<String, double> dailyEarningsMap,
//     Map<String, int> dailyTasksMap,
//     EarningsPeriod period,
//     DateTime now,
//   ) {
//     final List<DailyEarning> dailyEarnings = [];
//
//     // Determine the number of days to generate
//     int daysCount;
//     switch (period) {
//       case EarningsPeriod.today:
//         daysCount = 1;
//         break;
//       case EarningsPeriod.week:
//         daysCount = 7;
//         break;
//       case EarningsPeriod.month:
//         daysCount = 30;
//         break;
//       case EarningsPeriod.year:
//         daysCount = 365;
//         break;
//     }
//
//     // Generate daily earnings for each day in the period
//     for (int i = daysCount - 1; i >= 0; i--) {
//       final date = now.subtract(Duration(days: i));
//       final dateKey = _formatDateKey(date);
//
//       final amount = dailyEarningsMap[dateKey] ?? 0.0;
//       final tasksCount = dailyTasksMap[dateKey] ?? 0;
//
//       dailyEarnings.add(DailyEarning(
//         date: date,
//         amount: amount,
//         tasksCount: tasksCount,
//         dayName: _getDayName(date),
//       ));
//     }
//
//     return dailyEarnings;
//   }
//
//   // Helper method to calculate growth percentage
//   double _calculateGrowthPercentage(
//     EarningsPeriod period,
//     DateTime now,
//     double currentEarnings,
//   ) {
//     // Get previous period transactions
//     DateTime previousPeriodStart;
//     DateTime previousPeriodEnd;
//
//     switch (period) {
//       case EarningsPeriod.today:
//         previousPeriodStart = now.subtract(Duration(days: 2));
//         previousPeriodEnd = now.subtract(Duration(days: 1));
//         break;
//       case EarningsPeriod.week:
//         previousPeriodStart = now.subtract(Duration(days: 14));
//         previousPeriodEnd = now.subtract(Duration(days: 7));
//         break;
//       case EarningsPeriod.month:
//         previousPeriodStart = now.subtract(Duration(days: 60));
//         previousPeriodEnd = now.subtract(Duration(days: 30));
//         break;
//       case EarningsPeriod.year:
//         previousPeriodStart = now.subtract(Duration(days: 730));
//         previousPeriodEnd = now.subtract(Duration(days: 365));
//         break;
//     }
//
//     final previousTransactions = _transactions.where((transaction) {
//       return transaction.createdAt.isAfter(previousPeriodStart) &&
//           transaction.createdAt.isBefore(previousPeriodEnd) &&
//           transaction.isCredit &&
//           transaction.type != 'withdrawal';
//     }).toList();
//
//     final previousEarnings = previousTransactions.fold<double>(
//       0.0,
//       (sum, transaction) => sum + transaction.amount,
//     );
//
//     if (previousEarnings == 0) return 0.0;
//
//     return ((currentEarnings - previousEarnings) / previousEarnings) * 100;
//   }
//
//   // Helper method to get period dates
//   Map<String, String> _getPeriodDates(EarningsPeriod period, DateTime now) {
//     DateTime startDate;
//
//     switch (period) {
//       case EarningsPeriod.today:
//         startDate = DateTime(now.year, now.month, now.day);
//         break;
//       case EarningsPeriod.week:
//         startDate = now.subtract(Duration(days: 7));
//         break;
//       case EarningsPeriod.month:
//         startDate = now.subtract(Duration(days: 30));
//         break;
//       case EarningsPeriod.year:
//         startDate = now.subtract(Duration(days: 365));
//         break;
//     }
//
//     return {
//       'start': _formatDate(startDate),
//       'end': _formatDate(now),
//     };
//   }
//
//   // Helper method to format date for display
//   String _formatDate(DateTime date) {
//     return '${date.day}/${date.month}/${date.year}';
//   }
//
//   // Helper method to get day name
//   String _getDayName(DateTime date) {
//     const arabicDays = [
//       'الاثنين',
//       'الثلاثاء',
//       'الأربعاء',
//       'الخميس',
//       'الجمعة',
//       'السبت',
//       'الأحد'
//     ];
//     return arabicDays[date.weekday - 1];
//   }
//
//   // Create empty earnings stats when no data is available
//   EarningsStats _createEmptyEarningsStats(EarningsPeriod period, DateTime now) {
//     final periodDates = _getPeriodDates(period, now);
//
//     final emptyEarningsData = EarningsData(
//       totalEarnings: 0.0,
//       totalTasks: 0,
//       averageEarningPerTask: 0.0,
//       periodStart: periodDates['start'],
//       periodEnd: periodDates['end'],
//       dailyEarnings: [],
//       growthPercentage: 0.0,
//       highestDayEarning: 0.0,
//       lowestDayEarning: 0.0,
//     );
//
//     return EarningsStats(
//       period: period.value,
//       stats: emptyEarningsData,
//       allTime: emptyEarningsData,
//     );
//   }
// }







//here is from saeed from AI
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import '../models/api_response.dart';
import '../models/wallet.dart';
import 'api_service.dart';
// TODO here is from saeed from AI
class WalletService extends ChangeNotifier {
  static final WalletService _instance = WalletService._internal();
  factory WalletService() => _instance;
  WalletService._internal();

  final ApiService _apiService = ApiService();

  Wallet? _wallet;
  List<WalletTransaction> _transactions = [];
  EarningsStats? _earningsStats;
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasError = false;

  // Getters
  Wallet? get wallet => _wallet;
  List<WalletTransaction> get transactions => _transactions;
  List<WalletTransaction> get recentTransactionsShort =>
      _transactions.take(5).toList();
  EarningsStats? get earningsStats => _earningsStats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _hasError;
  bool get isEmpty => _transactions.isEmpty && !_isLoading;
  bool get hasData => _transactions.isNotEmpty;
  String get currencySymbol => 'ر.س';

  // Get wallet information
  Future<ApiResponse<WalletResponse>> getWallet() async {
    // 💡 التعديل: تأجيل تغيير حالة التحميل إلى microtask
    Future.microtask(() => _setLoading(true));

    try {
      final response = await _apiService.get<WalletResponse>(
        AppConfig.walletEndpoint,
        fromJson: (data) => WalletResponse.fromJson(data['data'] ?? data),
      );

      if (response.isSuccess && response.data != null) {
        _wallet = response.data!.wallet;
        notifyListeners();
      }

      return response;
    } catch (e) {
      return ApiResponse<WalletResponse>(
        success: false,
        message: 'فشل في جلب بيانات المحفظة: $e',
      );
    } finally {
      _setLoading(false);
    }
  }

  // Get wallet transactions
  Future<ApiResponse<WalletTransactionsResponse>> getTransactions({
    int page = 1,
    int perPage = 20,
    String? type,
    String? from,
    String? to,
    bool refresh = false,
  }) async {
    if (page == 1 || refresh) {
      // 💡 التعديل: تأجيل مسح الأخطاء لمنع notifyListeners() من العمل أثناء البناء
      Future.microtask(() => _clearError());
    }

    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'per_page': perPage.toString(),
        if (type != null) 'type': type,
        if (from != null) 'from': from,
        if (to != null) 'to': to,
      };

      debugPrint('Fetching transactions with params: $queryParams');

      final response = await _apiService.get<WalletTransactionsResponse>(
        AppConfig.transactionsEndpoint,
        queryParams: queryParams,
        fromJson: (data) =>
            WalletTransactionsResponse.fromJson(data['data'] ?? data),
      );

      if (response.isSuccess && response.data != null) {
        final newTransactions = response.data!.transactions;
        debugPrint('Received ${newTransactions.length} transactions from API');

        if (page == 1 || refresh) {
          _transactions = newTransactions;
        } else {
          _transactions.addAll(newTransactions);
        }

        // ⚠️ مهم: تم حذف _clearError() المتزامن من هنا لأنه تم نقله إلى الأعلى مع microtask
        notifyListeners();
      } else {
        _setError(response.errorMessage ?? 'فشل في جلب المعاملات المالية');
        debugPrint('API Error: ${response.errorMessage}');
      }

      return response;
    } catch (e) {
      final errorMsg = 'فشل في جلب المعاملات المالية: $e';
      _setError(errorMsg);
      debugPrint('Exception in getTransactions: $e');

      return ApiResponse<WalletTransactionsResponse>(
        success: false,
        message: errorMsg,
      );
    }
  }

  // Get earnings statistics from real transaction data
  Future<ApiResponse<EarningsStatsResponse>> getEarningsStats({
    EarningsPeriod period = EarningsPeriod.month,
  }) async {
    try {
      // First ensure we have transaction data
      if (_transactions.isEmpty) {
        // هذا الاستدعاء أصبح آمناً الآن بسبب التعديل في getTransactions
        await getTransactions(page: 1);
      }

      // Calculate real earnings statistics from transactions
      final realStats = _calculateRealEarningsStats(period);
      _earningsStats = realStats;
      notifyListeners();

      return ApiResponse<EarningsStatsResponse>(
        success: true,
        message: 'تم جلب إحصائيات الأرباح بنجاح',
        data: EarningsStatsResponse(
          success: true,
          stats: realStats,
        ),
      );

      // TODO: Uncomment this when API is ready
      /*
      final queryParams = <String, String>{
        'period': period.value,
      };

      final response = await _apiService.get<EarningsStatsResponse>(
        AppConfig.earningsStatsEndpoint,
        queryParams: queryParams,
        fromJson: (data) =>
            EarningsStatsResponse.fromJson(data['data'] ?? data),
      );

      if (response.isSuccess && response.data != null) {
        _earningsStats = response.data!.stats;
        notifyListeners();
      }

      return response;
      */
    } catch (e) {
      return ApiResponse<EarningsStatsResponse>(
        success: false,
        message: 'فشل في جلب إحصائيات الأرباح: $e',
      );
    }
  }

  // Get transactions by type
  Future<ApiResponse<WalletTransactionsResponse>> getTransactionsByType(
      WalletTransactionType type, {
        int page = 1,
        int perPage = 20,
      }) async {
    return getTransactions(
      page: page,
      perPage: perPage,
      type: type.value,
    );
  }

  // Get credit transactions
  Future<ApiResponse<WalletTransactionsResponse>> getCreditTransactions({
    int page = 1,
    int perPage = 20,
  }) async {
    return getTransactionsByType(
      WalletTransactionType.credit,
      page: page,
      perPage: perPage,
    );
  }

  // Get debit transactions
  Future<ApiResponse<WalletTransactionsResponse>> getDebitTransactions({
    int page = 1,
    int perPage = 20,
  }) async {
    return getTransactionsByType(
      WalletTransactionType.debit,
      page: page,
      perPage: perPage,
    );
  }

  // Get commission transactions
  Future<ApiResponse<WalletTransactionsResponse>> getCommissionTransactions({
    int page = 1,
    int perPage = 20,
  }) async {
    return getTransactionsByType(
      WalletTransactionType.commission,
      page: page,
      perPage: perPage,
    );
  }

  // Get earnings for different periods
  Future<ApiResponse<EarningsStatsResponse>> getTodayEarnings() async {
    return getEarningsStats(period: EarningsPeriod.today);
  }

  Future<ApiResponse<EarningsStatsResponse>> getWeekEarnings() async {
    return getEarningsStats(period: EarningsPeriod.week);
  }

  Future<ApiResponse<EarningsStatsResponse>> getMonthEarnings() async {
    return getEarningsStats(period: EarningsPeriod.month);
  }

  Future<ApiResponse<EarningsStatsResponse>> getYearEarnings() async {
    return getEarningsStats(period: EarningsPeriod.year);
  }

  // Refresh wallet data
  Future<void> refreshWallet() async {
    await getWallet();
  }

  // Refresh transactions
  Future<void> refreshTransactions() async {
    await getTransactions(page: 1);
  }

  // Refresh earnings stats
  Future<void> refreshEarningsStats() async {
    await getEarningsStats();
  }

  // Refresh all wallet data
  Future<void> refreshAll() async {
    await Future.wait([
      refreshWallet(),
      refreshTransactions(),
      refreshEarningsStats(),
    ]);
  }

  // Clear wallet data
  void clearWalletData() {
    _wallet = null;
    _transactions.clear();
    _earningsStats = null;
    notifyListeners();
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _hasError = true;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    _hasError = false;
    notifyListeners();
  }

  // Helper methods
  double get currentBalance => _wallet?.balance ?? 0.0;
  double get totalEarnings => _wallet?.totalEarnings ?? 0.0;
  double get pendingAmount => _wallet?.pendingAmount ?? 0.0;
  String get currency => _wallet?.currency ?? 'SAR';

  // Get transaction by ID
  WalletTransaction? getTransactionById(int id) {
    try {
      return _transactions.firstWhere((transaction) => transaction.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get transactions by type from local list
  List<WalletTransaction> getLocalTransactionsByType(TransactionType type) {
    return _transactions
        .where((transaction) => transaction.type == type.value)
        .toList();
  }

  // Get credit transactions from local list
  List<WalletTransaction> get localCreditTransactions {
    return _transactions.where((transaction) => transaction.isCredit).toList();
  }

  // Get debit transactions from local list
  List<WalletTransaction> get localDebitTransactions {
    return _transactions.where((transaction) => transaction.isDebit).toList();
  }

  // Calculate total for transaction type
  double getTotalForTransactionType(TransactionType type) {
    return _transactions
        .where((transaction) => transaction.type == type.value)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  // Get recent transactions (last 10)
  List<WalletTransaction> get recentTransactions {
    final sortedTransactions = List<WalletTransaction>.from(_transactions);
    sortedTransactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sortedTransactions.take(10).toList();
  }

  // Check if has sufficient balance
  bool hasSufficientBalance(double amount) {
    return currentBalance >= amount;
  }

  // Format currency
  String formatCurrency(double amount) {
    return '${amount.toStringAsFixed(2)} $currency';
  }

  // Get commission display text
  String get commissionDisplayText {
    if (_wallet?.commission == null) return '';
    return _wallet!.commission.displayValue;
  }

  // Calculate real earnings statistics from transaction data
  EarningsStats _calculateRealEarningsStats(EarningsPeriod period) {
    final now = DateTime.now();

    // If no transactions available, return empty stats
    if (_transactions.isEmpty) {
      return _createEmptyEarningsStats(period, now);
    }

    // Filter transactions based on period
    final filteredTransactions =
    _filterTransactionsByPeriod(_transactions, period, now);

    // Get only credit transactions (earnings) - exclude withdrawals
    final earningsTransactions = filteredTransactions
        .where((t) => t.isCredit && t.type != 'withdrawal')
        .toList();

    // If no earnings transactions in this period, return empty stats
    if (earningsTransactions.isEmpty) {
      return _createEmptyEarningsStats(period, now);
    }

    // Calculate total earnings
    final totalEarnings = earningsTransactions.fold<double>(
      0.0,
          (sum, transaction) => sum + transaction.amount,
    );

    // Calculate total tasks (assuming each earning transaction represents a task)
    final totalTasks = earningsTransactions.length;

    // Calculate average earning per task
    final averageEarningPerTask =
    totalTasks > 0 ? totalEarnings / totalTasks : 0.0;

    // Group transactions by date for daily earnings
    final dailyEarningsMap = <String, double>{};
    final dailyTasksMap = <String, int>{};

    for (final transaction in earningsTransactions) {
      final dateKey = _formatDateKey(transaction.createdAt);
      dailyEarningsMap[dateKey] =
          (dailyEarningsMap[dateKey] ?? 0.0) + transaction.amount;
      dailyTasksMap[dateKey] = (dailyTasksMap[dateKey] ?? 0) + 1;
    }

    // Create daily earnings list
    final dailyEarnings = _createDailyEarningsList(
      dailyEarningsMap,
      dailyTasksMap,
      period,
      now,
    );

    // Calculate growth percentage (compare with previous period)
    final growthPercentage =
    _calculateGrowthPercentage(period, now, totalEarnings);

    // Find highest and lowest day earnings
    final amounts = dailyEarnings.map((e) => e.amount).toList();
    final highestDayEarning =
    amounts.isEmpty ? 0.0 : amounts.reduce((a, b) => a > b ? a : b);
    final lowestDayEarning =
    amounts.isEmpty ? 0.0 : amounts.reduce((a, b) => a < b ? a : b);

    // Calculate period dates
    final periodDates = _getPeriodDates(period, now);

    final earningsData = EarningsData(
      totalEarnings: totalEarnings,
      totalTasks: totalTasks,
      averageEarningPerTask: averageEarningPerTask,
      periodStart: periodDates['start'],
      periodEnd: periodDates['end'],
      dailyEarnings: dailyEarnings,
      growthPercentage: growthPercentage,
      highestDayEarning: highestDayEarning,
      lowestDayEarning: lowestDayEarning,
    );

    // Calculate all-time stats (simplified for now)
    final allTimeData = EarningsData(
      totalEarnings: totalEarnings * 1.5, // Mock all-time total
      totalTasks: totalTasks * 2, // Mock all-time tasks
      averageEarningPerTask: averageEarningPerTask,
      periodStart: null,
      periodEnd: null,
      dailyEarnings: [],
      growthPercentage: 0.0,
      highestDayEarning: highestDayEarning,
      lowestDayEarning: lowestDayEarning,
    );

    return EarningsStats(
      period: period.value,
      stats: earningsData,
      allTime: allTimeData,
    );
  }

  // Helper method to filter transactions by period
  List<WalletTransaction> _filterTransactionsByPeriod(
      List<WalletTransaction> transactions,
      EarningsPeriod period,
      DateTime now,
      ) {
    DateTime startDate;

    switch (period) {
      case EarningsPeriod.today:
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case EarningsPeriod.week:
        startDate = now.subtract(Duration(days: 7));
        break;
      case EarningsPeriod.month:
        startDate = now.subtract(Duration(days: 30));
        break;
      case EarningsPeriod.year:
        startDate = now.subtract(Duration(days: 365));
        break;
    }

    return transactions.where((transaction) {
      return transaction.createdAt.isAfter(startDate) ||
          transaction.createdAt.isAtSameMomentAs(startDate);
    }).toList();
  }

  // Helper method to format date key for grouping
  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Helper method to create daily earnings list
  List<DailyEarning> _createDailyEarningsList(
      Map<String, double> dailyEarningsMap,
      Map<String, int> dailyTasksMap,
      EarningsPeriod period,
      DateTime now,
      ) {
    final List<DailyEarning> dailyEarnings = [];

    // Determine the number of days to generate
    int daysCount;
    switch (period) {
      case EarningsPeriod.today:
        daysCount = 1;
        break;
      case EarningsPeriod.week:
        daysCount = 7;
        break;
      case EarningsPeriod.month:
        daysCount = 30;
        break;
      case EarningsPeriod.year:
        daysCount = 365;
        break;
    }

    // Generate daily earnings for each day in the period
    for (int i = daysCount - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateKey = _formatDateKey(date);

      final amount = dailyEarningsMap[dateKey] ?? 0.0;
      final tasksCount = dailyTasksMap[dateKey] ?? 0;

      dailyEarnings.add(DailyEarning(
        date: date,
        amount: amount,
        tasksCount: tasksCount,
        dayName: _getDayName(date),
      ));
    }

    return dailyEarnings;
  }

  // Helper method to calculate growth percentage
  double _calculateGrowthPercentage(
      EarningsPeriod period,
      DateTime now,
      double currentEarnings,
      ) {
    // Get previous period transactions
    DateTime previousPeriodStart;
    DateTime previousPeriodEnd;

    switch (period) {
      case EarningsPeriod.today:
        previousPeriodStart = now.subtract(Duration(days: 2));
        previousPeriodEnd = now.subtract(Duration(days: 1));
        break;
      case EarningsPeriod.week:
        previousPeriodStart = now.subtract(Duration(days: 14));
        previousPeriodEnd = now.subtract(Duration(days: 7));
        break;
      case EarningsPeriod.month:
        previousPeriodStart = now.subtract(Duration(days: 60));
        previousPeriodEnd = now.subtract(Duration(days: 30));
        break;
      case EarningsPeriod.year:
        previousPeriodStart = now.subtract(Duration(days: 730));
        previousPeriodEnd = now.subtract(Duration(days: 365));
        break;
    }

    final previousTransactions = _transactions.where((transaction) {
      return transaction.createdAt.isAfter(previousPeriodStart) &&
          transaction.createdAt.isBefore(previousPeriodEnd) &&
          transaction.isCredit &&
          transaction.type != 'withdrawal';
    }).toList();

    final previousEarnings = previousTransactions.fold<double>(
      0.0,
          (sum, transaction) => sum + transaction.amount,
    );

    if (previousEarnings == 0) return 0.0;

    return ((currentEarnings - previousEarnings) / previousEarnings) * 100;
  }

  // Helper method to get period dates
  Map<String, String> _getPeriodDates(EarningsPeriod period, DateTime now) {
    DateTime startDate;

    switch (period) {
      case EarningsPeriod.today:
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case EarningsPeriod.week:
        startDate = now.subtract(Duration(days: 7));
        break;
      case EarningsPeriod.month:
        startDate = now.subtract(Duration(days: 30));
        break;
      case EarningsPeriod.year:
        startDate = now.subtract(Duration(days: 365));
        break;
    }

    return {
      'start': _formatDate(startDate),
      'end': _formatDate(now),
    };
  }

  // Helper method to format date for display
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Helper method to get day name
  String _getDayName(DateTime date) {
    const arabicDays = [
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد'
    ];
    return arabicDays[date.weekday - 1];
  }

  // Create empty earnings stats when no data is available
  EarningsStats _createEmptyEarningsStats(EarningsPeriod period, DateTime now) {
    final periodDates = _getPeriodDates(period, now);

    final emptyEarningsData = EarningsData(
      totalEarnings: 0.0,
      totalTasks: 0,
      averageEarningPerTask: 0.0,
      periodStart: periodDates['start'],
      periodEnd: periodDates['end'],
      dailyEarnings: [],
      growthPercentage: 0.0,
      highestDayEarning: 0.0,
      lowestDayEarning: 0.0,
    );

    return EarningsStats(
      period: period.value,
      stats: emptyEarningsData,
      allTime: emptyEarningsData,
    );
  }
}
