import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../shared/services/firebase_service.dart';
import '../models/admin_user_model.dart';
import '../../domain/entities/admin_user.dart';
import '../../domain/repositories/admin_repository.dart';

/// Remote data source for admin operations using Firebase
abstract class AdminRemoteDataSource {
  /// Authenticate admin with email and password
  Future<AdminUserModel> authenticateAdmin({
    required String email,
    required String password,
  });

  /// Sign out admin user
  Future<void> signOut();

  /// Get admin user by ID
  Future<AdminUserModel> getAdminById(String adminId);

  /// Get all admin users
  Future<List<AdminUserModel>> getAllAdmins();

  /// Create new admin user
  Future<AdminUserModel> createAdmin({
    required String email,
    required String displayName,
    required AdminRole role,
    List<AdminPermission>? customPermissions,
  });

  /// Update admin user
  Future<AdminUserModel> updateAdmin({
    required String adminId,
    String? displayName,
    AdminRole? role,
    List<AdminPermission>? permissions,
    bool? isActive,
  });

  /// Delete admin user
  Future<void> deleteAdmin(String adminId);

  /// Update admin last login time
  Future<void> updateLastLogin(String adminId);

  /// Get admin activity logs
  Future<List<AdminActivityLog>> getAdminActivityLogs({
    String? adminId,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  });

  /// Log admin activity
  Future<void> logAdminActivity({
    required String adminId,
    required AdminActivityType activityType,
    required String description,
    Map<String, dynamic>? metadata,
  });

  /// Stream of admin authentication state changes
  Stream<AdminUserModel> get authStateChanges;

  /// Get current authenticated admin user
  AdminUserModel get currentAdmin;
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final FirebaseService _firebaseService;
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AdminUserModel _currentAdmin = AdminUserModel(
    uid: '',
    email: '',
    displayName: '',
    role: AdminRole.viewer,
    permissions: const [],
    isActive: false,
    createdAt: DateTime.fromMillisecondsSinceEpoch(0),
  );

  AdminRemoteDataSourceImpl({required FirebaseService firebaseService})
    : _firebaseService = firebaseService,
      _auth = firebaseService.auth,
      _firestore = firebaseService.firestore;

  @override
  AdminUserModel get currentAdmin => _currentAdmin;

  @override
  Stream<AdminUserModel> get authStateChanges {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) {
        _currentAdmin = AdminUserModel(
          uid: '',
          email: '',
          displayName: '',
          role: AdminRole.viewer,
          permissions: const [],
          isActive: false,
          createdAt: DateTime.fromMillisecondsSinceEpoch(0),
        );
        return _currentAdmin;
      }

