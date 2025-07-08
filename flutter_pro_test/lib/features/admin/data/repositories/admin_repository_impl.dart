import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/admin_user.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_data_source.dart';

/// Implementation of AdminRepository
class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource remoteDataSource;

  AdminRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Stream<AdminUser> get authStateChanges {
    return remoteDataSource.authStateChanges.map((adminModel) => adminModel.toEntity());
  }

  @override
  AdminUser get currentAdmin {
    return remoteDataSource.currentAdmin.toEntity();
  }

  @override
  Future<Either<Failure, AdminUser>> authenticateAdmin({
    required String email,
    required String password,
  }) async {
    try {
      final adminModel = await remoteDataSource.authenticateAdmin(
        email: email,
        password: password,
      );
      return Right(adminModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Authentication failed: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Sign out failed: $e'));
    }
  }

  @override
  Future<Either<Failure, AdminUser>> getAdminById(String adminId) async {
    try {
      final adminModel = await remoteDataSource.getAdminById(adminId);
      return Right(adminModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get admin user: $e'));
    }
  }

  @override
  Future<Either<Failure, List<AdminUser>>> getAllAdmins() async {
    try {
      final adminModels = await remoteDataSource.getAllAdmins();
      final admins = adminModels.map((model) => model.toEntity()).toList();
      return Right(admins);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get admin users: $e'));
    }
  }

  @override
  Future<Either<Failure, AdminUser>> createAdmin({
    required String email,
    required String displayName,
    required AdminRole role,
    List<AdminPermission>? customPermissions,
  }) async {
    try {
      final adminModel = await remoteDataSource.createAdmin(
        email: email,
        displayName: displayName,
        role: role,
        customPermissions: customPermissions,
      );
      return Right(adminModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to create admin user: $e'));
    }
  }

  @override
  Future<Either<Failure, AdminUser>> updateAdmin({
    required String adminId,
    String? displayName,
    AdminRole? role,
    List<AdminPermission>? permissions,
    bool? isActive,
  }) async {
    try {
      final adminModel = await remoteDataSource.updateAdmin(
        adminId: adminId,
        displayName: displayName,
        role: role,
        permissions: permissions,
        isActive: isActive,
      );
      return Right(adminModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to update admin user: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAdmin(String adminId) async {
    try {
      await remoteDataSource.deleteAdmin(adminId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to delete admin user: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateLastLogin(String adminId) async {
    try {
      await remoteDataSource.updateLastLogin(adminId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to update last login: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> hasPermission({
    required String adminId,
    required AdminPermission permission,
  }) async {
    try {
      final adminModel = await remoteDataSource.getAdminById(adminId);
      final admin = adminModel.toEntity();
      return Right(admin.canPerformAction(permission));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to check permission: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> validateSession() async {
    try {
      final currentAdmin = remoteDataSource.currentAdmin;
      if (currentAdmin.isEmpty) {
        return const Right(false);
      }

      // Check if admin is still active
      final adminModel = await remoteDataSource.getAdminById(currentAdmin.uid);
      return Right(adminModel.isActive);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to validate session: $e'));
    }
  }

  @override
  Future<Either<Failure, AdminUser>> refreshAdmin() async {
    try {
      final currentAdmin = remoteDataSource.currentAdmin;
      if (currentAdmin.isEmpty) {
        return const Left(AuthFailure('No admin user authenticated'));
      }

      final adminModel = await remoteDataSource.getAdminById(currentAdmin.uid);
      return Right(adminModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to refresh admin: $e'));
    }
  }

  @override
  Future<Either<Failure, List<AdminActivityLog>>> getAdminActivityLogs({
    String? adminId,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  }) async {
    try {
      final logs = await remoteDataSource.getAdminActivityLogs(
        adminId: adminId,
        startDate: startDate,
        endDate: endDate,
        limit: limit,
      );
      return Right(logs);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get admin activity logs: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> logAdminActivity({
    required String adminId,
    required AdminActivityType activityType,
    required String description,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await remoteDataSource.logAdminActivity(
        adminId: adminId,
        activityType: activityType,
        description: description,
        metadata: metadata,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to log admin activity: $e'));
    }
  }
}
