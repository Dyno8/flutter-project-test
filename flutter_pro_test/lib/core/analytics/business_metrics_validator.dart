import 'dart:async';
import 'dart:math';
import '../monitoring/monitoring_service.dart';

import 'business_analytics_service.dart';
import 'firebase_analytics_service.dart';
import '../performance/performance_manager.dart';

/// Comprehensive business metrics validation service
/// Validates accuracy, consistency, and real-time synchronization of business analytics
class BusinessMetricsValidator {
  static final BusinessMetricsValidator _instance =
      BusinessMetricsValidator._internal();
  factory BusinessMetricsValidator() => _instance;
  BusinessMetricsValidator._internal();

  // Dependencies
  BusinessAnalyticsService? _businessAnalytics;
  FirebaseAnalyticsService? _firebaseAnalytics;
  MonitoringService? _monitoringService;
  PerformanceManager? _performanceManager;

  // Validation state
  bool _isInitialized = false;
  Timer? _validationTimer;
  final List<ValidationResult> _validationHistory = [];
  final Map<String, dynamic> _baselineMetrics = {};
  final Map<String, List<double>> _metricTrends = {};

  // Validation configuration
  static const Duration _validationInterval = Duration(minutes: 5);
  static const int _maxValidationHistory = 100;
  static const double _acceptableVarianceThreshold = 0.15; // 15%
  static const int _trendAnalysisWindow = 10;

  /// Initialize the validator
  Future<void> initialize({
    required BusinessAnalyticsService businessAnalytics,
    required FirebaseAnalyticsService firebaseAnalytics,
    required MonitoringService monitoringService,
    required PerformanceManager performanceManager,
  }) async {
    if (_isInitialized) return;

    try {
      _businessAnalytics = businessAnalytics;
      _firebaseAnalytics = firebaseAnalytics;
      _monitoringService = monitoringService;
      _performanceManager = performanceManager;

      // Establish baseline metrics
      await _establishBaseline();

      // Start periodic validation
      _startPeriodicValidation();

      _isInitialized = true;

      _logValidationEvent(
        'VALIDATOR_INITIALIZED',
        'Business metrics validator initialized successfully',
        ValidationSeverity.info,
      );
    } catch (e, stackTrace) {
      _logValidationEvent(
        'VALIDATOR_INIT_FAILED',
        'Failed to initialize business metrics validator: $e',
        ValidationSeverity.error,
        metadata: {'stack_trace': stackTrace.toString()},
      );
      rethrow;
    }
  }

