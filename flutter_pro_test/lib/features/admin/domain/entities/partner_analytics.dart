import 'package:equatable/equatable.dart';

/// Partner analytics entity for comprehensive partner performance analysis
class PartnerAnalytics extends Equatable {
  final int totalPartners;
  final int activePartners;
  final int newPartners;
  final int inactivePartners;
  final int suspendedPartners;
  final double averageRating;
  final double averageCompletionRate;
  final double averageResponseTime;
  final Map<String, int> partnersByRegion;
  final Map<String, int> partnersByService;
  final Map<String, int> partnersByRating;
  final List<DailyPartnerData> partnerGrowthTrend;
  final List<PartnerPerformanceData> topPerformers;
  final List<PartnerPerformanceData> underPerformers;
  final DateTime periodStart;
  final DateTime periodEnd;
  final PartnerInsights insights;
  final PartnerQualityMetrics qualityMetrics;

  const PartnerAnalytics({
    required this.totalPartners,
    required this.activePartners,
    required this.newPartners,
    required this.inactivePartners,
    required this.suspendedPartners,
    required this.averageRating,
    required this.averageCompletionRate,
    required this.averageResponseTime,
    required this.partnersByRegion,
    required this.partnersByService,
    required this.partnersByRating,
    required this.partnerGrowthTrend,
    required this.topPerformers,
    required this.underPerformers,
    required this.periodStart,
    required this.periodEnd,
    required this.insights,
    required this.qualityMetrics,
  });

  /// Calculate partner growth rate
  double getPartnerGrowthRate(PartnerAnalytics? previousPeriod) {
    if (previousPeriod == null || previousPeriod.totalPartners == 0) {
      return totalPartners > 0 ? 100.0 : 0.0;
    }
    return ((totalPartners - previousPeriod.totalPartners) / 
            previousPeriod.totalPartners) * 100;
  }

  /// Get partner activity rate
  double get partnerActivityRate {
    if (totalPartners == 0) return 0.0;
    return (activePartners / totalPartners) * 100;
  }

