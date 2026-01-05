import 'package:equatable/equatable.dart';

enum AuthProvider { email, google }

class AuthUser extends Equatable {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final bool emailVerified;
  final AuthProvider authProvider;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  const AuthUser({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.emailVerified,
    required this.authProvider,
    required this.createdAt,
    this.lastLoginAt,
  });

  AuthUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    bool? emailVerified,
    AuthProvider? authProvider,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return AuthUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      emailVerified: emailVerified ?? this.emailVerified,
      authProvider: authProvider ?? this.authProvider,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  @override
  List<Object?> get props => [
        uid,
        email,
        displayName,
        photoUrl,
        emailVerified,
        authProvider,
        createdAt,
        lastLoginAt,
      ];
}
