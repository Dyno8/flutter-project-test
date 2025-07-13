import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_pro_test/core/monitoring/monitoring_service.dart';
import 'package:flutter_pro_test/core/performance/performance_manager.dart';
import 'package:flutter_pro_test/core/security/security_manager.dart';
import 'package:flutter_pro_test/core/error_tracking/error_tracking_service.dart';
import 'package:flutter_pro_test/core/analytics/firebase_analytics_service.dart';
import 'package:flutter_pro_test/shared/services/notification_service.dart';

@GenerateMocks([
  SharedPreferences,
  FirebaseAnalyticsService,
  NotificationService,
])
import 'monitoring_services_performance_test.mocks.dart';

void main() {
  group('Monitoring Services Performance Tests', () {
    late MonitoringService monitoringService;
    late PerformanceManager performanceManager;
    late SecurityManager securityManager;
    late ErrorTrackingService errorTrackingService;
    late MockSharedPreferences mockSharedPreferences;
    late MockFirebaseAnalyticsService mockAnalyticsService;
    late MockNotificationService mockNotificationService;

    setUp(() async {
      // Setup mocks
      mockSharedPreferences = MockSharedPreferences();
      mockAnalyticsService = MockFirebaseAnalyticsService();
      mockNotificationService = MockNotificationService();

      when(mockSharedPreferences.getString(any)).thenReturn(null);
      when(mockSharedPreferences.getInt(any)).thenReturn(null);
      when(mockSharedPreferences.getBool(any)).thenReturn(false);
      when(
        mockSharedPreferences.setString(any, any),
      ).thenAnswer((_) async => true);
      when(
        mockSharedPreferences.setInt(any, any),
      ).thenAnswer((_) async => true);
      when(
        mockSharedPreferences.setBool(any, any),
      ).thenAnswer((_) async => true);

      // Mock analytics service
      when(
        mockAnalyticsService.logEvent(any, parameters: anyNamed('parameters')),
      ).thenAnswer((_) async => {});
      when(
        mockAnalyticsService.recordError(
          any,
          any,
          metadata: anyNamed('metadata'),
        ),
      ).thenAnswer((_) async => {});

      SharedPreferences.setMockInitialValues({});

      // Initialize services
      monitoringService = MonitoringService();
      await monitoringService.initialize();

      performanceManager = PerformanceManager();
      await performanceManager.initialize();

      securityManager = SecurityManager();
      await securityManager.initialize();

      errorTrackingService = ErrorTrackingService();
      await errorTrackingService.initialize(
        analyticsService: mockAnalyticsService,
        monitoringService: monitoringService,
        notificationService: mockNotificationService,
      );
    });

    tearDown(() async {
      monitoringService.dispose();
      performanceManager.dispose();
      errorTrackingService.dispose();
    });

    group('MonitoringService Performance Tests', () {
      test('should handle high-frequency logging efficiently', () async {
        const iterations = 10000;
        final stopwatch = Stopwatch()..start();

        // Test high-frequency logging
        for (int i = 0; i < iterations; i++) {
          monitoringService.logInfo(
            'Performance test log $i',
            metadata: {
              'iteration': i,
              'timestamp': DateTime.now().millisecondsSinceEpoch,
              'test_data': 'sample_data_$i',
            },
          );
        }

        final loggingTime = stopwatch.elapsedMilliseconds;
        stopwatch.stop();

        // Performance assertions
        expect(
          loggingTime,
          lessThan(5000),
          reason: 'Logging should complete within 5 seconds',
        );

        final avgTimePerLog = loggingTime / iterations;
        expect(
          avgTimePerLog,
          lessThan(1.0),
          reason: 'Average time per log should be less than 1ms',
        );

        // Verify logs were recorded (within buffer limit)
        final logs = monitoringService.getRecentLogs(limit: iterations);
        expect(
          logs.length,
          lessThanOrEqualTo(MonitoringService.maxLogBufferSize),
        );
      });

      test('should handle concurrent logging from multiple sources', () async {
        const concurrentSources = 50;
        const logsPerSource = 100;
        final stopwatch = Stopwatch()..start();

        // Create concurrent logging tasks
        final futures = <Future>[];
        for (int source = 0; source < concurrentSources; source++) {
          futures.add(
            Future(() async {
              for (int i = 0; i < logsPerSource; i++) {
                monitoringService.logInfo(
                  'Concurrent log from source $source, iteration $i',
                  metadata: {
                    'source_id': source,
                    'iteration': i,
                    'thread_id': source,
                  },
                );

                // Add small random delay to simulate real-world conditions
                if (i % 10 == 0) {
                  await Future.delayed(
                    Duration(microseconds: math.Random().nextInt(100)),
                  );
                }
              }
            }),
          );
        }

        await Future.wait(futures);
        final totalTime = stopwatch.elapsedMilliseconds;
        stopwatch.stop();

        // Performance assertions
        expect(
          totalTime,
          lessThan(10000),
          reason: 'Concurrent logging should complete within 10 seconds',
        );

        // Verify system stability
        final logs = monitoringService.getRecentLogs(
          limit: concurrentSources * logsPerSource,
        );
        expect(
          logs.length,
          lessThanOrEqualTo(MonitoringService.maxLogBufferSize),
        );

        // Verify health status is still accessible
        final healthStatus = monitoringService.getHealthStatus();
        expect(healthStatus, isNotNull);
        expect(healthStatus['status'], isNotNull);
      });

      test('should maintain performance during memory pressure', () async {
        const memoryPressureIterations = 5000;
        final stopwatch = Stopwatch()..start();

        // Create memory pressure with large log entries
        for (int i = 0; i < memoryPressureIterations; i++) {
          final largeMetadata = <String, dynamic>{};

          // Create large metadata objects
          for (int j = 0; j < 50; j++) {
            largeMetadata['key_$j'] = 'large_data_value_$j' * 10;
          }

          monitoringService.logWarning(
            'Memory pressure test log $i with large metadata',
            metadata: largeMetadata,
          );

          // Periodically check system health
          if (i % 1000 == 0) {
            final healthStatus = monitoringService.getHealthStatus();
            expect(healthStatus['status'], isIn(['healthy', 'warning']));
          }
        }

        final totalTime = stopwatch.elapsedMilliseconds;
        stopwatch.stop();

        // Performance assertions
        expect(
          totalTime,
          lessThan(15000),
          reason: 'Memory pressure test should complete within 15 seconds',
        );

        // Verify system is still responsive
        final finalHealthStatus = monitoringService.getHealthStatus();
        expect(finalHealthStatus, isNotNull);

        // Memory usage should be reported
        expect(finalHealthStatus['checks']['memory'], isNotNull);
      });

      test('should handle error rate monitoring efficiently', () async {
        const errorIterations = 1000;
        final stopwatch = Stopwatch()..start();

        // Generate various types of errors
        for (int i = 0; i < errorIterations; i++) {
          final errorType = i % 5;

          switch (errorType) {
            case 0:
              monitoringService.logError(
                'Network error $i',
                error: Exception('Network timeout'),
              );
              break;
            case 1:
              monitoringService.logError(
                'Database error $i',
                error: Exception('Connection failed'),
              );
              break;
            case 2:
              monitoringService.logCritical(
                'Critical system error $i',
                error: Exception('System failure'),
              );
              break;
            case 3:
              monitoringService.logWarning('Performance warning $i');
              break;
            case 4:
              monitoringService.logInfo('Recovery info $i');
              break;
          }
        }

        final totalTime = stopwatch.elapsedMilliseconds;
        stopwatch.stop();

        // Performance assertions
        expect(
          totalTime,
          lessThan(8000),
          reason: 'Error logging should complete within 8 seconds',
        );

        // Verify error statistics are calculated efficiently
        final errorStats = monitoringService.getErrorStats();
        expect(errorStats, isNotNull);
        expect(errorStats['total_errors'], isA<int>());
        expect(errorStats['error_rate_per_minute'], isA<double>());
      });
    });

    group('PerformanceManager Load Tests', () {
      test('should handle high-frequency event recording', () async {
        const eventIterations = 15000;
        final stopwatch = Stopwatch()..start();

        // Record various types of performance events
        for (int i = 0; i < eventIterations; i++) {
          final eventType = i % 6;

          switch (eventType) {
            case 0:
              performanceManager.recordEvent(
                'api_call_$i',
                duration: Duration(milliseconds: 50 + (i % 200)),
                metadata: {'endpoint': '/api/test', 'method': 'GET'},
              );
              break;
            case 1:
              performanceManager.recordEvent(
                'database_query_$i',
                duration: Duration(milliseconds: 10 + (i % 100)),
                metadata: {'table': 'users', 'operation': 'SELECT'},
              );
              break;
            case 2:
              performanceManager.recordEvent(
                'ui_render_$i',
                duration: Duration(milliseconds: 16 + (i % 50)),
                metadata: {'widget': 'ListView', 'items': i % 100},
              );
              break;
            case 3:
              performanceManager.recordEvent(
                'cache_operation_$i',
                duration: Duration(microseconds: 100 + (i % 1000)),
                metadata: {'operation': 'get', 'hit': i % 2 == 0},
              );
              break;
            case 4:
              performanceManager.recordEvent(
                'network_request_$i',
                duration: Duration(milliseconds: 100 + (i % 500)),
                metadata: {'size_bytes': 1024 * (i % 10)},
              );
              break;
            case 5:
              performanceManager.recordEvent(
                'file_operation_$i',
                duration: Duration(milliseconds: 5 + (i % 50)),
                metadata: {'operation': 'read', 'size_kb': i % 100},
              );
              break;
          }
        }

        final totalTime = stopwatch.elapsedMilliseconds;
        stopwatch.stop();

        // Performance assertions
        expect(
          totalTime,
          lessThan(12000),
          reason: 'Event recording should complete within 12 seconds',
        );

        final avgTimePerEvent = totalTime / eventIterations;
        expect(
          avgTimePerEvent,
          lessThan(1.0),
          reason: 'Average time per event should be less than 1ms',
        );

        // Verify events were recorded
        final events = performanceManager.getRecentEvents(
          limit: eventIterations,
        );
        expect(
          events.length,
          lessThanOrEqualTo(PerformanceManager.maxEventQueueSize),
        );

        // Verify performance stats are still accessible
        final stats = performanceManager.getPerformanceStats();
        expect(stats, isNotNull);
        expect(stats['event_queue_size'], isA<int>());
      });
    });

    group('SecurityManager Performance Tests', () {
      test('should handle rapid session validation efficiently', () async {
        // Generate session token
        final sessionToken = securityManager.generateSessionToken();

        const validationIterations = 5000;
        final stopwatch = Stopwatch()..start();

        // Perform rapid session validations
        for (int i = 0; i < validationIterations; i++) {
          final isValid = securityManager.validateSession(sessionToken);
          expect(isValid, isTrue);
        }

        final totalTime = stopwatch.elapsedMilliseconds;
        stopwatch.stop();

        // Performance assertions
        expect(
          totalTime,
          lessThan(3000),
          reason: 'Session validation should complete within 3 seconds',
        );

        final avgTimePerValidation = totalTime / validationIterations;
        expect(
          avgTimePerValidation,
          lessThan(1.0),
          reason: 'Average validation time should be less than 1ms',
        );
      });

      test('should handle concurrent session operations', () async {
        const concurrentSessions = 100;
        final stopwatch = Stopwatch()..start();

        // Create concurrent session operations
        final futures = <Future>[];
        for (int i = 0; i < concurrentSessions; i++) {
          futures.add(
            Future(() async {
              // Generate session
              final token = securityManager.generateSessionToken();

              // Validate multiple times
              for (int j = 0; j < 50; j++) {
                final isValid = securityManager.validateSession(token);
                expect(isValid, isTrue);

                // Add small delay
                await Future.delayed(Duration(microseconds: 10));
              }

              // Invalidate session
              securityManager.invalidateSession();
            }),
          );
        }

        await Future.wait(futures);
        final totalTime = stopwatch.elapsedMilliseconds;
        stopwatch.stop();

        // Performance assertions
        expect(
          totalTime,
          lessThan(8000),
          reason:
              'Concurrent session operations should complete within 8 seconds',
        );
      });

      test('should handle security event logging under load', () async {
        const securityEventIterations = 3000;
        final stopwatch = Stopwatch()..start();

        // Log various security events
        for (int i = 0; i < securityEventIterations; i++) {
          final eventType = i % 4;

          switch (eventType) {
            case 0:
              securityManager.logSecurityEvent(
                eventType: 'login_attempt',
                description: 'User login attempt $i',
                metadata: {'user_id': 'user_$i', 'ip': '192.168.1.$i'},
              );
              break;
            case 1:
              securityManager.logSecurityEvent(
                eventType: 'failed_authentication',
                description: 'Failed authentication $i',
                metadata: {'reason': 'invalid_password', 'attempts': i % 5},
              );
              break;
            case 2:
              securityManager.logSecurityEvent(
                eventType: 'session_created',
                description: 'New session created $i',
                metadata: {'session_duration': '${i % 60}m'},
              );
              break;
            case 3:
              securityManager.logSecurityEvent(
                eventType: 'permission_check',
                description: 'Permission check $i',
                metadata: {'resource': 'admin_panel', 'granted': i % 2 == 0},
              );
              break;
          }
        }

        final totalTime = stopwatch.elapsedMilliseconds;
        stopwatch.stop();

        // Performance assertions
        expect(
          totalTime,
          lessThan(6000),
          reason: 'Security event logging should complete within 6 seconds',
        );

        // Verify security logs are accessible
        final securityLogs = securityManager.getSecurityLogs();
        expect(securityLogs, isNotNull);
      });
    });

    group('ErrorTrackingService Performance Tests', () {
      test('should handle high-frequency error tracking', () async {
        const errorIterations = 8000;
        final stopwatch = Stopwatch()..start();

        // Track various types of errors
        for (int i = 0; i < errorIterations; i++) {
          final errorType = i % 5;

          switch (errorType) {
            case 0:
              await errorTrackingService.trackError(
                errorType: 'network_error',
                errorMessage: 'Network error $i',
                error: Exception('Network error $i'),
                stackTrace: StackTrace.current,
                metadata: {'operation': 'api_call', 'endpoint': '/api/test'},
              );
              break;
            case 1:
              await errorTrackingService.trackError(
                errorType: 'database_error',
                errorMessage: 'Database error $i',
                error: Exception('Database error $i'),
                stackTrace: StackTrace.current,
                metadata: {'query': 'SELECT * FROM users', 'table': 'users'},
              );
              break;
            case 2:
              await errorTrackingService.trackError(
                errorType: 'ui_error',
                errorMessage: 'UI error $i',
                error: Exception('UI error $i'),
                stackTrace: StackTrace.current,
                metadata: {'widget': 'ListView', 'action': 'scroll'},
              );
              break;
            case 3:
              await errorTrackingService.trackError(
                errorType: 'validation_error',
                errorMessage: 'Validation error $i',
                error: Exception('Validation error $i'),
                stackTrace: StackTrace.current,
                metadata: {'field': 'email', 'value': 'invalid_email'},
              );
              break;
            case 4:
              await errorTrackingService.trackError(
                errorType: 'performance_error',
                errorMessage: 'Performance error $i',
                error: Exception('Performance error $i'),
                stackTrace: StackTrace.current,
                metadata: {
                  'operation': 'heavy_computation',
                  'duration_ms': i % 1000,
                },
              );
              break;
          }
        }

        final totalTime = stopwatch.elapsedMilliseconds;
        stopwatch.stop();

        // Performance assertions
        expect(
          totalTime,
          lessThan(15000),
          reason: 'Error tracking should complete within 15 seconds',
        );

        final avgTimePerError = totalTime / errorIterations;
        expect(
          avgTimePerError,
          lessThan(2.0),
          reason: 'Average time per error should be less than 2ms',
        );

        // Verify error statistics
        final errorStats = errorTrackingService.getErrorStatistics();
        expect(errorStats, isNotNull);
        expect(errorStats['total_errors'], greaterThan(0));
      });

      test('should handle concurrent error tracking', () async {
        const concurrentErrors = 50;
        const errorsPerThread = 100;
        final stopwatch = Stopwatch()..start();

        // Create concurrent error tracking tasks
        final futures = <Future>[];
        for (int thread = 0; thread < concurrentErrors; thread++) {
          futures.add(
            Future(() async {
              for (int i = 0; i < errorsPerThread; i++) {
                await errorTrackingService.trackError(
                  errorType: 'concurrent_error',
                  errorMessage:
                      'Concurrent error from thread $thread, iteration $i',
                  error: Exception(
                    'Concurrent error from thread $thread, iteration $i',
                  ),
                  stackTrace: StackTrace.current,
                  metadata: {
                    'thread_id': thread,
                    'iteration': i,
                    'timestamp': DateTime.now().millisecondsSinceEpoch,
                  },
                );

                // Add small random delay
                if (i % 20 == 0) {
                  await Future.delayed(
                    Duration(microseconds: math.Random().nextInt(50)),
                  );
                }
              }
            }),
          );
        }

        await Future.wait(futures);
        final totalTime = stopwatch.elapsedMilliseconds;
        stopwatch.stop();

        // Performance assertions
        expect(
          totalTime,
          lessThan(20000),
          reason: 'Concurrent error tracking should complete within 20 seconds',
        );

        // Verify system stability
        final errorStats = errorTrackingService.getErrorStatistics();
        expect(errorStats, isNotNull);
        expect(errorStats['total_errors'], greaterThan(0));
      });
    });

    group('Memory Management and Resource Cleanup Tests', () {
      test(
        'should maintain stable memory usage under sustained load',
        () async {
          const sustainedLoadDuration = 30; // seconds
          const operationsPerSecond = 100;

          final stopwatch = Stopwatch()..start();
          var operationCount = 0;

          // Run sustained load test
          while (stopwatch.elapsedMilliseconds < sustainedLoadDuration * 1000) {
            // Mix of operations
            final operationType = operationCount % 4;

            switch (operationType) {
              case 0:
                monitoringService.logInfo(
                  'Sustained load test $operationCount',
                );
                break;
              case 1:
                performanceManager.recordEvent(
                  'sustained_event_$operationCount',
                );
                break;
              case 2:
                performanceManager.cacheData(
                  'key_$operationCount',
                  'data_$operationCount',
                );
                break;
              case 3:
                final _ = performanceManager.getCachedData<String>(
                  'key_${operationCount ~/ 2}',
                );
                break;
            }

            operationCount++;

            // Control operation rate
            if (operationCount % operationsPerSecond == 0) {
              await Future.delayed(const Duration(milliseconds: 10));

              // Check system health periodically
              final healthStatus = monitoringService.getHealthStatus();
              expect(healthStatus['status'], isIn(['healthy', 'warning']));
            }
          }

          stopwatch.stop();

          // Verify system is still responsive after sustained load
          final finalHealthStatus = monitoringService.getHealthStatus();
          expect(finalHealthStatus, isNotNull);

          final performanceStats = performanceManager.getPerformanceStats();
          expect(performanceStats, isNotNull);

          // Log completion for debugging
          expect(operationCount, greaterThan(0));
        },
      );

      test('should properly cleanup resources on disposal', () async {
        // Create temporary services for disposal testing
        final tempMonitoringService = MonitoringService();
        await tempMonitoringService.initialize();

        final tempPerformanceManager = PerformanceManager();
        await tempPerformanceManager.initialize();

        // Generate some activity
        for (int i = 0; i < 100; i++) {
          tempMonitoringService.logInfo('Cleanup test $i');
          tempPerformanceManager.recordEvent('cleanup_event_$i');
        }

        // Verify services are active
        expect(tempMonitoringService.getRecentLogs(limit: 10), isNotEmpty);
        expect(tempPerformanceManager.getRecentEvents(limit: 10), isNotEmpty);

        // Dispose services
        final disposeStopwatch = Stopwatch()..start();
        tempMonitoringService.dispose();
        tempPerformanceManager.dispose();
        disposeStopwatch.stop();

        // Disposal should be quick
        expect(disposeStopwatch.elapsedMilliseconds, lessThan(1000));
      });
    });
  });
}
