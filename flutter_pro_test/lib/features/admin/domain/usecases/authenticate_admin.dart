import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/admin_user.dart';
import '../repositories/admin_repository.dart';

/// Use case for authenticating admin users
class AuthenticateAdmin implements UseCase<AdminUser, AuthenticateAdminParams> {
  final AdminRepository repository;

  const AuthenticateAdmin(this.repository);

  @override
  Future<Either<Failure, AdminUser>> call(AuthenticateAdminParams params) async {
    // Validate email format
    if (!_isValidEmail(params.email)) {
      return const Left(ValidationFailure('Invalid email format'));
    }

    // Validate password length
    if (params.password.length < 8) {
      return const Left(ValidationFailure('Password must be at least 8 characters'));
    }

    // Authenticate admin
    final result = await repository.authenticateAdmin(
      email: params.email,
      password: params.password,
    );

    return result.fold(
      (failure) => Left(failure),
      (admin) async {
        // Check if admin is active
        if (!admin.isActive) {
          return const Left(AuthFailure('Admin account is deactivated'));
        }

        // Update last login time
        await repository.updateLastLogin(admin.uid);

        // Log admin activity
        await repository.logAdminActivity(
          adminId: admin.uid,
          activityType: AdminActivityType.login,
          description: 'Admin logged in successfully',
          metadata: {
            'loginTime': DateTime.now().toIso8601String(),
            'email': params.email,
          },
        );

        return Right(admin);
      },
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}

/// Parameters for admin authentication
class AuthenticateAdminParams extends Equatable {
  final String email;
  final String password;

  const AuthenticateAdminParams({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}
