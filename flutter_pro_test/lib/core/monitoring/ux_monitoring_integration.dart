import 'dart:async';
import 'package:flutter/foundation.dart';

import '../analytics/firebase_analytics_service.dart';
import '../analytics/business_analytics_service.dart';
import 'monitoring_service.dart';
import 'ux_monitoring_service.dart';
import 'user_session_tracker.dart';
import 'user_feedback_collector.dart';
import 'ux_error_impact_analyzer.dart';
import '../error_tracking/error_tracking_service.dart';
import '../config/environment_config.dart';

/// Integration service that coordinates all UX monitoring components
/// Provides a unified interface for UX monitoring and Firebase Analytics integration
class UXMonitoringIntegration {
  static final UXMonitoringIntegration _instance =
      UXMonitoringIntegration._internal();
  factory UXMonitoringIntegration() => _instance;
  UXMonitoringIntegration._internal();

  // Dependencies
  late final FirebaseAnalyticsService _analyticsService;
  late final BusinessAnalyticsService _businessAnalyticsService;
  late final MonitoringService _monitoringService;
  late final ErrorTrackingService _errorTrackingService;

  // UX Monitoring Services
  late final UXMonitoringService _uxMonitoringService;
  late final UserSessionTracker _sessionTracker;
  late final UserFeedbackCollector _feedbackCollector;
  late final UXErrorImpactAnalyzer _errorImpactAnalyzer;

  // State management
  bool _isInitialized = false;
  bool _isTrackingActive = false;
  String? _currentUserId;
  String? _currentUserType;

  // Configuration
  static const Duration metricsReportingInterval = Duration(minutes: 5);
  Timer? _metricsReportingTimer;

