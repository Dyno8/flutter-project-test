import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../analytics/firebase_analytics_service.dart';
import 'monitoring_service.dart';
import 'ux_monitoring_service.dart';
import '../error_tracking/error_tracking_service.dart';

/// Specialized service for analyzing error impact on user experience
/// Correlates errors with user behavior, session abandonment, and satisfaction
class UXErrorImpactAnalyzer {
  static final UXErrorImpactAnalyzer _instance =
      UXErrorImpactAnalyzer._internal();
  factory UXErrorImpactAnalyzer() => _instance;
  UXErrorImpactAnalyzer._internal();

  // Dependencies
  late final UXMonitoringService _uxMonitoringService;
  late final FirebaseAnalyticsService _analyticsService;
  late final MonitoringService _monitoringService;
  late final ErrorTrackingService _errorTrackingService;
  SharedPreferences? _prefs;

  // State management
  bool _isInitialized = false;

  // Error impact tracking
  final List<ErrorImpactAnalysis> _errorImpactHistory = [];
  final Map<String, List<ErrorImpactAnalysis>> _impactsByScreen = {};
  final Map<String, List<ErrorImpactAnalysis>> _impactsByErrorType = {};
  final Map<String, double> _screenAbandonmentRates = {};
  final Map<String, double> _errorRecoveryRates = {};

  // Error patterns
  final Map<String, int> _errorFrequency = {};
  final Map<String, List<String>> _errorSequences = {};
  final Map<String, double> _errorSeverityScores = {};

  // Configuration
  static const int maxImpactHistory = 1000;
  static const Duration analysisInterval = Duration(minutes: 10);
  static const double criticalAbandonmentThreshold = 0.3; // 30%
  static const double highImpactThreshold = 0.2; // 20%

  // Timer for periodic analysis
  Timer? _analysisTimer;

