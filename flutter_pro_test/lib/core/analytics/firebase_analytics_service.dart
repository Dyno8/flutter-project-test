import 'dart:async';
import 'dart:io';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';
import '../config/environment_config.dart';
import '../monitoring/monitoring_service.dart';

/// Comprehensive Firebase Analytics service for CareNow MVP
/// Integrates Analytics, Crashlytics, and Performance Monitoring
class FirebaseAnalyticsService {
  static final FirebaseAnalyticsService _instance =
      FirebaseAnalyticsService._internal();
  factory FirebaseAnalyticsService() => _instance;
  FirebaseAnalyticsService._internal();

  // Firebase services
  late final FirebaseAnalytics _analytics;
  late final FirebaseCrashlytics _crashlytics;
  late final FirebasePerformance _performance;

  // Integration services
  final MonitoringService _monitoringService = MonitoringService();

  // State management
  bool _isInitialized = false;
  final Map<String, Trace> _activeTraces = {};
  final Map<String, HttpMetric> _activeHttpMetrics = {};

  // Configuration
  static const String _userIdKey = 'user_id';
  static const String _userTypeKey = 'user_type';
  static const String _appVersionKey = 'app_version';
  static const String _environmentKey = 'environment';

  /// Initialize Firebase Analytics services
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize Firebase services
      _analytics = FirebaseAnalytics.instance;
      _crashlytics = FirebaseCrashlytics.instance;
      _performance = FirebasePerformance.instance;

      // Configure based on environment
      await _configureForEnvironment();

      // Set up crash reporting
      await _setupCrashReporting();

      // Set up performance monitoring
      await _setupPerformanceMonitoring();

      // Set default user properties
      await _setDefaultUserProperties();

      _isInitialized = true;

