import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    // Check internet connection
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final userModel = await remoteDataSource.login(email, password);
      
      // Cache user data locally
      await localDataSource.cacheUser(userModel);
      
      return Right(userModel.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      // Get cached user to retrieve token
      final user = await localDataSource.getCachedUser();
      
      // If user has token and internet is available, logout from server
      if (user?.token != null && await networkInfo.isConnected) {
        try {
          await remoteDataSource.logout(user!.token!);
        } catch (e) {
          // Continue with local logout even if server logout fails
        }
      }
      
      // Clear local cache regardless of server logout result
      await localDataSource.clearCache();
      
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to logout: $e'));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final userModel = await localDataSource.getCachedUser();
      return Right(userModel?.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to get current user: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    try {
      final isLoggedIn = await localDataSource.isLoggedIn();
      return Right(isLoggedIn);
    } catch (e) {
      return const Right(false);
    }
  }
}