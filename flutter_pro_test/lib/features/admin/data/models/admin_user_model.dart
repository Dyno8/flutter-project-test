import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/admin_user.dart';

/// Data model for AdminUser with Firestore serialization
class AdminUserModel extends AdminUser {
  const AdminUserModel({
    required super.uid,
    required super.email,
    required super.displayName,
    required super.role,
    required super.permissions,
    super.lastLoginAt,
    super.isActive = true,
    required super.createdAt,
    super.updatedAt,
  });

  /// Create AdminUserModel from domain entity
  factory AdminUserModel.fromEntity(AdminUser admin) {
    return AdminUserModel(
      uid: admin.uid,
      email: admin.email,
      displayName: admin.displayName,
      role: admin.role,
      permissions: admin.permissions,
      lastLoginAt: admin.lastLoginAt,
      isActive: admin.isActive,
      createdAt: admin.createdAt,
      updatedAt: admin.updatedAt,
    );
  }

  /// Create AdminUserModel from Firestore document
  factory AdminUserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return AdminUserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      role: _parseRole(data['role']),
      permissions: _parsePermissions(data['permissions']),
      lastLoginAt: data['lastLoginAt'] != null
          ? (data['lastLoginAt'] as Timestamp).toDate()
          : null,
      isActive: data['isActive'] ?? true,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Create AdminUserModel from JSON map
  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    return AdminUserModel(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? '',
      role: _parseRole(json['role']),
      permissions: _parsePermissions(json['permissions']),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'])
          : null,
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'role': role.name,
      'permissions': permissions.map((p) => p.name).toList(),
      'lastLoginAt': lastLoginAt != null
          ? Timestamp.fromDate(lastLoginAt!)
          : null,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'role': role.name,
      'permissions': permissions.map((p) => p.name).toList(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Parse role from string
  static AdminRole _parseRole(dynamic roleData) {
    if (roleData == null) return AdminRole.viewer;

    final roleString = roleData.toString();
    return AdminRole.values.firstWhere(
      (role) => role.name == roleString,
      orElse: () => AdminRole.viewer,
    );
  }

  /// Parse permissions from list
  static List<AdminPermission> _parsePermissions(dynamic permissionsData) {
    if (permissionsData == null) return [];

    if (permissionsData is List) {
      return permissionsData
          .map(
            (p) => AdminPermission.values.firstWhere(
              (permission) => permission.name == p.toString(),
              orElse: () => AdminPermission.viewDashboard,
            ),
          )
          .toList();
    }

    return [];
  }

  /// Create a copy with updated fields
  @override
  AdminUserModel copyWith({
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
    return AdminUserModel(
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

  /// Convert to domain entity
  AdminUser toEntity() {
    return AdminUser(
      uid: uid,
      email: email,
      displayName: displayName,
      role: role,
      permissions: permissions,
      lastLoginAt: lastLoginAt,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
