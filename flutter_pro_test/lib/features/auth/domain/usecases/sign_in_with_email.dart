import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

/// Use case for signing in with email and password
class SignInWithEmail implements UseCase<AuthUser, SignInWithEmailParams> {
  final AuthRepository repository;

  const SignInWithEmail(this.repository);

  @override
  Future<Either<Failure, AuthUser>> call(SignInWithEmailParams params) async {
    // Validate email format
    if (!_isValidEmail(params.email)) {
      return const Left(ValidationFailure('Invalid email format'));
    }

    // Validate password length
    if (params.password.length < 6) {
      return const Left(ValidationFailure('Password must be at least 6 characters'));
    }

    return await repository.signInWithEmailAndPassword(
      email: params.email,
      password: params.password,
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}

/// Parameters for sign in with email use case
class SignInWithEmailParams extends Equatable {
  final String email;
  final String password;

  const SignInWithEmailParams({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}
