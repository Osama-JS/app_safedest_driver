import 'package:get/get.dart';
import '../Helpers/WalletHelper.dart';
import '../models/wallet.dart';
import '../models/api_response.dart';

class WalletController extends GetxController {
  final WalletHelper _walletHelper = WalletHelper();

  // Reactive state
  final Rxn<Wallet> wallet = Rxn<Wallet>();
  final RxList<WalletTransaction> transactions = <WalletTransaction>[].obs;
  final RxList<WithdrawalRequest> withdrawalRequests = <WithdrawalRequest>[].obs;
  final Rxn<EarningsStats> earningsStats = Rxn<EarningsStats>();

  final RxBool isLoading = false.obs;
  final RxBool isWithdrawLoading = false.obs;
  final RxString errorMessage = "".obs;

  // Balance visibility toggle
  final RxBool isBalanceVisible = false.obs;
  void toggleBalanceVisibility() => isBalanceVisible.toggle();

  // Added getters requested by user
  double get currentBalance => wallet.value?.balance ?? 0.0;
  String get currency => wallet.value?.currency ?? 'SAR';
  double get totalEarnings => wallet.value?.totalEarnings ?? 0.0;
  double get pendingAmount => wallet.value?.pendingAmount ?? 0.0;
  double get pendingWithdrawal => wallet.value?.pendingWithdrawal ?? 0.0;

  @override
  void onInit() {
    super.onInit();
    // fetchAllData();
  }

  // Fetch wallet info
  Future<void> fetchWallet() async {
    isLoading.value = true;
    try {
      final response = await _walletHelper.getWallet();
      if (response.isSuccess && response.data != null) {
        wallet.value = response.data!.wallet;
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch transactions
  Future<void> fetchTransactions({int page = 1, int perPage = 20, bool refresh = false}) async {
    if (page == 1) isLoading.value = true;
    try {
      final response = await _walletHelper.getTransactions(page: page, perPage: perPage);
      if (response.isSuccess && response.data != null) {
        if (page == 1 || refresh) {
          transactions.assignAll(response.data!.transactions);
        } else {
          transactions.addAll(response.data!.transactions);
        }
      }
    } finally {
      if (page == 1) isLoading.value = false;
    }
  }

  // Fetch earnings stats
  Future<void> fetchEarningsStats({String period = 'month'}) async {
    final response = await _walletHelper.getEarningsStats(period: period);
    if (response.isSuccess && response.data != null) {
      earningsStats.value = response.data!.stats;
    }
  }

  // Request withdrawal
  Future<bool> requestWithdrawal(double amount, {String? notes}) async {
    isWithdrawLoading.value = true;
    try {
      final response = await _walletHelper.requestWithdrawal(
        amount: amount,
        notes: notes,
      );
      if (response.isSuccess) {
        await refreshAll();
        return true;
      } else {
        errorMessage.value = response.message ?? "حدث خطأ أثناء إرسال طلب السحب";
        return false;
      }
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isWithdrawLoading.value = false;
    }
  }

  // Fetch withdrawal history
  Future<void> fetchWithdrawalHistory({int page = 1, bool refresh = false}) async {
    if (page == 1) isLoading.value = true;
    try {
      final response = await _walletHelper.getWithdrawalHistory(page: page);
      if (response.isSuccess && response.data != null) {
        if (page == 1 || refresh) {
          withdrawalRequests.assignAll(response.data!.withdrawals);
        } else {
          withdrawalRequests.addAll(response.data!.withdrawals);
        }
      }
    } finally {
      if (page == 1) isLoading.value = false;
    }
  }

  // Refresh all
  Future<void> refreshAll() async {
    await Future.wait([
      fetchWallet(),
      fetchTransactions(refresh: true),
      fetchEarningsStats(),
      fetchWithdrawalHistory(refresh: true),
    ]);
  }

  // Reset
  void reset() {
    wallet.value = null;
    transactions.clear();
    withdrawalRequests.clear();
    earningsStats.value = null;
  }
}
