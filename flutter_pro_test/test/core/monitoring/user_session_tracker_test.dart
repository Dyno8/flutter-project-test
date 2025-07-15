import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_pro_test/core/monitoring/user_session_tracker.dart';
import 'package:flutter_pro_test/core/monitoring/ux_monitoring_service.dart';
import 'package:flutter_pro_test/core/analytics/firebase_analytics_service.dart';
import 'package:flutter_pro_test/core/monitoring/monitoring_service.dart';

import 'user_session_tracker_test.mocks.dart';

@GenerateMocks([
  UXMonitoringService,
  FirebaseAnalyticsService,
  MonitoringService,
  SharedPreferences,
])
void main() {
  group('UserSessionTracker - Basic Functionality Tests', () {
    late UserSessionTracker sessionTracker;
    late MockUXMonitoringService mockUXMonitoringService;
    late MockFirebaseAnalyticsService mockAnalyticsService;
    late MockMonitoringService mockMonitoringService;
    late MockSharedPreferences mockSharedPreferences;

    setUp(() {
      sessionTracker = UserSessionTracker();
      mockUXMonitoringService = MockUXMonitoringService();
      mockAnalyticsService = MockFirebaseAnalyticsService();
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
        mockUXMonitoringService.trackJourneyEvent(
          eventType: anyNamed('eventType'),
          screenName: anyNamed('screenName'),
          action: anyNamed('action'),
          metadata: anyNamed('metadata'),
        ),
      ).thenAnswer((_) async {});
    });

    group('initialization', () {
      test('should initialize successfully', () async {
        // Act
        await sessionTracker.initialize(
          uxMonitoringService: mockUXMonitoringService,
          analyticsService: mockAnalyticsService,
          monitoringService: mockMonitoringService,
        );

        // Assert
        expect(sessionTracker.isInitialized, isTrue);
      });

      test('should not initialize twice', () async {
        // Arrange
        await sessionTracker.initialize(
          uxMonitoringService: mockUXMonitoringService,
          analyticsService: mockAnalyticsService,
          monitoringService: mockMonitoringService,
        );

        // Act
        await sessionTracker.initialize(
          uxMonitoringService: mockUXMonitoringService,
          analyticsService: mockAnalyticsService,
          monitoringService: mockMonitoringService,
        );

        // Assert - Should still be initialized
        expect(sessionTracker.isInitialized, isTrue);
      });
    });

    group('session management', () {
      setUp(() async {
        await sessionTracker.initialize(
          uxMonitoringService: mockUXMonitoringService,
          analyticsService: mockAnalyticsService,
          monitoringService: mockMonitoringService,
        );
      });

      test('should start session successfully', () async {
        // Act
        await sessionTracker.startSession(
          userId: 'user123',
          userType: 'client',
        );

        // Assert
        expect(sessionTracker.currentSessionId, isNotNull);
        expect(sessionTracker.currentUserId, equals('user123'));
      });

      test('should end previous session when starting new one', () async {
        // Arrange
        await sessionTracker.startSession(
          userId: 'user123',
          userType: 'client',
        );
        final firstSessionId = sessionTracker.currentSessionId;

        // Act
        await sessionTracker.startSession(
          userId: 'user456',
          userType: 'partner',
        );

        // Assert
        expect(sessionTracker.currentSessionId, isNot(equals(firstSessionId)));
        expect(sessionTracker.currentUserId, equals('user456'));
      });

      test('should end session successfully', () async {
        // Arrange
        await sessionTracker.startSession(
          userId: 'user123',
          userType: 'client',
        );

        // Act
        await sessionTracker.endSession();

        // Assert
        expect(sessionTracker.currentSessionId, isNull);
        verify(
          mockAnalyticsService.logEvent(
            'session_ended',
            parameters: anyNamed('parameters'),
          ),
        ).called(1);
        verify(mockMonitoringService.logInfo('User session ended')).called(1);
      });

      test('should handle session timeout', () async {
        // Arrange
        await sessionTracker.startSession(
          userId: 'user123',
          userType: 'client',
        );

        // Act
        await sessionTracker.endSession(timeout: true);

        // Assert
        verify(
          mockAnalyticsService.logEvent(
            'session_ended',
            parameters: anyNamed('parameters'),
          ),
        ).called(1);
        verify(
          mockMonitoringService.logInfo('User session ended (timeout)'),
        ).called(1);
      });
    });

    group('screen tracking', () {
      setUp(() async {
        await sessionTracker.initialize(
          uxMonitoringService: mockUXMonitoringService,
          analyticsService: mockAnalyticsService,
          monitoringService: mockMonitoringService,
        );
        await sessionTracker.startSession(
          userId: 'user123',
          userType: 'client',
        );
      });

      test('should track screen view successfully', () async {
        // Act
        await sessionTracker.trackScreenView(
          screenName: 'home_screen',
          screenClass: 'HomeScreen',
          parameters: {'source': 'navigation'},
        );

        // Assert
        verify(
          mockUXMonitoringService.trackJourneyEvent(
            eventType: 'screen_view',
            screenName: 'home_screen',
            metadata: anyNamed('metadata'),
          ),
        ).called(1);
        verify(
          mockAnalyticsService.logScreenView(
            screenName: 'home_screen',
            screenClass: 'HomeScreen',
            parameters: anyNamed('parameters'),
          ),
        ).called(1);
        verify(
          mockMonitoringService.logInfo('Screen view tracked: home_screen'),
        ).called(1);
      });

      test('should track multiple screen views', () async {
        // Act
        await sessionTracker.trackScreenView(screenName: 'home_screen');
        await sessionTracker.trackScreenView(screenName: 'profile_screen');
        await sessionTracker.trackScreenView(screenName: 'settings_screen');

        // Assert
        verify(
          mockUXMonitoringService.trackJourneyEvent(
            eventType: 'screen_view',
            screenName: anyNamed('screenName'),
            metadata: anyNamed('metadata'),
          ),
        ).called(3);
      });

      test('should not track when session not active', () async {
        // Arrange
        await sessionTracker.endSession();

        // Act
        await sessionTracker.trackScreenView(screenName: 'home_screen');

        // Assert
        verifyNever(
          mockUXMonitoringService.trackJourneyEvent(
            eventType: any,
            screenName: any,
            metadata: anyNamed('metadata'),
          ),
        );
      });
    });

    group('interaction tracking', () {
      setUp(() async {
        await sessionTracker.initialize(
          uxMonitoringService: mockUXMonitoringService,
          analyticsService: mockAnalyticsService,
          monitoringService: mockMonitoringService,
        );
        await sessionTracker.startSession(
          userId: 'user123',
          userType: 'client',
        );
      });

      test('should track tap interaction', () async {
        // Act
        await sessionTracker.trackInteraction(
          interactionType: 'tap',
          elementId: 'login_button',
          action: 'click',
          parameters: {'screen': 'login'},
        );

        // Assert
        verify(
          mockUXMonitoringService.trackJourneyEvent(
            eventType: 'user_action',
            screenName: any,
            action: 'tap',
            metadata: anyNamed('metadata'),
          ),
        ).called(1);
      });

      test('should track scroll interaction', () async {
        // Act
        await sessionTracker.trackInteraction(
          interactionType: 'scroll',
          elementId: 'main_list',
          parameters: {'direction': 'down'},
        );

        // Assert
        verify(
          mockUXMonitoringService.trackJourneyEvent(
            eventType: 'user_action',
            screenName: any,
            action: 'scroll',
            metadata: anyNamed('metadata'),
          ),
        ).called(1);
      });

      test('should track text input interaction', () async {
        // Act
        await sessionTracker.trackInteraction(
          interactionType: 'text_input',
          elementId: 'search_field',
          action: 'type',
        );

        // Assert
        verify(
          mockUXMonitoringService.trackJourneyEvent(
            eventType: 'user_action',
            screenName: any,
            action: 'text_input',
            metadata: anyNamed('metadata'),
          ),
        ).called(1);
      });
    });

    group('feature usage tracking', () {
      setUp(() async {
        await sessionTracker.initialize(
          uxMonitoringService: mockUXMonitoringService,
          analyticsService: mockAnalyticsService,
          monitoringService: mockMonitoringService,
        );
        await sessionTracker.startSession(
          userId: 'user123',
          userType: 'client',
        );
      });

      test('should track feature usage successfully', () async {
        // Act
        await sessionTracker.trackFeatureUsage(
          featureName: 'booking_creation',
          category: 'core_feature',
          parameters: {'booking_type': 'cleaning'},
        );

        // Assert
        verify(
          mockUXMonitoringService.trackJourneyEvent(
            eventType: 'feature_used',
            screenName: any,
            action: 'booking_creation',
            metadata: anyNamed('metadata'),
          ),
        ).called(1);
        verify(
          mockMonitoringService.logInfo(
            'Feature usage tracked: booking_creation',
          ),
        ).called(1);
      });

      test('should track multiple feature usages', () async {
        // Act
        await sessionTracker.trackFeatureUsage(featureName: 'search');
        await sessionTracker.trackFeatureUsage(featureName: 'filter');
        await sessionTracker.trackFeatureUsage(featureName: 'sort');

        // Assert
        verify(
          mockUXMonitoringService.trackJourneyEvent(
            eventType: 'feature_used',
            screenName: any,
            action: anyNamed('action'),
            metadata: anyNamed('metadata'),
          ),
        ).called(3);
      });
    });

    group('analytics retrieval', () {
      setUp(() async {
        await sessionTracker.initialize(
          uxMonitoringService: mockUXMonitoringService,
          analyticsService: mockAnalyticsService,
          monitoringService: mockMonitoringService,
        );
        await sessionTracker.startSession(
          userId: 'user123',
          userType: 'client',
        );
      });

      test('should return current session analytics', () {
        // Act
        final analytics = sessionTracker.getCurrentSessionAnalytics();

        // Assert
        expect(analytics, isA<Map<String, dynamic>>());
        expect(analytics['active'], isTrue);
        expect(analytics['session_id'], isNotNull);
        expect(analytics['user_id'], equals('user123'));
        expect(analytics['user_type'], equals('client'));
      });

      test('should return navigation flow analytics', () {
        // Act
        final analytics = sessionTracker.getNavigationFlowAnalytics();

        // Assert
        expect(analytics, isA<Map<String, dynamic>>());
        expect(analytics.containsKey('navigation_flows'), isTrue);
        expect(analytics.containsKey('navigation_history'), isTrue);
        expect(analytics.containsKey('screen_visit_counts'), isTrue);
      });

      test('should return engagement metrics', () {
        // Act
        final metrics = sessionTracker.getEngagementMetrics();

        // Assert
        expect(metrics, isA<Map<String, dynamic>>());
        expect(metrics.containsKey('session_duration_seconds'), isTrue);
        expect(metrics.containsKey('total_taps'), isTrue);
        expect(metrics.containsKey('total_scrolls'), isTrue);
        expect(metrics.containsKey('engagement_rate'), isTrue);
      });

      test('should return inactive session analytics when no session', () {
        // Arrange
        final inactiveTracker = UserSessionTracker();

        // Act
        final analytics = inactiveTracker.getCurrentSessionAnalytics();

        // Assert
        expect(analytics['active'], isFalse);
        expect(analytics['message'], equals('No active session'));
      });
    });

    group('error handling', () {
      setUp(() async {
        await sessionTracker.initialize(
          uxMonitoringService: mockUXMonitoringService,
          analyticsService: mockAnalyticsService,
          monitoringService: mockMonitoringService,
        );
      });

      test('should handle tracking errors gracefully', () async {
        // Arrange
        when(
          mockUXMonitoringService.trackJourneyEvent(
            eventType: any,
            screenName: any,
            metadata: anyNamed('metadata'),
          ),
        ).thenThrow(Exception('Tracking error'));

        await sessionTracker.startSession(
          userId: 'user123',
          userType: 'client',
        );

        // Act
        await sessionTracker.trackScreenView(screenName: 'home_screen');

        // Assert
        verify(
          mockMonitoringService.logError(
            'Failed to track screen view',
            error: any,
            stackTrace: any,
          ),
        ).called(1);
      });

      test('should handle session start errors gracefully', () async {
        // Arrange
        when(
          mockAnalyticsService.logEvent(
            any,
            parameters: anyNamed('parameters'),
          ),
        ).thenThrow(Exception('Analytics error'));

        // Act
        await sessionTracker.startSession(
          userId: 'user123',
          userType: 'client',
        );

        // Assert
        verify(
          mockMonitoringService.logError(
            'Failed to start user session',
            error: any,
            stackTrace: any,
          ),
        ).called(1);
      });
    });

    group('disposal', () {
      test('should dispose resources properly', () async {
        // Arrange
        await sessionTracker.initialize(
          uxMonitoringService: mockUXMonitoringService,
          analyticsService: mockAnalyticsService,
          monitoringService: mockMonitoringService,
        );
        await sessionTracker.startSession(
          userId: 'user123',
          userType: 'client',
        );

        // Act
        await sessionTracker.dispose();

        // Assert
        expect(sessionTracker.isInitialized, isFalse);
        expect(sessionTracker.isTrackingActive, isFalse);
        expect(sessionTracker.currentSessionId, isNull);
      });
    });
  });
}
