import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final int? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.code});
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection. Please check your network.',
    super.code,
  });
}

class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Failed to access local storage.',
    super.code,
  });
}

class AuthFailure extends Failure {
  const AuthFailure({
    super.message = 'Authentication failed. Please check your API key.',
    super.code = 401,
  });
}

class RateLimitFailure extends Failure {
  const RateLimitFailure({
    super.message = 'Rate limit exceeded. Please wait a moment.',
    super.code = 429,
  });
}

class AudioFailure extends Failure {
  const AudioFailure({required super.message, super.code});
}

class OCRFailure extends Failure {
  const OCRFailure({
    super.message = 'Failed to extract text from document.',
    super.code,
  });
}

class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, super.code});
}

class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'An unexpected error occurred.',
    super.code,
  });
}
