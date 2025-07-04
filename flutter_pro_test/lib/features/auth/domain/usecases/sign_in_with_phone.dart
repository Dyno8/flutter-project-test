import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

/// Use case for signing in with phone number (send OTP)
class SignInWithPhone implements UseCase<String, SignInWithPhoneParams> {
  final AuthRepository repository;

  const SignInWithPhone(this.repository);

  @override
  Future<Either<Failure, String>> call(SignInWithPhoneParams params) async {
    // Validate phone number format (Vietnamese format)
    if (!_isValidVietnamesePhone(params.phoneNumber)) {
      return const Left(ValidationFailure('Invalid Vietnamese phone number format'));
    }

    return await repository.signInWithPhoneNumber(
      phoneNumber: params.phoneNumber,
    );
  }

  bool _isValidVietnamesePhone(String phone) {
    // Vietnamese phone number validation
    // Supports formats: +84xxxxxxxxx, 84xxxxxxxxx, 0xxxxxxxxx
    return RegExp(r'^(\+84|84|0)(3|5|7|8|9)([0-9]{8})$').hasMatch(phone);
  }
}

/// Parameters for sign in with phone use case
class SignInWithPhoneParams extends Equatable {
  final String phoneNumber;

  const SignInWithPhoneParams({
    required this.phoneNumber,
  });

  @override
  List<Object> get props => [phoneNumber];
}
