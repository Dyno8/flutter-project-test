import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_pro_test/core/monitoring/monitoring_service.dart';

void main() {
  group('MonitoringService', () {
    late MonitoringService monitoringService;

    setUpAll(() async {
      // Initialize SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
      monitoringService = MonitoringService();
      await monitoringService.initialize();
    });

    tearDown(() {
      // Clean up after each test
      monitoringService.clearLogs();
    });

    group('Logging', () {
      test('should log debug messages', () {
        const message = 'Debug test message';
        final metadata = {'test': 'debug'};

        monitoringService.logDebug(message, metadata: metadata);

        final logs = monitoringService.getRecentLogs(limit: 1);
        expect(logs, hasLength(1));

        final log = logs.first;
        expect(log.level, equals(LogLevel.debug));
        expect(log.message, equals(message));
        expect(log.metadata, equals(metadata));
      });

      test('should log info messages', () {
        const message = 'Info test message';

        monitoringService.logInfo(message);

        final logs = monitoringService.getRecentLogs(limit: 1);
        expect(logs, hasLength(1));
        expect(logs.first.level, equals(LogLevel.info));
        expect(logs.first.message, equals(message));
      });

      test('should log warning messages', () {
        const message = 'Warning test message';
        final metadata = {'warning_type': 'test'};

        monitoringService.logWarning(message, metadata: metadata);

        final logs = monitoringService.getRecentLogs(limit: 1);
        expect(logs, hasLength(1));
        expect(logs.first.level, equals(LogLevel.warning));
        expect(logs.first.message, equals(message));
        expect(logs.first.metadata, equals(metadata));
      });

      test('should log error messages with details', () {
        const message = 'Error test message';
        final error = Exception('Test exception');
        final stackTrace = StackTrace.current;
        final metadata = {'error_code': 'TEST_001'};

        monitoringService.logError(
          message,
          error: error,
          stackTrace: stackTrace,
          metadata: metadata,
        );

        final logs = monitoringService.getRecentLogs(limit: 1);
        expect(logs, hasLength(1));

        final log = logs.first;
        expect(log.level, equals(LogLevel.error));
        expect(log.message, equals(message));
        expect(log.metadata['error'], contains('Test exception'));
        expect(log.metadata['stack_trace'], isA<String>());
        expect(log.metadata['error_code'], equals('TEST_001'));
      });

      test('should log critical messages', () {
        const message = 'Critical test message';
        final error = Exception('Critical exception');

        monitoringService.logCritical(message, error: error);

        final logs = monitoringService.getRecentLogs(limit: 1);
        expect(logs, hasLength(1));
        expect(logs.first.level, equals(LogLevel.critical));
        expect(logs.first.message, equals(message));
      });

      test('should maintain log buffer size limit', () {
        // Generate more logs than the buffer limit
        for (int i = 0; i < MonitoringService.maxLogBufferSize + 10; i++) {
          monitoringService.logInfo('Test message $i');
        }

        final logs = monitoringService.getRecentLogs(
          limit: MonitoringService.maxLogBufferSize + 10,
        );
        expect(
          logs.length,
          lessThanOrEqualTo(MonitoringService.maxLogBufferSize),
        );
      });

      test('should filter logs by minimum level', () {
        // Log messages at different levels
        monitoringService.logDebug('Debug message');
        monitoringService.logInfo('Info message');
        monitoringService.logWarning('Warning message');
        monitoringService.logError('Error message');
        monitoringService.logCritical('Critical message');

        // Get only warning and above
        final warningAndAbove = monitoringService.getRecentLogs(
          minLevel: LogLevel.warning,
        );
        expect(warningAndAbove, hasLength(3)); // warning, error, critical

        for (final log in warningAndAbove) {
          expect(log.level.index, greaterThanOrEqualTo(LogLevel.warning.index));
        }

        // Get only errors and above
        final errorsAndAbove = monitoringService.getRecentLogs(
          minLevel: LogLevel.error,
        );
        expect(errorsAndAbove, hasLength(2)); // error, critical
      });

      test('should return logs in reverse chronological order', () async {
        // Log messages with small delays to ensure different timestamps
        monitoringService.logInfo('First message');
        await Future.delayed(const Duration(milliseconds: 1));
        monitoringService.logInfo('Second message');
        await Future.delayed(const Duration(milliseconds: 1));
        monitoringService.logInfo('Third message');

        final logs = monitoringService.getRecentLogs(limit: 3);
        expect(logs, hasLength(3));

        // Should be in reverse chronological order (most recent first)
        expect(logs[0].message, equals('Third message'));
        expect(logs[1].message, equals('Second message'));
        expect(logs[2].message, equals('First message'));
      });
    });

    group('Error Statistics', () {
      test('should track error statistics', () {
        // Log some errors
        monitoringService.logError('Error 1');
        monitoringService.logError('Error 2');
        monitoringService.logError('Error 1'); // Duplicate
        monitoringService.logCritical('Critical error');

        final stats = monitoringService.getErrorStats();

        expect(stats, containsPair('total_errors', isA<int>()));
        expect(stats, containsPair('recent_errors_1h', isA<int>()));
        expect(stats, containsPair('unique_errors', isA<int>()));
        expect(stats, containsPair('error_rate_per_minute', isA<double>()));

        expect(stats['total_errors'], greaterThan(0));
        expect(stats['recent_errors_1h'], greaterThan(0));
      });

      test('should calculate error rate correctly', () {
        // Log multiple errors quickly
        for (int i = 0; i < 5; i++) {
          monitoringService.logError('Rapid error $i');
        }

        final stats = monitoringService.getErrorStats();
        final errorRate = stats['error_rate_per_minute'] as double;

        expect(errorRate, greaterThan(0));
        expect(errorRate, equals(5.0)); // 5 errors in the last minute
      });
    });

    group('Health Monitoring', () {
      test('should provide health status', () {
        final healthStatus = monitoringService.getHealthStatus();

        expect(healthStatus, containsPair('timestamp', isA<String>()));
        expect(healthStatus, containsPair('status', isA<String>()));
        expect(healthStatus, containsPair('checks', isA<Map>()));

        final checks = healthStatus['checks'] as Map<String, dynamic>;
        expect(checks, containsPair('memory', isA<Map>()));
        expect(checks, containsPair('error_rate', isA<Map>()));
        expect(checks, containsPair('storage', isA<Map>()));
      });

      test('should detect high error rate in health check', () {
        // Generate high error rate
        for (int i = 0; i < MonitoringService.maxErrorsPerMinute + 1; i++) {
          monitoringService.logError('High rate error $i');
        }

        final healthStatus = monitoringService.getHealthStatus();
        final checks = healthStatus['checks'] as Map<String, dynamic>;
        final errorRateCheck = checks['error_rate'] as Map<String, dynamic>;

        expect(healthStatus['status'], equals('error'));
        expect(errorRateCheck, containsPair('error', isA<String>()));
      });

      test('should report healthy status under normal conditions', () {
        // Log a few normal messages
        monitoringService.logInfo('Normal operation');
        monitoringService.logDebug('Debug info');

        final healthStatus = monitoringService.getHealthStatus();

        // Should be healthy with low error rate and normal memory usage
        expect(
          healthStatus['status'],
          anyOf(equals('healthy'), equals('warning')),
        );
      });
    });

    group('Log Management', () {
      test('should clear all logs', () {
        // Add some logs
        monitoringService.logInfo('Test log 1');
        monitoringService.logError('Test error 1');
        monitoringService.logWarning('Test warning 1');

        expect(monitoringService.getRecentLogs(), isNotEmpty);

        // Clear logs
        monitoringService.clearLogs();

        // Should have only the "All logs cleared" message
        final logs = monitoringService.getRecentLogs();
        expect(logs, hasLength(1));
        expect(logs.first.message, equals('All logs cleared'));
      });

      test('should handle log serialization', () {
        const message = 'Serialization test';
        final metadata = {
          'string': 'value',
          'number': 42,
          'boolean': true,
          'list': [1, 2, 3],
          'map': {'nested': 'value'},
        };

        monitoringService.logInfo(message, metadata: metadata);

        final logs = monitoringService.getRecentLogs(limit: 1);
        expect(logs, hasLength(1));

        final log = logs.first;
        final json = log.toJson();

        expect(json, containsPair('level', 'info'));
        expect(json, containsPair('message', message));
        expect(json, containsPair('timestamp', isA<String>()));
        expect(json, containsPair('metadata', metadata));

        // Verify timestamp is valid ISO 8601
        expect(() => DateTime.parse(json['timestamp']), returnsNormally);
      });
    });

    group('Performance Impact', () {
      test('should handle high-frequency logging efficiently', () {
        const iterations = 1000;
        final stopwatch = Stopwatch()..start();

        for (int i = 0; i < iterations; i++) {
          monitoringService.logInfo(
            'High frequency log $i',
            metadata: {'iteration': i},
          );
        }

        final totalTime = stopwatch.elapsedMilliseconds;
        stopwatch.stop();

        // Should complete within reasonable time (less than 1 second)
        expect(totalTime, lessThan(1000));

        // Verify logs were recorded (within buffer limit)
        final logs = monitoringService.getRecentLogs(limit: iterations);
        expect(
          logs.length,
          lessThanOrEqualTo(MonitoringService.maxLogBufferSize),
        );
      });

      test('should handle concurrent logging', () async {
        const concurrentLogs = 100;
        final futures = <Future>[];

        // Simulate concurrent logging from multiple sources
        for (int i = 0; i < concurrentLogs; i++) {
          futures.add(
            Future(() {
              monitoringService.logInfo('Concurrent log $i');
            }),
          );
        }

        await Future.wait(futures);

        // All logs should be recorded (within buffer limit)
        final logs = monitoringService.getRecentLogs(limit: concurrentLogs);
        expect(
          logs.length,
          lessThanOrEqualTo(MonitoringService.maxLogBufferSize),
        );
      });
    });

    group('Integration Tests', () {
      test('should handle complete monitoring workflow', () {
        // Simulate application startup
        monitoringService.logInfo('Application started');

        // Simulate normal operations
        monitoringService.logDebug('Processing user request');
        monitoringService.logInfo('User authenticated successfully');

        // Simulate warning condition
        monitoringService.logWarning(
          'High memory usage detected',
          metadata: {'memory_mb': 450},
        );

        // Simulate error condition
        monitoringService.logError(
          'Database connection failed',
          error: Exception('Connection timeout'),
          metadata: {'retry_count': 3},
        );

        // Simulate recovery
        monitoringService.logInfo('Database connection restored');

        // Check health status
        final healthStatus = monitoringService.getHealthStatus();
        expect(healthStatus, isNotEmpty);

        // Check error statistics
        final errorStats = monitoringService.getErrorStats();
        expect(errorStats['total_errors'], greaterThan(0));

        // Check logs
        final logs = monitoringService.getRecentLogs();
        expect(logs.length, equals(6)); // All logged messages

        // Verify log levels are correct
        final logLevels = logs.map((log) => log.level).toList();
        expect(logLevels, contains(LogLevel.info));
        expect(logLevels, contains(LogLevel.debug));
        expect(logLevels, contains(LogLevel.warning));
        expect(logLevels, contains(LogLevel.error));
      });
    });
  });
}
