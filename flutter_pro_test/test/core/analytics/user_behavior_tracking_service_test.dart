import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:flutter_pro_test/core/analytics/business_analytics_service.dart';
import 'package:flutter_pro_test/core/monitoring/monitoring_service.dart';

// Generate mocks
@GenerateMocks([BusinessAnalyticsService, MonitoringService])
import 'user_behavior_tracking_service_test.mocks.dart';

void main() {
  group('UserBehaviorTrackingService', () {
    late UserBehaviorTrackingService service;
    late MockBusinessAnalyticsService mockBusinessAnalytics;
    late MockMonitoringService mockMonitoringService;

    setUp(() {
      service = UserBehaviorTrackingService();
      mockBusinessAnalytics = MockBusinessAnalyticsService();
      mockMonitoringService = MockMonitoringService();

      // Setup default mock behaviors
      when(mockMonitoringService.logInfo(any)).thenReturn(null);
      when(
        mockMonitoringService.logError(
          any,
          error: anyNamed('error'),
          stackTrace: anyNamed('stackTrace'),
        ),
      ).thenReturn(null);
      when(
        mockBusinessAnalytics.trackUserAction(
          actionName: anyNamed('actionName'),
          category: anyNamed('category'),
          screenName: anyNamed('screenName'),
          parameters: anyNamed('parameters'),
        ),
      ).thenAnswer((_) async => {});
    });

    group('service state', () {
      test('should provide singleton instance', () {
        expect(service, isA<UserBehaviorTrackingService>());
      });

      test('should initialize with dependencies', () {
        // Act
        service.initialize(
          businessAnalytics: mockBusinessAnalytics,
          monitoringService: mockMonitoringService,
        );

        // Assert - should not throw
        expect(service, isA<UserBehaviorTrackingService>());
      });
    });

    group('click tracking', () {
      test('should track click patterns', () async {
        // Arrange
        service.initialize(
          businessAnalytics: mockBusinessAnalytics,
          monitoringService: mockMonitoringService,
        );

        // Act
        await service.trackClickPattern(
          elementId: 'button_1',
          screenName: 'home',
        );
        await service.trackClickPattern(
          elementId: 'button_1',
          screenName: 'home',
        );

        // Assert - verify tracking was called
        verify(
          mockBusinessAnalytics.trackUserAction(
            actionName: 'click_pattern',
            category: 'interaction',
            screenName: 'home',
            parameters: anyNamed('parameters'),
          ),
        ).called(2);
      });

      test('should track click patterns without initialization', () async {
        // Act & Assert - should not throw
        expect(
          () => service.trackClickPattern(
            elementId: 'button_1',
            screenName: 'home',
          ),
          returnsNormally,
        );
      });
    });

    group('screen time tracking', () {
      test('should start screen time tracking', () async {
        // Arrange
        service.initialize(
          businessAnalytics: mockBusinessAnalytics,
          monitoringService: mockMonitoringService,
        );

        // Act
        service.startScreenTimeTracking('home_screen');

        // Assert - should not throw
        expect(
          () => service.startScreenTimeTracking('home_screen'),
          returnsNormally,
        );
      });

      test('should end screen time tracking', () async {
        // Arrange
        service.initialize(
          businessAnalytics: mockBusinessAnalytics,
          monitoringService: mockMonitoringService,
        );

        // Act
        await service.startScreenTimeTracking('home_screen');
        await Future.delayed(Duration(milliseconds: 100)); // Small delay
        await service.endScreenTimeTracking('home_screen');

        // Assert - verify engagement tracking was called
        verify(
          mockBusinessAnalytics.trackEngagement(
            engagementType: 'screen_time',
            duration: anyNamed('duration'),
            parameters: anyNamed('parameters'),
          ),
        ).called(1);
      });

      test('should handle ending tracking without starting', () async {
        // Act & Assert - should not throw
        expect(
          () => service.endScreenTimeTracking('unknown_screen'),
          returnsNormally,
        );
      });
    });

    group('search tracking', () {
      test('should track search queries', () async {
        // Arrange
        service.initialize(
          businessAnalytics: mockBusinessAnalytics,
          monitoringService: mockMonitoringService,
        );

        // Act
        await service.trackSearchBehavior(
          query: 'home cleaning',
          searchType: 'services',
          resultsCount: 15,
        );

        // Assert - verify tracking was called
        verify(
          mockBusinessAnalytics.trackUserAction(
            actionName: 'search_performed',
            category: 'search',
            parameters: anyNamed('parameters'),
          ),
        ).called(1);
      });

      test('should track search without results count', () async {
        // Arrange
        service.initialize(
          businessAnalytics: mockBusinessAnalytics,
          monitoringService: mockMonitoringService,
        );

        // Act
        await service.trackSearchBehavior(
          query: 'plumbing',
          searchType: 'services',
        );

        // Assert - verify tracking was called
        verify(
          mockBusinessAnalytics.trackUserAction(
            actionName: 'search_performed',
            category: 'search',
            parameters: anyNamed('parameters'),
          ),
        ).called(1);
      });
    });

    group('error tracking', () {
      test('should track error encounters', () async {
        // Arrange
        service.initialize(
          businessAnalytics: mockBusinessAnalytics,
          monitoringService: mockMonitoringService,
        );

        // Act
        await service.trackUserErrorEncounter(
          errorType: 'network_error',
          screenName: 'booking_screen',
        );

        // Assert - verify error tracking was called
        verify(
          mockBusinessAnalytics.trackError(
            errorType: 'network_error',
            error: anyNamed('error'),
            screenName: 'booking_screen',
            userAction: anyNamed('userAction'),
            metadata: anyNamed('metadata'),
          ),
        ).called(1);
      });

      test('should increment error count for repeated errors', () async {
        // Arrange
        service.initialize(
          businessAnalytics: mockBusinessAnalytics,
          monitoringService: mockMonitoringService,
        );

        // Act
        await service.trackUserErrorEncounter(
          errorType: 'validation_error',
          screenName: 'form_screen',
        );
        await service.trackUserErrorEncounter(
          errorType: 'validation_error',
          screenName: 'form_screen',
        );

        // Assert - verify error tracking was called twice
        verify(
          mockBusinessAnalytics.trackError(
            errorType: 'validation_error',
            error: anyNamed('error'),
            screenName: 'form_screen',
            userAction: anyNamed('userAction'),
            metadata: anyNamed('metadata'),
          ),
        ).called(2);
      });
    });

    group('service functionality', () {
      test('should handle tracking without initialization', () async {
        // Act & Assert - should not throw when not initialized
        expect(
          () => service.trackClickPattern(
            elementId: 'button_1',
            screenName: 'home',
          ),
          returnsNormally,
        );
        expect(
          () =>
              service.trackSearchBehavior(query: 'test', searchType: 'general'),
          returnsNormally,
        );
        expect(
          () => service.trackUserErrorEncounter(
            errorType: 'test_error',
            screenName: 'test_screen',
          ),
          returnsNormally,
        );
      });

      test('should handle multiple tracking calls', () async {
        // Arrange
        service.initialize(
          businessAnalytics: mockBusinessAnalytics,
          monitoringService: mockMonitoringService,
        );

        // Act - multiple tracking calls
        await service.trackClickPattern(
          elementId: 'button_1',
          screenName: 'home',
        );
        await service.trackSearchBehavior(
          query: 'cleaning',
          searchType: 'services',
        );
        await service.trackUserErrorEncounter(
          errorType: 'network_error',
          screenName: 'booking',
        );

        // Assert - verify all tracking calls were made
        verify(
          mockBusinessAnalytics.trackUserAction(
            actionName: anyNamed('actionName'),
            category: anyNamed('category'),
            screenName: anyNamed('screenName'),
            parameters: anyNamed('parameters'),
          ),
        ).called(greaterThan(0));
      });
    });
  });
}
