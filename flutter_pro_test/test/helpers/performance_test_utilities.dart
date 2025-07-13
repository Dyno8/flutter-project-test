import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';

/// Utilities for performance testing and benchmarking
class PerformanceTestUtilities {
  /// Measure execution time of a function
  static Future<PerformanceResult> measureExecutionTime<T>(
    Future<T> Function() operation, {
    String? operationName,
    int iterations = 1,
    bool warmup = true,
  }) async {
    final name = operationName ?? 'Operation';
    final results = <Duration>[];

    // Warmup run to avoid cold start effects
    if (warmup && iterations > 1) {
      await operation();
    }

    for (int i = 0; i < iterations; i++) {
      final stopwatch = Stopwatch()..start();
      await operation();
      stopwatch.stop();
      results.add(stopwatch.elapsed);
    }

    return PerformanceResult(
      operationName: name,
      iterations: iterations,
      results: results,
    );
  }

  /// Measure memory usage during operation (simplified)
  static Future<MemoryUsageResult> measureMemoryUsage<T>(
    Future<T> Function() operation, {
    String? operationName,
    Duration sampleInterval = const Duration(milliseconds: 100),
  }) async {
    final name = operationName ?? 'Operation';
    final memorySnapshots = <MemorySnapshot>[];
    Timer? samplingTimer;

    // Start memory sampling
    samplingTimer = Timer.periodic(sampleInterval, (timer) {
      memorySnapshots.add(
        MemorySnapshot(
          timestamp: DateTime.now(),
          // In a real implementation, you would use dart:developer or platform channels
          // to get actual memory usage. For testing, we'll simulate it.
          usedMemoryMB: _simulateMemoryUsage(),
        ),
      );
    });

    final startTime = DateTime.now();
    final result = await operation();
    final endTime = DateTime.now();

    samplingTimer.cancel();

    return MemoryUsageResult(
      operationName: name,
      startTime: startTime,
      endTime: endTime,
      memorySnapshots: memorySnapshots,
      result: result,
    );
  }

  /// Run concurrent operations and measure performance
  static Future<ConcurrencyTestResult> measureConcurrentPerformance<T>(
    Future<T> Function() operation, {
    required int concurrentOperations,
    String? operationName,
    Duration? timeout,
  }) async {
    final name = operationName ?? 'Concurrent Operation';
    final futures = <Future<T>>[];
    final results = <ConcurrentOperationResult<T>>[];

    final overallStopwatch = Stopwatch()..start();

    // Start all operations concurrently
    for (int i = 0; i < concurrentOperations; i++) {
      final operationStopwatch = Stopwatch()..start();
      final future = operation()
          .then((result) {
            operationStopwatch.stop();
            return ConcurrentOperationResult<T>(
              operationId: i,
              result: result,
              duration: operationStopwatch.elapsed,
              completedAt: DateTime.now(),
            );
          })
          .catchError((error, stackTrace) {
            operationStopwatch.stop();
            return ConcurrentOperationResult<T>(
              operationId: i,
              error: error,
              stackTrace: stackTrace,
              duration: operationStopwatch.elapsed,
              completedAt: DateTime.now(),
            );
          });

      futures.add(
        future.then((opResult) {
          results.add(opResult);
          if (opResult.result != null) {
            return opResult.result!;
          } else {
            throw opResult.error ?? Exception('Unknown error');
          }
        }),
      );
    }

    // Wait for all operations to complete
    try {
      if (timeout != null) {
        await Future.wait(futures).timeout(timeout);
      } else {
        await Future.wait(futures);
      }
    } catch (e) {
      // Some operations may have timed out or failed
    }

    overallStopwatch.stop();

    return ConcurrencyTestResult<T>(
      operationName: name,
      concurrentOperations: concurrentOperations,
      totalDuration: overallStopwatch.elapsed,
      results: results,
    );
  }

