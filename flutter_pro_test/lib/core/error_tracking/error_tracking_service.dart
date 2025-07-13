import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../analytics/firebase_analytics_service.dart';
import '../analytics/analytics_events.dart';
import '../monitoring/monitoring_service.dart';
import '../config/environment_config.dart';
import '../../shared/services/notification_service.dart';

/// Comprehensive error tracking and alerting service
class ErrorTrackingService {
  static final ErrorTrackingService _instance =
      ErrorTrackingService._internal();
  factory ErrorTrackingService() => _instance;
  ErrorTrackingService._internal();

  // Dependencies
  FirebaseAnalyticsService? _analyticsService;
  MonitoringService? _monitoringService;
  NotificationService? _notificationService;
  SharedPreferences? _prefs;

  // Error tracking data
  final Map<String, List<ErrorIncident>> _errorHistory = {};
  final Map<String, ErrorThreshold> _errorThresholds = {};
  final Map<String, DateTime> _lastAlertTimes = {};
  final List<ErrorIncident> _recentErrors = [];

  // Configuration
  static const int maxErrorHistory = 1000;
  static const int maxRecentErrors = 50;
  static const Duration alertCooldown = Duration(minutes: 15);
  static const Duration performanceCheckInterval = Duration(minutes: 5);

  // State
  bool _isInitialized = false;
  Timer? _performanceMonitorTimer;
  Timer? _errorCleanupTimer;

