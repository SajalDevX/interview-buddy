import '../entities/auth_user.dart';
import '../../core/utils/either.dart';
import '../../core/errors/failures.dart';

abstract class AuthRepository {
  /// Stream of auth state changes
  Stream<AuthUser?> get authStateChanges;

  /// Get current user
  Future<Either<Failure, AuthUser?>> getCurrentUser();

  /// Sign up with email and password
  Future<Either<Failure, AuthUser>> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  });

  /// Sign in with email and password
  Future<Either<Failure, AuthUser>> signInWithEmail({
    required String email,
    required String password,
  });

  /// Sign in with Google
  Future<Either<Failure, AuthUser>> signInWithGoogle();

  /// Sign out
  Future<Either<Failure, void>> signOut();

  /// Send password reset email
  Future<Either<Failure, void>> sendPasswordResetEmail(String email);

  /// Send email verification
  Future<Either<Failure, void>> sendEmailVerification();

  /// Update user profile
  Future<Either<Failure, void>> updateProfile({
    String? displayName,
    String? photoUrl,
  });

  /// Delete account
  Future<Either<Failure, void>> deleteAccount();

  /// Check if user is signed in
  bool get isSignedIn;

  /// Get current user ID
  String? get currentUserId;
}
