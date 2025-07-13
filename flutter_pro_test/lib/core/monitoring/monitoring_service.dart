import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../errors/exceptions.dart';
import '../analytics/firebase_analytics_service.dart';
import '../analytics/analytics_events.dart';
import '../config/environment_config.dart';

/// Comprehensive monitoring and logging service with Firebase integration
class MonitoringService {
  static final MonitoringService _instance = MonitoringService._internal();
  factory MonitoringService() => _instance;
  MonitoringService._internal();

  SharedPreferences? _prefs;
  final List<LogEntry> _logBuffer = [];
  final Map<String, int> _errorCounts = {};
  final Map<String, DateTime> _lastErrorTimes = {};
  Timer? _healthCheckTimer;
  Timer? _logFlushTimer;

  // Firebase Analytics integration
  FirebaseAnalyticsService? _analyticsService;
  bool _analyticsEnabled = false;

  // Configuration
  static const int maxLogBufferSize = 500;
  static const int healthCheckIntervalSeconds = 30;
  static const int logFlushIntervalSeconds = 60;
  static const int maxErrorsPerMinute = 10;

  /// Initialize monitoring service with Firebase Analytics integration
  Future<void> initialize({FirebaseAnalyticsService? analyticsService}) async {
    _prefs = await SharedPreferences.getInstance();

    // Initialize Firebase Analytics integration
    if (analyticsService != null) {
      _analyticsService = analyticsService;
      _analyticsEnabled = EnvironmentConfig.analyticsConfig.analyticsEnabled;

      if (_analyticsEnabled) {
        await _setupAnalyticsIntegration();
      }
    }

    _startHealthChecks();
    _startLogFlushing();

    // Log service initialization
    logInfo(
      'MonitoringService initialized with Firebase Analytics integration',
    );

    // Track initialization event
    if (_analyticsEnabled) {
      await _trackAnalyticsEvent(AnalyticsEvents.appOpened, {
        AnalyticsParameters.timestamp: DateTime.now().toIso8601String(),
        AnalyticsParameters.environment: EnvironmentConfig.environment,
      });
    }
  }

  /// Start periodic health checks
  void _startHealthChecks() {
    _healthCheckTimer?.cancel();
    _healthCheckTimer = Timer.periodic(
      const Duration(seconds: healthCheckIntervalSeconds),
      (_) => _performHealthCheck(),
    );
  }

  /// Start periodic log flushing
  void _startLogFlushing() {
    _logFlushTimer?.cancel();
    _logFlushTimer = Timer.periodic(
      const Duration(seconds: logFlushIntervalSeconds),
      (_) => _flushLogs(),
    );
  }

  /// Perform system health check
  void _performHealthCheck() {
    final healthStatus = _checkSystemHealth();

    if (healthStatus['status'] == 'healthy') {
      logDebug('System health check passed', metadata: healthStatus);
    } else {
      logWarning('System health check failed', metadata: healthStatus);
    }
  }

  /// Check system health
  Map<String, dynamic> _checkSystemHealth() {
    final status = <String, dynamic>{
      'timestamp': DateTime.now().toIso8601String(),
      'status': 'healthy',
      'checks': <String, dynamic>{},
    };

    // Memory check
    try {
      final memoryInfo = _getMemoryInfo();
      status['checks']['memory'] = memoryInfo;

      if (memoryInfo['usage_mb'] > 500) {
        // 500MB threshold
        status['status'] = 'warning';
        status['checks']['memory']['warning'] = 'High memory usage detected';
      }
    } catch (e) {
      status['checks']['memory'] = {'error': e.toString()};
      status['status'] = 'error';
    }

    // Error rate check
    try {
      final errorRate = _getRecentErrorRate();
      status['checks']['error_rate'] = {'errors_per_minute': errorRate};

      if (errorRate > maxErrorsPerMinute) {
        status['status'] = 'error';
        status['checks']['error_rate']['error'] = 'High error rate detected';
      }
    } catch (e) {
      status['checks']['error_rate'] = {'error': e.toString()};
      status['status'] = 'error';
    }

    // Storage check
    try {
      final storageInfo = _getStorageInfo();
      status['checks']['storage'] = storageInfo;
    } catch (e) {
      status['checks']['storage'] = {'error': e.toString()};
    }

    return status;
  }

  /// Get memory information
  Map<String, dynamic> _getMemoryInfo() {
    // Simplified memory info - in production, use proper memory monitoring
    return {
      'usage_mb': _logBuffer.length * 0.5, // Rough estimate
      'buffer_size': _logBuffer.length,
      'max_buffer_size': maxLogBufferSize,
    };
  }

  /// Get recent error rate
  double _getRecentErrorRate() {
    final now = DateTime.now();
    final oneMinuteAgo = now.subtract(const Duration(minutes: 1));

    int recentErrors = 0;
    for (final entry in _lastErrorTimes.entries) {
      if (entry.value.isAfter(oneMinuteAgo)) {
        recentErrors += _errorCounts[entry.key] ?? 0;
      }
    }

    return recentErrors.toDouble();
  }

