import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/reading.dart';
import '../repositories/meter_repository.dart';

class GetReadingHistory implements UseCase<List<Reading>, GetReadingHistoryParams> {
  final MeterRepository repository;

  GetReadingHistory(this.repository);

  @override
  Future<Either<Failure, List<Reading>>> call(GetReadingHistoryParams params) async {
    return await repository.getReadingHistory(params.meterId);
  }
}

class GetReadingHistoryParams {
  final String meterId;

  GetReadingHistoryParams({required this.meterId});
}