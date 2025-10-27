import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/meter_repository.dart';

class ExtractReadingOCR implements UseCase<String, ExtractReadingOCRParams> {
  final MeterRepository repository;

  ExtractReadingOCR(this.repository);

  @override
  Future<Either<Failure, String>> call(ExtractReadingOCRParams params) async {
    // Validate image path exists
    final file = File(params.imagePath);
    if (!file.existsSync()) {
      return Left(OCRFailure('Image file does not exist'));
    }

    // Check if file is an image
    final extension = params.imagePath.toLowerCase();
    if (!extension.endsWith('.jpg') && 
        !extension.endsWith('.jpeg') && 
        !extension.endsWith('.png')) {
      return Left(OCRFailure('File must be an image (jpg, jpeg, or png)'));
    }

    // Check file size (max 10MB)
    final fileSize = await file.length();
    const maxSize = 10 * 1024 * 1024; // 10MB
    if (fileSize > maxSize) {
      return Left(OCRFailure('Image file is too large (max 10MB)'));
    }

    // Check file size (min 10KB)
    const minSize = 10 * 1024; // 10KB
    if (fileSize < minSize) {
      return Left(OCRFailure('Image file is too small (min 10KB)'));
    }

    // All validations passed, extract reading
    return await repository.extractReadingFromImage(params.imagePath);
  }
}

class ExtractReadingOCRParams {
  final String imagePath;

  ExtractReadingOCRParams({required this.imagePath});
}