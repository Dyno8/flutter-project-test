import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

/// Use case for signing out current user
class SignOut implements NoParamsUseCase<void> {
  final AuthRepository repository;

  const SignOut(this.repository);

  @override
  Future<Either<Failure, void>> call() async {
    return await repository.signOut();
  }
}
