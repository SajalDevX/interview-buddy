part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state before auth check
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading state during auth operations
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// User is authenticated
class Authenticated extends AuthState {
  final AuthUser user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// User is not authenticated
class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// Auth error occurred
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Password reset email sent successfully
class PasswordResetSent extends AuthState {
  const PasswordResetSent();
}
