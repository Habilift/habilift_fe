// Emergency Contact Model
class EmergencyContactModel {
  final String id;
  final String name;
  final String phone;
  final String? description;
  final String? country;
  final String? region;
  final String? contactType;
  final bool is247;
  final String? operatingHours;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  EmergencyContactModel({
    required this.id,
    required this.name,
    required this.phone,
    this.description,
    this.country,
    this.region,
    this.contactType,
    this.is247 = false,
    this.operatingHours,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EmergencyContactModel.fromJson(Map<String, dynamic> json) {
    return EmergencyContactModel(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      description: json['description'] as String?,
      country: json['country'] as String?,
      region: json['region'] as String?,
      contactType: json['contact_type'] as String?,
      is247: json['is_24_7'] as bool? ?? false,
      operatingHours: json['operating_hours'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'description': description,
      'country': country,
      'region': region,
      'contact_type': contactType,
      'is_24_7': is247,
      'operating_hours': operatingHours,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
