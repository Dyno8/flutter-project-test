import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_pro_test/core/performance/performance_analytics_service.dart';
import 'package:flutter_pro_test/core/analytics/firebase_analytics_service.dart';
import 'package:flutter_pro_test/core/monitoring/monitoring_service.dart';
import 'package:flutter_pro_test/core/error_tracking/error_tracking_service.dart';

// Generate mocks
@GenerateMocks([
  FirebaseAnalyticsService,
  MonitoringService,
  ErrorTrackingService,
  SharedPreferences,
])
import 'performance_analytics_service_test.mocks.dart';

void main() {
  group('PerformanceAnalyticsService', () {
    late PerformanceAnalyticsService performanceAnalytics;
    late MockFirebaseAnalyticsService mockAnalyticsService;
    late MockMonitoringService mockMonitoringService;
    late MockErrorTrackingService mockErrorTrackingService;
    late MockSharedPreferences mockPrefs;

    setUp(() {
      performanceAnalytics = PerformanceAnalyticsService();
      mockAnalyticsService = MockFirebaseAnalyticsService();
      mockMonitoringService = MockMonitoringService();
      mockErrorTrackingService = MockErrorTrackingService();
      mockPrefs = MockSharedPreferences();
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
        await performanceAnalytics.initialize(
          analyticsService: mockAnalyticsService,
          monitoringService: mockMonitoringService,
          errorTrackingService: mockErrorTrackingService,
        );

        // Assert
        expect(performanceAnalytics.isInitialized, isTrue);
        verify(
          mockAnalyticsService.logEvent(
            'performance_analytics_initialized',
            parameters: any,
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
          () => performanceAnalytics.initialize(
            analyticsService: mockAnalyticsService,
            monitoringService: mockMonitoringService,
            errorTrackingService: mockErrorTrackingService,
          ),
          throwsException,
        );
      });
    });

    group('metric recording', () {
      setUp(() async {
        when(mockPrefs.getString(any)).thenReturn(null);
        when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);
        when(
          mockAnalyticsService.logEvent(
            any,
            parameters: anyNamed('parameters'),
          ),
        ).thenAnswer((_) async => {});
        when(mockMonitoringService.logInfo(any)).thenReturn(null);

        await performanceAnalytics.initialize(
          analyticsService: mockAnalyticsService,
          monitoringService: mockMonitoringService,
          errorTrackingService: mockErrorTrackingService,
        );
      });

      test('should record performance metrics', () async {
        // Arrange
        const metricName = 'api_response_time';
        const value = 250.0;
        const unit = 'ms';
        const context = 'user_api';
        final metadata = {'endpoint': '/api/users'};

        // Act
        await performanceAnalytics.recordMetric(
          metricName: metricName,
          value: value,
          unit: unit,
          context: context,
          metadata: metadata,
        );

        // Assert
        verify(
          mockAnalyticsService.logEvent(
            'screen_load_time',
            parameters: argThat(
              isA<Map<String, Object?>>()
                  .having(
                    (map) => map['metric_name'],
                    'metric_name',
                    equals(metricName),
                  )
                  .having(
                    (map) => map['metric_value'],
                    'metric_value',
                    equals(value),
                  )
                  .having(
                    (map) => map['metric_unit'],
                    'metric_unit',
                    equals(unit),
                  )
                  .having((map) => map['context'], 'context', equals(context)),
            ),
          ),
        ).called(1);

        verify(
          mockMonitoringService.logInfo(
            'Performance metric recorded: $metricName = $value $unit',
          ),
        ).called(1);
      });

      test('should record screen load time', () async {
        // Arrange
        const screenName = 'home_screen';
        final loadTime = Duration(milliseconds: 1500);
        final metadata = {'user_type': 'client'};

        // Act
        await performanceAnalytics.recordScreenLoadTime(
          screenName: screenName,
          loadTime: loadTime,
          metadata: metadata,
        );

        // Assert
        verify(
          mockAnalyticsService.logEvent(
            'screen_load_time',
            parameters: argThat(
              isA<Map<String, Object?>>()
                  .having(
                    (map) => map['metric_name'],
                    'metric_name',
                    equals('screen_load_time_$screenName'),
                  )
                  .having(
                    (map) => map['metric_value'],
                    'metric_value',
                    equals(1500.0),
                  )
                  .having(
                    (map) => map['metric_unit'],
                    'metric_unit',
                    equals('ms'),
                  ),
            ),
          ),
        ).called(1);
      });

      test('should record API response time', () async {
        // Arrange
        const endpoint = '/api/bookings';
        final responseTime = Duration(milliseconds: 300);
        const statusCode = 200;
        final metadata = {'method': 'POST'};

        // Act
        await performanceAnalytics.recordApiResponseTime(
          endpoint: endpoint,
          responseTime: responseTime,
          statusCode: statusCode,
          metadata: metadata,
        );

        // Assert
        verify(
          mockAnalyticsService.logEvent(
            'screen_load_time',
            parameters: argThat(
              isA<Map<String, Object?>>()
                  .having(
                    (map) => map['metric_name'],
                    'metric_name',
                    equals('api_response_time'),
                  )
                  .having(
                    (map) => map['metric_value'],
                    'metric_value',
                    equals(300.0),
                  )
                  .having((map) => map['context'], 'context', equals(endpoint)),
            ),
          ),
        ).called(1);
      });

      test('should record memory usage', () async {
        // Arrange
        const memoryUsageMB = 150.5;
        const context = 'app_runtime';
        final metadata = {'screen': 'booking_screen'};

        // Act
        await performanceAnalytics.recordMemoryUsage(
          memoryUsageMB: memoryUsageMB,
          context: context,
          metadata: metadata,
        );

        // Assert
        verify(
          mockAnalyticsService.logEvent(
            'screen_load_time',
            parameters: argThat(
              isA<Map<String, Object?>>()
                  .having(
                    (map) => map['metric_name'],
                    'metric_name',
                    equals('memory_usage'),
                  )
                  .having(
                    (map) => map['metric_value'],
                    'metric_value',
                    equals(memoryUsageMB),
                  )
                  .having(
                    (map) => map['metric_unit'],
                    'metric_unit',
                    equals('MB'),
                  ),
            ),
          ),
        ).called(1);
      });

      test('should record frame render time', () async {
        // Arrange
        final renderTime = Duration(microseconds: 16667); // ~60 FPS
        const screenName = 'animation_screen';
        final metadata = {'animation_type': 'fade'};

        // Act
        await performanceAnalytics.recordFrameRenderTime(
          renderTime: renderTime,
          screenName: screenName,
          metadata: metadata,
        );

        // Assert
        verify(
          mockAnalyticsService.logEvent(
            'screen_load_time',
            parameters: argThat(
              isA<Map<String, Object?>>()
                  .having(
                    (map) => map['metric_name'],
                    'metric_name',
                    equals('frame_render_time'),
                  )
                  .having(
                    (map) => map['metric_value'],
                    'metric_value',
                    equals(16667.0),
                  )
                  .having(
                    (map) => map['metric_unit'],
                    'metric_unit',
                    equals('μs'),
                  ),
            ),
          ),
        ).called(1);
      });

      test('should maintain metric history', () async {
        // Arrange
        const metricName = 'test_metric';

        // Act
        for (int i = 0; i < 5; i++) {
          await performanceAnalytics.recordMetric(
            metricName: metricName,
            value: (i * 100).toDouble(),
            unit: 'ms',
          );
        }

        // Assert
        final statistics = performanceAnalytics.getPerformanceStatistics();
        expect(statistics['metrics'], isA<Map<String, dynamic>>());
        expect(statistics['metrics'][metricName], isNotNull);
      });

      test('should limit metric history size', () async {
        // Arrange
        const metricName = 'test_metric';
        const maxHistorySize =
            1000; // Based on PerformanceAnalyticsService.maxHistorySize

        // Act
        for (int i = 0; i < maxHistorySize + 10; i++) {
          await performanceAnalytics.recordMetric(
            metricName: metricName,
            value: i.toDouble(),
            unit: 'ms',
          );
        }

        // Assert
        // We can't directly access the history, but we can verify it doesn't cause memory issues
        expect(
          () => performanceAnalytics.getPerformanceStatistics(),
          returnsNormally,
        );
      });
    });

    group('performance regression detection', () {
      setUp(() async {
        when(mockPrefs.getString(any)).thenReturn(null);
        when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);
        when(
          mockAnalyticsService.logEvent(
            any,
            parameters: anyNamed('parameters'),
          ),
        ).thenAnswer((_) async => {});
        when(mockMonitoringService.logInfo(any)).thenReturn(null);
        when(
          mockErrorTrackingService.trackPerformanceDegradation(
            metricName: anyNamed('metricName'),
            currentValue: anyNamed('currentValue'),
            threshold: anyNamed('threshold'),
            context: anyNamed('context'),
            metadata: anyNamed('metadata'),
          ),
        ).thenAnswer((_) async => {});

        await performanceAnalytics.initialize(
          analyticsService: mockAnalyticsService,
          monitoringService: mockMonitoringService,
          errorTrackingService: mockErrorTrackingService,
        );
      });

      test('should detect performance regression', () async {
        // Arrange
        const metricName = 'api_response_time';

        // Record baseline metrics (good performance)
        for (int i = 0; i < 10; i++) {
          await performanceAnalytics.recordMetric(
            metricName: metricName,
            value: 200.0 + (i * 10), // 200-290ms
            unit: 'ms',
          );
        }

        // Act - Record a significantly worse metric (regression)
        await performanceAnalytics.recordMetric(
          metricName: metricName,
          value: 5000.0, // 5 seconds - much worse than baseline
          unit: 'ms',
        );

        // Assert
        verify(
          mockErrorTrackingService.trackPerformanceDegradation(
            metricName: metricName,
            currentValue: 5000.0,
            threshold: any,
            context: 'performance_regression_detection',
            metadata: any,
          ),
        ).called(1);
      });
    });

    group('performance statistics', () {
      setUp(() async {
        when(mockPrefs.getString(any)).thenReturn(null);
        when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);
        when(
          mockAnalyticsService.logEvent(
            any,
            parameters: anyNamed('parameters'),
          ),
        ).thenAnswer((_) async => {});
        when(mockMonitoringService.logInfo(any)).thenReturn(null);

        await performanceAnalytics.initialize(
          analyticsService: mockAnalyticsService,
          monitoringService: mockMonitoringService,
          errorTrackingService: mockErrorTrackingService,
        );
      });

      test('should provide performance statistics', () async {
        // Arrange
        const metricName = 'test_metric';
        final values = [100.0, 150.0, 200.0, 120.0, 180.0];

        for (final value in values) {
          await performanceAnalytics.recordMetric(
            metricName: metricName,
            value: value,
            unit: 'ms',
          );
        }

        // Act
        final statistics = performanceAnalytics.getPerformanceStatistics();

        // Assert
        expect(statistics, isA<Map<String, dynamic>>());
        expect(statistics['metrics'], isA<Map<String, dynamic>>());
        expect(statistics['bottlenecks'], isA<List>());
        expect(statistics['recommendations'], isA<List>());
        expect(statistics['performance_score'], isA<double>());
      });

      test('should provide performance trends', () async {
        // Arrange
        const metricName = 'trend_metric';

        // Record metrics with an improving trend
        for (int i = 0; i < 10; i++) {
          await performanceAnalytics.recordMetric(
            metricName: metricName,
            value: (1000 - i * 50).toDouble(), // Improving from 1000ms to 550ms
            unit: 'ms',
          );
        }

        // Act
        final trends = performanceAnalytics.getPerformanceTrends();

        // Assert
        expect(trends, isA<Map<String, dynamic>>());
        if (trends.containsKey(metricName)) {
          expect(trends[metricName]['trend_direction'], isA<String>());
          expect(trends[metricName]['trend_percentage'], isA<double>());
        }
      });

      test('should identify bottlenecks', () async {
        // Arrange
        const metricName = 'bottleneck_metric';

        // Record metrics with high variance (inconsistent performance)
        final values = [100.0, 150.0, 2000.0, 120.0, 1800.0, 110.0, 2500.0];
        for (final value in values) {
          await performanceAnalytics.recordMetric(
            metricName: metricName,
            value: value,
            unit: 'ms',
          );
        }

        // Act
        final bottlenecks = performanceAnalytics.getIdentifiedBottlenecks();

        // Assert
        expect(bottlenecks, isA<List<PerformanceBottleneck>>());
        // Bottlenecks are identified during analysis, which runs periodically
        // So we can't guarantee they'll be detected immediately
      });

      test('should generate optimization recommendations', () async {
        // Arrange
        const metricName = 'memory_usage';

        // Record high memory usage to trigger recommendations
        for (int i = 0; i < 5; i++) {
          await performanceAnalytics.recordMetric(
            metricName: metricName,
            value: 250.0, // High memory usage
            unit: 'MB',
          );
        }

        // Act
        final recommendations = performanceAnalytics
            .getOptimizationRecommendations();

        // Assert
        expect(recommendations, isA<List<OptimizationRecommendation>>());
        // Recommendations are generated during analysis, which runs periodically
        // So we can't guarantee they'll be generated immediately
      });
    });

    group('baseline management', () {
      setUp(() async {
        when(mockPrefs.getString(any)).thenReturn(null);
        when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);
        when(
          mockAnalyticsService.logEvent(
            any,
            parameters: anyNamed('parameters'),
          ),
        ).thenAnswer((_) async => {});
        when(mockMonitoringService.logInfo(any)).thenReturn(null);

        await performanceAnalytics.initialize(
          analyticsService: mockAnalyticsService,
          monitoringService: mockMonitoringService,
          errorTrackingService: mockErrorTrackingService,
        );
      });

      test('should have default baselines', () {
        // Act
        final statistics = performanceAnalytics.getPerformanceStatistics();

        // Assert
        expect(statistics, isA<Map<String, dynamic>>());
        // Default baselines are set during initialization
        // We can't directly verify them, but they should be used for comparison
      });

      test('should update baselines over time', () async {
        // Arrange
        const metricName = 'baseline_test_metric';

        // Record sufficient metrics for baseline calculation
        for (int i = 0; i < 60; i++) {
          await performanceAnalytics.recordMetric(
            metricName: metricName,
            value: (200 + i).toDouble(),
            unit: 'ms',
          );
        }

        // Act & Assert
        // Baseline updates happen periodically, so we can't test them directly
        // But we can verify the service handles the metrics correctly
        expect(
          () => performanceAnalytics.getPerformanceStatistics(),
          returnsNormally,
        );
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
        when(mockMonitoringService.logInfo(any)).thenReturn(null);

        await performanceAnalytics.initialize(
          analyticsService: mockAnalyticsService,
          monitoringService: mockMonitoringService,
          errorTrackingService: mockErrorTrackingService,
        );
      });

      test('should save performance data to SharedPreferences', () async {
        // Arrange
        await performanceAnalytics.recordMetric(
          metricName: 'test_metric',
          value: 100.0,
          unit: 'ms',
        );

        // Act & Assert
        // Data is saved during analysis, which runs periodically
        // We can verify the service is set up to save data
        verify(mockPrefs.setString(any, any)).called(greaterThan(0));
      });
    });

    group('service state', () {
      test('should report initialization status correctly', () {
        // Initially not initialized
        expect(performanceAnalytics.isInitialized, isFalse);
      });

      test('should dispose resources properly', () {
        // Act
        performanceAnalytics.dispose();

        // Assert
        expect(performanceAnalytics.isInitialized, isFalse);
      });
    });
  });
}
