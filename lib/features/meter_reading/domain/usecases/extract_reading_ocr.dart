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
      return const Left(OCRFailure('Image file does not exist'));
    }

    // Check if file is an image
    final extension = params.imagePath.toLowerCase();
    if (!extension.endsWith('.jpg') && 
        !extension.endsWith('.jpeg') && 
        !extension.endsWith('.png')) {
      return const Left(OCRFailure('File must be an image (jpg, jpeg, or png)'));
    }

    // Check file size (max 10MB)
    final fileSize = await file.length();
    const maxSize = 10 * 1024 * 1024; // 10MB
    if (fileSize > maxSize) {
      return const Left(OCRFailure('Image file is too large (max 10MB)'));
    }

    // Check file size (min 10KB)
    const minSize = 10 * 1024; // 10KB
    if (fileSize < minSize) {
      return const Left(OCRFailure('Image file is too small (min 10KB)'));
    }

    // Extract reading from repository
    final result = await repository.extractReadingFromImage(params.imagePath);

    // Validate the extracted reading content
    return result.fold(
      (failure) => Left(failure),
      (reading) {
        // Validate the extracted reading
        final validationError = _validateReading(
          reading,
          location: params.location,
        );
        
        if (validationError != null) {
          return Left(ValidationFailure(validationError));
        }
        
        // All validations passed
        return Right(reading);
      },
    );
  }

  // Enhanced validation method with location context
  String? _validateReading(
    String reading, {
    String? location,

  }) {
    // Check if empty
    if (reading.isEmpty) {
      return 'No reading could be extracted from the image';
    }

    // Remove any whitespace
    final cleanReading = reading.replaceAll(RegExp(r'\s+'), '');

    // Check if contains any letters
    if (RegExp(r'[a-zA-Z]').hasMatch(cleanReading)) {
      return 'Reading contains letters: "$reading". Only numbers allowed.';
    }

    // Check if contains decimal point
    if (cleanReading.contains('.')) {
      return 'Reading contains decimal point. Only whole numbers allowed.';
    }

    // Check if it's a valid number (will only be digits now)
    final value = int.tryParse(cleanReading);
    if (value == null) {
      return 'Invalid reading format: "$reading"';
    }

    // Check reasonable length (4-8 digits)
    if (cleanReading.length < 4) {
      return 'Reading too short (minimum 4 digits)';
    }

    if (cleanReading.length > 8) {
      return 'Reading too long (maximum 8 digits)';
    }

    // Check reasonable value range for water meter (0 - 999,999)
    if (value > 999999) {
      return 'Reading value too high (maximum 999,999)';
    }

    // All validations passed
    return null;
  }
} 

class ExtractReadingOCRParams {
  final String imagePath;
  final String? location;   

  ExtractReadingOCRParams({
    required this.imagePath,
    this.location,
  
  });
}