import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/models/user_profile_model.dart';

/// Abstract repository interface for user profile operations
abstract class UserProfileRepository {
  /// Get user profile by ID
  Future<Either<Failure, UserProfileModel>> getUserProfile(String uid);

  /// Create new user profile
  Future<Either<Failure, UserProfileModel>> createUserProfile(UserProfileModel profile);

  /// Update existing user profile
  Future<Either<Failure, UserProfileModel>> updateUserProfile(UserProfileModel profile);

  /// Delete user profile
  Future<Either<Failure, void>> deleteUserProfile(String uid);

  /// Check if user profile exists
  Future<Either<Failure, bool>> profileExists(String uid);

  /// Update profile avatar
  Future<Either<Failure, String>> updateProfileAvatar(String uid, String imagePath);

  /// Update user location
  Future<Either<Failure, void>> updateUserLocation(String uid, double latitude, double longitude);

  /// Update user preferences
  Future<Either<Failure, void>> updateUserPreferences(String uid, List<String> preferences);

  /// Verify user phone number
  Future<Either<Failure, void>> verifyPhoneNumber(String uid);

  /// Verify user email
  Future<Either<Failure, void>> verifyEmail(String uid);

  /// Get users by role
  Future<Either<Failure, List<UserProfileModel>>> getUsersByRole(UserRole role);

  /// Search users by name or location
  Future<Either<Failure, List<UserProfileModel>>> searchUsers({
    String? query,
    UserRole? role,
    String? city,
    String? district,
  });

  /// Get nearby users (for location-based services)
  Future<Either<Failure, List<UserProfileModel>>> getNearbyUsers({
    required double latitude,
    required double longitude,
    required double radiusKm,
    UserRole? role,
  });

  /// Stream of user profile changes
  Stream<Either<Failure, UserProfileModel>> watchUserProfile(String uid);
}