  /// Establish baseline metrics for comparison
  Future<void> _establishBaseline() async {
    try {
      final sessionInfo = _businessAnalytics?.getSessionInfo() ?? {};
      final performanceStats = _performanceManager?.getPerformanceStats() ?? {};

      _baselineMetrics.addAll({
        'session_duration': sessionInfo['session_duration_seconds'] ?? 0,
        'journey_events': sessionInfo['journey_events_count'] ?? 0,
        'feature_usage': sessionInfo['feature_usage_count'] ?? 0,
        'memory_usage': performanceStats['memory_usage_bytes'] ?? 0,
        'api_response_time': performanceStats['avg_response_time_ms'] ?? 0,
        'error_count': performanceStats['total_errors'] ?? 0,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      _logValidationEvent(
        'BASELINE_ESTABLISHED',
        'Baseline metrics established',
        ValidationSeverity.info,
        metadata: _baselineMetrics,
      );
    } catch (e) {
      _logValidationEvent(
        'BASELINE_FAILED',
        'Failed to establish baseline metrics: $e',
        ValidationSeverity.error,
      );
    }
  }

  /// Start periodic validation
  void _startPeriodicValidation() {
    _validationTimer = Timer.periodic(_validationInterval, (timer) async {
      if (!_isInitialized) {
        timer.cancel();
        return;
      }

      await _performValidationCycle();
    });
  }

  /// Perform comprehensive validation cycle
  Future<ValidationResult> _performValidationCycle() async {
    final startTime = DateTime.now();
    final validationId = 'validation_${startTime.millisecondsSinceEpoch}';

    try {
      final results = <String, ValidationCheck>{};

      // 1. Data consistency validation
      results['data_consistency'] = await _validateDataConsistency();

      // 2. Real-time synchronization validation
      results['realtime_sync'] = await _validateRealtimeSync();

      // 3. Metric accuracy validation
      results['metric_accuracy'] = await _validateMetricAccuracy();

      // 4. Performance impact validation
      results['performance_impact'] = await _validatePerformanceImpact();

      // 5. Business logic validation
      results['business_logic'] = await _validateBusinessLogic();

      // 6. Trend analysis validation
      results['trend_analysis'] = await _validateTrendAnalysis();

      final duration = DateTime.now().difference(startTime);
      final overallScore = _calculateOverallScore(results);
      final status = _determineValidationStatus(overallScore);

      final validationResult = ValidationResult(
        validationId: validationId,
        timestamp: startTime,
        duration: duration,
        overallScore: overallScore,
        status: status,
        checks: results,
        recommendations: _generateRecommendations(results),
      );

      // Store validation result
      _storeValidationResult(validationResult);

      _logValidationEvent(
        'VALIDATION_COMPLETED',
        'Business metrics validation completed',
        status == ValidationStatus.passed
            ? ValidationSeverity.info
            : ValidationSeverity.warning,
        metadata: {
          'validation_id': validationId,
          'overall_score': overallScore,
          'duration_ms': duration.inMilliseconds,
          'status': status.name,
        },
      );

      return validationResult;
    } catch (e, stackTrace) {
      final errorResult = ValidationResult(
        validationId: validationId,
        timestamp: startTime,
        duration: DateTime.now().difference(startTime),
        overallScore: 0.0,
        status: ValidationStatus.failed,
        checks: {},
        recommendations: ['Fix validation system errors'],
        error: e.toString(),
      );

      _storeValidationResult(errorResult);

      _logValidationEvent(
        'VALIDATION_FAILED',
        'Business metrics validation failed: $e',
        ValidationSeverity.error,
        metadata: {'stack_trace': stackTrace.toString()},
      );

      return errorResult;
    }
  }

  /// Validate data consistency across different sources
  Future<ValidationCheck> _validateDataConsistency() async {
    try {
      final issues = <String>[];
      final sessionInfo = _businessAnalytics?.getSessionInfo() ?? {};
      final performanceStats = _performanceManager?.getPerformanceStats() ?? {};

      // Check for null or invalid values
      if (sessionInfo['session_id'] == null ||
          sessionInfo['session_id'] == '') {
        issues.add('Session ID is null');
      }

      final sessionDuration = sessionInfo['session_duration_seconds'];
      if (sessionDuration != null && sessionDuration < 0) {
        issues.add('Negative session duration detected');
      }

      final totalErrors = performanceStats['total_errors'];
      if (totalErrors != null && totalErrors < 0) {
        issues.add('Negative error count detected');
      }

      // Check for data type consistency
      final journeyEvents = sessionInfo['journey_events_count'];
      if (journeyEvents != null && journeyEvents is! int) {
        issues.add('Journey events count has incorrect data type');
      }

      final score = issues.isEmpty
          ? 100.0
          : max(0.0, 100.0 - (issues.length * 20.0));

      return ValidationCheck(
        checkName: 'Data Consistency',
        score: score,
        passed: issues.isEmpty,
        issues: issues,
        recommendations: issues.isEmpty
            ? []
            : ['Review data collection and validation logic'],
      );
    } catch (e) {
      return ValidationCheck(
        checkName: 'Data Consistency',
        score: 0.0,
        passed: false,
        issues: ['Validation check failed: $e'],
        recommendations: ['Fix data consistency validation'],
      );
    }
  }

  /// Validate real-time synchronization
  Future<ValidationCheck> _validateRealtimeSync() async {
    try {
      final issues = <String>[];
      final startTime = DateTime.now();

      // Simulate real-time data update
      await _businessAnalytics?.trackUserAction(
        actionName: 'validation_test_action',
        category: 'validation',
      );

      // Wait for synchronization
      await Future.delayed(const Duration(milliseconds: 500));

      // Check if data was updated
      final sessionInfo = _businessAnalytics?.getSessionInfo() ?? {};
      final syncDelay = DateTime.now().difference(startTime);

      if (syncDelay.inMilliseconds > 1000) {
        issues.add('Real-time sync delay exceeds 1 second');
      }

      if (sessionInfo['journey_events_count'] == null) {
        issues.add('Journey events not updating in real-time');
      }

      final score = issues.isEmpty
          ? 100.0
          : max(0.0, 100.0 - (issues.length * 25.0));

      return ValidationCheck(
        checkName: 'Real-time Synchronization',
        score: score,
        passed: issues.isEmpty,
        issues: issues,
        recommendations: issues.isEmpty
            ? []
            : ['Optimize real-time data synchronization'],
      );
    } catch (e) {
      return ValidationCheck(
        checkName: 'Real-time Synchronization',
        score: 0.0,
        passed: false,
        issues: ['Sync validation failed: $e'],
        recommendations: ['Fix real-time synchronization validation'],
      );
    }
  }

  /// Validate metric accuracy against baseline
  Future<ValidationCheck> _validateMetricAccuracy() async {
    try {
      final issues = <String>[];
      final sessionInfo = _businessAnalytics?.getSessionInfo() ?? {};
      final performanceStats = _performanceManager?.getPerformanceStats() ?? {};

      // Compare against baseline
      final currentMetrics = {
        'session_duration': sessionInfo['session_duration_seconds'] ?? 0,
        'journey_events': sessionInfo['journey_events_count'] ?? 0,
        'memory_usage': performanceStats['memory_usage_bytes'] ?? 0,
        'error_count': performanceStats['total_errors'] ?? 0,
      };

      for (final entry in currentMetrics.entries) {
        final key = entry.key;
        final currentValue = entry.value as num;
        final baselineValue = _baselineMetrics[key] as num? ?? 0;

        if (baselineValue > 0) {
          final variance = (currentValue - baselineValue).abs() / baselineValue;
          if (variance > _acceptableVarianceThreshold) {
            issues.add(
              '$key variance (${(variance * 100).toStringAsFixed(1)}%) exceeds threshold',
            );
          }
        }

        // Update trend data
        _metricTrends[key] = (_metricTrends[key] ?? [])
          ..add(currentValue.toDouble());
        if (_metricTrends[key]!.length > _trendAnalysisWindow) {
          _metricTrends[key]!.removeAt(0);
        }
      }

      final score = issues.isEmpty
          ? 100.0
          : max(0.0, 100.0 - (issues.length * 15.0));

      return ValidationCheck(
        checkName: 'Metric Accuracy',
        score: score,
        passed: issues.isEmpty,
        issues: issues,
        recommendations: issues.isEmpty
            ? []
            : [
                'Review metric calculation algorithms',
                'Check data collection accuracy',
              ],
      );
    } catch (e) {
      return ValidationCheck(
        checkName: 'Metric Accuracy',
        score: 0.0,
        passed: false,
        issues: ['Accuracy validation failed: $e'],
        recommendations: ['Fix metric accuracy validation'],
      );
    }
  }

  /// Validate performance impact of analytics
  Future<ValidationCheck> _validatePerformanceImpact() async {
    try {
      final issues = <String>[];
      final performanceStats = _performanceManager?.getPerformanceStats() ?? {};

      final memoryUsage = performanceStats['memory_usage_bytes'] as num? ?? 0;
      final responseTime =
          performanceStats['avg_response_time_ms'] as num? ?? 0;

      // Check memory usage (should be under 100MB for analytics)
      if (memoryUsage > 100 * 1024 * 1024) {
        issues.add('Analytics memory usage exceeds 100MB');
      }

      // Check response time impact (should be under 100ms)
      if (responseTime > 100) {
        issues.add('Analytics causing response time degradation');
      }

      final score = issues.isEmpty
          ? 100.0
          : max(0.0, 100.0 - (issues.length * 30.0));

      return ValidationCheck(
        checkName: 'Performance Impact',
        score: score,
        passed: issues.isEmpty,
        issues: issues,
        recommendations: issues.isEmpty
            ? []
            : ['Optimize analytics performance', 'Reduce memory footprint'],
      );
    } catch (e) {
      return ValidationCheck(
        checkName: 'Performance Impact',
        score: 0.0,
        passed: false,
        issues: ['Performance validation failed: $e'],
        recommendations: ['Fix performance impact validation'],
      );
    }
  }

  /// Validate business logic consistency
  Future<ValidationCheck> _validateBusinessLogic() async {
    try {
      final issues = <String>[];
      final sessionInfo = _businessAnalytics?.getSessionInfo() ?? {};

      // Validate session logic
      final sessionDuration =
          sessionInfo['session_duration_seconds'] as int? ?? 0;
      final journeyEvents = sessionInfo['journey_events_count'] as int? ?? 0;

      if (sessionDuration > 0 && journeyEvents == 0) {
        issues.add('Active session with no journey events');
      }

      if (sessionDuration < 0) {
        issues.add('Negative session duration');
      }

      // Validate user tracking logic
      final userId = _businessAnalytics?.currentUserId;
      final userType = _businessAnalytics?.currentUserType;

      if (userId != null && userId.isNotEmpty && userType == null) {
        issues.add('User ID set but user type missing');
      }

      final score = issues.isEmpty
          ? 100.0
          : max(0.0, 100.0 - (issues.length * 20.0));

      return ValidationCheck(
        checkName: 'Business Logic',
        score: score,
        passed: issues.isEmpty,
        issues: issues,
        recommendations: issues.isEmpty
            ? []
            : ['Review business logic implementation'],
      );
    } catch (e) {
      return ValidationCheck(
        checkName: 'Business Logic',
        score: 0.0,
        passed: false,
        issues: ['Business logic validation failed: $e'],
        recommendations: ['Fix business logic validation'],
      );
    }
  }

  /// Validate trend analysis
  Future<ValidationCheck> _validateTrendAnalysis() async {
    try {
      final issues = <String>[];

      for (final entry in _metricTrends.entries) {
        final metricName = entry.key;
        final values = entry.value;

        if (values.length >= 3) {
          // Check for anomalous spikes
          final mean = values.reduce((a, b) => a + b) / values.length;
          final variance =
              values.map((v) => pow(v - mean, 2)).reduce((a, b) => a + b) /
              values.length;
          final stdDev = sqrt(variance);

          for (final value in values) {
            if ((value - mean).abs() > 3 * stdDev) {
              issues.add('Anomalous spike detected in $metricName');
              break;
            }
          }
        }
      }

      final score = issues.isEmpty
          ? 100.0
          : max(0.0, 100.0 - (issues.length * 25.0));

      return ValidationCheck(
        checkName: 'Trend Analysis',
        score: score,
        passed: issues.isEmpty,
        issues: issues,
        recommendations: issues.isEmpty
            ? []
            : [
                'Investigate metric anomalies',
                'Review data collection stability',
              ],
      );
    } catch (e) {
      return ValidationCheck(
        checkName: 'Trend Analysis',
        score: 0.0,
        passed: false,
        issues: ['Trend analysis failed: $e'],
        recommendations: ['Fix trend analysis validation'],
      );
    }
  }

  /// Calculate overall validation score
  double _calculateOverallScore(Map<String, ValidationCheck> checks) {
    if (checks.isEmpty) return 0.0;

    final totalScore = checks.values.fold<double>(
      0.0,
      (sum, check) => sum + check.score,
    );
    return totalScore / checks.length;
  }

  /// Determine validation status based on score
  ValidationStatus _determineValidationStatus(double score) {
    if (score >= 90.0) return ValidationStatus.passed;
    if (score >= 70.0) return ValidationStatus.warning;
    return ValidationStatus.failed;
  }

  /// Generate recommendations based on validation results
  List<String> _generateRecommendations(Map<String, ValidationCheck> checks) {
    final recommendations = <String>[];

    for (final check in checks.values) {
      if (!check.passed) {
        recommendations.addAll(check.recommendations);
      }
    }

    // Add general recommendations
    if (recommendations.isNotEmpty) {
      recommendations.addAll([
        'Schedule regular metrics validation',
        'Monitor analytics performance impact',
        'Review data collection accuracy',
      ]);
    }

    return recommendations.toSet().toList(); // Remove duplicates
  }

  /// Store validation result
  void _storeValidationResult(ValidationResult result) {
    _validationHistory.add(result);

    // Keep history size manageable
    while (_validationHistory.length > _maxValidationHistory) {
      _validationHistory.removeAt(0);
    }
  }

  /// Log validation event
  void _logValidationEvent(
    String eventType,
    String description,
    ValidationSeverity severity, {
    Map<String, dynamic>? metadata,
  }) {
    final enhancedMetadata = {
      'event_type': eventType,
      'severity': severity.name,
      'timestamp': DateTime.now().toIso8601String(),
      'service': 'BusinessMetricsValidator',
      ...?metadata,
    };

    switch (severity) {
      case ValidationSeverity.error:
        _monitoringService?.logError(description, metadata: enhancedMetadata);
        break;
      case ValidationSeverity.warning:
        _monitoringService?.logWarning(description, metadata: enhancedMetadata);
        break;
      case ValidationSeverity.info:
        _monitoringService?.logInfo(description, metadata: enhancedMetadata);
        break;
    }
  }

  /// Get validation history
  List<ValidationResult> getValidationHistory() =>
      List.unmodifiable(_validationHistory);

  /// Get latest validation result
  ValidationResult? getLatestValidation() =>
      _validationHistory.isNotEmpty ? _validationHistory.last : null;

  /// Get validation summary
  Map<String, dynamic> getValidationSummary() {
    final latest = getLatestValidation();

    return {
      'is_initialized': _isInitialized,
      'validation_active': _validationTimer?.isActive ?? false,
      'total_validations': _validationHistory.length,
      'latest_score': latest?.overallScore ?? 0.0,
      'latest_status': latest?.status.name ?? 'unknown',
      'last_validation': latest?.timestamp.toIso8601String(),
    };
  }

  /// Perform manual validation
  Future<ValidationResult> performManualValidation() async {
    return await _performValidationCycle();
  }

  /// Dispose resources
  void dispose() {
    _validationTimer?.cancel();
    _validationHistory.clear();
    _metricTrends.clear();
    _isInitialized = false;
  }

  /// Check if validator is initialized
  bool get isInitialized => _isInitialized;
}

/// Validation result
class ValidationResult {
  final String validationId;
  final DateTime timestamp;
  final Duration duration;
  final double overallScore;
  final ValidationStatus status;
  final Map<String, ValidationCheck> checks;
  final List<String> recommendations;
  final String? error;

  const ValidationResult({
    required this.validationId,
    required this.timestamp,
    required this.duration,
    required this.overallScore,
    required this.status,
    required this.checks,
    required this.recommendations,
    this.error,
  });
}

/// Individual validation check
class ValidationCheck {
  final String checkName;
  final double score;
  final bool passed;
  final List<String> issues;
  final List<String> recommendations;

  const ValidationCheck({
    required this.checkName,
    required this.score,
    required this.passed,
    required this.issues,
    required this.recommendations,
  });
}

/// Validation status
enum ValidationStatus { passed, warning, failed }

/// Validation severity
enum ValidationSeverity { info, warning, error }
