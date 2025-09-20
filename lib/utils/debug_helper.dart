import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/task_service.dart';
import '../services/wallet_service.dart';
import '../config/app_config.dart';

class DebugHelper {
  static const String _tag = 'SafeDestsDebug';

  // Debug logging with consistent format
  static void log(String message, {String? tag}) {
    if (kDebugMode) {
      debugPrint('[$_tag${tag != null ? ':$tag' : ''}] $message');
    }
  }

  // Log API requests
  static void logApiRequest(String method, String endpoint, {Map<String, dynamic>? params}) {
    if (kDebugMode) {
      final fullUrl = AppConfig.getApiUrl(endpoint);
      log('API Request: $method $fullUrl', tag: 'API');
      if (params != null && params.isNotEmpty) {
        log('Parameters: $params', tag: 'API');
      }
    }
  }

  // Log API responses
  static void logApiResponse(String endpoint, bool success, {String? message, dynamic data}) {
    if (kDebugMode) {
      log('API Response: $endpoint - ${success ? 'SUCCESS' : 'ERROR'}', tag: 'API');
      if (message != null) {
        log('Message: $message', tag: 'API');
      }
      if (data != null && kDebugMode) {
        log('Data: $data', tag: 'API');
      }
    }
  }

  // Log service states
  static void logServiceState(String serviceName, {
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
    int? dataCount,
  }) {
    if (kDebugMode) {
      log('Service State: $serviceName', tag: 'SERVICE');
      if (isLoading != null) log('  Loading: $isLoading', tag: 'SERVICE');
      if (hasError != null) log('  Has Error: $hasError', tag: 'SERVICE');
      if (errorMessage != null) log('  Error: $errorMessage', tag: 'SERVICE');
      if (dataCount != null) log('  Data Count: $dataCount', tag: 'SERVICE');
    }
  }

  // Comprehensive system check
  static Future<Map<String, dynamic>> performSystemCheck(BuildContext context) async {
    log('Starting comprehensive system check...', tag: 'SYSTEM_CHECK');
    
    final results = <String, dynamic>{};
    
    try {
      // Check authentication
      final authService = AuthService();
      final isAuthenticated = authService.isAuthenticated;
      final currentDriver = authService.currentDriver;
      
      results['authentication'] = {
        'isAuthenticated': isAuthenticated,
        'hasDriverData': currentDriver != null,
        'driverName': currentDriver?.name,
        'driverStatus': currentDriver?.status,
        'driverOnline': currentDriver?.online,
        'driverFree': currentDriver?.free,
      };
      
      log('Auth Check: Authenticated=$isAuthenticated, Driver=${currentDriver?.name}', tag: 'SYSTEM_CHECK');
      
      // Check task service
      final taskService = TaskService();
      results['tasks'] = {
        'isLoading': taskService.isLoading,
        'hasError': taskService.hasError,
        'errorMessage': taskService.errorMessage,
        'taskCount': taskService.tasks.length,
        'hasCurrentTask': taskService.hasActiveTask,
        'activeTasks': taskService.activeTasks.length,
      };
      
      log('Task Check: Count=${taskService.tasks.length}, Error=${taskService.hasError}', tag: 'SYSTEM_CHECK');
      
      // Check wallet service
      final walletService = WalletService();
      results['wallet'] = {
        'isLoading': walletService.isLoading,
        'hasError': walletService.hasError,
        'errorMessage': walletService.errorMessage,
        'hasWalletData': walletService.wallet != null,
        'transactionCount': walletService.transactions.length,
        'balance': walletService.wallet?.balance,
      };
      
      log('Wallet Check: Transactions=${walletService.transactions.length}, Error=${walletService.hasError}', tag: 'SYSTEM_CHECK');
      
      // Check network connectivity (basic)
      results['network'] = {
        'baseUrl': AppConfig.baseUrl,
        'tasksEndpoint': AppConfig.tasksEndpoint,
        'walletEndpoint': AppConfig.walletEndpoint,
      };
      
      results['timestamp'] = DateTime.now().toIso8601String();
      results['success'] = true;
      
    } catch (e) {
      log('System check failed: $e', tag: 'SYSTEM_CHECK');
      results['success'] = false;
      results['error'] = e.toString();
    }
    
    log('System check completed', tag: 'SYSTEM_CHECK');
    return results;
  }

