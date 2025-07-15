import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:flutter_pro_test/core/monitoring/ux_monitoring_integration.dart';
import 'package:flutter_pro_test/core/monitoring/ux_monitoring_service.dart';
import 'package:flutter_pro_test/core/monitoring/user_session_tracker.dart';
import 'package:flutter_pro_test/core/monitoring/user_feedback_collector.dart';
import 'package:flutter_pro_test/core/monitoring/ux_error_impact_analyzer.dart';
import 'package:flutter_pro_test/core/analytics/firebase_analytics_service.dart';
import 'package:flutter_pro_test/core/analytics/business_analytics_service.dart';
import 'package:flutter_pro_test/core/monitoring/monitoring_service.dart';
import 'package:flutter_pro_test/core/error_tracking/error_tracking_service.dart';

import 'ux_monitoring_integration_test.mocks.dart';

@GenerateMocks([
  FirebaseAnalyticsService,
  BusinessAnalyticsService,
  MonitoringService,
  ErrorTrackingService,
  UXMonitoringService,
  UserSessionTracker,
  UserFeedbackCollector,
  UXErrorImpactAnalyzer,
])
void main() {
  group('UXMonitoringIntegration', () {
    late UXMonitoringIntegration uxMonitoringIntegration;
    late MockFirebaseAnalyticsService mockAnalyticsService;
    late MockBusinessAnalyticsService mockBusinessAnalyticsService;
    late MockMonitoringService mockMonitoringService;
    late MockErrorTrackingService mockErrorTrackingService;
    late MockUXMonitoringService mockUXMonitoringService;
    late MockUserSessionTracker mockSessionTracker;
    late MockUserFeedbackCollector mockFeedbackCollector;
    late MockUXErrorImpactAnalyzer mockErrorImpactAnalyzer;

    setUp(() {
      uxMonitoringIntegration = UXMonitoringIntegration();
      mockAnalyticsService = MockFirebaseAnalyticsService();
      mockBusinessAnalyticsService = MockBusinessAnalyticsService();
      mockMonitoringService = MockMonitoringService();
      mockErrorTrackingService = MockErrorTrackingService();
      mockUXMonitoringService = MockUXMonitoringService();
      mockSessionTracker = MockUserSessionTracker();
      mockFeedbackCollector = MockUserFeedbackCollector();
      mockErrorImpactAnalyzer = MockUXErrorImpactAnalyzer();

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

      // Setup service initialization mocks
      when(
        mockUXMonitoringService.initialize(
          analyticsService: anyNamed('analyticsService'),
          businessAnalyticsService: anyNamed('businessAnalyticsService'),
          monitoringService: anyNamed('monitoringService'),
        ),
      ).thenAnswer((_) async {});
      when(
        mockSessionTracker.initialize(
          uxMonitoringService: anyNamed('uxMonitoringService'),
          analyticsService: anyNamed('analyticsService'),
          monitoringService: anyNamed('monitoringService'),
        ),
      ).thenAnswer((_) async {});
      when(
        mockFeedbackCollector.initialize(
          uxMonitoringService: anyNamed('uxMonitoringService'),
          analyticsService: anyNamed('analyticsService'),
          monitoringService: anyNamed('monitoringService'),
        ),
      ).thenAnswer((_) async {});
      when(
        mockErrorImpactAnalyzer.initialize(
          uxMonitoringService: anyNamed('uxMonitoringService'),
          analyticsService: anyNamed('analyticsService'),
          monitoringService: anyNamed('monitoringService'),
          errorTrackingService: anyNamed('errorTrackingService'),
        ),
      ).thenAnswer((_) async {});

      // Setup property getters
      when(mockUXMonitoringService.isInitialized).thenReturn(true);
      when(mockSessionTracker.isInitialized).thenReturn(true);
      when(mockFeedbackCollector.isInitialized).thenReturn(true);
      when(mockErrorImpactAnalyzer.isInitialized).thenReturn(true);
      when(mockSessionTracker.currentSessionId).thenReturn('session123');
    });

    group('initialization', () {
      test('should initialize successfully', () async {
        // Act
        await uxMonitoringIntegration.initialize(
          analyticsService: mockAnalyticsService,
          businessAnalyticsService: mockBusinessAnalyticsService,
          monitoringService: mockMonitoringService,
          errorTrackingService: mockErrorTrackingService,
        );

        // Assert
        expect(uxMonitoringIntegration.isInitialized, isTrue);
        expect(uxMonitoringIntegration.isTrackingActive, isTrue);
        verify(
          mockMonitoringService.logInfo(
            'UX Monitoring Integration initialized successfully',
          ),
        ).called(1);
        verify(
          mockAnalyticsService.logEvent(
            'ux_monitoring_integration_initialized',
            parameters: anyNamed('parameters'),
          ),
        ).called(1);
      });

      test('should not initialize twice', () async {
        // Arrange
        await uxMonitoringIntegration.initialize(
          analyticsService: mockAnalyticsService,
          businessAnalyticsService: mockBusinessAnalyticsService,
          monitoringService: mockMonitoringService,
          errorTrackingService: mockErrorTrackingService,
        );

        // Act
        await uxMonitoringIntegration.initialize(
          analyticsService: mockAnalyticsService,
          businessAnalyticsService: mockBusinessAnalyticsService,
          monitoringService: mockMonitoringService,
          errorTrackingService: mockErrorTrackingService,
        );

        // Assert
        verify(
          mockMonitoringService.logInfo(
            'UX Monitoring Integration initialized successfully',
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
          () => uxMonitoringIntegration.initialize(
            analyticsService: mockAnalyticsService,
            businessAnalyticsService: mockBusinessAnalyticsService,
            monitoringService: mockMonitoringService,
            errorTrackingService: mockErrorTrackingService,
          ),
          throwsException,
        );
      });
    });

    group('session management', () {
      setUp(() async {
        await uxMonitoringIntegration.initialize(
          analyticsService: mockAnalyticsService,
          businessAnalyticsService: mockBusinessAnalyticsService,
          monitoringService: mockMonitoringService,
          errorTrackingService: mockErrorTrackingService,
        );
      });

      test('should start user session successfully', () async {
        // Act
        await uxMonitoringIntegration.startUserSession(
          userId: 'user123',
          userType: 'client',
          userProperties: {'name': 'Test User'},
        );

        // Assert
        expect(uxMonitoringIntegration.currentUserId, equals('user123'));
        expect(uxMonitoringIntegration.currentUserType, equals('client'));
        verify(
          mockBusinessAnalyticsService.setUser(
            userId: 'user123',
            userType: 'client',
            userProperties: anyNamed('userProperties'),
          ),
        ).called(1);
        verify(
          mockSessionTracker.startSession(
            userId: 'user123',
            userType: 'client',
          ),
        ).called(1);
        verify(
          mockMonitoringService.logInfo(
            'User session started with UX monitoring: user123',
          ),
        ).called(1);
      });

      test('should end session successfully', () async {
        // Arrange
        await uxMonitoringIntegration.startUserSession(
          userId: 'user123',
          userType: 'client',
        );

        // Act
        await uxMonitoringIntegration.endSession();

        // Assert
        expect(uxMonitoringIntegration.currentUserId, isNull);
        expect(uxMonitoringIntegration.currentUserType, isNull);
        verify(mockSessionTracker.endSession()).called(1);
        verify(mockMonitoringService.logInfo('User session ended')).called(1);
      });

      test('should handle session start errors gracefully', () async {
        // Arrange
        when(
          mockSessionTracker.startSession(userId: any, userType: any),
        ).thenThrow(Exception('Session error'));

        // Act
        await uxMonitoringIntegration.startUserSession(
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

    group('tracking', () {
      setUp(() async {
        await uxMonitoringIntegration.initialize(
          analyticsService: mockAnalyticsService,
          businessAnalyticsService: mockBusinessAnalyticsService,
          monitoringService: mockMonitoringService,
          errorTrackingService: mockErrorTrackingService,
        );
        await uxMonitoringIntegration.startUserSession(
          userId: 'user123',
          userType: 'client',
        );
      });

      test('should track screen view successfully', () async {
        // Act
        await uxMonitoringIntegration.trackScreenView(
          screenName: 'home_screen',
          screenClass: 'HomeScreen',
          parameters: {'source': 'navigation'},
        );

        // Assert
        verify(
          mockSessionTracker.trackScreenView(
            screenName: 'home_screen',
            screenClass: 'HomeScreen',
            parameters: anyNamed('parameters'),
          ),
        ).called(1);
        verify(
          mockBusinessAnalyticsService.trackScreenView(
            screenName: 'home_screen',
            screenClass: 'HomeScreen',
            parameters: anyNamed('parameters'),
          ),
        ).called(1);
        verify(
          mockMonitoringService.logInfo('Screen view tracked: home_screen'),
        ).called(1);
      });

      test('should track user interaction successfully', () async {
        // Act
        await uxMonitoringIntegration.trackUserInteraction(
          interactionType: 'tap',
          elementId: 'login_button',
          action: 'click',
          screenName: 'login_screen',
          parameters: {'result': 'success'},
        );

        // Assert
        verify(
          mockSessionTracker.trackInteraction(
            interactionType: 'tap',
            elementId: 'login_button',
            action: 'click',
            parameters: anyNamed('parameters'),
          ),
        ).called(1);
        verify(
          mockBusinessAnalyticsService.trackUserAction(
            actionName: 'tap',
            category: 'interaction',
            screenName: 'login_screen',
            parameters: anyNamed('parameters'),
          ),
        ).called(1);
        verify(
          mockMonitoringService.logInfo('User interaction tracked: tap'),
        ).called(1);
      });

      test('should track feature usage successfully', () async {
        // Act
        await uxMonitoringIntegration.trackFeatureUsage(
          featureName: 'booking_creation',
          category: 'core_feature',
          screenName: 'booking_screen',
          parameters: {'booking_type': 'cleaning'},
        );

        // Assert
        verify(
          mockSessionTracker.trackFeatureUsage(
            featureName: 'booking_creation',
            category: 'core_feature',
            parameters: anyNamed('parameters'),
          ),
        ).called(1);
        verify(
          mockBusinessAnalyticsService.trackUserAction(
            actionName: 'booking_creation',
            category: 'core_feature',
            screenName: 'booking_screen',
            parameters: anyNamed('parameters'),
          ),
        ).called(1);
        verify(
          mockMonitoringService.logInfo(
            'Feature usage tracked: booking_creation',
          ),
        ).called(1);
      });

      test('should collect user feedback successfully', () async {
        // Act
        await uxMonitoringIntegration.collectUserFeedback(
          screenName: 'home_screen',
          feedbackType: 'general',
          rating: 5,
          comment: 'Great app!',
          metadata: {'source': 'prompt'},
        );

        // Assert
        verify(
          mockFeedbackCollector.collectFeedback(
            userId: 'user123',
            screenName: 'home_screen',
            feedbackType: 'general',
            rating: 5,
            comment: 'Great app!',
            metadata: anyNamed('metadata'),
          ),
        ).called(1);
        verify(
          mockMonitoringService.logInfo(
            'User feedback collected: general (5/5)',
          ),
        ).called(1);
      });

      test('should track error with impact successfully', () async {
        // Act
        await uxMonitoringIntegration.trackErrorWithImpact(
          errorId: 'error123',
          screenName: 'payment_screen',
          errorType: 'network',
          errorMessage: 'Connection timeout',
          errorMetadata: {'retry_count': 1},
        );

        // Assert
        verify(
          mockErrorImpactAnalyzer.analyzeErrorImpact(
            errorId: 'error123',
            userId: 'user123',
            sessionId: 'session123',
            screenName: 'payment_screen',
            errorType: 'network',
            errorMessage: 'Connection timeout',
            errorTimestamp: any,
            errorMetadata: anyNamed('errorMetadata'),
          ),
        ).called(1);
        verify(
          mockMonitoringService.logInfo(
            'Error impact analyzed: network on payment_screen',
          ),
        ).called(1);
      });

      test('should not track when not initialized', () async {
        // Arrange
        final uninitializedIntegration = UXMonitoringIntegration();

        // Act
        await uninitializedIntegration.trackScreenView(
          screenName: 'home_screen',
        );

        // Assert
        verifyNever(
          mockSessionTracker.trackScreenView(
            screenName: any,
            screenClass: anyNamed('screenClass'),
            parameters: anyNamed('parameters'),
          ),
        );
      });
    });

    group('analytics retrieval', () {
      setUp(() async {
        await uxMonitoringIntegration.initialize(
          analyticsService: mockAnalyticsService,
          businessAnalyticsService: mockBusinessAnalyticsService,
          monitoringService: mockMonitoringService,
          errorTrackingService: mockErrorTrackingService,
        );

        // Setup mock analytics data
        when(mockSessionTracker.getCurrentSessionAnalytics()).thenReturn({
          'active': true,
          'session_id': 'session123',
          'duration_seconds': 120,
        });
        when(
          mockSessionTracker.getNavigationFlowAnalytics(),
        ).thenReturn({'navigation_flows': {}, 'navigation_history': []});
        when(
          mockSessionTracker.getEngagementMetrics(),
        ).thenReturn({'engagement_rate': 5.0, 'bounce_rate': 0.0});
        when(
          mockFeedbackCollector.getOverallFeedbackAnalytics(),
        ).thenReturn({'total_feedback': 10, 'overall_satisfaction': 4.5});
        when(
          mockErrorImpactAnalyzer.getOverallErrorImpactAnalytics(),
        ).thenReturn({'total_errors': 5, 'overall_abandonment_rate': 20.0});
        when(
          mockUXMonitoringService.getCurrentSessionMetrics(),
        ).thenReturn({'active': true, 'session_id': 'session123'});
      });

      test('should return comprehensive UX analytics', () {
        // Act
        final analytics = uxMonitoringIntegration.getComprehensiveUXAnalytics();

        // Assert
        expect(analytics, isA<Map<String, dynamic>>());
        expect(analytics.containsKey('session_analytics'), isTrue);
        expect(analytics.containsKey('navigation_analytics'), isTrue);
        expect(analytics.containsKey('engagement_metrics'), isTrue);
        expect(analytics.containsKey('feedback_analytics'), isTrue);
        expect(analytics.containsKey('error_impact_analytics'), isTrue);
        expect(analytics.containsKey('ux_monitoring_metrics'), isTrue);
        expect(analytics.containsKey('timestamp'), isTrue);
      });

      test('should return screen-specific analytics', () {
        // Arrange
        when(
          mockFeedbackCollector.getFeedbackAnalyticsForScreen('home_screen'),
        ).thenReturn({
          'screen_name': 'home_screen',
          'feedback_count': 5,
          'satisfaction_score': 4.2,
        });
        when(
          mockErrorImpactAnalyzer.getScreenErrorImpactAnalytics('home_screen'),
        ).thenReturn({
          'screen_name': 'home_screen',
          'total_errors': 2,
          'abandonment_rate': 10.0,
        });

        // Act
        final analytics = uxMonitoringIntegration.getScreenAnalytics(
          'home_screen',
        );

        // Assert
        expect(analytics, isA<Map<String, dynamic>>());
        expect(analytics['screen_name'], equals('home_screen'));
        expect(analytics.containsKey('feedback_analytics'), isTrue);
        expect(analytics.containsKey('error_impact_analytics'), isTrue);
        expect(analytics.containsKey('timestamp'), isTrue);
      });

      test('should return service status', () {
        // Act
        final status = uxMonitoringIntegration.getServiceStatus();

        // Assert
        expect(status, isA<Map<String, dynamic>>());
        expect(status['initialized'], isTrue);
        expect(status['tracking_active'], isTrue);
        expect(status.containsKey('current_user_id'), isTrue);
        expect(status.containsKey('services'), isTrue);
        expect(status.containsKey('metrics'), isTrue);
      });

      test('should handle analytics errors gracefully', () {
        // Arrange
        when(
          mockSessionTracker.getCurrentSessionAnalytics(),
        ).thenThrow(Exception('Analytics error'));

        // Act
        final analytics = uxMonitoringIntegration.getComprehensiveUXAnalytics();

        // Assert
        expect(analytics.containsKey('error'), isTrue);
        verify(
          mockMonitoringService.logError(
            'Failed to get comprehensive UX analytics',
            error: any,
            stackTrace: any,
          ),
        ).called(1);
      });
    });

    group('feedback prompts', () {
      setUp(() async {
        await uxMonitoringIntegration.initialize(
          analyticsService: mockAnalyticsService,
          businessAnalyticsService: mockBusinessAnalyticsService,
          monitoringService: mockMonitoringService,
          errorTrackingService: mockErrorTrackingService,
        );
        await uxMonitoringIntegration.startUserSession(
          userId: 'user123',
          userType: 'client',
        );
      });

      test('should check if feedback prompt should be shown', () async {
        // Arrange
        when(
          mockFeedbackCollector.shouldShowFeedbackPrompt(
            userId: 'user123',
            screenName: 'home_screen',
          ),
        ).thenReturn(Future.value(true));

        // Act
        final shouldShow = await uxMonitoringIntegration
            .shouldShowFeedbackPrompt('home_screen');

        // Assert
        expect(shouldShow, isTrue);
      });

      test('should get feedback prompt for type', () {
        // Arrange
        when(
          mockFeedbackCollector.getFeedbackPrompt('general'),
        ).thenReturn('How would you rate your overall experience?');

        // Act
        final prompt = uxMonitoringIntegration.getFeedbackPrompt('general');

        // Assert
        expect(prompt, equals('How would you rate your overall experience?'));
      });

      test('should handle feedback prompt errors gracefully', () async {
        // Arrange
        when(
          mockFeedbackCollector.shouldShowFeedbackPrompt(
            userId: any,
            screenName: any,
          ),
        ).thenThrow(Exception('Prompt error'));

        // Act
        final shouldShow = await uxMonitoringIntegration
            .shouldShowFeedbackPrompt('home_screen');

        // Assert
        expect(shouldShow, isFalse);
        verify(
          mockMonitoringService.logError(
            'Failed to check feedback prompt',
            error: any,
          ),
        ).called(1);
      });
    });

    group('tracking control', () {
      setUp(() async {
        await uxMonitoringIntegration.initialize(
          analyticsService: mockAnalyticsService,
          businessAnalyticsService: mockBusinessAnalyticsService,
          monitoringService: mockMonitoringService,
          errorTrackingService: mockErrorTrackingService,
        );
      });

      test('should enable/disable tracking', () {
        // Act
        uxMonitoringIntegration.setTrackingEnabled(false);

        // Assert
        expect(uxMonitoringIntegration.isTrackingActive, isFalse);
        verify(mockMonitoringService.logInfo('UX tracking disabled')).called(1);

        // Act again
        uxMonitoringIntegration.setTrackingEnabled(true);

        // Assert again
        expect(uxMonitoringIntegration.isTrackingActive, isTrue);
        verify(mockMonitoringService.logInfo('UX tracking enabled')).called(1);
      });
    });

    group('disposal', () {
      test('should dispose resources properly', () async {
        // Arrange
        await uxMonitoringIntegration.initialize(
          analyticsService: mockAnalyticsService,
          businessAnalyticsService: mockBusinessAnalyticsService,
          monitoringService: mockMonitoringService,
          errorTrackingService: mockErrorTrackingService,
        );

        // Act
        await uxMonitoringIntegration.dispose();

        // Assert
        expect(uxMonitoringIntegration.isInitialized, isFalse);
        expect(uxMonitoringIntegration.isTrackingActive, isFalse);
        expect(uxMonitoringIntegration.currentUserId, isNull);
        expect(uxMonitoringIntegration.currentUserType, isNull);
        verify(mockSessionTracker.dispose()).called(1);
        verify(mockFeedbackCollector.dispose()).called(1);
        verify(mockErrorImpactAnalyzer.dispose()).called(1);
        verify(mockUXMonitoringService.dispose()).called(1);
        verify(
          mockMonitoringService.logInfo('UX Monitoring Integration disposed'),
        ).called(1);
      });

      test('should handle disposal errors gracefully', () async {
        // Arrange
        await uxMonitoringIntegration.initialize(
          analyticsService: mockAnalyticsService,
          businessAnalyticsService: mockBusinessAnalyticsService,
          monitoringService: mockMonitoringService,
          errorTrackingService: mockErrorTrackingService,
        );
        when(
          mockSessionTracker.dispose(),
        ).thenThrow(Exception('Disposal error'));

        // Act
        await uxMonitoringIntegration.dispose();

        // Assert
        verify(
          mockMonitoringService.logError(
            'Failed to dispose UX Monitoring Integration',
            error: any,
            stackTrace: any,
          ),
        ).called(1);
      });
    });
  });
}
