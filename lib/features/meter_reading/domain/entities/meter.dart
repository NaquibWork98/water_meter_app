import 'package:equatable/equatable.dart';

class Meter extends Equatable {
  final String id;
  final String qrCode;
  final String location;
  final String tenantId;
  final String tenantName;
  final String? tenantEmail;
  final String? lastReading;
  final DateTime? lastReadingDate;

  const Meter({
    required this.id,
    required this.qrCode,
    required this.location,
    required this.tenantId,
    required this.tenantName,
    this.tenantEmail,
    this.lastReading,
    this.lastReadingDate,
  });

  @override
  List<Object?> get props => [
        id,
        qrCode,
        location,
        tenantId,
        tenantName,
        tenantEmail,
        lastReading,
        lastReadingDate,
      ];
}