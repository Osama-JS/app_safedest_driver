import '../services/api_service.dart';
import '../config/app_config.dart';
import '../models/api_response.dart';
import '../models/wallet.dart';

class WalletHelper {
  final ApiService _apiService = ApiService();

  // Get wallet information
  Future<ApiResponse<WalletResponse>> getWallet() async {
    return await _apiService.get<WalletResponse>(
      AppConfig.walletEndpoint,
      fromJson: (data) => WalletResponse.fromJson(data['data'] ?? data),
    );
  }

  // Get transactions
  Future<ApiResponse<WalletTransactionsResponse>> getTransactions({
    int page = 1,
    int perPage = 20,
    String? type,
    String? from,
    String? to,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'per_page': perPage.toString(),
      if (type != null) 'type': type,
      if (from != null) 'from': from,
      if (to != null) 'to': to,
    };

    return await _apiService.get<WalletTransactionsResponse>(
      AppConfig.transactionsEndpoint,
      queryParams: queryParams,
      fromJson: (data) => WalletTransactionsResponse.fromJson(data['data'] ?? data),
    );
  }

  // Get earnings statistics
  Future<ApiResponse<EarningsStatsResponse>> getEarningsStats({
    String? period,
  }) async {
    final queryParams = <String, String>{
      if (period != null) 'period': period,
    };

    return await _apiService.get<EarningsStatsResponse>(
      AppConfig.earningsStatsEndpoint,
      queryParams: queryParams,
      fromJson: (data) => EarningsStatsResponse.fromJson(data['data'] ?? data),
    );
  }

  // Request withdrawal
  Future<ApiResponse<Map<String, dynamic>>> requestWithdrawal({
    required double amount,
    String? paymentMethod,
    String? notes,
  }) async {
    return await _apiService.post<Map<String, dynamic>>(
      AppConfig.withdrawEndpoint,
      body: {
        'amount': amount,
        if (paymentMethod != null) 'payment_method': paymentMethod,
        if (notes != null) 'notes': notes,
      },
      fromJson: (data) => data['data'] ?? data,
    );
  }

  // Get withdrawal history
  Future<ApiResponse<WithdrawalHistoryResponse>> getWithdrawalHistory({
    int page = 1,
    int perPage = 20,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'per_page': perPage.toString(),
    };

    return await _apiService.get<WithdrawalHistoryResponse>(
      AppConfig.withdrawalHistoryEndpoint,
      queryParams: queryParams,
      fromJson: (data) => WithdrawalHistoryResponse.fromJson(data['data'] ?? data),
    );
  }
}

class WithdrawalHistoryResponse {
  final List<WithdrawalRequest> withdrawals;
  final int currentPage;
  final int lastPage;
  final int total;

  WithdrawalHistoryResponse({
    required this.withdrawals,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  factory WithdrawalHistoryResponse.fromJson(Map<String, dynamic> json) {
    return WithdrawalHistoryResponse(
      withdrawals: json['withdrawals'] != null && json['withdrawals'] is List
          ? (json['withdrawals'] as List)
              .map((item) => WithdrawalRequest.fromJson(item))
              .toList()
          : [],
      currentPage: (json['pagination']?['current_page'] as int?) ?? 1,
      lastPage: (json['pagination']?['last_page'] as int?) ?? 1,
      total: (json['pagination']?['total'] as int?) ?? 0,
    );
  }
}
