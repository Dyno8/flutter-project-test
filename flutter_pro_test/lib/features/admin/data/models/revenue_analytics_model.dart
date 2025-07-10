import '../../domain/entities/revenue_analytics.dart';

/// Data model for RevenueAnalytics entity
class RevenueAnalyticsModel extends RevenueAnalytics {
  const RevenueAnalyticsModel({
    required super.totalRevenue,
    required super.monthlyRevenue,
    required super.weeklyRevenue,
    required super.dailyRevenue,
    required super.averageOrderValue,
    required super.totalCommissions,
    required super.netRevenue,
    required super.revenueByService,
    required super.revenueByPartner,
    required super.revenueByRegion,
    required super.revenueTrend,
    required super.monthlyTrend,
    required super.periodStart,
    required super.periodEnd,
    required super.insights,
    required super.paymentMethods,
  });

  /// Create from JSON
  factory RevenueAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return RevenueAnalyticsModel(
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      monthlyRevenue: (json['monthlyRevenue'] as num?)?.toDouble() ?? 0.0,
      weeklyRevenue: (json['weeklyRevenue'] as num?)?.toDouble() ?? 0.0,
      dailyRevenue: (json['dailyRevenue'] as num?)?.toDouble() ?? 0.0,
      averageOrderValue: (json['averageOrderValue'] as num?)?.toDouble() ?? 0.0,
      totalCommissions: (json['totalCommissions'] as num?)?.toDouble() ?? 0.0,
      netRevenue: (json['netRevenue'] as num?)?.toDouble() ?? 0.0,
      revenueByService: Map<String, double>.from(
        (json['revenueByService'] as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(key, (value as num?)?.toDouble() ?? 0.0),
        ) ?? {},
      ),
      revenueByPartner: Map<String, double>.from(
        (json['revenueByPartner'] as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(key, (value as num?)?.toDouble() ?? 0.0),
        ) ?? {},
      ),
      revenueByRegion: Map<String, double>.from(
        (json['revenueByRegion'] as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(key, (value as num?)?.toDouble() ?? 0.0),
        ) ?? {},
      ),
      revenueTrend: (json['revenueTrend'] as List<dynamic>?)
          ?.map((item) => DailyRevenueDataModel.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      monthlyTrend: (json['monthlyTrend'] as List<dynamic>?)
          ?.map((item) => MonthlyRevenueDataModel.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      periodStart: DateTime.parse(json['periodStart'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
      insights: RevenueInsightsModel.fromJson(json['insights'] as Map<String, dynamic>),
      paymentMethods: PaymentMethodAnalyticsModel.fromJson(json['paymentMethods'] as Map<String, dynamic>),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'totalRevenue': totalRevenue,
      'monthlyRevenue': monthlyRevenue,
      'weeklyRevenue': weeklyRevenue,
      'dailyRevenue': dailyRevenue,
      'averageOrderValue': averageOrderValue,
      'totalCommissions': totalCommissions,
      'netRevenue': netRevenue,
      'revenueByService': revenueByService,
      'revenueByPartner': revenueByPartner,
      'revenueByRegion': revenueByRegion,
      'revenueTrend': revenueTrend.map((item) => (item as DailyRevenueDataModel).toJson()).toList(),
      'monthlyTrend': monthlyTrend.map((item) => (item as MonthlyRevenueDataModel).toJson()).toList(),
      'periodStart': periodStart.toIso8601String(),
      'periodEnd': periodEnd.toIso8601String(),
      'insights': (insights as RevenueInsightsModel).toJson(),
      'paymentMethods': (paymentMethods as PaymentMethodAnalyticsModel).toJson(),
    };
  }

  /// Convert to entity
  RevenueAnalytics toEntity() => this;

  /// Create mock data for testing
  factory RevenueAnalyticsModel.mock() {
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 30));
    
    return RevenueAnalyticsModel(
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
        'partner_4': 15000.0,
      },
      revenueByRegion: {
        'Ho Chi Minh City': 75000.0,
        'Hanoi': 35000.0,
        'Da Nang': 15000.0,
      },
      revenueTrend: List.generate(30, (index) {
        final date = startDate.add(Duration(days: index));
        return DailyRevenueDataModel(
          date: date,
          totalRevenue: 3000.0 + (index * 50),
          commissions: 300.0 + (index * 5),
          netRevenue: 2700.0 + (index * 45),
          transactionCount: 35 + index,
        );
      }),
      monthlyTrend: List.generate(12, (index) {
        final month = DateTime(now.year, index + 1);
        return MonthlyRevenueDataModel(
          month: month,
          totalRevenue: 80000.0 + (index * 5000),
          commissions: 8000.0 + (index * 500),
          netRevenue: 72000.0 + (index * 4500),
          transactionCount: 950 + (index * 50),
          growthRate: 5.0 + (index * 0.5),
        );
      }),
      periodStart: startDate,
      periodEnd: now,
      insights: RevenueInsightsModel.mock(),
      paymentMethods: PaymentMethodAnalyticsModel.mock(),
    );
  }
}

