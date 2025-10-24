import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/meter_repository.dart';

class ExtractReadingOCR implements UseCase<String, ExtractReadingOCRParams> {
  final MeterRepository repository;

  ExtractReadingOCR(this.repository);

  @override
  Future<Either<Failure, String>> call(ExtractReadingOCRParams params) async {
    return await repository.extractReadingFromImage(params.imagePath);
  }
}

class ExtractReadingOCRParams {
  final String imagePath;

  ExtractReadingOCRParams({required this.imagePath});
}