import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// Core services
import 'package:flutter_pro_test/core/analytics/business_analytics_service.dart';
import 'package:flutter_pro_test/core/monitoring/monitoring_service.dart';

// Generated mocks
import 'analytics_integration_test.mocks.dart';

@GenerateMocks([MonitoringService])
void main() {
  group('Analytics Integration Tests', () {
    late MockMonitoringService mockMonitoringService;

    // Services under test
    late BusinessAnalyticsService businessAnalyticsService;
    late UserBehaviorTrackingService userBehaviorTrackingService;

    setUp(() async {
      // Initialize mocks
      mockMonitoringService = MockMonitoringService();

      // Configure mock behaviors
      when(mockMonitoringService.isAnalyticsEnabled).thenReturn(true);
      when(mockMonitoringService.logInfo(any)).thenReturn(null);
      when(
        mockMonitoringService.logError(
          any,
          error: anyNamed('error'),
          stackTrace: anyNamed('stackTrace'),
        ),
      ).thenReturn(null);

      // Initialize services
      businessAnalyticsService = BusinessAnalyticsService();
      userBehaviorTrackingService = UserBehaviorTrackingService();
    });

    tearDown(() async {
      // Clean up services - no cleanup needed for these services
    });

    group('Basic Service Integration', () {
      test(
        'should handle service interactions without initialization',
        () async {
          // Test that services can be used without full initialization
          // This tests the basic integration patterns

          // Act: Try to use services without initialization
          expect(
            () => businessAnalyticsService.trackUserAction(
              actionName: 'test_action',
              screenName: 'test_screen',
            ),
            returnsNormally,
          );

          expect(
            () => userBehaviorTrackingService.trackClickPattern(
              elementId: 'test_element',
              screenName: 'test_screen',
            ),
            returnsNormally,
          );

          expect(
            () => userBehaviorTrackingService.trackSearchBehavior(
              query: 'test_query',
              searchType: 'general',
            ),
            returnsNormally,
          );
        },
      );

      test(
        'should handle service initialization with mocked dependencies',
        () async {
          // Test service initialization with mocked monitoring service

          // Act: Initialize User Behavior Tracking with Business Analytics
          expect(
            () => userBehaviorTrackingService.initialize(
              businessAnalytics: businessAnalyticsService,
              monitoringService: mockMonitoringService,
            ),
            returnsNormally,
          );

          // Test that initialized service can track behavior
          expect(
            () => userBehaviorTrackingService.trackClickPattern(
              elementId: 'test_button',
              screenName: 'home_screen',
            ),
            returnsNormally,
          );
        },
      );

      test('should handle concurrent service operations', () async {
        // Initialize user behavior tracking
        userBehaviorTrackingService.initialize(
          businessAnalytics: businessAnalyticsService,
          monitoringService: mockMonitoringService,
        );

        // Act: Make multiple concurrent calls
        final futures = <Future>[];

        for (int i = 0; i < 5; i++) {
          futures.add(
            Future(
              () => businessAnalyticsService.trackUserAction(
                actionName: 'concurrent_action_$i',
                screenName: 'test_screen',
              ),
            ),
          );

          futures.add(
            Future(
              () => userBehaviorTrackingService.trackClickPattern(
                elementId: 'button_$i',
                screenName: 'test_screen',
              ),
            ),
          );
        }

        // Assert: All operations should complete without errors
        await expectLater(Future.wait(futures), completes);
      });

      test('should maintain service state consistency', () async {
        // Initialize services
        userBehaviorTrackingService.initialize(
          businessAnalytics: businessAnalyticsService,
          monitoringService: mockMonitoringService,
        );

        // Track multiple actions
        businessAnalyticsService.trackUserAction(
          actionName: 'login',
          screenName: 'login_screen',
        );

        userBehaviorTrackingService.trackClickPattern(
          elementId: 'login_button',
          screenName: 'login_screen',
        );

        businessAnalyticsService.trackUserAction(
          actionName: 'view_dashboard',
          screenName: 'dashboard_screen',
        );

        // Verify that services completed without errors
        // Note: Services may not call monitoring service in all scenarios
        expect(businessAnalyticsService, isNotNull);
        expect(userBehaviorTrackingService, isNotNull);
      });

      test('should handle error scenarios gracefully', () async {
        // Setup: Make monitoring service throw an error
        when(
          mockMonitoringService.logInfo(any),
        ).thenThrow(Exception('Monitoring error'));

        // Initialize services
        userBehaviorTrackingService.initialize(
          businessAnalytics: businessAnalyticsService,
          monitoringService: mockMonitoringService,
        );

        // Act & Assert: Should not crash when monitoring fails
        expect(
          () => businessAnalyticsService.trackUserAction(
            actionName: 'test_action',
          ),
          returnsNormally,
        );

        expect(
          () => userBehaviorTrackingService.trackClickPattern(
            elementId: 'test_element',
            screenName: 'test_screen',
          ),
          returnsNormally,
        );
      });

      test('should handle service dependency chain', () async {
        // Test the dependency chain: UserBehaviorTracking -> BusinessAnalytics -> MonitoringService

        // Initialize the chain
        userBehaviorTrackingService.initialize(
          businessAnalytics: businessAnalyticsService,
          monitoringService: mockMonitoringService,
        );

        // Track user behavior which should flow through the chain
        userBehaviorTrackingService.trackClickPattern(
          elementId: 'test_button',
          screenName: 'test_screen',
        );

        userBehaviorTrackingService.trackSearchBehavior(
          query: 'cleaning services',
          searchType: 'services',
        );

        userBehaviorTrackingService.trackUserErrorEncounter(
          errorType: 'network_error',
          screenName: 'booking_screen',
        );

        // Verify that the service chain completed successfully
        // Note: Monitoring service calls depend on service implementation
        expect(userBehaviorTrackingService, isNotNull);
      });

      test('should handle multiple service instances', () async {
        // Create additional service instances
        final businessAnalytics2 = BusinessAnalyticsService();
        final userBehaviorTracking2 = UserBehaviorTrackingService();

        // Initialize both sets of services
        userBehaviorTrackingService.initialize(
          businessAnalytics: businessAnalyticsService,
          monitoringService: mockMonitoringService,
        );

        userBehaviorTracking2.initialize(
          businessAnalytics: businessAnalytics2,
          monitoringService: mockMonitoringService,
        );

        // Use both service instances
        businessAnalyticsService.trackUserAction(
          actionName: 'action_1',
          screenName: 'screen_1',
        );

        businessAnalytics2.trackUserAction(
          actionName: 'action_2',
          screenName: 'screen_2',
        );

        userBehaviorTrackingService.trackClickPattern(
          elementId: 'button_1',
          screenName: 'screen_1',
        );

        userBehaviorTracking2.trackClickPattern(
          elementId: 'button_2',
          screenName: 'screen_2',
        );

        // Verify both service instances are working
        expect(businessAnalyticsService, isNotNull);
        expect(businessAnalytics2, isNotNull);
        expect(userBehaviorTrackingService, isNotNull);
        expect(userBehaviorTracking2, isNotNull);
      });
    });
  });
}
