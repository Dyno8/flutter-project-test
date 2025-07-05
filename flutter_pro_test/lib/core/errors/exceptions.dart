/// Base exception class for the application
abstract class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

/// Exception thrown when there's a server error
class ServerException extends AppException {
  const ServerException(super.message);
}

/// Exception thrown when there's a cache error
class CacheException extends AppException {
  const CacheException(super.message);
}

/// Exception thrown when there's a network error
class NetworkException extends AppException {
  const NetworkException(super.message);
}

/// Exception thrown when authentication fails
class AuthException extends AppException {
  const AuthException(super.message);
}

/// Exception thrown when validation fails
class ValidationException extends AppException {
  const ValidationException(super.message);
}

/// Exception thrown when a resource is not found
class NotFoundException extends AppException {
  const NotFoundException(super.message);
}

/// Exception thrown when access is forbidden
class ForbiddenException extends AppException {
  const ForbiddenException(super.message);
}

/// Exception thrown when there's a timeout
class TimeoutException extends AppException {
  const TimeoutException(super.message);
}
