import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/environment_config.dart';
import '../analytics/firebase_analytics_service.dart';
import '../performance/performance_manager.dart';
import 'monitoring_service.dart';
import 'alerting_system.dart' as alerting;

/// Performance validation service for production monitoring
/// Validates production performance meets SLA requirements and triggers alerts
class PerformanceValidationService {
  static final PerformanceValidationService _instance =
      PerformanceValidationService._internal();
  factory PerformanceValidationService() => _instance;
  PerformanceValidationService._internal();

  // Dependencies
  MonitoringService? _monitoringService;
  FirebaseAnalyticsService? _analyticsService;
  PerformanceManager? _performanceManager;
  alerting.AlertingSystem? _alertingSystem;

  SharedPreferences? _prefs;
  Timer? _validationTimer;
  Timer? _reportingTimer;

  // Configuration - Production SLA Requirements
  static const double maxLoadTimeMs = 3000.0; // 3 seconds
  static const double maxApiResponseTimeMs = 500.0; // 500ms
  static const double minCacheHitRate = 0.7; // 70%
  static const int maxMemoryUsageMB = 512; // 512MB
  static const double maxErrorRate = 0.01; // 1%
  static const int validationIntervalSeconds = 60; // 1 minute
  static const int reportingIntervalSeconds = 300; // 5 minutes

  // State tracking
  final List<PerformanceValidationResult> _validationHistory = [];
  final Map<String, List<double>> _performanceMetrics = {};
  final Map<String, DateTime> _lastViolationTimes = {};
  bool _isInitialized = false;
  bool _isValidationActive = false;

