import '../../domain/entities/tenant.dart';

class TenantModel extends Tenant {
  const TenantModel({
    required super.id,
    required super.name,
    required super.email,
    required super.location,
    super.phoneNumber,
    super.meterId,
  });

  factory TenantModel.fromJson(Map<String, dynamic> json) {
    return TenantModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      location: json['location'] as String,
      phoneNumber: json['phone_number'] as String?,
      meterId: json['meter_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'location': location,
      'phone_number': phoneNumber,
      'meter_id': meterId,
    };
  }

  Tenant toEntity() {
    return Tenant(
      id: id,
      name: name,
      email: email,
      location: location,
      phoneNumber: phoneNumber,
      meterId: meterId,
    );
  }
}