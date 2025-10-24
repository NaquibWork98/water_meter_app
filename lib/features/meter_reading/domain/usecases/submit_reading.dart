import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/reading.dart';
import '../repositories/meter_repository.dart';

class SubmitReading implements UseCase<void, SubmitReadingParams> {
  final MeterRepository repository;

  SubmitReading(this.repository);

  @override
  Future<Either<Failure, void>> call(SubmitReadingParams params) async {
    return await repository.submitReading(params.reading);
  }
}

class SubmitReadingParams {
  final Reading reading;

  SubmitReadingParams({required this.reading});
}