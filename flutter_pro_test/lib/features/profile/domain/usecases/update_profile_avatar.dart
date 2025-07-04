import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/user_profile_repository.dart';

/// Use case for updating user profile avatar
class UpdateProfileAvatar implements UseCase<String, UpdateProfileAvatarParams> {
  final UserProfileRepository repository;

  const UpdateProfileAvatar(this.repository);

  @override
  Future<Either<Failure, String>> call(UpdateProfileAvatarParams params) async {
    // Validate user ID
    if (params.uid.trim().isEmpty) {
      return const Left(ValidationFailure('User ID cannot be empty'));
    }

    // Validate image path
    if (params.imagePath.trim().isEmpty) {
      return const Left(ValidationFailure('Image path cannot be empty'));
    }

    // Validate image file extension
    final allowedExtensions = ['.jpg', '.jpeg', '.png', '.webp'];
    final hasValidExtension = allowedExtensions.any(
      (ext) => params.imagePath.toLowerCase().endsWith(ext),
    );

    if (!hasValidExtension) {
      return const Left(ValidationFailure('Invalid image format. Allowed: JPG, JPEG, PNG, WEBP'));
    }

    return await repository.updateProfileAvatar(params.uid, params.imagePath);
  }
}

/// Parameters for update profile avatar use case
class UpdateProfileAvatarParams extends Equatable {
  final String uid;
  final String imagePath;

  const UpdateProfileAvatarParams({
    required this.uid,
    required this.imagePath,
  });

  @override
  List<Object> get props => [uid, imagePath];
}
