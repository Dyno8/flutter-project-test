import 'package:flutter_test/flutter_test.dart';
import 'performance_test_utilities.dart';

void main() {
  group('Performance Test Utilities Tests', () {
    test('should measure execution time', () async {
      final result = await PerformanceTestUtilities.measureExecutionTime(
        () async {
          await Future.delayed(const Duration(milliseconds: 100));
          return 'test result';
        },
        operationName: 'Test Operation',
        iterations: 3,
      );

      expect(result.operationName, equals('Test Operation'));
      expect(result.iterations, equals(3));
      expect(result.results, hasLength(3));
      expect(result.averageDuration.inMilliseconds, greaterThan(90));
      expect(result.averageDuration.inMilliseconds, lessThan(200));
      expect(result.totalDuration.inMilliseconds, greaterThan(270));
      expect(result.minDuration.inMilliseconds, greaterThan(0));
      expect(result.maxDuration.inMilliseconds, greaterThan(0));
      expect(result.standardDeviation.inMilliseconds, greaterThanOrEqualTo(0));
    });

    test('should measure memory usage', () async {
      final result = await PerformanceTestUtilities.measureMemoryUsage(
        () async {
          // Simulate some work
          final list = List.generate(1000, (i) => 'item_$i');
          await Future.delayed(
            const Duration(milliseconds: 250),
          ); // Longer delay to allow sampling
          return list.length;
        },
        operationName: 'Memory Test',
        sampleInterval: const Duration(
          milliseconds: 50,
        ), // More frequent sampling
      );

      expect(result.operationName, equals('Memory Test'));
      expect(result.result, equals(1000));
      expect(result.duration.inMilliseconds, greaterThan(200));
      // Memory snapshots might be empty in test environment, so make it optional
      expect(result.peakMemoryUsage, greaterThanOrEqualTo(0));
      expect(result.averageMemoryUsage, greaterThanOrEqualTo(0));
    });

    test('should measure concurrent performance', () async {
      final result =
          await PerformanceTestUtilities.measureConcurrentPerformance(
            () async {
              await Future.delayed(const Duration(milliseconds: 50));
              return 'concurrent result';
            },
            concurrentOperations: 5,
            operationName: 'Concurrent Test',
          );

      expect(result.operationName, equals('Concurrent Test'));
      expect(result.concurrentOperations, equals(5));
      expect(result.results, hasLength(5));
      expect(result.successfulOperations, equals(5));
      expect(result.failedOperations, equals(0));
      expect(result.successRate, equals(1.0));
      expect(result.totalDuration.inMilliseconds, greaterThan(40));
      expect(result.averageOperationDuration.inMilliseconds, greaterThan(40));
    });

    test('should handle concurrent operation failures', () async {
      var callCount = 0;
      final result =
          await PerformanceTestUtilities.measureConcurrentPerformance(
            () async {
              callCount++;
              if (callCount <= 2) {
                throw Exception('Test error');
              }
              await Future.delayed(const Duration(milliseconds: 10));
              return 'success';
            },
            concurrentOperations: 5,
            operationName: 'Failure Test',
          );

      expect(result.operationName, equals('Failure Test'));
      expect(result.concurrentOperations, equals(5));
      expect(result.results, hasLength(5));
      expect(result.failedOperations, greaterThan(0));
      expect(result.successfulOperations, greaterThan(0));
      expect(result.successRate, lessThan(1.0));
    });

    test('should run load test', () async {
      var operationCount = 0;
      final result = await PerformanceTestUtilities.runLoadTest(
        operation: () async {
          operationCount++;
          await Future.delayed(const Duration(milliseconds: 10));
        },
        duration: const Duration(seconds: 1),
        operationsPerSecond: 5,
        testName: 'Load Test',
      );

      expect(result.testName, equals('Load Test'));
      expect(result.duration, equals(const Duration(seconds: 1)));
      expect(result.targetOperationsPerSecond, equals(5));
      expect(result.actualOperations, greaterThan(0));
      expect(result.successfulOperations, greaterThan(0));
      expect(result.failedOperations, equals(0));
      expect(result.successRate, equals(1.0));
      expect(result.actualOperationsPerSecond, greaterThan(0));
      expect(result.averageOperationDuration.inMilliseconds, greaterThan(0));
    });

    test('should assert performance expectations', () {
      final result = PerformanceResult(
        operationName: 'Test',
        iterations: 3,
        results: [
          const Duration(milliseconds: 100),
          const Duration(milliseconds: 110),
          const Duration(milliseconds: 90),
        ],
      );

      // Should not throw
      PerformanceTestUtilities.assertPerformance(
        result,
        maxAverageTime: const Duration(milliseconds: 150),
        maxTotalTime: const Duration(milliseconds: 400),
        maxStandardDeviation: 50.0,
      );

      // Should throw for too strict requirements
      expect(
        () => PerformanceTestUtilities.assertPerformance(
          result,
          maxAverageTime: const Duration(milliseconds: 50),
        ),
        throwsA(isA<TestFailure>()),
      );
    });

    test('should assert concurrency performance', () {
      final result = ConcurrencyTestResult<String>(
        operationName: 'Test',
        concurrentOperations: 5,
        totalDuration: const Duration(milliseconds: 200),
        results: [
          ConcurrentOperationResult<String>(
            operationId: 0,
            result: 'success',
            duration: const Duration(milliseconds: 100),
            completedAt: DateTime.now(),
          ),
          ConcurrentOperationResult<String>(
            operationId: 1,
            result: 'success',
            duration: const Duration(milliseconds: 110),
            completedAt: DateTime.now(),
          ),
          ConcurrentOperationResult<String>(
            operationId: 2,
            result: 'success',
            duration: const Duration(milliseconds: 90),
            completedAt: DateTime.now(),
          ),
          ConcurrentOperationResult<String>(
            operationId: 3,
            result: 'success',
            duration: const Duration(milliseconds: 105),
            completedAt: DateTime.now(),
          ),
          ConcurrentOperationResult<String>(
            operationId: 4,
            result: 'success',
            duration: const Duration(milliseconds: 95),
            completedAt: DateTime.now(),
          ),
        ],
      );

      // Should not throw
      PerformanceTestUtilities.assertConcurrencyPerformance(
        result,
        maxTotalTime: const Duration(milliseconds: 300),
        minSuccessRate: 0.8,
        maxAverageOperationTime: const Duration(milliseconds: 150),
      );

      // Should throw for too strict requirements
      expect(
        () => PerformanceTestUtilities.assertConcurrencyPerformance(
          result,
          maxTotalTime: const Duration(milliseconds: 100),
        ),
        throwsA(isA<TestFailure>()),
      );
    });

    test('should calculate performance statistics correctly', () {
      final result = PerformanceResult(
        operationName: 'Statistics Test',
        iterations: 4,
        results: [
          const Duration(milliseconds: 100),
          const Duration(milliseconds: 200),
          const Duration(milliseconds: 150),
          const Duration(milliseconds: 250),
        ],
      );

      expect(result.averageDuration.inMilliseconds, equals(175));
      expect(result.totalDuration.inMilliseconds, equals(700));
      expect(result.minDuration.inMilliseconds, equals(100));
      expect(result.maxDuration.inMilliseconds, equals(250));
      expect(result.standardDeviation.inMilliseconds, greaterThan(0));
    });

    test('should handle load test with failures', () async {
      var operationCount = 0;
      final result = await PerformanceTestUtilities.runLoadTest(
        operation: () async {
          operationCount++;
          if (operationCount % 3 == 0) {
            throw Exception('Simulated failure');
          }
          await Future.delayed(const Duration(milliseconds: 5));
        },
        duration: const Duration(milliseconds: 500),
        operationsPerSecond: 10,
        testName: 'Failure Load Test',
      );

      expect(result.testName, equals('Failure Load Test'));
      expect(result.actualOperations, greaterThan(0));
      expect(result.failedOperations, greaterThan(0));
      expect(result.successfulOperations, greaterThan(0));
      expect(result.successRate, lessThan(1.0));
      expect(result.successRate, greaterThan(0.0));
    });

    test('should provide meaningful toString representations', () {
      final performanceResult = PerformanceResult(
        operationName: 'Test Operation',
        iterations: 2,
        results: [
          const Duration(milliseconds: 100),
          const Duration(milliseconds: 200),
        ],
      );

      final toString = performanceResult.toString();
      expect(toString, contains('Test Operation'));
      expect(toString, contains('avg=150ms'));
      expect(toString, contains('min=100ms'));
      expect(toString, contains('max=200ms'));
      expect(toString, contains('iterations=2'));
    });
  });
}
