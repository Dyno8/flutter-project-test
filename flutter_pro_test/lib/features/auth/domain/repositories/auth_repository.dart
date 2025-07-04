import 'package:dartz/dartz.dart';

import '../entities/auth_user.dart';
import '../../../../core/errors/failures.dart';

/// Abstract repository interface for authentication operations
abstract class AuthRepository {
  /// Stream of authentication state changes
  Stream<AuthUser> get authStateChanges;

  /// Get current authenticated user
  AuthUser get currentUser;

  /// Sign in with email and password
  Future<Either<Failure, AuthUser>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Sign up with email and password
  Future<Either<Failure, AuthUser>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  });

  /// Sign in with phone number (send OTP)
  Future<Either<Failure, String>> signInWithPhoneNumber({
    required String phoneNumber,
  });

  /// Verify phone number with OTP code
  Future<Either<Failure, AuthUser>> verifyPhoneNumber({
    required String verificationId,
    required String smsCode,
  });

  /// Send email verification
  Future<Either<Failure, void>> sendEmailVerification();

  /// Send password reset email
  Future<Either<Failure, void>> sendPasswordResetEmail({required String email});

  /// Update user profile
  Future<Either<Failure, void>> updateProfile({
    String? displayName,
    String? photoURL,
  });

  /// Update user email
  Future<Either<Failure, void>> updateEmail({required String newEmail});

  /// Update user password
  Future<Either<Failure, void>> updatePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Re-authenticate user with password
  Future<Either<Failure, void>> reauthenticateWithPassword({
    required String password,
  });

  /// Sign out current user
  Future<Either<Failure, void>> signOut();

  /// Delete user account
  Future<Either<Failure, void>> deleteAccount();

  /// Check if email is already in use
  Future<Either<Failure, bool>> isEmailInUse({required String email});

  /// Refresh current user data
  Future<Either<Failure, AuthUser>> refreshUser();
}
