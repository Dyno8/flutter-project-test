import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/services/realtime_analytics_service.dart';
import '../../data/services/websocket_service.dart';
import '../../domain/entities/system_metrics.dart';
import '../../domain/entities/booking_analytics.dart';

/// BLoC for managing real-time analytics data
class RealtimeAnalyticsBloc extends Bloc<RealtimeAnalyticsEvent, RealtimeAnalyticsState> {
  final RealtimeAnalyticsService _analyticsService;
  final WebSocketService _webSocketService;
  
  StreamSubscription<SystemMetrics>? _systemMetricsSubscription;
  StreamSubscription<BookingAnalytics>? _bookingAnalyticsSubscription;
  StreamSubscription<double>? _revenueSubscription;
  StreamSubscription<int>? _userCountSubscription;
  StreamSubscription<int>? _activeBookingsSubscription;
  StreamSubscription<Map<String, int>>? _partnerStatusSubscription;
  StreamSubscription<Map<String, dynamic>>? _webSocketSubscription;

  RealtimeAnalyticsBloc({
    required RealtimeAnalyticsService analyticsService,
    required WebSocketService webSocketService,
  })  : _analyticsService = analyticsService,
        _webSocketService = webSocketService,
        super(RealtimeAnalyticsInitial()) {
    
    on<RealtimeAnalyticsStarted>(_onStarted);
    on<RealtimeAnalyticsStopped>(_onStopped);
    on<RealtimeAnalyticsSystemMetricsUpdated>(_onSystemMetricsUpdated);
    on<RealtimeAnalyticsBookingAnalyticsUpdated>(_onBookingAnalyticsUpdated);
    on<RealtimeAnalyticsRevenueUpdated>(_onRevenueUpdated);
    on<RealtimeAnalyticsUserCountUpdated>(_onUserCountUpdated);
    on<RealtimeAnalyticsActiveBookingsUpdated>(_onActiveBookingsUpdated);
    on<RealtimeAnalyticsPartnerStatusUpdated>(_onPartnerStatusUpdated);
    on<RealtimeAnalyticsWebSocketMessageReceived>(_onWebSocketMessageReceived);
    on<RealtimeAnalyticsConnectionStatusChanged>(_onConnectionStatusChanged);
  }

  /// Handle analytics started event
  Future<void> _onStarted(
    RealtimeAnalyticsStarted event,
    Emitter<RealtimeAnalyticsState> emit,
  ) async {
    emit(RealtimeAnalyticsLoading());

    try {
      // Initialize services
      _analyticsService.initialize();
      await _webSocketService.connect();

      // Subscribe to data streams
      _subscribeToStreams();

      emit(RealtimeAnalyticsLoaded(
        systemMetrics: null,
        bookingAnalytics: null,
        currentRevenue: 0,
        currentUserCount: 0,
        currentActiveBookings: 0,
        currentPartnerStatus: {},
        isWebSocketConnected: _webSocketService.isConnected,
        lastUpdated: DateTime.now(),
      ));
    } catch (e) {
      emit(RealtimeAnalyticsError(e.toString()));
    }
  }

  /// Handle analytics stopped event
  Future<void> _onStopped(
    RealtimeAnalyticsStopped event,
    Emitter<RealtimeAnalyticsState> emit,
  ) async {
    _unsubscribeFromStreams();
    _analyticsService.dispose();
    _webSocketService.disconnect();
    emit(RealtimeAnalyticsInitial());
  }

  /// Handle system metrics updated event
  void _onSystemMetricsUpdated(
    RealtimeAnalyticsSystemMetricsUpdated event,
    Emitter<RealtimeAnalyticsState> emit,
  ) {
    if (state is RealtimeAnalyticsLoaded) {
      final currentState = state as RealtimeAnalyticsLoaded;
      emit(currentState.copyWith(
        systemMetrics: event.metrics,
        lastUpdated: DateTime.now(),
      ));
    }
  }

