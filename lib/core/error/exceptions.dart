class ServerException implements Exception {
  final String message;
  ServerException(this.message);
}

class CacheException implements Exception {
  final String message;
  CacheException(this.message);
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
}

class OCRException implements Exception {
  final String message;
  OCRException(this.message);

  @override
  String toString() => 'OCRException: $message';
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
}

class CameraException implements Exception {
  final String message;
  CameraException(this.message);
}