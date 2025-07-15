import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/environment_config.dart';
import '../analytics/firebase_analytics_service.dart';
import '../error_tracking/error_tracking_service.dart';
import 'monitoring_service.dart';
import 'production_monitoring_service.dart';

/// Enhanced alerting system for production monitoring
/// Provides automated error detection, incident management, and notification systems
class AlertingSystem {
  static final AlertingSystem _instance = AlertingSystem._internal();
  factory AlertingSystem() => _instance;
  AlertingSystem._internal();

  // Dependencies
  MonitoringService? _monitoringService;
  FirebaseAnalyticsService? _analyticsService;
  ErrorTrackingService? _errorTrackingService;
  ProductionMonitoringService? _productionMonitoring;

  SharedPreferences? _prefs;
  Timer? _alertProcessingTimer;
  Timer? _escalationTimer;

  // Configuration
  static const int alertProcessingIntervalSeconds = 30;
  static const int escalationCheckIntervalSeconds = 300; // 5 minutes
  static const int maxAlertsPerHour = 50;
  static const Duration alertCooldownPeriod = Duration(minutes: 5);
  static const Duration criticalAlertCooldown = Duration(minutes: 1);

  // State tracking
  final List<AlertRule> _alertRules = [];
  final List<AlertIncident> _activeIncidents = [];
  final List<AlertNotification> _notificationQueue = [];
  final Map<String, DateTime> _lastAlertTimes = {};
  final Map<String, int> _alertCounts = {};
  bool _isInitialized = false;
  bool _isProcessingActive = false;