  /// Handle booking analytics updated event
  void _onBookingAnalyticsUpdated(
    RealtimeAnalyticsBookingAnalyticsUpdated event,
    Emitter<RealtimeAnalyticsState> emit,
  ) {
    if (state is RealtimeAnalyticsLoaded) {
      final currentState = state as RealtimeAnalyticsLoaded;
      emit(currentState.copyWith(
        bookingAnalytics: event.analytics,
        lastUpdated: DateTime.now(),
      ));
    }
  }

  /// Handle revenue updated event
  void _onRevenueUpdated(
    RealtimeAnalyticsRevenueUpdated event,
    Emitter<RealtimeAnalyticsState> emit,
  ) {
    if (state is RealtimeAnalyticsLoaded) {
      final currentState = state as RealtimeAnalyticsLoaded;
      emit(currentState.copyWith(
        currentRevenue: event.revenue,
        lastUpdated: DateTime.now(),
      ));
    }
  }

  /// Handle user count updated event
  void _onUserCountUpdated(
    RealtimeAnalyticsUserCountUpdated event,
    Emitter<RealtimeAnalyticsState> emit,
  ) {
    if (state is RealtimeAnalyticsLoaded) {
      final currentState = state as RealtimeAnalyticsLoaded;
      emit(currentState.copyWith(
        currentUserCount: event.userCount,
        lastUpdated: DateTime.now(),
      ));
    }
  }

  /// Handle active bookings updated event
  void _onActiveBookingsUpdated(
    RealtimeAnalyticsActiveBookingsUpdated event,
    Emitter<RealtimeAnalyticsState> emit,
  ) {
    if (state is RealtimeAnalyticsLoaded) {
      final currentState = state as RealtimeAnalyticsLoaded;
      emit(currentState.copyWith(
        currentActiveBookings: event.activeBookings,
        lastUpdated: DateTime.now(),
      ));
    }
  }

  /// Handle partner status updated event
  void _onPartnerStatusUpdated(
    RealtimeAnalyticsPartnerStatusUpdated event,
    Emitter<RealtimeAnalyticsState> emit,
  ) {
    if (state is RealtimeAnalyticsLoaded) {
      final currentState = state as RealtimeAnalyticsLoaded;
      emit(currentState.copyWith(
        currentPartnerStatus: event.partnerStatus,
        lastUpdated: DateTime.now(),
      ));
    }
  }

  /// Handle WebSocket message received event
  void _onWebSocketMessageReceived(
    RealtimeAnalyticsWebSocketMessageReceived event,
    Emitter<RealtimeAnalyticsState> emit,
  ) {
    // Process WebSocket messages and trigger appropriate updates
    final message = event.message;
    
    switch (message['type']) {
      case 'analytics_update':
        _processAnalyticsUpdate(message);
        break;
      case 'system_event':
        _processSystemEvent(message);
        break;
    }
  }

  /// Handle connection status changed event
  void _onConnectionStatusChanged(
    RealtimeAnalyticsConnectionStatusChanged event,
    Emitter<RealtimeAnalyticsState> emit,
  ) {
    if (state is RealtimeAnalyticsLoaded) {
      final currentState = state as RealtimeAnalyticsLoaded;
      emit(currentState.copyWith(
        isWebSocketConnected: event.isConnected,
        lastUpdated: DateTime.now(),
      ));
    }
  }

