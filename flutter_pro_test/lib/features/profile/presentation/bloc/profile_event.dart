import 'package:equatable/equatable.dart';

import '../../../../shared/models/user_profile_model.dart';

/// Base class for all profile events
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load user profile
class LoadUserProfile extends ProfileEvent {
  final String uid;

  const LoadUserProfile({required this.uid});

  @override
  List<Object> get props => [uid];
}

/// Event to create user profile
class CreateUserProfile extends ProfileEvent {
  final UserProfileModel profile;

  const CreateUserProfile({required this.profile});

  @override
  List<Object> get props => [profile];
}

/// Event to update user profile
class UpdateUserProfile extends ProfileEvent {
  final UserProfileModel profile;

  const UpdateUserProfile({required this.profile});

  @override
  List<Object> get props => [profile];
}

/// Event to update profile avatar
class UpdateProfileAvatar extends ProfileEvent {
  final String uid;
  final String imagePath;

  const UpdateProfileAvatar({
    required this.uid,
    required this.imagePath,
  });

  @override
  List<Object> get props => [uid, imagePath];
}

/// Event to update user location
class UpdateUserLocation extends ProfileEvent {
  final String uid;
  final double latitude;
  final double longitude;

  const UpdateUserLocation({
    required this.uid,
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object> get props => [uid, latitude, longitude];
}

/// Event to update user preferences
class UpdateUserPreferences extends ProfileEvent {
  final String uid;
  final List<String> preferences;

  const UpdateUserPreferences({
    required this.uid,
    required this.preferences,
  });

  @override
  List<Object> get props => [uid, preferences];
}

/// Event to verify phone number
class VerifyPhoneNumber extends ProfileEvent {
  final String uid;

  const VerifyPhoneNumber({required this.uid});

  @override
  List<Object> get props => [uid];
}

/// Event to verify email
class VerifyEmail extends ProfileEvent {
  final String uid;

  const VerifyEmail({required this.uid});

  @override
  List<Object> get props => [uid];
}

/// Event to refresh profile data
class RefreshProfile extends ProfileEvent {
  final String uid;

  const RefreshProfile({required this.uid});

  @override
  List<Object> get props => [uid];
}

/// Event to clear profile data
class ClearProfile extends ProfileEvent {
  const ClearProfile();
}

/// Event to start watching profile changes
class StartWatchingProfile extends ProfileEvent {
  final String uid;

  const StartWatchingProfile({required this.uid});

  @override
  List<Object> get props => [uid];
}

/// Event to stop watching profile changes
class StopWatchingProfile extends ProfileEvent {
  const StopWatchingProfile();
}