      // Log successful initialization
      await logEvent(
        'analytics_service_initialized',
        parameters: {
          'environment': EnvironmentConfig.environment,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      if (EnvironmentConfig.isDebug) {
        print('📊 Firebase Analytics Service initialized successfully');
      }
    } catch (e, stackTrace) {
      _monitoringService.logError(
        'Failed to initialize Firebase Analytics Service',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Configure services based on environment
  Future<void> _configureForEnvironment() async {
    final isProduction = EnvironmentConfig.isProduction;

    // Configure analytics collection
    await _analytics.setAnalyticsCollectionEnabled(
      EnvironmentConfig.performanceConfig.analyticsEnabled,
    );

    // Configure crashlytics collection
    await _crashlytics.setCrashlyticsCollectionEnabled(
      EnvironmentConfig.performanceConfig.crashReportingEnabled,
    );

    // Configure performance monitoring
    await _performance.setPerformanceCollectionEnabled(
      EnvironmentConfig.performanceConfig.performanceMonitoringEnabled,
    );

    // Set debug mode for non-production environments
    if (!isProduction) {
      await _analytics.setSessionTimeoutDuration(const Duration(minutes: 30));
    }
  }

  /// Setup crash reporting with custom handlers
  Future<void> _setupCrashReporting() async {
    // Set up Flutter error handling
    FlutterError.onError = (FlutterErrorDetails details) {
      _crashlytics.recordFlutterFatalError(details);
      _monitoringService.logError(
        'Flutter Fatal Error',
        error: details.exception,
        stackTrace: details.stack,
        metadata: {
          'library': details.library,
          'context': details.context?.toString(),
        },
      );
    };

    // Set up platform error handling
    PlatformDispatcher.instance.onError = (error, stack) {
      _crashlytics.recordError(error, stack, fatal: true);
      _monitoringService.logError(
        'Platform Error',
        error: error,
        stackTrace: stack,
      );
      return true;
    };

    // Set custom keys for better crash analysis
    await _crashlytics.setCustomKey(
      'environment',
      EnvironmentConfig.environment,
    );
    await _crashlytics.setCustomKey(
      'app_version',
      EnvironmentConfig.appVersion,
    );
    await _crashlytics.setCustomKey('platform', Platform.operatingSystem);
  }

  /// Setup performance monitoring
  Future<void> _setupPerformanceMonitoring() async {
    // Enable automatic HTTP/HTTPS network request monitoring
    // This is handled automatically by Firebase Performance

    if (EnvironmentConfig.isDebug) {
      print('🚀 Performance monitoring enabled');
    }
  }

  /// Set default user properties
  Future<void> _setDefaultUserProperties() async {
    await _analytics.setUserProperty(
      name: _environmentKey,
      value: EnvironmentConfig.environment,
    );

    await _analytics.setUserProperty(
      name: _appVersionKey,
      value: EnvironmentConfig.appVersion,
    );
  }

  /// Set user ID for analytics
  Future<void> setUserId(String userId) async {
    if (!_isInitialized) await initialize();

    try {
      await _analytics.setUserId(id: userId);
      await _crashlytics.setUserIdentifier(userId);

      await _analytics.setUserProperty(name: _userIdKey, value: userId);
    } catch (e, stackTrace) {
      _monitoringService.logError(
        'Failed to set user ID',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Set user type (client, partner, admin)
  Future<void> setUserType(String userType) async {
    if (!_isInitialized) await initialize();

    try {
      await _analytics.setUserProperty(name: _userTypeKey, value: userType);

      await _crashlytics.setCustomKey('user_type', userType);
    } catch (e, stackTrace) {
      _monitoringService.logError(
        'Failed to set user type',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Log custom analytics event
  Future<void> logEvent(
    String eventName, {
    Map<String, Object?>? parameters,
  }) async {
    if (!_isInitialized) await initialize();

    try {
      // Add default parameters and convert to correct type
      final enrichedParameters = <String, Object>{
        'timestamp': DateTime.now().toIso8601String(),
        'environment': EnvironmentConfig.environment,
      };

      // Add user parameters, filtering out null values
      if (parameters != null) {
        for (final entry in parameters.entries) {
          if (entry.value != null) {
            enrichedParameters[entry.key] = entry.value!;
          }
        }
      }

      await _analytics.logEvent(
        name: eventName,
        parameters: enrichedParameters,
      );

      // Also log to monitoring service for debugging
      _monitoringService.logInfo(
        'Analytics event: $eventName',
        metadata: enrichedParameters,
      );
    } catch (e, stackTrace) {
      _monitoringService.logError(
        'Failed to log analytics event: $eventName',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Log screen view
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
    Map<String, Object?>? parameters,
  }) async {
    if (!_isInitialized) await initialize();

    try {
      // Convert parameters to the correct type
      final convertedParameters = parameters?.map(
        (key, value) => MapEntry(key, value as Object),
      );

      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass,
        parameters: convertedParameters,
      );
    } catch (e, stackTrace) {
      _monitoringService.logError(
        'Failed to log screen view: $screenName',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Record non-fatal error
  Future<void> recordError(
    dynamic error,
    StackTrace? stackTrace, {
    Map<String, dynamic>? metadata,
    bool fatal = false,
  }) async {
    if (!_isInitialized) await initialize();

    try {
      await _crashlytics.recordError(
        error,
        stackTrace,
        fatal: fatal,
        information:
            metadata?.entries.map((e) => '${e.key}: ${e.value}').toList() ?? [],
      );
    } catch (e, stackTrace) {
      _monitoringService.logError(
        'Failed to record error to Crashlytics',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Start performance trace
  Future<Trace?> startTrace(String traceName) async {
    if (!_isInitialized) await initialize();

    try {
      final trace = _performance.newTrace(traceName);
      await trace.start();
      _activeTraces[traceName] = trace;
      return trace;
    } catch (e, stackTrace) {
      _monitoringService.logError(
        'Failed to start trace: $traceName',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Stop performance trace
  Future<void> stopTrace(String traceName) async {
    try {
      final trace = _activeTraces.remove(traceName);
      if (trace != null) {
        await trace.stop();
      }
    } catch (e, stackTrace) {
      _monitoringService.logError(
        'Failed to stop trace: $traceName',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Add attribute to active trace
  Future<void> setTraceAttribute(
    String traceName,
    String attribute,
    String value,
  ) async {
    try {
      final trace = _activeTraces[traceName];
      if (trace != null) {
        trace.setMetric(attribute, int.tryParse(value) ?? 0);
      }
    } catch (e, stackTrace) {
      _monitoringService.logError(
        'Failed to set trace attribute: $traceName.$attribute',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Start HTTP metric tracking
  Future<HttpMetric?> startHttpMetric(String url, HttpMethod httpMethod) async {
    if (!_isInitialized) await initialize();

    try {
      final metric = _performance.newHttpMetric(url, httpMethod);
      await metric.start();
      _activeHttpMetrics[url] = metric;
      return metric;
    } catch (e, stackTrace) {
      _monitoringService.logError(
        'Failed to start HTTP metric: $url',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Stop HTTP metric tracking
  Future<void> stopHttpMetric(
    String url, {
    int? responseCode,
    int? requestPayloadSize,
    int? responsePayloadSize,
  }) async {
    try {
      final metric = _activeHttpMetrics.remove(url);
      if (metric != null) {
        if (responseCode != null) {
          metric.httpResponseCode = responseCode;
        }
        if (requestPayloadSize != null) {
          metric.requestPayloadSize = requestPayloadSize;
        }
        if (responsePayloadSize != null) {
          metric.responsePayloadSize = responsePayloadSize;
        }
        await metric.stop();
      }
    } catch (e, stackTrace) {
      _monitoringService.logError(
        'Failed to stop HTTP metric: $url',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Get Firebase Analytics instance for advanced usage
  FirebaseAnalytics get analytics => _analytics;

  /// Get Firebase Crashlytics instance for advanced usage
  FirebaseCrashlytics get crashlytics => _crashlytics;

  /// Get Firebase Performance instance for advanced usage
  FirebasePerformance get performance => _performance;

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;

  /// Dispose resources
  Future<void> dispose() async {
    // Stop all active traces
    for (final trace in _activeTraces.values) {
      try {
        await trace.stop();
      } catch (e) {
        // Ignore errors during cleanup
      }
    }
    _activeTraces.clear();

    // Stop all active HTTP metrics
    for (final metric in _activeHttpMetrics.values) {
      try {
        await metric.stop();
      } catch (e) {
        // Ignore errors during cleanup
      }
    }
    _activeHttpMetrics.clear();

    _isInitialized = false;
  }
}
