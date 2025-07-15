import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_pro_test/core/monitoring/ux_error_impact_analyzer.dart';
import 'package:flutter_pro_test/core/monitoring/ux_monitoring_service.dart';
import 'package:flutter_pro_test/core/analytics/firebase_analytics_service.dart';
import 'package:flutter_pro_test/core/monitoring/monitoring_service.dart';
import 'package:flutter_pro_test/core/error_tracking/error_tracking_service.dart';

import 'ux_error_impact_analyzer_test.mocks.dart';

@GenerateMocks([
  UXMonitoringService,
  FirebaseAnalyticsService,
  MonitoringService,
  ErrorTrackingService,
  SharedPreferences,
])
void main() {
  group('UXErrorImpactAnalyzer', () {
    late UXErrorImpactAnalyzer errorImpactAnalyzer;
    late MockUXMonitoringService mockUXMonitoringService;
    late MockFirebaseAnalyticsService mockAnalyticsService;
    late MockMonitoringService mockMonitoringService;
    late MockErrorTrackingService mockErrorTrackingService;
    late MockSharedPreferences mockSharedPreferences;

    setUp(() {
      errorImpactAnalyzer = UXErrorImpactAnalyzer();
      mockUXMonitoringService = MockUXMonitoringService();
      mockAnalyticsService = MockFirebaseAnalyticsService();
      mockMonitoringService = MockMonitoringService();
      mockErrorTrackingService = MockErrorTrackingService();
      mockSharedPreferences = MockSharedPreferences();

      // Setup SharedPreferences mock
      SharedPreferences.setMockInitialValues({});
      when(mockSharedPreferences.getString(any)).thenReturn(null);
      when(
        mockSharedPreferences.setString(any, any),
      ).thenAnswer((_) async => true);

      // Setup basic mock behaviors
      when(mockMonitoringService.logInfo(any)).thenReturn(null);
      when(
        mockMonitoringService.logError(
          any,
          error: anyNamed('error'),
          stackTrace: anyNamed('stackTrace'),
        ),
      ).thenReturn(null);
      when(
        mockAnalyticsService.logEvent(any, parameters: anyNamed('parameters')),
      ).thenAnswer((_) async {});
      when(
        mockErrorTrackingService.trackError(
          errorType: anyNamed('errorType'),
          errorMessage: anyNamed('errorMessage'),
          error: any,
          stackTrace: anyNamed('stackTrace'),
          userId: anyNamed('userId'),
          screenName: anyNamed('screenName'),
          userAction: anyNamed('userAction'),
          metadata: anyNamed('metadata'),
          severity: anyNamed('severity'),
          fatal: anyNamed('fatal'),
        ),
      ).thenAnswer((_) async {});
      when(
        mockUXMonitoringService.trackErrorImpact(
          errorId: anyNamed('errorId'),
          userId: anyNamed('userId'),
          screenName: anyNamed('screenName'),
          errorType: anyNamed('errorType'),
          errorMessage: anyNamed('errorMessage'),
          sessionAbandoned: anyNamed('sessionAbandoned'),
          userAction: anyNamed('userAction'),
          metadata: anyNamed('metadata'),
        ),
      ).thenAnswer((_) async {});

      // Setup UX monitoring service mock
      when(mockUXMonitoringService.getCurrentSessionMetrics()).thenReturn({
        'active': true,
        'session_id': 'session123',
        'duration_seconds': 120,
        'screens_visited': 3,
        'total_interactions': 15,
      });
    });

    group('initialization', () {
      test('should initialize successfully', () async {
        // Act
        await errorImpactAnalyzer.initialize(
          uxMonitoringService: mockUXMonitoringService,
          analyticsService: mockAnalyticsService,
          monitoringService: mockMonitoringService,
          errorTrackingService: mockErrorTrackingService,
        );

        // Assert
        expect(errorImpactAnalyzer.isInitialized, isTrue);
        verify(
          mockMonitoringService.logInfo(
            'UXErrorImpactAnalyzer initialized successfully',
          ),
        ).called(1);
      });

      test('should not initialize twice', () async {
        // Arrange
        await errorImpactAnalyzer.initialize(
          uxMonitoringService: mockUXMonitoringService,
          analyticsService: mockAnalyticsService,
          monitoringService: mockMonitoringService,
          errorTrackingService: mockErrorTrackingService,
        );

        // Act
        await errorImpactAnalyzer.initialize(
          uxMonitoringService: mockUXMonitoringService,
          analyticsService: mockAnalyticsService,
          monitoringService: mockMonitoringService,
          errorTrackingService: mockErrorTrackingService,
        );

        // Assert
        verify(
          mockMonitoringService.logInfo(
            'UXErrorImpactAnalyzer initialized successfully',
          ),
        ).called(1);
      });
    });

    group('error impact analysis', () {
      setUp(() async {
        await errorImpactAnalyzer.initialize(
          uxMonitoringService: mockUXMonitoringService,
          analyticsService: mockAnalyticsService,
          monitoringService: mockMonitoringService,
          errorTrackingService: mockErrorTrackingService,
        );
      });

      test('should analyze error impact successfully', () async {
        // Act
        await errorImpactAnalyzer.analyzeErrorImpact(
          errorId: 'error123',
          userId: 'user123',
          sessionId: 'session123',
          screenName: 'payment_screen',
          errorType: 'network',
          errorMessage: 'Connection timeout',
          errorTimestamp: DateTime.now(),
          errorMetadata: {'retry_count': 1},
        );

        // Assert
        expect(errorImpactAnalyzer.totalErrorImpacts, equals(1));
        verify(
          mockUXMonitoringService.trackErrorImpact(
            errorId: 'error123',
            userId: 'user123',
            screenName: 'payment_screen',
            errorType: 'network',
            errorMessage: 'Connection timeout',
            sessionAbandoned: any,
            userAction: anyNamed('userAction'),
            metadata: anyNamed('metadata'),
          ),
        ).called(1);
        verify(
          mockAnalyticsService.logEvent(
            'ux_error_impact_analyzed',
            parameters: anyNamed('parameters'),
          ),
        ).called(1);
      });

      test('should handle critical errors with high severity', () async {
        // Act
        await errorImpactAnalyzer.analyzeErrorImpact(
          errorId: 'error456',
          userId: 'user123',
          sessionId: 'session123',
          screenName: 'payment_screen',
          errorType: 'crash',
          errorMessage: 'Application crashed',
          errorTimestamp: DateTime.now(),
        );

        // Assert
        expect(errorImpactAnalyzer.totalErrorImpacts, equals(1));
        verify(
          mockMonitoringService.logError(
            'UX error impact tracked: crash on payment_screen',
            metadata: any,
          ),
        ).called(1);
      });

      test('should handle session abandonment', () async {
        // Arrange
        when(
          mockUXMonitoringService.getCurrentSessionMetrics(),
        ).thenReturn({'active': false, 'session_id': 'session123'});

        // Act
        await errorImpactAnalyzer.analyzeErrorImpact(
          errorId: 'error789',
          userId: 'user123',
          sessionId: 'session123',
          screenName: 'checkout_screen',
          errorType: 'validation',
          errorMessage: 'Invalid payment method',
          errorTimestamp: DateTime.now().subtract(const Duration(seconds: 10)),
        );

        // Assert
        expect(errorImpactAnalyzer.totalErrorImpacts, equals(1));
      });

      test('should not analyze when not initialized', () async {
        // Arrange
        final uninitializedAnalyzer = UXErrorImpactAnalyzer();

        // Act
        await uninitializedAnalyzer.analyzeErrorImpact(
          errorId: 'error123',
          userId: 'user123',
          sessionId: 'session123',
          screenName: 'home_screen',
          errorType: 'ui',
          errorMessage: 'Button not responding',
          errorTimestamp: DateTime.now(),
        );

        // Assert
        expect(uninitializedAnalyzer.totalErrorImpacts, equals(0));
        verify(
          mockMonitoringService.logError(
            'UXErrorImpactAnalyzer not initialized',
          ),
        ).called(1);
      });

      test('should handle analysis errors gracefully', () async {
        // Arrange
        when(
          mockUXMonitoringService.trackErrorImpact(
            errorId: any,
            userId: any,
            screenName: any,
            errorType: any,
            errorMessage: any,
            sessionAbandoned: any,
            userAction: anyNamed('userAction'),
            metadata: anyNamed('metadata'),
          ),
        ).thenThrow(Exception('Tracking error'));

        // Act
        await errorImpactAnalyzer.analyzeErrorImpact(
          errorId: 'error123',
          userId: 'user123',
          sessionId: 'session123',
          screenName: 'home_screen',
          errorType: 'ui',
          errorMessage: 'Button not responding',
          errorTimestamp: DateTime.now(),
        );

        // Assert
        verify(
          mockMonitoringService.logError(
            'Failed to analyze error impact',
            error: any,
            stackTrace: any,
          ),
        ).called(1);
      });
    });

    group('analytics retrieval', () {
      setUp(() async {
        await errorImpactAnalyzer.initialize(
          uxMonitoringService: mockUXMonitoringService,
          analyticsService: mockAnalyticsService,
          monitoringService: mockMonitoringService,
          errorTrackingService: mockErrorTrackingService,
        );

        // Add some test error impacts
        await errorImpactAnalyzer.analyzeErrorImpact(
          errorId: 'error1',
          userId: 'user123',
          sessionId: 'session123',
          screenName: 'home_screen',
          errorType: 'network',
          errorMessage: 'Connection failed',
          errorTimestamp: DateTime.now(),
        );
        await errorImpactAnalyzer.analyzeErrorImpact(
          errorId: 'error2',
          userId: 'user456',
          sessionId: 'session456',
          screenName: 'home_screen',
          errorType: 'ui',
          errorMessage: 'Button not responding',
          errorTimestamp: DateTime.now(),
        );
      });

      test('should return screen error impact analytics', () {
        // Act
        final analytics = errorImpactAnalyzer.getScreenErrorImpactAnalytics(
          'home_screen',
        );

        // Assert
        expect(analytics, isA<Map<String, dynamic>>());
        expect(analytics['screen_name'], equals('home_screen'));
        expect(analytics['total_errors'], equals(2));
        expect(analytics['has_data'], isTrue);
        expect(analytics['errors_by_type'], isA<Map<String, int>>());
        expect(analytics['recent_impacts'], isA<List>());
      });

      test('should return empty analytics for screen with no errors', () {
        // Act
        final analytics = errorImpactAnalyzer.getScreenErrorImpactAnalytics(
          'unknown_screen',
        );

        // Assert
        expect(analytics['screen_name'], equals('unknown_screen'));
        expect(analytics['total_errors'], equals(0));
        expect(analytics['has_data'], isFalse);
      });

      test('should return overall error impact analytics', () {
        // Act
        final analytics = errorImpactAnalyzer.getOverallErrorImpactAnalytics();

        // Assert
        expect(analytics, isA<Map<String, dynamic>>());
        expect(analytics['total_errors'], equals(2));
        expect(analytics['has_data'], isTrue);
        expect(
          analytics['screen_abandonment_rates'],
          isA<Map<String, double>>(),
        );
        expect(analytics['error_recovery_rates'], isA<Map<String, double>>());
        expect(analytics['error_frequency'], isA<Map<String, int>>());
      });

      test('should return empty analytics when no errors', () {
        // Arrange
        final emptyAnalyzer = UXErrorImpactAnalyzer();

        // Act
        final analytics = emptyAnalyzer.getOverallErrorImpactAnalytics();

        // Assert
        expect(analytics['total_errors'], equals(0));
        expect(analytics['has_data'], isFalse);
      });

      test('should return error patterns', () {
        // Act
        final patterns = errorImpactAnalyzer.getErrorPatterns();

        // Assert
        expect(patterns, isA<Map<String, dynamic>>());
        expect(patterns.containsKey('error_frequency'), isTrue);
        expect(patterns.containsKey('error_sequences'), isTrue);
        expect(patterns.containsKey('error_severity_scores'), isTrue);
        expect(patterns.containsKey('trending_errors'), isTrue);
      });
    });

    group('severity calculation', () {
      setUp(() async {
        await errorImpactAnalyzer.initialize(
          uxMonitoringService: mockUXMonitoringService,
          analyticsService: mockAnalyticsService,
          monitoringService: mockMonitoringService,
          errorTrackingService: mockErrorTrackingService,
        );
      });

      test('should assign high severity to crash errors', () async {
        // Act
        await errorImpactAnalyzer.analyzeErrorImpact(
          errorId: 'crash_error',
          userId: 'user123',
          sessionId: 'session123',
          screenName: 'home_screen',
          errorType: 'crash',
          errorMessage: 'Application crashed',
          errorTimestamp: DateTime.now(),
        );

        // Assert
        final analytics = errorImpactAnalyzer.getOverallErrorImpactAnalytics();
        expect(analytics['overall_severity'], greaterThan(0.8));
      });

      test('should assign higher severity to payment screen errors', () async {
        // Act
        await errorImpactAnalyzer.analyzeErrorImpact(
          errorId: 'payment_error',
          userId: 'user123',
          sessionId: 'session123',
          screenName: 'payment_screen',
          errorType: 'network',
          errorMessage: 'Payment failed',
          errorTimestamp: DateTime.now(),
        );

        // Assert
        final analytics = errorImpactAnalyzer.getScreenErrorImpactAnalytics(
          'payment_screen',
        );
        expect(analytics['average_severity'], greaterThan(0.5));
      });

      test('should assign lower severity to warning errors', () async {
        // Act
        await errorImpactAnalyzer.analyzeErrorImpact(
          errorId: 'warning_error',
          userId: 'user123',
          sessionId: 'session123',
          screenName: 'home_screen',
          errorType: 'warning',
          errorMessage: 'Minor issue detected',
          errorTimestamp: DateTime.now(),
        );

        // Assert
        final analytics = errorImpactAnalyzer.getScreenErrorImpactAnalytics(
          'home_screen',
        );
        expect(analytics['average_severity'], lessThan(0.8));
      });
    });

    group('data persistence', () {
      setUp(() async {
        await errorImpactAnalyzer.initialize(
          uxMonitoringService: mockUXMonitoringService,
          analyticsService: mockAnalyticsService,
          monitoringService: mockMonitoringService,
          errorTrackingService: mockErrorTrackingService,
        );
      });

      test('should save error impact data', () async {
        // Act
        await errorImpactAnalyzer.analyzeErrorImpact(
          errorId: 'error123',
          userId: 'user123',
          sessionId: 'session123',
          screenName: 'home_screen',
          errorType: 'network',
          errorMessage: 'Connection failed',
          errorTimestamp: DateTime.now(),
        );

        // Assert
        verify(
          mockSharedPreferences.setString('error_impact_history', any),
        ).called(1);
        verify(
          mockSharedPreferences.setString('screen_abandonment_rates', any),
        ).called(1);
        verify(
          mockSharedPreferences.setString('error_recovery_rates', any),
        ).called(1);
        verify(
          mockSharedPreferences.setString('error_frequency', any),
        ).called(1);
      });

      test(
        'should load persisted error impact data on initialization',
        () async {
          // Arrange
          const impactJson = '''[{
          "id": "1",
          "errorId": "error123",
          "userId": "user123",
          "sessionId": "session123",
          "screenName": "home_screen",
          "errorType": "network",
          "errorMessage": "Connection failed",
          "errorTimestamp": "2023-01-01T00:00:00.000Z",
          "sessionAbandoned": false,
          "severityScore": 0.7,
          "recoveryAttempted": true,
          "recoverySuccessful": false,
          "recoveryTimeSeconds": null,
          "userActionsAfterError": ["retry_action"],
          "impactMetrics": {},
          "metadata": {}
        }]''';
          when(
            mockSharedPreferences.getString('error_impact_history'),
          ).thenReturn(impactJson);

          // Act
          final newAnalyzer = UXErrorImpactAnalyzer();
          await newAnalyzer.initialize(
            uxMonitoringService: mockUXMonitoringService,
            analyticsService: mockAnalyticsService,
            monitoringService: mockMonitoringService,
            errorTrackingService: mockErrorTrackingService,
          );

          // Assert
          expect(newAnalyzer.totalErrorImpacts, equals(1));
        },
      );
    });

    group('disposal', () {
      test('should dispose resources properly', () async {
        // Arrange
        await errorImpactAnalyzer.initialize(
          uxMonitoringService: mockUXMonitoringService,
          analyticsService: mockAnalyticsService,
          monitoringService: mockMonitoringService,
          errorTrackingService: mockErrorTrackingService,
        );

        // Act
        await errorImpactAnalyzer.dispose();

        // Assert
        expect(errorImpactAnalyzer.isInitialized, isFalse);
        verify(
          mockSharedPreferences.setString(any, any),
        ).called(greaterThan(0));
      });
    });
  });
}
