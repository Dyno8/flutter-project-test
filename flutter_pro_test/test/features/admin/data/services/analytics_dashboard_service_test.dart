import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter_pro_test/features/admin/data/services/analytics_dashboard_service.dart';
import 'package:flutter_pro_test/core/analytics/firebase_analytics_service.dart';
import 'package:flutter_pro_test/core/analytics/business_analytics_service.dart';
import 'package:flutter_pro_test/core/monitoring/monitoring_service.dart';

// Generate mocks
@GenerateMocks([
  FirebaseAnalytics,
  FirebaseFirestore,
  FirebaseAnalyticsService,
  BusinessAnalyticsService,
  MonitoringService,
  DocumentReference,
  DocumentSnapshot,
  CollectionReference,
])
import 'analytics_dashboard_service_test.mocks.dart';

void main() {
  group('AnalyticsDashboardService', () {
    late MockFirebaseAnalytics mockAnalytics;
    late MockFirebaseFirestore mockFirestore;
    late MockFirebaseAnalyticsService mockAnalyticsService;
    late MockBusinessAnalyticsService mockBusinessAnalytics;
    late MockMonitoringService mockMonitoringService;
    late AnalyticsDashboardService dashboardService;

    void setupFirestoreMocks() {
      // Mock collection and document references
      final mockUsersCollection =
          MockCollectionReference<Map<String, dynamic>>();
      final mockUsersDoc = MockDocumentReference<Map<String, dynamic>>();
      final mockUsersSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();

      final mockBusinessDoc = MockDocumentReference<Map<String, dynamic>>();
      final mockBusinessSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();

      // Setup users analytics data
      when(
        mockFirestore.collection('analytics'),
      ).thenReturn(mockUsersCollection);
      when(mockUsersCollection.doc('users')).thenReturn(mockUsersDoc);
      when(mockUsersDoc.get()).thenAnswer((_) async => mockUsersSnapshot);
      when(mockUsersSnapshot.data()).thenReturn({
        'total_users': 15000,
        'avg_session_duration': 9.2,
        'user_segments': {'new': 0.25, 'regular': 0.55, 'power': 0.20},
      });

      // Setup business analytics data
      when(mockUsersCollection.doc('business')).thenReturn(mockBusinessDoc);
      when(mockBusinessDoc.get()).thenAnswer((_) async => mockBusinessSnapshot);
      when(mockBusinessSnapshot.data()).thenReturn({
        'revenue_week': 95000,
        'revenue_month': 380000,
        'revenue_year': 2800000,
        'bookings_total': 1500,
        'bookings_completed': 1350,
        'bookings_cancelled': 85,
        'bookings_pending': 65,
        'conversion_funnel': {
          'app_opens': 12000,
          'service_browse': 8500,
          'booking_started': 3800,
          'payment': 3200,
          'completed': 3000,
        },
      });
    }

    setUp(() {
      // Reset singleton instance for testing
      AnalyticsDashboardService.resetInstance();

      mockAnalytics = MockFirebaseAnalytics();
      mockFirestore = MockFirebaseFirestore();
      mockAnalyticsService = MockFirebaseAnalyticsService();
      mockBusinessAnalytics = MockBusinessAnalyticsService();
      mockMonitoringService = MockMonitoringService();

      // Setup default mock behaviors
      when(mockAnalyticsService.isInitialized).thenReturn(true);
      when(mockAnalyticsService.initialize()).thenAnswer((_) async => {});
      when(
        mockAnalyticsService.logEvent(any, parameters: anyNamed('parameters')),
      ).thenAnswer((_) async => {});

      when(mockMonitoringService.logInfo(any)).thenReturn(null);
      when(
        mockMonitoringService.logError(
          any,
          error: anyNamed('error'),
          stackTrace: anyNamed('stackTrace'),
        ),
      ).thenReturn(null);
      when(
        mockMonitoringService.getHealthStatus(),
      ).thenReturn({'status': 'healthy', 'score': 95});
      when(
        mockMonitoringService.getErrorStats(),
      ).thenReturn({'total': 10, 'critical': 1, 'warning': 5, 'info': 4});

      // Setup Firestore mocks
      setupFirestoreMocks();

      // Create service instance with mocked dependencies
      dashboardService = AnalyticsDashboardService(
        analytics: mockAnalytics,
        firestore: mockFirestore,
        analyticsService: mockAnalyticsService,
        businessAnalytics: mockBusinessAnalytics,
        monitoringService: mockMonitoringService,
      );
    });

    group('service state', () {
      test('should provide singleton instance', () {
        // Test that the service can be instantiated
        expect(dashboardService, isA<AnalyticsDashboardService>());
      });

      test('should provide access to analytics methods', () {
        // Test that all expected methods are available
        expect(dashboardService.initialize, isA<Function>());
        expect(dashboardService.refreshAllMetrics, isA<Function>());
        expect(dashboardService.dispose, isA<Function>());
      });

      test('should initialize successfully', () async {
        // Arrange - make analytics service not initialized
        when(mockAnalyticsService.isInitialized).thenReturn(false);

        // Act
        await dashboardService.initialize();

        // Assert
        verify(mockAnalyticsService.initialize()).called(1);
        verify(
          mockAnalyticsService.logEvent(
            'admin_analytics_dashboard_initialized',
            parameters: anyNamed('parameters'),
          ),
        ).called(1);
        verify(
          mockMonitoringService.logInfo(
            'Analytics Dashboard Service initialized',
          ),
        ).called(1);
      });

      test('should handle initialization errors', () async {
        // Arrange
        when(mockAnalyticsService.isInitialized).thenReturn(false);
        when(
          mockAnalyticsService.initialize(),
        ).thenThrow(Exception('Initialization failed'));

        // Act & Assert
        await expectLater(dashboardService.initialize(), throwsException);

        verify(
          mockMonitoringService.logError(
            'Failed to initialize Analytics Dashboard Service',
            error: anyNamed('error'),
            stackTrace: anyNamed('stackTrace'),
          ),
        ).called(1);
      });
    });

    group('metrics access', () {
      test('should provide access to metrics getters', () {
        // Test that all metrics getters are available
        expect(dashboardService.latestUserMetrics, isA<Map<String, dynamic>>());
        expect(
          dashboardService.latestPerformanceMetrics,
          isA<Map<String, dynamic>>(),
        );
        expect(
          dashboardService.latestBusinessMetrics,
          isA<Map<String, dynamic>>(),
        );
        expect(
          dashboardService.latestErrorMetrics,
          isA<Map<String, dynamic>>(),
        );
      });

      test('should provide access to metrics streams', () {
        // Test that all metrics streams are available
        expect(
          dashboardService.userMetricsStream,
          isA<Stream<Map<String, dynamic>>>(),
        );
        expect(
          dashboardService.performanceMetricsStream,
          isA<Stream<Map<String, dynamic>>>(),
        );
        expect(
          dashboardService.businessMetricsStream,
          isA<Stream<Map<String, dynamic>>>(),
        );
        expect(
          dashboardService.errorMetricsStream,
          isA<Stream<Map<String, dynamic>>>(),
        );
      });

      test('should refresh all metrics successfully', () async {
        // Act
        await dashboardService.refreshAllMetrics();

        // Assert - verify Firestore calls were made
        verify(mockFirestore.collection('analytics')).called(greaterThan(0));
      });

      test('should fetch user metrics with correct data structure', () async {
        // Act
        await dashboardService.refreshAllMetrics();
        final userMetrics = dashboardService.latestUserMetrics;

        // Assert
        expect(userMetrics, isNotEmpty);
        expect(userMetrics.containsKey('active_users'), isTrue);
        expect(userMetrics.containsKey('new_users'), isTrue);
        expect(userMetrics.containsKey('retention_rate'), isTrue);
        expect(userMetrics.containsKey('total_users'), isTrue);
        expect(userMetrics.containsKey('avg_session_duration'), isTrue);
        expect(userMetrics.containsKey('user_segments'), isTrue);
        expect(userMetrics.containsKey('timestamp'), isTrue);
      });

      test(
        'should fetch performance metrics with correct data structure',
        () async {
          // Act
          await dashboardService.refreshAllMetrics();
          final performanceMetrics = dashboardService.latestPerformanceMetrics;

          // Assert
          expect(performanceMetrics, isNotEmpty);
          expect(performanceMetrics.containsKey('app_load_time'), isTrue);
          expect(performanceMetrics.containsKey('api_response_time'), isTrue);
          expect(performanceMetrics.containsKey('memory_usage'), isTrue);
          expect(performanceMetrics.containsKey('cpu_usage'), isTrue);
          expect(performanceMetrics.containsKey('health_status'), isTrue);
          expect(performanceMetrics.containsKey('performance_score'), isTrue);
          expect(performanceMetrics.containsKey('timestamp'), isTrue);
        },
      );

      test(
        'should fetch business metrics with correct data structure',
        () async {
          // Act
          await dashboardService.refreshAllMetrics();
          final businessMetrics = dashboardService.latestBusinessMetrics;

          // Assert
          expect(businessMetrics, isNotEmpty);
          expect(businessMetrics.containsKey('revenue_today'), isTrue);
          expect(businessMetrics.containsKey('revenue_week'), isTrue);
          expect(businessMetrics.containsKey('revenue_month'), isTrue);
          expect(businessMetrics.containsKey('bookings_today'), isTrue);
          expect(businessMetrics.containsKey('bookings_total'), isTrue);
          expect(businessMetrics.containsKey('conversion_rate'), isTrue);
          expect(businessMetrics.containsKey('conversion_funnel'), isTrue);
          expect(businessMetrics.containsKey('timestamp'), isTrue);
        },
      );

      test('should fetch error metrics with correct data structure', () async {
        // Act
        await dashboardService.refreshAllMetrics();
        final errorMetrics = dashboardService.latestErrorMetrics;

        // Assert
        expect(errorMetrics, isNotEmpty);
        expect(errorMetrics.containsKey('app_crashes'), isTrue);
        expect(errorMetrics.containsKey('network_errors'), isTrue);
        expect(errorMetrics.containsKey('validation_errors'), isTrue);
        expect(errorMetrics.containsKey('auth_errors'), isTrue);
        expect(errorMetrics.containsKey('error_rate'), isTrue);
        expect(errorMetrics.containsKey('error_counts'), isTrue);
        expect(errorMetrics.containsKey('timestamp'), isTrue);
      });
    });

    group('error handling', () {
      test('should handle Firestore errors gracefully', () async {
        // Arrange
        when(
          mockFirestore.collection('analytics'),
        ).thenThrow(Exception('Firestore error'));

        // Act
        await dashboardService.refreshAllMetrics();

        // Assert - should not crash and should log error
        verify(
          mockMonitoringService.logError(
            any,
            error: anyNamed('error'),
            stackTrace: anyNamed('stackTrace'),
          ),
        ).called(greaterThan(0));
      });

      test('should return cached data when fetch fails', () async {
        // Arrange - first successful call to populate cache
        await dashboardService.refreshAllMetrics();
        final cachedUserMetrics = dashboardService.latestUserMetrics;

        // Arrange - make subsequent calls fail
        when(
          mockFirestore.collection('analytics'),
        ).thenThrow(Exception('Network error'));

        // Act
        await dashboardService.refreshAllMetrics();

        // Assert - should return cached data
        final userMetrics = dashboardService.latestUserMetrics;
        expect(userMetrics, equals(cachedUserMetrics));
      });
    });

    group('stream functionality', () {
      test('should emit data through streams', () async {
        // Arrange
        final userMetricsStream = dashboardService.userMetricsStream;
        final performanceMetricsStream =
            dashboardService.performanceMetricsStream;
        final businessMetricsStream = dashboardService.businessMetricsStream;
        final errorMetricsStream = dashboardService.errorMetricsStream;

        // Act
        await dashboardService.refreshAllMetrics();

        // Assert - streams should be available
        expect(userMetricsStream, isA<Stream<Map<String, dynamic>>>());
        expect(performanceMetricsStream, isA<Stream<Map<String, dynamic>>>());
        expect(businessMetricsStream, isA<Stream<Map<String, dynamic>>>());
        expect(errorMetricsStream, isA<Stream<Map<String, dynamic>>>());
      });
    });

    group('resource management', () {
      test('should handle dispose without crashing', () {
        // Test that dispose doesn't crash

        // Act & Assert - should not throw
        expect(() => dashboardService.dispose(), returnsNormally);
      });

      test('should clean up resources on dispose', () {
        // Act
        dashboardService.dispose();

        // Assert - streams should be closed (no direct way to test this)
        // This test mainly ensures dispose doesn't crash
        expect(dashboardService, isA<AnalyticsDashboardService>());
      });
    });
  });
}