  /// Initialize alerting system
  Future<void> initialize({
    required MonitoringService monitoringService,
    required FirebaseAnalyticsService analyticsService,
    required ErrorTrackingService errorTrackingService,
    required ProductionMonitoringService productionMonitoring,
  }) async {
    if (_isInitialized) return;

    try {
      _prefs = await SharedPreferences.getInstance();

      // Initialize dependencies
      _monitoringService = monitoringService;
      _analyticsService = analyticsService;
      _errorTrackingService = errorTrackingService;
      _productionMonitoring = productionMonitoring;

      // Load configuration and rules
      await _loadAlertRules();
      await _loadActiveIncidents();

      // Set up default alert rules
      _setupDefaultAlertRules();

      // Start alert processing
      _startAlertProcessing();

      _isInitialized = true;
      _isProcessingActive = true;

      _monitoringService?.logInfo(
        'AlertingSystem initialized successfully',
        metadata: {
          'alert_rules_count': _alertRules.length,
          'environment': EnvironmentConfig.environment,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      // Track initialization
      await _analyticsService?.logEvent(
        'alerting_system_initialized',
        parameters: {
          'environment': EnvironmentConfig.environment,
          'alert_rules_count': _alertRules.length,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e, stackTrace) {
      _monitoringService?.logError(
        'Failed to initialize AlertingSystem',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Set up default alert rules
  void _setupDefaultAlertRules() {
    // Critical system health alert
    _alertRules.add(
      AlertRule(
        id: 'system_health_critical',
        name: 'System Health Critical',
        description: 'Triggered when system health is critical',
        condition: AlertCondition.systemHealthCritical,
        severity: AlertSeverity.critical,
        cooldownPeriod: criticalAlertCooldown,
        enabled: true,
        notificationChannels: [
          NotificationChannel.firebase,
          NotificationChannel.console,
        ],
      ),
    );

    // High error rate alert
    _alertRules.add(
      AlertRule(
        id: 'high_error_rate',
        name: 'High Error Rate',
        description: 'Triggered when error rate exceeds threshold',
        condition: AlertCondition.highErrorRate,
        severity: AlertSeverity.high,
        threshold: 0.05, // 5%
        cooldownPeriod: alertCooldownPeriod,
        enabled: true,
        notificationChannels: [
          NotificationChannel.firebase,
          NotificationChannel.console,
        ],
      ),
    );

    // Performance degradation alert
    _alertRules.add(
      AlertRule(
        id: 'performance_degradation',
        name: 'Performance Degradation',
        description: 'Triggered when performance degrades significantly',
        condition: AlertCondition.performanceDegradation,
        severity: AlertSeverity.medium,
        threshold: 3000.0, // 3 seconds
        cooldownPeriod: alertCooldownPeriod,
        enabled: true,
        notificationChannels: [NotificationChannel.firebase],
      ),
    );

    // Memory usage alert
    _alertRules.add(
      AlertRule(
        id: 'high_memory_usage',
        name: 'High Memory Usage',
        description: 'Triggered when memory usage is high',
        condition: AlertCondition.highMemoryUsage,
        severity: AlertSeverity.medium,
        threshold: 512.0, // 512MB
        cooldownPeriod: alertCooldownPeriod,
        enabled: true,
        notificationChannels: [NotificationChannel.firebase],
      ),
    );

    // Security violation alert
    _alertRules.add(
      AlertRule(
        id: 'security_violation',
        name: 'Security Violation',
        description: 'Triggered when security violations are detected',
        condition: AlertCondition.securityViolation,
        severity: AlertSeverity.critical,
        cooldownPeriod: criticalAlertCooldown,
        enabled: true,
        notificationChannels: [
          NotificationChannel.firebase,
          NotificationChannel.console,
        ],
      ),
    );

    // Firebase service failure alert
    _alertRules.add(
      AlertRule(
        id: 'firebase_service_failure',
        name: 'Firebase Service Failure',
        description: 'Triggered when Firebase services fail',
        condition: AlertCondition.firebaseServiceFailure,
        severity: AlertSeverity.high,
        cooldownPeriod: alertCooldownPeriod,
        enabled: true,
        notificationChannels: [
          NotificationChannel.firebase,
          NotificationChannel.console,
        ],
      ),
    );
  }

  /// Start alert processing
  void _startAlertProcessing() {
    // Start alert processing timer
    _alertProcessingTimer?.cancel();
    _alertProcessingTimer = Timer.periodic(
      const Duration(seconds: alertProcessingIntervalSeconds),
      (_) => _processAlerts(),
    );

    // Start escalation timer
    _escalationTimer?.cancel();
    _escalationTimer = Timer.periodic(
      const Duration(seconds: escalationCheckIntervalSeconds),
      (_) => _processEscalations(),
    );
  }

  /// Process alerts
  Future<void> _processAlerts() async {
    if (!_isProcessingActive) return;

    try {
      // Get current system status
      final healthStatus = _productionMonitoring?.getCurrentHealthStatus();
      final errorStats = _monitoringService?.getErrorStats();

      // Check each alert rule
      for (final rule in _alertRules.where((r) => r.enabled)) {
        await _evaluateAlertRule(rule, healthStatus, errorStats);
      }

      // Process notification queue
      await _processNotificationQueue();

      // Clean up old alerts
      _cleanupOldAlerts();
    } catch (e) {
      _monitoringService?.logError('Failed to process alerts', error: e);
    }
  }

  /// Evaluate alert rule
  Future<void> _evaluateAlertRule(
    AlertRule rule,
    Map<String, dynamic>? healthStatus,
    Map<String, dynamic>? errorStats,
  ) async {
    try {
      bool shouldTrigger = false;
      Map<String, dynamic> alertData = {};

      switch (rule.condition) {
        case AlertCondition.systemHealthCritical:
          shouldTrigger = healthStatus?['status'] == 'critical';
          alertData = healthStatus ?? {};
          break;

        case AlertCondition.highErrorRate:
          final errorRate =
              errorStats?['error_rate_per_minute'] as double? ?? 0.0;
          shouldTrigger = errorRate > (rule.threshold ?? 0.05);
          alertData = {
            'error_rate': errorRate,
            'threshold': rule.threshold,
            'error_stats': errorStats,
          };
          break;

        case AlertCondition.performanceDegradation:
          // This would need performance metrics from PerformanceManager
          shouldTrigger = false; // Placeholder
          break;

        case AlertCondition.highMemoryUsage:
          final memoryUsage =
              healthStatus?['checks']?['system']?['checks']?['memory']?['usage_mb']
                  as int? ??
              0;
          shouldTrigger = memoryUsage > (rule.threshold ?? 512);
          alertData = {
            'memory_usage_mb': memoryUsage,
            'threshold_mb': rule.threshold,
          };
          break;

        case AlertCondition.securityViolation:
          // This would check for security violations
          shouldTrigger = false; // Placeholder
          break;

        case AlertCondition.firebaseServiceFailure:
          final firebaseStatus =
              healthStatus?['checks']?['firebase']?['status'] as String?;
          shouldTrigger =
              firebaseStatus == 'error' || firebaseStatus == 'critical';
          alertData = healthStatus?['checks']?['firebase'] ?? {};
          break;
      }

      if (shouldTrigger) {
        await _triggerAlert(rule, alertData);
      }
    } catch (e) {
      _monitoringService?.logError(
        'Failed to evaluate alert rule: ${rule.id}',
        error: e,
      );
    }
  }

  /// Trigger alert
  Future<void> _triggerAlert(
    AlertRule rule,
    Map<String, dynamic> alertData,
  ) async {
    // Check cooldown period
    final lastAlertTime = _lastAlertTimes[rule.id];
    final now = DateTime.now();

    if (lastAlertTime != null) {
      final timeSinceLastAlert = now.difference(lastAlertTime);
      if (timeSinceLastAlert < rule.cooldownPeriod) {
        return; // Skip due to cooldown
      }
    }

    // Check rate limiting
    final currentHour = DateTime(now.year, now.month, now.day, now.hour);
    final hourlyKey = '${rule.id}_${currentHour.millisecondsSinceEpoch}';
    final hourlyCount = _alertCounts[hourlyKey] ?? 0;

    if (hourlyCount >= maxAlertsPerHour) {
      return; // Skip due to rate limiting
    }

    // Create alert incident
    final incident = AlertIncident(
      id: 'incident_${now.millisecondsSinceEpoch}_${rule.id}',
      ruleId: rule.id,
      ruleName: rule.name,
      severity: rule.severity,
      status: IncidentStatus.active,
      createdAt: now,
      alertData: alertData,
      description: rule.description,
    );

    // Add to active incidents
    _activeIncidents.add(incident);

    // Update tracking
    _lastAlertTimes[rule.id] = now;
    _alertCounts[hourlyKey] = hourlyCount + 1;

    // Create notifications
    for (final channel in rule.notificationChannels) {
      final notification = AlertNotification(
        id: 'notification_${now.millisecondsSinceEpoch}_${channel.toString()}',
        incidentId: incident.id,
        channel: channel,
        message: _buildAlertMessage(rule, alertData),
        createdAt: now,
        status: NotificationStatus.pending,
      );

      _notificationQueue.add(notification);
    }

    // Save state
    await _saveActiveIncidents();

    _monitoringService?.logError(
      'ALERT TRIGGERED: ${rule.name}',
      metadata: {
        'rule_id': rule.id,
        'severity': rule.severity.toString(),
        'incident_id': incident.id,
        'alert_data': alertData,
      },
    );

    // Track to Firebase
    await _analyticsService?.logEvent(
      'production_alert_triggered',
      parameters: {
        'rule_id': rule.id,
        'rule_name': rule.name,
        'severity': rule.severity.toString(),
        'incident_id': incident.id,
        'environment': EnvironmentConfig.environment,
        'timestamp': now.toIso8601String(),
      },
    );
  }

  /// Build alert message
  String _buildAlertMessage(AlertRule rule, Map<String, dynamic> alertData) {
    final buffer = StringBuffer();
    buffer.writeln('🚨 ALERT: ${rule.name}');
    buffer.writeln(
      'Severity: ${rule.severity.toString().split('.').last.toUpperCase()}',
    );
    buffer.writeln('Description: ${rule.description}');
    buffer.writeln('Environment: ${EnvironmentConfig.environment}');
    buffer.writeln('Time: ${DateTime.now().toIso8601String()}');

    if (alertData.isNotEmpty) {
      buffer.writeln('Data: ${jsonEncode(alertData)}');
    }

    return buffer.toString();
  }

  /// Process notification queue
  Future<void> _processNotificationQueue() async {
    final pendingNotifications = _notificationQueue
        .where((n) => n.status == NotificationStatus.pending)
        .toList();

    for (final notification in pendingNotifications) {
      try {
        await _sendNotification(notification);
        notification.status = NotificationStatus.sent;
        notification.sentAt = DateTime.now();
      } catch (e) {
        notification.status = NotificationStatus.failed;
        notification.error = e.toString();

        _monitoringService?.logError(
          'Failed to send notification: ${notification.id}',
          error: e,
        );
      }
    }

    // Remove old notifications
    _notificationQueue.removeWhere(
      (n) => n.createdAt.isBefore(
        DateTime.now().subtract(const Duration(hours: 24)),
      ),
    );
  }

  /// Send notification
  Future<void> _sendNotification(AlertNotification notification) async {
    switch (notification.channel) {
      case NotificationChannel.firebase:
        await _sendFirebaseNotification(notification);
        break;
      case NotificationChannel.console:
        await _sendConsoleNotification(notification);
        break;
      case NotificationChannel.email:
        await _sendEmailNotification(notification);
        break;
      case NotificationChannel.slack:
        await _sendSlackNotification(notification);
        break;
    }
  }

  /// Send Firebase notification
  Future<void> _sendFirebaseNotification(AlertNotification notification) async {
    // Track as custom event in Firebase Analytics
    await _analyticsService?.logEvent(
      'alert_notification_sent',
      parameters: {
        'notification_id': notification.id,
        'incident_id': notification.incidentId,
        'channel': 'firebase',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Send console notification
  Future<void> _sendConsoleNotification(AlertNotification notification) async {
    if (kDebugMode) {
      print('🚨 ALERT NOTIFICATION: ${notification.message}');
    }
  }

  /// Send email notification (placeholder)
  Future<void> _sendEmailNotification(AlertNotification notification) async {
    // Placeholder for email notification implementation
    // In production, this would integrate with an email service
  }

  /// Send Slack notification (placeholder)
  Future<void> _sendSlackNotification(AlertNotification notification) async {
    // Placeholder for Slack notification implementation
    // In production, this would integrate with Slack API
  }

  /// Process escalations
  Future<void> _processEscalations() async {
    // Implementation for escalation processing will be added
  }

  /// Clean up old alerts
  void _cleanupOldAlerts() {
    final cutoffTime = DateTime.now().subtract(const Duration(hours: 24));

    // Remove old incidents
    _activeIncidents.removeWhere(
      (incident) =>
          incident.createdAt.isBefore(cutoffTime) &&
          incident.status == IncidentStatus.resolved,
    );

    // Clean up alert counts
    final currentHour = DateTime.now().hour;
    _alertCounts.removeWhere(
      (key, value) => !key.contains(
        '_${DateTime.now().year}${DateTime.now().month}${DateTime.now().day}$currentHour',
      ),
    );
  }

  /// Load alert rules
  Future<void> _loadAlertRules() async {
    // Implementation for loading custom alert rules
  }

  /// Load active incidents
  Future<void> _loadActiveIncidents() async {
    // Implementation for loading active incidents from storage
  }

  /// Save active incidents
  Future<void> _saveActiveIncidents() async {
    try {
      final incidentsJson = jsonEncode(
        _activeIncidents.map((i) => i.toMap()).toList(),
      );
      await _prefs?.setString('active_incidents', incidentsJson);
    } catch (e) {
      _monitoringService?.logError('Failed to save active incidents', error: e);
    }
  }

  /// Get active incidents
  List<AlertIncident> getActiveIncidents() => List.from(_activeIncidents);

  /// Get alert rules
  List<AlertRule> getAlertRules() => List.from(_alertRules);

  /// Check if system is initialized
  bool get isInitialized => _isInitialized;

  /// Dispose resources
  void dispose() {
    _alertProcessingTimer?.cancel();
    _escalationTimer?.cancel();
    _isProcessingActive = false;
  }
}

/// Alert rule data class
class AlertRule {
  final String id;
  final String name;
  final String description;
  final AlertCondition condition;
  final AlertSeverity severity;
  final double? threshold;
  final Duration cooldownPeriod;
  final bool enabled;
  final List<NotificationChannel> notificationChannels;

  AlertRule({
    required this.id,
    required this.name,
    required this.description,
    required this.condition,
    required this.severity,
    this.threshold,
    required this.cooldownPeriod,
    required this.enabled,
    required this.notificationChannels,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'condition': condition.toString(),
      'severity': severity.toString(),
      'threshold': threshold,
      'cooldown_period_ms': cooldownPeriod.inMilliseconds,
      'enabled': enabled,
      'notification_channels': notificationChannels
          .map((c) => c.toString())
          .toList(),
    };
  }
}

/// Alert incident data class
class AlertIncident {
  final String id;
  final String ruleId;
  final String ruleName;
  final AlertSeverity severity;
  IncidentStatus status;
  final DateTime createdAt;
  DateTime? resolvedAt;
  final Map<String, dynamic> alertData;
  final String description;

  AlertIncident({
    required this.id,
    required this.ruleId,
    required this.ruleName,
    required this.severity,
    required this.status,
    required this.createdAt,
    this.resolvedAt,
    required this.alertData,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'rule_id': ruleId,
      'rule_name': ruleName,
      'severity': severity.toString(),
      'status': status.toString(),
      'created_at': createdAt.toIso8601String(),
      'resolved_at': resolvedAt?.toIso8601String(),
      'alert_data': alertData,
      'description': description,
    };
  }
}

/// Alert notification data class
class AlertNotification {
  final String id;
  final String incidentId;
  final NotificationChannel channel;
  final String message;
  final DateTime createdAt;
  NotificationStatus status;
  DateTime? sentAt;
  String? error;

  AlertNotification({
    required this.id,
    required this.incidentId,
    required this.channel,
    required this.message,
    required this.createdAt,
    required this.status,
    this.sentAt,
    this.error,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'incident_id': incidentId,
      'channel': channel.toString(),
      'message': message,
      'created_at': createdAt.toIso8601String(),
      'status': status.toString(),
      'sent_at': sentAt?.toIso8601String(),
      'error': error,
    };
  }
}

/// Alert condition enumeration
enum AlertCondition {
  systemHealthCritical,
  highErrorRate,
  performanceDegradation,
  highMemoryUsage,
  securityViolation,
  firebaseServiceFailure,
}

/// Alert severity enumeration (reusing from production_monitoring_service.dart)
enum AlertSeverity { low, medium, high, critical }

/// Incident status enumeration
enum IncidentStatus { active, acknowledged, resolved, suppressed }

/// Notification channel enumeration
enum NotificationChannel { firebase, console, email, slack }

/// Notification status enumeration
enum NotificationStatus { pending, sent, failed, cancelled }
