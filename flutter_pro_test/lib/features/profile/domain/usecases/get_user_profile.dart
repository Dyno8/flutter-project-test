import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../shared/models/user_profile_model.dart';
import '../repositories/user_profile_repository.dart';

/// Use case for getting user profile
class GetUserProfile implements UseCase<UserProfileModel, GetUserProfileParams> {
  final UserProfileRepository repository;

  const GetUserProfile(this.repository);

  @override
  Future<Either<Failure, UserProfileModel>> call(GetUserProfileParams params) async {
    // Validate user ID
    if (params.uid.trim().isEmpty) {
      return const Left(ValidationFailure('User ID cannot be empty'));
    }

    return await repository.getUserProfile(params.uid);
  }
}

/// Parameters for get user profile use case
class GetUserProfileParams extends Equatable {
  final String uid;

  const GetUserProfileParams({required this.uid});

  @override
  List<Object> get props => [uid];
}
