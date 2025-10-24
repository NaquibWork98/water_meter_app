import '../../domain/entities/meter.dart';

class MeterModel extends Meter {
  const MeterModel({
    required super.id,
    required super.qrCode,
    required super.location,
    required super.tenantId,
    required super.tenantName,
    super.tenantEmail,
    super.lastReading,
    super.lastReadingDate,
  });

  factory MeterModel.fromJson(Map<String, dynamic> json) {
    return MeterModel(
      id: json['id'] as String,
      qrCode: json['qr_code'] as String,
      location: json['location'] as String,
      tenantId: json['tenant_id'] as String,
      tenantName: json['tenant_name'] as String,
      tenantEmail: json['tenant_email'] as String?,
      lastReading: json['last_reading'] as String?,
      lastReadingDate: json['last_reading_date'] != null
          ? DateTime.parse(json['last_reading_date'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'qr_code': qrCode,
      'location': location,
      'tenant_id': tenantId,
      'tenant_name': tenantName,
      'tenant_email': tenantEmail,
      'last_reading': lastReading,
      'last_reading_date': lastReadingDate?.toIso8601String(),
    };
  }

  Meter toEntity() {
    return Meter(
      id: id,
      qrCode: qrCode,
      location: location,
      tenantId: tenantId,
      tenantName: tenantName,
      tenantEmail: tenantEmail,
      lastReading: lastReading,
      lastReadingDate: lastReadingDate,
    );
  }
}