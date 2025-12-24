class ServerException implements Exception {
  final String message;
  final int? statusCode;

  ServerException({required this.message, this.statusCode});

  @override
  String toString() => 'ServerException: $message (Code: $statusCode)';
}

class CacheException implements Exception {
  final String message;

  CacheException({this.message = 'Cache operation failed'});

  @override
  String toString() => 'CacheException: $message';
}

class NetworkException implements Exception {
  final String message;

  NetworkException({this.message = 'Network connection failed'});

  @override
  String toString() => 'NetworkException: $message';
}

class AudioException implements Exception {
  final String message;

  AudioException({required this.message});

  @override
  String toString() => 'AudioException: $message';
}

class OCRException implements Exception {
  final String message;

  OCRException({required this.message});

  @override
  String toString() => 'OCRException: $message';
}

class AuthException implements Exception {
  final String message;

  AuthException({this.message = 'Authentication failed'});

  @override
  String toString() => 'AuthException: $message';
}

class RateLimitException implements Exception {
  final String message;
  final Duration? retryAfter;

  RateLimitException({
    this.message = 'Rate limit exceeded',
    this.retryAfter,
  });

  @override
  String toString() => 'RateLimitException: $message';
}