      try {
        final adminDoc = await _firestore
            .collection(AppConstants.adminUsersCollection)
            .doc(user.uid)
            .get();

        if (adminDoc.exists) {
          _currentAdmin = AdminUserModel.fromFirestore(adminDoc);
          return _currentAdmin;
        } else {
          // User exists in Firebase Auth but not in admin collection
          await _auth.signOut();
          throw const ServerException('Admin user not found');
        }
      } catch (e) {
        _currentAdmin = AdminUserModel(
          uid: '',
          email: '',
          displayName: '',
          role: AdminRole.viewer,
          permissions: const [],
          isActive: false,
          createdAt: DateTime.fromMillisecondsSinceEpoch(0),
        );
        return _currentAdmin;
      }
    });
  }

  @override
  Future<AdminUserModel> authenticateAdmin({
    required String email,
    required String password,
  }) async {
    try {
      // Sign in with Firebase Auth
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw const ServerException('Authentication failed');
      }

      // Get admin user data from Firestore
      final adminDoc = await _firestore
          .collection(AppConstants.adminUsersCollection)
          .doc(user.uid)
          .get();

      if (!adminDoc.exists) {
        // User exists in Firebase Auth but not in admin collection
        await _auth.signOut();
        throw const ServerException('Admin user not found');
      }

      final admin = AdminUserModel.fromFirestore(adminDoc);

      if (!admin.isActive) {
        await _auth.signOut();
        throw const ServerException('Admin account is deactivated');
      }

      _currentAdmin = admin;
      return admin;
    } on FirebaseAuthException catch (e) {
      throw ServerException(_getAuthErrorMessage(e.code));
    } catch (e) {
      throw ServerException('Authentication failed: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _currentAdmin = AdminUserModel(
        uid: '',
        email: '',
        displayName: '',
        role: AdminRole.viewer,
        permissions: const [],
        isActive: false,
        createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      );
    } catch (e) {
      throw ServerException('Sign out failed: $e');
    }
  }

  @override
  Future<AdminUserModel> getAdminById(String adminId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.adminUsersCollection)
          .doc(adminId)
          .get();

      if (!doc.exists) {
        throw const ServerException('Admin user not found');
      }

      return AdminUserModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException('Failed to get admin user: $e');
    }
  }

  @override
  Future<List<AdminUserModel>> getAllAdmins() async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.adminUsersCollection)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => AdminUserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException('Failed to get admin users: $e');
    }
  }

  @override
  Future<AdminUserModel> createAdmin({
    required String email,
    required String displayName,
    required AdminRole role,
    List<AdminPermission>? customPermissions,
  }) async {
    try {
      // Create user in Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: _generateTemporaryPassword(),
      );

      final user = userCredential.user;
      if (user == null) {
        throw const ServerException('Failed to create admin user');
      }

      // Update display name
      await user.updateDisplayName(displayName);

      // Create admin document in Firestore
      final permissions =
          customPermissions ?? AdminUser.getDefaultPermissions(role);
      final adminData = AdminUserModel(
        uid: user.uid,
        email: email,
        displayName: displayName,
        role: role,
        permissions: permissions,
        isActive: true,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection(AppConstants.adminUsersCollection)
          .doc(user.uid)
          .set(adminData.toFirestore());

      return adminData;
    } on FirebaseAuthException catch (e) {
      throw ServerException(_getAuthErrorMessage(e.code));
    } catch (e) {
      throw ServerException('Failed to create admin user: $e');
    }
  }

  @override
  Future<AdminUserModel> updateAdmin({
    required String adminId,
    String? displayName,
    AdminRole? role,
    List<AdminPermission>? permissions,
    bool? isActive,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (displayName != null) updateData['displayName'] = displayName;
      if (role != null) updateData['role'] = role.name;
      if (permissions != null) {
        updateData['permissions'] = permissions.map((p) => p.name).toList();
      }
      if (isActive != null) updateData['isActive'] = isActive;

      await _firestore
          .collection(AppConstants.adminUsersCollection)
          .doc(adminId)
          .update(updateData);

      return await getAdminById(adminId);
    } catch (e) {
      throw ServerException('Failed to update admin user: $e');
    }
  }

  @override
  Future<void> deleteAdmin(String adminId) async {
    try {
      // Delete from Firestore
      await _firestore
          .collection(AppConstants.adminUsersCollection)
          .doc(adminId)
          .delete();

      // Note: Firebase Auth user deletion requires admin SDK
      // For now, we just deactivate the admin in Firestore
    } catch (e) {
      throw ServerException('Failed to delete admin user: $e');
    }
  }

  @override
  Future<void> updateLastLogin(String adminId) async {
    try {
      await _firestore
          .collection(AppConstants.adminUsersCollection)
          .doc(adminId)
          .update({'lastLoginAt': FieldValue.serverTimestamp()});
    } catch (e) {
      throw ServerException('Failed to update last login: $e');
    }
  }

  @override
  Future<List<AdminActivityLog>> getAdminActivityLogs({
    String? adminId,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  }) async {
    try {
      Query query = _firestore
          .collection(AppConstants.adminActivityLogsCollection)
          .orderBy('timestamp', descending: true)
          .limit(limit);

      if (adminId != null) {
        query = query.where('adminId', isEqualTo: adminId);
      }

      if (startDate != null) {
        query = query.where(
          'timestamp',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        );
      }

      if (endDate != null) {
        query = query.where(
          'timestamp',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate),
        );
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return AdminActivityLog(
          id: doc.id,
          adminId: data['adminId'] ?? '',
          adminName: data['adminName'] ?? '',
          activityType: AdminActivityType.values.firstWhere(
            (type) => type.name == data['activityType'],
            orElse: () => AdminActivityType.viewDashboard,
          ),
          description: data['description'] ?? '',
          timestamp: (data['timestamp'] as Timestamp).toDate(),
          metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
          ipAddress: data['ipAddress'],
          userAgent: data['userAgent'],
        );
      }).toList();
    } catch (e) {
      throw ServerException('Failed to get admin activity logs: $e');
    }
  }

  @override
  Future<void> logAdminActivity({
    required String adminId,
    required AdminActivityType activityType,
    required String description,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final admin = await getAdminById(adminId);

      await _firestore.collection(AppConstants.adminActivityLogsCollection).add(
        {
          'adminId': adminId,
          'adminName': admin.displayName,
          'activityType': activityType.name,
          'description': description,
          'timestamp': FieldValue.serverTimestamp(),
          'metadata': metadata ?? {},
          // Note: IP address and user agent would need to be passed from client
        },
      );
    } catch (e) {
      throw ServerException('Failed to log admin activity: $e');
    }
  }

  String _generateTemporaryPassword() {
    // Generate a temporary password for new admin users
    // In production, this should be more secure and sent via email
    return 'TempPass123!';
  }

  String _getAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'Admin user not found';
      case 'wrong-password':
        return 'Invalid password';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'Admin account has been disabled';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later';
      default:
        return 'Authentication failed';
    }
  }
}