  /// Create load test scenario
  static Future<LoadTestResult> runLoadTest({
    required Future<void> Function() operation,
    required Duration duration,
    required int operationsPerSecond,
    String? testName,
  }) async {
    final name = testName ?? 'Load Test';
    final results = <LoadTestOperationResult>[];
    final startTime = DateTime.now();
    final endTime = startTime.add(duration);

    final operationInterval = Duration(
      milliseconds: (1000 / operationsPerSecond).round(),
    );

    var operationCount = 0;
    var successCount = 0;
    var errorCount = 0;

    while (DateTime.now().isBefore(endTime)) {
      final operationStartTime = DateTime.now();
      final stopwatch = Stopwatch()..start();

      try {
        await operation();
        stopwatch.stop();
        successCount++;

        results.add(
          LoadTestOperationResult(
            operationId: operationCount,
            startTime: operationStartTime,
            duration: stopwatch.elapsed,
            success: true,
          ),
        );
      } catch (error, stackTrace) {
        stopwatch.stop();
        errorCount++;

        results.add(
          LoadTestOperationResult(
            operationId: operationCount,
            startTime: operationStartTime,
            duration: stopwatch.elapsed,
            success: false,
            error: error,
            stackTrace: stackTrace,
          ),
        );
      }

      operationCount++;

      // Wait for next operation interval
      await Future.delayed(operationInterval);
    }

    return LoadTestResult(
      testName: name,
      duration: duration,
      targetOperationsPerSecond: operationsPerSecond,
      actualOperations: operationCount,
      successfulOperations: successCount,
      failedOperations: errorCount,
      results: results,
    );
  }

  /// Assert performance expectations
  static void assertPerformance(
    PerformanceResult result, {
    Duration? maxAverageTime,
    Duration? maxTotalTime,
    double? maxStandardDeviation,
  }) {
    if (maxAverageTime != null) {
      expect(
        result.averageDuration,
        lessThanOrEqualTo(maxAverageTime),
        reason:
            '${result.operationName} average time exceeded ${maxAverageTime.inMilliseconds}ms',
      );
    }

    if (maxTotalTime != null) {
      expect(
        result.totalDuration,
        lessThanOrEqualTo(maxTotalTime),
        reason:
            '${result.operationName} total time exceeded ${maxTotalTime.inMilliseconds}ms',
      );
    }

    if (maxStandardDeviation != null) {
      expect(
        result.standardDeviation.inMilliseconds,
        lessThanOrEqualTo(maxStandardDeviation),
        reason:
            '${result.operationName} performance too inconsistent (std dev: ${result.standardDeviation.inMilliseconds}ms)',
      );
    }
  }

  /// Assert concurrency performance
  static void assertConcurrencyPerformance(
    ConcurrencyTestResult result, {
    Duration? maxTotalTime,
    double? minSuccessRate,
    Duration? maxAverageOperationTime,
  }) {
    if (maxTotalTime != null) {
      expect(
        result.totalDuration,
        lessThanOrEqualTo(maxTotalTime),
        reason: '${result.operationName} concurrent execution took too long',
      );
    }

    if (minSuccessRate != null) {
      expect(
        result.successRate,
        greaterThanOrEqualTo(minSuccessRate),
        reason:
            '${result.operationName} success rate too low: ${result.successRate}',
      );
    }

    if (maxAverageOperationTime != null) {
      expect(
        result.averageOperationDuration,
        lessThanOrEqualTo(maxAverageOperationTime),
        reason: '${result.operationName} average operation time too high',
      );
    }
  }

  // Helper method to simulate memory usage (for testing purposes)
  static double _simulateMemoryUsage() {
    // Simulate memory usage between 50MB and 200MB
    return 50.0 + (math.Random().nextDouble() * 150.0);
  }
}

/// Result of a performance measurement
class PerformanceResult {
  final String operationName;
  final int iterations;
  final List<Duration> results;

  PerformanceResult({
    required this.operationName,
    required this.iterations,
    required this.results,
  });

  Duration get averageDuration {
    final totalMicroseconds = results
        .map((d) => d.inMicroseconds)
        .reduce((a, b) => a + b);
    return Duration(microseconds: totalMicroseconds ~/ results.length);
  }

  Duration get totalDuration {
    return results.reduce((a, b) => a + b);
  }