  /// Get storage information
  Map<String, dynamic> _getStorageInfo() {
    return {
      'log_entries': _logBuffer.length,
      'error_counts': _errorCounts.length,
      'preferences_keys': _prefs?.getKeys().length ?? 0,
    };
  }

  /// Log debug message
  void logDebug(String message, {Map<String, dynamic>? metadata}) {
    _addLogEntry(LogLevel.debug, message, metadata: metadata);
  }

  /// Log info message
  void logInfo(String message, {Map<String, dynamic>? metadata}) {
    _addLogEntry(LogLevel.info, message, metadata: metadata);
  }

  /// Log warning message
  void logWarning(String message, {Map<String, dynamic>? metadata}) {
    _addLogEntry(LogLevel.warning, message, metadata: metadata);
  }

  /// Log error message
  void logError(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) {
    final errorMetadata = <String, dynamic>{
      ...?metadata,
      if (error != null) 'error': error.toString(),
      if (stackTrace != null) 'stack_trace': stackTrace.toString(),
    };

    _addLogEntry(LogLevel.error, message, metadata: errorMetadata);
    _recordError(message);
  }

  /// Log critical error
  void logCritical(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) {
    final errorMetadata = <String, dynamic>{
      ...?metadata,
      if (error != null) 'error': error.toString(),
      if (stackTrace != null) 'stack_trace': stackTrace.toString(),
    };

    _addLogEntry(LogLevel.critical, message, metadata: errorMetadata);
    _recordError(message);

    // Critical errors should be handled immediately
    _flushLogs();
  }

  /// Add log entry to buffer
  void _addLogEntry(
    LogLevel level,
    String message, {
    Map<String, dynamic>? metadata,
  }) {
    final entry = LogEntry(
      level: level,
      message: message,
      timestamp: DateTime.now(),
      metadata: metadata ?? {},
    );

    _logBuffer.add(entry);

    // Keep buffer size manageable
    while (_logBuffer.length > maxLogBufferSize) {
      _logBuffer.removeAt(0);
    }

    // Print to console in debug mode
    if (kDebugMode) {
      final levelIcon = _getLevelIcon(level);
      print('$levelIcon [${level.name.toUpperCase()}] $message');
      if (metadata != null && metadata.isNotEmpty) {
        print('   Metadata: ${jsonEncode(metadata)}');
      }
    }
  }

