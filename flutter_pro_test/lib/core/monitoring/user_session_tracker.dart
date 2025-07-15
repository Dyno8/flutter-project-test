import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../analytics/firebase_analytics_service.dart';
import 'monitoring_service.dart';
import 'ux_monitoring_service.dart';
import '../config/environment_config.dart';

/// Specialized service for tracking user sessions and journeys
/// Provides detailed analytics on user behavior, navigation patterns, and engagement
class UserSessionTracker {
  static final UserSessionTracker _instance = UserSessionTracker._internal();
  factory UserSessionTracker() => _instance;
  UserSessionTracker._internal();

  // Dependencies
  late final UXMonitoringService _uxMonitoringService;
  late final FirebaseAnalyticsService _analyticsService;
  late final MonitoringService _monitoringService;
  SharedPreferences? _prefs;

  // State management
  bool _isInitialized = false;
  bool _isTrackingActive = false;

  // Session tracking
  String? _currentUserId;
  String? _currentUserType;
  String? _currentSessionId;
  DateTime? _sessionStartTime;
  DateTime? _lastActivityTime;
  String? _currentScreenName;
  final List<Map<String, dynamic>> _sessionJourney = [];
  final Map<String, int> _screenVisitCounts = {};
  final Map<String, double> _screenTimeSpent = {};

  // Navigation patterns
  final Map<String, Map<String, int>> _navigationFlows = {};
  final List<String> _navigationHistory = [];

  // Engagement metrics
  int _totalTaps = 0;
  int _totalScrolls = 0;
  int _totalTextInputs = 0;
  final Map<String, int> _featureUsage = {};
  final Map<String, double> _averageTimePerScreen = {};

  // Configuration
  static const Duration sessionTimeout = Duration(minutes: 30);
  static const Duration inactivityTimeout = Duration(minutes: 5);
  static const int maxJourneyEvents = 1000;
  static const int maxNavigationHistory = 100;

  // Timers
  Timer? _sessionTimer;
  Timer? _inactivityTimer;
  Timer? _screenTimeTimer;
  DateTime? _screenStartTime;