  Duration get minDuration => results.reduce((a, b) => a < b ? a : b);
  Duration get maxDuration => results.reduce((a, b) => a > b ? a : b);

  Duration get standardDeviation {
    final avg = averageDuration.inMicroseconds;
    final variance =
        results
            .map((d) => math.pow(d.inMicroseconds - avg, 2))
            .reduce((a, b) => a + b) /
        results.length;
    return Duration(microseconds: math.sqrt(variance).round());
  }

  @override
  String toString() {
    return 'PerformanceResult($operationName: avg=${averageDuration.inMilliseconds}ms, '
        'min=${minDuration.inMilliseconds}ms, max=${maxDuration.inMilliseconds}ms, '
        'iterations=$iterations)';
  }
}

/// Result of memory usage measurement
class MemoryUsageResult<T> {
  final String operationName;
  final DateTime startTime;
  final DateTime endTime;
  final List<MemorySnapshot> memorySnapshots;
  final T result;

  MemoryUsageResult({
    required this.operationName,
    required this.startTime,
    required this.endTime,
    required this.memorySnapshots,
    required this.result,
  });

  Duration get duration => endTime.difference(startTime);
  double get peakMemoryUsage =>
      memorySnapshots.map((s) => s.usedMemoryMB).reduce(math.max);
  double get averageMemoryUsage =>
      memorySnapshots.map((s) => s.usedMemoryMB).reduce((a, b) => a + b) /
      memorySnapshots.length;
}

/// Memory snapshot at a point in time
class MemorySnapshot {
  final DateTime timestamp;
  final double usedMemoryMB;

  MemorySnapshot({required this.timestamp, required this.usedMemoryMB});
}

/// Result of a single concurrent operation
class ConcurrentOperationResult<T> {
  final int operationId;
  final T? result;
  final Object? error;
  final StackTrace? stackTrace;
  final Duration duration;
  final DateTime completedAt;

  ConcurrentOperationResult({
    required this.operationId,
    this.result,
    this.error,
    this.stackTrace,
    required this.duration,
    required this.completedAt,
  });

  bool get isSuccess => error == null;
}

/// Result of concurrent performance test
class ConcurrencyTestResult<T> {
  final String operationName;
  final int concurrentOperations;
  final Duration totalDuration;
  final List<ConcurrentOperationResult<T>> results;

  ConcurrencyTestResult({
    required this.operationName,
    required this.concurrentOperations,
    required this.totalDuration,
    required this.results,
  });

  int get successfulOperations => results.where((r) => r.isSuccess).length;
  int get failedOperations => results.where((r) => !r.isSuccess).length;
  double get successRate => successfulOperations / results.length;

  Duration get averageOperationDuration {
    final totalMicroseconds = results
        .map((r) => r.duration.inMicroseconds)
        .reduce((a, b) => a + b);
    return Duration(microseconds: totalMicroseconds ~/ results.length);
  }
}

/// Result of a single load test operation
class LoadTestOperationResult {
  final int operationId;
  final DateTime startTime;
  final Duration duration;
  final bool success;
  final Object? error;
  final StackTrace? stackTrace;

  LoadTestOperationResult({
    required this.operationId,
    required this.startTime,
    required this.duration,
    required this.success,
    this.error,
    this.stackTrace,
  });
}

/// Result of load test
class LoadTestResult {
  final String testName;
  final Duration duration;
  final int targetOperationsPerSecond;
  final int actualOperations;
  final int successfulOperations;
  final int failedOperations;
  final List<LoadTestOperationResult> results;

  LoadTestResult({
    required this.testName,
    required this.duration,
    required this.targetOperationsPerSecond,
    required this.actualOperations,
    required this.successfulOperations,
    required this.failedOperations,
    required this.results,
  });

  double get actualOperationsPerSecond => actualOperations / duration.inSeconds;
  double get successRate => successfulOperations / actualOperations;

  Duration get averageOperationDuration {
    if (results.isEmpty) return Duration.zero;
    final totalMicroseconds = results
        .map((r) => r.duration.inMicroseconds)
        .reduce((a, b) => a + b);
    return Duration(microseconds: totalMicroseconds ~/ results.length);
  }
}