  /// Subscribe to all data streams
  void _subscribeToStreams() {
    // Subscribe to analytics service streams
    _systemMetricsSubscription = _analyticsService.getSystemMetricsStream().listen(
      (metrics) => add(RealtimeAnalyticsSystemMetricsUpdated(metrics)),
    );

    _bookingAnalyticsSubscription = _analyticsService.getBookingAnalyticsStream().listen(
      (analytics) => add(RealtimeAnalyticsBookingAnalyticsUpdated(analytics)),
    );

    _revenueSubscription = _analyticsService.getRevenueStream().listen(
      (revenue) => add(RealtimeAnalyticsRevenueUpdated(revenue)),
    );

    _userCountSubscription = _analyticsService.getUserCountStream().listen(
      (userCount) => add(RealtimeAnalyticsUserCountUpdated(userCount)),
    );

    _activeBookingsSubscription = _analyticsService.getActiveBookingsStream().listen(
      (activeBookings) => add(RealtimeAnalyticsActiveBookingsUpdated(activeBookings)),
    );

    _partnerStatusSubscription = _analyticsService.getPartnerStatusStream().listen(
      (partnerStatus) => add(RealtimeAnalyticsPartnerStatusUpdated(partnerStatus)),
    );

    // Subscribe to WebSocket messages
    _webSocketSubscription = _webSocketService.messageStream.listen(
      (message) => add(RealtimeAnalyticsWebSocketMessageReceived(message)),
    );
  }

  /// Unsubscribe from all data streams
  void _unsubscribeFromStreams() {
    _systemMetricsSubscription?.cancel();
    _bookingAnalyticsSubscription?.cancel();
    _revenueSubscription?.cancel();
    _userCountSubscription?.cancel();
    _activeBookingsSubscription?.cancel();
    _partnerStatusSubscription?.cancel();
    _webSocketSubscription?.cancel();

    _systemMetricsSubscription = null;
    _bookingAnalyticsSubscription = null;
    _revenueSubscription = null;
    _userCountSubscription = null;
    _activeBookingsSubscription = null;
    _partnerStatusSubscription = null;
    _webSocketSubscription = null;
  }

  /// Process analytics update from WebSocket
  void _processAnalyticsUpdate(Map<String, dynamic> message) {
    final dataType = message['dataType'] as String?;
    final data = message['data'] as Map<String, dynamic>?;

    if (data == null) return;

    switch (dataType) {
      case 'system_metrics':
        // Process system metrics update
        break;
      case 'booking_analytics':
        // Process booking analytics update
        break;
      case 'revenue_data':
        // Process revenue data update
        break;
    }
  }

  /// Process system event from WebSocket
  void _processSystemEvent(Map<String, dynamic> message) {
    final eventType = message['event'] as String?;
    final data = message['data'] as Map<String, dynamic>?;

    switch (eventType) {
      case 'booking_created':
        // Handle new booking event
        break;
      case 'booking_completed':
        // Handle booking completion event
        break;
      case 'user_registered':
        // Handle new user registration event
        break;
      case 'partner_status_changed':
        // Handle partner status change event
        break;
    }
  }

  @override
  Future<void> close() {
    _unsubscribeFromStreams();
    _analyticsService.dispose();
    _webSocketService.dispose();
    return super.close();
  }
}

/// Events for RealtimeAnalyticsBloc
abstract class RealtimeAnalyticsEvent extends Equatable {
  const RealtimeAnalyticsEvent();

  @override
  List<Object?> get props => [];
}

class RealtimeAnalyticsStarted extends RealtimeAnalyticsEvent {
  const RealtimeAnalyticsStarted();
}

class RealtimeAnalyticsStopped extends RealtimeAnalyticsEvent {
  const RealtimeAnalyticsStopped();
}

class RealtimeAnalyticsSystemMetricsUpdated extends RealtimeAnalyticsEvent {
  final SystemMetrics metrics;

  const RealtimeAnalyticsSystemMetricsUpdated(this.metrics);

  @override
  List<Object> get props => [metrics];
}

class RealtimeAnalyticsBookingAnalyticsUpdated extends RealtimeAnalyticsEvent {
  final BookingAnalytics analytics;

  const RealtimeAnalyticsBookingAnalyticsUpdated(this.analytics);

  @override
  List<Object> get props => [analytics];
}

class RealtimeAnalyticsRevenueUpdated extends RealtimeAnalyticsEvent {
  final double revenue;