  /// Get most popular region for partners
  String get mostPopularRegion {
    if (partnersByRegion.isEmpty) return 'N/A';
    return partnersByRegion.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Get most popular service category
  String get mostPopularService {
    if (partnersByService.isEmpty) return 'N/A';
    return partnersByService.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Get partner quality score
  double get qualityScore {
    // Weighted score based on rating, completion rate, and response time
    final ratingScore = (averageRating / 5.0) * 40; // 40% weight
    final completionScore = averageCompletionRate * 40; // 40% weight
    final responseScore = averageResponseTime > 0 
        ? (1 / averageResponseTime) * 20 // 20% weight (lower is better)
        : 20;
    return ratingScore + completionScore + responseScore;
  }

  @override
  List<Object?> get props => [
        totalPartners,
        activePartners,
        newPartners,
        inactivePartners,
        suspendedPartners,
        averageRating,
        averageCompletionRate,
        averageResponseTime,
        partnersByRegion,
        partnersByService,
        partnersByRating,
        partnerGrowthTrend,
        topPerformers,
        underPerformers,
        periodStart,
        periodEnd,
        insights,
        qualityMetrics,
      ];
}

/// Daily partner data for growth trend analysis
class DailyPartnerData extends Equatable {
  final DateTime date;
  final int totalPartners;
  final int newPartners;
  final int activePartners;
  final double averageRating;
  final double averageCompletionRate;

  const DailyPartnerData({
    required this.date,
    required this.totalPartners,
    required this.newPartners,
    required this.activePartners,
    required this.averageRating,
    required this.averageCompletionRate,
  });

  double get activityRate {
    if (totalPartners == 0) return 0.0;
    return (activePartners / totalPartners) * 100;
  }

  @override
  List<Object?> get props => [
        date,
        totalPartners,
        newPartners,
        activePartners,
        averageRating,
        averageCompletionRate,
      ];
}

/// Partner performance data
class PartnerPerformanceData extends Equatable {
  final String partnerId;
  final String partnerName;
  final double rating;
  final double completionRate;
  final double responseTime;
  final int totalJobs;
  final int completedJobs;
  final double totalEarnings;
  final List<String> services;
  final String region;

  const PartnerPerformanceData({
    required this.partnerId,
    required this.partnerName,
    required this.rating,
    required this.completionRate,
    required this.responseTime,
    required this.totalJobs,
    required this.completedJobs,
    required this.totalEarnings,
    required this.services,
    required this.region,
  });

  double get performanceScore {
    // Weighted performance score
    final ratingScore = (rating / 5.0) * 30;
    final completionScore = completionRate * 30;
    final volumeScore = (totalJobs / 100.0).clamp(0.0, 1.0) * 20;
    final responseScore = responseTime > 0 
        ? (1 / responseTime).clamp(0.0, 1.0) * 20
        : 20;
    return ratingScore + completionScore + volumeScore + responseScore;
  }

  @override
  List<Object?> get props => [
        partnerId,
        partnerName,
        rating,
        completionRate,
        responseTime,
        totalJobs,
        completedJobs,
        totalEarnings,
        services,
        region,
      ];
}

/// Partner insights and recommendations
class PartnerInsights extends Equatable {
  final List<String> performanceTrends;
  final List<String> recommendations;
  final List<PartnerAlert> alerts;
  final PartnerCapacityAnalysis capacityAnalysis;
  final PartnerTrainingNeeds trainingNeeds;

  const PartnerInsights({
    required this.performanceTrends,
    required this.recommendations,
    required this.alerts,
    required this.capacityAnalysis,
    required this.trainingNeeds,
  });

  @override
  List<Object?> get props => [
        performanceTrends,
        recommendations,
        alerts,
        capacityAnalysis,
        trainingNeeds,
      ];
}

/// Partner alert for admin attention
class PartnerAlert extends Equatable {
  final String id;
  final PartnerAlertType type;
  final String title;
  final String description;
  final AlertSeverity severity;
  final DateTime timestamp;
  final String? partnerId;
  final Map<String, dynamic> metadata;

  const PartnerAlert({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.severity,
    required this.timestamp,
    this.partnerId,
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
        partnerId,
        metadata,
      ];
}

/// Partner alert types
enum PartnerAlertType {
  lowRating,
  highCancellationRate,
  slowResponseTime,
  inactivePartner,
  qualityIssue;

  String get displayName {
    switch (this) {
      case PartnerAlertType.lowRating:
        return 'Low Partner Rating';
      case PartnerAlertType.highCancellationRate:
        return 'High Cancellation Rate';
      case PartnerAlertType.slowResponseTime:
        return 'Slow Response Time';
      case PartnerAlertType.inactivePartner:
        return 'Inactive Partner';
      case PartnerAlertType.qualityIssue:
        return 'Quality Issue';
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

/// Partner capacity analysis
class PartnerCapacityAnalysis extends Equatable {
  final double currentUtilization;
  final double optimalUtilization;
  final int availableCapacity;
  final Map<String, double> utilizationByService;
  final Map<String, double> utilizationByRegion;

  const PartnerCapacityAnalysis({
    required this.currentUtilization,
    required this.optimalUtilization,
    required this.availableCapacity,
    required this.utilizationByService,
    required this.utilizationByRegion,
  });

  bool get isOverUtilized => currentUtilization > optimalUtilization;
  bool get isUnderUtilized => currentUtilization < (optimalUtilization * 0.7);

  @override
  List<Object?> get props => [
        currentUtilization,
        optimalUtilization,
        availableCapacity,
        utilizationByService,
        utilizationByRegion,
      ];
}

/// Partner training needs analysis
class PartnerTrainingNeeds extends Equatable {
  final List<String> skillGaps;
  final List<String> trainingRecommendations;
  final Map<String, int> partnersNeedingTraining;
  final List<TrainingProgram> availablePrograms;

  const PartnerTrainingNeeds({
    required this.skillGaps,
    required this.trainingRecommendations,
    required this.partnersNeedingTraining,
    required this.availablePrograms,
  });

  @override
  List<Object?> get props => [
        skillGaps,
        trainingRecommendations,
        partnersNeedingTraining,
        availablePrograms,
      ];
}

/// Training program definition
class TrainingProgram extends Equatable {
  final String id;
  final String name;
  final String description;
  final List<String> skills;
  final int duration;
  final String level;

  const TrainingProgram({
    required this.id,
    required this.name,
    required this.description,
    required this.skills,
    required this.duration,
    required this.level,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        skills,
        duration,
        level,
      ];
}

/// Partner quality metrics
class PartnerQualityMetrics extends Equatable {
  final double averageCustomerSatisfaction;
  final double averageJobQuality;
  final double averagePunctuality;
  final double averageProfessionalism;
  final Map<String, double> qualityByService;
  final List<QualityTrend> qualityTrends;

  const PartnerQualityMetrics({
    required this.averageCustomerSatisfaction,
    required this.averageJobQuality,
    required this.averagePunctuality,
    required this.averageProfessionalism,
    required this.qualityByService,
    required this.qualityTrends,
  });

  double get overallQualityScore {
    return (averageCustomerSatisfaction + averageJobQuality + 
            averagePunctuality + averageProfessionalism) / 4.0;
  }

  @override
  List<Object?> get props => [
        averageCustomerSatisfaction,
        averageJobQuality,
        averagePunctuality,
        averageProfessionalism,
        qualityByService,
        qualityTrends,
      ];
}

/// Quality trend data
class QualityTrend extends Equatable {
  final DateTime date;
  final double qualityScore;
  final double customerSatisfaction;
  final double jobQuality;

  const QualityTrend({
    required this.date,
    required this.qualityScore,
    required this.customerSatisfaction,
    required this.jobQuality,
  });

  @override
  List<Object?> get props => [
        date,
        qualityScore,
        customerSatisfaction,
        jobQuality,
      ];
}
