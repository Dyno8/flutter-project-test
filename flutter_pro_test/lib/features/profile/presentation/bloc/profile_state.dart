import 'package:equatable/equatable.dart';

import '../../../../shared/models/user_profile_model.dart';

/// Base class for all profile states
abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

/// Loading state
class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

/// Profile loaded successfully
class ProfileLoaded extends ProfileState {
  final UserProfileModel profile;

  const ProfileLoaded({required this.profile});

  @override
  List<Object> get props => [profile];
}

/// Profile operation in progress
class ProfileOperationInProgress extends ProfileState {
  final String message;

  const ProfileOperationInProgress({required this.message});

  @override
  List<Object> get props => [message];
}

/// Profile created successfully
class ProfileCreated extends ProfileState {
  final UserProfileModel profile;

  const ProfileCreated({required this.profile});

  @override
  List<Object> get props => [profile];
}

/// Profile updated successfully
class ProfileUpdated extends ProfileState {
  final UserProfileModel profile;

  const ProfileUpdated({required this.profile});

  @override
  List<Object> get props => [profile];
}

/// Avatar updated successfully
class AvatarUpdated extends ProfileState {
  final String avatarUrl;

  const AvatarUpdated({required this.avatarUrl});

  @override
  List<Object> get props => [avatarUrl];
}

/// Location updated successfully
class LocationUpdated extends ProfileState {
  const LocationUpdated();
}

/// Preferences updated successfully
class PreferencesUpdated extends ProfileState {
  const PreferencesUpdated();
}

/// Phone number verified successfully
class PhoneNumberVerified extends ProfileState {
  const PhoneNumberVerified();
}

/// Email verified successfully
class EmailVerified extends ProfileState {
  const EmailVerified();
}

/// Profile operation failed
class ProfileError extends ProfileState {
  final String message;

  const ProfileError({required this.message});

  @override
  List<Object> get props => [message];
}

/// Profile not found
class ProfileNotFound extends ProfileState {
  const ProfileNotFound();
}
