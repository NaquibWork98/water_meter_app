import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/meter.dart';
import '../../domain/entities/reading.dart';
import '../../domain/entities/tenant.dart';
import '../../domain/repositories/meter_repository.dart';
import '../datasources/meter_local_data_source.dart';
import '../datasources/meter_remote_data_source.dart';
import '../models/reading_model.dart';

class MeterRepositoryImpl implements MeterRepository {
  final MeterRemoteDataSource remoteDataSource;
  final MeterLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  MeterRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, Meter>> getMeterByQRCode(String qrCode) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final meterModel = await remoteDataSource.getMeterByQRCode(qrCode);
      return Right(meterModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get meter: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Meter>>> getAllMeters() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final meterModels = await remoteDataSource.getAllMeters();
      final meters = meterModels.map((m) => m.toEntity()).toList();
      return Right(meters);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get meters: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> extractReadingFromImage(String imagePath) async {
    try {
      // TODO: Implement OCR logic here when meters arrive
      // For now, return a mock reading
      await Future.delayed(const Duration(seconds: 2));
      
      // Simulate OCR extraction
      return const Right('12345.67');
      
      // TODO: Real implementation will be:
      // final reading = await ocrService.extractReading(imagePath);
      // return Right(reading);
    } on OCRException catch (e) {
      return Left(OCRFailure(e.message));
    } catch (e) {
      return Left(OCRFailure('Failed to extract reading: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> submitReading(Reading reading) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final readingModel = ReadingModel.fromEntity(reading);
      await remoteDataSource.submitReading(readingModel);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to submit reading: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Reading>>> getReadingHistory(String meterId) async {
    try {
      // Try to get from cache first
      final cachedReadings = await localDataSource.getCachedReadings(meterId);
      
      if (await networkInfo.isConnected) {
        // Get fresh data from server
        final remoteReadings = await remoteDataSource.getReadingHistory(meterId);
        
        // Cache the fresh data
        await localDataSource.cacheReadings(remoteReadings);
        
        return Right(remoteReadings.map((r) => r.toEntity()).toList());
      } else {
        // Return cached data if no internet
        if (cachedReadings.isNotEmpty) {
          return Right(cachedReadings.map((r) => r.toEntity()).toList());
        } else {
          return const Left(NetworkFailure('No internet connection and no cached data'));
        }
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get reading history: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Tenant>>> getAllTenants() async {
    try {
      // Try to get from cache first
      final cachedTenants = await localDataSource.getCachedTenants();
      
      if (await networkInfo.isConnected) {
        // Get fresh data from server
        final remoteTenants = await remoteDataSource.getAllTenants();
        
        // Cache the fresh data
        await localDataSource.cacheTenants(remoteTenants);
        
        return Right(remoteTenants.map((t) => t.toEntity()).toList());
      } else {
        // Return cached data if no internet
        if (cachedTenants.isNotEmpty) {
          return Right(cachedTenants.map((t) => t.toEntity()).toList());
        } else {
          return const Left(NetworkFailure('No internet connection and no cached data'));
        }
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get tenants: $e'));
    }
  }

  @override
  Future<Either<Failure, Tenant>> getTenantById(String tenantId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final tenantModel = await remoteDataSource.getTenantById(tenantId);
      return Right(tenantModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get tenant: $e'));
    }
  }
}