  /// Get icon for log level
  String _getLevelIcon(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '🐛';
      case LogLevel.info:
        return 'ℹ️';
      case LogLevel.warning:
        return '⚠️';
      case LogLevel.error:
        return '❌';
      case LogLevel.critical:
        return '🚨';
    }
  }

  /// Record error for rate limiting
  void _recordError(String message) {
    final now = DateTime.now();
    _errorCounts[message] = (_errorCounts[message] ?? 0) + 1;
    _lastErrorTimes[message] = now;
  }

  /// Flush logs to persistent storage
  void _flushLogs() {
    if (_logBuffer.isEmpty) return;

    try {
      final logsJson = _logBuffer.map((entry) => entry.toJson()).toList();
      final existingLogsJson = _prefs?.getString('monitoring_logs');

      List<dynamic> allLogs = [];
      if (existingLogsJson != null) {
        try {
          allLogs = jsonDecode(existingLogsJson) as List;
        } catch (e) {
          logWarning('Failed to parse existing logs: $e');
        }
      }

      allLogs.addAll(logsJson);

      // Keep only recent logs (last 1000)
      if (allLogs.length > 1000) {
        allLogs = allLogs.sublist(allLogs.length - 1000);
      }

      _prefs?.setString('monitoring_logs', jsonEncode(allLogs));
      _logBuffer.clear();

      if (kDebugMode) {
        print('📝 Flushed ${logsJson.length} log entries');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to flush logs: $e');
      }
    }
  }

  /// Get recent logs
  List<LogEntry> getRecentLogs({int limit = 100, LogLevel? minLevel}) {
    var logs = _logBuffer.toList();

    if (minLevel != null) {
      logs = logs.where((log) => log.level.index >= minLevel.index).toList();
    }

    logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return logs.take(limit).toList();
  }

  /// Get error statistics
  Map<String, dynamic> getErrorStats() {
    final now = DateTime.now();
    final oneHourAgo = now.subtract(const Duration(hours: 1));

    int recentErrors = 0;
    for (final entry in _lastErrorTimes.entries) {
      if (entry.value.isAfter(oneHourAgo)) {
        recentErrors += _errorCounts[entry.key] ?? 0;
      }
    }

    return {
      'total_errors': _errorCounts.values.fold(0, (sum, count) => sum + count),
      'recent_errors_1h': recentErrors,
      'unique_errors': _errorCounts.length,
      'error_rate_per_minute': _getRecentErrorRate(),
    };
  }

  /// Get system health status
  Map<String, dynamic> getHealthStatus() {
    return _checkSystemHealth();
  }

  /// Clear all logs and reset counters
  void clearLogs() {
    _logBuffer.clear();
    _errorCounts.clear();
    _lastErrorTimes.clear();
    _prefs?.remove('monitoring_logs');
    logInfo('All logs cleared');
  }

  /// Setup Firebase Analytics integration
  Future<void> _setupAnalyticsIntegration() async {
    try {
      if (_analyticsService != null && !_analyticsService!.isInitialized) {
        await _analyticsService!.initialize();
      }

      // Set up custom error tracking
      _setupCustomErrorTracking();

      if (kDebugMode) {
        print('📊 Firebase Analytics integration setup completed');
      }
    } catch (e) {
      logError('Failed to setup Firebase Analytics integration', error: e);
    }
  }

  /// Setup custom error tracking with Firebase
  void _setupCustomErrorTracking() {
    // This method can be extended to set up custom error tracking patterns
    if (kDebugMode) {
      print('🔍 Custom error tracking setup completed');
    }
  }

  /// Track analytics event
  Future<void> _trackAnalyticsEvent(
    String eventName,
    Map<String, Object?> parameters,
  ) async {
    if (!_analyticsEnabled || _analyticsService == null) return;

    try {
      await _analyticsService!.logEvent(eventName, parameters: parameters);
    } catch (e) {
      logError('Failed to track analytics event: $eventName', error: e);
    }
  }

  /// Track performance metrics to Firebase
  Future<void> trackPerformanceMetric({
    required String metricName,
    required Duration duration,
    Map<String, Object?>? additionalData,
  }) async {
    if (!_analyticsEnabled || _analyticsService == null) return;

    try {
      final parameters = <String, Object?>{
        AnalyticsParameters.loadTime: duration.inMilliseconds,
        AnalyticsParameters.timestamp: DateTime.now().toIso8601String(),
        ...?additionalData,
      };

      await _analyticsService!.logEvent(
        AnalyticsEvents.screenLoadTime,
        parameters: parameters,
      );

      logInfo(
        'Performance metric tracked: $metricName (${duration.inMilliseconds}ms)',
      );
    } catch (e) {
      logError('Failed to track performance metric: $metricName', error: e);
    }
  }

  /// Track error to Firebase Crashlytics
  Future<void> trackError({
    required String errorType,
    required dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
    bool fatal = false,
  }) async {
    if (!_analyticsEnabled || _analyticsService == null) return;

    try {
      // Record error to Crashlytics
      await _analyticsService!.recordError(
        error,
        stackTrace,
        metadata: metadata,
        fatal: fatal,
      );

      // Track error event to Analytics
      await _analyticsService!.logEvent(
        AnalyticsEvents.errorOccurred,
        parameters: {
          AnalyticsParameters.errorType: errorType,
          AnalyticsParameters.errorMessage: error.toString(),
          AnalyticsParameters.timestamp: DateTime.now().toIso8601String(),
          if (metadata != null)
            ...metadata.map((k, v) => MapEntry(k, v.toString())),
        },
      );

      logError(
        'Error tracked to Firebase: $errorType',
        error: error,
        stackTrace: stackTrace,
      );
    } catch (e) {
      logError('Failed to track error to Firebase: $errorType', error: e);
    }
  }

  /// Track user action
  Future<void> trackUserAction({
    required String actionName,
    String? screenName,
    Map<String, Object?>? parameters,
  }) async {
    if (!_analyticsEnabled || _analyticsService == null) return;

    try {
      final eventParameters = <String, Object?>{
        AnalyticsParameters.actionType: actionName,
        AnalyticsParameters.timestamp: DateTime.now().toIso8601String(),
        if (screenName != null) AnalyticsParameters.screenName: screenName,
        ...?parameters,
      };

      await _analyticsService!.logEvent(
        AnalyticsEvents.featureUsed,
        parameters: eventParameters,
      );

      logInfo('User action tracked: $actionName');
    } catch (e) {
      logError('Failed to track user action: $actionName', error: e);
    }
  }

  /// Track screen view
  Future<void> trackScreenView({
    required String screenName,
    String? screenClass,
    Map<String, Object?>? parameters,
  }) async {
    if (!_analyticsEnabled || _analyticsService == null) return;

    try {
      await _analyticsService!.logScreenView(
        screenName: screenName,
        screenClass: screenClass,
        parameters: parameters,
      );

      logInfo('Screen view tracked: $screenName');
    } catch (e) {
      logError('Failed to track screen view: $screenName', error: e);
    }
  }

  /// Get analytics service instance
  FirebaseAnalyticsService? get analyticsService => _analyticsService;

  /// Check if analytics is enabled
  bool get isAnalyticsEnabled => _analyticsEnabled;

  /// Dispose resources
  void dispose() {
    _healthCheckTimer?.cancel();
    _logFlushTimer?.cancel();
    _flushLogs();
  }
}

/// Log levels
enum LogLevel { debug, info, warning, error, critical }

/// Log entry data class
class LogEntry {
  final LogLevel level;
  final String message;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  const LogEntry({
    required this.level,
    required this.message,
    required this.timestamp,
    required this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'level': level.name,
    'message': message,
    'timestamp': timestamp.toIso8601String(),
    'metadata': metadata,
  };
}
