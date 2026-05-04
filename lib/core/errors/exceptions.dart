/// Thrown when the remote data source returns a non-2xx response.
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({required this.message, this.statusCode});

  @override
  String toString() => 'ServerException(statusCode: $statusCode, message: $message)';
}

/// Thrown when there is no internet connection.
class NetworkException implements Exception {
  final String message;

  const NetworkException({this.message = 'No internet connection.'});

  @override
  String toString() => 'NetworkException(message: $message)';
}

/// Thrown when reading/writing to local cache fails.
class CacheException implements Exception {
  final String message;

  const CacheException({this.message = 'Cache error.'});

  @override
  String toString() => 'CacheException(message: $message)';
}

/// Thrown when the user is not authenticated.
class UnauthorizedException implements Exception {
  final String message;

  const UnauthorizedException({this.message = 'Unauthorized.'});

  @override
  String toString() => 'UnauthorizedException(message: $message)';
}
