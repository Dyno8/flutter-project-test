import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../analytics/firebase_analytics_service.dart';
import '../analytics/business_analytics_service.dart';
import '../analytics/analytics_events.dart';
import 'monitoring_service.dart';
import '../config/environment_config.dart';

/// User experience monitoring service for comprehensive UX tracking and analysis
class UXMonitoringService {
  static final UXMonitoringService _instance = UXMonitoringService._internal();
  factory UXMonitoringService() => _instance;
  UXMonitoringService._internal();

  // Dependencies
  FirebaseAnalyticsService? _analyticsService;
  BusinessAnalyticsService? _businessAnalyticsService;
  MonitoringService? _monitoringService;
  SharedPreferences? _prefs;

  // State management
  bool _isInitialized = false;
  bool _isTrackingActive = false;

  // User session tracking
  String? _currentSessionId;
  DateTime? _sessionStartTime;
  final List<UserJourneyEvent> _currentJourney = [];
  final Map<String, UserSessionMetrics> _sessionMetrics = {};

  // User feedback tracking
  final List<UserFeedback> _feedbackHistory = [];
  final Map<String, List<UserFeedback>> _feedbackByScreen = {};

  // Error impact tracking
  final List<UXErrorImpact> _errorImpacts = [];
  final Map<String, double> _screenErrorRates = {};

  // Funnel analysis
  final Map<String, FunnelAnalysis> _funnelAnalytics = {};
  final List<String> _conversionFunnels = [
    'user_registration',
    'booking_creation',
    'payment_completion',
    'service_completion',
  ];

  // Configuration
  static const int maxJourneyEvents = 100;
  static const int maxFeedbackHistory = 500;
  static const int maxErrorImpacts = 200;
  static const Duration sessionTimeout = Duration(minutes: 30);
  static const Duration metricsReportingInterval = Duration(minutes: 5);

  // Timers
  Timer? _sessionTimeoutTimer;
  Timer? _metricsReportingTimer;

