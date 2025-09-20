import 'task_offer.dart';

class TaskAd {
  final int id;
  final int taskId;
  final String description;
  final String status;
  final double lowestPrice;
  final double highestPrice;
  final bool included;
  final DateTime createdAt;
  final DateTime? closedAt;
  final TaskAdTask? task;
  final TaskOffer? myOffer;
  final int offersCount;
  final bool hasAcceptedOffer;
  final int? acceptedDriverId;
  final bool canSubmitOffer;
  final bool canViewDetails;
  final TaskAdCommission? commission;

  TaskAd({
    required this.id,
    required this.taskId,
    required this.description,
    required this.status,
    required this.lowestPrice,
    required this.highestPrice,
    required this.included,
    required this.createdAt,
    this.closedAt,
    this.task,
    this.myOffer,
    required this.offersCount,
    required this.hasAcceptedOffer,
    this.acceptedDriverId,
    required this.canSubmitOffer,
    required this.canViewDetails,
    this.commission,
  });

  factory TaskAd.fromJson(Map<String, dynamic> json) {
    return TaskAd(
      id: _parseToInt(json['id']) ?? 0,
      taskId: _parseToInt(json['task_id']) ?? 0,
      description: _parseToString(json['description']) ?? '',
      status: _parseToString(json['status']) ?? 'running',
      lowestPrice: _parseToDouble(json['lowest_price']) ?? 0.0,
      highestPrice: _parseToDouble(json['highest_price']) ?? 0.0,
      included: _parseToBool(json['included']) ?? false,
      createdAt: _parseToDateTime(json['created_at']) ?? DateTime.now(),
      closedAt: _parseToDateTime(json['closed_at']),
      task: json['task'] != null && json['task'] is Map<String, dynamic>
          ? TaskAdTask.fromJson(json['task'])
          : null,
      myOffer:
          json['my_offer'] != null && json['my_offer'] is Map<String, dynamic>
              ? TaskOffer.fromJson(json['my_offer'])
              : null,
      offersCount: _parseToInt(json['offers_count']) ?? 0,
      hasAcceptedOffer: _parseToBool(json['has_accepted_offer']) ?? false,
      acceptedDriverId: _parseToInt(json['accepted_driver_id']),
      canSubmitOffer: _parseToBool(json['can_submit_offer']) ?? false,
      canViewDetails: _parseToBool(json['can_view_details']) ?? false,
      commission: json['commission'] != null &&
              json['commission'] is Map<String, dynamic>
          ? TaskAdCommission.fromJson(json['commission'])
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
      'task_id': taskId,
      'description': description,
      'status': status,
      'lowest_price': lowestPrice,
      'highest_price': highestPrice,
      'included': included,
      'created_at': createdAt.toIso8601String(),
      'closed_at': closedAt?.toIso8601String(),
      'task': task?.toJson(),
      'my_offer': myOffer?.toJson(),
      'offers_count': offersCount,
      'has_accepted_offer': hasAcceptedOffer,
      'accepted_driver_id': acceptedDriverId,
      'can_submit_offer': canSubmitOffer,
      'can_view_details': canViewDetails,
      'commission': commission?.toJson(),
    };
  }

  TaskAd copyWith({
    int? id,
    int? taskId,
    String? description,
    String? status,
    double? lowestPrice,
    double? highestPrice,
    bool? included,
    DateTime? createdAt,
    DateTime? closedAt,
    TaskAdTask? task,
    TaskOffer? myOffer,
    int? offersCount,
    bool? hasAcceptedOffer,
    int? acceptedDriverId,
    bool? canSubmitOffer,
    bool? canViewDetails,
    TaskAdCommission? commission,
  }) {
    return TaskAd(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      description: description ?? this.description,
      status: status ?? this.status,
      lowestPrice: lowestPrice ?? this.lowestPrice,
      highestPrice: highestPrice ?? this.highestPrice,
      included: included ?? this.included,
      createdAt: createdAt ?? this.createdAt,
      closedAt: closedAt ?? this.closedAt,
      task: task ?? this.task,
      myOffer: myOffer ?? this.myOffer,
      offersCount: offersCount ?? this.offersCount,
      hasAcceptedOffer: hasAcceptedOffer ?? this.hasAcceptedOffer,
      acceptedDriverId: acceptedDriverId ?? this.acceptedDriverId,
      canSubmitOffer: canSubmitOffer ?? this.canSubmitOffer,
      canViewDetails: canViewDetails ?? this.canViewDetails,
      commission: commission ?? this.commission,
    );
  }

  @override
  String toString() {
    return 'TaskAd(id: $id, status: $status, priceRange: $lowestPrice-$highestPrice)';
  }
}

class TaskAdTask {
  final TaskAdPoint? pickup;
  final TaskAdPoint? delivery;
  final String? vehicleSize;
  final TaskAdCustomer? customer;

  TaskAdTask({
    this.pickup,
    this.delivery,
    this.vehicleSize,
    this.customer,
  });

