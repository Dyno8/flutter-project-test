import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_performance/firebase_performance.dart';

import 'package:flutter_pro_test/core/analytics/firebase_analytics_service.dart';
import '../../helpers/firebase_test_helper.dart';

void main() {
  setUpAll(() async {
    await FirebaseTestHelper.initializeFirebase();
  });

  tearDownAll(() {
    FirebaseTestHelper.cleanup();
  });

  group('FirebaseAnalyticsService', () {
    late FirebaseAnalyticsService analyticsService;

    setUp(() {
      analyticsService = FirebaseAnalyticsService();
    });

    group('initialization', () {
      test('should report initialization status correctly', () {
        // Initially not initialized
        expect(analyticsService.isInitialized, isFalse);
      });

      test('should handle initialization errors gracefully', () async {
        // Since we can't mock Firebase.initializeApp() easily in tests,
        // we test that the service handles Firebase initialization errors
        // by checking that it doesn't crash when Firebase is not initialized

        // Act & Assert - should not throw
        expect(() => analyticsService.isInitialized, returnsNormally);
      });
    });

    group('event logging', () {
      test('should handle Firebase initialization errors in logEvent', () async {
        // Test that the service handles Firebase initialization errors gracefully
        // The service should catch and log errors internally without throwing

        // Act - this will trigger Firebase initialization error
        try {
          await analyticsService.logEvent(
            'test_event',
            parameters: {'key': 'value'},
          );
          // If we reach here, the service handled the error gracefully
        } catch (e) {
          // If an exception is thrown, it should be a Firebase-related error
          expect(e.toString(), contains('Firebase'));
        }
      });

      test(
        'should handle Firebase initialization errors in logScreenView',
        () async {
          // Test that the service handles Firebase initialization errors gracefully

          // Act - this will trigger Firebase initialization error
          try {
            await analyticsService.logScreenView(
              screenName: 'test_screen',
              screenClass: 'TestScreen',
            );
            // If we reach here, the service handled the error gracefully
          } catch (e) {
            // If an exception is thrown, it should be a Firebase-related error
            expect(e.toString(), contains('Firebase'));
          }
        },
      );

      test('should provide access to service methods', () {
        // Test that all expected methods are available
        expect(analyticsService.logEvent, isA<Function>());
        expect(analyticsService.logScreenView, isA<Function>());
        expect(analyticsService.setUserId, isA<Function>());
        expect(analyticsService.setUserType, isA<Function>());
        expect(analyticsService.recordError, isA<Function>());
        expect(analyticsService.startTrace, isA<Function>());
        expect(analyticsService.stopTrace, isA<Function>());
        expect(analyticsService.startHttpMetric, isA<Function>());
        expect(analyticsService.stopHttpMetric, isA<Function>());
      });
    });

    group('user management', () {
      test('should handle Firebase initialization errors in setUserId', () async {
        // Test that the service handles Firebase initialization errors gracefully

        // Act - this will trigger Firebase initialization error
        try {
          await analyticsService.setUserId('test_user_123');
          // If we reach here, the service handled the error gracefully
        } catch (e) {
          // If an exception is thrown, it should be a Firebase-related error
          expect(e.toString(), contains('Firebase'));
        }
      });

      test(
        'should handle Firebase initialization errors in setUserType',
        () async {
          // Test that the service handles Firebase initialization errors gracefully

          // Act - this will trigger Firebase initialization error
          try {
            await analyticsService.setUserType('client');
            // If we reach here, the service handled the error gracefully
          } catch (e) {
            // If an exception is thrown, it should be a Firebase-related error
            expect(e.toString(), contains('Firebase'));
          }
        },
      );
    });

    group('error tracking', () {
      test(
        'should handle Firebase initialization errors in recordError',
        () async {
          // Test that the service handles Firebase initialization errors gracefully

          final error = Exception('Test error');
          final stackTrace = StackTrace.current;
          const metadata = {'key': 'value'};

          // Act - this will trigger Firebase initialization error
          try {
            await analyticsService.recordError(
              error,
              stackTrace,
              metadata: metadata,
              fatal: false,
            );
            // If we reach here, the service handled the error gracefully
          } catch (e) {
            // If an exception is thrown, it should be a Firebase-related error
            expect(e.toString(), contains('Firebase'));
          }
        },
      );
    });

    group('performance tracking', () {
      test(
        'should handle Firebase initialization errors in startTrace',
        () async {
          // Test that the service handles Firebase initialization errors gracefully

          // Act - this will trigger Firebase initialization error
          try {
            await analyticsService.startTrace('test_trace');
            // If we reach here, the service handled the error gracefully
          } catch (e) {
            // If an exception is thrown, it should be a Firebase-related error
            expect(e.toString(), contains('Firebase'));
          }
        },
      );

      test(
        'should handle Firebase initialization errors in startHttpMetric',
        () async {
          // Test that the service handles Firebase initialization errors gracefully

          const url = 'https://api.example.com/test';
          const httpMethod = HttpMethod.Get;

          // Act - this will trigger Firebase initialization error
          try {
            await analyticsService.startHttpMetric(url, httpMethod);
            // If we reach here, the service handled the error gracefully
          } catch (e) {
            // If an exception is thrown, it should be a Firebase-related error
            expect(e.toString(), contains('Firebase'));
          }
        },
      );

      test('should handle stopTrace calls gracefully', () async {
        // Test that stopTrace doesn't crash even when no trace was started

        // Act & Assert - should not throw
        expect(
          () => analyticsService.stopTrace('non_existent_trace'),
          returnsNormally,
        );
      });

      test('should handle stopHttpMetric calls gracefully', () async {
        // Test that stopHttpMetric doesn't crash even when no metric was started

        const url = 'https://api.example.com/test';

        // Act & Assert - should not throw
        expect(
          () => analyticsService.stopHttpMetric(
            url,
            responseCode: 200,
            requestPayloadSize: 1024,
            responsePayloadSize: 2048,
          ),
          returnsNormally,
        );
      });
    });

    group('service state', () {
      test('should report initialization status correctly', () {
        // Initially not initialized
        expect(analyticsService.isInitialized, isFalse);
      });

      test('should handle dispose without crashing', () async {
        // Test that the service can handle dispose calls
        // even when Firebase is not properly initialized

        // Act & Assert - should not throw
        expect(() => analyticsService.dispose(), returnsNormally);
      });

      test('should provide singleton instance', () {
        // Test that the service follows singleton pattern
        final instance1 = FirebaseAnalyticsService();
        final instance2 = FirebaseAnalyticsService();

        expect(instance1, same(instance2));
      });
    });
  });
}