  /// Initialize user session tracker
  Future<void> initialize({
    required UXMonitoringService uxMonitoringService,
    required FirebaseAnalyticsService analyticsService,
    required MonitoringService monitoringService,
  }) async {
    if (_isInitialized) return;

    try {
      _uxMonitoringService = uxMonitoringService;
      _analyticsService = analyticsService;
      _monitoringService = monitoringService;
      _prefs = await SharedPreferences.getInstance();

      // Load persisted data
      await _loadPersistedData();

      _isInitialized = true;
      _isTrackingActive = true;

      _monitoringService.logInfo('UserSessionTracker initialized successfully');
    } catch (e, stackTrace) {
      _monitoringService.logError(
        'Failed to initialize UserSessionTracker',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Start tracking a new user session
  Future<void> startSession({
    required String userId,
    required String userType,
  }) async {
    if (!_isInitialized) return;

    try {
      // End previous session if exists
      if (_currentSessionId != null) {
        await endSession();
      }

      _currentUserId = userId;
      _currentUserType = userType;
      _currentSessionId = DateTime.now().millisecondsSinceEpoch.toString();
      _sessionStartTime = DateTime.now();
      _lastActivityTime = DateTime.now();
      _sessionJourney.clear();
      _navigationHistory.clear();

      // Reset session timers
      _resetSessionTimers();

      // Track session start
      await _trackSessionEvent('session_started', {
        'user_id': userId,
        'user_type': userType,
        'session_id': _currentSessionId!,
        'timestamp': _sessionStartTime!.toIso8601String(),
        'app_version': EnvironmentConfig.appVersion,
        'environment': EnvironmentConfig.environment,
      });

      _monitoringService.logInfo('User session started: $_currentSessionId');
    } catch (e, stackTrace) {
      _monitoringService.logError(
        'Failed to start user session',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Track screen view
  Future<void> trackScreenView({
    required String screenName,
    String? screenClass,
    Map<String, dynamic>? parameters,
  }) async {
    if (!_isInitialized || !_isTrackingActive || _currentSessionId == null) {
      return;
    }

    try {
      // Calculate time spent on previous screen
      if (_currentScreenName != null && _screenStartTime != null) {
        final timeSpent = DateTime.now().difference(_screenStartTime!);
        _updateScreenTimeSpent(_currentScreenName!, timeSpent);
      }

      // Update current screen
      final previousScreen = _currentScreenName;
      _currentScreenName = screenName;
      _screenStartTime = DateTime.now();
      _lastActivityTime = DateTime.now();

      // Update screen visit counts
      _screenVisitCounts[screenName] =
          (_screenVisitCounts[screenName] ?? 0) + 1;

      // Update navigation flow
      if (previousScreen != null) {
        _navigationFlows.putIfAbsent(previousScreen, () => {});
        _navigationFlows[previousScreen]![screenName] =
            (_navigationFlows[previousScreen]![screenName] ?? 0) + 1;
      }

      // Add to navigation history
      _navigationHistory.add(screenName);
      while (_navigationHistory.length > maxNavigationHistory) {
        _navigationHistory.removeAt(0);
      }

      // Add to journey
      _addToJourney('screen_view', screenName, parameters);

      // Track to UX monitoring
      await _uxMonitoringService.trackJourneyEvent(
        eventType: 'screen_view',
        screenName: screenName,
        metadata: {
          'screen_class': screenClass,
          'visit_count': _screenVisitCounts[screenName],
          'previous_screen': previousScreen,
          ...?parameters,
        },
      );

      // Track to Firebase Analytics
      await _analyticsService.logScreenView(
        screenName: screenName,
        screenClass: screenClass,
        parameters: {
          'session_id': _currentSessionId!,
          'visit_count': _screenVisitCounts[screenName],
          'previous_screen': previousScreen,
          ...?parameters,
        },
      );

      // Reset inactivity timer
      _resetInactivityTimer();

      _monitoringService.logInfo('Screen view tracked: $screenName');
    } catch (e, stackTrace) {
      _monitoringService.logError(
        'Failed to track screen view',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Track user interaction
  Future<void> trackInteraction({
    required String interactionType,
    required String elementId,
    String? action,
    Map<String, dynamic>? parameters,
  }) async {
    if (!_isInitialized || !_isTrackingActive || _currentSessionId == null) {
      return;
    }

    try {
      _lastActivityTime = DateTime.now();

      // Update interaction counts
      switch (interactionType) {
        case 'tap':
          _totalTaps++;
          break;
        case 'scroll':
          _totalScrolls++;
          break;
        case 'text_input':
          _totalTextInputs++;
          break;
      }

      // Add to journey
      _addToJourney('interaction', interactionType, {
        'element_id': elementId,
        'action': action,
        'screen_name': _currentScreenName,
        ...?parameters,
      });

      // Track to UX monitoring
      await _uxMonitoringService.trackJourneyEvent(
        eventType: 'user_action',
        screenName: _currentScreenName ?? 'unknown',
        action: interactionType,
        metadata: {'element_id': elementId, 'action': action, ...?parameters},
      );

      // Reset inactivity timer
      _resetInactivityTimer();
    } catch (e, stackTrace) {
      _monitoringService.logError(
        'Failed to track user interaction',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Track feature usage
  Future<void> trackFeatureUsage({
    required String featureName,
    String? category,
    Map<String, dynamic>? parameters,
  }) async {
    if (!_isInitialized || !_isTrackingActive || _currentSessionId == null) {
      return;
    }

    try {
      _lastActivityTime = DateTime.now();

      // Update feature usage counts
      _featureUsage[featureName] = (_featureUsage[featureName] ?? 0) + 1;

      // Add to journey
      _addToJourney('feature_used', featureName, {
        'category': category,
        'usage_count': _featureUsage[featureName],
        'screen_name': _currentScreenName,
        ...?parameters,
      });

      // Track to UX monitoring
      await _uxMonitoringService.trackJourneyEvent(
        eventType: 'feature_used',
        screenName: _currentScreenName ?? 'unknown',
        action: featureName,
        metadata: {
          'category': category,
          'usage_count': _featureUsage[featureName],
          ...?parameters,
        },
      );

      // Reset inactivity timer
      _resetInactivityTimer();

      _monitoringService.logInfo('Feature usage tracked: $featureName');
    } catch (e, stackTrace) {
      _monitoringService.logError(
        'Failed to track feature usage',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// End current session
  Future<void> endSession({bool timeout = false}) async {
    if (!_isInitialized || _currentSessionId == null) return;

    try {
      // Calculate final screen time
      if (_currentScreenName != null && _screenStartTime != null) {
        final timeSpent = DateTime.now().difference(_screenStartTime!);
        _updateScreenTimeSpent(_currentScreenName!, timeSpent);
      }

      // Calculate session duration
      final sessionDuration = _sessionStartTime != null
          ? DateTime.now().difference(_sessionStartTime!)
          : Duration.zero;

      // Track session end
      await _trackSessionEvent('session_ended', {
        'session_id': _currentSessionId!,
        'duration_seconds': sessionDuration.inSeconds,
        'screen_count': _screenVisitCounts.length,
        'interaction_count': _totalTaps + _totalScrolls + _totalTextInputs,
        'timeout': timeout,
        'timestamp': DateTime.now().toIso8601String(),
      });

      // Save session data
      await _saveSessionData();

      // Cancel timers
      _sessionTimer?.cancel();
      _inactivityTimer?.cancel();
      _screenTimeTimer?.cancel();

      // Clear session data
      _currentSessionId = null;
      _sessionStartTime = null;
      _screenStartTime = null;
      _currentScreenName = null;

      _monitoringService.logInfo(
        'User session ended${timeout ? ' (timeout)' : ''}',
      );
    } catch (e, stackTrace) {
      _monitoringService.logError(
        'Failed to end user session',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Get current session analytics
  Map<String, dynamic> getCurrentSessionAnalytics() {
    if (_currentSessionId == null) {
      return {'active': false, 'message': 'No active session'};
    }

    final sessionDuration = _sessionStartTime != null
        ? DateTime.now().difference(_sessionStartTime!)
        : Duration.zero;

    return {
      'active': true,
      'session_id': _currentSessionId,
      'user_id': _currentUserId,
      'user_type': _currentUserType,
      'duration_seconds': sessionDuration.inSeconds,
      'current_screen': _currentScreenName,
      'screens_visited': _screenVisitCounts.length,
      'total_interactions': _totalTaps + _totalScrolls + _totalTextInputs,
      'journey_events': _sessionJourney.length,
      'features_used': _featureUsage.length,
      'last_activity': _lastActivityTime?.toIso8601String(),
    };
  }

  /// Get navigation flow analytics
  Map<String, dynamic> getNavigationFlowAnalytics() {
    return {
      'navigation_flows': _navigationFlows,
      'navigation_history': _navigationHistory.take(20).toList(),
      'screen_visit_counts': _screenVisitCounts,
      'average_time_per_screen': _averageTimePerScreen,
      'most_visited_screens': _getMostVisitedScreens(),
      'common_navigation_paths': _getCommonNavigationPaths(),
    };
  }

  /// Get engagement metrics
  Map<String, dynamic> getEngagementMetrics() {
    final sessionDuration = _sessionStartTime != null
        ? DateTime.now().difference(_sessionStartTime!)
        : Duration.zero;

    return {
      'session_duration_seconds': sessionDuration.inSeconds,
      'total_taps': _totalTaps,
      'total_scrolls': _totalScrolls,
      'total_text_inputs': _totalTextInputs,
      'feature_usage': _featureUsage,
      'engagement_rate': _calculateEngagementRate(),
      'bounce_rate': _calculateBounceRate(),
      'session_depth': _screenVisitCounts.length,
    };
  }

  /// Helper method to add event to journey
  void _addToJourney(
    String eventType,
    String eventName,
    Map<String, dynamic>? metadata,
  ) {
    final journeyEvent = {
      'timestamp': DateTime.now().toIso8601String(),
      'event_type': eventType,
      'event_name': eventName,
      'screen_name': _currentScreenName,
      'session_id': _currentSessionId,
      'metadata': metadata ?? {},
    };

    _sessionJourney.add(journeyEvent);

    // Keep journey size manageable
    while (_sessionJourney.length > maxJourneyEvents) {
      _sessionJourney.removeAt(0);
    }
  }

  /// Update screen time spent
  void _updateScreenTimeSpent(String screenName, Duration timeSpent) {
    final currentTime = _screenTimeSpent[screenName] ?? 0.0;
    _screenTimeSpent[screenName] = currentTime + timeSpent.inSeconds;

    // Update average time per screen
    final visitCount = _screenVisitCounts[screenName] ?? 1;
    _averageTimePerScreen[screenName] =
        _screenTimeSpent[screenName]! / visitCount;
  }

  /// Reset session timers
  void _resetSessionTimers() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer(sessionTimeout, () => endSession(timeout: true));
    _resetInactivityTimer();
  }

  /// Reset inactivity timer
  void _resetInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(inactivityTimeout, _handleInactivity);
  }

  /// Handle user inactivity
  void _handleInactivity() {
    _monitoringService.logInfo('User inactivity detected');

    // Track inactivity event
    _addToJourney('inactivity', 'user_inactive', {
      'last_activity': _lastActivityTime?.toIso8601String(),
      'inactivity_duration_seconds': inactivityTimeout.inSeconds,
    });
  }

  /// Track session events
  Future<void> _trackSessionEvent(
    String eventName,
    Map<String, dynamic> parameters,
  ) async {
    try {
      await _analyticsService.logEvent(eventName, parameters: parameters);
      _addToJourney('session_event', eventName, parameters);
    } catch (e) {
      _monitoringService.logError(
        'Failed to track session event: $eventName',
        error: e,
      );
    }
  }

  /// Get most visited screens
  List<Map<String, dynamic>> _getMostVisitedScreens() {
    final sortedScreens = _screenVisitCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedScreens
        .take(10)
        .map(
          (entry) => {
            'screen_name': entry.key,
            'visit_count': entry.value,
            'average_time_seconds': _averageTimePerScreen[entry.key] ?? 0.0,
          },
        )
        .toList();
  }

  /// Get common navigation paths
  List<Map<String, dynamic>> _getCommonNavigationPaths() {
    final pathCounts = <String, int>{};

    // Analyze navigation history for common 2-step paths
    for (int i = 0; i < _navigationHistory.length - 1; i++) {
      final path = '${_navigationHistory[i]} -> ${_navigationHistory[i + 1]}';
      pathCounts[path] = (pathCounts[path] ?? 0) + 1;
    }

    final sortedPaths = pathCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedPaths
        .take(10)
        .map((entry) => {'path': entry.key, 'count': entry.value})
        .toList();
  }

  /// Calculate engagement rate
  double _calculateEngagementRate() {
    if (_sessionStartTime == null) return 0.0;

    final sessionDuration = DateTime.now().difference(_sessionStartTime!);
    final totalInteractions = _totalTaps + _totalScrolls + _totalTextInputs;

    if (sessionDuration.inSeconds == 0) return 0.0;

    // Interactions per minute
    return (totalInteractions / sessionDuration.inMinutes).clamp(0.0, 100.0);
  }

  /// Calculate bounce rate (single screen sessions)
  double _calculateBounceRate() {
    return _screenVisitCounts.length <= 1 ? 100.0 : 0.0;
  }

  /// Load persisted data
  Future<void> _loadPersistedData() async {
    try {
      // Load navigation flows
      final navigationFlowsJson = _prefs?.getString('session_navigation_flows');
      if (navigationFlowsJson != null) {
        final flowsData =
            jsonDecode(navigationFlowsJson) as Map<String, dynamic>;
        _navigationFlows.clear();
        flowsData.forEach((key, value) {
          _navigationFlows[key] = Map<String, int>.from(value);
        });
      }

      // Load feature usage
      final featureUsageJson = _prefs?.getString('session_feature_usage');
      if (featureUsageJson != null) {
        final usageData = jsonDecode(featureUsageJson) as Map<String, dynamic>;
        _featureUsage.clear();
        usageData.forEach((key, value) {
          _featureUsage[key] = value as int;
        });
      }

      _monitoringService.logInfo('Session tracker persisted data loaded');
    } catch (e, stackTrace) {
      _monitoringService.logError(
        'Failed to load session tracker persisted data',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Save session data
  Future<void> _saveSessionData() async {
    try {
      // Save navigation flows
      await _prefs?.setString(
        'session_navigation_flows',
        jsonEncode(_navigationFlows),
      );

      // Save feature usage
      await _prefs?.setString(
        'session_feature_usage',
        jsonEncode(_featureUsage),
      );

      // Save current session journey
      if (_sessionJourney.isNotEmpty) {
        await _prefs?.setString(
          'last_session_journey',
          jsonEncode(_sessionJourney),
        );
      }

      _monitoringService.logInfo('Session data saved successfully');
    } catch (e, stackTrace) {
      _monitoringService.logError(
        'Failed to save session data',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;

  /// Check if tracking is active
  bool get isTrackingActive => _isTrackingActive;

  /// Get current session ID
  String? get currentSessionId => _currentSessionId;

  /// Get current user ID
  String? get currentUserId => _currentUserId;

  /// Dispose resources
  Future<void> dispose() async {
    _sessionTimer?.cancel();
    _inactivityTimer?.cancel();
    _screenTimeTimer?.cancel();

    if (_currentSessionId != null) {
      await endSession();
    }

    _isInitialized = false;
    _isTrackingActive = false;
  }
}
