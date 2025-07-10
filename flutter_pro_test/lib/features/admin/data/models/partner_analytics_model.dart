import '../../domain/entities/partner_analytics.dart';

/// Data model for PartnerAnalytics entity
class PartnerAnalyticsModel extends PartnerAnalytics {
  const PartnerAnalyticsModel({
    required super.totalPartners,
    required super.activePartners,
    required super.newPartners,
    required super.inactivePartners,
    required super.suspendedPartners,
    required super.averageRating,
    required super.averageCompletionRate,
    required super.averageResponseTime,
    required super.partnersByRegion,
    required super.partnersByService,
    required super.partnersByRating,
    required super.partnerGrowthTrend,
    required super.topPerformers,
    required super.underPerformers,
    required super.periodStart,
    required super.periodEnd,
    required super.insights,
    required super.qualityMetrics,
  });

  /// Create from JSON
  factory PartnerAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return PartnerAnalyticsModel(
      totalPartners: json['totalPartners'] as int? ?? 0,
      activePartners: json['activePartners'] as int? ?? 0,
      newPartners: json['newPartners'] as int? ?? 0,
      inactivePartners: json['inactivePartners'] as int? ?? 0,
      suspendedPartners: json['suspendedPartners'] as int? ?? 0,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      averageCompletionRate: (json['averageCompletionRate'] as num?)?.toDouble() ?? 0.0,
      averageResponseTime: (json['averageResponseTime'] as num?)?.toDouble() ?? 0.0,
      partnersByRegion: Map<String, int>.from(
        (json['partnersByRegion'] as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(key, value as int? ?? 0),
        ) ?? {},
      ),
      partnersByService: Map<String, int>.from(
        (json['partnersByService'] as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(key, value as int? ?? 0),
        ) ?? {},
      ),
      partnersByRating: Map<String, int>.from(
        (json['partnersByRating'] as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(key, value as int? ?? 0),
        ) ?? {},
      ),
      partnerGrowthTrend: (json['partnerGrowthTrend'] as List<dynamic>?)
          ?.map((item) => DailyPartnerDataModel.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      topPerformers: (json['topPerformers'] as List<dynamic>?)
          ?.map((item) => PartnerPerformanceDataModel.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      underPerformers: (json['underPerformers'] as List<dynamic>?)
          ?.map((item) => PartnerPerformanceDataModel.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      periodStart: DateTime.parse(json['periodStart'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
      insights: PartnerInsightsModel.fromJson(json['insights'] as Map<String, dynamic>),
      qualityMetrics: PartnerQualityMetricsModel.fromJson(json['qualityMetrics'] as Map<String, dynamic>),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'totalPartners': totalPartners,
      'activePartners': activePartners,
      'newPartners': newPartners,
      'inactivePartners': inactivePartners,
      'suspendedPartners': suspendedPartners,
      'averageRating': averageRating,
      'averageCompletionRate': averageCompletionRate,
      'averageResponseTime': averageResponseTime,
      'partnersByRegion': partnersByRegion,
      'partnersByService': partnersByService,
      'partnersByRating': partnersByRating,
      'partnerGrowthTrend': partnerGrowthTrend.map((item) => (item as DailyPartnerDataModel).toJson()).toList(),
      'topPerformers': topPerformers.map((item) => (item as PartnerPerformanceDataModel).toJson()).toList(),
      'underPerformers': underPerformers.map((item) => (item as PartnerPerformanceDataModel).toJson()).toList(),
      'periodStart': periodStart.toIso8601String(),
      'periodEnd': periodEnd.toIso8601String(),
      'insights': (insights as PartnerInsightsModel).toJson(),
      'qualityMetrics': (qualityMetrics as PartnerQualityMetricsModel).toJson(),
    };
  }

  /// Convert to entity
  PartnerAnalytics toEntity() => this;

  /// Create mock data for testing
  factory PartnerAnalyticsModel.mock() {
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 30));
    
    return PartnerAnalyticsModel(
      totalPartners: 1250,
      activePartners: 890,
      newPartners: 125,
      inactivePartners: 285,
      suspendedPartners: 75,
      averageRating: 4.3,
      averageCompletionRate: 87.5,
      averageResponseTime: 2.5,
      partnersByRegion: {
        'Ho Chi Minh City': 620,
        'Hanoi': 380,
        'Da Nang': 145,
        'Can Tho': 105,
      },
      partnersByService: {
        'Home Cleaning': 450,
        'Plumbing': 320,
        'Electrical': 280,
        'Gardening': 200,
      },
      partnersByRating: {
        '5 Stars': 425,
        '4 Stars': 520,
        '3 Stars': 225,
        '2 Stars': 65,
        '1 Star': 15,
      },
      partnerGrowthTrend: List.generate(30, (index) {
        final date = startDate.add(Duration(days: index));
        return DailyPartnerDataModel(
          date: date,
          totalPartners: 1200 + (index * 2),
          newPartners: 3 + (index % 5),
          activePartners: 850 + (index * 1),
          averageRating: 4.2 + (index * 0.003),
          averageCompletionRate: 85.0 + (index * 0.08),
        );
      }),
      topPerformers: List.generate(10, (index) {
        return PartnerPerformanceDataModel(
          partnerId: 'partner_${index + 1}',
          partnerName: 'Top Partner ${index + 1}',
          rating: 4.8 - (index * 0.05),
          completionRate: 95.0 - (index * 1.0),
          responseTime: 1.0 + (index * 0.2),
          totalJobs: 150 - (index * 10),
          completedJobs: 142 - (index * 8),
          totalEarnings: 25000.0 - (index * 2000),
          services: ['Home Cleaning', 'Plumbing'],
          region: 'Ho Chi Minh City',
        );
      }),
      underPerformers: List.generate(5, (index) {
        return PartnerPerformanceDataModel(
          partnerId: 'partner_under_${index + 1}',
          partnerName: 'Partner ${index + 1}',
          rating: 3.0 - (index * 0.2),
          completionRate: 65.0 - (index * 5.0),
          responseTime: 8.0 + (index * 1.0),
          totalJobs: 25 - (index * 3),
          completedJobs: 15 - (index * 2),
          totalEarnings: 3000.0 - (index * 500),
          services: ['Gardening'],
          region: 'Can Tho',
        );
      }),
      periodStart: startDate,
      periodEnd: now,
      insights: PartnerInsightsModel.mock(),
      qualityMetrics: PartnerQualityMetricsModel.mock(),
    );
  }
}

/// Data model for DailyPartnerData
class DailyPartnerDataModel extends DailyPartnerData {
  const DailyPartnerDataModel({
    required super.date,
    required super.totalPartners,
    required super.newPartners,
    required super.activePartners,
    required super.averageRating,
    required super.averageCompletionRate,
  });

  factory DailyPartnerDataModel.fromJson(Map<String, dynamic> json) {
    return DailyPartnerDataModel(
      date: DateTime.parse(json['date'] as String),
      totalPartners: json['totalPartners'] as int? ?? 0,
      newPartners: json['newPartners'] as int? ?? 0,
      activePartners: json['activePartners'] as int? ?? 0,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      averageCompletionRate: (json['averageCompletionRate'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'totalPartners': totalPartners,
      'newPartners': newPartners,
      'activePartners': activePartners,
      'averageRating': averageRating,
      'averageCompletionRate': averageCompletionRate,
    };
  }
}

/// Data model for PartnerPerformanceData
class PartnerPerformanceDataModel extends PartnerPerformanceData {
  const PartnerPerformanceDataModel({
    required super.partnerId,
    required super.partnerName,
    required super.rating,
    required super.completionRate,
    required super.responseTime,
    required super.totalJobs,
    required super.completedJobs,
    required super.totalEarnings,
    required super.services,
    required super.region,
  });

  factory PartnerPerformanceDataModel.fromJson(Map<String, dynamic> json) {
    return PartnerPerformanceDataModel(
      partnerId: json['partnerId'] as String,
      partnerName: json['partnerName'] as String,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      completionRate: (json['completionRate'] as num?)?.toDouble() ?? 0.0,
      responseTime: (json['responseTime'] as num?)?.toDouble() ?? 0.0,
      totalJobs: json['totalJobs'] as int? ?? 0,
      completedJobs: json['completedJobs'] as int? ?? 0,
      totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0.0,
      services: List<String>.from(json['services'] as List<dynamic>? ?? []),
      region: json['region'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'partnerId': partnerId,
      'partnerName': partnerName,
      'rating': rating,
      'completionRate': completionRate,
      'responseTime': responseTime,
      'totalJobs': totalJobs,
      'completedJobs': completedJobs,
      'totalEarnings': totalEarnings,
      'services': services,
      'region': region,
    };
  }
}

/// Data model for PartnerInsights
class PartnerInsightsModel extends PartnerInsights {
  const PartnerInsightsModel({
    required super.performanceTrends,
    required super.recommendations,
    required super.alerts,
    required super.capacityAnalysis,
    required super.trainingNeeds,
  });

  factory PartnerInsightsModel.fromJson(Map<String, dynamic> json) {
    return PartnerInsightsModel(
      performanceTrends: List<String>.from(json['performanceTrends'] as List<dynamic>? ?? []),
      recommendations: List<String>.from(json['recommendations'] as List<dynamic>? ?? []),
      alerts: (json['alerts'] as List<dynamic>?)
          ?.map((item) => PartnerAlertModel.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      capacityAnalysis: PartnerCapacityAnalysisModel.fromJson(json['capacityAnalysis'] as Map<String, dynamic>),
      trainingNeeds: PartnerTrainingNeedsModel.fromJson(json['trainingNeeds'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'performanceTrends': performanceTrends,
      'recommendations': recommendations,
      'alerts': alerts.map((alert) => (alert as PartnerAlertModel).toJson()).toList(),
      'capacityAnalysis': (capacityAnalysis as PartnerCapacityAnalysisModel).toJson(),
      'trainingNeeds': (trainingNeeds as PartnerTrainingNeedsModel).toJson(),
    };
  }

  factory PartnerInsightsModel.mock() {
    return PartnerInsightsModel(
      performanceTrends: [
        'Partner performance improved by 12% this month',
        'Response times decreased by 15% on average',
        'New partner onboarding increased by 25%',
      ],
      recommendations: [
        'Provide additional training for underperforming partners',
        'Implement partner incentive programs',
        'Expand partner network in high-demand areas',
      ],
      alerts: [],
      capacityAnalysis: PartnerCapacityAnalysisModel.mock(),
      trainingNeeds: PartnerTrainingNeedsModel.mock(),
    );
  }
}

/// Data model for PartnerAlert
class PartnerAlertModel extends PartnerAlert {
  const PartnerAlertModel({
    required super.id,
    required super.type,
    required super.title,
    required super.description,
    required super.severity,
    required super.timestamp,
    super.partnerId,
    super.metadata = const {},
  });

  factory PartnerAlertModel.fromJson(Map<String, dynamic> json) {
    return PartnerAlertModel(
      id: json['id'] as String,
      type: PartnerAlertType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PartnerAlertType.lowRating,
      ),
      title: json['title'] as String,
      description: json['description'] as String,
      severity: AlertSeverity.values.firstWhere(
        (e) => e.name == json['severity'],
        orElse: () => AlertSeverity.low,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      partnerId: json['partnerId'] as String?,
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
      'partnerId': partnerId,
      'metadata': metadata,
    };
  }
}

/// Data model for PartnerCapacityAnalysis
class PartnerCapacityAnalysisModel extends PartnerCapacityAnalysis {
  const PartnerCapacityAnalysisModel({
    required super.currentUtilization,
    required super.optimalUtilization,
    required super.availableCapacity,
    required super.utilizationByService,
    required super.utilizationByRegion,
  });

  factory PartnerCapacityAnalysisModel.fromJson(Map<String, dynamic> json) {
    return PartnerCapacityAnalysisModel(
      currentUtilization: (json['currentUtilization'] as num?)?.toDouble() ?? 0.0,
      optimalUtilization: (json['optimalUtilization'] as num?)?.toDouble() ?? 0.0,
      availableCapacity: json['availableCapacity'] as int? ?? 0,
      utilizationByService: Map<String, double>.from(
        (json['utilizationByService'] as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(key, (value as num?)?.toDouble() ?? 0.0),
        ) ?? {},
      ),
      utilizationByRegion: Map<String, double>.from(
        (json['utilizationByRegion'] as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(key, (value as num?)?.toDouble() ?? 0.0),
        ) ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentUtilization': currentUtilization,
      'optimalUtilization': optimalUtilization,
      'availableCapacity': availableCapacity,
      'utilizationByService': utilizationByService,
      'utilizationByRegion': utilizationByRegion,
    };
  }

  factory PartnerCapacityAnalysisModel.mock() {
    return const PartnerCapacityAnalysisModel(
      currentUtilization: 78.5,
      optimalUtilization: 85.0,
      availableCapacity: 285,
      utilizationByService: {
        'Home Cleaning': 85.2,
        'Plumbing': 72.8,
        'Electrical': 68.5,
        'Gardening': 65.3,
      },
      utilizationByRegion: {
        'Ho Chi Minh City': 82.1,
        'Hanoi': 75.8,
        'Da Nang': 68.9,
        'Can Tho': 62.5,
      },
    );
  }
}

/// Data model for PartnerTrainingNeeds
class PartnerTrainingNeedsModel extends PartnerTrainingNeeds {
  const PartnerTrainingNeedsModel({
    required super.skillGaps,
    required super.trainingRecommendations,
    required super.partnersNeedingTraining,
    required super.availablePrograms,
  });

  factory PartnerTrainingNeedsModel.fromJson(Map<String, dynamic> json) {
    return PartnerTrainingNeedsModel(
      skillGaps: List<String>.from(json['skillGaps'] as List<dynamic>? ?? []),
      trainingRecommendations: List<String>.from(json['trainingRecommendations'] as List<dynamic>? ?? []),
      partnersNeedingTraining: Map<String, int>.from(
        (json['partnersNeedingTraining'] as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(key, value as int? ?? 0),
        ) ?? {},
      ),
      availablePrograms: (json['availablePrograms'] as List<dynamic>?)
          ?.map((item) => TrainingProgramModel.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'skillGaps': skillGaps,
      'trainingRecommendations': trainingRecommendations,
      'partnersNeedingTraining': partnersNeedingTraining,
      'availablePrograms': availablePrograms.map((program) => (program as TrainingProgramModel).toJson()).toList(),
    };
  }

  factory PartnerTrainingNeedsModel.mock() {
    return const PartnerTrainingNeedsModel(
      skillGaps: [
        'Customer Service',
        'Time Management',
        'Technical Skills',
      ],
      trainingRecommendations: [
        'Implement customer service training program',
        'Provide time management workshops',
        'Offer technical skill certification courses',
      ],
      partnersNeedingTraining: {
        'Customer Service': 125,
        'Time Management': 89,
        'Technical Skills': 156,
      },
      availablePrograms: [],
    );
  }
}

/// Data model for TrainingProgram
class TrainingProgramModel extends TrainingProgram {
  const TrainingProgramModel({
    required super.id,
    required super.name,
    required super.description,
    required super.skills,
    required super.duration,
    required super.level,
  });

  factory TrainingProgramModel.fromJson(Map<String, dynamic> json) {
    return TrainingProgramModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      skills: List<String>.from(json['skills'] as List<dynamic>? ?? []),
      duration: json['duration'] as int? ?? 0,
      level: json['level'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'skills': skills,
      'duration': duration,
      'level': level,
    };
  }
}

/// Data model for PartnerQualityMetrics
class PartnerQualityMetricsModel extends PartnerQualityMetrics {
  const PartnerQualityMetricsModel({
    required super.averageCustomerSatisfaction,
    required super.averageJobQuality,
    required super.averagePunctuality,
    required super.averageProfessionalism,
    required super.qualityByService,
    required super.qualityTrends,
  });

  factory PartnerQualityMetricsModel.fromJson(Map<String, dynamic> json) {
    return PartnerQualityMetricsModel(
      averageCustomerSatisfaction: (json['averageCustomerSatisfaction'] as num?)?.toDouble() ?? 0.0,
      averageJobQuality: (json['averageJobQuality'] as num?)?.toDouble() ?? 0.0,
      averagePunctuality: (json['averagePunctuality'] as num?)?.toDouble() ?? 0.0,
      averageProfessionalism: (json['averageProfessionalism'] as num?)?.toDouble() ?? 0.0,
      qualityByService: Map<String, double>.from(
        (json['qualityByService'] as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(key, (value as num?)?.toDouble() ?? 0.0),
        ) ?? {},
      ),
      qualityTrends: (json['qualityTrends'] as List<dynamic>?)
          ?.map((item) => QualityTrendModel.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'averageCustomerSatisfaction': averageCustomerSatisfaction,
      'averageJobQuality': averageJobQuality,
      'averagePunctuality': averagePunctuality,
      'averageProfessionalism': averageProfessionalism,
      'qualityByService': qualityByService,
      'qualityTrends': qualityTrends.map((trend) => (trend as QualityTrendModel).toJson()).toList(),
    };
  }

  factory PartnerQualityMetricsModel.mock() {
    return PartnerQualityMetricsModel(
      averageCustomerSatisfaction: 4.2,
      averageJobQuality: 4.1,
      averagePunctuality: 4.0,
      averageProfessionalism: 4.3,
      qualityByService: {
        'Home Cleaning': 4.4,
        'Plumbing': 4.1,
        'Electrical': 4.0,
        'Gardening': 3.9,
      },
      qualityTrends: List.generate(30, (index) {
        final date = DateTime.now().subtract(Duration(days: 29 - index));
        return QualityTrendModel(
          date: date,
          qualityScore: 4.0 + (index * 0.01),
          customerSatisfaction: 4.1 + (index * 0.008),
          jobQuality: 4.0 + (index * 0.009),
        );
      }),
    );
  }
}

/// Data model for QualityTrend
class QualityTrendModel extends QualityTrend {
  const QualityTrendModel({
    required super.date,
    required super.qualityScore,
    required super.customerSatisfaction,
    required super.jobQuality,
  });

  factory QualityTrendModel.fromJson(Map<String, dynamic> json) {
    return QualityTrendModel(
      date: DateTime.parse(json['date'] as String),
      qualityScore: (json['qualityScore'] as num?)?.toDouble() ?? 0.0,
      customerSatisfaction: (json['customerSatisfaction'] as num?)?.toDouble() ?? 0.0,
      jobQuality: (json['jobQuality'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'qualityScore': qualityScore,
      'customerSatisfaction': customerSatisfaction,
      'jobQuality': jobQuality,
    };
  }
}
