part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Check authentication status on app start
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Auth state changed (from Firebase listener)
class AuthUserChanged extends AuthEvent {
  final AuthUser? user;

  const AuthUserChanged(this.user);

  @override
  List<Object?> get props => [user];
}

/// Sign in with email and password
class SignInWithEmailRequested extends AuthEvent {
  final String email;
  final String password;

  const SignInWithEmailRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// Sign up with email and password
class SignUpWithEmailRequested extends AuthEvent {
  final String email;
  final String password;
  final String? displayName;

  const SignUpWithEmailRequested({
    required this.email,
    required this.password,
    this.displayName,
  });

  @override
  List<Object?> get props => [email, password, displayName];
}

/// Sign in with Google
class SignInWithGoogleRequested extends AuthEvent {
  const SignInWithGoogleRequested();
}

/// Sign out
class SignOutRequested extends AuthEvent {
  const SignOutRequested();
}

/// Request password reset
class PasswordResetRequested extends AuthEvent {
  final String email;

  const PasswordResetRequested(this.email);

  @override
  List<Object?> get props => [email];
}
