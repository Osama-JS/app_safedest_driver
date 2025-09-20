class Task {
  final int id;
  final String? customerName;
  final String? pickupAddress;
  final String? deliveryAddress;
  final double totalPrice;
  final double commission;
  final String status;
  final String? notes;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? completedAt;
  final String? paymentMethod;
  final String? paymentStatus;
  final int? driverId;
  final int? pendingDriverId;
  final Customer? customer;
  final TaskPoint? pickupPoint;
  final TaskPoint? deliveryPoint;
  final List<TaskItem>? items;
  final String? specialInstructions;

  // حساب مستحقات السائق (السعر - العمولة)
  double get driverEarnings => totalPrice - commission;

  Task({
    required this.id,
    this.customerName,
    this.pickupAddress,
    this.deliveryAddress,
    required this.totalPrice,
    required this.commission,
    required this.status,
    this.notes,
    required this.createdAt,
    this.acceptedAt,
    this.completedAt,
    this.paymentMethod,
    this.paymentStatus,
    this.driverId,
    this.pendingDriverId,
    this.customer,
    this.pickupPoint,
    this.deliveryPoint,
    this.items,
    this.specialInstructions,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: _parseToInt(json['id']) ?? 0,
      customerName: _parseToString(json['customer_name']),
      pickupAddress: _parseToString(json['pickup_address']),
      deliveryAddress: _parseToString(json['delivery_address']),
      totalPrice: _parseToDouble(json['total_price']) ?? 0.0,
      commission: _parseToDouble(json['commission']) ?? 0.0,
      status: _parseToString(json['status']) ?? 'assign',
      driverId: _parseToInt(json['driver_id']),
      pendingDriverId: _parseToInt(json['pending_driver_id']),
      notes: _parseToString(json['notes']),
      createdAt: _parseToDateTime(json['created_at']) ?? DateTime.now(),
      acceptedAt: _parseToDateTime(json['accepted_at']),
      completedAt: _parseToDateTime(json['completed_at']),
      paymentMethod: _parseToString(json['payment_method']),
      paymentStatus: _parseToString(json['payment_status']),
      customer:
          json['customer'] != null && json['customer'] is Map<String, dynamic>
              ? Customer.fromJson(json['customer'])
              : null,
      pickupPoint: json['pickup_point'] != null &&
              json['pickup_point'] is Map<String, dynamic>
          ? TaskPoint.fromJson(json['pickup_point'])
          : null,
      deliveryPoint: json['delivery_point'] != null &&
              json['delivery_point'] is Map<String, dynamic>
          ? TaskPoint.fromJson(json['delivery_point'])
          : null,
      items: json['items'] != null && json['items'] is List
          ? (json['items'] as List)
              .whereType<Map<String, dynamic>>()
              .map((item) => TaskItem.fromJson(item))
              .toList()
          : null,
      specialInstructions: _parseToString(json['special_instructions']),
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
      'customer_name': customerName,
      'pickup_address': pickupAddress,
      'delivery_address': deliveryAddress,
      'total_price': totalPrice,
      'commission': commission,
      'status': status,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'accepted_at': acceptedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'customer': customer?.toJson(),
      'pickup_point': pickupPoint?.toJson(),
      'delivery_point': deliveryPoint?.toJson(),
      'items': items?.map((item) => item.toJson()).toList(),
      'special_instructions': specialInstructions,
    };
  }

  Task copyWith({
    int? id,
    String? customerName,
    String? pickupAddress,
    String? deliveryAddress,
    double? totalPrice,
    double? commission,
    String? status,
    String? notes,
    DateTime? createdAt,
    DateTime? acceptedAt,
    DateTime? completedAt,
    String? paymentMethod,
    String? paymentStatus,
    Customer? customer,
    TaskPoint? pickupPoint,
    TaskPoint? deliveryPoint,
    List<TaskItem>? items,
    String? specialInstructions,
  }) {
    return Task(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      totalPrice: totalPrice ?? this.totalPrice,
      commission: commission ?? this.commission,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      completedAt: completedAt ?? this.completedAt,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      customer: customer ?? this.customer,
      pickupPoint: pickupPoint ?? this.pickupPoint,
      deliveryPoint: deliveryPoint ?? this.deliveryPoint,
      items: items ?? this.items,
      specialInstructions: specialInstructions ?? this.specialInstructions,
    );
  }

  @override
  String toString() {
    return 'Task(id: $id, status: $status, totalPrice: $totalPrice, commission: $commission)';
  }
}

class Customer {
  final String name;
  final String? phone;
  final String? email;

  Customer({
    required this.name,
    this.phone,
    this.email,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      name: Task._parseToString(json['name']) ?? 'Unknown',
      phone: Task._parseToString(json['phone']),
      email: Task._parseToString(json['email']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
    };
  }
}

class TaskPoint {
  final String address;
  final double latitude;
  final double longitude;
  final String? contactName;
  final String? contactPhone;

  TaskPoint({
    required this.address,
    required this.latitude,
    required this.longitude,
    this.contactName,
    this.contactPhone,
  });

