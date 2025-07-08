import 'package:equatable/equatable.dart';

/// Admin user roles
enum AdminRole {
  superAdmin,
  admin,
  viewer;

  String get displayName {
    switch (this) {
      case AdminRole.superAdmin:
        return 'Super Admin';
      case AdminRole.admin:
        return 'Admin';
      case AdminRole.viewer:
        return 'Viewer';
    }
  }

  bool get canManageUsers => this == AdminRole.superAdmin;
  bool get canManagePartners => this != AdminRole.viewer;
  bool get canViewAnalytics => true;
  bool get canExportData => this != AdminRole.viewer;
  bool get canManageSystem => this == AdminRole.superAdmin;
}

/// Admin permissions
enum AdminPermission {
  viewDashboard,
  viewAnalytics,
  manageUsers,
  managePartners,
  manageBookings,
  viewRevenue,
  exportData,
  manageSystem,
  viewLogs;

  String get displayName {
    switch (this) {
      case AdminPermission.viewDashboard:
        return 'View Dashboard';
      case AdminPermission.viewAnalytics:
        return 'View Analytics';
      case AdminPermission.manageUsers:
        return 'Manage Users';
      case AdminPermission.managePartners:
        return 'Manage Partners';
      case AdminPermission.manageBookings:
        return 'Manage Bookings';
      case AdminPermission.viewRevenue:
        return 'View Revenue';
      case AdminPermission.exportData:
        return 'Export Data';
      case AdminPermission.manageSystem:
        return 'Manage System';
      case AdminPermission.viewLogs:
        return 'View Logs';
    }
  }
}

/// Admin user entity
class AdminUser extends Equatable {
  final String uid;
  final String email;
  final String displayName;
  final AdminRole role;
  final List<AdminPermission> permissions;
  final DateTime? lastLoginAt;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const AdminUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    required this.permissions,
    this.lastLoginAt,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  /// Create an empty/anonymous admin user
  static AdminUser empty = AdminUser(
    uid: '',
    email: '',
    displayName: '',
    role: AdminRole.viewer,
    permissions: const [],
    isActive: false,
    createdAt: DateTime.fromMillisecondsSinceEpoch(0),
  );

  /// Check if admin user is empty (not authenticated)
  bool get isEmpty => this == AdminUser.empty;

  /// Check if admin user is not empty (authenticated)
  bool get isNotEmpty => this != AdminUser.empty;

  /// Check if admin has specific permission
  bool hasPermission(AdminPermission permission) {
    return permissions.contains(permission);
  }

  /// Check if admin can perform action based on role
  bool canPerformAction(AdminPermission permission) {
    if (!isActive) return false;

    switch (permission) {
      case AdminPermission.viewDashboard:
      case AdminPermission.viewAnalytics:
        return true;
      case AdminPermission.manageUsers:
      case AdminPermission.manageSystem:
        return role == AdminRole.superAdmin;
      case AdminPermission.managePartners:
      case AdminPermission.manageBookings:
      case AdminPermission.exportData:
        return role != AdminRole.viewer;
      case AdminPermission.viewRevenue:
      case AdminPermission.viewLogs:
        return role != AdminRole.viewer;
    }
  }

  /// Get default permissions for role
  static List<AdminPermission> getDefaultPermissions(AdminRole role) {
    switch (role) {
      case AdminRole.superAdmin:
        return AdminPermission.values;
      case AdminRole.admin:
        return [
          AdminPermission.viewDashboard,
          AdminPermission.viewAnalytics,
          AdminPermission.managePartners,
          AdminPermission.manageBookings,
          AdminPermission.viewRevenue,
          AdminPermission.exportData,
          AdminPermission.viewLogs,
        ];
      case AdminRole.viewer:
        return [AdminPermission.viewDashboard, AdminPermission.viewAnalytics];
    }
  }

  /// Copy with method for updating admin user
  AdminUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    AdminRole? role,
    List<AdminPermission>? permissions,
    DateTime? lastLoginAt,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AdminUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      permissions: permissions ?? this.permissions,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    uid,
    email,
    displayName,
    role,
    permissions,
    lastLoginAt,
    isActive,
    createdAt,
    updatedAt,
  ];

  @override
  String toString() {
    return 'AdminUser(uid: $uid, email: $email, displayName: $displayName, role: $role, isActive: $isActive)';
  }
}
