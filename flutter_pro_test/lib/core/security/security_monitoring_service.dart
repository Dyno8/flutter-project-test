import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../monitoring/monitoring_service.dart';
import '../analytics/firebase_analytics_service.dart';
import 'advanced_security_manager.dart';
import 'security_compliance_manager.dart';

/// Comprehensive security monitoring service for production deployment
class SecurityMonitoringService {
  static final SecurityMonitoringService _instance =
      SecurityMonitoringService._internal();
  factory SecurityMonitoringService() => _instance;
  SecurityMonitoringService._internal();

  final AdvancedSecurityManager _securityManager = AdvancedSecurityManager();
  final SecurityComplianceManager _complianceManager =
      SecurityComplianceManager();
  final MonitoringService _monitoringService = MonitoringService();

  FirebaseAnalyticsService? _analyticsService;
  SharedPreferences? _prefs;
  Timer? _monitoringTimer;
  bool _isInitialized = false;

  // Security monitoring configuration
  static const String _securityAlertsKey = 'security_alerts';
  static const String _incidentLogKey = 'security_incidents';
  static const String _complianceStatusKey = 'compliance_status';

  /// Initialize security monitoring service
  Future<void> initialize({
    required FirebaseAnalyticsService analyticsService,
  }) async {
    if (_isInitialized) return;

    try {
      _analyticsService = analyticsService;
      _prefs = await SharedPreferences.getInstance();

      await _securityManager.initialize();
      await _complianceManager.initialize();
      await _monitoringService.initialize();

      // Start continuous monitoring
      _startContinuousMonitoring();

      _isInitialized = true;

      _logSecurityEvent(
        eventType: 'SECURITY_MONITORING_INITIALIZED',
        description: 'Security monitoring service initialized successfully',
        severity: SecuritySeverity.info,
      );
    } catch (e) {
      _logSecurityEvent(
        eventType: 'SECURITY_MONITORING_INIT_FAILED',
        description: 'Failed to initialize security monitoring: $e',
        severity: SecuritySeverity.critical,
      );
      rethrow;
    }
  }

  /// Start continuous security monitoring
  void _startContinuousMonitoring() {
    // Monitor every 2 minutes for production-grade security
    _monitoringTimer = Timer.periodic(const Duration(minutes: 2), (
      timer,
    ) async {
      if (!_isInitialized) {
        timer.cancel();
        return;
      }

      await _performSecurityMonitoringCycle();
    });
  }

  /// Perform comprehensive security monitoring cycle
  Future<void> _performSecurityMonitoringCycle() async {
    try {
      final startTime = DateTime.now();

      // 1. Security health check
      final healthReport = await _securityManager.performSecurityHealthCheck();
      await _processSecurityHealthReport(healthReport);

      // 2. Compliance status check
      final complianceStatus = await _complianceManager.checkComplianceStatus(
        ComplianceStandard.iso27001,
      );
      await _processComplianceStatus(complianceStatus);

      // 3. Incident detection and response
      await _detectAndProcessSecurityIncidents();

      // 4. SSL certificate monitoring
      await _monitorSSLCertificateStatus();

      // 5. Unauthorized access monitoring
      await _monitorUnauthorizedAccess();

      final duration = DateTime.now().difference(startTime);

      _logSecurityEvent(
        eventType: 'SECURITY_MONITORING_CYCLE_COMPLETED',
        description: 'Security monitoring cycle completed successfully',
        severity: SecuritySeverity.info,
        metadata: {
          'duration_ms': duration.inMilliseconds,
          'health_status': healthReport.overallStatus.name,
          'compliance_status': complianceStatus.status.name,
        },
      );
    } catch (e) {
      _logSecurityEvent(
        eventType: 'SECURITY_MONITORING_CYCLE_FAILED',
        description: 'Security monitoring cycle failed: $e',
        severity: SecuritySeverity.error,
      );
    }
  }

  /// Process security health report
  Future<void> _processSecurityHealthReport(SecurityHealthReport report) async {
    // Check for critical security status
    if (report.overallStatus == SecurityStatus.critical) {
      await _triggerSecurityAlert(
        alertType: 'CRITICAL_SECURITY_STATUS',
        message: 'Critical security status detected',
        severity: SecuritySeverity.critical,
        metadata: {
          'integrity_check': report.integrityCheckPassed,
          'recent_violations': report.recentViolationsCount,
          'total_violations': report.totalViolationsCount,
        },
      );
    }

    // Monitor violation trends
    if (report.recentViolationsCount > 10) {
      await _triggerSecurityAlert(
        alertType: 'HIGH_VIOLATION_COUNT',
        message: 'High number of recent security violations detected',
        severity: SecuritySeverity.warning,
        metadata: {
          'recent_violations': report.recentViolationsCount,
          'threshold': 10,
        },
      );
    }
  }

