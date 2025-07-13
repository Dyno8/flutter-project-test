import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/services/analytics_dashboard_service.dart';

// Events
abstract class AnalyticsDashboardEvent extends Equatable {
  const AnalyticsDashboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadAnalyticsDashboard extends AnalyticsDashboardEvent {
  const LoadAnalyticsDashboard();
}

class RefreshAnalyticsDashboard extends AnalyticsDashboardEvent {
  const RefreshAnalyticsDashboard();
}

class UpdateUserMetrics extends AnalyticsDashboardEvent {
  final Map<String, dynamic> metrics;

  const UpdateUserMetrics(this.metrics);

  @override
  List<Object?> get props => [metrics];
}

class UpdatePerformanceMetrics extends AnalyticsDashboardEvent {
  final Map<String, dynamic> metrics;

  const UpdatePerformanceMetrics(this.metrics);

  @override
  List<Object?> get props => [metrics];
}

class UpdateBusinessMetrics extends AnalyticsDashboardEvent {
  final Map<String, dynamic> metrics;

  const UpdateBusinessMetrics(this.metrics);

  @override
  List<Object?> get props => [metrics];
}

class UpdateErrorMetrics extends AnalyticsDashboardEvent {
  final Map<String, dynamic> metrics;

  const UpdateErrorMetrics(this.metrics);

  @override
  List<Object?> get props => [metrics];
}

class ExportAnalyticsData extends AnalyticsDashboardEvent {
  final String format; // 'pdf' or 'csv'

  const ExportAnalyticsData(this.format);

  @override
  List<Object?> get props => [format];
}

// States
abstract class AnalyticsDashboardState extends Equatable {
  const AnalyticsDashboardState();

  @override
  List<Object?> get props => [];
}

class AnalyticsDashboardInitial extends AnalyticsDashboardState {
  const AnalyticsDashboardInitial();
}

class AnalyticsDashboardLoading extends AnalyticsDashboardState {
  const AnalyticsDashboardLoading();
}

class AnalyticsDashboardLoaded extends AnalyticsDashboardState {
  final Map<String, dynamic> userMetrics;
  final Map<String, dynamic> performanceMetrics;
  final Map<String, dynamic> businessMetrics;
  final Map<String, dynamic> errorMetrics;
  final DateTime lastUpdated;

