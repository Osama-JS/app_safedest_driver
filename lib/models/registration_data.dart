class RegistrationData {
  final List<Vehicle> vehicles;
  final FormTemplate? driverTemplate;
  final List<FormField> driverFields;
  final List<Team> publicTeams;
  final List<Map<String, String>> phoneCodes;

  RegistrationData({
    required this.vehicles,
    this.driverTemplate,
    required this.driverFields,
    required this.publicTeams,
    required this.phoneCodes,
  });

  factory RegistrationData.fromJson(Map<String, dynamic> json) {
    return RegistrationData(
      vehicles: (json['vehicles'] as List<dynamic>?)
              ?.map((item) => Vehicle.fromJson(item))
              .toList() ??
          [],
      driverTemplate: json['driver_template'] != null
          ? FormTemplate.fromJson(json['driver_template'])
          : null,
      driverFields: (json['driver_fields'] as List<dynamic>?)
              ?.map((item) => FormField.fromJson(item))
              .toList() ??
          [],
      publicTeams: (json['public_teams'] as List<dynamic>?)
              ?.map((item) => Team.fromJson(item))
              .toList() ??
          [],
      phoneCodes: (json['phone_codes'] as List<dynamic>?)
              ?.map((item) => Map<String, String>.from(item))
              .toList() ??
          [],
    );
  }
}

class Vehicle {
  final int id;
  final String name;
  final String? enName;
  final List<VehicleType> types;

  Vehicle({
    required this.id,
    required this.name,
    this.enName,
    required this.types,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      enName: json['en_name'],
      types: (json['types'] as List<dynamic>?)
              ?.map((item) => VehicleType.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class VehicleType {
  final int id;
  final String name;
  final String? enName;
  final int vehicleId;
  final List<VehicleSize> sizes;

  VehicleType({
    required this.id,
    required this.name,
    this.enName,
    required this.vehicleId,
    required this.sizes,
  });

  factory VehicleType.fromJson(Map<String, dynamic> json) {
    return VehicleType(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      enName: json['en_name'],
      vehicleId: json['vehicle_id'] ?? 0,
      sizes: (json['sizes'] as List<dynamic>?)
              ?.map((item) => VehicleSize.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class VehicleSize {
  final int id;
  final String name;
  final int vehicleTypeId;

  VehicleSize({
    required this.id,
    required this.name,
    required this.vehicleTypeId,
  });

  factory VehicleSize.fromJson(Map<String, dynamic> json) {
    return VehicleSize(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      vehicleTypeId: json['vehicle_type_id'] ?? 0,
    );
  }
}

class FormTemplate {
  final int id;
  final String name;
  final String? description;

  FormTemplate({
    required this.id,
    required this.name,
    this.description,
  });

  factory FormTemplate.fromJson(Map<String, dynamic> json) {
    return FormTemplate(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
    );
  }
}

class FormField {
  final int id;
  final int formTemplateId;
  final String name;
  final String label;
  final String type;
  final bool required;
  final String? value;
  final int order;

  FormField({
    required this.id,
    required this.formTemplateId,
    required this.name,
    required this.label,
    required this.type,
    required this.required,
    this.value,
    required this.order,
  });

  factory FormField.fromJson(Map<String, dynamic> json) {
    return FormField(
      id: json['id'] ?? 0,
      formTemplateId: json['form_template_id'] ?? 0,
      name: json['name'] ?? '',
      label: json['label'] ?? '',
      type: json['type'] ?? 'text',
      required: json['required'] == true || json['required'] == 1,
      value: json['value'],
      order: json['order'] ?? 0,
    );
  }

  MapEntry<String, dynamic> toKeyValue() {
    return MapEntry(name, value);
  }
}

// دالة لتحويل القائمة كلها إلى additional_fields
Map<String, dynamic> buildAdditionalFields(List<FormField> fields) {
  return {
    "additional_fields": Map.fromEntries(
      fields.map((f) => f.toKeyValue()),
    )
  };
}

class Team {
  final int id;
  final String name;
  final String? address;
  final String? description;

  Team({
    required this.id,
    required this.name,
    this.address,
    this.description,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      address: json['address'],
      description: json['description'],
    );
  }
}
