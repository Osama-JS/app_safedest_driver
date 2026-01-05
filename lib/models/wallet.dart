class Wallet {
  final double balance;
  final double debtCeiling;
  final double pendingAmount;
  final double totalEarnings;
  final String currency;
  final Commission commission;

  Wallet({
    required this.balance,
    required this.debtCeiling,
    required this.pendingAmount,
    required this.totalEarnings,
    required this.currency,
    required this.commission,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      balance: _parseToDouble(json['balance']) ?? 0.0,
      debtCeiling: _parseToDouble(json['debt_ceiling']) ?? 0.0,
      pendingAmount: _parseToDouble(json['pending_amount']) ?? 0.0,
      totalEarnings: _parseToDouble(json['total_earnings']) ?? 0.0,
      currency: _parseToString(json['currency']) ?? 'SAR',
      commission: json['commission'] != null &&
              json['commission'] is Map<String, dynamic>
          ? Commission.fromJson(json['commission'])
          : Commission(type: 'percentage', value: 0.0),
    );
  }

  // Helper methods for safe parsing
  static double? _parseToDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static String? _parseToString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value.isEmpty ? null : value;
    if (value is bool) return value.toString();
    return value.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'balance': balance,
      'debt_ceiling': debtCeiling,
      'pending_amount': pendingAmount,
      'total_earnings': totalEarnings,
      'currency': currency,
      'commission': commission.toJson(),
    };
  }

  @override
  String toString() {
    return 'Wallet(balance: $balance, currency: $currency, totalEarnings: $totalEarnings)';
  }
}

class Commission {
  final String type;
  final double value;

  Commission({
    required this.type,
    required this.value,
  });

  factory Commission.fromJson(Map<String, dynamic> json) {
    return Commission(
      type: Wallet._parseToString(json['type']) ?? 'percentage',
      value: Wallet._parseToDouble(json['value']) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'value': value,
    };
  }

  String get displayValue {
    if (type == 'percentage') {
      return '${value.toStringAsFixed(1)}%';
    } else {
      return '${value.toStringAsFixed(2)} SAR';
    }
  }
}

class WalletTransaction {
  final int id;
  final double amount;
  final String type;
  final String description;
  final String status;
  final DateTime createdAt;
  final DateTime? maturityTime;
  final String? referenceId;
  final String? image; // للصور أو ملفات PDF
  final int? taskId;

  WalletTransaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.description,
    required this.status,
    required this.createdAt,
    this.maturityTime,
    this.referenceId,
    this.image,
    this.taskId,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: _parseToInt(json['id']) ?? 0,
      amount: Wallet._parseToDouble(json['amount']) ?? 0.0,
      type: Wallet._parseToString(json['type']) ?? 'credit',
      description: Wallet._parseToString(json['description']) ?? '',
      status: Wallet._parseToString(json['status']) ?? 'completed',
      createdAt: _parseToDateTime(json['created_at']) ?? DateTime.now(),
      maturityTime: _parseToDateTime(json['maturity_time']),
      referenceId: Wallet._parseToString(json['reference_id']),
      image: Wallet._parseToString(json['image']),
      taskId: _parseToInt(json['task_id']),
    );
  }

  // Helper methods for safe parsing
  static int? _parseToInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static DateTime? _parseToDateTime(dynamic value) {
    if (value == null) return null;
    if (value is String && value.isNotEmpty) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'type': type,
      'description': description,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'maturity_time': maturityTime?.toIso8601String(),
      'reference_id': referenceId,
      'task_id': taskId,
    };
  }

  bool get isCredit =>
      type == 'credit' || type == 'commission' || type == 'deposit';
  bool get isDebit => type == 'debit' || type == 'withdrawal';

  @override
  String toString() {
    return 'WalletTransaction(id: $id, amount: $amount, type: $type, status: $status)';
  }
}

class EarningsStats {
  final String period;
  final EarningsData stats;
  final EarningsData allTime;

  EarningsStats({
    required this.period,
    required this.stats,
    required this.allTime,
  });

  double get totalEarnings => stats.totalEarnings;

