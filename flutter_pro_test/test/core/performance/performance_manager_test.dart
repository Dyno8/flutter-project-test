import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_pro_test/core/performance/performance_manager.dart';

void main() {
  group('PerformanceManager', () {
    late PerformanceManager performanceManager;

    setUpAll(() async {
      // Initialize SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
      performanceManager = PerformanceManager();
      await performanceManager.initialize();
    });

    tearDown(() {
      // Clean up after each test
      performanceManager.clearAllCache();
    });

    group('Cache Management', () {
      test('should cache and retrieve data correctly', () {
        const key = 'test_key';
        const data = 'test_data';

        // Cache data
        performanceManager.cacheData(key, data);

        // Retrieve data
        final cachedData = performanceManager.getCachedData<String>(key);
        expect(cachedData, equals(data));
      });

      test('should return null for non-existent cache key', () {
        final cachedData = performanceManager.getCachedData<String>(
          'non_existent',
        );
        expect(cachedData, isNull);
      });

      test('should handle different data types', () {
        // String data
        performanceManager.cacheData('string_key', 'string_value');
        expect(
          performanceManager.getCachedData<String>('string_key'),
          equals('string_value'),
        );

        // Integer data
        performanceManager.cacheData('int_key', 42);
        expect(performanceManager.getCachedData<int>('int_key'), equals(42));

        // List data
        final listData = [1, 2, 3, 4, 5];
        performanceManager.cacheData('list_key', listData);
        expect(
          performanceManager.getCachedData<List<int>>('list_key'),
          equals(listData),
        );

        // Map data
        final mapData = {'key1': 'value1', 'key2': 'value2'};
        performanceManager.cacheData('map_key', mapData);
        expect(
          performanceManager.getCachedData<Map<String, String>>('map_key'),
          equals(mapData),
        );
      });

      test('should check if data is cached', () {
        const key = 'cached_key';
        const data = 'cached_data';

        expect(performanceManager.isCached(key), isFalse);

        performanceManager.cacheData(key, data);
        expect(performanceManager.isCached(key), isTrue);
      });

      test('should clear specific cache entry', () {
        const key = 'clear_test_key';
        const data = 'clear_test_data';

        performanceManager.cacheData(key, data);
        expect(performanceManager.isCached(key), isTrue);

        performanceManager.clearCache(key);
        expect(performanceManager.isCached(key), isFalse);
      });

      test('should clear all cache', () {
        // Cache multiple items
        performanceManager.cacheData('key1', 'data1');
        performanceManager.cacheData('key2', 'data2');
        performanceManager.cacheData('key3', 'data3');

        expect(performanceManager.isCached('key1'), isTrue);
        expect(performanceManager.isCached('key2'), isTrue);
        expect(performanceManager.isCached('key3'), isTrue);

        performanceManager.clearAllCache();

        expect(performanceManager.isCached('key1'), isFalse);
        expect(performanceManager.isCached('key2'), isFalse);
        expect(performanceManager.isCached('key3'), isFalse);
      });

      test('should handle cache size limit', () {
        // Fill cache beyond limit
        for (int i = 0; i < PerformanceManager.maxCacheSize + 10; i++) {
          performanceManager.cacheData('key_$i', 'data_$i');
        }

        final stats = performanceManager.getPerformanceStats();
        expect(
          stats['cache_size'],
          lessThanOrEqualTo(PerformanceManager.maxCacheSize),
        );
      });
    });

    group('Performance Events', () {
      test('should record performance events', () {
        const eventName = 'test_event';
        final duration = const Duration(milliseconds: 100);
        final metadata = {'test': 'metadata'};

        performanceManager.recordEvent(
          eventName,
          duration: duration,
          metadata: metadata,
        );

        final events = performanceManager.getRecentEvents(limit: 1);
        expect(events, hasLength(1));

        final event = events.first;
        expect(event.name, equals(eventName));
        expect(event.duration, equals(duration));
        expect(event.metadata, equals(metadata));
      });

      test('should record events without duration', () {
        const eventName = 'simple_event';

        performanceManager.recordEvent(eventName);

        final events = performanceManager.getRecentEvents(limit: 1);
        expect(events, hasLength(1));

        final event = events.first;
        expect(event.name, equals(eventName));
        expect(event.duration, isNull);
      });

      test('should limit event queue size', () {
        // Record more events than the queue limit
        for (int i = 0; i < PerformanceManager.maxEventQueueSize + 10; i++) {
          performanceManager.recordEvent('event_$i');
        }

        final events = performanceManager.getRecentEvents(
          limit: PerformanceManager.maxEventQueueSize + 10,
        );
        expect(
          events.length,
          lessThanOrEqualTo(PerformanceManager.maxEventQueueSize),
        );
      });

      test('should return recent events in correct order', () async {
        // Record events with delays to ensure different timestamps
        performanceManager.recordEvent('event_1');
        await Future.delayed(const Duration(milliseconds: 1));
        performanceManager.recordEvent('event_2');
        await Future.delayed(const Duration(milliseconds: 1));
        performanceManager.recordEvent('event_3');

        final events = performanceManager.getRecentEvents(limit: 3);
        expect(events, hasLength(3));

        // Should be in reverse chronological order (most recent first)
        expect(events[0].name, equals('event_3'));
        expect(events[1].name, equals('event_2'));
        expect(events[2].name, equals('event_1'));
      });
    });

    group('Performance Statistics', () {
      test('should provide performance statistics', () {
        // Add some cache data
        performanceManager.cacheData('stat_key1', 'data1');
        performanceManager.cacheData('stat_key2', 'data2');

        // Record some events
        performanceManager.recordEvent('stat_event1');
        performanceManager.recordEvent('stat_event2');

        final stats = performanceManager.getPerformanceStats();

        expect(stats, containsPair('cache_size', isA<int>()));
        expect(stats, containsPair('cache_hit_rate', isA<double>()));
        expect(stats, containsPair('memory_usage_bytes', isA<int>()));
        expect(stats, containsPair('total_events', isA<int>()));

        expect(stats['cache_size'], equals(2));
        expect(stats['total_events'], equals(2));
      });

      test('should calculate cache hit rate correctly', () {
        const key = 'hit_rate_key';
        const data = 'hit_rate_data';

        // Cache data
        performanceManager.cacheData(key, data);

        // Generate cache hits
        for (int i = 0; i < 5; i++) {
          performanceManager.getCachedData<String>(key);
        }

        // Generate cache misses
        for (int i = 0; i < 3; i++) {
          performanceManager.getCachedData<String>('non_existent_$i');
        }

        final stats = performanceManager.getPerformanceStats();
        final hitRate = stats['cache_hit_rate'] as double;

        // Hit rate should be 5/(5+3) = 0.625 = 62.5%
        expect(hitRate, closeTo(0.625, 0.01));
      });

      test('should estimate memory usage', () {
        // Add data of different sizes
        performanceManager.cacheData('small', 'x');
        performanceManager.cacheData('medium', 'x' * 100);
        performanceManager.cacheData('large', 'x' * 1000);

        final stats = performanceManager.getPerformanceStats();
        final memoryUsage = stats['memory_usage_bytes'] as int;

        expect(memoryUsage, greaterThan(0));
        expect(
          memoryUsage,
          greaterThan(1000),
        ); // Should account for large string
      });
    });

    group('Performance Benchmarking', () {
      test('should measure cache performance', () async {
        const iterations = 1000;
        final stopwatch = Stopwatch()..start();

        // Benchmark cache writes
        for (int i = 0; i < iterations; i++) {
          performanceManager.cacheData('bench_key_$i', 'bench_data_$i');
        }

        final writeTime = stopwatch.elapsedMicroseconds;
        stopwatch.reset();

        // Benchmark cache reads
        for (int i = 0; i < iterations; i++) {
          performanceManager.getCachedData<String>('bench_key_$i');
        }

        final readTime = stopwatch.elapsedMicroseconds;
        stopwatch.stop();

        // Record benchmark results
        performanceManager.recordEvent(
          'cache_benchmark',
          metadata: {
            'iterations': iterations,
            'write_time_us': writeTime,
            'read_time_us': readTime,
            'avg_write_time_us': writeTime / iterations,
            'avg_read_time_us': readTime / iterations,
          },
        );

        // Verify benchmark was recorded
        final events = performanceManager.getRecentEvents(limit: 1);
        expect(events, hasLength(1));
        expect(events.first.name, equals('cache_benchmark'));
        expect(events.first.metadata['iterations'], equals(iterations));
      });

      test('should measure event recording performance', () {
        const iterations = 1000;
        final stopwatch = Stopwatch()..start();

        for (int i = 0; i < iterations; i++) {
          performanceManager.recordEvent(
            'perf_test_event_$i',
            duration: Duration(milliseconds: i % 100),
            metadata: {'iteration': i},
          );
        }

        final totalTime = stopwatch.elapsedMicroseconds;
        stopwatch.stop();

        final avgTimePerEvent = totalTime / iterations;

        // Event recording should be fast (less than 100 microseconds per event)
        expect(avgTimePerEvent, lessThan(100));

        // Verify all events were recorded (within queue limit)
        final events = performanceManager.getRecentEvents(limit: iterations);
        expect(
          events.length,
          lessThanOrEqualTo(PerformanceManager.maxEventQueueSize),
        );
      });
    });

    group('Load Testing', () {
      test('should handle concurrent cache operations', () async {
        const concurrentOperations = 100;
        final futures = <Future>[];

        // Simulate concurrent cache operations
        for (int i = 0; i < concurrentOperations; i++) {
          futures.add(
            Future(() {
              performanceManager.cacheData('concurrent_key_$i', 'data_$i');
              return performanceManager.getCachedData<String>(
                'concurrent_key_$i',
              );
            }),
          );
        }

        final results = await Future.wait(futures);

        // All operations should complete successfully
        expect(results, hasLength(concurrentOperations));
        for (int i = 0; i < concurrentOperations; i++) {
          expect(results[i], equals('data_$i'));
        }
      });

      test('should maintain performance under load', () async {
        const loadIterations = 5000;
        final stopwatch = Stopwatch()..start();

        // Simulate high load
        for (int i = 0; i < loadIterations; i++) {
          performanceManager.cacheData('load_key_$i', 'load_data_$i');

          if (i % 2 == 0) {
            performanceManager.getCachedData<String>('load_key_${i ~/ 2}');
          }

          if (i % 10 == 0) {
            performanceManager.recordEvent('load_event_$i');
          }
        }

        final totalTime = stopwatch.elapsedMilliseconds;
        stopwatch.stop();

        // Should complete within reasonable time (less than 5 seconds)
        expect(totalTime, lessThan(5000));

        // System should still be responsive
        final stats = performanceManager.getPerformanceStats();
        expect(stats, isNotEmpty);
        expect(stats['cache_size'], isA<int>());
      });
    });
  });
}
