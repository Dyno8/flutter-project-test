import 'package:equatable/equatable.dart';

/// Revenue analytics entity for comprehensive financial reporting
class RevenueAnalytics extends Equatable {
  final double totalRevenue;
  final double monthlyRevenue;
  final double weeklyRevenue;
  final double dailyRevenue;
  final double averageOrderValue;
  final double totalCommissions;
  final double netRevenue;
  final Map<String, double> revenueByService;
  final Map<String, double> revenueByPartner;
  final Map<String, double> revenueByRegion;
  final List<DailyRevenueData> revenueTrend;
  final List<MonthlyRevenueData> monthlyTrend;
  final DateTime periodStart;
  final DateTime periodEnd;
  final RevenueInsights insights;
  final PaymentMethodAnalytics paymentMethods;

  const RevenueAnalytics({
    required this.totalRevenue,
    required this.monthlyRevenue,
    required this.weeklyRevenue,
    required this.dailyRevenue,
    required this.averageOrderValue,
    required this.totalCommissions,
    required this.netRevenue,
    required this.revenueByService,
    required this.revenueByPartner,
    required this.revenueByRegion,
    required this.revenueTrend,
    required this.monthlyTrend,
    required this.periodStart,
    required this.periodEnd,
    required this.insights,
    required this.paymentMethods,
  });

  /// Calculate growth rate compared to previous period
  double getGrowthRate(RevenueAnalytics? previousPeriod) {
    if (previousPeriod == null || previousPeriod.totalRevenue == 0) {
      return totalRevenue > 0 ? 100.0 : 0.0;
    }
    return ((totalRevenue - previousPeriod.totalRevenue) / 
            previousPeriod.totalRevenue) * 100;
  }

  /// Get commission rate
  double get commissionRate {
    if (totalRevenue == 0) return 0.0;
    return (totalCommissions / totalRevenue) * 100;
  }

