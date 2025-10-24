import 'package:equatable/equatable.dart';
import '../../domain/entities/meter.dart';
import '../../domain/entities/reading.dart';
import '../../domain/entities/tenant.dart';

abstract class MeterReadingState extends Equatable {
  const MeterReadingState();

  @override
  List<Object?> get props => [];
}

// Initial State
class MeterReadingInitial extends MeterReadingState {}

// Loading State
class MeterReadingLoading extends MeterReadingState {
  final String? message;

  const MeterReadingLoading({this.message});

  @override
  List<Object?> get props => [message];
}

// Meter Loaded (after QR scan)
class MeterLoaded extends MeterReadingState {
  final Meter meter;

  const MeterLoaded(this.meter);

  @override
  List<Object> get props => [meter];
}

// Reading Extracted (after OCR)
class ReadingExtracted extends MeterReadingState {
  final Meter meter;
  final String extractedReading;
  final String imagePath;

  const ReadingExtracted({
    required this.meter,
    required this.extractedReading,
    required this.imagePath,
  });

  @override
  List<Object> get props => [meter, extractedReading, imagePath];
}

// Reading Submitted Successfully
class ReadingSubmitted extends MeterReadingState {
  final String message;

  const ReadingSubmitted({this.message = 'Reading submitted successfully'});

  @override
  List<Object> get props => [message];
}

// Reading History Loaded
class ReadingHistoryLoaded extends MeterReadingState {
  final List<Reading> readings;
  final String meterId;

  const ReadingHistoryLoaded({
    required this.readings,
    required this.meterId,
  });

  @override
  List<Object> get props => [readings, meterId];
}

// Tenants Loaded
class TenantsLoaded extends MeterReadingState {
  final List<Tenant> tenants;

  const TenantsLoaded(this.tenants);

  @override
  List<Object> get props => [tenants];
}

// Tenant Details Loaded
class TenantDetailsLoaded extends MeterReadingState {
  final Tenant tenant;

  const TenantDetailsLoaded(this.tenant);

  @override
  List<Object> get props => [tenant];
}

// Error State
class MeterReadingError extends MeterReadingState {
  final String message;

  const MeterReadingError(this.message);

  @override
  List<Object> get props => [message];
}