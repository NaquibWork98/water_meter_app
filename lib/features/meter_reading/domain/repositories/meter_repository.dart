import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/meter.dart';
import '../entities/reading.dart';
import '../entities/tenant.dart';

abstract class MeterRepository {
  // Meter operations
  Future<Either<Failure, Meter>> getMeterByQRCode(String qrCode);
  Future<Either<Failure, List<Meter>>> getAllMeters();
  
  // Reading operations
  Future<Either<Failure, String>> extractReadingFromImage(String imagePath);
  Future<Either<Failure, void>> submitReading(Reading reading);
  Future<Either<Failure, List<Reading>>> getReadingHistory(String meterId);
  
  // Tenant operations
  Future<Either<Failure, List<Tenant>>> getAllTenants();
  Future<Either<Failure, Tenant>> getTenantById(String tenantId);
}