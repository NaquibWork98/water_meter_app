import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/meter.dart';
import '../repositories/meter_repository.dart';

class ScanQRCode implements UseCase<Meter, ScanQRCodeParams> {
  final MeterRepository repository;

  ScanQRCode(this.repository);

  @override
  Future<Either<Failure, Meter>> call(ScanQRCodeParams params) async {
    return await repository.getMeterByQRCode(params.qrCode);
  }
}

class ScanQRCodeParams {
  final String qrCode;

  ScanQRCodeParams({required this.qrCode});
}