import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/system_metrics.dart';
import '../../domain/entities/booking_analytics.dart';
import '../../domain/usecases/get_system_metrics.dart';
import '../../domain/usecases/get_booking_analytics.dart';
import '../../domain/repositories/analytics_repository.dart';

/// BLoC for admin dashboard
class AdminDashboardBloc
    extends Bloc<AdminDashboardEvent, AdminDashboardState> {
  final GetSystemMetrics _getSystemMetrics;
  final GetBookingAnalytics _getBookingAnalytics;
  final AnalyticsRepository _analyticsRepository;
  StreamSubscription<Either<Failure, SystemMetrics>>? _metricsSubscription;

  AdminDashboardBloc({
    required GetSystemMetrics getSystemMetrics,
    required GetBookingAnalytics getBookingAnalytics,
    required AnalyticsRepository analyticsRepository,
  }) : _getSystemMetrics = getSystemMetrics,
       _getBookingAnalytics = getBookingAnalytics,
       _analyticsRepository = analyticsRepository,
       super(AdminDashboardInitial()) {
    on<AdminDashboardStarted>(_onDashboardStarted);
    on<AdminDashboardRefreshRequested>(_onRefreshRequested);
    on<AdminDashboardMetricsUpdated>(_onMetricsUpdated);
    on<AdminDashboardDateRangeChanged>(_onDateRangeChanged);
    on<AdminDashboardRealTimeToggled>(_onRealTimeToggled);
  }

  @override
  Future<void> close() {
    _metricsSubscription?.cancel();
    return super.close();
  }

  Future<void> _onDashboardStarted(
    AdminDashboardStarted event,
    Emitter<AdminDashboardState> emit,
  ) async {
    emit(AdminDashboardLoading());
    await _loadDashboardData(emit, event.startDate, event.endDate);
  }

  Future<void> _onRefreshRequested(
    AdminDashboardRefreshRequested event,
    Emitter<AdminDashboardState> emit,
  ) async {
    if (state is AdminDashboardLoaded) {
      final currentState = state as AdminDashboardLoaded;
      emit(currentState.copyWith(isRefreshing: true));
      await _loadDashboardData(emit, event.startDate, event.endDate);
    } else {
      emit(AdminDashboardLoading());
      await _loadDashboardData(emit, event.startDate, event.endDate);
    }
  }

  Future<void> _onMetricsUpdated(
    AdminDashboardMetricsUpdated event,
    Emitter<AdminDashboardState> emit,
  ) async {
    if (state is AdminDashboardLoaded) {
      final currentState = state as AdminDashboardLoaded;
      emit(
        currentState.copyWith(
          systemMetrics: event.systemMetrics,
          lastUpdated: DateTime.now(),
        ),
      );
    }
  }

  Future<void> _onDateRangeChanged(
    AdminDashboardDateRangeChanged event,
    Emitter<AdminDashboardState> emit,
  ) async {
    if (state is AdminDashboardLoaded) {
      final currentState = state as AdminDashboardLoaded;
      emit(currentState.copyWith(isRefreshing: true));
      await _loadDashboardData(emit, event.startDate, event.endDate);
    }
  }

  Future<void> _onRealTimeToggled(
    AdminDashboardRealTimeToggled event,
    Emitter<AdminDashboardState> emit,
  ) async {
    if (state is AdminDashboardLoaded) {
      final currentState = state as AdminDashboardLoaded;

      if (event.enabled) {
        // Start real-time updates
        _metricsSubscription?.cancel();
        _metricsSubscription = _analyticsRepository.watchSystemMetrics().listen(
          (result) => result.fold(
            (failure) => add(AdminDashboardErrorOccurred(failure.message)),
            (metrics) => add(AdminDashboardMetricsUpdated(metrics)),
          ),
        );

        emit(currentState.copyWith(isRealTimeEnabled: true));
      } else {
        // Stop real-time updates
        _metricsSubscription?.cancel();
        emit(currentState.copyWith(isRealTimeEnabled: false));
      }
    }
  }

  Future<void> _loadDashboardData(
    Emitter<AdminDashboardState> emit,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      // Load system metrics
      final systemMetricsResult = await _getSystemMetrics();

      if (systemMetricsResult.isLeft()) {
        final failure = systemMetricsResult.fold((l) => l, (r) => null)!;
        emit(AdminDashboardError(failure.message));
        return;
      }

      final systemMetrics = systemMetricsResult.fold((l) => null, (r) => r)!;

      // Load booking analytics
      final bookingAnalyticsResult = await _getBookingAnalytics(
        GetBookingAnalyticsParams(startDate: startDate, endDate: endDate),
      );

      if (bookingAnalyticsResult.isLeft()) {
        final failure = bookingAnalyticsResult.fold((l) => l, (r) => null)!;
        emit(AdminDashboardError(failure.message));
        return;
      }

      final bookingAnalytics = bookingAnalyticsResult.fold(
        (l) => null,
        (r) => r,
      )!;

      // Get analytics summary
      final summaryResult = await _analyticsRepository.getAnalyticsSummary(
        startDate: startDate,
        endDate: endDate,
      );

      final summary = summaryResult.fold((l) => null, (r) => r);

      emit(
        AdminDashboardLoaded(
          systemMetrics: systemMetrics,
          bookingAnalytics: bookingAnalytics,
          analyticsSummary: summary,
          startDate: startDate,
          endDate: endDate,
          lastUpdated: DateTime.now(),
          isRealTimeEnabled: false,
          isRefreshing: false,
        ),
      );
    } catch (e) {
      emit(AdminDashboardError('Failed to load dashboard data: $e'));
    }
  }
}