  /// Initialize error tracking service
  Future<void> initialize({
    required FirebaseAnalyticsService analyticsService,
    required MonitoringService monitoringService,
    required NotificationService notificationService,
  }) async {
    if (_isInitialized) return;

    try {
      _analyticsService = analyticsService;
      _monitoringService = monitoringService;
      _notificationService = notificationService;
      _prefs = await SharedPreferences.getInstance();

      // Load saved error data
      await _loadErrorData();

      // Set up default error thresholds
      _setupDefaultThresholds();

      // Start monitoring timers
      _startPerformanceMonitoring();
      _startErrorCleanup();

      _isInitialized = true;

      // Track initialization
      await _analyticsService?.logEvent(
        AnalyticsEvents.errorOccurred,
        parameters: {
          'event_type': 'error_tracking_initialized',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      _monitoringService?.logInfo('Error Tracking Service initialized');
    } catch (e, stackTrace) {
      _monitoringService?.logError(
        'Failed to initialize Error Tracking Service',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Track an error incident
  Future<void> trackError({
    required String errorType,
    required String errorMessage,
    required dynamic error,
    StackTrace? stackTrace,
    String? userId,
    String? screenName,
    String? userAction,
    Map<String, dynamic>? metadata,
    ErrorSeverity severity = ErrorSeverity.medium,
    bool fatal = false,
  }) async {
    if (!_isInitialized) return;

    try {
      final incident = ErrorIncident(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        errorType: errorType,
        errorMessage: errorMessage,
        error: error.toString(),
        stackTrace: stackTrace?.toString(),
        userId: userId,
        screenName: screenName,
        userAction: userAction,
        metadata: metadata ?? {},
        severity: severity,
        fatal: fatal,
        timestamp: DateTime.now(),
        environment: EnvironmentConfig.environment,
        appVersion: EnvironmentConfig.appVersion,
      );

      // Add to error history
      _errorHistory[errorType] ??= [];
      _errorHistory[errorType]!.add(incident);

      // Keep history size manageable
      if (_errorHistory[errorType]!.length > maxErrorHistory) {
        _errorHistory[errorType]!.removeAt(0);
      }

      // Add to recent errors
      _recentErrors.add(incident);
      if (_recentErrors.length > maxRecentErrors) {
        _recentErrors.removeAt(0);
      }

      // Track to Firebase Analytics and Crashlytics
      await _trackToFirebase(incident);

      // Check if alert should be triggered
      await _checkAlertThresholds(errorType, incident);

      // Save error data
      await _saveErrorData();

      _monitoringService?.logError(
        'Error tracked: $errorType',
        error: error,
        stackTrace: stackTrace,
        metadata: {
          'incident_id': incident.id,
          'severity': severity.name,
          'fatal': fatal,
          ...?metadata,
        },
      );
    } catch (e, stackTrace) {
      _monitoringService?.logError(
        'Failed to track error',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Track performance degradation
  Future<void> trackPerformanceDegradation({
    required String metricName,
    required double currentValue,
    required double threshold,
    String? context,
    Map<String, dynamic>? metadata,
  }) async {
    if (!_isInitialized) return;

    try {
      await trackError(
        errorType: 'performance_degradation',
        errorMessage: 'Performance metric $metricName exceeded threshold',
        error: 'Current: $currentValue, Threshold: $threshold',
        severity: ErrorSeverity.high,
        metadata: {
          'metric_name': metricName,
          'current_value': currentValue,
          'threshold': threshold,
          'degradation_percentage':
              ((currentValue - threshold) / threshold * 100),
          'context': context,
          ...?metadata,
        },
      );
    } catch (e, stackTrace) {
      _monitoringService?.logError(
        'Failed to track performance degradation',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Set custom error threshold
  void setErrorThreshold({
    required String errorType,
    required int maxOccurrences,
    required Duration timeWindow,
    ErrorSeverity alertSeverity = ErrorSeverity.high,
  }) {
    _errorThresholds[errorType] = ErrorThreshold(
      errorType: errorType,
      maxOccurrences: maxOccurrences,
      timeWindow: timeWindow,
      alertSeverity: alertSeverity,
    );
  }

  /// Get error statistics
  Map<String, dynamic> getErrorStatistics() {
    final now = DateTime.now();
    final last24Hours = now.subtract(const Duration(hours: 24));
    final lastWeek = now.subtract(const Duration(days: 7));

    final recent24hErrors = _recentErrors
        .where((error) => error.timestamp.isAfter(last24Hours))
        .toList();

    final recentWeekErrors = _recentErrors
        .where((error) => error.timestamp.isAfter(lastWeek))
        .toList();

    return {
      'total_errors': _recentErrors.length,
      'errors_24h': recent24hErrors.length,
      'errors_week': recentWeekErrors.length,
      'error_types': _errorHistory.keys.toList(),
      'error_type_counts': _errorHistory.map(
        (type, incidents) => MapEntry(type, incidents.length),
      ),
      'severity_breakdown': _getSeverityBreakdown(recent24hErrors),
      'fatal_errors_24h': recent24hErrors.where((e) => e.fatal).length,
      'most_common_errors': _getMostCommonErrors(recent24hErrors),
      'error_trends': _getErrorTrends(),
    };
  }

  /// Get recent error incidents
  List<ErrorIncident> getRecentErrors({int limit = 20}) {
    final sortedErrors = List<ErrorIncident>.from(_recentErrors)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sortedErrors.take(limit).toList();
  }

  /// Get errors by type
  List<ErrorIncident> getErrorsByType(String errorType) {
    return _errorHistory[errorType] ?? [];
  }

  /// Clear error history
  Future<void> clearErrorHistory() async {
    _errorHistory.clear();
    _recentErrors.clear();
    _lastAlertTimes.clear();
    await _saveErrorData();
    _monitoringService?.logInfo('Error history cleared');
  }

  /// Track to Firebase Analytics and Crashlytics
  Future<void> _trackToFirebase(ErrorIncident incident) async {
    try {
      // Track to Firebase Crashlytics
      await _analyticsService?.recordError(
        incident.error,
        incident.stackTrace != null
            ? StackTrace.fromString(incident.stackTrace!)
            : null,
        metadata: {
          'incident_id': incident.id,
          'error_type': incident.errorType,
          'severity': incident.severity.name,
          'screen_name': incident.screenName,
          'user_action': incident.userAction,
          'user_id': incident.userId,
          ...incident.metadata,
        },
        fatal: incident.fatal,
      );

      // Track to Firebase Analytics
      await _analyticsService?.logEvent(
        AnalyticsEvents.errorOccurred,
        parameters: {
          'error_type': incident.errorType,
          'error_message': incident.errorMessage,
          'severity': incident.severity.name,
          'fatal': incident.fatal,
          'screen_name': incident.screenName ?? 'unknown',
          'user_id': incident.userId ?? 'anonymous',
          'timestamp': incident.timestamp.toIso8601String(),
        },
      );
    } catch (e) {
      _monitoringService?.logError(
        'Failed to track error to Firebase',
        error: e,
      );
    }
  }

  /// Check if alert thresholds are exceeded
  Future<void> _checkAlertThresholds(
    String errorType,
    ErrorIncident incident,
  ) async {
    final threshold = _errorThresholds[errorType];
    if (threshold == null) return;

    final now = DateTime.now();
    final windowStart = now.subtract(threshold.timeWindow);

    final recentErrors =
        _errorHistory[errorType]
            ?.where((error) => error.timestamp.isAfter(windowStart))
            .toList() ??
        [];

    if (recentErrors.length >= threshold.maxOccurrences) {
      final lastAlert = _lastAlertTimes[errorType];
      if (lastAlert == null || now.difference(lastAlert) > alertCooldown) {
        await _sendAlert(errorType, threshold, recentErrors, incident);
        _lastAlertTimes[errorType] = now;
      }
    }
  }

  /// Send alert notification
  Future<void> _sendAlert(
    String errorType,
    ErrorThreshold threshold,
    List<ErrorIncident> recentErrors,
    ErrorIncident triggeringIncident,
  ) async {
    try {
      final alertMessage =
          'Error threshold exceeded for $errorType: '
          '${recentErrors.length} occurrences in ${threshold.timeWindow.inMinutes} minutes';

      // Send notification to admin users
      await _notificationService?.sendNotificationToAdmins(
        title: 'Error Alert: $errorType',
        body: alertMessage,
        data: {
          'type': 'error_alert',
          'error_type': errorType,
          'occurrence_count': recentErrors.length.toString(),
          'threshold': threshold.maxOccurrences.toString(),
          'time_window_minutes': threshold.timeWindow.inMinutes.toString(),
          'incident_id': triggeringIncident.id,
        },
      );

      // Track alert sent
      await _analyticsService?.logEvent(
        'error_alert_sent',
        parameters: {
          'error_type': errorType,
          'occurrence_count': recentErrors.length,
          'threshold': threshold.maxOccurrences,
          'severity': threshold.alertSeverity.name,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      _monitoringService?.logInfo(
        'Error alert sent for $errorType: ${recentErrors.length} occurrences',
      );
    } catch (e, stackTrace) {
      _monitoringService?.logError(
        'Failed to send error alert',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Setup default error thresholds
  void _setupDefaultThresholds() {
    // App crashes - very sensitive
    setErrorThreshold(
      errorType: 'app_crash',
      maxOccurrences: 3,
      timeWindow: const Duration(hours: 1),
      alertSeverity: ErrorSeverity.critical,
    );

    // Network errors - moderate sensitivity
    setErrorThreshold(
      errorType: 'network_error',
      maxOccurrences: 10,
      timeWindow: const Duration(minutes: 30),
      alertSeverity: ErrorSeverity.high,
    );

    // Authentication errors - high sensitivity
    setErrorThreshold(
      errorType: 'auth_error',
      maxOccurrences: 5,
      timeWindow: const Duration(minutes: 15),
      alertSeverity: ErrorSeverity.high,
    );

    // Performance degradation - moderate sensitivity
    setErrorThreshold(
      errorType: 'performance_degradation',
      maxOccurrences: 5,
      timeWindow: const Duration(minutes: 10),
      alertSeverity: ErrorSeverity.medium,
    );

    // Validation errors - low sensitivity
    setErrorThreshold(
      errorType: 'validation_error',
      maxOccurrences: 20,
      timeWindow: const Duration(hours: 1),
      alertSeverity: ErrorSeverity.low,
    );
  }

  /// Start performance monitoring
  void _startPerformanceMonitoring() {
    _performanceMonitorTimer = Timer.periodic(performanceCheckInterval, (
      _,
    ) async {
      await _checkPerformanceMetrics();
    });
  }

  /// Start error cleanup timer
  void _startErrorCleanup() {
    _errorCleanupTimer = Timer.periodic(const Duration(hours: 6), (_) async {
      await _cleanupOldErrors();
    });
  }

  /// Check performance metrics for degradation
  Future<void> _checkPerformanceMetrics() async {
    try {
      final healthStatus = _monitoringService?.getHealthStatus() ?? {};
      final performanceScore = healthStatus['score'] as double? ?? 100.0;

      // Check if performance score is below threshold
      if (performanceScore < 70.0) {
        await trackPerformanceDegradation(
          metricName: 'overall_performance_score',
          currentValue: performanceScore,
          threshold: 70.0,
          context: 'automated_monitoring',
          metadata: {
            'health_status': healthStatus,
            'check_time': DateTime.now().toIso8601String(),
          },
        );
      }
    } catch (e) {
      _monitoringService?.logError(
        'Failed to check performance metrics',
        error: e,
      );
    }
  }

  /// Cleanup old errors to prevent memory issues
  Future<void> _cleanupOldErrors() async {
    try {
      final cutoffTime = DateTime.now().subtract(const Duration(days: 7));

      // Remove old errors from history
      for (final errorType in _errorHistory.keys.toList()) {
        _errorHistory[errorType]?.removeWhere(
          (error) => error.timestamp.isBefore(cutoffTime),
        );

        if (_errorHistory[errorType]?.isEmpty ?? true) {
          _errorHistory.remove(errorType);
        }
      }

      // Remove old recent errors
      _recentErrors.removeWhere(
        (error) => error.timestamp.isBefore(cutoffTime),
      );

      await _saveErrorData();
      _monitoringService?.logInfo('Old error data cleaned up');
    } catch (e) {
      _monitoringService?.logError('Failed to cleanup old errors', error: e);
    }
  }

  /// Load error data from storage
  Future<void> _loadErrorData() async {
    try {
      final errorDataJson = _prefs?.getString('error_tracking_data');
      if (errorDataJson != null) {
        final errorData = jsonDecode(errorDataJson) as Map<String, dynamic>;

        // Load recent errors
        final recentErrorsData =
            errorData['recent_errors'] as List<dynamic>? ?? [];
        _recentErrors.clear();
        for (final errorJson in recentErrorsData) {
          try {
            _recentErrors.add(ErrorIncident.fromJson(errorJson));
          } catch (e) {
            // Skip invalid error data
          }
        }

        // Load last alert times
        final alertTimesData =
            errorData['last_alert_times'] as Map<String, dynamic>? ?? {};
        _lastAlertTimes.clear();
        for (final entry in alertTimesData.entries) {
          try {
            _lastAlertTimes[entry.key] = DateTime.parse(entry.value);
          } catch (e) {
            // Skip invalid timestamp
          }
        }
      }
    } catch (e) {
      _monitoringService?.logError('Failed to load error data', error: e);
    }
  }

  /// Save error data to storage
  Future<void> _saveErrorData() async {
    try {
      final errorData = {
        'recent_errors': _recentErrors.map((error) => error.toJson()).toList(),
        'last_alert_times': _lastAlertTimes.map(
          (key, value) => MapEntry(key, value.toIso8601String()),
        ),
        'saved_at': DateTime.now().toIso8601String(),
      };

      await _prefs?.setString('error_tracking_data', jsonEncode(errorData));
    } catch (e) {
      _monitoringService?.logError('Failed to save error data', error: e);
    }
  }

  /// Get severity breakdown
  Map<String, int> _getSeverityBreakdown(List<ErrorIncident> errors) {
    final breakdown = <String, int>{};
    for (final error in errors) {
      breakdown[error.severity.name] =
          (breakdown[error.severity.name] ?? 0) + 1;
    }
    return breakdown;
  }

  /// Get most common errors
  List<Map<String, dynamic>> _getMostCommonErrors(List<ErrorIncident> errors) {
    final errorCounts = <String, int>{};
    for (final error in errors) {
      errorCounts[error.errorType] = (errorCounts[error.errorType] ?? 0) + 1;
    }

    final sortedErrors = errorCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedErrors
        .take(5)
        .map((entry) => {'error_type': entry.key, 'count': entry.value})
        .toList();
  }

  /// Get error trends
  Map<String, dynamic> _getErrorTrends() {
    final now = DateTime.now();
    final last24Hours = now.subtract(const Duration(hours: 24));
    final previous24Hours = now.subtract(const Duration(hours: 48));

    final recent24h = _recentErrors
        .where((error) => error.timestamp.isAfter(last24Hours))
        .length;

    final previous24h = _recentErrors
        .where(
          (error) =>
              error.timestamp.isAfter(previous24Hours) &&
              error.timestamp.isBefore(last24Hours),
        )
        .length;

    final trend = previous24h > 0
        ? ((recent24h - previous24h) / previous24h * 100).round()
        : 0;

    return {
      'current_24h': recent24h,
      'previous_24h': previous24h,
      'trend_percentage': trend,
      'trend_direction': trend > 0
          ? 'increasing'
          : trend < 0
          ? 'decreasing'
          : 'stable',
    };
  }

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;

  /// Dispose resources
  void dispose() {
    _performanceMonitorTimer?.cancel();
    _errorCleanupTimer?.cancel();
    _isInitialized = false;
  }
}

/// Error incident model
class ErrorIncident {
  final String id;
  final String errorType;
  final String errorMessage;
  final String error;
  final String? stackTrace;
  final String? userId;
  final String? screenName;
  final String? userAction;
  final Map<String, dynamic> metadata;
  final ErrorSeverity severity;
  final bool fatal;
  final DateTime timestamp;
  final String environment;
  final String appVersion;

  ErrorIncident({
    required this.id,
    required this.errorType,
    required this.errorMessage,
    required this.error,
    this.stackTrace,
    this.userId,
    this.screenName,
    this.userAction,
    required this.metadata,
    required this.severity,
    required this.fatal,
    required this.timestamp,
    required this.environment,
    required this.appVersion,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'errorType': errorType,
    'errorMessage': errorMessage,
    'error': error,
    'stackTrace': stackTrace,
    'userId': userId,
    'screenName': screenName,
    'userAction': userAction,
    'metadata': metadata,
    'severity': severity.name,
    'fatal': fatal,
    'timestamp': timestamp.toIso8601String(),
    'environment': environment,
    'appVersion': appVersion,
  };

  factory ErrorIncident.fromJson(Map<String, dynamic> json) => ErrorIncident(
    id: json['id'],
    errorType: json['errorType'],
    errorMessage: json['errorMessage'],
    error: json['error'],
    stackTrace: json['stackTrace'],
    userId: json['userId'],
    screenName: json['screenName'],
    userAction: json['userAction'],
    metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    severity: ErrorSeverity.values.firstWhere(
      (s) => s.name == json['severity'],
      orElse: () => ErrorSeverity.medium,
    ),
    fatal: json['fatal'] ?? false,
    timestamp: DateTime.parse(json['timestamp']),
    environment: json['environment'] ?? 'unknown',
    appVersion: json['appVersion'] ?? 'unknown',
  );
}

/// Error threshold configuration
class ErrorThreshold {
  final String errorType;
  final int maxOccurrences;
  final Duration timeWindow;
  final ErrorSeverity alertSeverity;

  ErrorThreshold({
    required this.errorType,
    required this.maxOccurrences,
    required this.timeWindow,
    required this.alertSeverity,
  });
}

/// Error severity levels
enum ErrorSeverity { low, medium, high, critical }

/// Extension for NotificationService to send admin notifications
extension NotificationServiceExtension on NotificationService {
  Future<void> sendNotificationToAdmins({
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    // In a real implementation, this would send notifications to all admin users
    // For now, we'll just log the notification
    print('Admin Notification: $title - $body');
  }
}

/// Incident management service for handling error incidents
class IncidentManagementService {
  static final IncidentManagementService _instance =
      IncidentManagementService._internal();
  factory IncidentManagementService() => _instance;
  IncidentManagementService._internal();

  // Dependencies
  ErrorTrackingService? _errorTrackingService;
  NotificationService? _notificationService;
  MonitoringService? _monitoringService;

  // Incident data
  final Map<String, Incident> _activeIncidents = {};
  final List<Incident> _incidentHistory = [];

  // Configuration
  static const Duration incidentTimeout = Duration(hours: 2);
  static const int maxIncidentHistory = 500;

  /// Initialize incident management service
  Future<void> initialize({
    required ErrorTrackingService errorTrackingService,
    required NotificationService notificationService,
    required MonitoringService monitoringService,
  }) async {
    _errorTrackingService = errorTrackingService;
    _notificationService = notificationService;
    _monitoringService = monitoringService;

    // Start incident monitoring
    _startIncidentMonitoring();

    _monitoringService?.logInfo('Incident Management Service initialized');
  }

  /// Create incident from error
  Future<Incident> createIncident({
    required ErrorIncident errorIncident,
    String? description,
    IncidentPriority priority = IncidentPriority.medium,
  }) async {
    final incident = Incident(
      id: 'INC-${DateTime.now().millisecondsSinceEpoch}',
      title: 'Error: ${errorIncident.errorType}',
      description: description ?? errorIncident.errorMessage,
      priority: priority,
      status: IncidentStatus.open,
      errorIncident: errorIncident,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _activeIncidents[incident.id] = incident;

    // Send notification for high/critical priority incidents
    if (priority == IncidentPriority.high ||
        priority == IncidentPriority.critical) {
      await _sendIncidentNotification(incident);
    }

    _monitoringService?.logInfo('Incident created: ${incident.id}');
    return incident;
  }

  /// Update incident status
  Future<void> updateIncidentStatus(
    String incidentId,
    IncidentStatus status,
  ) async {
    final incident = _activeIncidents[incidentId];
    if (incident != null) {
      final updatedIncident = incident.copyWith(
        status: status,
        updatedAt: DateTime.now(),
        resolvedAt: status == IncidentStatus.resolved ? DateTime.now() : null,
      );

      if (status == IncidentStatus.resolved ||
          status == IncidentStatus.closed) {
        _activeIncidents.remove(incidentId);
        _incidentHistory.add(updatedIncident);

        // Keep history size manageable
        if (_incidentHistory.length > maxIncidentHistory) {
          _incidentHistory.removeAt(0);
        }
      } else {
        _activeIncidents[incidentId] = updatedIncident;
      }

      _monitoringService?.logInfo(
        'Incident $incidentId status updated to ${status.name}',
      );
    }
  }

  /// Get active incidents
  List<Incident> getActiveIncidents() {
    return _activeIncidents.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Get incident history
  List<Incident> getIncidentHistory({int limit = 50}) {
    final sortedHistory = List<Incident>.from(_incidentHistory)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sortedHistory.take(limit).toList();
  }

  /// Get incident statistics
  Map<String, dynamic> getIncidentStatistics() {
    final now = DateTime.now();
    final last24Hours = now.subtract(const Duration(hours: 24));
    final lastWeek = now.subtract(const Duration(days: 7));

    final allIncidents = [..._activeIncidents.values, ..._incidentHistory];

    final recent24h = allIncidents
        .where((incident) => incident.createdAt.isAfter(last24Hours))
        .toList();

    final recentWeek = allIncidents
        .where((incident) => incident.createdAt.isAfter(lastWeek))
        .toList();

    return {
      'active_incidents': _activeIncidents.length,
      'total_incidents': allIncidents.length,
      'incidents_24h': recent24h.length,
      'incidents_week': recentWeek.length,
      'priority_breakdown': _getPriorityBreakdown(recent24h),
      'status_breakdown': _getStatusBreakdown(allIncidents),
      'avg_resolution_time': _getAverageResolutionTime(),
      'critical_incidents_24h': recent24h
          .where((i) => i.priority == IncidentPriority.critical)
          .length,
    };
  }

  /// Send incident notification
  Future<void> _sendIncidentNotification(Incident incident) async {
    try {
      await _notificationService?.sendNotificationToAdmins(
        title: 'New ${incident.priority.name.toUpperCase()} Incident',
        body: '${incident.title}: ${incident.description}',
        data: {
          'type': 'incident_created',
          'incident_id': incident.id,
          'priority': incident.priority.name,
          'error_type': incident.errorIncident.errorType,
        },
      );
    } catch (e) {
      _monitoringService?.logError(
        'Failed to send incident notification',
        error: e,
      );
    }
  }

  /// Start incident monitoring
  void _startIncidentMonitoring() {
    Timer.periodic(const Duration(minutes: 30), (_) async {
      await _checkIncidentTimeouts();
    });
  }

  /// Check for incident timeouts
  Future<void> _checkIncidentTimeouts() async {
    final now = DateTime.now();
    final timeoutThreshold = now.subtract(incidentTimeout);

    final timedOutIncidents = _activeIncidents.values
        .where(
          (incident) =>
              incident.status == IncidentStatus.open &&
              incident.createdAt.isBefore(timeoutThreshold),
        )
        .toList();

    for (final incident in timedOutIncidents) {
      await updateIncidentStatus(incident.id, IncidentStatus.escalated);

      // Send escalation notification
      await _notificationService?.sendNotificationToAdmins(
        title: 'Incident Escalated',
        body: 'Incident ${incident.id} has been escalated due to timeout',
        data: {
          'type': 'incident_escalated',
          'incident_id': incident.id,
          'timeout_hours': incidentTimeout.inHours.toString(),
        },
      );
    }
  }

  /// Get priority breakdown
  Map<String, int> _getPriorityBreakdown(List<Incident> incidents) {
    final breakdown = <String, int>{};
    for (final incident in incidents) {
      breakdown[incident.priority.name] =
          (breakdown[incident.priority.name] ?? 0) + 1;
    }
    return breakdown;
  }

  /// Get status breakdown
  Map<String, int> _getStatusBreakdown(List<Incident> incidents) {
    final breakdown = <String, int>{};
    for (final incident in incidents) {
      breakdown[incident.status.name] =
          (breakdown[incident.status.name] ?? 0) + 1;
    }
    return breakdown;
  }

  /// Get average resolution time
  double _getAverageResolutionTime() {
    final resolvedIncidents = _incidentHistory
        .where((incident) => incident.resolvedAt != null)
        .toList();

    if (resolvedIncidents.isEmpty) return 0.0;

    final totalResolutionTime = resolvedIncidents
        .map(
          (incident) =>
              incident.resolvedAt!.difference(incident.createdAt).inMinutes,
        )
        .reduce((a, b) => a + b);

    return totalResolutionTime / resolvedIncidents.length;
  }
}

/// Incident model
class Incident {
  final String id;
  final String title;
  final String description;
  final IncidentPriority priority;
  final IncidentStatus status;
  final ErrorIncident errorIncident;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? resolvedAt;

  Incident({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    required this.errorIncident,
    required this.createdAt,
    required this.updatedAt,
    this.resolvedAt,
  });

  Incident copyWith({
    String? title,
    String? description,
    IncidentPriority? priority,
    IncidentStatus? status,
    DateTime? updatedAt,
    DateTime? resolvedAt,
  }) {
    return Incident(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      errorIncident: errorIncident,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }
}

/// Incident priority levels
enum IncidentPriority { low, medium, high, critical }

/// Incident status
enum IncidentStatus { open, inProgress, escalated, resolved, closed }