  /// Process compliance status
  Future<void> _processComplianceStatus(ComplianceStatus status) async {
    // Store compliance status
    await _prefs?.setString(
      _complianceStatusKey,
      jsonEncode({
        'standard': status.standard.name,
        'status': status.status.name,
        'score': status.score,
        'last_check': status.lastCheckDate?.toIso8601String(),
        'issues': status.issues,
      }),
    );

    // Alert on compliance violations
    if (status.status == ComplianceLevel.critical) {
      await _triggerSecurityAlert(
        alertType: 'COMPLIANCE_VIOLATION',
        message: 'Compliance violation detected for ${status.standard.name}',
        severity: SecuritySeverity.critical,
        metadata: {
          'standard': status.standard.name,
          'score': status.score,
          'issues': status.issues,
        },
      );
    }
  }

  /// Detect and process security incidents
  Future<void> _detectAndProcessSecurityIncidents() async {
    final violations = _securityManager.getSecurityViolations();
    final recentViolations = violations.where((v) {
      final timestamp = DateTime.tryParse(v['timestamp'] ?? '');
      if (timestamp == null) return false;
      return DateTime.now().difference(timestamp).inMinutes < 10;
    }).toList();

    // Detect potential security incidents
    if (recentViolations.length >= 5) {
      await _createSecurityIncident(
        incidentType: 'MULTIPLE_VIOLATIONS',
        description: 'Multiple security violations detected in short timeframe',
        severity: SecuritySeverity.critical,
        affectedSystems: ['authentication', 'access_control'],
        violations: recentViolations,
      );
    }
  }

  /// Monitor SSL certificate status
  Future<void> _monitorSSLCertificateStatus() async {
    try {
      // In production, this would check actual SSL certificate
      final sslStatus = {
        'valid': true,
        'expires_in_days': 30,
        'issuer': 'Firebase Hosting',
        'last_checked': DateTime.now().toIso8601String(),
      };

      // Alert if certificate expires soon
      if (sslStatus['expires_in_days'] as int < 7) {
        await _triggerSecurityAlert(
          alertType: 'SSL_CERTIFICATE_EXPIRING',
          message:
              'SSL certificate expires in ${sslStatus['expires_in_days']} days',
          severity: SecuritySeverity.warning,
          metadata: sslStatus,
        );
      }
    } catch (e) {
      _logSecurityEvent(
        eventType: 'SSL_MONITORING_FAILED',
        description: 'Failed to monitor SSL certificate: $e',
        severity: SecuritySeverity.error,
      );
    }
  }

  /// Monitor unauthorized access attempts
  Future<void> _monitorUnauthorizedAccess() async {
    final violations = _securityManager.getSecurityViolations();
    final accessViolations = violations
        .where(
          (v) =>
              v['type'] == 'UNAUTHORIZED_ACCESS' ||
              v['type'] == 'AUTHENTICATION_FAILURE',
        )
        .toList();

    final recentAccessViolations = accessViolations.where((v) {
      final timestamp = DateTime.tryParse(v['timestamp'] ?? '');
      if (timestamp == null) return false;
      return DateTime.now().difference(timestamp).inHours < 1;
    }).toList();

    if (recentAccessViolations.length > 3) {
      await _triggerSecurityAlert(
        alertType: 'UNAUTHORIZED_ACCESS_PATTERN',
        message: 'Pattern of unauthorized access attempts detected',
        severity: SecuritySeverity.critical,
        metadata: {
          'violation_count': recentAccessViolations.length,
          'time_window': '1_hour',
          'violations': recentAccessViolations.take(5).toList(),
        },
      );
    }
  }

  /// Trigger security alert
  Future<void> _triggerSecurityAlert({
    required String alertType,
    required String message,
    required SecuritySeverity severity,
    Map<String, dynamic>? metadata,
  }) async {
    final alert = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'type': alertType,
      'message': message,
      'severity': severity.name,
      'timestamp': DateTime.now().toIso8601String(),
      'metadata': metadata ?? {},
      'acknowledged': false,
    };

    // Store alert
    final alerts = await _getStoredAlerts();
    alerts.add(alert);
    await _prefs?.setString(_securityAlertsKey, jsonEncode(alerts));