  const RealtimeAnalyticsRevenueUpdated(this.revenue);

  @override
  List<Object> get props => [revenue];
}

class RealtimeAnalyticsUserCountUpdated extends RealtimeAnalyticsEvent {
  final int userCount;

  const RealtimeAnalyticsUserCountUpdated(this.userCount);

  @override
  List<Object> get props => [userCount];
}

class RealtimeAnalyticsActiveBookingsUpdated extends RealtimeAnalyticsEvent {
  final int activeBookings;

  const RealtimeAnalyticsActiveBookingsUpdated(this.activeBookings);

  @override
  List<Object> get props => [activeBookings];
}

class RealtimeAnalyticsPartnerStatusUpdated extends RealtimeAnalyticsEvent {
  final Map<String, int> partnerStatus;

  const RealtimeAnalyticsPartnerStatusUpdated(this.partnerStatus);

  @override
  List<Object> get props => [partnerStatus];
}

class RealtimeAnalyticsWebSocketMessageReceived extends RealtimeAnalyticsEvent {
  final Map<String, dynamic> message;

  const RealtimeAnalyticsWebSocketMessageReceived(this.message);

  @override
  List<Object> get props => [message];
}

class RealtimeAnalyticsConnectionStatusChanged extends RealtimeAnalyticsEvent {
  final bool isConnected;

  const RealtimeAnalyticsConnectionStatusChanged(this.isConnected);

  @override
  List<Object> get props => [isConnected];
}

/// States for RealtimeAnalyticsBloc
abstract class RealtimeAnalyticsState extends Equatable {
  const RealtimeAnalyticsState();

  @override
  List<Object?> get props => [];
}

class RealtimeAnalyticsInitial extends RealtimeAnalyticsState {}

class RealtimeAnalyticsLoading extends RealtimeAnalyticsState {}

class RealtimeAnalyticsLoaded extends RealtimeAnalyticsState {
  final SystemMetrics? systemMetrics;
  final BookingAnalytics? bookingAnalytics;
  final double currentRevenue;
  final int currentUserCount;
  final int currentActiveBookings;
  final Map<String, int> currentPartnerStatus;
  final bool isWebSocketConnected;
  final DateTime lastUpdated;

  const RealtimeAnalyticsLoaded({
    required this.systemMetrics,
    required this.bookingAnalytics,
    required this.currentRevenue,
    required this.currentUserCount,
    required this.currentActiveBookings,
    required this.currentPartnerStatus,
    required this.isWebSocketConnected,
    required this.lastUpdated,
  });

  RealtimeAnalyticsLoaded copyWith({
    SystemMetrics? systemMetrics,
    BookingAnalytics? bookingAnalytics,
    double? currentRevenue,
    int? currentUserCount,
    int? currentActiveBookings,
    Map<String, int>? currentPartnerStatus,
    bool? isWebSocketConnected,
    DateTime? lastUpdated,
  }) {
    return RealtimeAnalyticsLoaded(
      systemMetrics: systemMetrics ?? this.systemMetrics,
      bookingAnalytics: bookingAnalytics ?? this.bookingAnalytics,
      currentRevenue: currentRevenue ?? this.currentRevenue,
      currentUserCount: currentUserCount ?? this.currentUserCount,
      currentActiveBookings: currentActiveBookings ?? this.currentActiveBookings,
      currentPartnerStatus: currentPartnerStatus ?? this.currentPartnerStatus,
      isWebSocketConnected: isWebSocketConnected ?? this.isWebSocketConnected,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [
        systemMetrics,
        bookingAnalytics,
        currentRevenue,
        currentUserCount,
        currentActiveBookings,
        currentPartnerStatus,
        isWebSocketConnected,
        lastUpdated,
      ];
}

class RealtimeAnalyticsError extends RealtimeAnalyticsState {
  final String message;

  const RealtimeAnalyticsError(this.message);

  @override
  List<Object> get props => [message];
}