  /// Get top revenue service
  String get topRevenueService {
    if (revenueByService.isEmpty) return 'N/A';
    return revenueByService.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Get top revenue partner
  String get topRevenuePartner {
    if (revenueByPartner.isEmpty) return 'N/A';
    return revenueByPartner.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  @override
  List<Object?> get props => [
        totalRevenue,
        monthlyRevenue,
        weeklyRevenue,
        dailyRevenue,
        averageOrderValue,
        totalCommissions,
        netRevenue,
        revenueByService,
        revenueByPartner,
        revenueByRegion,
        revenueTrend,
        monthlyTrend,
        periodStart,
        periodEnd,
        insights,
        paymentMethods,
      ];
}

/// Daily revenue data for trend analysis
class DailyRevenueData extends Equatable {
  final DateTime date;
  final double totalRevenue;
  final double commissions;
  final double netRevenue;
  final int transactionCount;

  const DailyRevenueData({
    required this.date,
    required this.totalRevenue,
    required this.commissions,
    required this.netRevenue,
    required this.transactionCount,
  });

  double get averageTransactionValue {
    if (transactionCount == 0) return 0.0;
    return totalRevenue / transactionCount;
  }

  @override
  List<Object?> get props => [
        date,
        totalRevenue,
        commissions,
        netRevenue,
        transactionCount,
      ];
}

/// Monthly revenue data for long-term analysis
class MonthlyRevenueData extends Equatable {
  final DateTime month;
  final double totalRevenue;
  final double commissions;
  final double netRevenue;
  final int transactionCount;
  final double growthRate;

  const MonthlyRevenueData({
    required this.month,
    required this.totalRevenue,
    required this.commissions,
    required this.netRevenue,
    required this.transactionCount,
    required this.growthRate,
  });

  @override
  List<Object?> get props => [
        month,
        totalRevenue,
        commissions,
        netRevenue,
        transactionCount,
        growthRate,
      ];
}

/// Revenue insights and recommendations
class RevenueInsights extends Equatable {
  final List<String> trends;
  final List<String> recommendations;
  final List<RevenueAlert> alerts;
  final SeasonalAnalysis seasonalAnalysis;
  final ForecastData forecast;

  const RevenueInsights({
    required this.trends,
    required this.recommendations,
    required this.alerts,
    required this.seasonalAnalysis,
    required this.forecast,
  });

  @override
  List<Object?> get props => [
        trends,
        recommendations,
        alerts,
        seasonalAnalysis,
        forecast,
      ];
}

/// Revenue alert for admin attention
class RevenueAlert extends Equatable {
  final String id;
  final RevenueAlertType type;
  final String title;
  final String description;
  final AlertSeverity severity;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  const RevenueAlert({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.severity,
    required this.timestamp,
    this.metadata = const {},
  });

  @override
  List<Object?> get props => [
        id,
        type,
        title,
        description,
        severity,
        timestamp,
        metadata,
      ];
}

/// Revenue alert types
enum RevenueAlertType {
  significantDrop,
  unusualSpike,
  lowConversion,
  highRefunds,
  paymentIssues;

  String get displayName {
    switch (this) {
      case RevenueAlertType.significantDrop:
        return 'Significant Revenue Drop';
      case RevenueAlertType.unusualSpike:
        return 'Unusual Revenue Spike';
      case RevenueAlertType.lowConversion:
        return 'Low Conversion Rate';
      case RevenueAlertType.highRefunds:
        return 'High Refund Rate';
      case RevenueAlertType.paymentIssues:
        return 'Payment Processing Issues';
    }
  }
}

/// Alert severity levels
enum AlertSeverity {
  low,
  medium,
  high,
  critical;

  String get displayName {
    switch (this) {
      case AlertSeverity.low:
        return 'Low';
      case AlertSeverity.medium:
        return 'Medium';
      case AlertSeverity.high:
        return 'High';
      case AlertSeverity.critical:
        return 'Critical';
    }
  }
}

/// Seasonal analysis for revenue patterns
class SeasonalAnalysis extends Equatable {
  final Map<String, double> monthlyPatterns;
  final Map<String, double> weeklyPatterns;
  final Map<String, double> dailyPatterns;
  final List<String> peakSeasons;
  final List<String> lowSeasons;

  const SeasonalAnalysis({
    required this.monthlyPatterns,
    required this.weeklyPatterns,
    required this.dailyPatterns,
    required this.peakSeasons,
    required this.lowSeasons,
  });

  @override
  List<Object?> get props => [
        monthlyPatterns,
        weeklyPatterns,
        dailyPatterns,
        peakSeasons,
        lowSeasons,
      ];
}

/// Revenue forecast data
class ForecastData extends Equatable {
  final double nextMonthForecast;
  final double nextQuarterForecast;
  final double confidenceLevel;
  final List<MonthlyForecast> monthlyForecasts;

  const ForecastData({
    required this.nextMonthForecast,
    required this.nextQuarterForecast,
    required this.confidenceLevel,
    required this.monthlyForecasts,
  });

  @override
  List<Object?> get props => [
        nextMonthForecast,
        nextQuarterForecast,
        confidenceLevel,
        monthlyForecasts,
      ];
}

/// Monthly forecast data
class MonthlyForecast extends Equatable {
  final DateTime month;
  final double forecastRevenue;
  final double confidenceLevel;

  const MonthlyForecast({
    required this.month,
    required this.forecastRevenue,
    required this.confidenceLevel,
  });

  @override
  List<Object?> get props => [
        month,
        forecastRevenue,
        confidenceLevel,
      ];
}

/// Payment method analytics
class PaymentMethodAnalytics extends Equatable {
  final Map<String, double> revenueByPaymentMethod;
  final Map<String, int> transactionsByPaymentMethod;
  final Map<String, double> averageValueByPaymentMethod;
  final Map<String, double> successRateByPaymentMethod;

  const PaymentMethodAnalytics({
    required this.revenueByPaymentMethod,
    required this.transactionsByPaymentMethod,
    required this.averageValueByPaymentMethod,
    required this.successRateByPaymentMethod,
  });

  String get mostPopularPaymentMethod {
    if (transactionsByPaymentMethod.isEmpty) return 'N/A';
    return transactionsByPaymentMethod.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  @override
  List<Object?> get props => [
        revenueByPaymentMethod,
        transactionsByPaymentMethod,
        averageValueByPaymentMethod,
        successRateByPaymentMethod,
      ];
}
