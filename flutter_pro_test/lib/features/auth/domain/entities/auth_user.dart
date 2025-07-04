import 'package:equatable/equatable.dart';

/// Authentication user entity representing the authenticated user
class AuthUser extends Equatable {
  final String uid;
  final String email;
  final String? displayName;
  final String? phoneNumber;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final String? photoURL;
  final DateTime? createdAt;
  final DateTime? lastSignInAt;

  const AuthUser({
    required this.uid,
    required this.email,
    this.displayName,
    this.phoneNumber,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    this.photoURL,
    this.createdAt,
    this.lastSignInAt,
  });

  /// Create an empty/anonymous user
  static const AuthUser empty = AuthUser(uid: '', email: '');

  /// Check if user is empty (not authenticated)
  bool get isEmpty => this == AuthUser.empty;

  /// Check if user is not empty (authenticated)
  bool get isNotEmpty => this != AuthUser.empty;

  /// Check if user has verified contact method
  bool get hasVerifiedContact => isEmailVerified || isPhoneVerified;

  @override
  List<Object?> get props => [
        uid,
        email,
        displayName,
        phoneNumber,
        isEmailVerified,
        isPhoneVerified,
        photoURL,
        createdAt,
        lastSignInAt,
      ];

  /// Create a copy of this user with updated fields
  AuthUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? phoneNumber,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    String? photoURL,
    DateTime? createdAt,
    DateTime? lastSignInAt,
  }) {
    return AuthUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      photoURL: photoURL ?? this.photoURL,
      createdAt: createdAt ?? this.createdAt,
      lastSignInAt: lastSignInAt ?? this.lastSignInAt,
    );
  }

  @override
  String toString() {
    return 'AuthUser(uid: $uid, email: $email, displayName: $displayName, '
        'phoneNumber: $phoneNumber, isEmailVerified: $isEmailVerified, '
        'isPhoneVerified: $isPhoneVerified)';
  }
}
