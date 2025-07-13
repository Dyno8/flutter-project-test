import 'dart:async';
import 'package:flutter/foundation.dart';
import 'firebase_analytics_service.dart';
import 'analytics_events.dart';
import '../config/environment_config.dart';
import '../monitoring/monitoring_service.dart';

/// Comprehensive business analytics service for CareNow MVP
/// Tracks user behavior, conversion funnels, engagement metrics, and business KPIs
class BusinessAnalyticsService {
  static final BusinessAnalyticsService _instance =
      BusinessAnalyticsService._internal();
  factory BusinessAnalyticsService() => _instance;
  BusinessAnalyticsService._internal();

  // Dependencies
  late final FirebaseAnalyticsService _analyticsService;
  late final MonitoringService _monitoringService;

  // State management
  bool _isInitialized = false;
  String? _currentUserId;
  String? _currentUserType;
  String? _currentSessionId;
  DateTime? _sessionStartTime;

  // Tracking data
  final Map<String, DateTime> _funnelStageTimestamps = {};
  final Map<String, int> _featureUsageCounts = {};
  final List<String> _userJourney = [];
  Timer? _sessionTimer;

  // Configuration
  static const Duration sessionTimeout = Duration(minutes: 30);
  static const int maxJourneyEvents = 100;

  /// Initialize business analytics service
  Future<void> initialize({
    required FirebaseAnalyticsService analyticsService,
    required MonitoringService monitoringService,
  }) async {
    if (_isInitialized) return;

    try {
      _analyticsService = analyticsService;
      _monitoringService = monitoringService;

      // Ensure Firebase Analytics is initialized
      if (!_analyticsService.isInitialized) {
        await _analyticsService.initialize();
      }

      // Start session tracking
      await _startSession();

      _isInitialized = true;

      if (EnvironmentConfig.isDebug) {
        print('📈 Business Analytics Service initialized successfully');
      }
    } catch (e, stackTrace) {
      _monitoringService.logError(
        'Failed to initialize Business Analytics Service',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Set user information for analytics
  Future<void> setUser({
    required String userId,
    required String userType,
    Map<String, String>? userProperties,
  }) async {
    if (!_isInitialized) return;

    try {
      _currentUserId = userId;
      _currentUserType = userType;

      // Set user ID in Firebase Analytics
      await _analyticsService.setUserId(userId);
      await _analyticsService.setUserType(userType);

      // Set additional user properties
      if (userProperties != null) {
        for (final entry in userProperties.entries) {
          await _analyticsService.analytics.setUserProperty(
            name: entry.key,
            value: entry.value,
          );
        }
      }

      // Track user identification event
      await _trackEvent(AnalyticsEvents.userSignIn, {
        AnalyticsParameters.userId: userId,
        AnalyticsParameters.userType: userType,
      });

      _monitoringService.logInfo('User set for analytics: $userId ($userType)');
    } catch (e, stackTrace) {
      _monitoringService.logError(
        'Failed to set user for analytics',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Start a new analytics session
  Future<void> _startSession() async {
    _currentSessionId = DateTime.now().millisecondsSinceEpoch.toString();
    _sessionStartTime = DateTime.now();
    _userJourney.clear();
    _funnelStageTimestamps.clear();

    // Start session timeout timer
    _sessionTimer?.cancel();
    _sessionTimer = Timer(sessionTimeout, _endSession);

    await _trackEvent(AnalyticsEvents.appOpened, {
      AnalyticsParameters.sessionId: _currentSessionId!,
      AnalyticsParameters.timestamp: _sessionStartTime!.toIso8601String(),
    });
  }

  /// End current analytics session
  Future<void> _endSession() async {
    if (_sessionStartTime == null || _currentSessionId == null) return;

    final sessionDuration = DateTime.now().difference(_sessionStartTime!);

    await _trackEvent(AnalyticsEvents.appClosed, {
      AnalyticsParameters.sessionId: _currentSessionId!,
      'session_duration_seconds': sessionDuration.inSeconds,
      'journey_events_count': _userJourney.length,
    });

    _sessionTimer?.cancel();
    _currentSessionId = null;
    _sessionStartTime = null;
  }

  /// Track screen view with analytics
  Future<void> trackScreenView({
    required String screenName,
    String? screenClass,
    Map<String, Object?>? parameters,
  }) async {
    if (!_isInitialized) return;

    try {
      // Add to user journey
      _addToUserJourney('screen_view:$screenName');

      // Track screen view
      await _analyticsService.logScreenView(
        screenName: screenName,
        screenClass: screenClass,
        parameters: {
          AnalyticsParameters.sessionId: _currentSessionId ?? 'unknown',
          ...?parameters,
        },
      );

      // Reset session timer
      _resetSessionTimer();
    } catch (e, stackTrace) {
      _monitoringService.logError(
        'Failed to track screen view: $screenName',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Track user action with business context
  Future<void> trackUserAction({
    required String actionName,
    String? category,
    String? screenName,
    Map<String, Object?>? parameters,
  }) async {
    if (!_isInitialized) return;

    try {
      // Update feature usage count
      _featureUsageCounts[actionName] =
          (_featureUsageCounts[actionName] ?? 0) + 1;

      // Add to user journey
      _addToUserJourney('action:$actionName');

      // Track the action
      await _trackEvent(AnalyticsEvents.featureUsed, {
        AnalyticsParameters.featureName: actionName,
        AnalyticsParameters.actionType: category ?? 'user_action',
        if (screenName != null) AnalyticsParameters.screenName: screenName,
        AnalyticsParameters.sessionId: _currentSessionId ?? 'unknown',
        'usage_count': _featureUsageCounts[actionName],
        ...?parameters,
      });

      // Reset session timer
      _resetSessionTimer();
    } catch (e, stackTrace) {
      _monitoringService.logError(
        'Failed to track user action: $actionName',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Track conversion funnel stage
  Future<void> trackFunnelStage({
    required String funnelName,
    required String stageName,
    Map<String, Object?>? parameters,
  }) async {
    if (!_isInitialized) return;

    try {
      final stageKey = '${funnelName}_$stageName';
      _funnelStageTimestamps[stageKey] = DateTime.now();

      // Add to user journey
      _addToUserJourney('funnel:$stageKey');

      await _trackEvent(AnalyticsEvents.conversionFunnel, {
        'funnel_name': funnelName,
        AnalyticsParameters.funnelStage: stageName,
        AnalyticsParameters.sessionId: _currentSessionId ?? 'unknown',
        if (_currentUserId != null) AnalyticsParameters.userId: _currentUserId!,
        if (_currentUserType != null)
          AnalyticsParameters.userType: _currentUserType!,
        ...?parameters,
      });

      _monitoringService.logInfo(
        'Funnel stage tracked: $funnelName -> $stageName',
      );
    } catch (e, stackTrace) {
      _monitoringService.logError(
        'Failed to track funnel stage: $funnelName -> $stageName',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Track business event (booking, payment, etc.)
  Future<void> trackBusinessEvent({
    required String eventName,
    double? revenue,
    String? currency,
    Map<String, Object?>? parameters,
  }) async {
    if (!_isInitialized) return;

    try {
      final eventParameters = <String, Object?>{
        AnalyticsParameters.sessionId: _currentSessionId ?? 'unknown',
        if (_currentUserId != null) AnalyticsParameters.userId: _currentUserId!,
        if (_currentUserType != null)
          AnalyticsParameters.userType: _currentUserType!,
        if (revenue != null) AnalyticsParameters.revenue: revenue,
        if (currency != null) AnalyticsParameters.paymentCurrency: currency,
        ...?parameters,
      };

      // Add to user journey
      _addToUserJourney('business:$eventName');

      await _trackEvent(eventName, eventParameters);

      // Track revenue if provided
      if (revenue != null) {
        await _trackEvent(AnalyticsEvents.revenueGenerated, {
          AnalyticsParameters.revenue: revenue,
          AnalyticsParameters.paymentCurrency: currency ?? 'USD',
          'event_source': eventName,
          ...eventParameters,
        });
      }

      _monitoringService.logInfo(
        'Business event tracked: $eventName${revenue != null ? ' (\$${revenue.toStringAsFixed(2)})' : ''}',
      );
    } catch (e, stackTrace) {
      _monitoringService.logError(
        'Failed to track business event: $eventName',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Track engagement metrics
  Future<void> trackEngagement({
    required String engagementType,
    Duration? duration,
    int? count,
    Map<String, Object?>? parameters,
  }) async {
    if (!_isInitialized) return;

    try {
      await _trackEvent('engagement_$engagementType', {
        'engagement_type': engagementType,
        if (duration != null) 'duration_seconds': duration.inSeconds,
        if (count != null) 'count': count,
        AnalyticsParameters.sessionId: _currentSessionId ?? 'unknown',
        ...?parameters,
      });
    } catch (e, stackTrace) {
      _monitoringService.logError(
        'Failed to track engagement: $engagementType',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Track error with business context
  Future<void> trackError({
    required String errorType,
    required dynamic error,
    StackTrace? stackTrace,
    String? screenName,
    String? userAction,
    Map<String, dynamic>? metadata,
  }) async {
    if (!_isInitialized) return;

    try {
      final errorMetadata = <String, dynamic>{
        'session_id': _currentSessionId ?? 'unknown',
        if (_currentUserId != null) 'user_id': _currentUserId!,
        if (_currentUserType != null) 'user_type': _currentUserType!,
        if (screenName != null) 'screen_name': screenName,
        if (userAction != null) 'user_action': userAction,
        'user_journey': _userJourney.take(10).toList(), // Last 10 events
        ...?metadata,
      };

      // Track to Firebase Crashlytics and Analytics
      await _analyticsService.recordError(
        error,
        stackTrace,
        metadata: errorMetadata,
      );

      // Add to user journey
      _addToUserJourney('error:$errorType');

      _monitoringService.logError(
        'Business error tracked: $errorType',
        error: error,
        stackTrace: stackTrace,
        metadata: errorMetadata,
      );
    } catch (e, stackTrace) {
      _monitoringService.logError(
        'Failed to track business error: $errorType',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Get user journey for analysis
  List<String> getUserJourney() => List.unmodifiable(_userJourney);

  /// Get feature usage statistics
  Map<String, int> getFeatureUsageStats() =>
      Map.unmodifiable(_featureUsageCounts);

  /// Get current session information
  Map<String, dynamic> getSessionInfo() {
    return {
      'session_id': _currentSessionId,
      'session_start_time': _sessionStartTime?.toIso8601String(),
      'session_duration_seconds': _sessionStartTime != null
          ? DateTime.now().difference(_sessionStartTime!).inSeconds
          : 0,
      'user_id': _currentUserId,
      'user_type': _currentUserType,
      'journey_events_count': _userJourney.length,
      'feature_usage_count': _featureUsageCounts.length,
    };
  }

  /// Helper method to track events
  Future<void> _trackEvent(
    String eventName,
    Map<String, Object?> parameters,
  ) async {
    await _analyticsService.logEvent(eventName, parameters: parameters);
  }

  /// Add event to user journey
  void _addToUserJourney(String event) {
    _userJourney.add('${DateTime.now().toIso8601String()}:$event');

    // Keep journey size manageable
    while (_userJourney.length > maxJourneyEvents) {
      _userJourney.removeAt(0);
    }
  }

  /// Reset session timer
  void _resetSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer(sessionTimeout, _endSession);
  }

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;

  /// Get current user ID
  String? get currentUserId => _currentUserId;

  /// Get current user type
  String? get currentUserType => _currentUserType;

  /// Dispose resources
  Future<void> dispose() async {
    _sessionTimer?.cancel();
    await _endSession();
    _isInitialized = false;
  }
}

/// User behavior tracking service for detailed user interaction analysis
class UserBehaviorTrackingService {
  static final UserBehaviorTrackingService _instance =
      UserBehaviorTrackingService._internal();
  factory UserBehaviorTrackingService() => _instance;
  UserBehaviorTrackingService._internal();

  // Dependencies
  BusinessAnalyticsService? _businessAnalytics;
  MonitoringService? _monitoringService;

  // Behavior tracking data
  final Map<String, List<DateTime>> _clickPatterns = {};
  final Map<String, Duration> _screenTimeTracking = {};
  final Map<String, DateTime> _screenStartTimes = {};
  final List<Map<String, dynamic>> _searchQueries = [];
  final Map<String, int> _errorEncounters = {};

  /// Initialize user behavior tracking
  void initialize({
    required BusinessAnalyticsService businessAnalytics,
    required MonitoringService monitoringService,
  }) {
    _businessAnalytics = businessAnalytics;
    _monitoringService = monitoringService;
  }

  /// Track user click/tap patterns
  Future<void> trackClickPattern({
    required String elementId,
    required String screenName,
    Map<String, Object?>? metadata,
  }) async {
    if (_businessAnalytics == null) return;

    try {
      final now = DateTime.now();
      _clickPatterns[elementId] ??= [];
      _clickPatterns[elementId]!.add(now);

      // Keep only recent clicks (last 100)
      if (_clickPatterns[elementId]!.length > 100) {
        _clickPatterns[elementId]!.removeAt(0);
      }

      await _businessAnalytics!.trackUserAction(
        actionName: 'click_pattern',
        category: 'interaction',
        screenName: screenName,
        parameters: {
          'element_id': elementId,
          'click_count': _clickPatterns[elementId]!.length,
          ...?metadata,
        },
      );
    } catch (e) {
      _monitoringService?.logError('Failed to track click pattern', error: e);
    }
  }

  /// Track screen time
  Future<void> startScreenTimeTracking(String screenName) async {
    _screenStartTimes[screenName] = DateTime.now();
  }

  /// End screen time tracking
  Future<void> endScreenTimeTracking(String screenName) async {
    if (_businessAnalytics == null) return;

    try {
      final startTime = _screenStartTimes[screenName];
      if (startTime != null) {
        final duration = DateTime.now().difference(startTime);
        _screenTimeTracking[screenName] = duration;

        await _businessAnalytics!.trackEngagement(
          engagementType: 'screen_time',
          duration: duration,
          parameters: {
            'screen_name': screenName,
            'duration_seconds': duration.inSeconds,
          },
        );

        _screenStartTimes.remove(screenName);
      }
    } catch (e) {
      _monitoringService?.logError('Failed to track screen time', error: e);
    }
  }

  /// Track search behavior
  Future<void> trackSearchBehavior({
    required String query,
    required String searchType,
    int? resultsCount,
    String? selectedResult,
  }) async {
    if (_businessAnalytics == null) return;

    try {
      final searchData = {
        'query': query,
        'search_type': searchType,
        'timestamp': DateTime.now().toIso8601String(),
        'results_count': resultsCount,
        'selected_result': selectedResult,
      };

      _searchQueries.add(searchData);

      // Keep only recent searches (last 50)
      if (_searchQueries.length > 50) {
        _searchQueries.removeAt(0);
      }

      await _businessAnalytics!.trackUserAction(
        actionName: 'search_performed',
        category: 'search',
        parameters: {
          'search_query': query,
          'search_type': searchType,
          'results_count': resultsCount ?? 0,
          if (selectedResult != null) 'selected_result': selectedResult,
        },
      );
    } catch (e) {
      _monitoringService?.logError('Failed to track search behavior', error: e);
    }
  }

  /// Track user error encounters
  Future<void> trackUserErrorEncounter({
    required String errorType,
    required String screenName,
    String? userAction,
    Map<String, dynamic>? context,
  }) async {
    if (_businessAnalytics == null) return;

    try {
      _errorEncounters[errorType] = (_errorEncounters[errorType] ?? 0) + 1;

      await _businessAnalytics!.trackError(
        errorType: errorType,
        error: 'User encountered error: $errorType',
        screenName: screenName,
        userAction: userAction,
        metadata: {
          'error_encounter_count': _errorEncounters[errorType],
          'is_user_error': true,
          ...?context,
        },
      );
    } catch (e) {
      _monitoringService?.logError(
        'Failed to track user error encounter',
        error: e,
      );
    }
  }

  /// Get behavior analytics summary
  Map<String, dynamic> getBehaviorSummary() {
    return {
      'click_patterns': _clickPatterns.map((k, v) => MapEntry(k, v.length)),
      'screen_time_tracking': _screenTimeTracking.map(
        (k, v) => MapEntry(k, v.inSeconds),
      ),
      'recent_searches': _searchQueries.take(10).toList(),
      'error_encounters': _errorEncounters,
      'total_interactions': _clickPatterns.values.fold(
        0,
        (sum, list) => sum + list.length,
      ),
    };
  }

  /// Clear behavior tracking data
  void clearBehaviorData() {
    _clickPatterns.clear();
    _screenTimeTracking.clear();
    _screenStartTimes.clear();
    _searchQueries.clear();
    _errorEncounters.clear();
  }
}
