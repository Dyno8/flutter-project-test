import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../analytics/firebase_analytics_service.dart';
import '../analytics/analytics_events.dart';
import '../monitoring/monitoring_service.dart';
import '../error_tracking/error_tracking_service.dart';
import '../config/environment_config.dart';

/// Comprehensive performance analytics and optimization service
class PerformanceAnalyticsService {
  static final PerformanceAnalyticsService _instance =
      PerformanceAnalyticsService._internal();
  factory PerformanceAnalyticsService() => _instance;
  PerformanceAnalyticsService._internal();

  // Dependencies
  FirebaseAnalyticsService? _analyticsService;
  MonitoringService? _monitoringService;
  ErrorTrackingService? _errorTrackingService;
  SharedPreferences? _prefs;

  // Performance data
  final Map<String, List<PerformanceMetric>> _performanceHistory = {};
  final Map<String, PerformanceBaseline> _performanceBaselines = {};
  final List<PerformanceBottleneck> _identifiedBottlenecks = [];
  final List<OptimizationRecommendation> _recommendations = [];

  // Configuration
  static const int maxHistorySize = 1000;
  static const Duration analysisInterval = Duration(minutes: 10);
  static const Duration baselineUpdateInterval = Duration(hours: 24);

  // State
  bool _isInitialized = false;
  Timer? _analysisTimer;
  Timer? _baselineUpdateTimer;

