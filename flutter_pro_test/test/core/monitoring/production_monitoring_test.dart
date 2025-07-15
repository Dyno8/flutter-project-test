import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_pro_test/core/monitoring/production_monitoring_service.dart';
import 'package:flutter_pro_test/core/monitoring/alerting_system.dart';
import 'package:flutter_pro_test/core/monitoring/performance_validation_service.dart';
import 'package:flutter_pro_test/core/monitoring/health_check_endpoint.dart';
import 'package:flutter_pro_test/core/monitoring/monitoring_service.dart';
import 'package:flutter_pro_test/core/analytics/firebase_analytics_service.dart';
import 'package:flutter_pro_test/core/error_tracking/error_tracking_service.dart';
import 'package:flutter_pro_test/core/performance/performance_manager.dart';
import 'package:flutter_pro_test/core/security/advanced_security_manager.dart';

// Generate mocks
@GenerateMocks([
  MonitoringService,
  FirebaseAnalyticsService,
  ErrorTrackingService,
  PerformanceManager,
  AdvancedSecurityManager,
])
import 'production_monitoring_test.mocks.dart';

void main() {
  group('Production Monitoring System Tests', () {
    late ProductionMonitoringService productionMonitoring;
    late AlertingSystem alertingSystem;
    late PerformanceValidationService performanceValidation;
    late HealthCheckEndpoint healthCheckEndpoint;

    late MockMonitoringService mockMonitoringService;
    late MockFirebaseAnalyticsService mockAnalyticsService;
    late MockErrorTrackingService mockErrorTrackingService;
    late MockPerformanceManager mockPerformanceManager;
    late MockAdvancedSecurityManager mockSecurityManager;

    setUpAll(() async {
      // Set up SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
    });

    setUp(() async {
      // Initialize mocks
      mockMonitoringService = MockMonitoringService();
      mockAnalyticsService = MockFirebaseAnalyticsService();
      mockErrorTrackingService = MockErrorTrackingService();
      mockPerformanceManager = MockPerformanceManager();
      mockSecurityManager = MockAdvancedSecurityManager();

      // Initialize services
      productionMonitoring = ProductionMonitoringService();
      alertingSystem = AlertingSystem();
      performanceValidation = PerformanceValidationService();
      healthCheckEndpoint = HealthCheckEndpoint();

      // Set up mock behaviors
      when(mockAnalyticsService.isInitialized).thenReturn(true);
      when(mockErrorTrackingService.isInitialized).thenReturn(true);
      when(mockMonitoringService.getErrorStats()).thenReturn({
        'total_errors': 0,
        'recent_errors_1h': 0,
        'unique_errors': 0,
        'error_rate_per_minute': 0.0,
      });
      when(mockPerformanceManager.getPerformanceStats()).thenReturn({
        'cache_size': 10,
        'cache_hit_rate': 0.8,
        'memory_usage_bytes': 100 * 1024 * 1024, // 100MB
        'total_events': 50,
      });
    });

    group('ProductionMonitoringService', () {
      test('should initialize successfully', () async {
        // Act
        await productionMonitoring.initialize(
          baseMonitoringService: mockMonitoringService,
          analyticsService: mockAnalyticsService,
          errorTrackingService: mockErrorTrackingService,
          performanceManager: mockPerformanceManager,
          securityManager: mockSecurityManager,
        );

        // Assert
        expect(productionMonitoring.isInitialized, isTrue);
        expect(productionMonitoring.isMonitoringActive, isTrue);

        // Verify initialization was logged
        verify(
          mockMonitoringService.logInfo(
            'ProductionMonitoringService initialized successfully',
            metadata: anyNamed('metadata'),
          ),
        ).called(1);
      });

      test('should perform health checks', () async {
        // Arrange
        await productionMonitoring.initialize(
          baseMonitoringService: mockMonitoringService,
          analyticsService: mockAnalyticsService,
          errorTrackingService: mockErrorTrackingService,
          performanceManager: mockPerformanceManager,
          securityManager: mockSecurityManager,
        );

        // Wait for initial health check
        await Future.delayed(const Duration(milliseconds: 100));

        // Act
        final healthStatus = productionMonitoring.getCurrentHealthStatus();

        // Assert
        expect(healthStatus, isNotNull);
        expect(healthStatus['status'], isNotNull);
        expect(healthStatus['timestamp'], isNotNull);
      });

      test('should track health check history', () async {
        // Arrange
        await productionMonitoring.initialize(
          baseMonitoringService: mockMonitoringService,
          analyticsService: mockAnalyticsService,
          errorTrackingService: mockErrorTrackingService,
          performanceManager: mockPerformanceManager,
          securityManager: mockSecurityManager,
        );

        // Wait for health checks to run
        await Future.delayed(const Duration(milliseconds: 200));

        // Act
        final healthHistory = productionMonitoring.getHealthCheckHistory(
          limit: 10,
        );

        // Assert
        expect(healthHistory, isNotNull);
        expect(healthHistory, isA<List<Map<String, dynamic>>>());
      });

      test('should get recent alerts', () async {
        // Arrange
        await productionMonitoring.initialize(
          baseMonitoringService: mockMonitoringService,
          analyticsService: mockAnalyticsService,
          errorTrackingService: mockErrorTrackingService,
          performanceManager: mockPerformanceManager,
          securityManager: mockSecurityManager,
        );

        // Act
        final recentAlerts = productionMonitoring.getRecentAlerts(limit: 5);

        // Assert
        expect(recentAlerts, isNotNull);
        expect(recentAlerts, isA<List<Map<String, dynamic>>>());
      });
    });

    group('AlertingSystem', () {
      test('should initialize with default alert rules', () async {
        // Act
        await alertingSystem.initialize(
          monitoringService: mockMonitoringService,
          analyticsService: mockAnalyticsService,
          errorTrackingService: mockErrorTrackingService,
          productionMonitoring: productionMonitoring,
        );

        // Assert
        expect(alertingSystem.isInitialized, isTrue);

        final alertRules = alertingSystem.getAlertRules();
        expect(alertRules, isNotEmpty);
        expect(alertRules.length, greaterThan(3)); // Should have default rules

        // Verify default rules exist
        final ruleIds = alertRules.map((r) => r.id).toList();
        expect(ruleIds, contains('system_health_critical'));
        expect(ruleIds, contains('high_error_rate'));
        expect(ruleIds, contains('performance_degradation'));
      });

      test('should track active incidents', () async {
        // Arrange
        await alertingSystem.initialize(
          monitoringService: mockMonitoringService,
          analyticsService: mockAnalyticsService,
          errorTrackingService: mockErrorTrackingService,
          productionMonitoring: productionMonitoring,
        );

        // Act
        final activeIncidents = alertingSystem.getActiveIncidents();

        // Assert
        expect(activeIncidents, isNotNull);
        expect(activeIncidents, isA<List<AlertIncident>>());
      });
    });

    group('PerformanceValidationService', () {
      test('should initialize with SLA requirements', () async {
        // Act
        await performanceValidation.initialize(
          monitoringService: mockMonitoringService,
          analyticsService: mockAnalyticsService,
          performanceManager: mockPerformanceManager,
          alertingSystem: alertingSystem,
        );

        // Assert
        expect(performanceValidation.isInitialized, isTrue);
        expect(performanceValidation.isValidationActive, isTrue);

        // Verify SLA requirements are set
        expect(PerformanceValidationService.maxLoadTimeMs, equals(3000.0));
        expect(
          PerformanceValidationService.maxApiResponseTimeMs,
          equals(500.0),
        );
        expect(PerformanceValidationService.minCacheHitRate, equals(0.7));
      });

      test('should track performance metrics', () async {
        // Arrange
        await performanceValidation.initialize(
          monitoringService: mockMonitoringService,
          analyticsService: mockAnalyticsService,
          performanceManager: mockPerformanceManager,
          alertingSystem: alertingSystem,
        );

        // Wait for validation to run
        await Future.delayed(const Duration(milliseconds: 100));

        // Act
        final performanceMetrics = performanceValidation
            .getCurrentPerformanceMetrics();

        // Assert
        expect(performanceMetrics, isNotNull);
        expect(performanceMetrics, isA<Map<String, dynamic>>());
      });

      test('should get validation history', () async {
        // Arrange
        await performanceValidation.initialize(
          monitoringService: mockMonitoringService,
          analyticsService: mockAnalyticsService,
          performanceManager: mockPerformanceManager,
          alertingSystem: alertingSystem,
        );

        // Wait for validations to run
        await Future.delayed(const Duration(milliseconds: 200));

        // Act
        final validationHistory = performanceValidation.getValidationHistory(
          limit: 10,
        );

        // Assert
        expect(validationHistory, isNotNull);
        expect(validationHistory, isA<List<PerformanceValidationResult>>());
      });
    });

    group('HealthCheckEndpoint', () {
      test('should initialize successfully', () async {
        // Arrange
        await productionMonitoring.initialize(
          baseMonitoringService: mockMonitoringService,
          analyticsService: mockAnalyticsService,
          errorTrackingService: mockErrorTrackingService,
          performanceManager: mockPerformanceManager,
          securityManager: mockSecurityManager,
        );

        // Act
        await healthCheckEndpoint.initialize(
          productionMonitoring: productionMonitoring,
          baseMonitoring: mockMonitoringService,
        );

        // Assert
        expect(healthCheckEndpoint.isInitialized, isTrue);
      });

      test('should perform manual health check', () async {
        // Arrange
        await productionMonitoring.initialize(
          baseMonitoringService: mockMonitoringService,
          analyticsService: mockAnalyticsService,
          errorTrackingService: mockErrorTrackingService,
          performanceManager: mockPerformanceManager,
          securityManager: mockSecurityManager,
        );

        await healthCheckEndpoint.initialize(
          productionMonitoring: productionMonitoring,
          baseMonitoring: mockMonitoringService,
        );

        // Act
        final healthCheckResult = await healthCheckEndpoint
            .performHealthCheck();

        // Assert
        expect(healthCheckResult, isNotNull);
        expect(healthCheckResult['success'], isNotNull);
        expect(healthCheckResult['timestamp'], isNotNull);

        if (healthCheckResult['success'] == true) {
          expect(healthCheckResult['health'], isNotNull);
        }
      });
    });

    group('Integration Tests', () {
      test('should initialize all monitoring services together', () async {
        // Act - Initialize all services
        await productionMonitoring.initialize(
          baseMonitoringService: mockMonitoringService,
          analyticsService: mockAnalyticsService,
          errorTrackingService: mockErrorTrackingService,
          performanceManager: mockPerformanceManager,
          securityManager: mockSecurityManager,
        );

        await alertingSystem.initialize(
          monitoringService: mockMonitoringService,
          analyticsService: mockAnalyticsService,
          errorTrackingService: mockErrorTrackingService,
          productionMonitoring: productionMonitoring,
        );

        await performanceValidation.initialize(
          monitoringService: mockMonitoringService,
          analyticsService: mockAnalyticsService,
          performanceManager: mockPerformanceManager,
          alertingSystem: alertingSystem,
        );

        await healthCheckEndpoint.initialize(
          productionMonitoring: productionMonitoring,
          baseMonitoring: mockMonitoringService,
        );

        // Allow services to fully start
        await Future.delayed(const Duration(milliseconds: 50));

        // Assert - All services should be initialized
        expect(productionMonitoring.isInitialized, isTrue);
        expect(alertingSystem.isInitialized, isTrue);
        expect(performanceValidation.isInitialized, isTrue);
        expect(healthCheckEndpoint.isInitialized, isTrue);

        // Verify monitoring is active
        expect(productionMonitoring.isMonitoringActive, isTrue);
        expect(performanceValidation.isValidationActive, isTrue);
      });

      test('should handle service disposal properly', () async {
        // Arrange - Initialize services
        await productionMonitoring.initialize(
          baseMonitoringService: mockMonitoringService,
          analyticsService: mockAnalyticsService,
          errorTrackingService: mockErrorTrackingService,
          performanceManager: mockPerformanceManager,
          securityManager: mockSecurityManager,
        );

        await alertingSystem.initialize(
          monitoringService: mockMonitoringService,
          analyticsService: mockAnalyticsService,
          errorTrackingService: mockErrorTrackingService,
          productionMonitoring: productionMonitoring,
        );

        // Act - Dispose services
        productionMonitoring.dispose();
        alertingSystem.dispose();
        performanceValidation.dispose();
        healthCheckEndpoint.dispose();

        // Assert - Services should be properly disposed
        expect(productionMonitoring.isMonitoringActive, isFalse);
        expect(performanceValidation.isValidationActive, isFalse);
        expect(healthCheckEndpoint.isInitialized, isFalse);
      });
    });

    tearDown(() {
      // Clean up services
      productionMonitoring.dispose();
      alertingSystem.dispose();
      performanceValidation.dispose();
      healthCheckEndpoint.dispose();
    });
  });
}
