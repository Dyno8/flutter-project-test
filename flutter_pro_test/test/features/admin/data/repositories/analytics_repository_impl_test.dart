import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';

import 'package:flutter_pro_test/core/errors/failures.dart';
import 'package:flutter_pro_test/core/errors/exceptions.dart';
import 'package:flutter_pro_test/features/admin/domain/entities/booking_analytics.dart';
import 'package:flutter_pro_test/features/admin/domain/entities/system_metrics.dart';
import 'package:flutter_pro_test/features/admin/domain/repositories/analytics_repository.dart';
import 'package:flutter_pro_test/features/admin/data/repositories/analytics_repository_impl.dart';
import 'package:flutter_pro_test/features/admin/data/datasources/analytics_remote_data_source.dart';
import 'package:flutter_pro_test/features/admin/data/models/system_metrics_model.dart';

import 'analytics_repository_impl_test.mocks.dart';

@GenerateMocks([AnalyticsRemoteDataSource])
void main() {
  group('AnalyticsRepositoryImpl', () {
    late AnalyticsRepositoryImpl repository;
    late MockAnalyticsRemoteDataSource mockRemoteDataSource;

    setUp(() {
      mockRemoteDataSource = MockAnalyticsRemoteDataSource();
      repository = AnalyticsRepositoryImpl(
        remoteDataSource: mockRemoteDataSource,
      );
    });

    group('getBookingAnalytics', () {
      final tStartDate = DateTime.now().subtract(const Duration(days: 30));
      final tEndDate = DateTime.now();
      final tBookingAnalytics = BookingAnalytics(
        totalBookings: 200,
        completedBookings: 150,
        cancelledBookings: 25,
        pendingBookings: 25,
        inProgressBookings: 0,
        averageBookingValue: 50.0,
        totalBookingValue: 7500.0,
        bookingsByService: const {'cleaning': 100, 'maintenance': 50},
        bookingsByTimeSlot: const {'morning': 80, 'afternoon': 120},
        bookingsByStatus: const {
          'completed': 150,
          'cancelled': 25,
          'pending': 25,
        },
        bookingsTrend: const [],
        periodStart: tStartDate,
        periodEnd: tEndDate,
        insights: const BookingInsights(
          trends: ['Increasing bookings on weekends'],
          recommendations: ['Add more partners for peak hours'],
          alerts: [],
          peakHours: PeakHoursAnalysis(
            peakHours: ['14:00', '15:00', '16:00'],
            lowHours: ['08:00', '09:00', '22:00'],
            hourlyDistribution: {'14': 25.0, '15': 30.0, '16': 20.0},
          ),
          servicePerformance: ServicePerformance(
            serviceCompletionRates: {'cleaning': 95.0, 'maintenance': 88.0},
            serviceAverageRatings: {'cleaning': 4.5, 'maintenance': 4.2},
            serviceRevenue: {'cleaning': 5000.0, 'maintenance': 2500.0},
            topPerformingServices: ['cleaning'],
            underperformingServices: ['maintenance'],
          ),
        ),
      );

      test(
        'should return booking analytics when remote data source call is successful',
        () async {
          // arrange
          when(
            mockRemoteDataSource.getBookingAnalytics(
              startDate: anyNamed('startDate'),
              endDate: anyNamed('endDate'),
            ),
          ).thenAnswer((_) async => tBookingAnalytics);

          // act
          final result = await repository.getBookingAnalytics(
            startDate: tStartDate,
            endDate: tEndDate,
          );

          // assert
          expect(result, equals(Right(tBookingAnalytics)));
          verify(
            mockRemoteDataSource.getBookingAnalytics(
              startDate: tStartDate,
              endDate: tEndDate,
            ),
          );
          verifyNoMoreInteractions(mockRemoteDataSource);
        },
      );

      test(
        'should return ServerFailure when remote data source throws ServerException',
        () async {
          // arrange
          when(
            mockRemoteDataSource.getBookingAnalytics(
              startDate: anyNamed('startDate'),
              endDate: anyNamed('endDate'),
            ),
          ).thenThrow(const ServerException('Server error'));

          // act
          final result = await repository.getBookingAnalytics(
            startDate: tStartDate,
            endDate: tEndDate,
          );

          // assert
          expect(result, isA<Left<Failure, BookingAnalytics>>());
          verify(
            mockRemoteDataSource.getBookingAnalytics(
              startDate: tStartDate,
              endDate: tEndDate,
            ),
          );
          verifyNoMoreInteractions(mockRemoteDataSource);
        },
      );

      test(
        'should return NetworkFailure when remote data source throws NetworkException',
        () async {
          // arrange
          when(
            mockRemoteDataSource.getBookingAnalytics(
              startDate: anyNamed('startDate'),
              endDate: anyNamed('endDate'),
            ),
          ).thenThrow(const NetworkException('Network error'));

          // act
          final result = await repository.getBookingAnalytics(
            startDate: tStartDate,
            endDate: tEndDate,
          );

          // assert
          expect(result, isA<Left<Failure, BookingAnalytics>>());
          verify(
            mockRemoteDataSource.getBookingAnalytics(
              startDate: tStartDate,
              endDate: tEndDate,
            ),
          );
          verifyNoMoreInteractions(mockRemoteDataSource);
        },
      );
    });

    group('getSystemMetrics', () {
      final tSystemMetricsModel = SystemMetricsModel(
        totalUsers: 100,
        totalPartners: 50,
        totalBookings: 200,
        activeBookings: 25,
        completedBookings: 150,
        cancelledBookings: 25,
        totalRevenue: 10000.0,
        monthlyRevenue: 5000.0,
        dailyRevenue: 200.0,
        averageRating: 4.5,
        totalReviews: 500,
        timestamp: DateTime.now(),
        performance: SystemPerformance(
          apiResponseTime: 250.0,
          errorRate: 1.5,
          activeConnections: 100,
          memoryUsage: 65.0,
          cpuUsage: 45.0,
          diskUsage: 70.0,
          requestsPerMinute: 500,
          lastUpdated: DateTime.now(),
        ),
      );

      test(
        'should return system metrics when remote data source call is successful',
        () async {
          // arrange
          when(
            mockRemoteDataSource.getSystemMetrics(),
          ).thenAnswer((_) async => tSystemMetricsModel);

          // act
          final result = await repository.getSystemMetrics();

          // assert
          expect(result, isA<Right<Failure, SystemMetrics>>());
          verify(mockRemoteDataSource.getSystemMetrics());
          verifyNoMoreInteractions(mockRemoteDataSource);
        },
      );

      test(
        'should return ServerFailure when remote data source throws ServerException',
        () async {
          // arrange
          when(
            mockRemoteDataSource.getSystemMetrics(),
          ).thenThrow(const ServerException('Server error'));

          // act
          final result = await repository.getSystemMetrics();

          // assert
          expect(result, isA<Left<Failure, SystemMetrics>>());
          verify(mockRemoteDataSource.getSystemMetrics());
          verifyNoMoreInteractions(mockRemoteDataSource);
        },
      );
    });

    // Note: getAnalyticsSummary is implemented in repository layer by combining multiple data sources
    // so it doesn't need direct remote data source testing
  });
}
