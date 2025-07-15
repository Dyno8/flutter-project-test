import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_pro_test/core/monitoring/ux_monitoring_service.dart';
import 'package:flutter_pro_test/core/analytics/firebase_analytics_service.dart';
import 'package:flutter_pro_test/core/analytics/business_analytics_service.dart';
import 'package:flutter_pro_test/core/monitoring/monitoring_service.dart';

import 'ux_monitoring_service_test.mocks.dart';

@GenerateMocks([
  FirebaseAnalyticsService,
  BusinessAnalyticsService,
  MonitoringService,
  SharedPreferences,
])
void main() {
  group('UXMonitoringService', () {
    late UXMonitoringService uxMonitoringService;
    late MockFirebaseAnalyticsService mockAnalyticsService;
    late MockBusinessAnalyticsService mockBusinessAnalyticsService;
    late MockMonitoringService mockMonitoringService;
    late MockSharedPreferences mockSharedPreferences;

    setUp(() {
      uxMonitoringService = UXMonitoringService();
      mockAnalyticsService = MockFirebaseAnalyticsService();
      mockBusinessAnalyticsService = MockBusinessAnalyticsService();
      mockMonitoringService = MockMonitoringService();
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
        mockBusinessAnalyticsService.trackEngagement(
          engagementType: anyNamed('engagementType'),
          parameters: anyNamed('parameters'),
        ),
      ).thenAnswer((_) async {});
    });

    group('initialization', () {
      test('should initialize successfully', () async {
        // Act
        await uxMonitoringService.initialize(
          analyticsService: mockAnalyticsService,
          businessAnalyticsService: mockBusinessAnalyticsService,
          monitoringService: mockMonitoringService,
        );

        // Assert
        expect(uxMonitoringService.isInitialized, isTrue);
        expect(uxMonitoringService.isTrackingActive, isTrue);
        verify(
          mockMonitoringService.logInfo(
            'UX Monitoring Service initialized successfully',
          ),
        ).called(1);
      });

      test('should not initialize twice', () async {
        // Arrange
        await uxMonitoringService.initialize(
          analyticsService: mockAnalyticsService,
          businessAnalyticsService: mockBusinessAnalyticsService,
          monitoringService: mockMonitoringService,
        );

        // Act
        await uxMonitoringService.initialize(
          analyticsService: mockAnalyticsService,
          businessAnalyticsService: mockBusinessAnalyticsService,
          monitoringService: mockMonitoringService,
        );

        // Assert
        verify(
          mockMonitoringService.logInfo(
            'UX Monitoring Service initialized successfully',
          ),
        ).called(1);
      });

      test('should handle initialization failure', () async {
        // Arrange
        when(
          mockAnalyticsService.logEvent(
            any,
            parameters: anyNamed('parameters'),
          ),
        ).thenThrow(Exception('Analytics error'));

        // Act & Assert
        expect(
          () => uxMonitoringService.initialize(
            analyticsService: mockAnalyticsService,
            businessAnalyticsService: mockBusinessAnalyticsService,
            monitoringService: mockMonitoringService,
          ),
          throwsException,
        );
      });
    });

    group('journey tracking', () {
      setUp(() async {
        await uxMonitoringService.initialize(
          analyticsService: mockAnalyticsService,
          businessAnalyticsService: mockBusinessAnalyticsService,
          monitoringService: mockMonitoringService,
        );
      });

      test('should track journey event successfully', () async {
        // Act
        await uxMonitoringService.trackJourneyEvent(
          eventType: 'screen_view',
          screenName: 'home_screen',
          action: 'view',
          metadata: {'test': 'data'},
        );

        // Assert
        verify(
          mockAnalyticsService.logEvent(
            'user_journey_event',
            parameters: anyNamed('parameters'),
          ),
        ).called(1);
        verify(
          mockMonitoringService.logInfo(
            'Journey event tracked: screen_view on home_screen',
          ),
        ).called(1);
      });

      test('should not track when not initialized', () async {
        // Arrange
        final uninitializedService = UXMonitoringService();

        // Act
        await uninitializedService.trackJourneyEvent(
          eventType: 'screen_view',
          screenName: 'home_screen',
        );

        // Assert
        verifyNever(
          mockAnalyticsService.logEvent(
            any,
            parameters: anyNamed('parameters'),
          ),
        );
      });

      test('should handle tracking errors gracefully', () async {
        // Arrange
        when(
          mockAnalyticsService.logEvent(
            any,
            parameters: anyNamed('parameters'),
          ),
        ).thenThrow(Exception('Tracking error'));

        // Act
        await uxMonitoringService.trackJourneyEvent(
          eventType: 'screen_view',
          screenName: 'home_screen',
        );

        // Assert
        verify(
          mockMonitoringService.logError(
            'Failed to track journey event',
            error: any,
            stackTrace: any,
          ),
        ).called(1);
      });
    });

    group('feedback collection', () {
      setUp(() async {
        await uxMonitoringService.initialize(
          analyticsService: mockAnalyticsService,
          businessAnalyticsService: mockBusinessAnalyticsService,
          monitoringService: mockMonitoringService,
        );
      });

      test('should collect user feedback successfully', () async {
        // Act
        await uxMonitoringService.collectUserFeedback(
          userId: 'user123',
          screenName: 'home_screen',
          feedbackType: 'general',
          rating: 5,
          comment: 'Great app!',
          metadata: {'source': 'prompt'},
        );

        // Assert
        verify(
          mockAnalyticsService.logEvent(
            'user_feedback_collected',
            parameters: anyNamed('parameters'),
          ),
        ).called(1);
        verify(
          mockMonitoringService.logInfo(
            'User feedback collected: general (5/5) on home_screen',
          ),
        ).called(1);
      });

      test('should handle feedback collection without comment', () async {
        // Act
        await uxMonitoringService.collectUserFeedback(
          userId: 'user123',
          screenName: 'home_screen',
          feedbackType: 'usability',
          rating: 3,
        );

        // Assert
        verify(
          mockAnalyticsService.logEvent(
            'user_feedback_collected',
            parameters: anyNamed('parameters'),
          ),
        ).called(1);
      });
    });

    group('error impact tracking', () {
      setUp(() async {
        await uxMonitoringService.initialize(
          analyticsService: mockAnalyticsService,
          businessAnalyticsService: mockBusinessAnalyticsService,
          monitoringService: mockMonitoringService,
        );
      });

      test('should track error impact successfully', () async {
        // Act
        await uxMonitoringService.trackErrorImpact(
          errorId: 'error123',
          userId: 'user123',
          screenName: 'payment_screen',
          errorType: 'network',
          errorMessage: 'Connection timeout',
          sessionAbandoned: false,
          userAction: 'retry',
          metadata: {'retry_count': 1},
        );

        // Assert
        verify(
          mockAnalyticsService.logEvent(
            'ux_error_impact',
            parameters: anyNamed('parameters'),
          ),
        ).called(1);
        verify(
          mockMonitoringService.logError(
            'UX error impact tracked: network on payment_screen',
            metadata: any,
          ),
        ).called(1);
      });

      test('should handle session abandonment', () async {
        // Act
        await uxMonitoringService.trackErrorImpact(
          errorId: 'error456',
          userId: 'user123',
          screenName: 'checkout_screen',
          errorType: 'validation',
          errorMessage: 'Invalid input',
          sessionAbandoned: true,
        );

        // Assert
        verify(
          mockAnalyticsService.logEvent(
            'ux_error_impact',
            parameters: anyNamed('parameters'),
          ),
        ).called(1);
      });
    });

    group('analytics retrieval', () {
      setUp(() async {
        await uxMonitoringService.initialize(
          analyticsService: mockAnalyticsService,
          businessAnalyticsService: mockBusinessAnalyticsService,
          monitoringService: mockMonitoringService,
        );
      });

      test('should return current session metrics', () {
        // Act
        final metrics = uxMonitoringService.getCurrentSessionMetrics();

        // Assert
        expect(metrics, isA<Map<String, dynamic>>());
        expect(metrics.containsKey('session_id'), isTrue);
        expect(metrics.containsKey('active'), isTrue);
      });

      test('should return feedback analytics', () {
        // Act
        final analytics = uxMonitoringService.getFeedbackAnalytics();

        // Assert
        expect(analytics, isA<Map<String, dynamic>>());
        expect(analytics.containsKey('total_feedback'), isTrue);
        expect(analytics.containsKey('average_rating'), isTrue);
        expect(analytics.containsKey('feedback_by_type'), isTrue);
      });

      test('should return error impact analytics', () {
        // Act
        final analytics = uxMonitoringService.getErrorImpactAnalytics();

        // Assert
        expect(analytics, isA<Map<String, dynamic>>());
        expect(analytics.containsKey('total_errors'), isTrue);
        expect(analytics.containsKey('abandonment_rate'), isTrue);
        expect(analytics.containsKey('error_types'), isTrue);
      });

      test('should return funnel analytics', () {
        // Act
        final analytics = uxMonitoringService.getFunnelAnalytics();

        // Assert
        expect(analytics, isA<Map<String, dynamic>>());
        expect(analytics.containsKey('funnels'), isTrue);
        expect(analytics.containsKey('total_funnels'), isTrue);
      });
    });

    group('funnel analysis', () {
      setUp(() async {
        await uxMonitoringService.initialize(
          analyticsService: mockAnalyticsService,
          businessAnalyticsService: mockBusinessAnalyticsService,
          monitoringService: mockMonitoringService,
        );
      });

      test('should update funnel analysis successfully', () async {
        // Act
        await uxMonitoringService.updateFunnelAnalysis(
          funnelId: 'user_registration',
          stepId: 'landing',
          userId: 'user123',
          completed: true,
          timeSpent: const Duration(seconds: 30),
        );

        // Assert
        verify(
          mockAnalyticsService.logEvent(
            'funnel_step_event',
            parameters: anyNamed('parameters'),
          ),
        ).called(1);
      });

      test('should handle invalid funnel ID', () async {
        // Act
        await uxMonitoringService.updateFunnelAnalysis(
          funnelId: 'invalid_funnel',
          stepId: 'step1',
          userId: 'user123',
        );

        // Assert - Should not crash, but may log an error
        verify(
          mockMonitoringService.logError(
            'Failed to update funnel analysis',
            error: any,
            stackTrace: any,
          ),
        ).called(1);
      });
    });

    group('disposal', () {
      test('should dispose resources properly', () async {
        // Arrange
        await uxMonitoringService.initialize(
          analyticsService: mockAnalyticsService,
          businessAnalyticsService: mockBusinessAnalyticsService,
          monitoringService: mockMonitoringService,
        );

        // Act
        await uxMonitoringService.dispose();

        // Assert
        expect(uxMonitoringService.isInitialized, isFalse);
        expect(uxMonitoringService.isTrackingActive, isFalse);
      });
    });
  });
}