  factory TaskPoint.fromJson(Map<String, dynamic> json) {
    return TaskPoint(
      address: Task._parseToString(json['address']) ?? '',
      latitude: Task._parseToDouble(json['latitude']) ?? 0.0,
      longitude: Task._parseToDouble(json['longitude']) ?? 0.0,
      contactName: Task._parseToString(json['contact_name']),
      contactPhone: Task._parseToString(json['contact_phone']),
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

class TaskItem {
  final String description;
  final int quantity;
  final double? weight;

  TaskItem({
    required this.description,
    required this.quantity,
    this.weight,
  });

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      description: Task._parseToString(json['description']) ?? '',
      quantity: Task._parseToInt(json['quantity']) ?? 1,
      weight: Task._parseToDouble(json['weight']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'quantity': quantity,
      'weight': weight,
    };
  }
}

// Task Status Enum
enum TaskStatus {
  assign,
  started,
  inPickupPoint,
  loading,
  inTheWay,
  inDeliveryPoint,
  unloading,
  completed,
  cancelled,
}

extension TaskStatusExtension on TaskStatus {
  String get value {
    switch (this) {
      case TaskStatus.assign:
        return 'assign';
      case TaskStatus.started:
        return 'started';
      case TaskStatus.inPickupPoint:
        return 'in pickup point';
      case TaskStatus.loading:
        return 'loading';
      case TaskStatus.inTheWay:
        return 'in the way';
      case TaskStatus.inDeliveryPoint:
        return 'in delivery point';
      case TaskStatus.unloading:
        return 'unloading';
      case TaskStatus.completed:
        return 'completed';
      case TaskStatus.cancelled:
        return 'cancelled';
    }
  }

  String get displayName {
    switch (this) {
      case TaskStatus.assign:
        return 'مخصصة';
      case TaskStatus.started:
        return 'بدأت';
      case TaskStatus.inPickupPoint:
        return 'في نقطة الاستلام';
      case TaskStatus.loading:
        return 'جاري التحميل';
      case TaskStatus.inTheWay:
        return 'في الطريق';
      case TaskStatus.inDeliveryPoint:
        return 'في نقطة التسليم';
      case TaskStatus.unloading:
        return 'جاري التفريغ';
      case TaskStatus.completed:
        return 'مكتملة';
      case TaskStatus.cancelled:
        return 'ملغية';
    }
  }

  static TaskStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'assign':
        return TaskStatus.assign;
      case 'started':
        return TaskStatus.started;
      case 'in pickup point':
        return TaskStatus.inPickupPoint;
      case 'loading':
        return TaskStatus.loading;
      case 'in the way':
        return TaskStatus.inTheWay;
      case 'in delivery point':
        return TaskStatus.inDeliveryPoint;
      case 'unloading':
        return TaskStatus.unloading;
      case 'completed':
        return TaskStatus.completed;
      case 'cancelled':
        return TaskStatus.cancelled;
      default:
        return TaskStatus.assign;
    }
  }
}

// Response Models
class TaskListResponse {
  final List<Task> tasks;
  final int currentPage;
  final int lastPage;
  final int total;
  final String? message;

  TaskListResponse({
    required this.tasks,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    this.message,
  });

  factory TaskListResponse.fromJson(Map<String, dynamic> json) {
    return TaskListResponse(
      tasks: json['data'] != null && json['data'] is List
          ? (json['data'] as List)
              .whereType<Map<String, dynamic>>()
              .map((item) => Task.fromJson(item))
              .toList()
          : json['tasks'] != null && json['tasks'] is List
              ? (json['tasks'] as List)
                  .whereType<Map<String, dynamic>>()
                  .map((item) => Task.fromJson(item))
                  .toList()
              : [],
      currentPage: Task._parseToInt(json['current_page']) ?? 1,
      lastPage: Task._parseToInt(json['last_page']) ?? 1,
      total: Task._parseToInt(json['total']) ?? 0,
      message: Task._parseToString(json['message']),
    );
  }
}

class TaskLog {
  final int id;
  final String status;
  final String? note;
  final String? fileName;
  final String? filePath;
  final DateTime createdAt;
  final String type;

  TaskLog({
    required this.id,
    required this.status,
    this.note,
    this.fileName,
    this.filePath,
    required this.createdAt,
    required this.type,
  });

  factory TaskLog.fromJson(Map<String, dynamic> json) {
    return TaskLog(
      id: Task._parseToInt(json['id']) ?? 0,
      status: Task._parseToString(json['status']) ?? '',
      note: Task._parseToString(json['note']),
      fileName: Task._parseToString(json['file_name']),
      filePath: Task._parseToString(json['file_path']),
      createdAt: Task._parseToDateTime(json['created_at']) ?? DateTime.now(),
      type: Task._parseToString(json['type']) ?? 'status_change',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'note': note,
      'file_name': fileName,
      'file_path': filePath,
      'created_at': createdAt.toIso8601String(),
      'type': type,
    };
  }
}
