import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  
  const Failure(this.message);
  
  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class OCRFailure extends Failure {
  const OCRFailure([super.message = 'Failed to extract reading from image']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Validation failed']);
}

class CameraFailure extends Failure {
  const CameraFailure(super.message);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}