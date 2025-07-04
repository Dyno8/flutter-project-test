import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

/// Use case for getting current authenticated user
class GetCurrentUser implements NoParamsUseCase<AuthUser> {
  final AuthRepository repository;

  const GetCurrentUser(this.repository);

  @override
  Future<Either<Failure, AuthUser>> call() async {
    try {
      final currentUser = repository.currentUser;
      return Right(currentUser);
    } catch (e) {
      return Left(AuthFailure('Failed to get current user: $e'));
    }
  }
}