  factory EarningsStats.fromJson(Map<String, dynamic> json) {
    return EarningsStats(
      period: json['period'] ?? 'month',
      stats: EarningsData.fromJson(json['stats'] ?? {}),
      allTime: EarningsData.fromJson(json['all_time'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'period': period,
      'stats': stats.toJson(),
      'all_time': allTime.toJson(),
    };
  }
}

class EarningsData {
  final double totalEarnings;
  final int totalTasks;
  final double averageEarningPerTask;
  final String? periodStart;
  final String? periodEnd;
  final List<DailyEarning> dailyEarnings;
  final double growthPercentage;
  final double highestDayEarning;
  final double lowestDayEarning;

  EarningsData({
    required this.totalEarnings,
    required this.totalTasks,
    required this.averageEarningPerTask,
    this.periodStart,
    this.periodEnd,
    this.dailyEarnings = const [],
    this.growthPercentage = 0.0,
    this.highestDayEarning = 0.0,
    this.lowestDayEarning = 0.0,
  });

  factory EarningsData.fromJson(Map<String, dynamic> json) {
    return EarningsData(
      totalEarnings: Wallet._parseToDouble(json['total_earnings']) ?? 0.0,
      totalTasks: WalletTransaction._parseToInt(json['total_tasks']) ?? 0,
      averageEarningPerTask:
          Wallet._parseToDouble(json['average_earning_per_task']) ?? 0.0,
      periodStart: Wallet._parseToString(json['period_start']),
      periodEnd: Wallet._parseToString(json['period_end']),
      dailyEarnings:
          json['daily_earnings'] != null && json['daily_earnings'] is List
              ? (json['daily_earnings'] as List)
                  .whereType<Map<String, dynamic>>()
                  .map((item) => DailyEarning.fromJson(item))
                  .toList()
              : [],
      growthPercentage: Wallet._parseToDouble(json['growth_percentage']) ?? 0.0,
      highestDayEarning:
          Wallet._parseToDouble(json['highest_day_earning']) ?? 0.0,
      lowestDayEarning:
          Wallet._parseToDouble(json['lowest_day_earning']) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_earnings': totalEarnings,
      'total_tasks': totalTasks,
      'average_earning_per_task': averageEarningPerTask,
      'period_start': periodStart,
      'period_end': periodEnd,
      'daily_earnings': dailyEarnings.map((e) => e.toJson()).toList(),
      'growth_percentage': growthPercentage,
      'highest_day_earning': highestDayEarning,
      'lowest_day_earning': lowestDayEarning,
    };
  }
}

// Daily Earning Model for Chart Data
class DailyEarning {
  final DateTime date;
  final double amount;
  final int tasksCount;
  final String dayName;

  DailyEarning({
    required this.date,
    required this.amount,
    required this.tasksCount,
    required this.dayName,
  });

  factory DailyEarning.fromJson(Map<String, dynamic> json) {
    return DailyEarning(
      date: WalletTransaction._parseToDateTime(json['date']) ?? DateTime.now(),
      amount: Wallet._parseToDouble(json['amount']) ?? 0.0,
      tasksCount: WalletTransaction._parseToInt(json['tasks_count']) ?? 0,
      dayName: Wallet._parseToString(json['day_name']) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'amount': amount,
      'tasks_count': tasksCount,
      'day_name': dayName,
    };
  }

  // Helper method to get short day name (e.g., "الأحد", "الاثنين")
  String get shortDayName {
    final weekdays = [
      'الأحد',
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت'
    ];
    return weekdays[date.weekday % 7];
  }

  // Helper method to get day number
  String get dayNumber => date.day.toString();
}

// Transaction Type Enum
enum TransactionType {
  credit,
  debit,
  commission,
  withdrawal,
  deposit,
}

extension TransactionTypeExtension on TransactionType {
  String get value {
    switch (this) {
      case TransactionType.credit:
        return 'credit';
      case TransactionType.debit:
        return 'debit';
      case TransactionType.commission:
        return 'commission';
      case TransactionType.withdrawal:
        return 'withdrawal';
      case TransactionType.deposit:
        return 'deposit';
    }
  }

  String get displayName {
    switch (this) {
      case TransactionType.credit:
        return 'إيداع';
      case TransactionType.debit:
        return 'سحب';
      case TransactionType.commission:
        return 'عمولة';
      case TransactionType.withdrawal:
        return 'سحب نقدي';
      case TransactionType.deposit:
        return 'إيداع نقدي';
    }
  }

  static TransactionType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'credit':
        return TransactionType.credit;
      case 'debit':
        return TransactionType.debit;
      case 'commission':
        return TransactionType.commission;
      case 'withdrawal':
        return TransactionType.withdrawal;
      case 'deposit':
        return TransactionType.deposit;
      default:
        return TransactionType.credit;
    }
  }
}

// Earnings Period Enum
enum EarningsPeriod {
  today,
  week,
  month,
  year,
}

