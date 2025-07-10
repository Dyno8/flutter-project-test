import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';

import 'package:flutter_pro_test/core/errors/failures.dart';
import 'package:flutter_pro_test/features/admin/domain/entities/system_metrics.dart';
import 'package:flutter_pro_test/features/admin/domain/entities/booking_analytics.dart';
import 'package:flutter_pro_test/features/admin/domain/repositories/admin_repository.dart';
import 'package:flutter_pro_test/features/admin/domain/repositories/analytics_repository.dart';
import 'package:flutter_pro_test/features/admin/domain/usecases/get_system_metrics.dart';
import 'package:flutter_pro_test/features/admin/domain/usecases/get_booking_analytics.dart';
import 'package:flutter_pro_test/features/admin/presentation/bloc/admin_dashboard_bloc.dart';

import 'admin_dashboard_bloc_test.mocks.dart';

// Test helper functions
BookingAnalytics _createTestBookingAnalytics({
  int totalBookings = 200,
  int completedBookings = 150,
  int cancelledBookings = 25,
  int pendingBookings = 25,
  int inProgressBookings = 0,
  double averageBookingValue = 50.0,
  double totalBookingValue = 7500.0,
}) {
  return BookingAnalytics(
    totalBookings: totalBookings,
    completedBookings: completedBookings,
    cancelledBookings: cancelledBookings,
    pendingBookings: pendingBookings,
    inProgressBookings: inProgressBookings,
    averageBookingValue: averageBookingValue,
    totalBookingValue: totalBookingValue,
    bookingsByService: const {'cleaning': 100, 'maintenance': 50},
    bookingsByTimeSlot: const {'morning': 80, 'afternoon': 120},
    bookingsByStatus: const {'completed': 150, 'cancelled': 25, 'pending': 25},
    bookingsTrend: const [],
    periodStart: DateTime.now().subtract(const Duration(days: 30)),
    periodEnd: DateTime.now(),
    insights: const BookingInsights(
      trends: ['Increasing bookings on weekends', 'Peak hours: 2-4 PM'],
      recommendations: [
        'Add more partners for peak hours',
        'Promote weekday bookings',
      ],
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
}

SystemMetrics _createTestSystemMetrics({
  int totalUsers = 100,
  int totalPartners = 50,
  int totalBookings = 200,
  int activeBookings = 25,
  int completedBookings = 150,
  int cancelledBookings = 25,
  double totalRevenue = 10000.0,
  double monthlyRevenue = 5000.0,
  double dailyRevenue = 200.0,
  double averageRating = 4.5,
  int totalReviews = 500,
}) {
  return SystemMetrics(
    totalUsers: totalUsers,
    totalPartners: totalPartners,
    totalBookings: totalBookings,
    activeBookings: activeBookings,
    completedBookings: completedBookings,
    cancelledBookings: cancelledBookings,
    totalRevenue: totalRevenue,
    monthlyRevenue: monthlyRevenue,
    dailyRevenue: dailyRevenue,
    averageRating: averageRating,
    totalReviews: totalReviews,
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
}

@GenerateMocks([
  AnalyticsRepository,
  AdminRepository,
  GetSystemMetrics,
  GetBookingAnalytics,
])
void main() {
  group('AdminDashboardBloc', () {
    late AdminDashboardBloc bloc;
    late MockGetSystemMetrics mockGetSystemMetrics;
    late MockGetBookingAnalytics mockGetBookingAnalytics;
    late MockAnalyticsRepository mockAnalyticsRepository;

    setUp(() {
      mockGetSystemMetrics = MockGetSystemMetrics();
      mockGetBookingAnalytics = MockGetBookingAnalytics();
      mockAnalyticsRepository = MockAnalyticsRepository();

      bloc = AdminDashboardBloc(
        getSystemMetrics: mockGetSystemMetrics,
        getBookingAnalytics: mockGetBookingAnalytics,
        analyticsRepository: mockAnalyticsRepository,
      );
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state should be AdminDashboardInitial', () {
      expect(bloc.state, equals(AdminDashboardInitial()));
    });

    test('should create AdminDashboardBloc successfully', () {
      expect(bloc, isNotNull);
      expect(bloc.state, isA<AdminDashboardInitial>());
    });

    group('AdminDashboardStarted', () {
      final tSystemMetrics = _createTestSystemMetrics();
      final tBookingAnalytics = _createTestBookingAnalytics();

      blocTest<AdminDashboardBloc, AdminDashboardState>(
        'should emit [AdminDashboardLoading, AdminDashboardLoaded] when data is loaded successfully',
        build: () {
          when(
            mockGetSystemMetrics.call(),
          ).thenAnswer((_) async => Right(tSystemMetrics));
          when(
            mockGetBookingAnalytics.call(any),
          ).thenAnswer((_) async => Right(tBookingAnalytics));
          when(
            mockAnalyticsRepository.getAnalyticsSummary(
              startDate: anyNamed('startDate'),
              endDate: anyNamed('endDate'),
            ),
          ).thenAnswer(
            (_) async => Right(
              AnalyticsSummary(
                systemMetrics: tSystemMetrics,
                bookingAnalytics: tBookingAnalytics,
                totalRevenue: 10000.0,
                totalUsers: 100,
                totalPartners: 50,
                keyInsights: [
                  'Revenue increased by 15%',
                  'Booking completion rate improved',
                ],
              ),
            ),
          );

          return bloc;
        },
        act: (bloc) => bloc.add(
          AdminDashboardStarted(
            startDate: DateTime.now().subtract(const Duration(days: 30)),
            endDate: DateTime.now(),
          ),
        ),
        expect: () => [
          AdminDashboardLoading(),
          isA<AdminDashboardLoaded>()
              .having(
                (state) => state.systemMetrics,
                'systemMetrics',
                tSystemMetrics,
              )
              .having(
                (state) => state.bookingAnalytics,
                'bookingAnalytics',
                tBookingAnalytics,
              )
              .having(
                (state) => state.isRealTimeEnabled,
                'isRealTimeEnabled',
                false,
              )
              .having((state) => state.isRefreshing, 'isRefreshing', false),
        ],
        verify: (_) {
          verify(mockGetSystemMetrics.call()).called(1);
          verify(mockGetBookingAnalytics.call(any)).called(1);
          verify(
            mockAnalyticsRepository.getAnalyticsSummary(
              startDate: anyNamed('startDate'),
              endDate: anyNamed('endDate'),
            ),
          ).called(1);
        },
      );

      blocTest<AdminDashboardBloc, AdminDashboardState>(
        'should emit [AdminDashboardLoading, AdminDashboardError] when system metrics fails',
        build: () {
          when(mockGetSystemMetrics.call()).thenAnswer(
            (_) async =>
                const Left(ServerFailure('Failed to get system metrics')),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(
          AdminDashboardStarted(
            startDate: DateTime.now().subtract(const Duration(days: 30)),
            endDate: DateTime.now(),
          ),
        ),
        expect: () => [
          AdminDashboardLoading(),
          isA<AdminDashboardError>().having(
            (state) => state.message,
            'message',
            contains('Failed to get system metrics'),
          ),
        ],
        verify: (_) {
          verify(mockGetSystemMetrics.call()).called(1);
        },
      );

      blocTest<AdminDashboardBloc, AdminDashboardState>(
        'should emit [AdminDashboardLoading, AdminDashboardError] when booking analytics fails',
        build: () {
          when(
            mockGetSystemMetrics.call(),
          ).thenAnswer((_) async => Right(tSystemMetrics));
          when(mockGetBookingAnalytics.call(any)).thenAnswer(
            (_) async =>
                const Left(ServerFailure('Failed to get booking analytics')),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(
          AdminDashboardStarted(
            startDate: DateTime.now().subtract(const Duration(days: 30)),
            endDate: DateTime.now(),
          ),
        ),
        expect: () => [
          AdminDashboardLoading(),
          isA<AdminDashboardError>().having(
            (state) => state.message,
            'message',
            contains('Failed to get booking analytics'),
          ),
        ],
        verify: (_) {
          verify(mockGetSystemMetrics.call()).called(1);
          verify(mockGetBookingAnalytics.call(any)).called(1);
        },
      );
    });
  });
}
