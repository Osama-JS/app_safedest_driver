import 'dart:io';

import 'driver.dart';
import 'task.dart';
import 'wallet.dart';
import 'notification.dart';

class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final Map<String, dynamic>? errors;
  final String? errorCode;
  final int? statusCode;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.errors,
    this.errorCode,
    this.statusCode,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'],
      data: fromJsonT != null
          ? fromJsonT(json['data'] ?? json)
          : json['data'],
      errors: json['errors'],
      errorCode: json['error_code'],
      statusCode: json['status_code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data,
      'errors': errors,
      'error_code': errorCode,
      'status_code': statusCode,
    };
  }

  bool get isSuccess => success;
  bool get isError => !success;
  bool get hasData => data != null;
  bool get hasErrors => errors != null && errors!.isNotEmpty;

  String get errorMessage {
    if (message != null) return message!;
    if (hasErrors) {
      final firstError = errors!.values.first;
      if (firstError is List && firstError.isNotEmpty) {
        return firstError.first.toString();
      }
      return firstError.toString();
    }
    return 'حدث خطأ غير معروف';
  }

  @override
  String toString() {
    return 'ApiResponse(success: $success, message: $message, hasData: $hasData)';
  }
}

class LoginResponse {
  final bool success;
  final String? message;
  final String? token;
  final Driver? driver;
  final List<String>? abilities;

  LoginResponse({
    required this.success,
    this.message,
    this.token,
    this.driver,
    this.abilities,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] ?? false,
      message: json['message'],
      token: json['token'],
      driver: json['driver'] != null ? Driver.fromJson(json['driver']) : null,
      abilities: json['abilities'] != null
          ? List<String>.from(json['abilities'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'token': token,
      'driver': driver?.toJson(),
      'abilities': abilities,
    };
  }

  @override
  String toString() {
    return 'LoginResponse(success: $success, token: ${token != null ? 'present' : 'null'})';
  }
}

class TasksResponse {
  final bool success;
  final List<Task> tasks;
  final PaginationInfo pagination;

  TasksResponse({
    required this.success,
    required this.tasks,
    required this.pagination,
  });

  factory TasksResponse.fromJson(Map<String, dynamic> json) {
    return TasksResponse(
      success: json['success'] ?? false,
      tasks: (json['tasks'] as List? ?? [])
          .map((task) => Task.fromJson(task))
          .toList(),
      pagination: PaginationInfo.fromJson(json['pagination'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'tasks': tasks.map((task) => task.toJson()).toList(),
      'pagination': pagination.toJson(),
    };
  }
}

class CommissionInfo {
  final String type;
  final double value;

  CommissionInfo({
    required this.type,
    required this.value,
  });

  factory CommissionInfo.fromJson(Map<String, dynamic> json) {
    return CommissionInfo(
      type: json['type'] ?? 'percentage',
      value: (json['value'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'value': value,
    };
  }
}

class WalletResponse {
  final bool success;
  final Wallet? wallet;
  final CommissionInfo? commission;

  WalletResponse({
    required this.success,
    this.wallet,
    this.commission,
  });

  factory WalletResponse.fromJson(Map<String, dynamic> json) {
    return WalletResponse(
      success: json['success'] ?? false,
      wallet: json['wallet'] != null ? Wallet.fromJson(json['wallet']) : null,
      commission: json['commission'] != null
          ? CommissionInfo.fromJson(json['commission'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'wallet': wallet?.toJson(),
      'commission': commission?.toJson(),
    };
  }
}

class TransactionsResponse {
  final bool success;
  final List<WalletTransaction> transactions;
  final PaginationInfo pagination;

  TransactionsResponse({
    required this.success,
    required this.transactions,
    required this.pagination,
  });

  factory TransactionsResponse.fromJson(Map<String, dynamic> json) {
    return TransactionsResponse(
      success: json['success'] ?? false,
      transactions: (json['transactions'] as List? ?? [])
          .map((transaction) => WalletTransaction.fromJson(transaction))
          .toList(),
      pagination: PaginationInfo.fromJson(json['pagination'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'transactions': transactions.map((t) => t.toJson()).toList(),
      'pagination': pagination.toJson(),
    };
  }
}

class EarningsStatsResponse {
  final bool success;
  final EarningsStats? stats;

  EarningsStatsResponse({
    required this.success,
    this.stats,
  });

  factory EarningsStatsResponse.fromJson(Map<String, dynamic> json) {
    return EarningsStatsResponse(
      success: json['success'] ?? false,
      stats: json['stats'] != null ? EarningsStats.fromJson(json) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'stats': stats?.toJson(),
    };
  }
}
class AppStatus {
  final bool success;
  final String minVersion;
  final String updateUrl;
  final String serverTime;

  AppStatus({
    required this.success,
    required this.minVersion,
    required this.updateUrl,
    required this.serverTime,
  });

  factory AppStatus.fromJson(Map<String, dynamic> json) {
    String mainUpdateUrl = "";

    if (Platform.isAndroid) {
      mainUpdateUrl = json['update_url']??'';
    } else if (Platform.isIOS) {
      mainUpdateUrl = json['update_url_ios'];
    } else {
      mainUpdateUrl = json['update_url']??'';
    }
    return AppStatus(
      success: json['success'] ?? false,
      minVersion: json['min_version'] ?? '1.0.0',
      updateUrl:  mainUpdateUrl,
      serverTime: json['server_time'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'min_version': minVersion,
      'update_url': updateUrl,
      'server_time': serverTime,
    };
  }
}
