import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

/// Use case for signing up with email and password
class SignUpWithEmail implements UseCase<AuthUser, SignUpWithEmailParams> {
  final AuthRepository repository;

  const SignUpWithEmail(this.repository);

  @override
  Future<Either<Failure, AuthUser>> call(SignUpWithEmailParams params) async {
    // Validate email format
    if (!_isValidEmail(params.email)) {
      return const Left(ValidationFailure('Invalid email format'));
    }

    // Validate password strength
    if (params.password.length < 6) {
      return const Left(ValidationFailure('Password must be at least 6 characters'));
    }

    // Validate display name
    if (params.displayName.trim().isEmpty) {
      return const Left(ValidationFailure('Display name cannot be empty'));
    }

    if (params.displayName.trim().length < 2) {
      return const Left(ValidationFailure('Display name must be at least 2 characters'));
    }

    // Validate password confirmation
    if (params.password != params.confirmPassword) {
      return const Left(ValidationFailure('Passwords do not match'));
    }

    return await repository.signUpWithEmailAndPassword(
      email: params.email,
      password: params.password,
      displayName: params.displayName.trim(),
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}

/// Parameters for sign up with email use case
class SignUpWithEmailParams extends Equatable {
  final String email;
  final String password;
  final String confirmPassword;
  final String displayName;

  const SignUpWithEmailParams({
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.displayName,
  });

  @override
  List<Object> get props => [email, password, confirmPassword, displayName];
}
