import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/tenant.dart';
import '../repositories/meter_repository.dart';

class GetAllTenants implements UseCase<List<Tenant>, NoParams> {
  final MeterRepository repository;

  GetAllTenants(this.repository);

  @override
  Future<Either<Failure, List<Tenant>>> call(NoParams params) async {
    return await repository.getAllTenants();
  }
}