import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/utils/either.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote/firebase_auth_service.dart';
import '../datasources/remote/firestore_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthService authService;
  final FirestoreService firestoreService;

  AuthRepositoryImpl({
    required this.authService,
    required this.firestoreService,
  });

  @override
  Stream<AuthUser?> get authStateChanges =>
      authService.authStateChanges.map(authService.mapFirebaseUserToAuthUser);

  @override
  bool get isSignedIn => authService.isSignedIn;

  @override
  String? get currentUserId => authService.currentUserId;

  @override
  Future<Either<Failure, AuthUser?>> getCurrentUser() async {
    try {
      final user =
          authService.mapFirebaseUserToAuthUser(authService.currentUser);
      return Right(user);
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthUser>> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await authService.signUpWithEmail(
        email: email,
        password: password,
      );

      if (displayName != null) {
        await authService.updateDisplayName(displayName);
      }

      // Create user profile in Firestore
      await firestoreService.createUserProfile(credential.user!.uid, {
        'email': email,
        'displayName': displayName,
        'createdAt': DateTime.now().toIso8601String(),
        'authProvider': 'email',
      });

      // Reload user to get updated data
      await authService.reloadUser();

      final authUser =
          authService.mapFirebaseUserToAuthUser(authService.currentUser);
      if (authUser == null) {
        return const Left(AuthFailure(message: 'Failed to create user'));
      }

      return Right(authUser);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(message: _mapFirebaseAuthError(e.code)));
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthUser>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await authService.signInWithEmail(
        email: email,
        password: password,
      );

      final authUser =
          authService.mapFirebaseUserToAuthUser(credential.user);
      if (authUser == null) {
        return const Left(AuthFailure(message: 'Failed to sign in'));
      }

      return Right(authUser);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(message: _mapFirebaseAuthError(e.code)));
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthUser>> signInWithGoogle() async {
    developer.log('🔵 [AuthRepo] signInWithGoogle called');
    try {
      developer.log('🔵 [AuthRepo] Calling authService.signInWithGoogle()...');
      final user = await authService.signInWithGoogle();
      developer.log('🟢 [AuthRepo] Got user from authService: ${user.email}');

      // Try to create Firestore profile but don't block sign-in if it fails
      try {
        final profileExists = await firestoreService.userProfileExists(user.uid);
        if (!profileExists) {
          developer.log('🔵 [AuthRepo] Creating Firestore profile...');
          await firestoreService.createUserProfile(user.uid, {
            'email': user.email,
            'displayName': user.displayName,
            'photoUrl': user.photoURL,
            'createdAt': DateTime.now().toIso8601String(),
            'authProvider': 'google',
          });
          developer.log('🟢 [AuthRepo] Firestore profile created');
        }
      } catch (firestoreError) {
        developer.log('🟡 [AuthRepo] Firestore profile operation failed (non-blocking): $firestoreError');
      }

      final authUser = authService.mapFirebaseUserToAuthUser(user);
      if (authUser == null) {
        developer.log('🔴 [AuthRepo] Failed to map Firebase user to AuthUser');
        return const Left(
            AuthFailure(message: 'Failed to sign in with Google'));
      }

      developer.log('🟢 [AuthRepo] Google sign-in complete! User: ${authUser.email}');
      return Right(authUser);
    } on FirebaseAuthException catch (e, stackTrace) {
      developer.log(
        '🔴 [AuthRepo] FirebaseAuthException',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(AuthFailure(message: _mapFirebaseAuthError(e.code)));
    } catch (e, stackTrace) {
      developer.log(
        '🔴 [AuthRepo] Unexpected error in signInWithGoogle',
        error: e,
        stackTrace: stackTrace,
      );
      developer.log('🔴 [AuthRepo] Error type: ${e.runtimeType}');
      developer.log('🔴 [AuthRepo] Error toString: $e');
      return Left(AuthFailure(message: 'Google Sign-In failed: ${e.runtimeType} - $e'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await authService.signOut();
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    try {
      await authService.sendPasswordResetEmail(email);
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(message: _mapFirebaseAuthError(e.code)));
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendEmailVerification() async {
    try {
      await authService.sendEmailVerification();
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      await authService.updateProfile(
        displayName: displayName,
        photoUrl: photoUrl,
      );

      // Update Firestore profile too
      final uid = authService.currentUserId;
      if (uid != null) {
        await firestoreService.updateUserProfile(uid, {
          if (displayName != null) 'displayName': displayName,
          if (photoUrl != null) 'photoUrl': photoUrl,
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }

      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      final uid = authService.currentUserId;
      if (uid != null) {
        // Delete all user data from Firestore first
        await firestoreService.deleteAllUserData(uid);
      }
      await authService.deleteAccount();
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  String _mapFirebaseAuthError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered';
      case 'invalid-email':
        return 'Invalid email address';
      case 'weak-password':
        return 'Password is too weak (minimum 6 characters)';
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'invalid-credential':
        return 'Invalid email or password';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled';
      case 'sign-in-cancelled':
        return 'Sign-in was cancelled';
      case 'network-request-failed':
        return 'Network error. Please check your connection';
      default:
        return 'Authentication failed: $code';
    }
  }
}
