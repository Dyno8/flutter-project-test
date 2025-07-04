import 'package:equatable/equatable.dart';

import '../../domain/entities/auth_user.dart';

/// Base class for all authentication states
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state when the app starts
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// State when checking authentication status
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// State when user is authenticated
class AuthAuthenticated extends AuthState {
  final AuthUser user;

  const AuthAuthenticated({required this.user});

  @override
  List<Object> get props => [user];
}

/// State when user is not authenticated
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// State when authentication operation is in progress
class AuthInProgress extends AuthState {
  final String message;

  const AuthInProgress({required this.message});

  @override
  List<Object> get props => [message];
}

/// State when phone verification code is sent
class AuthPhoneCodeSent extends AuthState {
  final String verificationId;
  final String phoneNumber;

  const AuthPhoneCodeSent({
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  List<Object> get props => [verificationId, phoneNumber];
}

/// State when authentication operation succeeds
class AuthSuccess extends AuthState {
  final String message;
  final AuthUser? user;

  const AuthSuccess({
    required this.message,
    this.user,
  });

  @override
  List<Object?> get props => [message, user];
}

/// State when authentication operation fails
class AuthFailure extends AuthState {
  final String message;

  const AuthFailure({required this.message});

  @override
  List<Object> get props => [message];
}

/// State when email verification is sent
class AuthEmailVerificationSent extends AuthState {
  const AuthEmailVerificationSent();
}

/// State when password reset email is sent
class AuthPasswordResetSent extends AuthState {
  final String email;

  const AuthPasswordResetSent({required this.email});

  @override
  List<Object> get props => [email];
}

/// State when profile is updated successfully
class AuthProfileUpdated extends AuthState {
  final AuthUser user;

  const AuthProfileUpdated({required this.user});

  @override
  List<Object> get props => [user];
}

/// State when email is updated successfully
class AuthEmailUpdated extends AuthState {
  const AuthEmailUpdated();
}

/// State when password is updated successfully
class AuthPasswordUpdated extends AuthState {
  const AuthPasswordUpdated();
}

/// State when account is deleted successfully
class AuthAccountDeleted extends AuthState {
  const AuthAccountDeleted();
}