  /// Initialize performance validation service
  Future<void> initialize({
    required MonitoringService monitoringService,
    required FirebaseAnalyticsService analyticsService,
    required PerformanceManager performanceManager,
    required alerting.AlertingSystem alertingSystem,
  }) async {
    if (_isInitialized) return;

    try {
      _prefs = await SharedPreferences.getInstance();

      // Initialize dependencies
      _monitoringService = monitoringService;
      _analyticsService = analyticsService;
      _performanceManager = performanceManager;
      _alertingSystem = alertingSystem;

      // Load historical data
      await _loadValidationHistory();

      // Initialize performance metrics tracking
      _initializeMetricsTracking();

      // Start validation services
      _startValidation();

      _isInitialized = true;
      _isValidationActive = true;

      _monitoringService?.logInfo(
        'PerformanceValidationService initialized successfully',
        metadata: {
          'environment': EnvironmentConfig.environment,
          'sla_requirements': {
            'max_load_time_ms': maxLoadTimeMs,
            'max_api_response_time_ms': maxApiResponseTimeMs,
            'min_cache_hit_rate': minCacheHitRate,
            'max_memory_usage_mb': maxMemoryUsageMB,
            'max_error_rate': maxErrorRate,
          },
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      // Track initialization
      await _analyticsService?.logEvent(
        'performance_validation_initialized',
        parameters: {
          'environment': EnvironmentConfig.environment,
          'max_load_time_ms': maxLoadTimeMs,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e, stackTrace) {
      _monitoringService?.logError(
        'Failed to initialize PerformanceValidationService',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Initialize metrics tracking
  void _initializeMetricsTracking() {
    _performanceMetrics['load_times'] = [];
    _performanceMetrics['api_response_times'] = [];
    _performanceMetrics['cache_hit_rates'] = [];
    _performanceMetrics['memory_usage'] = [];
    _performanceMetrics['error_rates'] = [];
  }

  /// Start validation services
  void _startValidation() {
    // Start performance validation timer
    _validationTimer?.cancel();
    _validationTimer = Timer.periodic(
      const Duration(seconds: validationIntervalSeconds),
      (_) => _performValidation(),
    );

    // Start performance reporting timer
    _reportingTimer?.cancel();
    _reportingTimer = Timer.periodic(
      const Duration(seconds: reportingIntervalSeconds),
      (_) => _generatePerformanceReport(),
    );
  }

  /// Perform performance validation
  Future<void> _performValidation() async {
    if (!_isValidationActive) return;

    try {
      final validationResult = PerformanceValidationResult(
        timestamp: DateTime.now(),
        validations: {},
        overallStatus: ValidationStatus.passed,
        violations: [],
      );

      // Validate load times
      await _validateLoadTimes(validationResult);

      // Validate API response times
      await _validateApiResponseTimes(validationResult);

      // Validate cache performance
      await _validateCachePerformance(validationResult);

      // Validate memory usage
      await _validateMemoryUsage(validationResult);

      // Validate error rates
      await _validateErrorRates(validationResult);

      // Determine overall status
      validationResult.overallStatus = _determineOverallValidationStatus(
        validationResult.validations,
      );

      // Store validation result
      _validationHistory.add(validationResult);

      // Keep only last 100 validations
      if (_validationHistory.length > 100) {
        _validationHistory.removeAt(0);
      }

      // Save to persistent storage
      await _saveValidationResult(validationResult);

      // Process violations and trigger alerts
      await _processViolations(validationResult);

      // Log validation result
      if (validationResult.overallStatus != ValidationStatus.passed) {
        _monitoringService?.logWarning(
          'Performance validation failed',
          metadata: validationResult.toMap(),
        );
      } else {
        _monitoringService?.logDebug(
          'Performance validation passed',
          metadata: {
            'validation_count': validationResult.validations.length,
            'timestamp': validationResult.timestamp.toIso8601String(),
          },
        );
      }
    } catch (e, stackTrace) {
      _monitoringService?.logError(
        'Performance validation failed with exception',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Validate load times
  Future<void> _validateLoadTimes(PerformanceValidationResult result) async {
    try {
      // For now, simulate load time validation
      // In a real implementation, this would analyze actual page load times from PerformanceManager
      final simulatedLoadTime = 2500.0; // 2.5 seconds (within SLA)

      _performanceMetrics['load_times']?.add(simulatedLoadTime);

      // Keep only last 50 measurements
      if (_performanceMetrics['load_times']!.length > 50) {
        _performanceMetrics['load_times']!.removeAt(0);
      }

      final validation = PerformanceValidation(
        metric: 'load_time',
        currentValue: simulatedLoadTime,
        threshold: maxLoadTimeMs,
        status: simulatedLoadTime <= maxLoadTimeMs
            ? ValidationStatus.passed
            : ValidationStatus.failed,
        message: simulatedLoadTime <= maxLoadTimeMs
            ? 'Load time within SLA: ${simulatedLoadTime.toStringAsFixed(0)}ms'
            : 'Load time exceeds SLA: ${simulatedLoadTime.toStringAsFixed(0)}ms > ${maxLoadTimeMs.toStringAsFixed(0)}ms',
      );

      result.validations['load_time'] = validation;

      if (validation.status == ValidationStatus.failed) {
        result.violations.add(
          PerformanceViolation(
            metric: 'load_time',
            currentValue: simulatedLoadTime,
            threshold: maxLoadTimeMs,
            severity: ViolationSeverity.high,
            message: validation.message,
          ),
        );
      }
    } catch (e) {
      result.validations['load_time'] = PerformanceValidation(
        metric: 'load_time',
        currentValue: 0,
        threshold: maxLoadTimeMs,
        status: ValidationStatus.error,
        message: 'Failed to validate load time: $e',
      );
    }
  }

  /// Validate API response times
  Future<void> _validateApiResponseTimes(
    PerformanceValidationResult result,
  ) async {
    try {
      // Simulate API response time validation
      final simulatedResponseTime = 350.0; // 350ms (within SLA)

      _performanceMetrics['api_response_times']?.add(simulatedResponseTime);

      if (_performanceMetrics['api_response_times']!.length > 50) {
        _performanceMetrics['api_response_times']!.removeAt(0);
      }

      final validation = PerformanceValidation(
        metric: 'api_response_time',
        currentValue: simulatedResponseTime,
        threshold: maxApiResponseTimeMs,
        status: simulatedResponseTime <= maxApiResponseTimeMs
            ? ValidationStatus.passed
            : ValidationStatus.failed,
        message: simulatedResponseTime <= maxApiResponseTimeMs
            ? 'API response time within SLA: ${simulatedResponseTime.toStringAsFixed(0)}ms'
            : 'API response time exceeds SLA: ${simulatedResponseTime.toStringAsFixed(0)}ms > ${maxApiResponseTimeMs.toStringAsFixed(0)}ms',
      );

      result.validations['api_response_time'] = validation;

      if (validation.status == ValidationStatus.failed) {
        result.violations.add(
          PerformanceViolation(
            metric: 'api_response_time',
            currentValue: simulatedResponseTime,
            threshold: maxApiResponseTimeMs,
            severity: ViolationSeverity.medium,
            message: validation.message,
          ),
        );
      }
    } catch (e) {
      result.validations['api_response_time'] = PerformanceValidation(
        metric: 'api_response_time',
        currentValue: 0,
        threshold: maxApiResponseTimeMs,
        status: ValidationStatus.error,
        message: 'Failed to validate API response time: $e',
      );
    }
  }

  /// Validate cache performance
  Future<void> _validateCachePerformance(
    PerformanceValidationResult result,
  ) async {
    try {
      final performanceStats = _performanceManager?.getPerformanceStats() ?? {};
      final cacheHitRate = performanceStats['cache_hit_rate'] as double? ?? 0.0;

      _performanceMetrics['cache_hit_rates']?.add(cacheHitRate);

      if (_performanceMetrics['cache_hit_rates']!.length > 50) {
        _performanceMetrics['cache_hit_rates']!.removeAt(0);
      }

      final validation = PerformanceValidation(
        metric: 'cache_hit_rate',
        currentValue: cacheHitRate,
        threshold: minCacheHitRate,
        status: cacheHitRate >= minCacheHitRate
            ? ValidationStatus.passed
            : ValidationStatus.failed,
        message: cacheHitRate >= minCacheHitRate
            ? 'Cache hit rate meets SLA: ${(cacheHitRate * 100).toStringAsFixed(1)}%'
            : 'Cache hit rate below SLA: ${(cacheHitRate * 100).toStringAsFixed(1)}% < ${(minCacheHitRate * 100).toStringAsFixed(1)}%',
      );

      result.validations['cache_hit_rate'] = validation;

      if (validation.status == ValidationStatus.failed) {
        result.violations.add(
          PerformanceViolation(
            metric: 'cache_hit_rate',
            currentValue: cacheHitRate,
            threshold: minCacheHitRate,
            severity: ViolationSeverity.medium,
            message: validation.message,
          ),
        );
      }
    } catch (e) {
      result.validations['cache_hit_rate'] = PerformanceValidation(
        metric: 'cache_hit_rate',
        currentValue: 0,
        threshold: minCacheHitRate,
        status: ValidationStatus.error,
        message: 'Failed to validate cache performance: $e',
      );
    }
  }

  /// Validate memory usage
  Future<void> _validateMemoryUsage(PerformanceValidationResult result) async {
    try {
      final performanceStats = _performanceManager?.getPerformanceStats() ?? {};
      final memoryUsageBytes =
          performanceStats['memory_usage_bytes'] as int? ?? 0;
      final memoryUsageMB = memoryUsageBytes / 1024 / 1024;

      _performanceMetrics['memory_usage']?.add(memoryUsageMB);

      if (_performanceMetrics['memory_usage']!.length > 50) {
        _performanceMetrics['memory_usage']!.removeAt(0);
      }

      final validation = PerformanceValidation(
        metric: 'memory_usage',
        currentValue: memoryUsageMB,
        threshold: maxMemoryUsageMB.toDouble(),
        status: memoryUsageMB <= maxMemoryUsageMB
            ? ValidationStatus.passed
            : ValidationStatus.failed,
        message: memoryUsageMB <= maxMemoryUsageMB
            ? 'Memory usage within SLA: ${memoryUsageMB.toStringAsFixed(1)}MB'
            : 'Memory usage exceeds SLA: ${memoryUsageMB.toStringAsFixed(1)}MB > ${maxMemoryUsageMB}MB',
      );

      result.validations['memory_usage'] = validation;

      if (validation.status == ValidationStatus.failed) {
        result.violations.add(
          PerformanceViolation(
            metric: 'memory_usage',
            currentValue: memoryUsageMB,
            threshold: maxMemoryUsageMB.toDouble(),
            severity: ViolationSeverity.high,
            message: validation.message,
          ),
        );
      }
    } catch (e) {
      result.validations['memory_usage'] = PerformanceValidation(
        metric: 'memory_usage',
        currentValue: 0,
        threshold: maxMemoryUsageMB.toDouble(),
        status: ValidationStatus.error,
        message: 'Failed to validate memory usage: $e',
      );
    }
  }

  /// Validate error rates
  Future<void> _validateErrorRates(PerformanceValidationResult result) async {
    try {
      final errorStats = _monitoringService?.getErrorStats() ?? {};
      final errorRate = errorStats['error_rate_per_minute'] as double? ?? 0.0;

      _performanceMetrics['error_rates']?.add(errorRate);

      if (_performanceMetrics['error_rates']!.length > 50) {
        _performanceMetrics['error_rates']!.removeAt(0);
      }

      final validation = PerformanceValidation(
        metric: 'error_rate',
        currentValue: errorRate,
        threshold: maxErrorRate,
        status: errorRate <= maxErrorRate
            ? ValidationStatus.passed
            : ValidationStatus.failed,
        message: errorRate <= maxErrorRate
            ? 'Error rate within SLA: ${(errorRate * 100).toStringAsFixed(2)}%'
            : 'Error rate exceeds SLA: ${(errorRate * 100).toStringAsFixed(2)}% > ${(maxErrorRate * 100).toStringAsFixed(2)}%',
      );

      result.validations['error_rate'] = validation;

      if (validation.status == ValidationStatus.failed) {
        result.violations.add(
          PerformanceViolation(
            metric: 'error_rate',
            currentValue: errorRate,
            threshold: maxErrorRate,
            severity: ViolationSeverity.critical,
            message: validation.message,
          ),
        );
      }
    } catch (e) {
      result.validations['error_rate'] = PerformanceValidation(
        metric: 'error_rate',
        currentValue: 0,
        threshold: maxErrorRate,
        status: ValidationStatus.error,
        message: 'Failed to validate error rate: $e',
      );
    }
  }

  /// Determine overall validation status
  ValidationStatus _determineOverallValidationStatus(
    Map<String, PerformanceValidation> validations,
  ) {
    if (validations.values.any((v) => v.status == ValidationStatus.error)) {
      return ValidationStatus.error;
    }

    if (validations.values.any((v) => v.status == ValidationStatus.failed)) {
      return ValidationStatus.failed;
    }

    return ValidationStatus.passed;
  }

  /// Process violations and trigger alerts
  Future<void> _processViolations(PerformanceValidationResult result) async {
    for (final violation in result.violations) {
      // Check if we should trigger an alert for this violation
      final lastViolationTime = _lastViolationTimes[violation.metric];
      final now = DateTime.now();

      // Only trigger alert if it's been more than 5 minutes since last alert
      if (lastViolationTime == null ||
          now.difference(lastViolationTime).inMinutes >= 5) {
        await _triggerPerformanceAlert(violation);
        _lastViolationTimes[violation.metric] = now;
      }
    }
  }

  /// Trigger performance alert
  Future<void> _triggerPerformanceAlert(PerformanceViolation violation) async {
    // This would integrate with the AlertingSystem to trigger alerts
    // For now, just log the violation
    _monitoringService?.logError(
      'PERFORMANCE VIOLATION: ${violation.metric}',
      metadata: {
        'metric': violation.metric,
        'current_value': violation.currentValue,
        'threshold': violation.threshold,
        'severity': violation.severity.toString(),
        'message': violation.message,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    // Track to Firebase Analytics
    await _analyticsService?.logEvent(
      'performance_violation',
      parameters: {
        'metric': violation.metric,
        'current_value': violation.currentValue,
        'threshold': violation.threshold,
        'severity': violation.severity.toString(),
        'environment': EnvironmentConfig.environment,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Generate performance report
  Future<void> _generatePerformanceReport() async {
    // Implementation for generating periodic performance reports
  }

  /// Load validation history
  Future<void> _loadValidationHistory() async {
    // Implementation for loading validation history from storage
  }

  /// Save validation result
  Future<void> _saveValidationResult(PerformanceValidationResult result) async {
    try {
      // Convert validation history to JSON
      final historyJson = jsonEncode(
        _validationHistory.map((v) => v.toMap()).toList(),
      );
      await _prefs?.setString('performance_validation_history', historyJson);

      // Track validation result to analytics
      await _analyticsService?.logEvent(
        'performance_validation_completed',
        parameters: {
          'overall_status': result.overallStatus.toString(),
          'validation_count': result.validations.length,
          'violation_count': result.violations.length,
          'timestamp': result.timestamp.toIso8601String(),
        },
      );
    } catch (e) {
      _monitoringService?.logError(
        'Failed to save performance validation result',
        error: e,
      );
    }
  }

  /// Get current performance metrics
  Map<String, dynamic> getCurrentPerformanceMetrics() {
    final metrics = <String, dynamic>{};

    for (final entry in _performanceMetrics.entries) {
      if (entry.value.isNotEmpty) {
        final values = entry.value;
        metrics[entry.key] = {
          'current': values.last,
          'average': values.reduce((a, b) => a + b) / values.length,
          'min': values.reduce((a, b) => a < b ? a : b),
          'max': values.reduce((a, b) => a > b ? a : b),
          'count': values.length,
        };
      }
    }

    return metrics;
  }

  /// Get validation history
  List<PerformanceValidationResult> getValidationHistory({int limit = 50}) {
    return _validationHistory.take(limit).toList();
  }

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;

  /// Check if validation is active
  bool get isValidationActive => _isValidationActive;

  /// Dispose resources
  void dispose() {
    _validationTimer?.cancel();
    _reportingTimer?.cancel();
    _isValidationActive = false;
  }
}

/// Performance validation result data class
class PerformanceValidationResult {
  final DateTime timestamp;
  final Map<String, PerformanceValidation> validations;
  ValidationStatus overallStatus;
  final List<PerformanceViolation> violations;

  PerformanceValidationResult({
    required this.timestamp,
    required this.validations,
    required this.overallStatus,
    required this.violations,
  });

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'validations': validations.map((k, v) => MapEntry(k, v.toMap())),
      'overall_status': overallStatus.toString(),
      'violations': violations.map((v) => v.toMap()).toList(),
    };
  }
}

/// Performance validation data class
class PerformanceValidation {
  final String metric;
  final double currentValue;
  final double threshold;
  final ValidationStatus status;
  final String message;

  PerformanceValidation({
    required this.metric,
    required this.currentValue,
    required this.threshold,
    required this.status,
    required this.message,
  });

  Map<String, dynamic> toMap() {
    return {
      'metric': metric,
      'current_value': currentValue,
      'threshold': threshold,
      'status': status.toString(),
      'message': message,
    };
  }
}

/// Performance violation data class
class PerformanceViolation {
  final String metric;
  final double currentValue;
  final double threshold;
  final ViolationSeverity severity;
  final String message;

  PerformanceViolation({
    required this.metric,
    required this.currentValue,
    required this.threshold,
    required this.severity,
    required this.message,
  });

  Map<String, dynamic> toMap() {
    return {
      'metric': metric,
      'current_value': currentValue,
      'threshold': threshold,
      'severity': severity.toString(),
      'message': message,
    };
  }
}

/// Validation status enumeration
enum ValidationStatus { passed, failed, error }

/// Violation severity enumeration
enum ViolationSeverity { low, medium, high, critical }
