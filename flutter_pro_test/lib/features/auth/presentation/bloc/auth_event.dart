import 'package:equatable/equatable.dart';

/// Base class for all authentication events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event to check authentication status on app start
class AuthStatusRequested extends AuthEvent {
  const AuthStatusRequested();
}

/// Event for signing in with email and password
class SignInWithEmailRequested extends AuthEvent {
  final String email;
  final String password;

  const SignInWithEmailRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

/// Event for signing up with email and password
class SignUpWithEmailRequested extends AuthEvent {
  final String email;
  final String password;
  final String confirmPassword;
  final String displayName;

  const SignUpWithEmailRequested({
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.displayName,
  });

  @override
  List<Object> get props => [email, password, confirmPassword, displayName];
}

/// Event for signing in with phone number
class SignInWithPhoneRequested extends AuthEvent {
  final String phoneNumber;

  const SignInWithPhoneRequested({
    required this.phoneNumber,
  });

  @override
  List<Object> get props => [phoneNumber];
}

/// Event for verifying phone number with OTP
class VerifyPhoneNumberRequested extends AuthEvent {
  final String verificationId;
  final String smsCode;

  const VerifyPhoneNumberRequested({
    required this.verificationId,
    required this.smsCode,
  });

  @override
  List<Object> get props => [verificationId, smsCode];
}

/// Event for sending email verification
class SendEmailVerificationRequested extends AuthEvent {
  const SendEmailVerificationRequested();
}

/// Event for sending password reset email
class SendPasswordResetRequested extends AuthEvent {
  final String email;

  const SendPasswordResetRequested({
    required this.email,
  });

  @override
  List<Object> get props => [email];
}

/// Event for updating user profile
class UpdateProfileRequested extends AuthEvent {
  final String? displayName;
  final String? photoURL;

  const UpdateProfileRequested({
    this.displayName,
    this.photoURL,
  });

  @override
  List<Object?> get props => [displayName, photoURL];
}

/// Event for updating user email
class UpdateEmailRequested extends AuthEvent {
  final String newEmail;

  const UpdateEmailRequested({
    required this.newEmail,
  });

  @override
  List<Object> get props => [newEmail];
}

/// Event for updating user password
class UpdatePasswordRequested extends AuthEvent {
  final String currentPassword;
  final String newPassword;

  const UpdatePasswordRequested({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object> get props => [currentPassword, newPassword];
}

/// Event for signing out
class SignOutRequested extends AuthEvent {
  const SignOutRequested();
}

/// Event for deleting user account
class DeleteAccountRequested extends AuthEvent {
  const DeleteAccountRequested();
}

/// Event for refreshing user data
class RefreshUserRequested extends AuthEvent {
  const RefreshUserRequested();
}

/// Event when authentication state changes (from Firebase stream)
class AuthStateChanged extends AuthEvent {
  final bool isAuthenticated;

  const AuthStateChanged({
    required this.isAuthenticated,
  });

  @override
  List<Object> get props => [isAuthenticated];
}
