import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/extract_reading_ocr.dart';
import '../../domain/usecases/get_all_tenants.dart';
import '../../domain/usecases/get_reading_history.dart';
import '../../domain/usecases/scan_qr_code.dart';
import '../../domain/usecases/submit_reading.dart';
import 'meter_reading_event.dart';
import 'meter_reading_state.dart';

class MeterReadingBloc extends Bloc<MeterReadingEvent, MeterReadingState> {
  final ScanQRCode scanQRCode;
  final ExtractReadingOCR extractReadingOCR;
  final SubmitReading submitReading;
  final GetReadingHistory getReadingHistory;
  final GetAllTenants getAllTenants;

  MeterReadingBloc({
    required this.scanQRCode,
    required this.extractReadingOCR,
    required this.submitReading,
    required this.getReadingHistory,
    required this.getAllTenants,
  }) : super(MeterReadingInitial()) {
    on<QRCodeScanned>(_onQRCodeScanned);
    on<ImageCaptured>(_onImageCaptured);
    on<ReadingManuallyEntered>(_onReadingManuallyEntered);
    on<ReadingConfirmed>(_onReadingConfirmed);
    on<ReadingHistoryRequested>(_onReadingHistoryRequested);
    on<AllTenantsRequested>(_onAllTenantsRequested);
    on<MeterReadingReset>(_onMeterReadingReset);
  }

  Future<void> _onQRCodeScanned(
    QRCodeScanned event,
    Emitter<MeterReadingState> emit,
  ) async {
    emit(const MeterReadingLoading(message: 'Scanning QR code...'));

    final result = await scanQRCode(ScanQRCodeParams(qrCode: event.qrCode));

    result.fold(
      (failure) => emit(MeterReadingError(failure.message)),
      (meter) => emit(MeterLoaded(meter)),
    );
  }

  Future<void> _onImageCaptured(
    ImageCaptured event,
    Emitter<MeterReadingState> emit,
  ) async {
    // Check if we have a meter loaded
    if (state is! MeterLoaded) {
      emit(const MeterReadingError('Please scan QR code first'));
      return;
    }

    final currentMeter = (state as MeterLoaded).meter;
    emit(const MeterReadingLoading(message: 'Extracting reading...'));

    final result = await extractReadingOCR(
      ExtractReadingOCRParams(imagePath: event.imagePath),
    );

    result.fold(
      (failure) => emit(MeterReadingError(failure.message)),
      (reading) => emit(ReadingExtracted(
        meter: currentMeter,
        extractedReading: reading,
        imagePath: event.imagePath,
      )),
    );
  }

  Future<void> _onReadingManuallyEntered(
    ReadingManuallyEntered event,
    Emitter<MeterReadingState> emit,
  ) async {
    // Check if we have a meter loaded
    if (state is! MeterLoaded) {
      emit(const MeterReadingError('Please scan QR code first'));
      return;
    }

    final currentMeter = (state as MeterLoaded).meter;

    // Transition to ReadingExtracted state with manual entry
    emit(ReadingExtracted(
      meter: currentMeter,
      extractedReading: event.reading,
      imagePath: '', // No image for manual entry
    ));
  }

  Future<void> _onReadingConfirmed(
    ReadingConfirmed event,
    Emitter<MeterReadingState> emit,
  ) async {
    emit(const MeterReadingLoading(message: 'Submitting reading...'));

    final result = await submitReading(
      SubmitReadingParams(reading: event.reading),
    );

    result.fold(
      (failure) => emit(MeterReadingError(failure.message)),
      (_) => emit(const ReadingSubmitted()),
    );
  }

  Future<void> _onReadingHistoryRequested(
    ReadingHistoryRequested event,
    Emitter<MeterReadingState> emit,
  ) async {
    emit(const MeterReadingLoading(message: 'Loading history...'));

    final result = await getReadingHistory(
      GetReadingHistoryParams(meterId: event.meterId),
    );

    result.fold(
      (failure) => emit(MeterReadingError(failure.message)),
      (readings) => emit(ReadingHistoryLoaded(
        readings: readings,
        meterId: event.meterId,
      )),
    );
  }

  Future<void> _onAllTenantsRequested(
    AllTenantsRequested event,
    Emitter<MeterReadingState> emit,
  ) async {
    emit(const MeterReadingLoading(message: 'Loading tenants...'));

    final result = await getAllTenants(NoParams());

    result.fold(
      (failure) => emit(MeterReadingError(failure.message)),
      (tenants) => emit(TenantsLoaded(tenants)),
    );
  }

  Future<void> _onMeterReadingReset(
    MeterReadingReset event,
    Emitter<MeterReadingState> emit,
  ) async {
    emit(MeterReadingInitial());
  }
}