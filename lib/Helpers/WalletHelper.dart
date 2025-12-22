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
}
