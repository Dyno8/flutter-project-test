import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_datasource.dart';

/// Implementation of AuthRepository using Firebase authentication
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource dataSource;

  const AuthRepositoryImpl({required this.dataSource});

  @override
  Stream<AuthUser> get authStateChanges => dataSource.authStateChanges;

  @override
  AuthUser get currentUser => dataSource.currentUser;

  @override
  Future<Either<Failure, AuthUser>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await dataSource.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<Either<Failure, AuthUser>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    return await dataSource.signUpWithEmailAndPassword(
      email: email,
      password: password,
      displayName: displayName,
    );
  }

  @override
  Future<Either<Failure, String>> signInWithPhoneNumber({
    required String phoneNumber,
  }) async {
    return await dataSource.signInWithPhoneNumber(phoneNumber: phoneNumber);
  }

  @override
  Future<Either<Failure, AuthUser>> verifyPhoneNumber({
    required String verificationId,
    required String smsCode,
  }) async {
    return await dataSource.verifyPhoneNumber(
      verificationId: verificationId,
      smsCode: smsCode,
    );
  }

  @override
  Future<Either<Failure, void>> sendEmailVerification() async {
    return await dataSource.sendEmailVerification();
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail({
    required String email,
  }) async {
    return await dataSource.sendPasswordResetEmail(email: email);
  }

  @override
  Future<Either<Failure, void>> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    return await dataSource.updateProfile(
      displayName: displayName,
      photoURL: photoURL,
    );
  }

  @override
  Future<Either<Failure, void>> updateEmail({
    required String newEmail,
  }) async {
    return await dataSource.updateEmail(newEmail: newEmail);
  }

  @override
  Future<Either<Failure, void>> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    return await dataSource.updatePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  @override
  Future<Either<Failure, void>> reauthenticateWithPassword({
    required String password,
  }) async {
    return await dataSource.reauthenticateWithPassword(password: password);
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    return await dataSource.signOut();
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    return await dataSource.deleteAccount();
  }

  @override
  Future<Either<Failure, bool>> isEmailInUse({
    required String email,
  }) async {
    return await dataSource.isEmailInUse(email: email);
  }

  @override
  Future<Either<Failure, AuthUser>> refreshUser() async {
    return await dataSource.refreshUser();
  }
}
