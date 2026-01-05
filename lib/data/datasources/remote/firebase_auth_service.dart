import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../domain/entities/auth_user.dart' as domain;

class FirebaseAuthService {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthService({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(
          scopes: ['email', 'profile'],
        );

  /// Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Get current Firebase user
  User? get currentUser => _auth.currentUser;

  /// Check if user is signed in
  bool get isSignedIn => currentUser != null;

  /// Get current user ID
  String? get currentUserId => currentUser?.uid;

  /// Sign up with email and password
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Sign in with email and password
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Sign in with Google
  /// Returns the current user if sign-in succeeds (workaround for Pigeon bug)
  Future<User> signInWithGoogle() async {
    developer.log('🔵 [GoogleSignIn] Starting Google Sign-In process...');

    developer.log('🔵 [GoogleSignIn] Calling _googleSignIn.signIn()...');
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser == null) {
      developer.log('🟡 [GoogleSignIn] User cancelled sign-in');
      throw FirebaseAuthException(
        code: 'sign-in-cancelled',
        message: 'Google sign-in was cancelled',
      );
    }

    developer.log('🟢 [GoogleSignIn] Got Google user: ${googleUser.email}');
    developer.log('🔵 [GoogleSignIn] Getting authentication tokens...');

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    developer.log('🟢 [GoogleSignIn] Got auth tokens - accessToken: ${googleAuth.accessToken != null}, idToken: ${googleAuth.idToken != null}');

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    developer.log('🔵 [GoogleSignIn] Signing in with Firebase credential...');

    try {
      final userCredential = await _auth.signInWithCredential(credential);
      developer.log('🟢 [GoogleSignIn] Firebase sign-in successful! User: ${userCredential.user?.email}');
      return userCredential.user!;
    } catch (e) {
      // Workaround for Pigeon bug: sign-in succeeds but parsing fails
      // Check if user is actually signed in
      developer.log('🟡 [GoogleSignIn] Pigeon parsing error, checking if user is signed in...');

      // Give Firebase a moment to update auth state
      await Future.delayed(const Duration(milliseconds: 100));

      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        developer.log('🟢 [GoogleSignIn] User IS signed in despite error! User: ${currentUser.email}');
        return currentUser;
      }

      developer.log('🔴 [GoogleSignIn] User is NOT signed in, rethrowing error');
      rethrow;
    }
  }

  /// Sign out from both Firebase and Google
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  /// Send email verification to current user
  Future<void> sendEmailVerification() async {
    await currentUser?.sendEmailVerification();
  }

  /// Update user display name
  Future<void> updateDisplayName(String displayName) async {
    await currentUser?.updateDisplayName(displayName);
  }

  /// Update user photo URL
  Future<void> updatePhotoUrl(String photoUrl) async {
    await currentUser?.updatePhotoURL(photoUrl);
  }

  /// Update user profile
  Future<void> updateProfile({String? displayName, String? photoUrl}) async {
    if (displayName != null) {
      await currentUser?.updateDisplayName(displayName);
    }
    if (photoUrl != null) {
      await currentUser?.updatePhotoURL(photoUrl);
    }
  }

  /// Delete current user account
  Future<void> deleteAccount() async {
    await currentUser?.delete();
  }

  /// Reload current user data
  Future<void> reloadUser() async {
    await currentUser?.reload();
  }

  /// Map Firebase User to AuthUser entity
  domain.AuthUser? mapFirebaseUserToAuthUser(User? user) {
    if (user == null) return null;

    final providerData = user.providerData;
    final isGoogle = providerData.any((p) => p.providerId == 'google.com');

    return domain.AuthUser(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
      emailVerified: user.emailVerified,
      authProvider: isGoogle ? domain.AuthProvider.google : domain.AuthProvider.email,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
      lastLoginAt: user.metadata.lastSignInTime,
    );
  }
}