  /// Initialize performance analytics service
  Future<void> initialize({
    required FirebaseAnalyticsService analyticsService,
    required MonitoringService monitoringService,
    required ErrorTrackingService errorTrackingService,
  }) async {
    if (_isInitialized) return;

    try {
      _analyticsService = analyticsService;
      _monitoringService = monitoringService;
      _errorTrackingService = errorTrackingService;
      _prefs = await SharedPreferences.getInstance();

      // Load saved performance data
      await _loadPerformanceData();

      // Set up default baselines
      _setupDefaultBaselines();

      // Start performance analysis
      _startPerformanceAnalysis();
      _startBaselineUpdates();

      _isInitialized = true;

      // Track initialization
      await _analyticsService?.logEvent(
        'performance_analytics_initialized',
        parameters: {
          'timestamp': DateTime.now().toIso8601String(),
          'environment': EnvironmentConfig.environment,
        },
      );

      _monitoringService?.logInfo('Performance Analytics Service initialized');
    } catch (e, stackTrace) {
      _monitoringService?.logError(
        'Failed to initialize Performance Analytics Service',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Record performance metric
  Future<void> recordMetric({
    required String metricName,
    required double value,
    required String unit,
    String? context,
    Map<String, dynamic>? metadata,
  }) async {
    if (!_isInitialized) return;

    try {
      final metric = PerformanceMetric(
        name: metricName,
        value: value,
        unit: unit,
        timestamp: DateTime.now(),
        context: context,
        metadata: metadata ?? {},
      );

      // Add to history
      _performanceHistory[metricName] ??= [];
      _performanceHistory[metricName]!.add(metric);

      // Keep history size manageable
      if (_performanceHistory[metricName]!.length > maxHistorySize) {
        _performanceHistory[metricName]!.removeAt(0);
      }

      // Check for performance regression
      await _checkPerformanceRegression(metricName, metric);

      // Track to Firebase Analytics
      await _analyticsService?.logEvent(
        AnalyticsEvents.screenLoadTime,
        parameters: {
          'metric_name': metricName,
          'metric_value': value,
          'metric_unit': unit,
          'context': context ?? 'unknown',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      _monitoringService?.logInfo(
        'Performance metric recorded: $metricName = $value $unit',
      );
    } catch (e, stackTrace) {
      _monitoringService?.logError(
        'Failed to record performance metric',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Record screen load time
  Future<void> recordScreenLoadTime({
    required String screenName,
    required Duration loadTime,
    Map<String, dynamic>? metadata,
  }) async {
    await recordMetric(
      metricName: 'screen_load_time_$screenName',
      value: loadTime.inMilliseconds.toDouble(),
      unit: 'ms',
      context: 'screen_loading',
      metadata: {'screen_name': screenName, ...?metadata},
    );
  }

  /// Record API response time
  Future<void> recordApiResponseTime({
    required String endpoint,
    required Duration responseTime,
    int? statusCode,
    Map<String, dynamic>? metadata,
  }) async {
    await recordMetric(
      metricName: 'api_response_time',
      value: responseTime.inMilliseconds.toDouble(),
      unit: 'ms',
      context: endpoint,
      metadata: {'endpoint': endpoint, 'status_code': statusCode, ...?metadata},
    );
  }

  /// Record memory usage
  Future<void> recordMemoryUsage({
    required double memoryUsageMB,
    String? context,
    Map<String, dynamic>? metadata,
  }) async {
    await recordMetric(
      metricName: 'memory_usage',
      value: memoryUsageMB,
      unit: 'MB',
      context: context ?? 'app_runtime',
      metadata: metadata,
    );
  }

  /// Record frame rendering time
  Future<void> recordFrameRenderTime({
    required Duration renderTime,
    String? screenName,
    Map<String, dynamic>? metadata,
  }) async {
    await recordMetric(
      metricName: 'frame_render_time',
      value: renderTime.inMicroseconds.toDouble(),
      unit: 'μs',
      context: screenName ?? 'unknown_screen',
      metadata: {'screen_name': screenName, ...?metadata},
    );
  }

  /// Get performance statistics
  Map<String, dynamic> getPerformanceStatistics() {
    final now = DateTime.now();
    final last24Hours = now.subtract(const Duration(hours: 24));
    final lastWeek = now.subtract(const Duration(days: 7));

    final stats = <String, dynamic>{};

    for (final entry in _performanceHistory.entries) {
      final metricName = entry.key;
      final metrics = entry.value;

      final recent24h = metrics
          .where((m) => m.timestamp.isAfter(last24Hours))
          .toList();
      final recentWeek = metrics
          .where((m) => m.timestamp.isAfter(lastWeek))
          .toList();

      if (recent24h.isNotEmpty) {
        stats[metricName] = {
          'current_24h': {
            'count': recent24h.length,
            'average': _calculateAverage(recent24h),
            'min': _calculateMin(recent24h),
            'max': _calculateMax(recent24h),
            'p95': _calculatePercentile(recent24h, 0.95),
            'p99': _calculatePercentile(recent24h, 0.99),
          },
          'week_trend': _calculateTrend(recentWeek),
          'baseline_comparison': _compareToBaseline(metricName, recent24h),
        };
      }
    }

    return {
      'metrics': stats,
      'bottlenecks': _identifiedBottlenecks.map((b) => b.toJson()).toList(),
      'recommendations': _recommendations.map((r) => r.toJson()).toList(),
      'performance_score': _calculateOverallPerformanceScore(),
      'regression_alerts': _getRecentRegressionAlerts(),
    };
  }

  /// Get performance trends
  Map<String, dynamic> getPerformanceTrends({Duration? timeWindow}) {
    final window = timeWindow ?? const Duration(days: 7);
    final cutoff = DateTime.now().subtract(window);

    final trends = <String, dynamic>{};

    for (final entry in _performanceHistory.entries) {
      final metricName = entry.key;
      final metrics = entry.value
          .where((m) => m.timestamp.isAfter(cutoff))
          .toList();

      if (metrics.length >= 2) {
        trends[metricName] = {
          'trend_direction': _calculateTrendDirection(metrics),
          'trend_percentage': _calculateTrendPercentage(metrics),
          'data_points': metrics.length,
          'time_window_hours': window.inHours,
        };
      }
    }

    return trends;
  }

  /// Get optimization recommendations
  List<OptimizationRecommendation> getOptimizationRecommendations() {
    return List.unmodifiable(_recommendations);
  }

  /// Get identified bottlenecks
  List<PerformanceBottleneck> getIdentifiedBottlenecks() {
    return List.unmodifiable(_identifiedBottlenecks);
  }

  /// Check for performance regression
  Future<void> _checkPerformanceRegression(
    String metricName,
    PerformanceMetric metric,
  ) async {
    final baseline = _performanceBaselines[metricName];
    if (baseline == null) return;

    final regressionThreshold =
        baseline.averageValue * 1.5; // 50% worse than baseline

    if (metric.value > regressionThreshold) {
      // Performance regression detected
      await _errorTrackingService?.trackPerformanceDegradation(
        metricName: metricName,
        currentValue: metric.value,
        threshold: regressionThreshold,
        context: 'performance_regression_detection',
        metadata: {
          'baseline_average': baseline.averageValue,
          'regression_percentage':
              ((metric.value - baseline.averageValue) /
              baseline.averageValue *
              100),
          'metric_context': metric.context,
        },
      );

      // Generate recommendation
      _generateRegressionRecommendation(metricName, metric, baseline);
    }
  }

  /// Generate regression recommendation
  void _generateRegressionRecommendation(
    String metricName,
    PerformanceMetric metric,
    PerformanceBaseline baseline,
  ) {
    final recommendation = OptimizationRecommendation(
      id: 'regression_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Performance Regression Detected: $metricName',
      description:
          'Performance has degraded by ${((metric.value - baseline.averageValue) / baseline.averageValue * 100).toStringAsFixed(1)}% compared to baseline',
      priority: RecommendationPriority.high,
      category: RecommendationCategory.performance,
      impact: RecommendationImpact.high,
      effort: RecommendationEffort.medium,
      recommendations: [
        'Investigate recent code changes that might affect $metricName',
        'Check for memory leaks or resource contention',
        'Review caching strategies and data loading patterns',
        'Consider performance profiling to identify bottlenecks',
      ],
      createdAt: DateTime.now(),
    );

    _recommendations.add(recommendation);

    // Keep recommendations list manageable
    if (_recommendations.length > 50) {
      _recommendations.removeAt(0);
    }
  }

  /// Start performance analysis
  void _startPerformanceAnalysis() {
    _analysisTimer = Timer.periodic(analysisInterval, (_) async {
      await _analyzePerformanceData();
    });
  }

  /// Start baseline updates
  void _startBaselineUpdates() {
    _baselineUpdateTimer = Timer.periodic(baselineUpdateInterval, (_) async {
      await _updatePerformanceBaselines();
    });
  }

  /// Analyze performance data for bottlenecks and recommendations
  Future<void> _analyzePerformanceData() async {
    try {
      // Clear old bottlenecks and recommendations
      _identifiedBottlenecks.clear();

      // Analyze each metric
      for (final entry in _performanceHistory.entries) {
        final metricName = entry.key;
        final metrics = entry.value;

        if (metrics.length >= 10) {
          // Need sufficient data
          await _analyzeMetricForBottlenecks(metricName, metrics);
        }
      }

      // Generate general recommendations
      _generateGeneralRecommendations();

      // Save analysis results
      await _savePerformanceData();

      _monitoringService?.logInfo('Performance analysis completed');
    } catch (e, stackTrace) {
      _monitoringService?.logError(
        'Failed to analyze performance data',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Analyze metric for bottlenecks
  Future<void> _analyzeMetricForBottlenecks(
    String metricName,
    List<PerformanceMetric> metrics,
  ) async {
    final recentMetrics = metrics
        .where(
          (m) => m.timestamp.isAfter(
            DateTime.now().subtract(const Duration(hours: 1)),
          ),
        )
        .toList();

    if (recentMetrics.isEmpty) return;

    final average = _calculateAverage(recentMetrics);
    final p95 = _calculatePercentile(recentMetrics, 0.95);

    // Check if P95 is significantly higher than average (indicating inconsistent performance)
    if (p95 > average * 2) {
      final bottleneck = PerformanceBottleneck(
        id: 'bottleneck_${DateTime.now().millisecondsSinceEpoch}',
        metricName: metricName,
        description:
            'Inconsistent performance detected - P95 is ${(p95 / average).toStringAsFixed(1)}x higher than average',
        severity: BottleneckSeverity.medium,
        averageValue: average,
        p95Value: p95,
        affectedOperations: recentMetrics
            .map((m) => m.context ?? 'unknown')
            .toSet()
            .toList(),
        detectedAt: DateTime.now(),
      );

      _identifiedBottlenecks.add(bottleneck);
    }
  }

  /// Generate general recommendations
  void _generateGeneralRecommendations() {
    // Example: Check for high memory usage
    final memoryMetrics = _performanceHistory['memory_usage'];
    if (memoryMetrics != null && memoryMetrics.isNotEmpty) {
      final recentMemory = memoryMetrics
          .where(
            (m) => m.timestamp.isAfter(
              DateTime.now().subtract(const Duration(hours: 1)),
            ),
          )
          .toList();

      if (recentMemory.isNotEmpty) {
        final avgMemory = _calculateAverage(recentMemory);
        if (avgMemory > 200) {
          // High memory usage threshold
          final recommendation = OptimizationRecommendation(
            id: 'memory_${DateTime.now().millisecondsSinceEpoch}',
            title: 'High Memory Usage Detected',
            description:
                'Average memory usage is ${avgMemory.toStringAsFixed(1)} MB, which may impact performance',
            priority: RecommendationPriority.medium,
            category: RecommendationCategory.memory,
            impact: RecommendationImpact.medium,
            effort: RecommendationEffort.high,
            recommendations: [
              'Review image loading and caching strategies',
              'Check for memory leaks in long-running operations',
              'Consider implementing lazy loading for large datasets',
              'Optimize widget rebuilds and state management',
            ],
            createdAt: DateTime.now(),
          );

          _recommendations.add(recommendation);
        }
      }
    }
  }

  /// Update performance baselines
  Future<void> _updatePerformanceBaselines() async {
    try {
      final cutoff = DateTime.now().subtract(const Duration(days: 7));

      for (final entry in _performanceHistory.entries) {
        final metricName = entry.key;
        final metrics = entry.value
            .where((m) => m.timestamp.isAfter(cutoff))
            .toList();

        if (metrics.length >= 50) {
          // Need sufficient data for baseline
          final baseline = PerformanceBaseline(
            metricName: metricName,
            averageValue: _calculateAverage(metrics),
            p50Value: _calculatePercentile(metrics, 0.5),
            p95Value: _calculatePercentile(metrics, 0.95),
            sampleCount: metrics.length,
            updatedAt: DateTime.now(),
          );

          _performanceBaselines[metricName] = baseline;
        }
      }

      await _savePerformanceData();
      _monitoringService?.logInfo('Performance baselines updated');
    } catch (e, stackTrace) {
      _monitoringService?.logError(
        'Failed to update performance baselines',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Setup default baselines
  void _setupDefaultBaselines() {
    // Default baselines for common metrics
    _performanceBaselines['screen_load_time'] = PerformanceBaseline(
      metricName: 'screen_load_time',
      averageValue: 2000, // 2 seconds
      p50Value: 1500,
      p95Value: 4000,
      sampleCount: 100,
      updatedAt: DateTime.now(),
    );

    _performanceBaselines['api_response_time'] = PerformanceBaseline(
      metricName: 'api_response_time',
      averageValue: 500, // 500ms
      p50Value: 300,
      p95Value: 1000,
      sampleCount: 100,
      updatedAt: DateTime.now(),
    );
  }

  /// Calculate average value
  double _calculateAverage(List<PerformanceMetric> metrics) {
    if (metrics.isEmpty) return 0.0;
    return metrics.map((m) => m.value).reduce((a, b) => a + b) / metrics.length;
  }

  /// Calculate minimum value
  double _calculateMin(List<PerformanceMetric> metrics) {
    if (metrics.isEmpty) return 0.0;
    return metrics.map((m) => m.value).reduce(min);
  }

  /// Calculate maximum value
  double _calculateMax(List<PerformanceMetric> metrics) {
    if (metrics.isEmpty) return 0.0;
    return metrics.map((m) => m.value).reduce(max);
  }

  /// Calculate percentile
  double _calculatePercentile(
    List<PerformanceMetric> metrics,
    double percentile,
  ) {
    if (metrics.isEmpty) return 0.0;

    final sortedValues = metrics.map((m) => m.value).toList()..sort();
    final index = (sortedValues.length * percentile).floor();
    return sortedValues[index.clamp(0, sortedValues.length - 1)];
  }

  /// Calculate trend direction
  String _calculateTrendDirection(List<PerformanceMetric> metrics) {
    if (metrics.length < 2) return 'stable';

    final firstHalf = metrics.take(metrics.length ~/ 2).toList();
    final secondHalf = metrics.skip(metrics.length ~/ 2).toList();

    final firstAvg = _calculateAverage(firstHalf);
    final secondAvg = _calculateAverage(secondHalf);

    if (secondAvg > firstAvg * 1.1) return 'degrading';
    if (secondAvg < firstAvg * 0.9) return 'improving';
    return 'stable';
  }

  /// Calculate trend percentage
  double _calculateTrendPercentage(List<PerformanceMetric> metrics) {
    if (metrics.length < 2) return 0.0;

    final firstHalf = metrics.take(metrics.length ~/ 2).toList();
    final secondHalf = metrics.skip(metrics.length ~/ 2).toList();

    final firstAvg = _calculateAverage(firstHalf);
    final secondAvg = _calculateAverage(secondHalf);

    if (firstAvg == 0) return 0.0;
    return ((secondAvg - firstAvg) / firstAvg * 100);
  }

  /// Calculate trend
  String _calculateTrend(List<PerformanceMetric> metrics) {
    return _calculateTrendDirection(metrics);
  }

  /// Compare to baseline
  Map<String, dynamic> _compareToBaseline(
    String metricName,
    List<PerformanceMetric> metrics,
  ) {
    final baseline = _performanceBaselines[metricName];
    if (baseline == null || metrics.isEmpty) {
      return {'status': 'no_baseline'};
    }

    final currentAvg = _calculateAverage(metrics);
    final difference =
        ((currentAvg - baseline.averageValue) / baseline.averageValue * 100);

    return {
      'baseline_average': baseline.averageValue,
      'current_average': currentAvg,
      'difference_percentage': difference,
      'status': difference > 20
          ? 'degraded'
          : difference < -20
          ? 'improved'
          : 'stable',
    };
  }

  /// Calculate overall performance score
  double _calculateOverallPerformanceScore() {
    // Simple scoring algorithm based on recent performance vs baselines
    double totalScore = 0.0;
    int metricCount = 0;

    for (final entry in _performanceHistory.entries) {
      final metricName = entry.key;
      final metrics = entry.value;
      final baseline = _performanceBaselines[metricName];

      if (baseline != null && metrics.isNotEmpty) {
        final recentMetrics = metrics
            .where(
              (m) => m.timestamp.isAfter(
                DateTime.now().subtract(const Duration(hours: 1)),
              ),
            )
            .toList();

        if (recentMetrics.isNotEmpty) {
          final currentAvg = _calculateAverage(recentMetrics);
          final score = (baseline.averageValue / currentAvg * 100).clamp(
            0,
            100,
          );
          totalScore += score;
          metricCount++;
        }
      }
    }

    return metricCount > 0 ? totalScore / metricCount : 85.0; // Default score
  }

  /// Get recent regression alerts
  List<Map<String, dynamic>> _getRecentRegressionAlerts() {
    final cutoff = DateTime.now().subtract(const Duration(hours: 24));
    return _recommendations
        .where(
          (r) => r.createdAt.isAfter(cutoff) && r.title.contains('Regression'),
        )
        .map((r) => r.toJson())
        .toList();
  }

  /// Load performance data from storage
  Future<void> _loadPerformanceData() async {
    try {
      final dataJson = _prefs?.getString('performance_analytics_data');
      if (dataJson != null) {
        final data = jsonDecode(dataJson) as Map<String, dynamic>;

        // Load baselines
        final baselinesData = data['baselines'] as Map<String, dynamic>? ?? {};
        for (final entry in baselinesData.entries) {
          try {
            _performanceBaselines[entry.key] = PerformanceBaseline.fromJson(
              entry.value,
            );
          } catch (e) {
            // Skip invalid baseline data
          }
        }
      }
    } catch (e) {
      _monitoringService?.logError('Failed to load performance data', error: e);
    }
  }

  /// Save performance data to storage
  Future<void> _savePerformanceData() async {
    try {
      final data = {
        'baselines': _performanceBaselines.map(
          (k, v) => MapEntry(k, v.toJson()),
        ),
        'saved_at': DateTime.now().toIso8601String(),
      };

      await _prefs?.setString('performance_analytics_data', jsonEncode(data));
    } catch (e) {
      _monitoringService?.logError('Failed to save performance data', error: e);
    }
  }

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;

  /// Dispose resources
  void dispose() {
    _analysisTimer?.cancel();
    _baselineUpdateTimer?.cancel();
    _isInitialized = false;
  }
}

/// Performance metric model
class PerformanceMetric {
  final String name;
  final double value;
  final String unit;
  final DateTime timestamp;
  final String? context;
  final Map<String, dynamic> metadata;

  PerformanceMetric({
    required this.name,
    required this.value,
    required this.unit,
    required this.timestamp,
    this.context,
    required this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'value': value,
    'unit': unit,
    'timestamp': timestamp.toIso8601String(),
    'context': context,
    'metadata': metadata,
  };

  factory PerformanceMetric.fromJson(Map<String, dynamic> json) =>
      PerformanceMetric(
        name: json['name'],
        value: json['value'].toDouble(),
        unit: json['unit'],
        timestamp: DateTime.parse(json['timestamp']),
        context: json['context'],
        metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      );
}

/// Performance baseline model
class PerformanceBaseline {
  final String metricName;
  final double averageValue;
  final double p50Value;
  final double p95Value;
  final int sampleCount;
  final DateTime updatedAt;

  PerformanceBaseline({
    required this.metricName,
    required this.averageValue,
    required this.p50Value,
    required this.p95Value,
    required this.sampleCount,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'metricName': metricName,
    'averageValue': averageValue,
    'p50Value': p50Value,
    'p95Value': p95Value,
    'sampleCount': sampleCount,
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory PerformanceBaseline.fromJson(Map<String, dynamic> json) =>
      PerformanceBaseline(
        metricName: json['metricName'],
        averageValue: json['averageValue'].toDouble(),
        p50Value: json['p50Value'].toDouble(),
        p95Value: json['p95Value'].toDouble(),
        sampleCount: json['sampleCount'],
        updatedAt: DateTime.parse(json['updatedAt']),
      );
}

/// Performance bottleneck model
class PerformanceBottleneck {
  final String id;
  final String metricName;
  final String description;
  final BottleneckSeverity severity;
  final double averageValue;
  final double p95Value;
  final List<String> affectedOperations;
  final DateTime detectedAt;

  PerformanceBottleneck({
    required this.id,
    required this.metricName,
    required this.description,
    required this.severity,
    required this.averageValue,
    required this.p95Value,
    required this.affectedOperations,
    required this.detectedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'metricName': metricName,
    'description': description,
    'severity': severity.name,
    'averageValue': averageValue,
    'p95Value': p95Value,
    'affectedOperations': affectedOperations,
    'detectedAt': detectedAt.toIso8601String(),
  };
}

/// Optimization recommendation model
class OptimizationRecommendation {
  final String id;
  final String title;
  final String description;
  final RecommendationPriority priority;
  final RecommendationCategory category;
  final RecommendationImpact impact;
  final RecommendationEffort effort;
  final List<String> recommendations;
  final DateTime createdAt;

  OptimizationRecommendation({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.category,
    required this.impact,
    required this.effort,
    required this.recommendations,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'priority': priority.name,
    'category': category.name,
    'impact': impact.name,
    'effort': effort.name,
    'recommendations': recommendations,
    'createdAt': createdAt.toIso8601String(),
  };
}

/// Bottleneck severity levels
enum BottleneckSeverity { low, medium, high, critical }

/// Recommendation priority levels
enum RecommendationPriority { low, medium, high, critical }

/// Recommendation categories
enum RecommendationCategory {
  performance,
  memory,
  network,
  ui,
  database,
  caching,
}

/// Recommendation impact levels
enum RecommendationImpact { low, medium, high }

/// Recommendation effort levels
enum RecommendationEffort { low, medium, high }
