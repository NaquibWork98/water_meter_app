import 'package:equatable/equatable.dart';
import '../../domain/entities/reading.dart';

abstract class MeterReadingEvent extends Equatable {
  const MeterReadingEvent();

  @override
  List<Object?> get props => [];
}

// QR Code Events
class QRCodeScanned extends MeterReadingEvent {
  final String qrCode;

  const QRCodeScanned(this.qrCode);

  @override
  List<Object> get props => [qrCode];
}

// Image/Camera Events
class ImageCaptured extends MeterReadingEvent {
  final String imagePath;

  const ImageCaptured(this.imagePath);

  @override
  List<Object> get props => [imagePath];
}

// Reading Events
class ReadingManuallyEntered extends MeterReadingEvent {
  final String reading;

  const ReadingManuallyEntered(this.reading);

  @override
  List<Object> get props => [reading];
}

class ReadingConfirmed extends MeterReadingEvent {
  final Reading reading;

  const ReadingConfirmed(this.reading);

  @override
  List<Object> get props => [reading];
}

class ReadingHistoryRequested extends MeterReadingEvent {
  final String meterId;

  const ReadingHistoryRequested(this.meterId);

  @override
  List<Object> get props => [meterId];
}

// Tenant Events
class AllTenantsRequested extends MeterReadingEvent {}

class TenantDetailsRequested extends MeterReadingEvent {
  final String tenantId;

  const TenantDetailsRequested(this.tenantId);

  @override
  List<Object> get props => [tenantId];
}

// Reset Event
class MeterReadingReset extends MeterReadingEvent {}