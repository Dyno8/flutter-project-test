import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/auth_user.dart';

/// Abstract interface for Firebase authentication data source
abstract class FirebaseAuthDataSource {
  Stream<AuthUser> get authStateChanges;
  AuthUser get currentUser;

  Future<Either<Failure, AuthUser>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<Either<Failure, AuthUser>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  });

  Future<Either<Failure, String>> signInWithPhoneNumber({
    required String phoneNumber,
  });

  Future<Either<Failure, AuthUser>> verifyPhoneNumber({
    required String verificationId,
    required String smsCode,
  });

  Future<Either<Failure, void>> sendEmailVerification();
  Future<Either<Failure, void>> sendPasswordResetEmail({required String email});
  Future<Either<Failure, void>> updateProfile({
    String? displayName,
    String? photoURL,
  });
  Future<Either<Failure, void>> updateEmail({required String newEmail});
  Future<Either<Failure, void>> updatePassword({
    required String currentPassword,
    required String newPassword,
  });
  Future<Either<Failure, void>> reauthenticateWithPassword({
    required String password,
  });
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, void>> deleteAccount();
  Future<Either<Failure, bool>> isEmailInUse({required String email});
  Future<Either<Failure, AuthUser>> refreshUser();
}

/// Implementation of Firebase authentication data source
class FirebaseAuthDataSourceImpl implements FirebaseAuthDataSource {
  final FirebaseAuth _firebaseAuth;

  FirebaseAuthDataSourceImpl({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  @override
  Stream<AuthUser> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((user) {
      return user != null ? _mapFirebaseUserToAuthUser(user) : AuthUser.empty;
    });
  }

  @override
  AuthUser get currentUser {
    final user = _firebaseAuth.currentUser;
    return user != null ? _mapFirebaseUserToAuthUser(user) : AuthUser.empty;
  }

  @override
  Future<Either<Failure, AuthUser>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        return const Left(AuthFailure('Sign in failed: No user returned'));
      }

      return Right(_mapFirebaseUserToAuthUser(credential.user!));
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseAuthError(e)));
    } catch (e) {
      return Left(AuthFailure('Unexpected error during sign in: $e'));
    }
  }

  @override
  Future<Either<Failure, AuthUser>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        return const Left(AuthFailure('Sign up failed: No user returned'));
      }

      // Update display name
      await credential.user!.updateDisplayName(displayName);
      await credential.user!.reload();

      final updatedUser = _firebaseAuth.currentUser;
      if (updatedUser == null) {
        return const Left(AuthFailure('Failed to get updated user'));
      }

      return Right(_mapFirebaseUserToAuthUser(updatedUser));
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseAuthError(e)));
    } catch (e) {
      return Left(AuthFailure('Unexpected error during sign up: $e'));
    }
  }

  String? _verificationId;

  @override
  Future<Either<Failure, String>> signInWithPhoneNumber({
    required String phoneNumber,
  }) async {
    try {
      final completer = Completer<Either<Failure, String>>();

      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification completed (Android only)
          try {
            final userCredential = await _firebaseAuth.signInWithCredential(
              credential,
            );
            if (userCredential.user != null) {
              completer.complete(const Right('auto-verified'));
            } else {
              completer.complete(
                const Left(AuthFailure('Auto-verification failed')),
              );
            }
          } catch (e) {
            completer.complete(
              Left(AuthFailure('Auto-verification error: $e')),
            );
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          completer.complete(Left(AuthFailure(_mapFirebaseAuthError(e))));
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          completer.complete(Right(verificationId));
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
          if (!completer.isCompleted) {
            completer.complete(Right(verificationId));
          }
        },
        timeout: const Duration(seconds: 60),
      );

      return await completer.future;
    } catch (e) {
      return Left(AuthFailure('Phone verification error: $e'));
    }
  }

  @override
  Future<Either<Failure, AuthUser>> verifyPhoneNumber({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      if (userCredential.user == null) {
        return const Left(
          AuthFailure('Phone verification failed: No user returned'),
        );
      }

      return Right(_mapFirebaseUserToAuthUser(userCredential.user!));
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseAuthError(e)));
    } catch (e) {
      return Left(AuthFailure('Phone verification error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return const Left(AuthFailure('No user signed in'));
      }

      await user.sendEmailVerification();
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseAuthError(e)));
    } catch (e) {
      return Left(AuthFailure('Email verification error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseAuthError(e)));
    } catch (e) {
      return Left(AuthFailure('Password reset error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return const Left(AuthFailure('No user signed in'));
      }

      await user.updateDisplayName(displayName);
      if (photoURL != null) {
        await user.updatePhotoURL(photoURL);
      }
      await user.reload();

      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseAuthError(e)));
    } catch (e) {
      return Left(AuthFailure('Profile update error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateEmail({required String newEmail}) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return const Left(AuthFailure('No user signed in'));
      }

      await user.updateEmail(newEmail);
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseAuthError(e)));
    } catch (e) {
      return Left(AuthFailure('Email update error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return const Left(AuthFailure('No user signed in'));
      }

      // Re-authenticate first
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseAuthError(e)));
    } catch (e) {
      return Left(AuthFailure('Password update error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> reauthenticateWithPassword({
    required String password,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return const Left(AuthFailure('No user signed in'));
      }

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);

      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseAuthError(e)));
    } catch (e) {
      return Left(AuthFailure('Re-authentication error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _firebaseAuth.signOut();
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure('Sign out error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return const Left(AuthFailure('No user signed in'));
      }

      await user.delete();
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseAuthError(e)));
    } catch (e) {
      return Left(AuthFailure('Account deletion error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isEmailInUse({required String email}) async {
    try {
      final methods = await _firebaseAuth.fetchSignInMethodsForEmail(email);
      return Right(methods.isNotEmpty);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseAuthError(e)));
    } catch (e) {
      return Left(AuthFailure('Email check error: $e'));
    }
  }

  @override
  Future<Either<Failure, AuthUser>> refreshUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return const Left(AuthFailure('No user signed in'));
      }

      await user.reload();
      final refreshedUser = _firebaseAuth.currentUser;

      if (refreshedUser == null) {
        return const Left(AuthFailure('Failed to refresh user'));
      }

      return Right(_mapFirebaseUserToAuthUser(refreshedUser));
    } catch (e) {
      return Left(AuthFailure('User refresh error: $e'));
    }
  }

  /// Helper method to map Firebase User to AuthUser entity
  AuthUser _mapFirebaseUserToAuthUser(User user) {
    return AuthUser(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      phoneNumber: user.phoneNumber,
      isEmailVerified: user.emailVerified,
      isPhoneVerified: user.phoneNumber != null,
      photoURL: user.photoURL,
      createdAt: user.metadata.creationTime,
      lastSignInAt: user.metadata.lastSignInTime,
    );
  }

  /// Helper method to map Firebase Auth errors to user-friendly messages
  String _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'invalid-email':
        return 'Invalid email address format.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'invalid-verification-code':
        return 'Invalid verification code.';
      case 'invalid-verification-id':
        return 'Invalid verification ID.';
      case 'credential-already-in-use':
        return 'This credential is already associated with another account.';
      case 'requires-recent-login':
        return 'Please sign in again to perform this action.';
      case 'invalid-phone-number':
        return 'Invalid phone number format.';
      case 'missing-phone-number':
        return 'Phone number is required.';
      case 'quota-exceeded':
        return 'SMS quota exceeded. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return e.message ?? 'An unexpected error occurred.';
    }
  }
}
