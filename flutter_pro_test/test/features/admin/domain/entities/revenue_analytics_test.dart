import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pro_test/features/admin/domain/entities/revenue_analytics.dart';

void main() {
  group('RevenueAnalytics', () {
    late RevenueAnalytics revenueAnalytics;
    late DateTime testStartDate;
    late DateTime testEndDate;

    setUp(() {
      testStartDate = DateTime(2024, 1, 1);
      testEndDate = DateTime(2024, 1, 31);

      revenueAnalytics = RevenueAnalytics(
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
          DailyRevenueData(
            date: testStartDate.add(const Duration(days: 1)),
            totalRevenue: 3200.0,
            commissions: 320.0,
            netRevenue: 2880.0,
            transactionCount: 38,
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
          trends: ['Revenue growth of 15% compared to last month'],
          recommendations: [
            'Focus marketing efforts on high-performing services',
          ],
          alerts: [],
          seasonalAnalysis: SeasonalAnalysis(
            monthlyPatterns: {'January': 0.8, 'February': 0.9},
            weeklyPatterns: {'Monday': 0.9, 'Tuesday': 0.8},
            dailyPatterns: {'08:00': 0.7, '10:00': 1.2},
            peakSeasons: ['Spring', 'Summer'],
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
          revenueByPaymentMethod: {
            'Credit Card': 75000.0,
            'Cash': 35000.0,
            'Bank Transfer': 15000.0,
          },
          transactionsByPaymentMethod: {
            'Credit Card': 850,
            'Cash': 420,
            'Bank Transfer': 180,
          },
          averageValueByPaymentMethod: {
            'Credit Card': 88.2,
            'Cash': 83.3,
            'Bank Transfer': 83.3,
          },
          successRateByPaymentMethod: {
            'Credit Card': 98.5,
            'Cash': 100.0,
            'Bank Transfer': 96.7,
          },
        ),
      );
    });

    test('should create RevenueAnalytics with all required fields', () {
      expect(revenueAnalytics.totalRevenue, equals(125000.0));
      expect(revenueAnalytics.monthlyRevenue, equals(95000.0));
      expect(revenueAnalytics.weeklyRevenue, equals(22000.0));
      expect(revenueAnalytics.dailyRevenue, equals(3500.0));
      expect(revenueAnalytics.averageOrderValue, equals(85.0));
      expect(revenueAnalytics.totalCommissions, equals(12500.0));
      expect(revenueAnalytics.netRevenue, equals(112500.0));
      expect(revenueAnalytics.periodStart, equals(testStartDate));
      expect(revenueAnalytics.periodEnd, equals(testEndDate));
    });

    test('should have correct revenue by service breakdown', () {
      expect(
        revenueAnalytics.revenueByService['Home Cleaning'],
        equals(45000.0),
      );
      expect(revenueAnalytics.revenueByService['Plumbing'], equals(35000.0));
      expect(revenueAnalytics.revenueByService['Electrical'], equals(25000.0));
      expect(revenueAnalytics.revenueByService['Gardening'], equals(20000.0));
    });

    test('should have correct revenue by partner breakdown', () {
      expect(revenueAnalytics.revenueByPartner['partner_1'], equals(25000.0));
      expect(revenueAnalytics.revenueByPartner['partner_2'], equals(22000.0));
      expect(revenueAnalytics.revenueByPartner['partner_3'], equals(18000.0));
    });

    test('should have correct revenue by region breakdown', () {
      expect(
        revenueAnalytics.revenueByRegion['Ho Chi Minh City'],
        equals(75000.0),
      );
      expect(revenueAnalytics.revenueByRegion['Hanoi'], equals(35000.0));
      expect(revenueAnalytics.revenueByRegion['Da Nang'], equals(15000.0));
    });

    test('should have revenue trend data', () {
      expect(revenueAnalytics.revenueTrend.length, equals(2));
      expect(revenueAnalytics.revenueTrend[0].totalRevenue, equals(3000.0));
      expect(revenueAnalytics.revenueTrend[1].totalRevenue, equals(3200.0));
    });

    test('should have monthly trend data', () {
      expect(revenueAnalytics.monthlyTrend.length, equals(1));
      expect(revenueAnalytics.monthlyTrend[0].totalRevenue, equals(95000.0));
      expect(revenueAnalytics.monthlyTrend[0].growthRate, equals(15.5));
    });

    test('should have insights data', () {
      expect(revenueAnalytics.insights.trends.isNotEmpty, isTrue);
      expect(revenueAnalytics.insights.recommendations.isNotEmpty, isTrue);
      expect(
        revenueAnalytics.insights.seasonalAnalysis.peakSeasons.contains(
          'Spring',
        ),
        isTrue,
      );
      expect(
        revenueAnalytics.insights.forecast.nextMonthForecast,
        equals(135000.0),
      );
    });

    test('should have payment method analytics', () {
      expect(
        revenueAnalytics.paymentMethods.revenueByPaymentMethod['Credit Card'],
        equals(75000.0),
      );
      expect(
        revenueAnalytics
            .paymentMethods
            .transactionsByPaymentMethod['Credit Card'],
        equals(850),
      );
      expect(
        revenueAnalytics
            .paymentMethods
            .successRateByPaymentMethod['Credit Card'],
        equals(98.5),
      );
    });

    test('should support equality comparison', () {
      final sameRevenueAnalytics = RevenueAnalytics(
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
        revenueTrend: revenueAnalytics.revenueTrend,
        monthlyTrend: revenueAnalytics.monthlyTrend,
        periodStart: testStartDate,
        periodEnd: testEndDate,
        insights: revenueAnalytics.insights,
        paymentMethods: revenueAnalytics.paymentMethods,
      );

      expect(revenueAnalytics, equals(sameRevenueAnalytics));
    });
  });

  group('DailyRevenueData', () {
    test('should create DailyRevenueData with all fields', () {
      final date = DateTime(2024, 1, 1);
      final dailyData = DailyRevenueData(
        date: date,
        totalRevenue: 3000.0,
        commissions: 300.0,
        netRevenue: 2700.0,
        transactionCount: 35,
      );

      expect(dailyData.date, equals(date));
      expect(dailyData.totalRevenue, equals(3000.0));
      expect(dailyData.commissions, equals(300.0));
      expect(dailyData.netRevenue, equals(2700.0));
      expect(dailyData.transactionCount, equals(35));
    });

    test('should support equality comparison', () {
      final date = DateTime(2024, 1, 1);
      final dailyData1 = DailyRevenueData(
        date: date,
        totalRevenue: 3000.0,
        commissions: 300.0,
        netRevenue: 2700.0,
        transactionCount: 35,
      );
      final dailyData2 = DailyRevenueData(
        date: date,
        totalRevenue: 3000.0,
        commissions: 300.0,
        netRevenue: 2700.0,
        transactionCount: 35,
      );

      expect(dailyData1, equals(dailyData2));
    });
  });

  group('MonthlyRevenueData', () {
    test('should create MonthlyRevenueData with all fields', () {
      final month = DateTime(2024, 1);
      final monthlyData = MonthlyRevenueData(
        month: month,
        totalRevenue: 95000.0,
        commissions: 9500.0,
        netRevenue: 85500.0,
        transactionCount: 1200,
        growthRate: 15.5,
      );

      expect(monthlyData.month, equals(month));
      expect(monthlyData.totalRevenue, equals(95000.0));
      expect(monthlyData.commissions, equals(9500.0));
      expect(monthlyData.netRevenue, equals(85500.0));
      expect(monthlyData.transactionCount, equals(1200));
      expect(monthlyData.growthRate, equals(15.5));
    });
  });

  group('RevenueInsights', () {
    test('should create RevenueInsights with all fields', () {
      const insights = RevenueInsights(
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
      );

      expect(insights.trends.length, equals(1));
      expect(insights.recommendations.length, equals(1));
      expect(insights.alerts.isEmpty, isTrue);
      expect(insights.seasonalAnalysis.peakSeasons.contains('Spring'), isTrue);
      expect(insights.forecast.nextMonthForecast, equals(135000.0));
    });
  });

  group('PaymentMethodAnalytics', () {
    test('should create PaymentMethodAnalytics with all fields', () {
      const paymentAnalytics = PaymentMethodAnalytics(
        revenueByPaymentMethod: {'Credit Card': 75000.0},
        transactionsByPaymentMethod: {'Credit Card': 850},
        averageValueByPaymentMethod: {'Credit Card': 88.2},
        successRateByPaymentMethod: {'Credit Card': 98.5},
      );

      expect(
        paymentAnalytics.revenueByPaymentMethod['Credit Card'],
        equals(75000.0),
      );
      expect(
        paymentAnalytics.transactionsByPaymentMethod['Credit Card'],
        equals(850),
      );
      expect(
        paymentAnalytics.averageValueByPaymentMethod['Credit Card'],
        equals(88.2),
      );
      expect(
        paymentAnalytics.successRateByPaymentMethod['Credit Card'],
        equals(98.5),
      );
    });
  });
}
