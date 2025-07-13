import 'package:flutter_test/flutter_test.dart';
import 'mock_data_generators.dart';

void main() {
  group('Mock Data Generators Tests', () {
    test('should generate analytics event', () {
      final event = MockDataGenerators.generateAnalyticsEvent();

      expect(event, isA<Map<String, dynamic>>());
      expect(event['name'], isNotNull);
      expect(event['userId'], isNotNull);
      expect(event['sessionId'], isNotNull);
      expect(event['timestamp'], isA<DateTime>());
      expect(event['parameters'], isA<Map<String, dynamic>>());
    });

    test('should generate analytics event batch', () {
      final events = MockDataGenerators.generateAnalyticsEventBatch(count: 5);

      expect(events, hasLength(5));
      expect(
        (events.first['timestamp'] as DateTime).isBefore(
          events.last['timestamp'] as DateTime,
        ),
        isTrue,
      );

      for (final event in events) {
        expect(event['name'], isNotNull);
        expect(event['userId'], isNotNull);
        expect(event['sessionId'], isNotNull);
      }
    });

    test('should generate user behavior event', () {
      final event = MockDataGenerators.generateUserBehaviorEvent();

      expect(event, isA<Map<String, dynamic>>());
      expect(event['userId'], isNotNull);
      expect(event['action'], isNotNull);
      expect(event['screen'], isNotNull);
      expect(event['timestamp'], isA<DateTime>());
      expect(event['metadata'], isA<Map<String, dynamic>>());
    });

    test('should generate business metrics', () {
      final metrics = MockDataGenerators.generateBusinessMetrics();

      expect(metrics, isA<Map<String, dynamic>>());
      expect(metrics['date'], isA<DateTime>());
      expect(metrics['totalRevenue'], isA<double>());
      expect(metrics['totalBookings'], isA<int>());
      expect(metrics['activeUsers'], isA<int>());
      expect(metrics['metadata'], isA<Map<String, dynamic>>());
    });

    test('should generate performance metric', () {
      final metric = MockDataGenerators.generatePerformanceMetric();

      expect(metric, isA<Map<String, dynamic>>());
      expect(metric['name'], isNotNull);
      expect(metric['value'], isA<double>());
      expect(metric['timestamp'], isA<DateTime>());
      expect(metric['unit'], isNotNull);
      expect(metric['metadata'], isA<Map<String, dynamic>>());
    });

    test('should generate log entry', () {
      final logEntry = MockDataGenerators.generateLogEntry();

      expect(logEntry, isA<Map<String, dynamic>>());
      expect(logEntry['level'], isNotNull);
      expect(logEntry['message'], isNotNull);
      expect(logEntry['timestamp'], isA<DateTime>());
      expect(logEntry['metadata'], isA<Map<String, dynamic>>());
    });

    test('should generate error incident', () {
      final incident = MockDataGenerators.generateErrorIncident();

      expect(incident, isA<Map<String, dynamic>>());
      expect(incident['id'], isNotNull);
      expect(incident['errorType'], isNotNull);
      expect(incident['errorMessage'], isNotNull);
      expect(incident['timestamp'], isA<DateTime>());
      expect(incident['severity'], isNotNull);
      expect(incident['metadata'], isA<Map<String, dynamic>>());
    });

    test('should generate load test data', () {
      final loadData = MockDataGenerators.generateLoadTestData(
        eventCount: 100,
        userCount: 10,
        timeSpan: const Duration(minutes: 30),
      );

      expect(loadData, isA<Map<String, dynamic>>());
      expect(loadData['events'], hasLength(100));
      expect(loadData['user_behaviors'], hasLength(20)); // Every 5th event
      expect(
        loadData['performance_metrics'],
        hasLength(10),
      ); // Every 10th event
      expect(loadData['log_entries'], hasLength(5)); // Every 20th event
      expect(loadData['error_incidents'], hasLength(1)); // Every 100th event

      final metadata = loadData['metadata'] as Map<String, dynamic>;
      expect(metadata['event_count'], equals(100));
      expect(metadata['user_count'], equals(10));
    });

    test('should generate user journey', () {
      final journey = MockDataGenerators.generateUserJourney(
        userId: 'test_user_123',
        stepCount: 5,
      );

      expect(journey, hasLength(5));
      expect(journey.first['userId'], equals('test_user_123'));

      // Verify journey progression
      for (int i = 1; i < journey.length; i++) {
        expect(
          (journey[i]['timestamp'] as DateTime).isAfter(
            journey[i - 1]['timestamp'] as DateTime,
          ),
          isTrue,
        );
      }

      // Verify all steps have required fields
      for (final step in journey) {
        expect(step['userId'], isNotNull);
        expect(step['action'], isNotNull);
        expect(step['screen'], isNotNull);
        expect(step['timestamp'], isA<DateTime>());
        expect(step['metadata'], isA<Map<String, dynamic>>());
      }
    });

    test('should generate consistent data types', () {
      // Generate multiple instances to verify consistency
      for (int i = 0; i < 10; i++) {
        final event = MockDataGenerators.generateAnalyticsEvent();
        expect(event['name'], isA<String>());
        expect(event['userId'], isA<String>());
        expect(event['sessionId'], isA<String>());
        expect(event['timestamp'], isA<DateTime>());
        expect(event['parameters'], isA<Map<String, dynamic>>());

        final behavior = MockDataGenerators.generateUserBehaviorEvent();
        expect(behavior['userId'], isA<String>());
        expect(behavior['action'], isA<String>());
        expect(behavior['screen'], isA<String>());
        expect(behavior['timestamp'], isA<DateTime>());

        final metric = MockDataGenerators.generatePerformanceMetric();
        expect(metric['name'], isA<String>());
        expect(metric['value'], isA<double>());
        expect(metric['unit'], isA<String>());
      }
    });
  });
}