  /// Initialize UX monitoring service
  Future<void> initialize({
    required FirebaseAnalyticsService analyticsService,
    required BusinessAnalyticsService businessAnalyticsService,
    required MonitoringService monitoringService,
  }) async {
    if (_isInitialized) return;

    try {
      _analyticsService = analyticsService;
      _businessAnalyticsService = businessAnalyticsService;
      _monitoringService = monitoringService;
      _prefs = await SharedPreferences.getInstance();

      // Load persisted data
      await _loadPersistedData();

      // Initialize default funnels
      await _initializeDefaultFunnels();

      // Start tracking
      await _startUXTracking();

      _isInitialized = true;
      _isTrackingActive = true;

      _monitoringService?.logInfo(
        'UX Monitoring Service initialized successfully',
      );

      // Track initialization
      await _trackUXEvent('ux_monitoring_initialized', {
        'timestamp': DateTime.now().toIso8601String(),
        'environment': EnvironmentConfig.environment,
      });
    } catch (e, stackTrace) {
      _monitoringService?.logError(
        'Failed to initialize UX Monitoring Service',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Start UX tracking
  Future<void> _startUXTracking() async {
    // Start session tracking
    await _startNewSession();

    // Start metrics reporting timer
    _metricsReportingTimer?.cancel();
    _metricsReportingTimer = Timer.periodic(
      metricsReportingInterval,
      (_) => _reportUXMetrics(),
    );

    _monitoringService?.logInfo('UX tracking started');
  }

  /// Start a new user session
  Future<void> _startNewSession() async {
    _currentSessionId = DateTime.now().millisecondsSinceEpoch.toString();
    _sessionStartTime = DateTime.now();
    _currentJourney.clear();

    // Reset session timeout timer
    _resetSessionTimer();

    // Track session start
    await _trackUXEvent('session_started', {
      'session_id': _currentSessionId!,
      'timestamp': _sessionStartTime!.toIso8601String(),
    });

    _monitoringService?.logInfo('New UX session started: $_currentSessionId');
  }

  /// Track user journey event
  Future<void> trackJourneyEvent({
    required String eventType,
    required String screenName,
    String? action,
    Map<String, dynamic>? metadata,
  }) async {
    if (!_isInitialized || !_isTrackingActive) return;

    try {
      final event = UserJourneyEvent(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sessionId: _currentSessionId ?? 'unknown',
        eventType: eventType,
        screenName: screenName,
        action: action,
        timestamp: DateTime.now(),
        metadata: metadata ?? {},
      );

      // Add to current journey
      _currentJourney.add(event);

      // Keep journey size manageable
      while (_currentJourney.length > maxJourneyEvents) {
        _currentJourney.removeAt(0);
      }

      // Update session metrics
      await _updateSessionMetrics(event);

      // Track to Firebase Analytics
      await _trackUXEvent('user_journey_event', {
        'session_id': event.sessionId,
        'event_type': eventType,
        'screen_name': screenName,
        'action': action ?? 'unknown',
        'timestamp': event.timestamp.toIso8601String(),
        ...?metadata,
      });

      // Reset session timer
      _resetSessionTimer();

      _monitoringService?.logInfo(
        'Journey event tracked: $eventType on $screenName',
      );
    } catch (e, stackTrace) {
      _monitoringService?.logError(
        'Failed to track journey event',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Collect user feedback
  Future<void> collectUserFeedback({
    required String userId,
    required String screenName,
    required String feedbackType,
    required int rating,
    String? comment,
    Map<String, dynamic>? metadata,
  }) async {
    if (!_isInitialized || !_isTrackingActive) return;

    try {
      final feedback = UserFeedback(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sessionId: _currentSessionId ?? 'unknown',
        userId: userId,
        screenName: screenName,
        feedbackType: feedbackType,
        rating: rating,
        comment: comment,
        timestamp: DateTime.now(),
        metadata: metadata ?? {},
      );

      // Add to feedback history
      _feedbackHistory.add(feedback);

      // Group by screen
      _feedbackByScreen.putIfAbsent(screenName, () => []).add(feedback);

      // Keep history size manageable
      while (_feedbackHistory.length > maxFeedbackHistory) {
        _feedbackHistory.removeAt(0);
      }

      // Save feedback
      await _saveFeedbackHistory();

      // Track to Firebase Analytics
      await _trackUXEvent('user_feedback_collected', {
        'session_id': feedback.sessionId,
        'user_id': userId,
        'screen_name': screenName,
        'feedback_type': feedbackType,
        'rating': rating,
        'has_comment': comment != null,
        'timestamp': feedback.timestamp.toIso8601String(),
        ...?metadata,
      });

      _monitoringService?.logInfo(
        'User feedback collected: $feedbackType ($rating/5) on $screenName',
      );
    } catch (e, stackTrace) {
      _monitoringService?.logError(
        'Failed to collect user feedback',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Track error impact on user experience
  Future<void> trackErrorImpact({
    required String errorId,
    required String userId,
    required String screenName,
    required String errorType,
    required String errorMessage,
    required bool sessionAbandoned,
    String? userAction,
    Map<String, dynamic>? metadata,
  }) async {
    if (!_isInitialized || !_isTrackingActive) return;

    try {
      final errorImpact = UXErrorImpact(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        errorId: errorId,
        sessionId: _currentSessionId ?? 'unknown',
        userId: userId,
        screenName: screenName,
        errorType: errorType,
        errorMessage: errorMessage,
        timestamp: DateTime.now(),
        sessionAbandoned: sessionAbandoned,
        userAction: userAction,
        metadata: metadata ?? {},
      );

      // Add to error impacts
      _errorImpacts.add(errorImpact);

      // Update screen error rates
      _updateScreenErrorRate(screenName);

      // Keep error impacts size manageable
      while (_errorImpacts.length > maxErrorImpacts) {
        _errorImpacts.removeAt(0);
      }

      // Update session metrics
      final sessionMetrics = _sessionMetrics[_currentSessionId];
      if (sessionMetrics != null) {
        sessionMetrics.errors++;
      }

      // Save error impacts
      await _saveErrorImpacts();

      // Track to Firebase Analytics
      await _trackUXEvent('ux_error_impact', {
        'session_id': errorImpact.sessionId,
        'error_id': errorId,
        'user_id': userId,
        'screen_name': screenName,
        'error_type': errorType,
        'session_abandoned': sessionAbandoned,
        'user_action': userAction ?? 'unknown',
        'timestamp': errorImpact.timestamp.toIso8601String(),
        ...?metadata,
      });

      // If session was abandoned, end the session
      if (sessionAbandoned) {
        await _endSession(abandoned: true);
      }

      _monitoringService?.logError(
        'UX error impact tracked: $errorType on $screenName',
        metadata: errorImpact.toMap(),
      );
    } catch (e, stackTrace) {
      _monitoringService?.logError(
        'Failed to track error impact',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Update funnel analysis
  Future<void> updateFunnelAnalysis({
    required String funnelId,
    required String stepId,
    required String userId,
    bool completed = false,
    Duration? timeSpent,
  }) async {
    if (!_isInitialized || !_isTrackingActive) return;

    try {
      final funnel = _funnelAnalytics[funnelId];
      if (funnel == null) return;

      final step = funnel.steps.firstWhere(
        (s) => s.id == stepId,
        orElse: () => throw Exception('Step not found: $stepId'),
      );

      // Update step metrics
      step.totalUsers++;
      if (completed) {
        step.completedUsers++;
      }

      if (timeSpent != null) {
        // Update average time spent (simple moving average)
        step.averageTimeSpentSeconds =
            (step.averageTimeSpentSeconds + timeSpent.inSeconds) / 2;
      }

      // Track funnel event
      await _trackUXEvent('funnel_step_event', {
        'session_id': _currentSessionId ?? 'unknown',
        'funnel_id': funnelId,
        'step_id': stepId,
        'user_id': userId,
        'completed': completed,
        'time_spent_seconds': timeSpent?.inSeconds ?? 0,
        'conversion_rate': step.conversionRate,
        'timestamp': DateTime.now().toIso8601String(),
      });

      _monitoringService?.logInfo(
        'Funnel step updated: $funnelId/$stepId (${step.conversionRate.toStringAsFixed(1)}%)',
      );
    } catch (e, stackTrace) {
      _monitoringService?.logError(
        'Failed to update funnel analysis',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Get current session metrics
  Map<String, dynamic> getCurrentSessionMetrics() {
    final sessionMetrics = _sessionMetrics[_currentSessionId];
    if (sessionMetrics == null) {
      return {
        'session_id': _currentSessionId,
        'active': false,
        'message': 'No active session',
      };
    }

    return {
      'session_id': _currentSessionId,
      'active': true,
      'metrics': sessionMetrics.toMap(),
      'journey_events': _currentJourney.length,
      'current_journey': _currentJourney
          .take(10)
          .map((e) => e.toMap())
          .toList(),
    };
  }

  /// Get user feedback analytics
  Map<String, dynamic> getFeedbackAnalytics({String? screenName}) {
    List<UserFeedback> feedbackToAnalyze;

    if (screenName != null) {
      feedbackToAnalyze = _feedbackByScreen[screenName] ?? [];
    } else {
      feedbackToAnalyze = _feedbackHistory;
    }

    if (feedbackToAnalyze.isEmpty) {
      return {
        'total_feedback': 0,
        'average_rating': 0.0,
        'feedback_by_type': <String, int>{},
        'recent_feedback': <Map<String, dynamic>>[],
      };
    }

    // Calculate analytics
    final totalFeedback = feedbackToAnalyze.length;
    final averageRating =
        feedbackToAnalyze.map((f) => f.rating).reduce((a, b) => a + b) /
        totalFeedback;

    final feedbackByType = <String, int>{};
    for (final feedback in feedbackToAnalyze) {
      feedbackByType[feedback.feedbackType] =
          (feedbackByType[feedback.feedbackType] ?? 0) + 1;
    }

    final recentFeedback = feedbackToAnalyze
        .take(10)
        .map((f) => f.toMap())
        .toList();

    return {
      'total_feedback': totalFeedback,
      'average_rating': averageRating,
      'feedback_by_type': feedbackByType,
      'recent_feedback': recentFeedback,
      'screen_name': screenName,
    };
  }

  /// Get error impact analytics
  Map<String, dynamic> getErrorImpactAnalytics({String? screenName}) {
    List<UXErrorImpact> errorsToAnalyze;

    if (screenName != null) {
      errorsToAnalyze = _errorImpacts
          .where((e) => e.screenName == screenName)
          .toList();
    } else {
      errorsToAnalyze = _errorImpacts;
    }

    if (errorsToAnalyze.isEmpty) {
      return {
        'total_errors': 0,
        'abandonment_rate': 0.0,
        'error_types': <String, int>{},
        'recent_errors': <Map<String, dynamic>>[],
      };
    }

    // Calculate analytics
    final totalErrors = errorsToAnalyze.length;
    final abandonedSessions = errorsToAnalyze
        .where((e) => e.sessionAbandoned)
        .length;
    final abandonmentRate = (abandonedSessions / totalErrors) * 100;

    final errorTypes = <String, int>{};
    for (final error in errorsToAnalyze) {
      errorTypes[error.errorType] = (errorTypes[error.errorType] ?? 0) + 1;
    }

    final recentErrors = errorsToAnalyze
        .take(10)
        .map((e) => e.toMap())
        .toList();

    return {
      'total_errors': totalErrors,
      'abandonment_rate': abandonmentRate,
      'error_types': errorTypes,
      'recent_errors': recentErrors,
      'screen_name': screenName,
    };
  }

  /// Get funnel analytics
  Map<String, dynamic> getFunnelAnalytics({String? funnelId}) {
    if (funnelId != null) {
      final funnel = _funnelAnalytics[funnelId];
      return funnel?.toMap() ?? {'error': 'Funnel not found: $funnelId'};
    }

    return {
      'funnels': _funnelAnalytics.values.map((f) => f.toMap()).toList(),
      'total_funnels': _funnelAnalytics.length,
    };
  }

  /// Initialize default conversion funnels
  Future<void> _initializeDefaultFunnels() async {
    // User registration funnel
    _funnelAnalytics['user_registration'] = FunnelAnalysis(
      funnelId: 'user_registration',
      name: 'User Registration',
      steps: [
        FunnelStep(id: 'landing', name: 'Landing Page', position: 1),
        FunnelStep(id: 'signup_form', name: 'Sign Up Form', position: 2),
        FunnelStep(
          id: 'email_verification',
          name: 'Email Verification',
          position: 3,
        ),
        FunnelStep(
          id: 'profile_completion',
          name: 'Profile Completion',
          position: 4,
        ),
      ],
      lastUpdated: DateTime.now(),
    );

    // Booking creation funnel
    _funnelAnalytics['booking_creation'] = FunnelAnalysis(
      funnelId: 'booking_creation',
      name: 'Booking Creation',
      steps: [
        FunnelStep(
          id: 'service_selection',
          name: 'Service Selection',
          position: 1,
        ),
        FunnelStep(
          id: 'partner_selection',
          name: 'Partner Selection',
          position: 2,
        ),
        FunnelStep(id: 'booking_details', name: 'Booking Details', position: 3),
        FunnelStep(
          id: 'booking_confirmation',
          name: 'Booking Confirmation',
          position: 4,
        ),
      ],
      lastUpdated: DateTime.now(),
    );

    // Payment completion funnel
    _funnelAnalytics['payment_completion'] = FunnelAnalysis(
      funnelId: 'payment_completion',
      name: 'Payment Completion',
      steps: [
        FunnelStep(
          id: 'payment_method',
          name: 'Payment Method Selection',
          position: 1,
        ),
        FunnelStep(id: 'payment_details', name: 'Payment Details', position: 2),
        FunnelStep(
          id: 'payment_processing',
          name: 'Payment Processing',
          position: 3,
        ),
        FunnelStep(id: 'payment_success', name: 'Payment Success', position: 4),
      ],
      lastUpdated: DateTime.now(),
    );

    // Service completion funnel
    _funnelAnalytics['service_completion'] = FunnelAnalysis(
      funnelId: 'service_completion',
      name: 'Service Completion',
      steps: [
        FunnelStep(id: 'service_start', name: 'Service Started', position: 1),
        FunnelStep(
          id: 'service_progress',
          name: 'Service In Progress',
          position: 2,
        ),
        FunnelStep(
          id: 'service_completion',
          name: 'Service Completed',
          position: 3,
        ),
        FunnelStep(
          id: 'review_submission',
          name: 'Review Submitted',
          position: 4,
        ),
      ],
      lastUpdated: DateTime.now(),
    );
  }

  /// Helper method to track UX events to Firebase Analytics
  Future<void> _trackUXEvent(
    String eventName,
    Map<String, dynamic> parameters,
  ) async {
    try {
      await _analyticsService?.logEvent(eventName, parameters: parameters);
      await _businessAnalyticsService?.trackEngagement(
        engagementType: eventName,
        parameters: parameters,
      );
    } catch (e) {
      _monitoringService?.logError(
        'Failed to track UX event: $eventName',
        error: e,
      );
    }
  }

  /// Report UX metrics periodically
  Future<void> _reportUXMetrics() async {
    try {
      final currentMetrics = getCurrentSessionMetrics();
      final feedbackAnalytics = getFeedbackAnalytics();
      final errorAnalytics = getErrorImpactAnalytics();
      final funnelAnalytics = getFunnelAnalytics();

      // Track comprehensive UX metrics
      await _trackUXEvent('ux_metrics_report', {
        'session_metrics': currentMetrics,
        'feedback_analytics': feedbackAnalytics,
        'error_analytics': errorAnalytics,
        'funnel_analytics': funnelAnalytics,
        'timestamp': DateTime.now().toIso8601String(),
      });

      _monitoringService?.logInfo('UX metrics reported successfully');
    } catch (e, stackTrace) {
      _monitoringService?.logError(
        'Failed to report UX metrics',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Reset session timeout timer
  void _resetSessionTimer() {
    _sessionTimeoutTimer?.cancel();
    _sessionTimeoutTimer = Timer(sessionTimeout, () => _endSession());
  }

  /// End current session
  Future<void> _endSession({bool abandoned = false}) async {
    if (_currentSessionId == null) return;

    try {
      final sessionMetrics = _sessionMetrics[_currentSessionId];
      if (sessionMetrics != null) {
        sessionMetrics.endTime = DateTime.now();
        sessionMetrics.completed = !abandoned;
      }

      // Track session end
      await _trackUXEvent('session_ended', {
        'session_id': _currentSessionId!,
        'duration_seconds': sessionMetrics?.duration.inSeconds ?? 0,
        'abandoned': abandoned,
        'journey_events': _currentJourney.length,
        'timestamp': DateTime.now().toIso8601String(),
      });

      // Save session data
      await _saveSessionMetrics();

      _monitoringService?.logInfo(
        'Session ended: $_currentSessionId (abandoned: $abandoned)',
      );

      // Clear current session
      _currentSessionId = null;
      _sessionStartTime = null;
      _sessionTimeoutTimer?.cancel();
    } catch (e, stackTrace) {
      _monitoringService?.logError(
        'Failed to end session',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Update session metrics with new event
  Future<void> _updateSessionMetrics(UserJourneyEvent event) async {
    if (_currentSessionId == null) return;

    try {
      final sessionMetrics = _sessionMetrics.putIfAbsent(
        _currentSessionId!,
        () => UserSessionMetrics(
          sessionId: _currentSessionId!,
          startTime: _sessionStartTime ?? DateTime.now(),
        ),
      );

      // Update metrics based on event type
      switch (event.eventType) {
        case 'screen_view':
          sessionMetrics.screenViews++;
          sessionMetrics.screenViewCounts[event.screenName] =
              (sessionMetrics.screenViewCounts[event.screenName] ?? 0) + 1;
          break;
        case 'user_action':
          sessionMetrics.userActions++;
          final actionKey = event.action ?? 'unknown';
          sessionMetrics.actionCounts[actionKey] =
              (sessionMetrics.actionCounts[actionKey] ?? 0) + 1;
          break;
        case 'error':
          sessionMetrics.errors++;
          break;
      }

      // Update screen time tracking (simplified)
      if (event.metadata.containsKey('time_spent_seconds')) {
        final timeSpent =
            event.metadata['time_spent_seconds'] as double? ?? 0.0;
        sessionMetrics.screenTimeSpent[event.screenName] =
            (sessionMetrics.screenTimeSpent[event.screenName] ?? 0.0) +
            timeSpent;
      }
    } catch (e, stackTrace) {
      _monitoringService?.logError(
        'Failed to update session metrics',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Update screen error rate
  void _updateScreenErrorRate(String screenName) {
    final totalErrors = _errorImpacts
        .where((e) => e.screenName == screenName)
        .length;
    final totalEvents = _currentJourney
        .where((e) => e.screenName == screenName)
        .length;

    if (totalEvents > 0) {
      _screenErrorRates[screenName] = (totalErrors / totalEvents) * 100;
    }
  }

  /// Load persisted data from SharedPreferences
  Future<void> _loadPersistedData() async {
    try {
      // Load feedback history
      final feedbackJson = _prefs?.getString('ux_feedback_history');
      if (feedbackJson != null) {
        final feedbackList = jsonDecode(feedbackJson) as List;
        _feedbackHistory.clear();
        _feedbackHistory.addAll(
          feedbackList.map(
            (item) => UserFeedback(
              id: item['id'],
              sessionId: item['sessionId'],
              userId: item['userId'],
              screenName: item['screenName'],
              feedbackType: item['feedbackType'],
              rating: item['rating'],
              comment: item['comment'],
              timestamp: DateTime.parse(item['timestamp']),
              metadata: Map<String, dynamic>.from(item['metadata']),
            ),
          ),
        );

        // Rebuild feedback by screen map
        _feedbackByScreen.clear();
        for (final feedback in _feedbackHistory) {
          _feedbackByScreen
              .putIfAbsent(feedback.screenName, () => [])
              .add(feedback);
        }
      }

      // Load error impacts
      final errorImpactsJson = _prefs?.getString('ux_error_impacts');
      if (errorImpactsJson != null) {
        final errorsList = jsonDecode(errorImpactsJson) as List;
        _errorImpacts.clear();
        _errorImpacts.addAll(
          errorsList.map(
            (item) => UXErrorImpact(
              id: item['id'],
              errorId: item['errorId'],
              sessionId: item['sessionId'],
              userId: item['userId'],
              screenName: item['screenName'],
              errorType: item['errorType'],
              errorMessage: item['errorMessage'],
              timestamp: DateTime.parse(item['timestamp']),
              sessionAbandoned: item['sessionAbandoned'],
              userAction: item['userAction'],
              metadata: Map<String, dynamic>.from(item['metadata']),
            ),
          ),
        );
      }

      _monitoringService?.logInfo('UX monitoring persisted data loaded');
    } catch (e, stackTrace) {
      _monitoringService?.logError(
        'Failed to load persisted UX data',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Save feedback history to SharedPreferences
  Future<void> _saveFeedbackHistory() async {
    try {
      final feedbackJson = jsonEncode(
        _feedbackHistory.map((f) => f.toMap()).toList(),
      );
      await _prefs?.setString('ux_feedback_history', feedbackJson);
    } catch (e) {
      _monitoringService?.logError('Failed to save feedback history', error: e);
    }
  }

  /// Save error impacts to SharedPreferences
  Future<void> _saveErrorImpacts() async {
    try {
      final errorImpactsJson = jsonEncode(
        _errorImpacts.map((e) => e.toMap()).toList(),
      );
      await _prefs?.setString('ux_error_impacts', errorImpactsJson);
    } catch (e) {
      _monitoringService?.logError('Failed to save error impacts', error: e);
    }
  }

  /// Save session metrics to SharedPreferences
  Future<void> _saveSessionMetrics() async {
    try {
      final sessionMetricsJson = jsonEncode(
        _sessionMetrics.values.map((s) => s.toMap()).toList(),
      );
      await _prefs?.setString('ux_session_metrics', sessionMetricsJson);
    } catch (e) {
      _monitoringService?.logError('Failed to save session metrics', error: e);
    }
  }

  /// Get current session ID
  String? get currentSessionId => _currentSessionId;

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;

  /// Check if tracking is active
  bool get isTrackingActive => _isTrackingActive;

  /// Dispose resources
  Future<void> dispose() async {
    _sessionTimeoutTimer?.cancel();
    _metricsReportingTimer?.cancel();

    if (_currentSessionId != null) {
      await _endSession();
    }

    _isInitialized = false;
    _isTrackingActive = false;
  }
}

/// User journey event model
class UserJourneyEvent {
  final String id;
  final String sessionId;
  final String eventType;
  final String screenName;
  final String? action;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  UserJourneyEvent({
    required this.id,
    required this.sessionId,
    required this.eventType,
    required this.screenName,
    this.action,
    required this.timestamp,
    required this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sessionId': sessionId,
      'eventType': eventType,
      'screenName': screenName,
      'action': action,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory UserJourneyEvent.fromMap(Map<String, dynamic> map) {
    return UserJourneyEvent(
      id: map['id'],
      sessionId: map['sessionId'],
      eventType: map['eventType'],
      screenName: map['screenName'],
      action: map['action'],
      timestamp: DateTime.parse(map['timestamp']),
      metadata: Map<String, dynamic>.from(map['metadata']),
    );
  }
}

/// User session metrics model
class UserSessionMetrics {
  final String sessionId;
  final DateTime startTime;
  DateTime? endTime;
  Duration get duration => endTime != null
      ? endTime!.difference(startTime)
      : DateTime.now().difference(startTime);
  int screenViews = 0;
  int userActions = 0;
  int errors = 0;
  Map<String, int> screenViewCounts = {};
  Map<String, int> actionCounts = {};
  Map<String, double> screenTimeSpent = {};
  bool completed = false;

  UserSessionMetrics({
    required this.sessionId,
    required this.startTime,
    this.endTime,
    this.screenViews = 0,
    this.userActions = 0,
    this.errors = 0,
    Map<String, int>? screenViewCounts,
    Map<String, int>? actionCounts,
    Map<String, double>? screenTimeSpent,
    this.completed = false,
  }) : screenViewCounts = screenViewCounts ?? {},
       actionCounts = actionCounts ?? {},
       screenTimeSpent = screenTimeSpent ?? {};

  Map<String, dynamic> toMap() {
    return {
      'sessionId': sessionId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'durationSeconds': duration.inSeconds,
      'screenViews': screenViews,
      'userActions': userActions,
      'errors': errors,
      'screenViewCounts': screenViewCounts,
      'actionCounts': actionCounts,
      'screenTimeSpent': screenTimeSpent,
      'completed': completed,
    };
  }
}

/// User feedback model
class UserFeedback {
  final String id;
  final String sessionId;
  final String userId;
  final String screenName;
  final String feedbackType;
  final int rating;
  final String? comment;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  UserFeedback({
    required this.id,
    required this.sessionId,
    required this.userId,
    required this.screenName,
    required this.feedbackType,
    required this.rating,
    this.comment,
    required this.timestamp,
    required this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sessionId': sessionId,
      'userId': userId,
      'screenName': screenName,
      'feedbackType': feedbackType,
      'rating': rating,
      'comment': comment,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }
}

/// UX error impact model
class UXErrorImpact {
  final String id;
  final String errorId;
  final String sessionId;
  final String userId;
  final String screenName;
  final String errorType;
  final String errorMessage;
  final DateTime timestamp;
  final bool sessionAbandoned;
  final String? userAction;
  final Map<String, dynamic> metadata;

  UXErrorImpact({
    required this.id,
    required this.errorId,
    required this.sessionId,
    required this.userId,
    required this.screenName,
    required this.errorType,
    required this.errorMessage,
    required this.timestamp,
    required this.sessionAbandoned,
    this.userAction,
    required this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'errorId': errorId,
      'sessionId': sessionId,
      'userId': userId,
      'screenName': screenName,
      'errorType': errorType,
      'errorMessage': errorMessage,
      'timestamp': timestamp.toIso8601String(),
      'sessionAbandoned': sessionAbandoned,
      'userAction': userAction,
      'metadata': metadata,
    };
  }
}

/// Funnel analysis model
class FunnelAnalysis {
  final String funnelId;
  final String name;
  final List<FunnelStep> steps;
  final DateTime lastUpdated;

  FunnelAnalysis({
    required this.funnelId,
    required this.name,
    required this.steps,
    required this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
      'funnelId': funnelId,
      'name': name,
      'steps': steps.map((step) => step.toMap()).toList(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}

/// Funnel step model
class FunnelStep {
  final String id;
  final String name;
  final int position;
  int totalUsers = 0;
  int completedUsers = 0;
  double get conversionRate =>
      totalUsers > 0 ? (completedUsers / totalUsers) * 100 : 0;
  double averageTimeSpentSeconds = 0;

  FunnelStep({
    required this.id,
    required this.name,
    required this.position,
    this.totalUsers = 0,
    this.completedUsers = 0,
    this.averageTimeSpentSeconds = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'position': position,
      'totalUsers': totalUsers,
      'completedUsers': completedUsers,
      'conversionRate': conversionRate,
      'averageTimeSpentSeconds': averageTimeSpentSeconds,
    };
  }
}
