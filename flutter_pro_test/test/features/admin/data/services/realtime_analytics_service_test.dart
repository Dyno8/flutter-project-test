import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pro_test/features/admin/data/services/realtime_analytics_service.dart';
import 'package:flutter_pro_test/features/admin/domain/entities/system_metrics.dart';
import 'package:flutter_pro_test/features/admin/domain/entities/booking_analytics.dart';

void main() {
  group('RealtimeAnalyticsService', () {
    late RealtimeAnalyticsService service;

    setUp(() {
      service = RealtimeAnalyticsService();
    });

    tearDown(() {
      service.dispose();
    });

    group('Initialization', () {
      test('should initialize service without errors', () {
        expect(() => service.initialize(), returnsNormally);
      });

      test('should dispose service without errors', () {
        service.initialize();
        expect(() => service.dispose(), returnsNormally);
      });
    });

    group('System Metrics Stream', () {
      test('should provide system metrics stream', () async {
        service.initialize();

        final stream = service.getSystemMetricsStream();
        expect(stream, isA<Stream<SystemMetrics>>());
      });

      test('should emit system metrics data', () async {
        service.initialize();

        final stream = service.getSystemMetricsStream();
        final completer = Completer<SystemMetrics>();

        final subscription = stream.listen((metrics) {
          if (!completer.isCompleted) {
            completer.complete(metrics);
          }
        });

        final metrics = await completer.future.timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw TimeoutException('No metrics received'),
        );

        expect(metrics, isA<SystemMetrics>());
        expect(metrics.totalUsers, greaterThan(0));
        expect(metrics.totalPartners, greaterThan(0));
        expect(metrics.totalBookings, greaterThan(0));
        expect(metrics.averageRating, greaterThanOrEqualTo(0));
        expect(metrics.performance.errorRate, greaterThanOrEqualTo(0));
        expect(metrics.performance.apiResponseTime, greaterThan(0));

        await subscription.cancel();
      });

      test('should emit multiple system metrics updates', () async {
        service.initialize();

        final stream = service.getSystemMetricsStream();
        final metrics = <SystemMetrics>[];
        final completer = Completer<void>();

        final subscription = stream.listen((metric) {
          metrics.add(metric);
          if (metrics.length >= 2) {
            completer.complete();
          }
        });

        await completer.future.timeout(
          const Duration(seconds: 15),
          onTimeout: () =>
              throw TimeoutException('Not enough metrics received'),
        );

        expect(metrics.length, greaterThanOrEqualTo(2));
        expect(metrics[0], isA<SystemMetrics>());
        expect(metrics[1], isA<SystemMetrics>());

        await subscription.cancel();
      });
    });

    group('Booking Analytics Stream', () {
      test('should provide booking analytics stream', () async {
        service.initialize();

        final stream = service.getBookingAnalyticsStream();
        expect(stream, isA<Stream<BookingAnalytics>>());
      });

      test('should emit booking analytics data', () async {
        service.initialize();

        final stream = service.getBookingAnalyticsStream();
        final completer = Completer<BookingAnalytics>();

        final subscription = stream.listen((analytics) {
          if (!completer.isCompleted) {
            completer.complete(analytics);
          }
        });

        final analytics = await completer.future.timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw TimeoutException('No analytics received'),
        );

        expect(analytics, isA<BookingAnalytics>());
        expect(analytics.totalBookings, greaterThan(0));
        expect(analytics.completedBookings, greaterThanOrEqualTo(0));
        expect(analytics.cancelledBookings, greaterThanOrEqualTo(0));
        expect(analytics.pendingBookings, greaterThanOrEqualTo(0));
        expect(analytics.completionRate, greaterThanOrEqualTo(0));
        expect(analytics.completionRate, lessThanOrEqualTo(100));

        await subscription.cancel();
      });
    });

    group('Revenue Stream', () {
      test('should provide revenue stream', () async {
        service.initialize();

        final stream = service.getRevenueStream();
        expect(stream, isA<Stream<double>>());
      });

      test('should emit revenue data', () async {
        service.initialize();

        final stream = service.getRevenueStream();
        final completer = Completer<double>();

        final subscription = stream.listen((revenue) {
          if (!completer.isCompleted) {
            completer.complete(revenue);
          }
        });

        final revenue = await completer.future.timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw TimeoutException('No revenue received'),
        );

        expect(revenue, isA<double>());
        expect(revenue, greaterThan(0));

        await subscription.cancel();
      });
    });

    group('User Count Stream', () {
      test('should provide user count stream', () async {
        service.initialize();

        final stream = service.getUserCountStream();
        expect(stream, isA<Stream<int>>());
      });

      test('should emit user count data', () async {
        service.initialize();

        final stream = service.getUserCountStream();
        final completer = Completer<int>();

        final subscription = stream.listen((userCount) {
          if (!completer.isCompleted) {
            completer.complete(userCount);
          }
        });

        final userCount = await completer.future.timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw TimeoutException('No user count received'),
        );

        expect(userCount, isA<int>());
        expect(userCount, greaterThan(0));

        await subscription.cancel();
      });
    });

    group('Active Bookings Stream', () {
      test('should provide active bookings stream', () async {
        service.initialize();

        final stream = service.getActiveBookingsStream();
        expect(stream, isA<Stream<int>>());
      });

      test('should emit active bookings data', () async {
        service.initialize();

        final stream = service.getActiveBookingsStream();
        final completer = Completer<int>();

        final subscription = stream.listen((activeBookings) {
          if (!completer.isCompleted) {
            completer.complete(activeBookings);
          }
        });

        final activeBookings = await completer.future.timeout(
          const Duration(seconds: 10),
          onTimeout: () =>
              throw TimeoutException('No active bookings received'),
        );

        expect(activeBookings, isA<int>());
        expect(activeBookings, greaterThanOrEqualTo(0));

        await subscription.cancel();
      });
    });

    group('Partner Status Stream', () {
      test('should provide partner status stream', () async {
        service.initialize();

        final stream = service.getPartnerStatusStream();
        expect(stream, isA<Stream<Map<String, int>>>());
      });

      test('should emit partner status data', () async {
        service.initialize();

        final stream = service.getPartnerStatusStream();
        final completer = Completer<Map<String, int>>();

        final subscription = stream.listen((partnerStatus) {
          if (!completer.isCompleted) {
            completer.complete(partnerStatus);
          }
        });

        final partnerStatus = await completer.future.timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw TimeoutException('No partner status received'),
        );

        expect(partnerStatus, isA<Map<String, int>>());
        expect(partnerStatus.containsKey('active'), isTrue);
        expect(partnerStatus.containsKey('inactive'), isTrue);
        expect(partnerStatus.containsKey('suspended'), isTrue);
        expect(partnerStatus['active'], greaterThanOrEqualTo(0));
        expect(partnerStatus['inactive'], greaterThanOrEqualTo(0));
        expect(partnerStatus['suspended'], greaterThanOrEqualTo(0));

        await subscription.cancel();
      });
    });

    group('Multiple Streams', () {
      test('should handle multiple concurrent streams', () async {
        service.initialize();

        final systemMetricsStream = service.getSystemMetricsStream();
        final revenueStream = service.getRevenueStream();
        final userCountStream = service.getUserCountStream();

        final systemMetricsCompleter = Completer<SystemMetrics>();
        final revenueCompleter = Completer<double>();
        final userCountCompleter = Completer<int>();

        final subscriptions = <StreamSubscription>[];

        subscriptions.add(
          systemMetricsStream.listen((metrics) {
            if (!systemMetricsCompleter.isCompleted) {
              systemMetricsCompleter.complete(metrics);
            }
          }),
        );

        subscriptions.add(
          revenueStream.listen((revenue) {
            if (!revenueCompleter.isCompleted) {
              revenueCompleter.complete(revenue);
            }
          }),
        );

        subscriptions.add(
          userCountStream.listen((userCount) {
            if (!userCountCompleter.isCompleted) {
              userCountCompleter.complete(userCount);
            }
          }),
        );

        await Future.wait([
          systemMetricsCompleter.future,
          revenueCompleter.future,
          userCountCompleter.future,
        ]).timeout(
          const Duration(seconds: 15),
          onTimeout: () =>
              throw TimeoutException('Not all streams received data'),
        );

        expect(systemMetricsCompleter.isCompleted, isTrue);
        expect(revenueCompleter.isCompleted, isTrue);
        expect(userCountCompleter.isCompleted, isTrue);

        for (final subscription in subscriptions) {
          await subscription.cancel();
        }
      });

      test('should clean up streams on dispose', () async {
        service.initialize();

        final stream = service.getSystemMetricsStream();
        final subscription = stream.listen((_) {});

        service.dispose();

        // After dispose, the stream should be closed
        expect(() => subscription.cancel(), returnsNormally);
      });
    });

    group('Stream Reuse', () {
      test('should reuse same stream for multiple listeners', () async {
        service.initialize();

        final stream1 = service.getSystemMetricsStream();
        final stream2 = service.getSystemMetricsStream();

        expect(identical(stream1, stream2), isTrue);
      });

      test('should handle multiple listeners on same stream', () async {
        service.initialize();

        final stream = service.getSystemMetricsStream();
        final metrics1 = <SystemMetrics>[];
        final metrics2 = <SystemMetrics>[];

        final subscription1 = stream.listen((metric) => metrics1.add(metric));
        final subscription2 = stream.listen((metric) => metrics2.add(metric));

        await Future.delayed(const Duration(seconds: 8));

        expect(metrics1.isNotEmpty, isTrue);
        expect(metrics2.isNotEmpty, isTrue);
        expect(metrics1.length, equals(metrics2.length));

        await subscription1.cancel();
        await subscription2.cancel();
      });
    });

    group('Error Handling', () {
      test('should handle service disposal gracefully', () {
        service.initialize();
        service.dispose();

        // Should not throw when getting streams after disposal
        expect(() => service.getSystemMetricsStream(), returnsNormally);
      });

      test('should handle multiple dispose calls', () {
        service.initialize();
        service.dispose();

        expect(() => service.dispose(), returnsNormally);
      });
    });
  });
}