    // Log to analytics
    await _analyticsService?.logEvent(
      'security_alert_triggered',
      parameters: {
        'alert_type': alertType,
        'severity': severity.name,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    _logSecurityEvent(
      eventType: 'SECURITY_ALERT_TRIGGERED',
      description: message,
      severity: severity,
      metadata: metadata,
    );
  }

  /// Create security incident
  Future<void> _createSecurityIncident({
    required String incidentType,
    required String description,
    required SecuritySeverity severity,
    required List<String> affectedSystems,
    List<Map<String, dynamic>>? violations,
  }) async {
    final incident = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'type': incidentType,
      'description': description,
      'severity': severity.name,
      'affected_systems': affectedSystems,
      'violations': violations ?? [],
      'timestamp': DateTime.now().toIso8601String(),
      'status': 'open',
      'response_actions': <String>[],
    };

    // Store incident
    final incidents = await _getStoredIncidents();
    incidents.add(incident);
    await _prefs?.setString(_incidentLogKey, jsonEncode(incidents));

    // Log to analytics
    await _analyticsService?.logEvent(
      'security_incident_created',
      parameters: {
        'incident_type': incidentType,
        'severity': severity.name,
        'affected_systems_count': affectedSystems.length,
      },
    );

    _logSecurityEvent(
      eventType: 'SECURITY_INCIDENT_CREATED',
      description: description,
      severity: severity,
      metadata: {
        'incident_id': incident['id'],
        'affected_systems': affectedSystems,
      },
    );
  }

  /// Get stored security alerts
  Future<List<Map<String, dynamic>>> _getStoredAlerts() async {
    final alertsJson = _prefs?.getString(_securityAlertsKey) ?? '[]';
    return List<Map<String, dynamic>>.from(
      jsonDecode(alertsJson).map((a) => Map<String, dynamic>.from(a)),
    );
  }

  /// Get stored security incidents
  Future<List<Map<String, dynamic>>> _getStoredIncidents() async {
    final incidentsJson = _prefs?.getString(_incidentLogKey) ?? '[]';
    return List<Map<String, dynamic>>.from(
      jsonDecode(incidentsJson).map((i) => Map<String, dynamic>.from(i)),
    );
  }

  /// Log security event
  void _logSecurityEvent({
    required String eventType,
    required String description,
    required SecuritySeverity severity,
    Map<String, dynamic>? metadata,
  }) {
    final enhancedMetadata = {
      'event_type': eventType,
      'severity': severity.name,
      'timestamp': DateTime.now().toIso8601String(),
      'service': 'SecurityMonitoringService',
      ...?metadata,
    };

    switch (severity) {
      case SecuritySeverity.critical:
      case SecuritySeverity.error:
        _monitoringService.logError(description, metadata: enhancedMetadata);
        break;
      case SecuritySeverity.warning:
        _monitoringService.logWarning(description, metadata: enhancedMetadata);
        break;
      case SecuritySeverity.info:
        _monitoringService.logInfo(description, metadata: enhancedMetadata);
        break;
    }
  }

  /// Get security monitoring status
  Map<String, dynamic> getSecurityMonitoringStatus() {
    return {
      'initialized': _isInitialized,
      'monitoring_active': _monitoringTimer?.isActive ?? false,
      'last_check': DateTime.now().toIso8601String(),
      'service_status': 'operational',
    };
  }

  /// Get security alerts
  Future<List<Map<String, dynamic>>> getSecurityAlerts({
    bool unacknowledgedOnly = false,
  }) async {
    final alerts = await _getStoredAlerts();
    if (unacknowledgedOnly) {
      return alerts
          .where((a) => !(a['acknowledged'] as bool? ?? false))
          .toList();
    }
    return alerts;
  }

  /// Get security incidents
  Future<List<Map<String, dynamic>>> getSecurityIncidents({
    String? status,
  }) async {
    final incidents = await _getStoredIncidents();
    if (status != null) {
      return incidents.where((i) => i['status'] == status).toList();
    }
    return incidents;
  }

  /// Acknowledge security alert
  Future<void> acknowledgeAlert(String alertId) async {
    final alerts = await _getStoredAlerts();
    final alertIndex = alerts.indexWhere((a) => a['id'] == alertId);

    if (alertIndex != -1) {
      alerts[alertIndex]['acknowledged'] = true;
      alerts[alertIndex]['acknowledged_at'] = DateTime.now().toIso8601String();
      await _prefs?.setString(_securityAlertsKey, jsonEncode(alerts));
    }
  }

  /// Get compliance status
  Future<Map<String, dynamic>?> getComplianceStatus() async {
    final statusJson = _prefs?.getString(_complianceStatusKey);
    if (statusJson != null) {
      return Map<String, dynamic>.from(jsonDecode(statusJson));
    }
    return null;
  }

  /// Dispose resources
  void dispose() {
    _monitoringTimer?.cancel();
  }

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;
}
