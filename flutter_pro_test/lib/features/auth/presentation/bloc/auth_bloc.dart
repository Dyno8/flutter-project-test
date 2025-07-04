import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/sign_in_with_email.dart';
import '../../domain/usecases/sign_up_with_email.dart';
import '../../domain/usecases/sign_in_with_phone.dart';
import '../../domain/usecases/verify_phone_number.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/get_current_user.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// BLoC for managing authentication state
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final SignInWithEmail _signInWithEmail;
  final SignUpWithEmail _signUpWithEmail;
  final SignInWithPhone _signInWithPhone;
  final VerifyPhoneNumber _verifyPhoneNumber;
  final SignOut _signOut;
  final GetCurrentUser _getCurrentUser;

  StreamSubscription<AuthUser>? _authStateSubscription;

  AuthBloc({
    required AuthRepository authRepository,
    required SignInWithEmail signInWithEmail,
    required SignUpWithEmail signUpWithEmail,
    required SignInWithPhone signInWithPhone,
    required VerifyPhoneNumber verifyPhoneNumber,
    required SignOut signOut,
    required GetCurrentUser getCurrentUser,
  }) : _authRepository = authRepository,
       _signInWithEmail = signInWithEmail,
       _signUpWithEmail = signUpWithEmail,
       _signInWithPhone = signInWithPhone,
       _verifyPhoneNumber = verifyPhoneNumber,
       _signOut = signOut,
       _getCurrentUser = getCurrentUser,
       super(const AuthInitial()) {
    // Register event handlers
    on<AuthStatusRequested>(_onAuthStatusRequested);
    on<SignInWithEmailRequested>(_onSignInWithEmailRequested);
    on<SignUpWithEmailRequested>(_onSignUpWithEmailRequested);
    on<SignInWithPhoneRequested>(_onSignInWithPhoneRequested);
    on<VerifyPhoneNumberRequested>(_onVerifyPhoneNumberRequested);
    on<SendEmailVerificationRequested>(_onSendEmailVerificationRequested);
    on<SendPasswordResetRequested>(_onSendPasswordResetRequested);
    on<UpdateProfileRequested>(_onUpdateProfileRequested);
    on<UpdateEmailRequested>(_onUpdateEmailRequested);
    on<UpdatePasswordRequested>(_onUpdatePasswordRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<DeleteAccountRequested>(_onDeleteAccountRequested);
    on<RefreshUserRequested>(_onRefreshUserRequested);
    on<AuthStateChanged>(_onAuthStateChanged);

    // Listen to authentication state changes
    _authStateSubscription = _authRepository.authStateChanges.listen((user) {
      add(AuthStateChanged(isAuthenticated: user.isNotEmpty));
    });
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }

  /// Handle authentication status request
  Future<void> _onAuthStatusRequested(
    AuthStatusRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final currentUser = _authRepository.currentUser;
    if (currentUser.isNotEmpty) {
      emit(AuthAuthenticated(user: currentUser));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  /// Handle sign in with email request
  Future<void> _onSignInWithEmailRequested(
    SignInWithEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthInProgress(message: 'Signing in...'));

    final result = await _signInWithEmail(
      SignInWithEmailParams(email: event.email, password: event.password),
    );

    result.fold(
      (failure) => emit(AuthFailure(message: failure.message)),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  /// Handle sign up with email request
  Future<void> _onSignUpWithEmailRequested(
    SignUpWithEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthInProgress(message: 'Creating account...'));

    final result = await _signUpWithEmail(
      SignUpWithEmailParams(
        email: event.email,
        password: event.password,
        confirmPassword: event.confirmPassword,
        displayName: event.displayName,
      ),
    );

    result.fold(
      (failure) => emit(AuthFailure(message: failure.message)),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  /// Handle sign in with phone request
  Future<void> _onSignInWithPhoneRequested(
    SignInWithPhoneRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthInProgress(message: 'Sending verification code...'));

    final result = await _signInWithPhone(
      SignInWithPhoneParams(phoneNumber: event.phoneNumber),
    );

    result.fold((failure) => emit(AuthFailure(message: failure.message)), (
      verificationId,
    ) {
      if (verificationId == 'auto-verified') {
        // Auto-verification completed (Android only)
        final currentUser = _authRepository.currentUser;
        emit(AuthAuthenticated(user: currentUser));
      } else {
        emit(
          AuthPhoneCodeSent(
            verificationId: verificationId,
            phoneNumber: event.phoneNumber,
          ),
        );
      }
    });
  }

  /// Handle verify phone number request
  Future<void> _onVerifyPhoneNumberRequested(
    VerifyPhoneNumberRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthInProgress(message: 'Verifying code...'));

    final result = await _verifyPhoneNumber(
      VerifyPhoneNumberParams(
        verificationId: event.verificationId,
        smsCode: event.smsCode,
      ),
    );

    result.fold(
      (failure) => emit(AuthFailure(message: failure.message)),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  /// Handle send email verification request
  Future<void> _onSendEmailVerificationRequested(
    SendEmailVerificationRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthInProgress(message: 'Sending verification email...'));

    final result = await _authRepository.sendEmailVerification();

    result.fold(
      (failure) => emit(AuthFailure(message: failure.message)),
      (_) => emit(const AuthEmailVerificationSent()),
    );
  }

  /// Handle send password reset request
  Future<void> _onSendPasswordResetRequested(
    SendPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthInProgress(message: 'Sending password reset email...'));

    final result = await _authRepository.sendPasswordResetEmail(
      email: event.email,
    );

    result.fold(
      (failure) => emit(AuthFailure(message: failure.message)),
      (_) => emit(AuthPasswordResetSent(email: event.email)),
    );
  }

  /// Handle update profile request
  Future<void> _onUpdateProfileRequested(
    UpdateProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthInProgress(message: 'Updating profile...'));

    final result = await _authRepository.updateProfile(
      displayName: event.displayName,
      photoURL: event.photoURL,
    );

    result.fold((failure) => emit(AuthFailure(message: failure.message)), (_) {
      final updatedUser = _authRepository.currentUser;
      emit(AuthProfileUpdated(user: updatedUser));
    });
  }

  /// Handle update email request
  Future<void> _onUpdateEmailRequested(
    UpdateEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthInProgress(message: 'Updating email...'));

    final result = await _authRepository.updateEmail(newEmail: event.newEmail);

    result.fold(
      (failure) => emit(AuthFailure(message: failure.message)),
      (_) => emit(const AuthEmailUpdated()),
    );
  }

  /// Handle update password request
  Future<void> _onUpdatePasswordRequested(
    UpdatePasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthInProgress(message: 'Updating password...'));

    final result = await _authRepository.updatePassword(
      currentPassword: event.currentPassword,
      newPassword: event.newPassword,
    );

    result.fold(
      (failure) => emit(AuthFailure(message: failure.message)),
      (_) => emit(const AuthPasswordUpdated()),
    );
  }

  /// Handle sign out request
  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthInProgress(message: 'Signing out...'));

    final result = await _signOut();

    result.fold(
      (failure) => emit(AuthFailure(message: failure.message)),
      (_) => emit(const AuthUnauthenticated()),
    );
  }

  /// Handle delete account request
  Future<void> _onDeleteAccountRequested(
    DeleteAccountRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthInProgress(message: 'Deleting account...'));

    final result = await _authRepository.deleteAccount();

    result.fold(
      (failure) => emit(AuthFailure(message: failure.message)),
      (_) => emit(const AuthAccountDeleted()),
    );
  }

  /// Handle refresh user request
  Future<void> _onRefreshUserRequested(
    RefreshUserRequested event,
    Emitter<AuthState> emit,
  ) async {
    final result = await _authRepository.refreshUser();

    result.fold(
      (failure) => emit(AuthFailure(message: failure.message)),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  /// Handle authentication state change
  Future<void> _onAuthStateChanged(
    AuthStateChanged event,
    Emitter<AuthState> emit,
  ) async {
    if (event.isAuthenticated) {
      final currentUser = _authRepository.currentUser;
      emit(AuthAuthenticated(user: currentUser));
    } else {
      emit(const AuthUnauthenticated());
    }
  }
}