  // Show debug dialog
  static void showDebugDialog(BuildContext context) async {
    final results = await performSystemCheck(context);
    
    if (!context.mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تشخيص النظام'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDebugSection('المصادقة', results['authentication']),
              const SizedBox(height: 16),
              _buildDebugSection('المهام', results['tasks']),
              const SizedBox(height: 16),
              _buildDebugSection('المحفظة', results['wallet']),
              const SizedBox(height: 16),
              _buildDebugSection('الشبكة', results['network']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إغلاق'),
          ),
          TextButton(
            onPressed: () {
              // Copy to clipboard or share
              final debugText = _formatDebugResults(results);
              log('Debug Results:\n$debugText', tag: 'DEBUG_DIALOG');
            },
            child: const Text('نسخ للوحة'),
          ),
        ],
      ),
    );
  }

  static Widget _buildDebugSection(String title, Map<String, dynamic>? data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        if (data != null)
          ...data.entries.map((entry) => Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 4),
            child: Text(
              '${entry.key}: ${entry.value}',
              style: const TextStyle(fontSize: 14),
            ),
          ))
        else
          const Text('لا توجد بيانات'),
      ],
    );
  }

  static String _formatDebugResults(Map<String, dynamic> results) {
    final buffer = StringBuffer();
    buffer.writeln('=== SafeDests Debug Report ===');
    buffer.writeln('Timestamp: ${results['timestamp']}');
    buffer.writeln('Success: ${results['success']}');
    
    if (results['error'] != null) {
      buffer.writeln('Error: ${results['error']}');
    }
    
    buffer.writeln('\n--- Authentication ---');
    final auth = results['authentication'] as Map<String, dynamic>?;
    if (auth != null) {
      auth.forEach((key, value) {
        buffer.writeln('$key: $value');
      });
    }
    
    buffer.writeln('\n--- Tasks ---');
    final tasks = results['tasks'] as Map<String, dynamic>?;
    if (tasks != null) {
      tasks.forEach((key, value) {
        buffer.writeln('$key: $value');
      });
    }
    
    buffer.writeln('\n--- Wallet ---');
    final wallet = results['wallet'] as Map<String, dynamic>?;
    if (wallet != null) {
      wallet.forEach((key, value) {
        buffer.writeln('$key: $value');
      });
    }
    
    buffer.writeln('\n--- Network ---');
    final network = results['network'] as Map<String, dynamic>?;
    if (network != null) {
      network.forEach((key, value) {
        buffer.writeln('$key: $value');
      });
    }
    
    return buffer.toString();
  }

  // Quick test functions
  static Future<void> testTasksAPI(BuildContext context) async {
    log('Testing Tasks API...', tag: 'TEST');
    final taskService = TaskService();
    
    try {
      final response = await taskService.getTasks(refresh: true);
      log('Tasks API Test Result: ${response.isSuccess}', tag: 'TEST');
      if (!response.isSuccess) {
        log('Tasks API Error: ${response.errorMessage}', tag: 'TEST');
      } else {
        log('Tasks received: ${taskService.tasks.length}', tag: 'TEST');
      }
    } catch (e) {
      log('Tasks API Test Exception: $e', tag: 'TEST');
    }
  }

  static Future<void> testWalletAPI(BuildContext context) async {
    log('Testing Wallet API...', tag: 'TEST');
    final walletService = WalletService();
    
    try {
      final walletResponse = await walletService.getWallet();
      final transactionsResponse = await walletService.getTransactions(refresh: true);
      
      log('Wallet API Test Result: ${walletResponse.isSuccess}', tag: 'TEST');
      log('Transactions API Test Result: ${transactionsResponse.isSuccess}', tag: 'TEST');
      
      if (!walletResponse.isSuccess) {
        log('Wallet API Error: ${walletResponse.errorMessage}', tag: 'TEST');
      }
      if (!transactionsResponse.isSuccess) {
        log('Transactions API Error: ${transactionsResponse.errorMessage}', tag: 'TEST');
      }
      
      log('Transactions received: ${walletService.transactions.length}', tag: 'TEST');
    } catch (e) {
      log('Wallet API Test Exception: $e', tag: 'TEST');
    }
  }
}
