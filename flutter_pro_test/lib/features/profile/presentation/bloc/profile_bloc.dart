import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_user_profile.dart';
import '../../domain/usecases/create_user_profile.dart';
import '../../domain/usecases/update_user_profile.dart';
import '../../domain/usecases/update_profile_avatar.dart';
import '../../domain/repositories/user_profile_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

/// BLoC for managing user profile state
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUserProfile _getUserProfile;
  final CreateUserProfile _createUserProfile;
  final UpdateUserProfile _updateUserProfile;
  final UpdateProfileAvatar _updateProfileAvatar;
  final UserProfileRepository _repository;

  StreamSubscription? _profileSubscription;

  ProfileBloc({
    required GetUserProfile getUserProfile,
    required CreateUserProfile createUserProfile,
    required UpdateUserProfile updateUserProfile,
    required UpdateProfileAvatar updateProfileAvatar,
    required UserProfileRepository repository,
  })  : _getUserProfile = getUserProfile,
        _createUserProfile = createUserProfile,
        _updateUserProfile = updateUserProfile,
        _updateProfileAvatar = updateProfileAvatar,
        _repository = repository,
        super(const ProfileInitial()) {
    // Register event handlers
    on<LoadUserProfile>(_onLoadUserProfile);
    on<CreateUserProfile>(_onCreateUserProfile);
    on<UpdateUserProfile>(_onUpdateUserProfile);
    on<UpdateProfileAvatar>(_onUpdateProfileAvatar);
    on<UpdateUserLocation>(_onUpdateUserLocation);
    on<UpdateUserPreferences>(_onUpdateUserPreferences);
    on<VerifyPhoneNumber>(_onVerifyPhoneNumber);
    on<VerifyEmail>(_onVerifyEmail);
    on<RefreshProfile>(_onRefreshProfile);
    on<ClearProfile>(_onClearProfile);
    on<StartWatchingProfile>(_onStartWatchingProfile);
    on<StopWatchingProfile>(_onStopWatchingProfile);
  }

  @override
  Future<void> close() {
    _profileSubscription?.cancel();
    return super.close();
  }

  /// Handle load user profile
  Future<void> _onLoadUserProfile(
    LoadUserProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());

    final result = await _getUserProfile(GetUserProfileParams(uid: event.uid));

    result.fold(
      (failure) => emit(ProfileError(message: failure.message)),
      (profile) => emit(ProfileLoaded(profile: profile)),
    );
  }

  /// Handle create user profile
  Future<void> _onCreateUserProfile(
    CreateUserProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileOperationInProgress(message: 'Tạo hồ sơ...'));

    final result = await _createUserProfile(
      CreateUserProfileParams(profile: event.profile),
    );

    result.fold(
      (failure) => emit(ProfileError(message: failure.message)),
      (profile) => emit(ProfileCreated(profile: profile)),
    );
  }

  /// Handle update user profile
  Future<void> _onUpdateUserProfile(
    UpdateUserProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileOperationInProgress(message: 'Cập nhật hồ sơ...'));

    final result = await _updateUserProfile(
      UpdateUserProfileParams(profile: event.profile),
    );

    result.fold(
      (failure) => emit(ProfileError(message: failure.message)),
      (profile) => emit(ProfileUpdated(profile: profile)),
    );
  }

  /// Handle update profile avatar
  Future<void> _onUpdateProfileAvatar(
    UpdateProfileAvatar event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileOperationInProgress(message: 'Cập nhật ảnh đại diện...'));

    final result = await _updateProfileAvatar(
      UpdateProfileAvatarParams(
        uid: event.uid,
        imagePath: event.imagePath,
      ),
    );

    result.fold(
      (failure) => emit(ProfileError(message: failure.message)),
      (avatarUrl) => emit(AvatarUpdated(avatarUrl: avatarUrl)),
    );
  }

  /// Handle update user location
  Future<void> _onUpdateUserLocation(
    UpdateUserLocation event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileOperationInProgress(message: 'Cập nhật vị trí...'));

    final result = await _repository.updateUserLocation(
      event.uid,
      event.latitude,
      event.longitude,
    );

    result.fold(
      (failure) => emit(ProfileError(message: failure.message)),
      (_) => emit(const LocationUpdated()),
    );
  }

  /// Handle update user preferences
  Future<void> _onUpdateUserPreferences(
    UpdateUserPreferences event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileOperationInProgress(message: 'Cập nhật sở thích...'));

    final result = await _repository.updateUserPreferences(
      event.uid,
      event.preferences,
    );

    result.fold(
      (failure) => emit(ProfileError(message: failure.message)),
      (_) => emit(const PreferencesUpdated()),
    );
  }

  /// Handle verify phone number
  Future<void> _onVerifyPhoneNumber(
    VerifyPhoneNumber event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileOperationInProgress(message: 'Xác thực số điện thoại...'));

    final result = await _repository.verifyPhoneNumber(event.uid);

    result.fold(
      (failure) => emit(ProfileError(message: failure.message)),
      (_) => emit(const PhoneNumberVerified()),
    );
  }

  /// Handle verify email
  Future<void> _onVerifyEmail(
    VerifyEmail event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileOperationInProgress(message: 'Xác thực email...'));

    final result = await _repository.verifyEmail(event.uid);

    result.fold(
      (failure) => emit(ProfileError(message: failure.message)),
      (_) => emit(const EmailVerified()),
    );
  }

  /// Handle refresh profile
  Future<void> _onRefreshProfile(
    RefreshProfile event,
    Emitter<ProfileState> emit,
  ) async {
    final result = await _getUserProfile(GetUserProfileParams(uid: event.uid));

    result.fold(
      (failure) => emit(ProfileError(message: failure.message)),
      (profile) => emit(ProfileLoaded(profile: profile)),
    );
  }

  /// Handle clear profile
  Future<void> _onClearProfile(
    ClearProfile event,
    Emitter<ProfileState> emit,
  ) async {
    _profileSubscription?.cancel();
    emit(const ProfileInitial());
  }

  /// Handle start watching profile
  Future<void> _onStartWatchingProfile(
    StartWatchingProfile event,
    Emitter<ProfileState> emit,
  ) async {
    _profileSubscription?.cancel();
    
    _profileSubscription = _repository.watchUserProfile(event.uid).listen(
      (result) {
        result.fold(
          (failure) => add(const ClearProfile()),
          (profile) => emit(ProfileLoaded(profile: profile)),
        );
      },
    );
  }

  /// Handle stop watching profile
  Future<void> _onStopWatchingProfile(
    StopWatchingProfile event,
    Emitter<ProfileState> emit,
  ) async {
    _profileSubscription?.cancel();
  }
}