  /// Initialize UX error impact analyzer
  Future<void> initialize({
    required UXMonitoringService uxMonitoringService,
    required FirebaseAnalyticsService analyticsService,
    required MonitoringService monitoringService,
    required ErrorTrackingService errorTrackingService,
  }) async {
    if (_isInitialized) return;

    try {
      _uxMonitoringService = uxMonitoringService;
      _analyticsService = analyticsService;
      _monitoringService = monitoringService;
      _errorTrackingService = errorTrackingService;
      _prefs = await SharedPreferences.getInstance();

      // Load persisted data
      await _loadPersistedData();

      // Start periodic analysis
      _startPeriodicAnalysis();

      _isInitialized = true;

      _monitoringService.logInfo(
        'UXErrorImpactAnalyzer initialized successfully',
      );
    } catch (e, stackTrace) {
      _monitoringService.logError(
        'Failed to initialize UXErrorImpactAnalyzer',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Analyze error impact on user experience
  Future<void> analyzeErrorImpact({
    required String errorId,
    required String userId,
    required String sessionId,
    required String screenName,
    required String errorType,
    required String errorMessage,
    required DateTime errorTimestamp,
    Map<String, dynamic>? errorMetadata,
  }) async {
    if (!_isInitialized) {
      _monitoringService.logError('UXErrorImpactAnalyzer not initialized');
      return;
    }

    try {
      // Get user session context
      final sessionMetrics = _uxMonitoringService.getCurrentSessionMetrics();

      // Determine if session was abandoned due to error
      final sessionAbandoned = await _checkSessionAbandonment(
        sessionId,
        errorTimestamp,
      );

      // Calculate error severity based on context
      final severityScore = _calculateErrorSeverity(
        errorType,
        screenName,
        sessionMetrics,
        errorMetadata,
      );

      // Check for error recovery
      final recoveryInfo = await _analyzeErrorRecovery(
        errorId,
        userId,
        sessionId,
        errorTimestamp,
      );

      // Create error impact analysis
      final impactAnalysis = ErrorImpactAnalysis(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        errorId: errorId,
        userId: userId,
        sessionId: sessionId,
        screenName: screenName,
        errorType: errorType,
        errorMessage: errorMessage,
        errorTimestamp: errorTimestamp,
        sessionAbandoned: sessionAbandoned,
        severityScore: severityScore,
        recoveryAttempted: recoveryInfo['attempted'] as bool,
        recoverySuccessful: recoveryInfo['successful'] as bool,
        recoveryTimeSeconds: recoveryInfo['recovery_time_seconds'] as int?,
        userActionsAfterError: recoveryInfo['user_actions'] as List<String>,
        impactMetrics: _calculateImpactMetrics(
          sessionMetrics,
          sessionAbandoned,
          severityScore,
        ),
        metadata: errorMetadata ?? {},
      );

      // Add to collections
      _errorImpactHistory.add(impactAnalysis);
      _impactsByScreen.putIfAbsent(screenName, () => []).add(impactAnalysis);
      _impactsByErrorType.putIfAbsent(errorType, () => []).add(impactAnalysis);

      // Keep history size manageable
      while (_errorImpactHistory.length > maxImpactHistory) {
        final oldImpact = _errorImpactHistory.removeAt(0);
        _removeFromCollections(oldImpact);
      }

      // Update metrics
      _updateErrorMetrics(impactAnalysis);

      // Save data
      await _saveImpactData();

      // Track to UX monitoring
      await _uxMonitoringService.trackErrorImpact(
        errorId: errorId,
        userId: userId,
        screenName: screenName,
        errorType: errorType,
        errorMessage: errorMessage,
        sessionAbandoned: sessionAbandoned,
        userAction: recoveryInfo['user_actions'].isNotEmpty
            ? recoveryInfo['user_actions'].first
            : null,
        metadata: {
          'severity_score': severityScore,
          'recovery_attempted': recoveryInfo['attempted'],
          'recovery_successful': recoveryInfo['successful'],
          ...?errorMetadata,
        },
      );

      // Track to Firebase Analytics
      await _analyticsService.logEvent(
        'ux_error_impact_analyzed',
        parameters: {
          'error_id': errorId,
          'user_id': userId,
          'session_id': sessionId,
          'screen_name': screenName,
          'error_type': errorType,
          'session_abandoned': sessionAbandoned,
          'severity_score': severityScore,
          'recovery_attempted': recoveryInfo['attempted'],
          'recovery_successful': recoveryInfo['successful'],
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      _monitoringService.logInfo(
        'Error impact analyzed: $errorType on $screenName (severity: ${severityScore.toStringAsFixed(2)})',
      );
    } catch (e, stackTrace) {
      _monitoringService.logError(
        'Failed to analyze error impact',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Get error impact analytics for a screen
  Map<String, dynamic> getScreenErrorImpactAnalytics(String screenName) {
    final screenImpacts = _impactsByScreen[screenName] ?? [];

    if (screenImpacts.isEmpty) {
      return {
        'screen_name': screenName,
        'total_errors': 0,
        'abandonment_rate': 0.0,
        'average_severity': 0.0,
        'recovery_rate': 0.0,
        'has_data': false,
      };
    }

    // Calculate metrics
    final totalErrors = screenImpacts.length;
    final abandonedSessions = screenImpacts
        .where((i) => i.sessionAbandoned)
        .length;
    final abandonmentRate = (abandonedSessions / totalErrors) * 100;

    final averageSeverity =
        screenImpacts.map((i) => i.severityScore).reduce((a, b) => a + b) /
        totalErrors;

    final recoveryAttempts = screenImpacts
        .where((i) => i.recoveryAttempted)
        .length;
    final successfulRecoveries = screenImpacts
        .where((i) => i.recoverySuccessful)
        .length;
    final recoveryRate = recoveryAttempts > 0
        ? (successfulRecoveries / recoveryAttempts) * 100
        : 0.0;

    // Group by error type
    final errorsByType = <String, int>{};
    for (final impact in screenImpacts) {
      errorsByType[impact.errorType] =
          (errorsByType[impact.errorType] ?? 0) + 1;
    }

    return {
      'screen_name': screenName,
      'total_errors': totalErrors,
      'abandonment_rate': abandonmentRate,
      'average_severity': averageSeverity,
      'recovery_rate': recoveryRate,
      'errors_by_type': errorsByType,
      'recent_impacts': screenImpacts.take(5).map((i) => i.toMap()).toList(),
      'has_data': true,
    };
  }

  /// Get overall error impact analytics
  Map<String, dynamic> getOverallErrorImpactAnalytics() {
    if (_errorImpactHistory.isEmpty) {
      return {
        'total_errors': 0,
        'overall_abandonment_rate': 0.0,
        'overall_severity': 0.0,
        'overall_recovery_rate': 0.0,
        'has_data': false,
      };
    }

    final totalErrors = _errorImpactHistory.length;
    final abandonedSessions = _errorImpactHistory
        .where((i) => i.sessionAbandoned)
        .length;
    final overallAbandonmentRate = (abandonedSessions / totalErrors) * 100;

    final overallSeverity =
        _errorImpactHistory
            .map((i) => i.severityScore)
            .reduce((a, b) => a + b) /
        totalErrors;

    final recoveryAttempts = _errorImpactHistory
        .where((i) => i.recoveryAttempted)
        .length;
    final successfulRecoveries = _errorImpactHistory
        .where((i) => i.recoverySuccessful)
        .length;
    final overallRecoveryRate = recoveryAttempts > 0
        ? (successfulRecoveries / recoveryAttempts) * 100
        : 0.0;

    // Get critical screens (high abandonment rate)
    final criticalScreens = _screenAbandonmentRates.entries
        .where((entry) => entry.value > criticalAbandonmentThreshold)
        .map(
          (entry) => {
            'screen_name': entry.key,
            'abandonment_rate': entry.value,
          },
        )
        .toList();

    return {
      'total_errors': totalErrors,
      'overall_abandonment_rate': overallAbandonmentRate,
      'overall_severity': overallSeverity,
      'overall_recovery_rate': overallRecoveryRate,
      'screen_abandonment_rates': _screenAbandonmentRates,
      'error_recovery_rates': _errorRecoveryRates,
      'critical_screens': criticalScreens,
      'error_frequency': _errorFrequency,
      'recent_impacts': _errorImpactHistory
          .take(10)
          .map((i) => i.toMap())
          .toList(),
      'has_data': true,
    };
  }

  /// Get error patterns and trends
  Map<String, dynamic> getErrorPatterns() {
    return {
      'error_frequency': _errorFrequency,
      'error_sequences': _errorSequences,
      'error_severity_scores': _errorSeverityScores,
      'trending_errors': _getTrendingErrors(),
      'error_correlations': _getErrorCorrelations(),
    };
  }

  /// Start periodic analysis
  void _startPeriodicAnalysis() {
    _analysisTimer?.cancel();
    _analysisTimer = Timer.periodic(
      analysisInterval,
      (_) => _performPeriodicAnalysis(),
    );
  }

  /// Perform periodic analysis of error impacts
  Future<void> _performPeriodicAnalysis() async {
    try {
      // Update abandonment rates
      _updateAbandonmentRates();

      // Update recovery rates
      _updateRecoveryRates();

      // Identify trending errors
      _identifyTrendingErrors();

      // Save updated data
      await _saveImpactData();

      _monitoringService.logInfo('Periodic error impact analysis completed');
    } catch (e, stackTrace) {
      _monitoringService.logError(
        'Failed to perform periodic error impact analysis',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Check if session was abandoned due to error
  Future<bool> _checkSessionAbandonment(
    String sessionId,
    DateTime errorTimestamp,
  ) async {
    try {
      // Get current session metrics
      final sessionMetrics = _uxMonitoringService.getCurrentSessionMetrics();

      // If session is still active and it's the current session, not abandoned
      if (sessionMetrics['active'] == true &&
          sessionMetrics['session_id'] == sessionId) {
        return false;
      }

      // Check if there were any user actions after the error
      // This is a simplified check - in a real implementation, you'd check the user journey
      final timeSinceError = DateTime.now().difference(errorTimestamp);

      // If less than 30 seconds have passed and no activity, likely abandoned
      if (timeSinceError.inSeconds < 30) {
        return true;
      }

      // For completed sessions, check if they ended shortly after the error
      return timeSinceError.inMinutes < 2;
    } catch (e) {
      _monitoringService.logError(
        'Failed to check session abandonment',
        error: e,
      );
      return false;
    }
  }

  /// Calculate error severity based on context
  double _calculateErrorSeverity(
    String errorType,
    String screenName,
    Map<String, dynamic> sessionMetrics,
    Map<String, dynamic>? errorMetadata,
  ) {
    double severity = 0.5; // Base severity

    // Error type severity weights
    switch (errorType.toLowerCase()) {
      case 'crash':
      case 'fatal':
        severity += 0.4;
        break;
      case 'network':
      case 'timeout':
        severity += 0.3;
        break;
      case 'validation':
      case 'ui':
        severity += 0.2;
        break;
      case 'warning':
        severity += 0.1;
        break;
    }

    // Screen criticality (payment, booking screens are more critical)
    if (screenName.toLowerCase().contains('payment') ||
        screenName.toLowerCase().contains('booking') ||
        screenName.toLowerCase().contains('checkout')) {
      severity += 0.2;
    }

    // Session context (errors early in session are more severe)
    final sessionDuration = sessionMetrics['duration_seconds'] as int? ?? 0;
    if (sessionDuration < 60) {
      severity += 0.1;
    }

    // Historical frequency (frequent errors are more severe)
    final frequency = _errorFrequency[errorType] ?? 0;
    if (frequency > 10) {
      severity += 0.1;
    }

    return severity.clamp(0.0, 1.0);
  }

  /// Analyze error recovery attempts
  Future<Map<String, dynamic>> _analyzeErrorRecovery(
    String errorId,
    String userId,
    String sessionId,
    DateTime errorTimestamp,
  ) async {
    try {
      // This is a simplified implementation
      // In a real app, you'd analyze user actions after the error

      final userActions = <String>[];
      bool attempted = false;
      bool successful = false;
      int? recoveryTimeSeconds;

      // Check if user performed any actions after the error
      // This would integrate with the user session tracker
      final timeSinceError = DateTime.now().difference(errorTimestamp);

      if (timeSinceError.inSeconds > 5) {
        attempted = true;
        userActions.add('retry_action');

        // If session continued for more than 30 seconds, consider it successful
        if (timeSinceError.inSeconds > 30) {
          successful = true;
          recoveryTimeSeconds = 30;
        }
      }

      return {
        'attempted': attempted,
        'successful': successful,
        'recovery_time_seconds': recoveryTimeSeconds,
        'user_actions': userActions,
      };
    } catch (e) {
      _monitoringService.logError('Failed to analyze error recovery', error: e);
      return {
        'attempted': false,
        'successful': false,
        'recovery_time_seconds': null,
        'user_actions': <String>[],
      };
    }
  }

  /// Calculate impact metrics
  Map<String, dynamic> _calculateImpactMetrics(
    Map<String, dynamic> sessionMetrics,
    bool sessionAbandoned,
    double severityScore,
  ) {
    final sessionDuration = sessionMetrics['duration_seconds'] as int? ?? 0;
    final screenCount = sessionMetrics['screens_visited'] as int? ?? 0;
    final interactionCount = sessionMetrics['total_interactions'] as int? ?? 0;

    return {
      'session_duration_before_error': sessionDuration,
      'screens_visited_before_error': screenCount,
      'interactions_before_error': interactionCount,
      'session_abandoned': sessionAbandoned,
      'severity_score': severityScore,
      'impact_score': _calculateOverallImpactScore(
        sessionAbandoned,
        severityScore,
        sessionDuration,
      ),
    };
  }

  /// Calculate overall impact score
  double _calculateOverallImpactScore(
    bool sessionAbandoned,
    double severityScore,
    int sessionDuration,
  ) {
    double impact = severityScore;

    if (sessionAbandoned) {
      impact += 0.3;
    }

    // Early session errors have higher impact
    if (sessionDuration < 60) {
      impact += 0.2;
    }

    return impact.clamp(0.0, 1.0);
  }

  /// Update error metrics
  void _updateErrorMetrics(ErrorImpactAnalysis impact) {
    // Update error frequency
    _errorFrequency[impact.errorType] =
        (_errorFrequency[impact.errorType] ?? 0) + 1;

    // Update severity scores
    _errorSeverityScores[impact.errorType] = impact.severityScore;

    // Update error sequences (simplified)
    final sequenceKey = '${impact.screenName}_${impact.errorType}';
    _errorSequences.putIfAbsent(sequenceKey, () => []).add(impact.errorMessage);

    // Keep sequences manageable
    if (_errorSequences[sequenceKey]!.length > 10) {
      _errorSequences[sequenceKey]!.removeAt(0);
    }
  }

  /// Update abandonment rates
  void _updateAbandonmentRates() {
    for (final screenName in _impactsByScreen.keys) {
      final screenImpacts = _impactsByScreen[screenName]!;
      final totalErrors = screenImpacts.length;
      final abandonedSessions = screenImpacts
          .where((i) => i.sessionAbandoned)
          .length;

      if (totalErrors > 0) {
        _screenAbandonmentRates[screenName] = abandonedSessions / totalErrors;
      }
    }
  }

  /// Update recovery rates
  void _updateRecoveryRates() {
    for (final errorType in _impactsByErrorType.keys) {
      final typeImpacts = _impactsByErrorType[errorType]!;
      final recoveryAttempts = typeImpacts
          .where((i) => i.recoveryAttempted)
          .length;
      final successfulRecoveries = typeImpacts
          .where((i) => i.recoverySuccessful)
          .length;

      if (recoveryAttempts > 0) {
        _errorRecoveryRates[errorType] =
            successfulRecoveries / recoveryAttempts;
      }
    }
  }

  /// Identify trending errors
  void _identifyTrendingErrors() {
    // Simple trending analysis based on recent frequency
    final recentImpacts = _errorImpactHistory
        .where((i) => DateTime.now().difference(i.errorTimestamp).inHours < 24)
        .toList();

    final recentFrequency = <String, int>{};
    for (final impact in recentImpacts) {
      recentFrequency[impact.errorType] =
          (recentFrequency[impact.errorType] ?? 0) + 1;
    }

    // Log trending errors
    for (final entry in recentFrequency.entries) {
      if (entry.value > 5) {
        _monitoringService.logInfo(
          'Trending error detected: ${entry.key} (${entry.value} occurrences)',
        );
      }
    }
  }

  /// Get trending errors
  List<Map<String, dynamic>> _getTrendingErrors() {
    final recentImpacts = _errorImpactHistory
        .where((i) => DateTime.now().difference(i.errorTimestamp).inHours < 24)
        .toList();

    final recentFrequency = <String, int>{};
    for (final impact in recentImpacts) {
      recentFrequency[impact.errorType] =
          (recentFrequency[impact.errorType] ?? 0) + 1;
    }

    final sortedErrors = recentFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedErrors
        .take(5)
        .map((entry) => {'error_type': entry.key, 'frequency': entry.value})
        .toList();
  }

  /// Get error correlations
  Map<String, dynamic> _getErrorCorrelations() {
    final correlations = <String, List<String>>{};

    // Simple correlation analysis - errors that often occur together
    for (final impact in _errorImpactHistory) {
      final sessionErrors = _errorImpactHistory
          .where((i) => i.sessionId == impact.sessionId && i.id != impact.id)
          .map((i) => i.errorType)
          .toList();

      if (sessionErrors.isNotEmpty) {
        correlations
            .putIfAbsent(impact.errorType, () => [])
            .addAll(sessionErrors);
      }
    }

    return correlations;
  }

  /// Remove impact from collections
  void _removeFromCollections(ErrorImpactAnalysis impact) {
    _impactsByScreen[impact.screenName]?.remove(impact);
    _impactsByErrorType[impact.errorType]?.remove(impact);
  }

  /// Load persisted data
  Future<void> _loadPersistedData() async {
    try {
      // Load error impact history
      final impactJson = _prefs?.getString('error_impact_history');
      if (impactJson != null) {
        final impactList = jsonDecode(impactJson) as List;
        _errorImpactHistory.clear();

        for (final item in impactList) {
          final impact = ErrorImpactAnalysis.fromMap(item);
          _errorImpactHistory.add(impact);
          _impactsByScreen.putIfAbsent(impact.screenName, () => []).add(impact);
          _impactsByErrorType
              .putIfAbsent(impact.errorType, () => [])
              .add(impact);
        }
      }

      // Load abandonment rates
      final abandonmentJson = _prefs?.getString('screen_abandonment_rates');
      if (abandonmentJson != null) {
        final abandonmentData =
            jsonDecode(abandonmentJson) as Map<String, dynamic>;
        _screenAbandonmentRates.clear();
        abandonmentData.forEach((key, value) {
          _screenAbandonmentRates[key] = value as double;
        });
      }

      // Load recovery rates
      final recoveryJson = _prefs?.getString('error_recovery_rates');
      if (recoveryJson != null) {
        final recoveryData = jsonDecode(recoveryJson) as Map<String, dynamic>;
        _errorRecoveryRates.clear();
        recoveryData.forEach((key, value) {
          _errorRecoveryRates[key] = value as double;
        });
      }

      // Load error frequency
      final frequencyJson = _prefs?.getString('error_frequency');
      if (frequencyJson != null) {
        final frequencyData = jsonDecode(frequencyJson) as Map<String, dynamic>;
        _errorFrequency.clear();
        frequencyData.forEach((key, value) {
          _errorFrequency[key] = value as int;
        });
      }

      _monitoringService.logInfo('Error impact data loaded successfully');
    } catch (e, stackTrace) {
      _monitoringService.logError(
        'Failed to load persisted error impact data',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Save impact data
  Future<void> _saveImpactData() async {
    try {
      // Save error impact history
      final impactJson = jsonEncode(
        _errorImpactHistory.map((i) => i.toMap()).toList(),
      );
      await _prefs?.setString('error_impact_history', impactJson);

      // Save abandonment rates
      final abandonmentJson = jsonEncode(_screenAbandonmentRates);
      await _prefs?.setString('screen_abandonment_rates', abandonmentJson);

      // Save recovery rates
      final recoveryJson = jsonEncode(_errorRecoveryRates);
      await _prefs?.setString('error_recovery_rates', recoveryJson);

      // Save error frequency
      final frequencyJson = jsonEncode(_errorFrequency);
      await _prefs?.setString('error_frequency', frequencyJson);
    } catch (e) {
      _monitoringService.logError('Failed to save error impact data', error: e);
    }
  }

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;

  /// Get total error impacts count
  int get totalErrorImpacts => _errorImpactHistory.length;

  /// Dispose resources
  Future<void> dispose() async {
    _analysisTimer?.cancel();
    await _saveImpactData();
    _isInitialized = false;
  }
}

/// Error impact analysis model
class ErrorImpactAnalysis {
  final String id;
  final String errorId;
  final String userId;
  final String sessionId;
  final String screenName;
  final String errorType;
  final String errorMessage;
  final DateTime errorTimestamp;
  final bool sessionAbandoned;
  final double severityScore;
  final bool recoveryAttempted;
  final bool recoverySuccessful;
  final int? recoveryTimeSeconds;
  final List<String> userActionsAfterError;
  final Map<String, dynamic> impactMetrics;
  final Map<String, dynamic> metadata;

  ErrorImpactAnalysis({
    required this.id,
    required this.errorId,
    required this.userId,
    required this.sessionId,
    required this.screenName,
    required this.errorType,
    required this.errorMessage,
    required this.errorTimestamp,
    required this.sessionAbandoned,
    required this.severityScore,
    required this.recoveryAttempted,
    required this.recoverySuccessful,
    this.recoveryTimeSeconds,
    required this.userActionsAfterError,
    required this.impactMetrics,
    required this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'errorId': errorId,
      'userId': userId,
      'sessionId': sessionId,
      'screenName': screenName,
      'errorType': errorType,
      'errorMessage': errorMessage,
      'errorTimestamp': errorTimestamp.toIso8601String(),
      'sessionAbandoned': sessionAbandoned,
      'severityScore': severityScore,
      'recoveryAttempted': recoveryAttempted,
      'recoverySuccessful': recoverySuccessful,
      'recoveryTimeSeconds': recoveryTimeSeconds,
      'userActionsAfterError': userActionsAfterError,
      'impactMetrics': impactMetrics,
      'metadata': metadata,
    };
  }

  factory ErrorImpactAnalysis.fromMap(Map<String, dynamic> map) {
    return ErrorImpactAnalysis(
      id: map['id'],
      errorId: map['errorId'],
      userId: map['userId'],
      sessionId: map['sessionId'],
      screenName: map['screenName'],
      errorType: map['errorType'],
      errorMessage: map['errorMessage'],
      errorTimestamp: DateTime.parse(map['errorTimestamp']),
      sessionAbandoned: map['sessionAbandoned'],
      severityScore: map['severityScore'],
      recoveryAttempted: map['recoveryAttempted'],
      recoverySuccessful: map['recoverySuccessful'],
      recoveryTimeSeconds: map['recoveryTimeSeconds'],
      userActionsAfterError: List<String>.from(map['userActionsAfterError']),
      impactMetrics: Map<String, dynamic>.from(map['impactMetrics']),
      metadata: Map<String, dynamic>.from(map['metadata']),
    );
  }
}
