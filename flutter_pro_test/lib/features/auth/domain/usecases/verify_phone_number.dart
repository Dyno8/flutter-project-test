import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

/// Use case for verifying phone number with OTP code
class VerifyPhoneNumber implements UseCase<AuthUser, VerifyPhoneNumberParams> {
  final AuthRepository repository;

  const VerifyPhoneNumber(this.repository);

  @override
  Future<Either<Failure, AuthUser>> call(VerifyPhoneNumberParams params) async {
    // Validate verification ID
    if (params.verificationId.trim().isEmpty) {
      return const Left(ValidationFailure('Verification ID cannot be empty'));
    }

    // Validate SMS code
    if (params.smsCode.trim().isEmpty) {
      return const Left(ValidationFailure('SMS code cannot be empty'));
    }

    if (params.smsCode.trim().length != 6) {
      return const Left(ValidationFailure('SMS code must be 6 digits'));
    }

    // Validate SMS code contains only digits
    if (!RegExp(r'^\d{6}$').hasMatch(params.smsCode.trim())) {
      return const Left(ValidationFailure('SMS code must contain only digits'));
    }

    return await repository.verifyPhoneNumber(
      verificationId: params.verificationId,
      smsCode: params.smsCode.trim(),
    );
  }
}

/// Parameters for verify phone number use case
class VerifyPhoneNumberParams extends Equatable {
  final String verificationId;
  final String smsCode;

  const VerifyPhoneNumberParams({
    required this.verificationId,
    required this.smsCode,
  });

  @override
  List<Object> get props => [verificationId, smsCode];
}