extension EarningsPeriodExtension on EarningsPeriod {
  String get value {
    switch (this) {
      case EarningsPeriod.today:
        return 'today';
      case EarningsPeriod.week:
        return 'week';
      case EarningsPeriod.month:
        return 'month';
      case EarningsPeriod.year:
        return 'year';
    }
  }

  String get displayName {
    switch (this) {
      case EarningsPeriod.today:
        return 'اليوم';
      case EarningsPeriod.week:
        return 'هذا الأسبوع';
      case EarningsPeriod.month:
        return 'هذا الشهر';
      case EarningsPeriod.year:
        return 'هذا العام';
    }
  }

  static EarningsPeriod fromString(String period) {
    switch (period.toLowerCase()) {
      case 'today':
        return EarningsPeriod.today;
      case 'week':
        return EarningsPeriod.week;
      case 'month':
        return EarningsPeriod.month;
      case 'year':
        return EarningsPeriod.year;
      default:
        return EarningsPeriod.month;
    }
  }
}

// Response Models
class WalletDataResponse {
  final Wallet wallet;
  final String? message;

  WalletDataResponse({
    required this.wallet,
    this.message,
  });

  factory WalletDataResponse.fromJson(Map<String, dynamic> json) {
    return WalletDataResponse(
      wallet: Wallet.fromJson(json['wallet'] ?? json),
      message: Wallet._parseToString(json['message']),
    );
  }
}

class WalletTransactionsResponse {
  final List<WalletTransaction> transactions;
  final int currentPage;
  final int lastPage;
  final int total;
  final String? message;

  WalletTransactionsResponse({
    required this.transactions,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    this.message,
  });

  factory WalletTransactionsResponse.fromJson(Map<String, dynamic> json) {
    return WalletTransactionsResponse(
      transactions: json['data'] != null && json['data'] is List
          ? (json['data'] as List)
              .whereType<Map<String, dynamic>>()
              .map((item) => WalletTransaction.fromJson(item))
              .toList()
          : json['transactions'] != null && json['transactions'] is List
              ? (json['transactions'] as List)
                  .whereType<Map<String, dynamic>>()
                  .map((item) => WalletTransaction.fromJson(item))
                  .toList()
              : [],
      currentPage: WalletTransaction._parseToInt(json['current_page']) ?? 1,
      lastPage: WalletTransaction._parseToInt(json['last_page']) ?? 1,
      total: WalletTransaction._parseToInt(json['total']) ?? 0,
      message: Wallet._parseToString(json['message']),
    );
  }
}

class WalletEarningsStatsResponse {
  final EarningsStats stats;
  final String? message;

  WalletEarningsStatsResponse({
    required this.stats,
    this.message,
  });

  factory WalletEarningsStatsResponse.fromJson(Map<String, dynamic> json) {
    return WalletEarningsStatsResponse(
      stats: EarningsStats.fromJson(json['stats'] ?? json),
      message: Wallet._parseToString(json['message']),
    );
  }
}

// Enums and Extensions
enum WalletTransactionType {
  credit,
  debit,
  commission,
  withdrawal,
  deposit;

  String get value {
    switch (this) {
      case WalletTransactionType.credit:
        return 'credit';
      case WalletTransactionType.debit:
        return 'debit';
      case WalletTransactionType.commission:
        return 'commission';
      case WalletTransactionType.withdrawal:
        return 'withdrawal';
      case WalletTransactionType.deposit:
        return 'deposit';
    }
  }

  String get displayName {
    switch (this) {
      case WalletTransactionType.credit:
        return 'إيداع';
      case WalletTransactionType.debit:
        return 'سحب';
      case WalletTransactionType.commission:
        return 'عمولة';
      case WalletTransactionType.withdrawal:
        return 'سحب نقدي';
      case WalletTransactionType.deposit:
        return 'إيداع';
    }
  }

  static WalletTransactionType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'credit':
        return WalletTransactionType.credit;
      case 'debit':
        return WalletTransactionType.debit;
      case 'commission':
        return WalletTransactionType.commission;
      case 'withdrawal':
        return WalletTransactionType.withdrawal;
      case 'deposit':
        return WalletTransactionType.deposit;
      default:
        return WalletTransactionType.credit;
    }
  }
}

extension WalletTransactionExtension on WalletTransaction {
  bool get isCredit =>
      type.toLowerCase() == 'credit' || type.toLowerCase() == 'deposit';
  bool get isDebit =>
      type.toLowerCase() == 'debit' || type.toLowerCase() == 'withdrawal';
}
