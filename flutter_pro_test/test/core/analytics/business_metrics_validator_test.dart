import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:flutter_pro_test/core/analytics/business_metrics_validator.dart';
import 'package:flutter_pro_test/core/analytics/business_analytics_service.dart';
import 'package:flutter_pro_test/core/analytics/firebase_analytics_service.dart';
import 'package:flutter_pro_test/core/monitoring/monitoring_service.dart';
import 'package:flutter_pro_test/core/performance/performance_manager.dart';

import 'business_metrics_validator_test.mocks.dart';

@GenerateMocks([
  BusinessAnalyticsService,
  FirebaseAnalyticsService,
  MonitoringService,
  PerformanceManager,
])
void main() {
  group('BusinessMetricsValidator', () {
    late BusinessMetricsValidator validator;
    late MockBusinessAnalyticsService mockBusinessAnalytics;
    late MockFirebaseAnalyticsService mockFirebaseAnalytics;
    late MockMonitoringService mockMonitoringService;
    late MockPerformanceManager mockPerformanceManager;

    setUp(() {
      validator = BusinessMetricsValidator();
      // Dispose any previous state
      validator.dispose();

      mockBusinessAnalytics = MockBusinessAnalyticsService();
      mockFirebaseAnalytics = MockFirebaseAnalyticsService();
      mockMonitoringService = MockMonitoringService();
      mockPerformanceManager = MockPerformanceManager();

      // Setup default mock responses
      when(mockBusinessAnalytics.getSessionInfo()).thenReturn({
        'session_id': 'test_session_123',
        'session_duration_seconds': 300,
        'journey_events_count': 5,
        'feature_usage_count': 3,
        'user_id': 'test_user',
        'user_type': 'client',
      });

      when(mockPerformanceManager.getPerformanceStats()).thenReturn({
        'memory_usage_bytes': 50 * 1024 * 1024, // 50MB
        'avg_response_time_ms': 75,
        'total_errors': 2,
        'total_events': 100,
      });

      when(mockBusinessAnalytics.currentUserId).thenReturn('test_user');
      when(mockBusinessAnalytics.currentUserType).thenReturn('client');
      when(
        mockBusinessAnalytics.trackUserAction(
          actionName: anyNamed('actionName'),
          category: anyNamed('category'),
        ),
      ).thenAnswer((_) async {});
    });

    group('Initialization', () {
      test('should initialize successfully with all dependencies', () async {
        // Act
        await validator.initialize(
          businessAnalytics: mockBusinessAnalytics,
          firebaseAnalytics: mockFirebaseAnalytics,
          monitoringService: mockMonitoringService,
          performanceManager: mockPerformanceManager,
        );

        // Assert
        expect(validator.isInitialized, isTrue);
        verify(
          mockMonitoringService.logInfo(any, metadata: anyNamed('metadata')),
        ).called(greaterThan(0));
      });

      test('should not reinitialize if already initialized', () async {
        // Arrange
        await validator.initialize(
          businessAnalytics: mockBusinessAnalytics,
          firebaseAnalytics: mockFirebaseAnalytics,
          monitoringService: mockMonitoringService,
          performanceManager: mockPerformanceManager,
        );

        // Act
        await validator.initialize(
          businessAnalytics: mockBusinessAnalytics,
          firebaseAnalytics: mockFirebaseAnalytics,
          monitoringService: mockMonitoringService,
          performanceManager: mockPerformanceManager,
        );

        // Assert
        expect(validator.isInitialized, isTrue);
      });

      test('should handle initialization errors gracefully', () async {
        // Arrange
        when(
          mockBusinessAnalytics.getSessionInfo(),
        ).thenThrow(Exception('Test error'));

        // Act & Assert
        // The initialization should complete but log an error during baseline establishment
        await validator.initialize(
          businessAnalytics: mockBusinessAnalytics,
          firebaseAnalytics: mockFirebaseAnalytics,
          monitoringService: mockMonitoringService,
          performanceManager: mockPerformanceManager,
        );

        // Verify error was logged during baseline establishment
        verify(
          mockMonitoringService.logError(any, metadata: anyNamed('metadata')),
        ).called(greaterThan(0));
      });
    });

    group('Manual Validation', () {
      setUp(() async {
        await validator.initialize(
          businessAnalytics: mockBusinessAnalytics,
          firebaseAnalytics: mockFirebaseAnalytics,
          monitoringService: mockMonitoringService,
          performanceManager: mockPerformanceManager,
        );
      });

      test('should perform manual validation successfully', () async {
        // Act
        final result = await validator.performManualValidation();

        // Assert
        expect(result, isA<ValidationResult>());
        expect(result.validationId, isNotEmpty);
        expect(result.timestamp, isA<DateTime>());
        expect(result.overallScore, isA<double>());
        expect(result.status, isA<ValidationStatus>());
        expect(result.checks, isNotEmpty);
      });

      test('should validate data consistency', () async {
        // Act
        final result = await validator.performManualValidation();

        // Assert
        expect(result.checks.containsKey('data_consistency'), isTrue);
        final consistencyCheck = result.checks['data_consistency']!;
        expect(consistencyCheck.checkName, equals('Data Consistency'));
        expect(consistencyCheck.score, isA<double>());
        expect(consistencyCheck.passed, isA<bool>());
      });

      test('should validate real-time synchronization', () async {
        // Act
        final result = await validator.performManualValidation();

        // Assert
        expect(result.checks.containsKey('realtime_sync'), isTrue);
        final syncCheck = result.checks['realtime_sync']!;
        expect(syncCheck.checkName, equals('Real-time Synchronization'));
        expect(syncCheck.score, isA<double>());
      });

      test('should validate metric accuracy', () async {
        // Act
        final result = await validator.performManualValidation();

        // Assert
        expect(result.checks.containsKey('metric_accuracy'), isTrue);
        final accuracyCheck = result.checks['metric_accuracy']!;
        expect(accuracyCheck.checkName, equals('Metric Accuracy'));
        expect(accuracyCheck.score, isA<double>());
      });

      test('should validate performance impact', () async {
        // Act
        final result = await validator.performManualValidation();

        // Assert
        expect(result.checks.containsKey('performance_impact'), isTrue);
        final performanceCheck = result.checks['performance_impact']!;
        expect(performanceCheck.checkName, equals('Performance Impact'));
        expect(performanceCheck.score, isA<double>());
      });

      test('should validate business logic', () async {
        // Act
        final result = await validator.performManualValidation();

        // Assert
        expect(result.checks.containsKey('business_logic'), isTrue);
        final logicCheck = result.checks['business_logic']!;
        expect(logicCheck.checkName, equals('Business Logic'));
        expect(logicCheck.score, isA<double>());
      });

      test('should validate trend analysis', () async {
        // Act
        final result = await validator.performManualValidation();

        // Assert
        expect(result.checks.containsKey('trend_analysis'), isTrue);
        final trendCheck = result.checks['trend_analysis']!;
        expect(trendCheck.checkName, equals('Trend Analysis'));
        expect(trendCheck.score, isA<double>());
      });
    });

    group('Data Consistency Validation', () {
      setUp(() async {
        await validator.initialize(
          businessAnalytics: mockBusinessAnalytics,
          firebaseAnalytics: mockFirebaseAnalytics,
          monitoringService: mockMonitoringService,
          performanceManager: mockPerformanceManager,
        );
      });

      test('should pass with valid data', () async {
        // Act
        final result = await validator.performManualValidation();
        final consistencyCheck = result.checks['data_consistency']!;

        // Assert
        expect(consistencyCheck.passed, isTrue);
        expect(consistencyCheck.score, equals(100.0));
        expect(consistencyCheck.issues, isEmpty);
      });

      test('should detect null session ID', () async {
        // Arrange
        when(mockBusinessAnalytics.getSessionInfo()).thenReturn({
          'session_id': null,
          'session_duration_seconds': 300,
          'journey_events_count': 5,
        });

        // Act
        final result = await validator.performManualValidation();
        final consistencyCheck = result.checks['data_consistency']!;

        // Assert
        expect(consistencyCheck.passed, isFalse);
        expect(consistencyCheck.issues, contains('Session ID is null'));
      });

      test('should detect negative session duration', () async {
        // Arrange
        when(mockBusinessAnalytics.getSessionInfo()).thenReturn({
          'session_id': 'test_session',
          'session_duration_seconds': -100,
          'journey_events_count': 5,
        });

        // Act
        final result = await validator.performManualValidation();
        final consistencyCheck = result.checks['data_consistency']!;

        // Assert
        expect(consistencyCheck.passed, isFalse);
        expect(
          consistencyCheck.issues,
          contains('Negative session duration detected'),
        );
      });

      test('should detect negative error count', () async {
        // Arrange
        when(mockPerformanceManager.getPerformanceStats()).thenReturn({
          'total_errors': -5,
          'memory_usage_bytes': 50 * 1024 * 1024,
          'avg_response_time_ms': 75,
        });

        // Act
        final result = await validator.performManualValidation();
        final consistencyCheck = result.checks['data_consistency']!;

        // Assert
        expect(consistencyCheck.passed, isFalse);
        expect(
          consistencyCheck.issues,
          contains('Negative error count detected'),
        );
      });
    });

    group('Performance Impact Validation', () {
      setUp(() async {
        await validator.initialize(
          businessAnalytics: mockBusinessAnalytics,
          firebaseAnalytics: mockFirebaseAnalytics,
          monitoringService: mockMonitoringService,
          performanceManager: mockPerformanceManager,
        );
      });

      test('should pass with acceptable performance metrics', () async {
        // Act
        final result = await validator.performManualValidation();
        final performanceCheck = result.checks['performance_impact']!;

        // Assert
        expect(performanceCheck.passed, isTrue);
        expect(performanceCheck.score, equals(100.0));
        expect(performanceCheck.issues, isEmpty);
      });

      test('should detect excessive memory usage', () async {
        // Arrange
        when(mockPerformanceManager.getPerformanceStats()).thenReturn({
          'memory_usage_bytes': 150 * 1024 * 1024, // 150MB
          'avg_response_time_ms': 75,
          'total_errors': 2,
        });

        // Act
        final result = await validator.performManualValidation();
        final performanceCheck = result.checks['performance_impact']!;

        // Assert
        expect(performanceCheck.passed, isFalse);
        expect(
          performanceCheck.issues,
          contains('Analytics memory usage exceeds 100MB'),
        );
      });

      test('should detect response time degradation', () async {
        // Arrange
        when(mockPerformanceManager.getPerformanceStats()).thenReturn({
          'memory_usage_bytes': 50 * 1024 * 1024,
          'avg_response_time_ms': 150, // Exceeds 100ms threshold
          'total_errors': 2,
        });

        // Act
        final result = await validator.performManualValidation();
        final performanceCheck = result.checks['performance_impact']!;

        // Assert
        expect(performanceCheck.passed, isFalse);
        expect(
          performanceCheck.issues,
          contains('Analytics causing response time degradation'),
        );
      });
    });

    group('Business Logic Validation', () {
      setUp(() async {
        await validator.initialize(
          businessAnalytics: mockBusinessAnalytics,
          firebaseAnalytics: mockFirebaseAnalytics,
          monitoringService: mockMonitoringService,
          performanceManager: mockPerformanceManager,
        );
      });

      test('should pass with consistent business logic', () async {
        // Act
        final result = await validator.performManualValidation();
        final logicCheck = result.checks['business_logic']!;

        // Assert
        expect(logicCheck.passed, isTrue);
        expect(logicCheck.score, equals(100.0));
        expect(logicCheck.issues, isEmpty);
      });

      test('should detect active session with no journey events', () async {
        // Arrange
        when(mockBusinessAnalytics.getSessionInfo()).thenReturn({
          'session_id': 'test_session',
          'session_duration_seconds': 300, // Active session
          'journey_events_count': 0, // No events
        });

        // Act
        final result = await validator.performManualValidation();
        final logicCheck = result.checks['business_logic']!;

        // Assert
        expect(logicCheck.passed, isFalse);
        expect(
          logicCheck.issues,
          contains('Active session with no journey events'),
        );
      });

      test('should detect user ID without user type', () async {
        // Arrange
        when(mockBusinessAnalytics.currentUserId).thenReturn('test_user');
        when(mockBusinessAnalytics.currentUserType).thenReturn(null);

        // Act
        final result = await validator.performManualValidation();
        final logicCheck = result.checks['business_logic']!;

        // Assert
        expect(logicCheck.passed, isFalse);
        expect(
          logicCheck.issues,
          contains('User ID set but user type missing'),
        );
      });
    });

    group('Validation History', () {
      setUp(() async {
        await validator.initialize(
          businessAnalytics: mockBusinessAnalytics,
          firebaseAnalytics: mockFirebaseAnalytics,
          monitoringService: mockMonitoringService,
          performanceManager: mockPerformanceManager,
        );
      });

      test('should store validation results in history', () async {
        // Act
        await validator.performManualValidation();
        await validator.performManualValidation();

        // Assert
        final history = validator.getValidationHistory();
        expect(history.length, equals(2));
        expect(history.first, isA<ValidationResult>());
        expect(history.last, isA<ValidationResult>());
      });

      test('should return latest validation result', () async {
        // Act
        final result1 = await validator.performManualValidation();
        await Future.delayed(const Duration(milliseconds: 10));
        final result2 = await validator.performManualValidation();

        // Assert
        final latest = validator.getLatestValidation();
        expect(latest, isNotNull);
        expect(latest!.validationId, equals(result2.validationId));
        expect(latest.timestamp.isAfter(result1.timestamp), isTrue);
      });

      test('should provide validation summary', () async {
        // Act
        await validator.performManualValidation();

        // Assert
        final summary = validator.getValidationSummary();
        expect(summary['is_initialized'], isTrue);
        expect(summary['total_validations'], equals(1));
        expect(summary['latest_score'], isA<double>());
        expect(summary['latest_status'], isA<String>());
        expect(summary['last_validation'], isA<String>());
      });
    });

    group('Error Handling', () {
      setUp(() async {
        await validator.initialize(
          businessAnalytics: mockBusinessAnalytics,
          firebaseAnalytics: mockFirebaseAnalytics,
          monitoringService: mockMonitoringService,
          performanceManager: mockPerformanceManager,
        );
      });

      test('should handle validation errors gracefully', () async {
        // Arrange
        when(
          mockBusinessAnalytics.getSessionInfo(),
        ).thenThrow(Exception('Test error'));

        // Act
        final result = await validator.performManualValidation();

        // Assert
        expect(result.status, equals(ValidationStatus.failed));
        expect(
          result.overallScore,
          lessThan(50.0),
        ); // Should be low due to errors
        // Note: The validator handles individual check errors gracefully,
        // so it won't have a global error but will have failed checks
      });

      test('should log validation errors', () async {
        // Arrange
        when(
          mockBusinessAnalytics.getSessionInfo(),
        ).thenThrow(Exception('Test error'));

        // Act
        await validator.performManualValidation();

        // Assert
        // The validator logs warnings for failed validations, not errors
        verify(
          mockMonitoringService.logWarning(any, metadata: anyNamed('metadata')),
        ).called(greaterThan(0));
      });
    });

    group('Resource Management', () {
      test('should dispose resources properly', () {
        // Act
        validator.dispose();

        // Assert
        expect(validator.isInitialized, isFalse);
      });

      test('should clear validation history on dispose', () async {
        // Arrange
        await validator.initialize(
          businessAnalytics: mockBusinessAnalytics,
          firebaseAnalytics: mockFirebaseAnalytics,
          monitoringService: mockMonitoringService,
          performanceManager: mockPerformanceManager,
        );
        await validator.performManualValidation();

        // Act
        validator.dispose();

        // Assert
        expect(validator.getValidationHistory(), isEmpty);
      });
    });
  });
}
