import 'dart:math';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/models/user_profile_model.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../datasources/user_profile_datasource.dart';

/// Implementation of UserProfileRepository using Firebase
class UserProfileRepositoryImpl implements UserProfileRepository {
  final UserProfileDataSource dataSource;

  const UserProfileRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, UserProfileModel>> getUserProfile(String uid) async {
    return await dataSource.getUserProfile(uid);
  }

  @override
  Future<Either<Failure, UserProfileModel>> createUserProfile(
    UserProfileModel profile,
  ) async {
    return await dataSource.createUserProfile(profile);
  }

  @override
  Future<Either<Failure, UserProfileModel>> updateUserProfile(
    UserProfileModel profile,
  ) async {
    return await dataSource.updateUserProfile(profile);
  }

  @override
  Future<Either<Failure, void>> deleteUserProfile(String uid) async {
    return await dataSource.deleteUserProfile(uid);
  }

  @override
  Future<Either<Failure, bool>> profileExists(String uid) async {
    return await dataSource.profileExists(uid);
  }

  @override
  Future<Either<Failure, String>> updateProfileAvatar(
    String uid,
    String imagePath,
  ) async {
    // Upload image and get URL
    final uploadResult = await dataSource.uploadProfileImage(uid, imagePath);

    return uploadResult.fold((failure) => Left(failure), (imageUrl) async {
      // Update profile with new avatar URL
      final profileResult = await dataSource.getUserProfile(uid);

      return profileResult.fold((failure) => Left(failure), (profile) async {
        final updatedProfile = profile.copyWith(
          avatar: imageUrl,
          updatedAt: DateTime.now(),
        );

        final updateResult = await dataSource.updateUserProfile(updatedProfile);
        return updateResult.fold(
          (failure) => Left(failure),
          (_) => Right(imageUrl),
        );
      });
    });
  }

  @override
  Future<Either<Failure, void>> updateUserLocation(
    String uid,
    double latitude,
    double longitude,
  ) async {
    final profileResult = await dataSource.getUserProfile(uid);

    return profileResult.fold((failure) => Left(failure), (profile) async {
      final updatedProfile = profile.copyWith(
        latitude: latitude,
        longitude: longitude,
        updatedAt: DateTime.now(),
      );

      final updateResult = await dataSource.updateUserProfile(updatedProfile);
      return updateResult.fold(
        (failure) => Left(failure),
        (_) => const Right(null),
      );
    });
  }

  @override
  Future<Either<Failure, void>> updateUserPreferences(
    String uid,
    List<String> preferences,
  ) async {
    final profileResult = await dataSource.getUserProfile(uid);

    return profileResult.fold((failure) => Left(failure), (profile) async {
      final updatedProfile = profile.copyWith(
        preferences: preferences,
        updatedAt: DateTime.now(),
      );

      final updateResult = await dataSource.updateUserProfile(updatedProfile);
      return updateResult.fold(
        (failure) => Left(failure),
        (_) => const Right(null),
      );
    });
  }

  @override
  Future<Either<Failure, void>> verifyPhoneNumber(String uid) async {
    final profileResult = await dataSource.getUserProfile(uid);

    return profileResult.fold((failure) => Left(failure), (profile) async {
      final updatedProfile = profile.copyWith(
        isPhoneVerified: true,
        updatedAt: DateTime.now(),
      );

      final updateResult = await dataSource.updateUserProfile(updatedProfile);
      return updateResult.fold(
        (failure) => Left(failure),
        (_) => const Right(null),
      );
    });
  }

  @override
  Future<Either<Failure, void>> verifyEmail(String uid) async {
    final profileResult = await dataSource.getUserProfile(uid);

    return profileResult.fold((failure) => Left(failure), (profile) async {
      final updatedProfile = profile.copyWith(
        isEmailVerified: true,
        updatedAt: DateTime.now(),
      );

      final updateResult = await dataSource.updateUserProfile(updatedProfile);
      return updateResult.fold(
        (failure) => Left(failure),
        (_) => const Right(null),
      );
    });
  }

  @override
  Future<Either<Failure, List<UserProfileModel>>> getUsersByRole(
    UserRole role,
  ) async {
    return await dataSource.getUsersByRole(role);
  }

  @override
  Future<Either<Failure, List<UserProfileModel>>> searchUsers({
    String? query,
    UserRole? role,
    String? city,
    String? district,
  }) async {
    return await dataSource.searchUsers(
      query: query,
      role: role,
      city: city,
      district: district,
    );
  }

  @override
  Future<Either<Failure, List<UserProfileModel>>> getNearbyUsers({
    required double latitude,
    required double longitude,
    required double radiusKm,
    UserRole? role,
  }) async {
    // Get all users by role first
    final usersResult = role != null
        ? await dataSource.getUsersByRole(role)
        : await dataSource.searchUsers();

    return usersResult.fold((failure) => Left(failure), (users) {
      // Filter users by distance (simple implementation)
      final nearbyUsers = users.where((user) {
        if (user.latitude == null || user.longitude == null) return false;

        final distance = _calculateDistance(
          latitude,
          longitude,
          user.latitude!,
          user.longitude!,
        );

        return distance <= radiusKm;
      }).toList();

      // Sort by distance
      nearbyUsers.sort((a, b) {
        final distanceA = _calculateDistance(
          latitude,
          longitude,
          a.latitude!,
          a.longitude!,
        );
        final distanceB = _calculateDistance(
          latitude,
          longitude,
          b.latitude!,
          b.longitude!,
        );
        return distanceA.compareTo(distanceB);
      });

      return Right(nearbyUsers);
    });
  }

  @override
  Stream<Either<Failure, UserProfileModel>> watchUserProfile(String uid) {
    return dataSource.watchUserProfile(uid);
  }

  /// Calculate distance between two points using Haversine formula
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final double c = 2 * asin(sqrt(a));

    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }
}