/// Admin dashboard events
abstract class AdminDashboardEvent extends Equatable {
  const AdminDashboardEvent();

  @override
  List<Object?> get props => [];
}

class AdminDashboardStarted extends AdminDashboardEvent {
  final DateTime startDate;
  final DateTime endDate;

  const AdminDashboardStarted({required this.startDate, required this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}

class AdminDashboardRefreshRequested extends AdminDashboardEvent {
  final DateTime startDate;
  final DateTime endDate;

  const AdminDashboardRefreshRequested({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

class AdminDashboardMetricsUpdated extends AdminDashboardEvent {
  final SystemMetrics systemMetrics;

  const AdminDashboardMetricsUpdated(this.systemMetrics);

  @override
  List<Object?> get props => [systemMetrics];
}

class AdminDashboardDateRangeChanged extends AdminDashboardEvent {
  final DateTime startDate;
  final DateTime endDate;

  const AdminDashboardDateRangeChanged({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

class AdminDashboardRealTimeToggled extends AdminDashboardEvent {
  final bool enabled;

  const AdminDashboardRealTimeToggled(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class AdminDashboardErrorOccurred extends AdminDashboardEvent {
  final String message;

  const AdminDashboardErrorOccurred(this.message);

  @override
  List<Object?> get props => [message];
}

/// Admin dashboard states
abstract class AdminDashboardState extends Equatable {
  const AdminDashboardState();

  @override
  List<Object?> get props => [];
}

class AdminDashboardInitial extends AdminDashboardState {}

class AdminDashboardLoading extends AdminDashboardState {}

class AdminDashboardLoaded extends AdminDashboardState {
  final SystemMetrics systemMetrics;
  final BookingAnalytics bookingAnalytics;
  final AnalyticsSummary? analyticsSummary;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime lastUpdated;
  final bool isRealTimeEnabled;
  final bool isRefreshing;

  const AdminDashboardLoaded({
    required this.systemMetrics,
    required this.bookingAnalytics,
    this.analyticsSummary,
    required this.startDate,
    required this.endDate,
    required this.lastUpdated,
    this.isRealTimeEnabled = false,
    this.isRefreshing = false,
  });

  AdminDashboardLoaded copyWith({
    SystemMetrics? systemMetrics,
    BookingAnalytics? bookingAnalytics,
    AnalyticsSummary? analyticsSummary,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? lastUpdated,
    bool? isRealTimeEnabled,
    bool? isRefreshing,
  }) {
    return AdminDashboardLoaded(
      systemMetrics: systemMetrics ?? this.systemMetrics,
      bookingAnalytics: bookingAnalytics ?? this.bookingAnalytics,
      analyticsSummary: analyticsSummary ?? this.analyticsSummary,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isRealTimeEnabled: isRealTimeEnabled ?? this.isRealTimeEnabled,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [
    systemMetrics,
    bookingAnalytics,
    analyticsSummary,
    startDate,
    endDate,
    lastUpdated,
    isRealTimeEnabled,
    isRefreshing,
  ];
}

class AdminDashboardError extends AdminDashboardState {
  final String message;

  const AdminDashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
