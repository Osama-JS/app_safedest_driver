import 'task_ad.dart';

class TaskOffer {
  final int id;
  final int? driverId;
  final String? driverName;
  final String? driverPhone;
  final double price;
  final String description;
  final bool accepted;
  final bool isMyOffer;
  final DateTime createdAt;
  final DateTime updatedAt;
  final TaskOfferAd? ad;

  TaskOffer({
    required this.id,
    this.driverId,
    this.driverName,
    this.driverPhone,
    required this.price,
    required this.description,
    required this.accepted,
    required this.isMyOffer,
    required this.createdAt,
    required this.updatedAt,
    this.ad,
  });

  factory TaskOffer.fromJson(Map<String, dynamic> json) {
    return TaskOffer(
      id: _parseToInt(json['id']) ?? 0,
      driverId: _parseToInt(json['driver_id']),
      driverName: _parseToString(json['driver_name']),
      driverPhone: _parseToString(json['driver_phone']),
      price: _parseToDouble(json['price']) ?? 0.0,
      description: _parseToString(json['description']) ?? '',
      accepted: _parseToBool(json['accepted']) ?? false,
      isMyOffer: _parseToBool(json['is_my_offer']) ?? false,
      createdAt: _parseToDateTime(json['created_at']) ?? DateTime.now(),
      updatedAt: _parseToDateTime(json['updated_at']) ?? DateTime.now(),
      ad: json['ad'] != null && json['ad'] is Map<String, dynamic>
          ? TaskOfferAd.fromJson(json['ad'])
          : null,
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

  static bool? _parseToBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
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
      'driver_id': driverId,
      'driver_name': driverName,
      'driver_phone': driverPhone,
      'price': price,
      'description': description,
      'accepted': accepted,
      'is_my_offer': isMyOffer,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'ad': ad?.toJson(),
    };
  }

  TaskOffer copyWith({
    int? id,
    int? driverId,
    String? driverName,
    String? driverPhone,
    double? price,
    String? description,
    bool? accepted,
    bool? isMyOffer,
    DateTime? createdAt,
    DateTime? updatedAt,
    TaskOfferAd? ad,
  }) {
    return TaskOffer(
      id: id ?? this.id,
      driverId: driverId ?? this.driverId,
      driverName: driverName ?? this.driverName,
      driverPhone: driverPhone ?? this.driverPhone,
      price: price ?? this.price,
      description: description ?? this.description,
      accepted: accepted ?? this.accepted,
      isMyOffer: isMyOffer ?? this.isMyOffer,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      ad: ad ?? this.ad,
    );
  }

  @override
  String toString() {
    return 'TaskOffer(id: $id, price: $price, accepted: $accepted, isMyOffer: $isMyOffer)';
  }

  // Get offer status for display
  TaskOfferStatus get status {
    if (accepted) {
      return TaskOfferStatus.accepted;
    } else if (ad?.status == 'closed') {
      return TaskOfferStatus.rejected;
    } else {
      return TaskOfferStatus.pending;
    }
  }
}

class TaskOfferAd {
  final int id;
  final int taskId;
  final String description;
  final String status;
  final double lowestPrice;
  final double highestPrice;
  final TaskOfferTask? task;

  TaskOfferAd({
    required this.id,
    required this.taskId,
    required this.description,
    required this.status,
    required this.lowestPrice,
    required this.highestPrice,
    this.task,
  });

