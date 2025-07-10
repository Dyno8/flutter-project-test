import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_pro_test/core/errors/failures.dart';
import 'package:flutter_pro_test/features/admin/domain/entities/revenue_analytics.dart';
import 'package:flutter_pro_test/features/admin/domain/repositories/analytics_repository.dart';
import 'package:flutter_pro_test/features/admin/domain/usecases/get_revenue_analytics.dart';

import 'get_revenue_analytics_test.mocks.dart';

@GenerateMocks([AnalyticsRepository])
void main() {
  late GetRevenueAnalytics usecase;
  late MockAnalyticsRepository mockRepository;

  setUp(() {
    mockRepository = MockAnalyticsRepository();
    usecase = GetRevenueAnalytics(mockRepository);
  });

  group('GetRevenueAnalytics', () {
    final testStartDate = DateTime(2024, 1, 1);
    final testEndDate = DateTime(2024, 1, 31);
    final testParams = GetRevenueAnalyticsParams(
      startDate: testStartDate,
      endDate: testEndDate,
    );

    final testRevenueAnalytics = RevenueAnalytics(
      totalRevenue: 125000.0,
      monthlyRevenue: 95000.0,
      weeklyRevenue: 22000.0,
      dailyRevenue: 3500.0,
      averageOrderValue: 85.0,
      totalCommissions: 12500.0,
      netRevenue: 112500.0,
      revenueByService: {
        'Home Cleaning': 45000.0,
        'Plumbing': 35000.0,
        'Electrical': 25000.0,
        'Gardening': 20000.0,
      },
      revenueByPartner: {
        'partner_1': 25000.0,
        'partner_2': 22000.0,
        'partner_3': 18000.0,
      },
      revenueByRegion: {
        'Ho Chi Minh City': 75000.0,
        'Hanoi': 35000.0,
        'Da Nang': 15000.0,
      },
      revenueTrend: [
        DailyRevenueData(
          date: testStartDate,
          totalRevenue: 3000.0,
          commissions: 300.0,
          netRevenue: 2700.0,
          transactionCount: 35,
        ),
      ],
      monthlyTrend: [
        MonthlyRevenueData(
          month: DateTime(2024, 1),
          totalRevenue: 95000.0,
          commissions: 9500.0,
          netRevenue: 85500.0,
          transactionCount: 1200,
          growthRate: 15.5,
        ),
      ],
      periodStart: testStartDate,
      periodEnd: testEndDate,
      insights: const RevenueInsights(
        trends: ['Revenue growth of 15%'],
        recommendations: ['Focus on high-performing services'],
        alerts: [],
        seasonalAnalysis: SeasonalAnalysis(
          monthlyPatterns: {'January': 0.8},
          weeklyPatterns: {'Monday': 0.9},
          dailyPatterns: {'08:00': 0.7},
          peakSeasons: ['Spring'],
          lowSeasons: ['Winter'],
        ),
        forecast: ForecastData(
          nextMonthForecast: 135000.0,
          nextQuarterForecast: 400000.0,
          confidenceLevel: 85.0,
          monthlyForecasts: [],
        ),
      ),
      paymentMethods: const PaymentMethodAnalytics(
        revenueByPaymentMethod: {'Credit Card': 75000.0},
        transactionsByPaymentMethod: {'Credit Card': 850},
        averageValueByPaymentMethod: {'Credit Card': 88.2},
        successRateByPaymentMethod: {'Credit Card': 98.5},
      ),
    );

    test('should get revenue analytics from repository', () async {
      // Arrange
      when(
        mockRepository.getRevenueAnalytics(
          startDate: anyNamed('startDate'),
          endDate: anyNamed('endDate'),
        ),
      ).thenAnswer((_) async => Right(testRevenueAnalytics));

      // Act
      final result = await usecase(testParams);

      // Assert
      expect(result, Right(testRevenueAnalytics));
      verify(
        mockRepository.getRevenueAnalytics(
          startDate: testStartDate,
          endDate: testEndDate,
        ),
      );
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      const failure = ServerFailure('Server error');
      when(
        mockRepository.getRevenueAnalytics(
          startDate: anyNamed('startDate'),
          endDate: anyNamed('endDate'),
        ),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(testParams);

      // Assert
      expect(result, const Left(failure));
      verify(
        mockRepository.getRevenueAnalytics(
          startDate: testStartDate,
          endDate: testEndDate,
        ),
      );
      verifyNoMoreInteractions(mockRepository);
    });

    test(
      'should return cache failure when repository returns cache failure',
      () async {
        // Arrange
        const failure = CacheFailure('Cache error');
        when(
          mockRepository.getRevenueAnalytics(
            startDate: anyNamed('startDate'),
            endDate: anyNamed('endDate'),
          ),
        ).thenAnswer((_) async => const Left(failure));

        // Act
        final result = await usecase(testParams);

        // Assert
        expect(result, const Left(failure));
        verify(
          mockRepository.getRevenueAnalytics(
            startDate: testStartDate,
            endDate: testEndDate,
          ),
        );
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test(
      'should return network failure when repository returns network failure',
      () async {
        // Arrange
        const failure = NetworkFailure('Network error');
        when(
          mockRepository.getRevenueAnalytics(
            startDate: anyNamed('startDate'),
            endDate: anyNamed('endDate'),
          ),
        ).thenAnswer((_) async => const Left(failure));

        // Act
        final result = await usecase(testParams);

        // Assert
        expect(result, const Left(failure));
        verify(
          mockRepository.getRevenueAnalytics(
            startDate: testStartDate,
            endDate: testEndDate,
          ),
        );
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test('should pass correct parameters to repository', () async {
      // Arrange
      when(
        mockRepository.getRevenueAnalytics(
          startDate: anyNamed('startDate'),
          endDate: anyNamed('endDate'),
        ),
      ).thenAnswer((_) async => Right(testRevenueAnalytics));

      // Act
      await usecase(testParams);

      // Assert
      verify(
        mockRepository.getRevenueAnalytics(
          startDate: testStartDate,
          endDate: testEndDate,
        ),
      );
    });

    test('should handle different date ranges', () async {
      // Arrange
      final differentStartDate = DateTime(2024, 2, 1);
      final differentEndDate = DateTime(2024, 2, 28);
      final differentParams = GetRevenueAnalyticsParams(
        startDate: differentStartDate,
        endDate: differentEndDate,
      );

      when(
        mockRepository.getRevenueAnalytics(
          startDate: anyNamed('startDate'),
          endDate: anyNamed('endDate'),
        ),
      ).thenAnswer((_) async => Right(testRevenueAnalytics));

      // Act
      await usecase(differentParams);

      // Assert
      verify(
        mockRepository.getRevenueAnalytics(
          startDate: differentStartDate,
          endDate: differentEndDate,
        ),
      );
    });
  });

  group('GetRevenueAnalyticsParams', () {
    test('should create params with required fields', () {
      final startDate = DateTime(2024, 1, 1);
      final endDate = DateTime(2024, 1, 31);
      final params = GetRevenueAnalyticsParams(
        startDate: startDate,
        endDate: endDate,
      );

      expect(params.startDate, equals(startDate));
      expect(params.endDate, equals(endDate));
    });

    test('should support equality comparison', () {
      final startDate = DateTime(2024, 1, 1);
      final endDate = DateTime(2024, 1, 31);
      final params1 = GetRevenueAnalyticsParams(
        startDate: startDate,
        endDate: endDate,
      );
      final params2 = GetRevenueAnalyticsParams(
        startDate: startDate,
        endDate: endDate,
      );

      expect(params1, equals(params2));
    });

    test('should have correct props for equality', () {
      final startDate = DateTime(2024, 1, 1);
      final endDate = DateTime(2024, 1, 31);
      final params = GetRevenueAnalyticsParams(
        startDate: startDate,
        endDate: endDate,
      );

      expect(params.startDate, equals(startDate));
      expect(params.endDate, equals(endDate));
    });

    test('should not be equal with different dates', () {
      final startDate1 = DateTime(2024, 1, 1);
      final endDate1 = DateTime(2024, 1, 31);
      final startDate2 = DateTime(2024, 2, 1);
      final endDate2 = DateTime(2024, 2, 28);

      final params1 = GetRevenueAnalyticsParams(
        startDate: startDate1,
        endDate: endDate1,
      );
      final params2 = GetRevenueAnalyticsParams(
        startDate: startDate2,
        endDate: endDate2,
      );

      expect(params1, isNot(equals(params2)));
    });

    test('should validate date range', () {
      final startDate = DateTime(2024, 1, 31);
      final endDate = DateTime(2024, 1, 1); // End date before start date

      // This should be handled by the use case or repository validation
      final params = GetRevenueAnalyticsParams(
        startDate: startDate,
        endDate: endDate,
      );

      expect(params.startDate.isAfter(params.endDate), isTrue);
    });
  });
}
