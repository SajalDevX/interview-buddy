import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/auth_user.dart';
import '../../../domain/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  StreamSubscription<AuthUser?>? _authSubscription;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthUserChanged>(_onAuthUserChanged);
    on<SignInWithEmailRequested>(_onSignInWithEmail);
    on<SignUpWithEmailRequested>(_onSignUpWithEmail);
    on<SignInWithGoogleRequested>(_onSignInWithGoogle);
    on<SignOutRequested>(_onSignOut);
    on<PasswordResetRequested>(_onPasswordReset);
  }

  void _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) {
    _authSubscription?.cancel();
    _authSubscription = authRepository.authStateChanges.listen(
      (user) => add(AuthUserChanged(user)),
    );
  }

  void _onAuthUserChanged(
    AuthUserChanged event,
    Emitter<AuthState> emit,
  ) {
    if (event.user != null) {
      emit(Authenticated(event.user!));
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onSignInWithEmail(
    SignInWithEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await authRepository.signInWithEmail(
      email: event.email,
      password: event.password,
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> _onSignUpWithEmail(
    SignUpWithEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await authRepository.signUpWithEmail(
      email: event.email,
      password: event.password,
      displayName: event.displayName,
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> _onSignInWithGoogle(
    SignInWithGoogleRequested event,
    Emitter<AuthState> emit,
  ) async {
    developer.log('🔵 [AuthBloc] SignInWithGoogleRequested received');
    emit(AuthLoading());

    try {
      developer.log('🔵 [AuthBloc] Calling authRepository.signInWithGoogle()...');
      final result = await authRepository.signInWithGoogle();
      developer.log('🔵 [AuthBloc] Got result from repository');

      result.fold(
        (failure) {
          developer.log('🔴 [AuthBloc] Sign-in failed: ${failure.message}');
          emit(AuthError(failure.message));
        },
        (user) {
          developer.log('🟢 [AuthBloc] Sign-in successful! User: ${user.email}');
          emit(Authenticated(user));
        },
      );
    } catch (e, stackTrace) {
      developer.log(
        '🔴 [AuthBloc] Unexpected exception in _onSignInWithGoogle',
        error: e,
        stackTrace: stackTrace,
      );
      emit(AuthError('Unexpected error: ${e.runtimeType} - $e'));
    }
  }

  Future<void> _onSignOut(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    await authRepository.signOut();
    emit(Unauthenticated());
  }

  Future<void> _onPasswordReset(
    PasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await authRepository.sendPasswordResetEmail(event.email);

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(PasswordResetSent()),
    );
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
