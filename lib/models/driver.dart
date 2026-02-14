import 'dart:convert';

class Driver {
  final int id;
  final String name;
  final String email;
  final String? username;
  final String phone;
  final String? phoneCode;
  final String? driverCode;
  final String? image;
  final String status;
  final bool online;
  final bool free;
  final String? address;
  final double? longitude;
  final double? latitude;
  final DateTime? lastSeenAt;
  final String commissionType;
  final double commissionValue;
  final int? locationUpdateInterval;
  final int? teamId;
  final int? vehicleSizeId;
  final double? walletBalance;
  final String? appVersion;
  final DateTime? lastActivityAt;
  final Map<String, dynamic>? additionalData;
  final Team? team;
  final VehicleSize? vehicleSize;

  final String? signatureImage;
  final String? bankName;
  final String? accountNumber;
  final String? ibanNumber;

  Driver({
    required this.id,
    required this.name,
    required this.email,
    this.username,
    required this.phone,
    this.phoneCode,
    this.driverCode,
    this.image,
    required this.status,
    required this.online,
    required this.free,
    this.address,
    this.longitude,
    this.latitude,
    this.lastSeenAt,
    required this.commissionType,
    required this.commissionValue,
    this.locationUpdateInterval,
    this.teamId,
    this.vehicleSizeId,
    this.walletBalance,
    this.appVersion,
    this.lastActivityAt,
    this.additionalData,
    this.team,
    this.vehicleSize,
    this.signatureImage,
    this.bankName,
    this.accountNumber,
    this.ibanNumber,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      username: json['username'],
      phone: json['phone'] ?? '',
      phoneCode: json['phone_code'],
      driverCode: json['driver_code'],
      image: json['image'],
      status: json['status'] ?? 'inactive',
      online: json['online'] ?? false,
      free: json['free'] ?? false,
      address: json['address'],
      longitude: json['longitude']?.toDouble(),
      latitude: json['altitude']
          ?.toDouble(), // Note: API uses 'altitude' for latitude
      lastSeenAt: json['last_seen_at'] != null
          ? DateTime.parse(json['last_seen_at'])
          : null,
      commissionType: json['commission_type'] ?? 'percentage',
      commissionValue: (json['commission_value'] ?? 0).toDouble(),
      locationUpdateInterval: json['location_update_interval'],
      teamId: json['team_id'],
      vehicleSizeId: json['vehicle_size_id'],
      walletBalance: (json['wallet_balance'] ?? 0).toDouble(),
      appVersion: json['app_version'],
      lastActivityAt: json['last_activity_at'] != null
          ? DateTime.parse(json['last_activity_at'])
          : null,
      additionalData: json['additional_data'] != null
          ? (json['additional_data'] is String
              ? Map<String, dynamic>.from(
                  jsonDecode(json['additional_data']) ?? {})
              : (json['additional_data'] is Map
                  ? Map<String, dynamic>.from(json['additional_data'])
                  : {}))
          : null,
      team: json['team'] != null ? Team.fromJson(json['team']) : null,
      vehicleSize: json['vehicle_size'] != null
          ? VehicleSize.fromJson(json['vehicle_size'])
          : null,
      signatureImage: json['signature_image'],
      bankName: json['bank_name'],
      accountNumber: json['account_number'],
      ibanNumber: json['iban_number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'username': username,
      'phone': phone,
      'phone_code': phoneCode,
      'image': image,
      'status': status,
      'online': online,
      'free': free,
      'address': address,
      'longitude': longitude,
      'altitude': latitude, // Note: API uses 'altitude' for latitude
      'last_seen_at': lastSeenAt?.toIso8601String(),
      'commission_type': commissionType,
      'commission_value': commissionValue,
      'location_update_interval': locationUpdateInterval,
      'team_id': teamId,
      'vehicle_size_id': vehicleSizeId,
      'wallet_balance': walletBalance,
      'app_version': appVersion,
      'last_activity_at': lastActivityAt?.toIso8601String(),
      'team': team?.toJson(),
      'vehicle_size': vehicleSize?.toJson(),
      'signature_image': signatureImage,
      'bank_name': bankName,
      'account_number': accountNumber,
      'iban_number': ibanNumber,
      'driver_code': driverCode,
    };
  }

  Driver copyWith({
    int? id,
    String? name,
    String? email,
    String? username,
    String? phone,
    String? phoneCode,
    String? driverCode,
    String? image,
    String? status,
    bool? online,
    bool? free,
    String? address,
    double? longitude,
    double? latitude,
    DateTime? lastSeenAt,
    String? commissionType,
    double? commissionValue,
    int? locationUpdateInterval,
    int? teamId,
    int? vehicleSizeId,
    double? walletBalance,
    String? appVersion,
    DateTime? lastActivityAt,
    Team? team,
    VehicleSize? vehicleSize,
    String? signatureImage,
    String? bankName,
    String? accountNumber,
    String? ibanNumber,
  }) {
    return Driver(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      username: username ?? this.username,
      phone: phone ?? this.phone,
      phoneCode: phoneCode ?? this.phoneCode,
      driverCode: driverCode ?? this.driverCode,
      image: image ?? this.image,
      status: status ?? this.status,
      online: online ?? this.online,
      free: free ?? this.free,
      address: address ?? this.address,
      longitude: longitude ?? this.longitude,
      latitude: latitude ?? this.latitude,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      commissionType: commissionType ?? this.commissionType,
      commissionValue: commissionValue ?? this.commissionValue,
      locationUpdateInterval:
          locationUpdateInterval ?? this.locationUpdateInterval,
      teamId: teamId ?? this.teamId,
      vehicleSizeId: vehicleSizeId ?? this.vehicleSizeId,
      walletBalance: walletBalance ?? this.walletBalance,
      appVersion: appVersion ?? this.appVersion,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      team: team ?? this.team,
      vehicleSize: vehicleSize ?? this.vehicleSize,
      signatureImage: signatureImage ?? this.signatureImage,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      ibanNumber: ibanNumber ?? this.ibanNumber,
    );
  }

  @override
  String toString() {
    return 'Driver(id: $id, name: $name, email: $email, online: $online, free: $free)';
  }
}

class Team {
  final int id;
  final String name;

  Team({
    required this.id,
    required this.name,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class VehicleSize {
  final int id;
  final String name;

  VehicleSize({
    required this.id,
    required this.name,
  });

  factory VehicleSize.fromJson(Map<String, dynamic> json) {
    return VehicleSize(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

// Driver Status Enum
enum DriverStatus {
  active,
  inactive,
  suspended,
  pending,
}

extension DriverStatusExtension on DriverStatus {
  String get value {
    switch (this) {
      case DriverStatus.active:
        return 'active';
      case DriverStatus.inactive:
        return 'inactive';
      case DriverStatus.suspended:
        return 'suspended';
      case DriverStatus.pending:
        return 'pending';
    }
  }

  static DriverStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return DriverStatus.active;
      case 'inactive':
        return DriverStatus.inactive;
      case 'suspended':
        return DriverStatus.suspended;
      case 'pending':
        return DriverStatus.pending;
      default:
        return DriverStatus.inactive;
    }
  }
}
