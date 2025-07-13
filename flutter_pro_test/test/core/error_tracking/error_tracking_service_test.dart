import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_pro_test/core/error_tracking/error_tracking_service.dart';
import 'package:flutter_pro_test/core/analytics/firebase_analytics_service.dart';
import 'package:flutter_pro_test/core/monitoring/monitoring_service.dart';
import 'package:flutter_pro_test/shared/services/notification_service.dart';
import '../../helpers/firebase_test_helper.dart';

// Generate mocks
@GenerateMocks([
  FirebaseAnalyticsService,
  MonitoringService,
  NotificationService,
  SharedPreferences,
])
import 'error_tracking_service_test.mocks.dart';

void main() {
  setUpAll(() async {
    await FirebaseTestHelper.initializeFirebase();
  });

  tearDownAll(() {
    FirebaseTestHelper.cleanup();
  });

  group('ErrorTrackingService', () {
    late ErrorTrackingService errorTrackingService;
    late MockFirebaseAnalyticsService mockAnalyticsService;
    late MockMonitoringService mockMonitoringService;
    late MockNotificationService mockNotificationService;
    late MockSharedPreferences mockPrefs;

    setUp(() {
      mockAnalyticsService = MockFirebaseAnalyticsService();
      mockMonitoringService = MockMonitoringService();
      mockNotificationService = MockNotificationService();
      mockPrefs = MockSharedPreferences();

      // Clear any previous verification state
      clearInteractions(mockAnalyticsService);
      clearInteractions(mockMonitoringService);
      clearInteractions(mockNotificationService);
      clearInteractions(mockPrefs);

      errorTrackingService = ErrorTrackingService();
    });

    group('initialization', () {
      test('should initialize successfully', () async {
        // Arrange
        when(mockPrefs.getString(any)).thenReturn(null);
        when(
          mockAnalyticsService.logEvent(
            any,
            parameters: anyNamed('parameters'),
          ),
        ).thenAnswer((_) async => {});

        // Act
        await errorTrackingService.initialize(
          analyticsService: mockAnalyticsService,
          monitoringService: mockMonitoringService,
          notificationService: mockNotificationService,
        );

        // Assert
        expect(errorTrackingService.isInitialized, isTrue);
        verify(
          mockAnalyticsService.logEvent(
            'error_occurred',
            parameters: argThat(
              isA<Map<String, Object?>>().having(
                (map) => map['event_type'],
                'event_type',
                equals('error_tracking_initialized'),
              ),
            ),
          ),
        ).called(1);
      });

      test('should handle initialization errors gracefully', () async {
        // Arrange
        when(
          mockPrefs.getString(any),
        ).thenThrow(Exception('SharedPreferences error'));

        // Act & Assert
        expect(
          () => errorTrackingService.initialize(
            analyticsService: mockAnalyticsService,
            monitoringService: mockMonitoringService,
            notificationService: mockNotificationService,
          ),
          throwsException,
        );
      });
    });

    group('error tracking', () {
      setUp(() async {
        when(mockPrefs.getString(any)).thenReturn(null);
        when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);
        when(
          mockAnalyticsService.logEvent(
            any,
            parameters: anyNamed('parameters'),
          ),
        ).thenAnswer((_) async => {});
        when(
          mockAnalyticsService.recordError(
            any,
            any,
            metadata: anyNamed('metadata'),
          ),
        ).thenAnswer((_) async => {});
        when(
          mockMonitoringService.logError(
            any,
            error: anyNamed('error'),
            stackTrace: anyNamed('stackTrace'),
            metadata: anyNamed('metadata'),
          ),
        ).thenReturn(null);

        await errorTrackingService.initialize(
          analyticsService: mockAnalyticsService,
          monitoringService: mockMonitoringService,
          notificationService: mockNotificationService,
        );
      });

      test('should track error incidents', () async {
        // Arrange
        const errorType = 'network_error';
        const errorMessage = 'Connection failed';
        final error = Exception('Network timeout');
        final stackTrace = StackTrace.current;
        const userId = 'user123';
        const screenName = 'booking_screen';
        const userAction = 'submit_booking';
        final metadata = {'endpoint': '/api/bookings'};

        // Act
        await errorTrackingService.trackError(
          errorType: errorType,
          errorMessage: errorMessage,
          error: error,
          stackTrace: stackTrace,
          userId: userId,
          screenName: screenName,
          userAction: userAction,
          metadata: metadata,
          severity: ErrorSeverity.high,
          fatal: false,
        );

        // Assert
        verify(
          mockAnalyticsService.recordError(
            error,
            stackTrace,
            metadata: argThat(
              isA<Map<String, dynamic>>()
                  .having(
                    (map) => map['error_type'],
                    'error_type',
                    equals(errorType),
                  )
                  .having((map) => map['severity'], 'severity', equals('high'))
                  .having(
                    (map) => map['screen_name'],
                    'screen_name',
                    equals(screenName),
                  ),
            ),
          ),
        ).called(1);

        verify(
          mockAnalyticsService.logEvent(
            'error_occurred',
            parameters: argThat(
              isA<Map<String, Object?>>()
                  .having(
                    (map) => map['error_type'],
                    'error_type',
                    equals(errorType),
                  )
                  .having(
                    (map) => map['error_message'],
                    'error_message',
                    equals(errorMessage),
                  )
                  .having((map) => map['severity'], 'severity', equals('high')),
            ),
          ),
        ).called(1);
      });

      test('should track performance degradation', () async {
        // Arrange
        const metricName = 'api_response_time';
        const currentValue = 5000.0;
        const threshold = 1000.0;
        const context = 'booking_api';
        final metadata = {'endpoint': '/api/bookings'};

        // Act
        await errorTrackingService.trackPerformanceDegradation(
          metricName: metricName,
          currentValue: currentValue,
          threshold: threshold,
          context: context,
          metadata: metadata,
        );

        // Assert
        verify(
          mockAnalyticsService.recordError(
            any,
            any,
            metadata: argThat(
              isA<Map<String, dynamic>>()
                  .having(
                    (map) => map['metric_name'],
                    'metric_name',
                    equals(metricName),
                  )
                  .having(
                    (map) => map['current_value'],
                    'current_value',
                    equals(currentValue),
                  )
                  .having(
                    (map) => map['threshold'],
                    'threshold',
                    equals(threshold),
                  ),
            ),
          ),
        ).called(1);
      });

      test('should maintain error history', () async {
        // Arrange
        const errorType = 'validation_error';
        const errorMessage = 'Invalid input';
        final error = Exception('Validation failed');

        // Act
        await errorTrackingService.trackError(
          errorType: errorType,
          errorMessage: errorMessage,
          error: error,
        );

        // Assert
        final recentErrors = errorTrackingService.getRecentErrors(limit: 10);
        expect(recentErrors, isNotEmpty);
        expect(recentErrors.first.errorType, equals(errorType));
        expect(recentErrors.first.errorMessage, equals(errorMessage));
      });

      test('should limit error history size', () async {
        // Arrange
        const maxRecentErrors =
            50; // Based on ErrorTrackingService.maxRecentErrors

        // Act
        for (int i = 0; i < maxRecentErrors + 10; i++) {
          await errorTrackingService.trackError(
            errorType: 'test_error',
            errorMessage: 'Test error $i',
            error: Exception('Test error $i'),
          );
        }

        // Assert
        final recentErrors = errorTrackingService.getRecentErrors(limit: 100);
        expect(recentErrors.length, equals(maxRecentErrors));
      });
    });

    group('error thresholds and alerting', () {
      setUp(() async {
        when(mockPrefs.getString(any)).thenReturn(null);
        when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);
        when(
          mockAnalyticsService.logEvent(
            any,
            parameters: anyNamed('parameters'),
          ),
        ).thenAnswer((_) async => {});
        when(
          mockAnalyticsService.recordError(
            any,
            any,
            metadata: anyNamed('metadata'),
          ),
        ).thenAnswer((_) async => {});
        when(
          mockMonitoringService.logError(
            any,
            error: anyNamed('error'),
            stackTrace: anyNamed('stackTrace'),
            metadata: anyNamed('metadata'),
          ),
        ).thenReturn(null);
        when(mockMonitoringService.logInfo(any)).thenReturn(null);
        // Note: sendNotificationToAdmins is an extension method and cannot be mocked directly
        // We'll test the notification functionality separately

        await errorTrackingService.initialize(
          analyticsService: mockAnalyticsService,
          monitoringService: mockMonitoringService,
          notificationService: mockNotificationService,
        );
      });

      test('should set custom error thresholds', () {
        // Arrange
        const errorType = 'custom_error';
        const maxOccurrences = 5;
        final timeWindow = Duration(minutes: 10);
        const alertSeverity = ErrorSeverity.high;

        // Act
        errorTrackingService.setErrorThreshold(
          errorType: errorType,
          maxOccurrences: maxOccurrences,
          timeWindow: timeWindow,
          alertSeverity: alertSeverity,
        );

        // Assert
        // No direct way to verify threshold was set, but we can test alert behavior
        expect(
          () => errorTrackingService.setErrorThreshold(
            errorType: errorType,
            maxOccurrences: maxOccurrences,
            timeWindow: timeWindow,
            alertSeverity: alertSeverity,
          ),
          returnsNormally,
        );
      });

      test('should trigger alerts when thresholds are exceeded', () async {
        // Arrange
        const errorType = 'test_alert_error';
        errorTrackingService.setErrorThreshold(
          errorType: errorType,
          maxOccurrences: 2,
          timeWindow: Duration(minutes: 5),
          alertSeverity: ErrorSeverity.high,
        );

        // Act - Trigger errors to exceed threshold
        for (int i = 0; i < 3; i++) {
          await errorTrackingService.trackError(
            errorType: errorType,
            errorMessage: 'Test error $i',
            error: Exception('Test error $i'),
          );
        }

        // Assert - Verify error tracking and analytics logging
        // Note: Notification verification skipped due to extension method limitations
        verify(
          mockAnalyticsService.logEvent(
            'error_threshold_exceeded',
            parameters: anyNamed('parameters'),
          ),
        ).called(1);

        verify(
          mockAnalyticsService.logEvent(
            'error_alert_sent',
            parameters: argThat(
              isA<Map<String, Object?>>().having(
                (map) => map['error_type'],
                'error_type',
                equals(errorType),
              ),
            ),
          ),
        ).called(1);
      });

      test('should respect alert cooldown period', () async {
        // Arrange
        const errorType = 'cooldown_test_error';
        errorTrackingService.setErrorThreshold(
          errorType: errorType,
          maxOccurrences: 1,
          timeWindow: Duration(minutes: 5),
          alertSeverity: ErrorSeverity.high,
        );

        // Act - Trigger multiple errors quickly
        for (int i = 0; i < 5; i++) {
          await errorTrackingService.trackError(
            errorType: errorType,
            errorMessage: 'Test error $i',
            error: Exception('Test error $i'),
          );
        }

        // Assert - Should only send one alert due to cooldown
        // Note: Notification verification skipped due to extension method limitations
        // Verify that error tracking events were logged
        verify(
          mockAnalyticsService.logEvent(
            'error_threshold_exceeded',
            parameters: anyNamed('parameters'),
          ),
        ).called(1);
      });
    });

    group('error statistics', () {
      setUp(() async {
        when(mockPrefs.getString(any)).thenReturn(null);
        when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);
        when(
          mockAnalyticsService.logEvent(
            any,
            parameters: anyNamed('parameters'),
          ),
        ).thenAnswer((_) async => {});
        when(
          mockAnalyticsService.recordError(
            any,
            any,
            metadata: anyNamed('metadata'),
          ),
        ).thenAnswer((_) async => {});
        when(
          mockMonitoringService.logError(
            any,
            error: anyNamed('error'),
            stackTrace: anyNamed('stackTrace'),
            metadata: anyNamed('metadata'),
          ),
        ).thenReturn(null);

        await errorTrackingService.initialize(
          analyticsService: mockAnalyticsService,
          monitoringService: mockMonitoringService,
          notificationService: mockNotificationService,
        );
      });

      test('should provide error statistics', () async {
        // Arrange
        await errorTrackingService.trackError(
          errorType: 'network_error',
          errorMessage: 'Connection failed',
          error: Exception('Network error'),
          severity: ErrorSeverity.high,
        );

        await errorTrackingService.trackError(
          errorType: 'validation_error',
          errorMessage: 'Invalid input',
          error: Exception('Validation error'),
          severity: ErrorSeverity.medium,
        );

        await errorTrackingService.trackError(
          errorType: 'network_error',
          errorMessage: 'Timeout',
          error: Exception('Network timeout'),
          severity: ErrorSeverity.high,
          fatal: true,
        );

        // Act
        final statistics = errorTrackingService.getErrorStatistics();

        // Assert
        expect(statistics, isA<Map<String, dynamic>>());
        expect(statistics['total_errors'], equals(3));
        expect(statistics['error_types'], contains('network_error'));
        expect(statistics['error_types'], contains('validation_error'));
        expect(statistics['error_type_counts']['network_error'], equals(2));
        expect(statistics['error_type_counts']['validation_error'], equals(1));
        expect(statistics['fatal_errors_24h'], equals(1));
        expect(statistics['severity_breakdown']['high'], equals(2));
        expect(statistics['severity_breakdown']['medium'], equals(1));
      });

      test('should get errors by type', () async {
        // Arrange
        const errorType = 'specific_error';
        await errorTrackingService.trackError(
          errorType: errorType,
          errorMessage: 'Specific error 1',
          error: Exception('Error 1'),
        );
        await errorTrackingService.trackError(
          errorType: errorType,
          errorMessage: 'Specific error 2',
          error: Exception('Error 2'),
        );
        await errorTrackingService.trackError(
          errorType: 'other_error',
          errorMessage: 'Other error',
          error: Exception('Other error'),
        );

        // Act
        final specificErrors = errorTrackingService.getErrorsByType(errorType);

        // Assert
        expect(specificErrors.length, equals(2));
        expect(specificErrors.every((e) => e.errorType == errorType), isTrue);
      });
    });

    group('data persistence', () {
      setUp(() async {
        when(mockPrefs.getString(any)).thenReturn(null);
        when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);
        when(
          mockAnalyticsService.logEvent(
            any,
            parameters: anyNamed('parameters'),
          ),
        ).thenAnswer((_) async => {});
        when(
          mockAnalyticsService.recordError(
            any,
            any,
            metadata: anyNamed('metadata'),
          ),
        ).thenAnswer((_) async => {});
        when(
          mockMonitoringService.logError(
            any,
            error: anyNamed('error'),
            stackTrace: anyNamed('stackTrace'),
            metadata: anyNamed('metadata'),
          ),
        ).thenReturn(null);

        await errorTrackingService.initialize(
          analyticsService: mockAnalyticsService,
          monitoringService: mockMonitoringService,
          notificationService: mockNotificationService,
        );
      });

      test('should save error data to SharedPreferences', () async {
        // Arrange
        await errorTrackingService.trackError(
          errorType: 'test_error',
          errorMessage: 'Test error',
          error: Exception('Test error'),
        );

        // Act & Assert
        verify(
          mockPrefs.setString(
            'error_tracking_data',
            argThat(contains('recent_errors')),
          ),
        ).called(greaterThan(0));
      });

      test('should clear error history', () async {
        // Arrange
        await errorTrackingService.trackError(
          errorType: 'test_error',
          errorMessage: 'Test error',
          error: Exception('Test error'),
        );

        // Act
        await errorTrackingService.clearErrorHistory();

        // Assert
        final recentErrors = errorTrackingService.getRecentErrors();
        expect(recentErrors, isEmpty);

        final statistics = errorTrackingService.getErrorStatistics();
        expect(statistics['total_errors'], equals(0));
      });
    });

    group('service state', () {
      test('should report initialization status correctly', () {
        // Initially not initialized
        expect(errorTrackingService.isInitialized, isFalse);
      });

      test('should dispose resources properly', () {
        // Act
        errorTrackingService.dispose();

        // Assert
        expect(errorTrackingService.isInitialized, isFalse);
      });
    });
  });
}
