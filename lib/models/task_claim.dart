import 'package:get/get.dart';

class TaskClaim {
  final int id;
  final int taskId;
  final String? customerTaskNumber;
  final String? status;
  final String? adminNote;
  final String? driverNote;
  final DateTime? createdAt;
  final String? pickupAddress;
  final String? deliveryAddress;
  final String? customerName;

  TaskClaim({
    required this.id,
    required this.taskId,
    this.customerTaskNumber,
    this.status,
    this.adminNote,
    this.driverNote,
    this.createdAt,
    this.pickupAddress,
    this.deliveryAddress,
    this.customerName,
  });

  factory TaskClaim.fromJson(Map<String, dynamic> json) {
    return TaskClaim(
      id: _parseToInt(json['id']) ?? 0,
      taskId: _parseToInt(json['task_id']) ?? 0,
      customerTaskNumber: _parseToString(json['customer_task_number']),
      status: _parseToString(json['status']),
      adminNote: _parseToString(json['admin_note']),
      driverNote: _parseToString(json['driver_note']),
      createdAt: _parseToDateTime(json['created_at']),
      pickupAddress: _parseToString(json['pickup_address']),
      deliveryAddress: _parseToString(json['delivery_address']),
      customerName: _parseToString(json['customer_name']),
    );
  }

  static int? _parseToInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static String? _parseToString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value.isEmpty ? null : value;
    return value.toString();
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
}

class AvailableTask {
  final int id;
  final String? customerTaskNumber;
  final double totalPrice;
  final String? customerName;
  final String? pickupAddress;
  final String? deliveryAddress;
  final double? distance;
  final String? status;
  final DateTime? createdAt;
  final String? claimStatus;
  final String? vehicleSize;
  final Map<String, dynamic>? additionalData;
  final String? conditions;

  AvailableTask({
    required this.id,
    this.customerTaskNumber,
    required this.totalPrice,
    this.customerName,
    this.pickupAddress,
    this.deliveryAddress,
    this.distance,
    this.status,
    this.createdAt,
    this.claimStatus,
    this.vehicleSize,
    this.additionalData,
    this.conditions,
  });

  factory AvailableTask.fromJson(Map<String, dynamic> json) {
    return AvailableTask(
      id: TaskClaim._parseToInt(json['id']) ?? 0,
      customerTaskNumber: TaskClaim._parseToString(json['customer_task_number']),
      totalPrice: _parseToDouble(json['total_price']) ?? 0.0,
      customerName: TaskClaim._parseToString(json['customer_name']),
      pickupAddress: TaskClaim._parseToString(json['pickup_address']),
      deliveryAddress: TaskClaim._parseToString(json['delivery_address']),
      distance: _parseToDouble(json['distance']),
      status: TaskClaim._parseToString(json['status']),
      createdAt: TaskClaim._parseToDateTime(json['created_at']),
      claimStatus: TaskClaim._parseToString(json['claim_status']),
      vehicleSize: TaskClaim._parseToString(json['vehicle_size']),
      additionalData: json['additional_data'] != null
          ? (json['additional_data'] is Map
              ? Map<String, dynamic>.from(json['additional_data'])
              : (json['additional_data'] is List
                  ? Map.fromEntries((json['additional_data'] as List)
                      .whereType<Map<String, dynamic>>()
                      .map((e) => MapEntry(
                          TaskClaim._parseToString(e['label']) ?? 'unspecified'.tr,
                          TaskClaim._parseToString(e['value']) ?? '')))
                  : null))
          : null,
      conditions: TaskClaim._parseToString(json['conditions']),
    );
  }

  static double? _parseToDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
