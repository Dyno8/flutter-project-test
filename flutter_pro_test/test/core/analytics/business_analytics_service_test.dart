import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import 'package:flutter_pro_test/core/analytics/business_analytics_service.dart';
import 'package:flutter_pro_test/core/analytics/firebase_analytics_service.dart';
import 'package:flutter_pro_test/core/monitoring/monitoring_service.dart';

// Generate mocks
@GenerateMocks([FirebaseAnalyticsService, MonitoringService, FirebaseAnalytics])
import 'business_analytics_service_test.mocks.dart';

void main() {
  group('BusinessAnalyticsService', () {
    late BusinessAnalyticsService businessAnalytics;
    late MockFirebaseAnalyticsService mockAnalyticsService;
    late MockMonitoringService mockMonitoringService;

    setUp(() {
      businessAnalytics = BusinessAnalyticsService();
      mockAnalyticsService = MockFirebaseAnalyticsService();
      mockMonitoringService = MockMonitoringService();
    });

    group('service state', () {
      test('should report initialization status correctly', () {
        // Initially not initialized
        expect(businessAnalytics.isInitialized, isFalse);
      });

      test('should provide singleton instance', () {
        // Test that the service follows singleton pattern
        final instance1 = BusinessAnalyticsService();
        final instance2 = BusinessAnalyticsService();

        expect(instance1, same(instance2));
      });

      test('should handle initialization with dependencies', () async {
        // Arrange
        when(mockAnalyticsService.isInitialized).thenReturn(true);
        when(
          mockAnalyticsService.logEvent(
            any,
            parameters: anyNamed('parameters'),
          ),
        ).thenAnswer((_) async => {});

        // Act
        await businessAnalytics.initialize(
          analyticsService: mockAnalyticsService,
          monitoringService: mockMonitoringService,
        );

        // Assert
        expect(businessAnalytics.isInitialized, isTrue);
      });
    });

    group('user management', () {
      test('should provide access to user management methods', () {
        // Test that all expected user management methods are available
        expect(businessAnalytics.setUser, isA<Function>());
        expect(businessAnalytics.currentUserId, isNull); // Initially null
        expect(businessAnalytics.currentUserType, isNull); // Initially null
      });

      test('should handle user operations without crashing', () async {
        // Test that user operations don't crash even without initialization

        // Act & Assert - should not throw
        expect(
          () => businessAnalytics.setUser(
            userId: 'test_user',
            userType: 'client',
          ),
          returnsNormally,
        );
      });
    });

    group('tracking methods', () {
      test('should provide access to tracking methods', () {
        // Test that all expected tracking methods are available
        expect(businessAnalytics.trackScreenView, isA<Function>());
        expect(businessAnalytics.trackUserAction, isA<Function>());
        expect(businessAnalytics.trackFunnelStage, isA<Function>());
        expect(businessAnalytics.trackBusinessEvent, isA<Function>());
        expect(businessAnalytics.trackEngagement, isA<Function>());
        expect(businessAnalytics.trackError, isA<Function>());
      });

      test('should handle tracking operations without crashing', () async {
        // Test that tracking operations don't crash even without initialization

        // Act & Assert - should not throw
        expect(
          () => businessAnalytics.trackScreenView(screenName: 'test_screen'),
          returnsNormally,
        );

        expect(
          () => businessAnalytics.trackUserAction(actionName: 'test_action'),
          returnsNormally,
        );

        expect(
          () => businessAnalytics.trackFunnelStage(
            funnelName: 'test_funnel',
            stageName: 'test_stage',
          ),
          returnsNormally,
        );
      });
    });
  });
}
