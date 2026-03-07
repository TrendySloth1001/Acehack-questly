/// Custom app exception.
class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException(this.message, [this.statusCode]);

  @override
  String toString() => 'AppException($statusCode): $message';
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'Network error']);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([String message = 'Unauthorized'])
    : super(message, 401);
}

class ServerException extends AppException {
  const ServerException([String message = 'Server error'])
    : super(message, 500);
}