  /// Initialize UX monitoring integration
  Future<void> initialize({
    required FirebaseAnalyticsService analyticsService,
    required BusinessAnalyticsService businessAnalyticsService,
    required MonitoringService monitoringService,
    required ErrorTrackingService errorTrackingService,
  }) async {
    if (_isInitialized) return;

    try {
      // Store dependencies
      _analyticsService = analyticsService;
      _businessAnalyticsService = businessAnalyticsService;
      _monitoringService = monitoringService;
      _errorTrackingService = errorTrackingService;

      // Initialize UX monitoring services
      _uxMonitoringService = UXMonitoringService();
      _sessionTracker = UserSessionTracker();
      _feedbackCollector = UserFeedbackCollector();
      _errorImpactAnalyzer = UXErrorImpactAnalyzer();

      // Initialize all services
      await _uxMonitoringService.initialize(
        analyticsService: _analyticsService,
        businessAnalyticsService: _businessAnalyticsService,
        monitoringService: _monitoringService,
      );

      await _sessionTracker.initialize(
        uxMonitoringService: _uxMonitoringService,
        analyticsService: _analyticsService,
        monitoringService: _monitoringService,
      );

      await _feedbackCollector.initialize(
        uxMonitoringService: _uxMonitoringService,
        analyticsService: _analyticsService,
        monitoringService: _monitoringService,
      );

      await _errorImpactAnalyzer.initialize(
        uxMonitoringService: _uxMonitoringService,
        analyticsService: _analyticsService,
        monitoringService: _monitoringService,
        errorTrackingService: _errorTrackingService,
      );

      // Start metrics reporting
      _startMetricsReporting();

      _isInitialized = true;
      _isTrackingActive = true;

      _monitoringService.logInfo(
        'UX Monitoring Integration initialized successfully',
      );

      // Track initialization
      await _analyticsService.logEvent(
        'ux_monitoring_integration_initialized',
        parameters: {
          'timestamp': DateTime.now().toIso8601String(),
          'environment': EnvironmentConfig.environment,
          'app_version': EnvironmentConfig.appVersion,
        },
      );
    } catch (e, stackTrace) {
      _monitoringService.logError(
        'Failed to initialize UX Monitoring Integration',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Start user session with comprehensive tracking
  Future<void> startUserSession({
    required String userId,
    required String userType,
    Map<String, dynamic>? userProperties,
  }) async {
    if (!_isInitialized) {
      _monitoringService.logError('UX Monitoring Integration not initialized');
      return;
    }

    try {
      _currentUserId = userId;
      _currentUserType = userType;

      // Set user in analytics services
      await _businessAnalyticsService.setUser(
        userId: userId,
        userType: userType,
        userProperties: userProperties?.map(
          (key, value) => MapEntry(key, value.toString()),
        ),
      );

      // Start session tracking
      await _sessionTracker.startSession(userId: userId, userType: userType);

      _monitoringService.logInfo(
        'User session started with UX monitoring: $userId',
      );
    } catch (e, stackTrace) {
      _monitoringService.logError(
        'Failed to start user session',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Track screen view with comprehensive analytics
  Future<void> trackScreenView({
    required String screenName,
    String? screenClass,
    Map<String, dynamic>? parameters,
  }) async {
    if (!_isInitialized || !_isTrackingActive) return;

    try {
      // Track in session tracker
      await _sessionTracker.trackScreenView(
        screenName: screenName,
        screenClass: screenClass,
        parameters: parameters,
      );

      // Track in business analytics
      await _businessAnalyticsService.trackScreenView(
        screenName: screenName,
        screenClass: screenClass,
        parameters: parameters,
      );

      _monitoringService.logInfo('Screen view tracked: $screenName');
    } catch (e, stackTrace) {
      _monitoringService.logError(
        'Failed to track screen view',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Track user interaction with detailed analytics
  Future<void> trackUserInteraction({
    required String interactionType,
    required String elementId,
    String? action,
    String? screenName,
    Map<String, dynamic>? parameters,
  }) async {
    if (!_isInitialized || !_isTrackingActive) return;

    try {
      // Track in session tracker
      await _sessionTracker.trackInteraction(
        interactionType: interactionType,
        elementId: elementId,
        action: action,
        parameters: parameters,
      );

      // Track in business analytics
      await _businessAnalyticsService.trackUserAction(
        actionName: interactionType,
        category: 'interaction',
        screenName: screenName,
        parameters: {'element_id': elementId, 'action': action, ...?parameters},
      );

      _monitoringService.logInfo('User interaction tracked: $interactionType');
    } catch (e, stackTrace) {
      _monitoringService.logError(
        'Failed to track user interaction',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Track feature usage with analytics
  Future<void> trackFeatureUsage({
    required String featureName,
    String? category,
    String? screenName,
    Map<String, dynamic>? parameters,
  }) async {
    if (!_isInitialized || !_isTrackingActive) return;

    try {
      // Track in session tracker
      await _sessionTracker.trackFeatureUsage(
        featureName: featureName,
        category: category,
        parameters: parameters,
      );

      // Track in business analytics
      await _businessAnalyticsService.trackUserAction(
        actionName: featureName,
        category: category ?? 'feature',
        screenName: screenName,
        parameters: parameters,
      );

      _monitoringService.logInfo('Feature usage tracked: $featureName');
    } catch (e, stackTrace) {
      _monitoringService.logError(
        'Failed to track feature usage',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Collect user feedback with comprehensive tracking
  Future<void> collectUserFeedback({
    required String screenName,
    required String feedbackType,
    required int rating,
    String? comment,
    Map<String, dynamic>? metadata,
  }) async {
    if (!_isInitialized || _currentUserId == null) return;

    try {
      await _feedbackCollector.collectFeedback(
        userId: _currentUserId!,
        screenName: screenName,
        feedbackType: feedbackType,
        rating: rating,
        comment: comment,
        metadata: metadata,
      );

      _monitoringService.logInfo(
        'User feedback collected: $feedbackType ($rating/5)',
      );
    } catch (e, stackTrace) {
      _monitoringService.logError(
        'Failed to collect user feedback',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Track error with impact analysis
  Future<void> trackErrorWithImpact({
    required String errorId,
    required String screenName,
    required String errorType,
    required String errorMessage,
    Map<String, dynamic>? errorMetadata,
  }) async {
    if (!_isInitialized || _currentUserId == null) return;

    try {
      final sessionId = _sessionTracker.currentSessionId ?? 'unknown';

      await _errorImpactAnalyzer.analyzeErrorImpact(
        errorId: errorId,
        userId: _currentUserId!,
        sessionId: sessionId,
        screenName: screenName,
        errorType: errorType,
        errorMessage: errorMessage,
        errorTimestamp: DateTime.now(),
        errorMetadata: errorMetadata,
      );

      _monitoringService.logInfo(
        'Error impact analyzed: $errorType on $screenName',
      );
    } catch (e, stackTrace) {
      _monitoringService.logError(
        'Failed to track error with impact',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Get comprehensive UX analytics
  Map<String, dynamic> getComprehensiveUXAnalytics() {
    if (!_isInitialized) {
      return {'error': 'UX Monitoring Integration not initialized'};
    }

    try {
      return {
        'session_analytics': _sessionTracker.getCurrentSessionAnalytics(),
        'navigation_analytics': _sessionTracker.getNavigationFlowAnalytics(),
        'engagement_metrics': _sessionTracker.getEngagementMetrics(),
        'feedback_analytics': _feedbackCollector.getOverallFeedbackAnalytics(),
        'error_impact_analytics': _errorImpactAnalyzer
            .getOverallErrorImpactAnalytics(),
        'ux_monitoring_metrics': _uxMonitoringService
            .getCurrentSessionMetrics(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e, stackTrace) {
      _monitoringService.logError(
        'Failed to get comprehensive UX analytics',
        error: e,
        stackTrace: stackTrace,
      );
      return {'error': 'Failed to get UX analytics'};
    }
  }

  /// Get screen-specific analytics
  Map<String, dynamic> getScreenAnalytics(String screenName) {
    if (!_isInitialized) {
      return {'error': 'UX Monitoring Integration not initialized'};
    }

    try {
      return {
        'screen_name': screenName,
        'feedback_analytics': _feedbackCollector.getFeedbackAnalyticsForScreen(
          screenName,
        ),
        'error_impact_analytics': _errorImpactAnalyzer
            .getScreenErrorImpactAnalytics(screenName),
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e, stackTrace) {
      _monitoringService.logError(
        'Failed to get screen analytics',
        error: e,
        stackTrace: stackTrace,
      );
      return {'error': 'Failed to get screen analytics'};
    }
  }

  /// Check if feedback prompt should be shown
  Future<bool> shouldShowFeedbackPrompt(String screenName) async {
    if (!_isInitialized || _currentUserId == null) return false;

    try {
      return await _feedbackCollector.shouldShowFeedbackPrompt(
        userId: _currentUserId!,
        screenName: screenName,
      );
    } catch (e) {
      _monitoringService.logError('Failed to check feedback prompt', error: e);
      return false;
    }
  }

  /// Get feedback prompt for specific type
  String getFeedbackPrompt(String feedbackType) {
    return _feedbackCollector.getFeedbackPrompt(feedbackType);
  }

  /// End current session
  Future<void> endSession() async {
    if (!_isInitialized) return;

    try {
      await _sessionTracker.endSession();
      _currentUserId = null;
      _currentUserType = null;

      _monitoringService.logInfo('User session ended');
    } catch (e, stackTrace) {
      _monitoringService.logError(
        'Failed to end user session',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Start metrics reporting
  void _startMetricsReporting() {
    _metricsReportingTimer?.cancel();
    _metricsReportingTimer = Timer.periodic(
      metricsReportingInterval,
      (_) => _reportComprehensiveMetrics(),
    );
  }

  /// Report comprehensive metrics to Firebase Analytics
  Future<void> _reportComprehensiveMetrics() async {
    try {
      final analytics = getComprehensiveUXAnalytics();

      if (analytics.containsKey('error')) {
        return; // Skip reporting if there's an error
      }

      // Extract key metrics for Firebase Analytics
      final sessionAnalytics =
          analytics['session_analytics'] as Map<String, dynamic>? ?? {};
      final engagementMetrics =
          analytics['engagement_metrics'] as Map<String, dynamic>? ?? {};
      final feedbackAnalytics =
          analytics['feedback_analytics'] as Map<String, dynamic>? ?? {};
      final errorAnalytics =
          analytics['error_impact_analytics'] as Map<String, dynamic>? ?? {};

      // Report to Firebase Analytics
      await _analyticsService.logEvent(
        'ux_comprehensive_metrics',
        parameters: {
          'session_active': sessionAnalytics['active'] ?? false,
          'session_duration_seconds': sessionAnalytics['duration_seconds'] ?? 0,
          'screens_visited': sessionAnalytics['screens_visited'] ?? 0,
          'total_interactions': sessionAnalytics['total_interactions'] ?? 0,
          'engagement_rate': engagementMetrics['engagement_rate'] ?? 0.0,
          'bounce_rate': engagementMetrics['bounce_rate'] ?? 0.0,
          'total_feedback': feedbackAnalytics['total_feedback'] ?? 0,
          'overall_satisfaction':
              feedbackAnalytics['overall_satisfaction'] ?? 0.0,
          'total_errors': errorAnalytics['total_errors'] ?? 0,
          'overall_abandonment_rate':
              errorAnalytics['overall_abandonment_rate'] ?? 0.0,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      _monitoringService.logInfo(
        'Comprehensive UX metrics reported to Firebase Analytics',
      );
    } catch (e, stackTrace) {
      _monitoringService.logError(
        'Failed to report comprehensive metrics',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Get service status
  Map<String, dynamic> getServiceStatus() {
    return {
      'initialized': _isInitialized,
      'tracking_active': _isTrackingActive,
      'current_user_id': _currentUserId,
      'current_user_type': _currentUserType,
      'services': {
        'ux_monitoring_service': _uxMonitoringService.isInitialized,
        'session_tracker': _sessionTracker.isInitialized,
        'feedback_collector': _feedbackCollector.isInitialized,
        'error_impact_analyzer': _errorImpactAnalyzer.isInitialized,
      },
      'metrics': {
        'total_feedback': _feedbackCollector.totalFeedbackCount,
        'total_error_impacts': _errorImpactAnalyzer.totalErrorImpacts,
      },
    };
  }

  /// Enable/disable tracking
  void setTrackingEnabled(bool enabled) {
    _isTrackingActive = enabled;
    _monitoringService.logInfo(
      'UX tracking ${enabled ? 'enabled' : 'disabled'}',
    );
  }

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;

  /// Check if tracking is active
  bool get isTrackingActive => _isTrackingActive;

  /// Get current user ID
  String? get currentUserId => _currentUserId;

  /// Get current user type
  String? get currentUserType => _currentUserType;

  /// Get UX monitoring service instance
  UXMonitoringService get uxMonitoringService => _uxMonitoringService;

  /// Get session tracker instance
  UserSessionTracker get sessionTracker => _sessionTracker;

  /// Get feedback collector instance
  UserFeedbackCollector get feedbackCollector => _feedbackCollector;

  /// Get error impact analyzer instance
  UXErrorImpactAnalyzer get errorImpactAnalyzer => _errorImpactAnalyzer;

  /// Dispose resources
  Future<void> dispose() async {
    try {
      _metricsReportingTimer?.cancel();

      if (_sessionTracker.isInitialized) {
        await _sessionTracker.dispose();
      }

      if (_feedbackCollector.isInitialized) {
        await _feedbackCollector.dispose();
      }

      if (_errorImpactAnalyzer.isInitialized) {
        await _errorImpactAnalyzer.dispose();
      }

      if (_uxMonitoringService.isInitialized) {
        await _uxMonitoringService.dispose();
      }

      _isInitialized = false;
      _isTrackingActive = false;
      _currentUserId = null;
      _currentUserType = null;

      _monitoringService.logInfo('UX Monitoring Integration disposed');
    } catch (e, stackTrace) {
      _monitoringService.logError(
        'Failed to dispose UX Monitoring Integration',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
}
