import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/admin_user.dart';

/// Abstract repository interface for admin operations
abstract class AdminRepository {
  /// Stream of admin authentication state changes
  Stream<AdminUser> get authStateChanges;

  /// Get current authenticated admin user
  AdminUser get currentAdmin;

  /// Authenticate admin with email and password
  Future<Either<Failure, AdminUser>> authenticateAdmin({
    required String email,
    required String password,
  });

  /// Sign out admin user
  Future<Either<Failure, void>> signOut();

  /// Get admin user by ID
  Future<Either<Failure, AdminUser>> getAdminById(String adminId);

  /// Get all admin users
  Future<Either<Failure, List<AdminUser>>> getAllAdmins();

  /// Create new admin user
  Future<Either<Failure, AdminUser>> createAdmin({
    required String email,
    required String displayName,
    required AdminRole role,
    List<AdminPermission>? customPermissions,
  });

  /// Update admin user
  Future<Either<Failure, AdminUser>> updateAdmin({
    required String adminId,
    String? displayName,
    AdminRole? role,
    List<AdminPermission>? permissions,
    bool? isActive,
  });

  /// Delete admin user
  Future<Either<Failure, void>> deleteAdmin(String adminId);

  /// Update admin last login time
  Future<Either<Failure, void>> updateLastLogin(String adminId);

  /// Check if admin has permission
  Future<Either<Failure, bool>> hasPermission({
    required String adminId,
    required AdminPermission permission,
  });

  /// Validate admin session
  Future<Either<Failure, bool>> validateSession();

  /// Refresh admin user data
  Future<Either<Failure, AdminUser>> refreshAdmin();

  /// Get admin activity logs
  Future<Either<Failure, List<AdminActivityLog>>> getAdminActivityLogs({
    String? adminId,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  });

  /// Log admin activity
  Future<Either<Failure, void>> logAdminActivity({
    required String adminId,
    required AdminActivityType activityType,
    required String description,
    Map<String, dynamic>? metadata,
  });
}

/// Admin activity log entity
class AdminActivityLog {
  final String id;
  final String adminId;
  final String adminName;
  final AdminActivityType activityType;
  final String description;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;
  final String? ipAddress;
  final String? userAgent;

  const AdminActivityLog({
    required this.id,
    required this.adminId,
    required this.adminName,
    required this.activityType,
    required this.description,
    required this.timestamp,
    this.metadata = const {},
    this.ipAddress,
    this.userAgent,
  });
}

/// Admin activity types
enum AdminActivityType {
  login,
  logout,
  viewDashboard,
  viewAnalytics,
  exportData,
  manageUser,
  managePartner,
  manageBooking,
  systemConfiguration,
  dataModification;

  String get displayName {
    switch (this) {
      case AdminActivityType.login:
        return 'Login';
      case AdminActivityType.logout:
        return 'Logout';
      case AdminActivityType.viewDashboard:
        return 'View Dashboard';
      case AdminActivityType.viewAnalytics:
        return 'View Analytics';
      case AdminActivityType.exportData:
        return 'Export Data';
      case AdminActivityType.manageUser:
        return 'Manage User';
      case AdminActivityType.managePartner:
        return 'Manage Partner';
      case AdminActivityType.manageBooking:
        return 'Manage Booking';
      case AdminActivityType.systemConfiguration:
        return 'System Configuration';
      case AdminActivityType.dataModification:
        return 'Data Modification';
    }
  }
}