  factory TaskOfferAd.fromJson(Map<String, dynamic> json) {
    return TaskOfferAd(
      id: TaskOffer._parseToInt(json['id']) ?? 0,
      taskId: TaskOffer._parseToInt(json['task_id']) ?? 0,
      description: TaskOffer._parseToString(json['description']) ?? '',
      status: TaskOffer._parseToString(json['status']) ?? 'running',
      lowestPrice: TaskOffer._parseToDouble(json['lowest_price']) ?? 0.0,
      highestPrice: TaskOffer._parseToDouble(json['highest_price']) ?? 0.0,
      task: json['task'] != null && json['task'] is Map<String, dynamic>
          ? TaskOfferTask.fromJson(json['task'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'task_id': taskId,
      'description': description,
      'status': status,
      'lowest_price': lowestPrice,
      'highest_price': highestPrice,
      'task': task?.toJson(),
    };
  }
}

class TaskOfferTask {
  final TaskOfferPoint? pickup;
  final TaskOfferPoint? delivery;

  TaskOfferTask({
    this.pickup,
    this.delivery,
  });

  factory TaskOfferTask.fromJson(Map<String, dynamic> json) {
    return TaskOfferTask(
      pickup: json['pickup'] != null && json['pickup'] is Map<String, dynamic>
          ? TaskOfferPoint.fromJson(json['pickup'])
          : null,
      delivery:
          json['delivery'] != null && json['delivery'] is Map<String, dynamic>
              ? TaskOfferPoint.fromJson(json['delivery'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pickup': pickup?.toJson(),
      'delivery': delivery?.toJson(),
    };
  }
}

class TaskOfferPoint {
  final String address;
  final String? contactName;

  TaskOfferPoint({
    required this.address,
    this.contactName,
  });

  factory TaskOfferPoint.fromJson(Map<String, dynamic> json) {
    return TaskOfferPoint(
      address: TaskOffer._parseToString(json['address']) ?? '',
      contactName: TaskOffer._parseToString(json['contact_name']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'contact_name': contactName,
    };
  }
}

// Task Offer Status Enum
enum TaskOfferStatus {
  pending,
  accepted,
  rejected,
}

extension TaskOfferStatusExtension on TaskOfferStatus {
  String get value {
    switch (this) {
      case TaskOfferStatus.pending:
        return 'pending';
      case TaskOfferStatus.accepted:
        return 'accepted';
      case TaskOfferStatus.rejected:
        return 'rejected';
    }
  }

  String get displayName {
    switch (this) {
      case TaskOfferStatus.pending:
        return 'في الانتظار';
      case TaskOfferStatus.accepted:
        return 'مقبول';
      case TaskOfferStatus.rejected:
        return 'مرفوض';
    }
  }

  static TaskOfferStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return TaskOfferStatus.pending;
      case 'accepted':
        return TaskOfferStatus.accepted;
      case 'rejected':
        return TaskOfferStatus.rejected;
      default:
        return TaskOfferStatus.pending;
    }
  }
}

// Response Models

class TaskOfferListResponse {
  final List<TaskOffer> offers;
  final int totalOffers;
  final TaskOffer? acceptedOffer;
  final String? message;

  TaskOfferListResponse({
    required this.offers,
    required this.totalOffers,
    this.acceptedOffer,
    this.message,
  });

  factory TaskOfferListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;

    return TaskOfferListResponse(
      offers: data['offers'] != null && data['offers'] is List
          ? (data['offers'] as List)
              .whereType<Map<String, dynamic>>()
              .map((item) => TaskOffer.fromJson(item))
              .toList()
          : [],
      totalOffers: TaskOffer._parseToInt(data['total_offers']) ?? 0,
      acceptedOffer: data['accepted_offer'] != null &&
              data['accepted_offer'] is Map<String, dynamic>
          ? TaskOffer.fromJson(data['accepted_offer'])
          : null,
      message: TaskOffer._parseToString(json['message']),
    );
  }
}

/// Pagination information for task offers
class TaskOfferPagination {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final int? from;
  final int? to;
  final bool hasMorePages;

  TaskOfferPagination({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    this.from,
    this.to,
    required this.hasMorePages,
  });

  factory TaskOfferPagination.fromJson(Map<String, dynamic> json) {
    return TaskOfferPagination(
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      perPage: json['per_page'] ?? 10,
      total: json['total'] ?? 0,
      from: json['from'],
      to: json['to'],
      hasMorePages: json['has_more_pages'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'last_page': lastPage,
      'per_page': perPage,
      'total': total,
      'from': from,
      'to': to,
      'has_more_pages': hasMorePages,
    };
  }
}

class MyOffersResponse {
  final List<TaskOffer> data;
  final TaskOfferPagination? pagination;
  final String? message;

  MyOffersResponse({
    required this.data,
    this.pagination,
    this.message,
  });

  // Backward compatibility getters
  List<TaskOffer> get offers => data;
  int get currentPage => pagination?.currentPage ?? 1;
  int get lastPage => pagination?.lastPage ?? 1;
  int get total => pagination?.total ?? 0;
  bool get hasMorePages => pagination?.hasMorePages ?? false;

  factory MyOffersResponse.fromJson(dynamic json) {
    try {
      // Handle both direct array and nested data structure
      List<dynamic> offersJson;
      TaskOfferPagination? pagination;

      if (json is Map<String, dynamic>) {
        if (json['data'] != null && json['data'] is Map<String, dynamic>) {
          // Nested structure: {"success": true, "data": {"data": [...], "pagination": {...}}}
          final dataMap = json['data'] as Map<String, dynamic>;
          offersJson = dataMap['data'] as List<dynamic>? ?? [];

          if (dataMap['pagination'] != null) {
            pagination = TaskOfferPagination.fromJson(dataMap['pagination']);
          }
        } else if (json['data'] != null && json['data'] is List) {
          // Direct data array: {"success": true, "data": [...]}
          offersJson = json['data'] as List<dynamic>;
        } else {
          offersJson = [];
        }
      } else if (json is List) {
        // Direct array response: [...]
        offersJson = json;
      } else {
        offersJson = [];
      }

      final offers =
          offersJson.map((offerJson) => TaskOffer.fromJson(offerJson)).toList();

      return MyOffersResponse(
        data: offers,
        pagination: pagination,
        message: json is Map<String, dynamic> ? json['message'] : null,
      );
    } catch (e) {
      print('Error parsing MyOffersResponse: $e');
      return MyOffersResponse(
        data: [],
        pagination: null,
        message: 'Error parsing response',
      );
    }
  }
}
