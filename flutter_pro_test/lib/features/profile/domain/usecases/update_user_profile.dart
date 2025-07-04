import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../shared/models/user_profile_model.dart';
import '../repositories/user_profile_repository.dart';

/// Use case for updating user profile
class UpdateUserProfile implements UseCase<UserProfileModel, UpdateUserProfileParams> {
  final UserProfileRepository repository;

  const UpdateUserProfile(this.repository);

  @override
  Future<Either<Failure, UserProfileModel>> call(UpdateUserProfileParams params) async {
    // Validate required fields
    if (params.profile.uid.trim().isEmpty) {
      return const Left(ValidationFailure('User ID cannot be empty'));
    }

    if (params.profile.email.trim().isEmpty) {
      return const Left(ValidationFailure('Email cannot be empty'));
    }

    if (params.profile.displayName.trim().isEmpty) {
      return const Left(ValidationFailure('Display name cannot be empty'));
    }

    // Validate email format
    if (!_isValidEmail(params.profile.email)) {
      return const Left(ValidationFailure('Invalid email format'));
    }

    // Validate display name length
    if (params.profile.displayName.trim().length < 2) {
      return const Left(ValidationFailure('Display name must be at least 2 characters'));
    }

    // Validate phone number if provided
    if (params.profile.phoneNumber != null && 
        params.profile.phoneNumber!.isNotEmpty &&
        !_isValidVietnamesePhone(params.profile.phoneNumber!)) {
      return const Left(ValidationFailure('Invalid Vietnamese phone number format'));
    }

    // Validate date of birth if provided
    if (params.profile.dateOfBirth != null) {
      final now = DateTime.now();
      final age = now.year - params.profile.dateOfBirth!.year;
      if (age < 16 || age > 100) {
        return const Left(ValidationFailure('Age must be between 16 and 100 years'));
      }
    }

    // Add updated timestamp
    final updatedProfile = params.profile.copyWith(
      updatedAt: DateTime.now(),
    );

    return await repository.updateUserProfile(updatedProfile);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidVietnamesePhone(String phone) {
    // Vietnamese phone number validation
    return RegExp(r'^(\+84|84|0)(3|5|7|8|9)([0-9]{8})$').hasMatch(phone);
  }
}

/// Parameters for update user profile use case
class UpdateUserProfileParams extends Equatable {
  final UserProfileModel profile;

  const UpdateUserProfileParams({required this.profile});

  @override
  List<Object> get props => [profile];
}
