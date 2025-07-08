import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/admin_user.dart';
import '../../domain/usecases/authenticate_admin.dart';
import '../../domain/repositories/admin_repository.dart';

/// BLoC for admin authentication
class AdminAuthBloc extends Bloc<AdminAuthEvent, AdminAuthState> {
  final AuthenticateAdmin _authenticateAdmin;
  final AdminRepository _adminRepository;
  late StreamSubscription<AdminUser> _authStateSubscription;

  AdminAuthBloc({
    required AuthenticateAdmin authenticateAdmin,
    required AdminRepository adminRepository,
  })  : _authenticateAdmin = authenticateAdmin,
        _adminRepository = adminRepository,
        super(AdminAuthInitial()) {
    on<AdminAuthStarted>(_onAuthStarted);
    on<AdminLoginRequested>(_onLoginRequested);
    on<AdminLogoutRequested>(_onLogoutRequested);
    on<AdminAuthStateChanged>(_onAuthStateChanged);
    on<AdminSessionValidationRequested>(_onSessionValidationRequested);

    // Listen to auth state changes
    _authStateSubscription = _adminRepository.authStateChanges.listen(
      (admin) => add(AdminAuthStateChanged(admin)),
    );
  }

  @override
  Future<void> close() {
    _authStateSubscription.cancel();
    return super.close();
  }

  Future<void> _onAuthStarted(
    AdminAuthStarted event,
    Emitter<AdminAuthState> emit,
  ) async {
    final currentAdmin = _adminRepository.currentAdmin;
    if (currentAdmin.isNotEmpty && currentAdmin.isActive) {
      emit(AdminAuthenticated(currentAdmin));
    } else {
      emit(AdminUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    AdminLoginRequested event,
    Emitter<AdminAuthState> emit,
  ) async {
    emit(AdminAuthLoading());

    final result = await _authenticateAdmin(
      AuthenticateAdminParams(
        email: event.email,
        password: event.password,
      ),
    );

    result.fold(
      (failure) => emit(AdminAuthError(failure.message)),
      (admin) => emit(AdminAuthenticated(admin)),
    );
  }

  Future<void> _onLogoutRequested(
    AdminLogoutRequested event,
    Emitter<AdminAuthState> emit,
  ) async {
    emit(AdminAuthLoading());

    final result = await _adminRepository.signOut();

    result.fold(
      (failure) => emit(AdminAuthError(failure.message)),
      (_) => emit(AdminUnauthenticated()),
    );
  }

  Future<void> _onAuthStateChanged(
    AdminAuthStateChanged event,
    Emitter<AdminAuthState> emit,
  ) async {
    if (event.admin.isNotEmpty && event.admin.isActive) {
      emit(AdminAuthenticated(event.admin));
    } else {
      emit(AdminUnauthenticated());
    }
  }

  Future<void> _onSessionValidationRequested(
    AdminSessionValidationRequested event,
    Emitter<AdminAuthState> emit,
  ) async {
    final result = await _adminRepository.validateSession();

    result.fold(
      (failure) => emit(AdminAuthError(failure.message)),
      (isValid) {
        if (!isValid) {
          emit(AdminUnauthenticated());
        }
      },
    );
  }
}

/// Admin authentication events
abstract class AdminAuthEvent extends Equatable {
  const AdminAuthEvent();

  @override
  List<Object?> get props => [];
}

class AdminAuthStarted extends AdminAuthEvent {}

class AdminLoginRequested extends AdminAuthEvent {
  final String email;
  final String password;

  const AdminLoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class AdminLogoutRequested extends AdminAuthEvent {}

class AdminAuthStateChanged extends AdminAuthEvent {
  final AdminUser admin;

  const AdminAuthStateChanged(this.admin);

  @override
  List<Object?> get props => [admin];
}

class AdminSessionValidationRequested extends AdminAuthEvent {}

/// Admin authentication states
abstract class AdminAuthState extends Equatable {
  const AdminAuthState();

  @override
  List<Object?> get props => [];
}

class AdminAuthInitial extends AdminAuthState {}

class AdminAuthLoading extends AdminAuthState {}

class AdminAuthenticated extends AdminAuthState {
  final AdminUser admin;

  const AdminAuthenticated(this.admin);

  @override
  List<Object?> get props => [admin];
}

class AdminUnauthenticated extends AdminAuthState {}

class AdminAuthError extends AdminAuthState {
  final String message;

  const AdminAuthError(this.message);

  @override
  List<Object?> get props => [message];
}