/// Data model for DailyRevenueData
class DailyRevenueDataModel extends DailyRevenueData {
  const DailyRevenueDataModel({
    required super.date,
    required super.totalRevenue,
    required super.commissions,
    required super.netRevenue,
    required super.transactionCount,
  });

  factory DailyRevenueDataModel.fromJson(Map<String, dynamic> json) {
    return DailyRevenueDataModel(
      date: DateTime.parse(json['date'] as String),
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      commissions: (json['commissions'] as num?)?.toDouble() ?? 0.0,
      netRevenue: (json['netRevenue'] as num?)?.toDouble() ?? 0.0,
      transactionCount: json['transactionCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'totalRevenue': totalRevenue,
      'commissions': commissions,
      'netRevenue': netRevenue,
      'transactionCount': transactionCount,
    };
  }
}

/// Data model for MonthlyRevenueData
class MonthlyRevenueDataModel extends MonthlyRevenueData {
  const MonthlyRevenueDataModel({
    required super.month,
    required super.totalRevenue,
    required super.commissions,
    required super.netRevenue,
    required super.transactionCount,
    required super.growthRate,
  });

  factory MonthlyRevenueDataModel.fromJson(Map<String, dynamic> json) {
    return MonthlyRevenueDataModel(
      month: DateTime.parse(json['month'] as String),
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      commissions: (json['commissions'] as num?)?.toDouble() ?? 0.0,
      netRevenue: (json['netRevenue'] as num?)?.toDouble() ?? 0.0,
      transactionCount: json['transactionCount'] as int? ?? 0,
      growthRate: (json['growthRate'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'month': month.toIso8601String(),
      'totalRevenue': totalRevenue,
      'commissions': commissions,
      'netRevenue': netRevenue,
      'transactionCount': transactionCount,
      'growthRate': growthRate,
    };
  }
}

/// Data model for RevenueInsights
class RevenueInsightsModel extends RevenueInsights {
  const RevenueInsightsModel({
    required super.trends,
    required super.recommendations,
    required super.alerts,
    required super.seasonalAnalysis,
    required super.forecast,
  });

  factory RevenueInsightsModel.fromJson(Map<String, dynamic> json) {
    return RevenueInsightsModel(
      trends: List<String>.from(json['trends'] as List<dynamic>? ?? []),
      recommendations: List<String>.from(json['recommendations'] as List<dynamic>? ?? []),
      alerts: (json['alerts'] as List<dynamic>?)
          ?.map((item) => RevenueAlertModel.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      seasonalAnalysis: SeasonalAnalysisModel.fromJson(json['seasonalAnalysis'] as Map<String, dynamic>),
      forecast: ForecastDataModel.fromJson(json['forecast'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trends': trends,
      'recommendations': recommendations,
      'alerts': alerts.map((alert) => (alert as RevenueAlertModel).toJson()).toList(),
      'seasonalAnalysis': (seasonalAnalysis as SeasonalAnalysisModel).toJson(),
      'forecast': (forecast as ForecastDataModel).toJson(),
    };
  }

  factory RevenueInsightsModel.mock() {
    return const RevenueInsightsModel(
      trends: [
        'Revenue growth of 15% compared to last month',
        'Home cleaning services showing strongest performance',
        'Weekend bookings generating 40% higher revenue',
      ],
      recommendations: [
        'Focus marketing efforts on high-performing services',
        'Optimize pricing for underperforming regions',
        'Increase partner capacity during peak hours',
      ],
      alerts: [],
      seasonalAnalysis: SeasonalAnalysisModel(
        monthlyPatterns: {
          'January': 0.8,
          'February': 0.9,
          'March': 1.1,
          'April': 1.2,
          'May': 1.3,
          'June': 1.1,
        },
        weeklyPatterns: {
          'Monday': 0.9,
          'Tuesday': 0.8,
          'Wednesday': 0.9,
          'Thursday': 1.0,
          'Friday': 1.2,
          'Saturday': 1.4,
          'Sunday': 1.1,
        },
        dailyPatterns: {
          '08:00': 0.7,
          '10:00': 1.2,
          '14:00': 1.4,
          '16:00': 1.3,
          '18:00': 1.1,
        },
        peakSeasons: ['Spring', 'Summer'],
        lowSeasons: ['Winter'],
      ),
      forecast: ForecastDataModel(
        nextMonthForecast: 135000.0,
        nextQuarterForecast: 400000.0,
        confidenceLevel: 85.0,
        monthlyForecasts: [],
      ),
    );
  }
}

/// Data model for RevenueAlert
class RevenueAlertModel extends RevenueAlert {
  const RevenueAlertModel({
    required super.id,
    required super.type,
    required super.title,
    required super.description,
    required super.severity,
    required super.timestamp,
    super.metadata = const {},
  });

  factory RevenueAlertModel.fromJson(Map<String, dynamic> json) {
    return RevenueAlertModel(
      id: json['id'] as String,
      type: RevenueAlertType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => RevenueAlertType.significantDrop,
      ),
      title: json['title'] as String,
      description: json['description'] as String,
      severity: AlertSeverity.values.firstWhere(
        (e) => e.name == json['severity'],
        orElse: () => AlertSeverity.low,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: Map<String, dynamic>.from(json['metadata'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'description': description,
      'severity': severity.name,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }
}

/// Data model for SeasonalAnalysis
class SeasonalAnalysisModel extends SeasonalAnalysis {
  const SeasonalAnalysisModel({
    required super.monthlyPatterns,
    required super.weeklyPatterns,
    required super.dailyPatterns,
    required super.peakSeasons,
    required super.lowSeasons,
  });

  factory SeasonalAnalysisModel.fromJson(Map<String, dynamic> json) {
    return SeasonalAnalysisModel(
      monthlyPatterns: Map<String, double>.from(
        (json['monthlyPatterns'] as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(key, (value as num?)?.toDouble() ?? 0.0),
        ) ?? {},
      ),
      weeklyPatterns: Map<String, double>.from(
        (json['weeklyPatterns'] as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(key, (value as num?)?.toDouble() ?? 0.0),
        ) ?? {},
      ),
      dailyPatterns: Map<String, double>.from(
        (json['dailyPatterns'] as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(key, (value as num?)?.toDouble() ?? 0.0),
        ) ?? {},
      ),
      peakSeasons: List<String>.from(json['peakSeasons'] as List<dynamic>? ?? []),
      lowSeasons: List<String>.from(json['lowSeasons'] as List<dynamic>? ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'monthlyPatterns': monthlyPatterns,
      'weeklyPatterns': weeklyPatterns,
      'dailyPatterns': dailyPatterns,
      'peakSeasons': peakSeasons,
      'lowSeasons': lowSeasons,
    };
  }
}

/// Data model for ForecastData
class ForecastDataModel extends ForecastData {
  const ForecastDataModel({
    required super.nextMonthForecast,
    required super.nextQuarterForecast,
    required super.confidenceLevel,
    required super.monthlyForecasts,
  });

  factory ForecastDataModel.fromJson(Map<String, dynamic> json) {
    return ForecastDataModel(
      nextMonthForecast: (json['nextMonthForecast'] as num?)?.toDouble() ?? 0.0,
      nextQuarterForecast: (json['nextQuarterForecast'] as num?)?.toDouble() ?? 0.0,
      confidenceLevel: (json['confidenceLevel'] as num?)?.toDouble() ?? 0.0,
      monthlyForecasts: (json['monthlyForecasts'] as List<dynamic>?)
          ?.map((item) => MonthlyForecastModel.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nextMonthForecast': nextMonthForecast,
      'nextQuarterForecast': nextQuarterForecast,
      'confidenceLevel': confidenceLevel,
      'monthlyForecasts': monthlyForecasts.map((item) => (item as MonthlyForecastModel).toJson()).toList(),
    };
  }
}

/// Data model for MonthlyForecast
class MonthlyForecastModel extends MonthlyForecast {
  const MonthlyForecastModel({
    required super.month,
    required super.forecastRevenue,
    required super.confidenceLevel,
  });

  factory MonthlyForecastModel.fromJson(Map<String, dynamic> json) {
    return MonthlyForecastModel(
      month: DateTime.parse(json['month'] as String),
      forecastRevenue: (json['forecastRevenue'] as num?)?.toDouble() ?? 0.0,
      confidenceLevel: (json['confidenceLevel'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'month': month.toIso8601String(),
      'forecastRevenue': forecastRevenue,
      'confidenceLevel': confidenceLevel,
    };
  }
}

/// Data model for PaymentMethodAnalytics
class PaymentMethodAnalyticsModel extends PaymentMethodAnalytics {
  const PaymentMethodAnalyticsModel({
    required super.revenueByPaymentMethod,
    required super.transactionsByPaymentMethod,
    required super.averageValueByPaymentMethod,
    required super.successRateByPaymentMethod,
  });

  factory PaymentMethodAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodAnalyticsModel(
      revenueByPaymentMethod: Map<String, double>.from(
        (json['revenueByPaymentMethod'] as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(key, (value as num?)?.toDouble() ?? 0.0),
        ) ?? {},
      ),
      transactionsByPaymentMethod: Map<String, int>.from(
        (json['transactionsByPaymentMethod'] as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(key, value as int? ?? 0),
        ) ?? {},
      ),
      averageValueByPaymentMethod: Map<String, double>.from(
        (json['averageValueByPaymentMethod'] as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(key, (value as num?)?.toDouble() ?? 0.0),
        ) ?? {},
      ),
      successRateByPaymentMethod: Map<String, double>.from(
        (json['successRateByPaymentMethod'] as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(key, (value as num?)?.toDouble() ?? 0.0),
        ) ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'revenueByPaymentMethod': revenueByPaymentMethod,
      'transactionsByPaymentMethod': transactionsByPaymentMethod,
      'averageValueByPaymentMethod': averageValueByPaymentMethod,
      'successRateByPaymentMethod': successRateByPaymentMethod,
    };
  }

  factory PaymentMethodAnalyticsModel.mock() {
    return const PaymentMethodAnalyticsModel(
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
    );
  }
}