  factory TaskAdTask.fromJson(Map<String, dynamic> json) {
    return TaskAdTask(
      pickup: json['pickup'] != null && json['pickup'] is Map<String, dynamic>
          ? TaskAdPoint.fromJson(json['pickup'])
          : null,
      delivery:
          json['delivery'] != null && json['delivery'] is Map<String, dynamic>
              ? TaskAdPoint.fromJson(json['delivery'])
              : null,
      vehicleSize: TaskAd._parseToString(json['vehicle_size']),
      customer:
          json['customer'] != null && json['customer'] is Map<String, dynamic>
              ? TaskAdCustomer.fromJson(json['customer'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pickup': pickup?.toJson(),
      'delivery': delivery?.toJson(),
      'vehicle_size': vehicleSize,
      'customer': customer?.toJson(),
    };
  }
}

class TaskAdPoint {
  final String address;
  final double? latitude;
  final double? longitude;
  final String? contactName;
  final String? contactPhone;

  TaskAdPoint({
    required this.address,
    this.latitude,
    this.longitude,
    this.contactName,
    this.contactPhone,
  });

  factory TaskAdPoint.fromJson(Map<String, dynamic> json) {
    return TaskAdPoint(
      address: TaskAd._parseToString(json['address']) ?? '',
      latitude: TaskAd._parseToDouble(json['latitude']),
      longitude: TaskAd._parseToDouble(json['longitude']),
      contactName: TaskAd._parseToString(json['contact_name']),
      contactPhone: TaskAd._parseToString(json['contact_phone']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'contact_name': contactName,
      'contact_phone': contactPhone,
    };
  }
}

class TaskAdCustomer {
  final String owner;
  final String? name;
  final String? phone;

  TaskAdCustomer({
    required this.owner,
    this.name,
    this.phone,
  });

  factory TaskAdCustomer.fromJson(Map<String, dynamic> json) {
    return TaskAdCustomer(
      owner: TaskAd._parseToString(json['owner']) ?? 'customer',
      name: TaskAd._parseToString(json['name']),
      phone: TaskAd._parseToString(json['phone']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'owner': owner,
      'name': name,
      'phone': phone,
    };
  }
}

class TaskAdCommission {
  final double serviceCommission;
  final String serviceCommissionType;
  final double vatCommission;

  TaskAdCommission({
    required this.serviceCommission,
    required this.serviceCommissionType,
    required this.vatCommission,
  });

  factory TaskAdCommission.fromJson(Map<String, dynamic> json) {
    return TaskAdCommission(
      serviceCommission:
          TaskAd._parseToDouble(json['service_commission']) ?? 0.0,
      serviceCommissionType:
          TaskAd._parseToString(json['service_commission_type']) ??
              'percentage',
      vatCommission: TaskAd._parseToDouble(json['vat_commission']) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'service_commission': serviceCommission,
      'service_commission_type': serviceCommissionType,
      'vat_commission': vatCommission,
    };
  }

  // حساب صافي مستحقات السائق
  double calculateDriverNet(double offerPrice) {
    double commission = serviceCommissionType == 'fixed'
        ? serviceCommission
        : (offerPrice * serviceCommission / 100);

    double vatAmount = offerPrice * vatCommission / 100;
    double totalDeduction = commission + vatAmount;

    return offerPrice - totalDeduction;
  }
}

// Task Ad Status Enum
enum TaskAdStatus {
  running,
  closed,
}

extension TaskAdStatusExtension on TaskAdStatus {
  String get value {
    switch (this) {
      case TaskAdStatus.running:
        return 'running';
      case TaskAdStatus.closed:
        return 'closed';
    }
  }

  String get displayName {
    switch (this) {
      case TaskAdStatus.running:
        return 'جاري';
      case TaskAdStatus.closed:
        return 'مغلق';
    }
  }

  static TaskAdStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'running':
        return TaskAdStatus.running;
      case 'closed':
        return TaskAdStatus.closed;
      default:
        return TaskAdStatus.running;
    }
  }
}

/// Response wrapper for task ads list
class TaskAdListResponse {
  final List<TaskAd> data;
  final TaskAdPagination? pagination;

  TaskAdListResponse({
    required this.data,
    this.pagination,
  });

  factory TaskAdListResponse.fromJson(dynamic json) {
    // Handle both direct array and nested data structure
    List<dynamic> adsJson;
    TaskAdPagination? pagination;

    if (json is Map<String, dynamic>) {
      if (json['data'] != null && json['data'] is Map<String, dynamic>) {
        // Nested structure: {"success": true, "data": {"data": [...], "pagination": {...}}}
        final dataMap = json['data'] as Map<String, dynamic>;
        adsJson = dataMap['data'] as List<dynamic>? ?? [];

        if (dataMap['pagination'] != null) {
          pagination = TaskAdPagination.fromJson(dataMap['pagination']);
        }
      } else if (json['data'] != null && json['data'] is List) {
        // Direct data array: {"success": true, "data": [...]}
        adsJson = json['data'] as List<dynamic>;
      } else {
        adsJson = [];
      }
    } else if (json is List) {
      // Direct array response: [...]
      adsJson = json;
    } else {
      adsJson = [];
    }

    final ads = adsJson.map((adJson) => TaskAd.fromJson(adJson)).toList();

    return TaskAdListResponse(
      data: ads,
      pagination: pagination,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((ad) => ad.toJson()).toList(),
      'pagination': pagination?.toJson(),
    };
  }
}

/// Pagination information for task ads
class TaskAdPagination {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final int? from;
  final int? to;
  final bool hasMorePages;

  TaskAdPagination({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    this.from,
    this.to,
    required this.hasMorePages,
  });

  factory TaskAdPagination.fromJson(Map<String, dynamic> json) {
    return TaskAdPagination(
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