  const AnalyticsDashboardLoaded({
    required this.userMetrics,
    required this.performanceMetrics,
    required this.businessMetrics,
    required this.errorMetrics,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [
        userMetrics,
        performanceMetrics,
        businessMetrics,
        errorMetrics,
        lastUpdated,
      ];

  AnalyticsDashboardLoaded copyWith({
    Map<String, dynamic>? userMetrics,
    Map<String, dynamic>? performanceMetrics,
    Map<String, dynamic>? businessMetrics,
    Map<String, dynamic>? errorMetrics,
    DateTime? lastUpdated,
  }) {
    return AnalyticsDashboardLoaded(
      userMetrics: userMetrics ?? this.userMetrics,
      performanceMetrics: performanceMetrics ?? this.performanceMetrics,
      businessMetrics: businessMetrics ?? this.businessMetrics,
      errorMetrics: errorMetrics ?? this.errorMetrics,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class AnalyticsDashboardError extends AnalyticsDashboardState {
  final String message;

  const AnalyticsDashboardError(this.message);

  @override
  List<Object?> get props => [message];
}

class AnalyticsDashboardExporting extends AnalyticsDashboardState {
  final String format;

  const AnalyticsDashboardExporting(this.format);

  @override
  List<Object?> get props => [format];
}

class AnalyticsDashboardExported extends AnalyticsDashboardState {
  final String format;
  final String filePath;

  const AnalyticsDashboardExported(this.format, this.filePath);

  @override
  List<Object?> get props => [format, filePath];
}

// BLoC
class AnalyticsDashboardBloc extends Bloc<AnalyticsDashboardEvent, AnalyticsDashboardState> {
  final AnalyticsDashboardService _analyticsService;
  
  // Stream subscriptions
  StreamSubscription<Map<String, dynamic>>? _userMetricsSubscription;
  StreamSubscription<Map<String, dynamic>>? _performanceMetricsSubscription;
  StreamSubscription<Map<String, dynamic>>? _businessMetricsSubscription;
  StreamSubscription<Map<String, dynamic>>? _errorMetricsSubscription;

  AnalyticsDashboardBloc({
    required AnalyticsDashboardService analyticsService,
  })  : _analyticsService = analyticsService,
        super(const AnalyticsDashboardInitial()) {
    on<LoadAnalyticsDashboard>(_onLoadAnalyticsDashboard);
    on<RefreshAnalyticsDashboard>(_onRefreshAnalyticsDashboard);
    on<UpdateUserMetrics>(_onUpdateUserMetrics);
    on<UpdatePerformanceMetrics>(_onUpdatePerformanceMetrics);
    on<UpdateBusinessMetrics>(_onUpdateBusinessMetrics);
    on<UpdateErrorMetrics>(_onUpdateErrorMetrics);
    on<ExportAnalyticsData>(_onExportAnalyticsData);
  }

  Future<void> _onLoadAnalyticsDashboard(
    LoadAnalyticsDashboard event,
    Emitter<AnalyticsDashboardState> emit,
  ) async {
    try {
      emit(const AnalyticsDashboardLoading());

      // Initialize the analytics service
      await _analyticsService.initialize();

      // Subscribe to real-time streams
      _subscribeToStreams();

      // Get initial data
      final userMetrics = _analyticsService.latestUserMetrics;
      final performanceMetrics = _analyticsService.latestPerformanceMetrics;
      final businessMetrics = _analyticsService.latestBusinessMetrics;
      final errorMetrics = _analyticsService.latestErrorMetrics;

      emit(AnalyticsDashboardLoaded(
        userMetrics: userMetrics,
        performanceMetrics: performanceMetrics,
        businessMetrics: businessMetrics,
        errorMetrics: errorMetrics,
        lastUpdated: DateTime.now(),
      ));
    } catch (e) {
      emit(AnalyticsDashboardError('Failed to load analytics dashboard: $e'));
    }
  }

  Future<void> _onRefreshAnalyticsDashboard(
    RefreshAnalyticsDashboard event,
    Emitter<AnalyticsDashboardState> emit,
  ) async {
    try {
      // Force refresh all metrics
      await _analyticsService.refreshAllMetrics();

      if (state is AnalyticsDashboardLoaded) {
        final currentState = state as AnalyticsDashboardLoaded;
        emit(currentState.copyWith(lastUpdated: DateTime.now()));
      }
    } catch (e) {
      emit(AnalyticsDashboardError('Failed to refresh analytics dashboard: $e'));
    }
  }

  void _onUpdateUserMetrics(
    UpdateUserMetrics event,
    Emitter<AnalyticsDashboardState> emit,
  ) {
    if (state is AnalyticsDashboardLoaded) {
      final currentState = state as AnalyticsDashboardLoaded;
      emit(currentState.copyWith(
        userMetrics: event.metrics,
        lastUpdated: DateTime.now(),
      ));
    }
  }

  void _onUpdatePerformanceMetrics(
    UpdatePerformanceMetrics event,
    Emitter<AnalyticsDashboardState> emit,
  ) {
    if (state is AnalyticsDashboardLoaded) {
      final currentState = state as AnalyticsDashboardLoaded;
      emit(currentState.copyWith(
        performanceMetrics: event.metrics,
        lastUpdated: DateTime.now(),
      ));
    }
  }

  void _onUpdateBusinessMetrics(
    UpdateBusinessMetrics event,
    Emitter<AnalyticsDashboardState> emit,
  ) {
    if (state is AnalyticsDashboardLoaded) {
      final currentState = state as AnalyticsDashboardLoaded;
      emit(currentState.copyWith(
        businessMetrics: event.metrics,
        lastUpdated: DateTime.now(),
      ));
    }
  }

  void _onUpdateErrorMetrics(
    UpdateErrorMetrics event,
    Emitter<AnalyticsDashboardState> emit,
  ) {
    if (state is AnalyticsDashboardLoaded) {
      final currentState = state as AnalyticsDashboardLoaded;
      emit(currentState.copyWith(
        errorMetrics: event.metrics,
        lastUpdated: DateTime.now(),
      ));
    }
  }

  Future<void> _onExportAnalyticsData(
    ExportAnalyticsData event,
    Emitter<AnalyticsDashboardState> emit,
  ) async {
    try {
      emit(AnalyticsDashboardExporting(event.format));

      // Simulate export process
      await Future.delayed(const Duration(seconds: 2));

      // In a real implementation, this would generate and save the file
      final filePath = 'analytics_export_${DateTime.now().millisecondsSinceEpoch}.${event.format}';

      emit(AnalyticsDashboardExported(event.format, filePath));

      // Return to loaded state after a brief delay
      await Future.delayed(const Duration(seconds: 1));
      if (state is AnalyticsDashboardExported) {
        add(const RefreshAnalyticsDashboard());
      }
    } catch (e) {
      emit(AnalyticsDashboardError('Failed to export analytics data: $e'));
    }
  }

  void _subscribeToStreams() {
    // Subscribe to user metrics stream
    _userMetricsSubscription = _analyticsService.userMetricsStream.listen(
      (metrics) => add(UpdateUserMetrics(metrics)),
      onError: (error) => add(const LoadAnalyticsDashboard()),
    );

    // Subscribe to performance metrics stream
    _performanceMetricsSubscription = _analyticsService.performanceMetricsStream.listen(
      (metrics) => add(UpdatePerformanceMetrics(metrics)),
      onError: (error) => add(const LoadAnalyticsDashboard()),
    );

    // Subscribe to business metrics stream
    _businessMetricsSubscription = _analyticsService.businessMetricsStream.listen(
      (metrics) => add(UpdateBusinessMetrics(metrics)),
      onError: (error) => add(const LoadAnalyticsDashboard()),
    );

    // Subscribe to error metrics stream
    _errorMetricsSubscription = _analyticsService.errorMetricsStream.listen(
      (metrics) => add(UpdateErrorMetrics(metrics)),
      onError: (error) => add(const LoadAnalyticsDashboard()),
    );
  }

  @override
  Future<void> close() {
    _userMetricsSubscription?.cancel();
    _performanceMetricsSubscription?.cancel();
    _businessMetricsSubscription?.cancel();
    _errorMetricsSubscription?.cancel();
    _analyticsService.dispose();
    return super.close();
  }
}
