import 'package:equatable/equatable.dart';

/// User analytics entity for comprehensive user behavior analysis
class UserAnalytics extends Equatable {
  final int totalUsers;
  final int activeUsers;
  final int newUsers;
  final int returningUsers;
  final int inactiveUsers;
  final double userRetentionRate;
  final double userChurnRate;
  final double averageSessionDuration;
  final Map<String, int> usersByRegion;
  final Map<String, int> usersByAgeGroup;
  final Map<String, int> usersByGender;
  final List<DailyUserData> userGrowthTrend;
  final List<UserCohortData> cohortAnalysis;
  final DateTime periodStart;
  final DateTime periodEnd;
  final UserBehaviorInsights behaviorInsights;
  final UserEngagementMetrics engagement;

  const UserAnalytics({
    required this.totalUsers,
    required this.activeUsers,
    required this.newUsers,
    required this.returningUsers,
    required this.inactiveUsers,
    required this.userRetentionRate,
    required this.userChurnRate,
    required this.averageSessionDuration,
    required this.usersByRegion,
    required this.usersByAgeGroup,
    required this.usersByGender,
    required this.userGrowthTrend,
    required this.cohortAnalysis,
    required this.periodStart,
    required this.periodEnd,
    required this.behaviorInsights,
    required this.engagement,
  });

  /// Calculate user growth rate
  double getUserGrowthRate(UserAnalytics? previousPeriod) {
    if (previousPeriod == null || previousPeriod.totalUsers == 0) {
      return totalUsers > 0 ? 100.0 : 0.0;
    }
    return ((totalUsers - previousPeriod.totalUsers) / 
            previousPeriod.totalUsers) * 100;
  }

  /// Get user activity rate
  double get userActivityRate {
    if (totalUsers == 0) return 0.0;
    return (activeUsers / totalUsers) * 100;
  }

  /// Get most popular region
  String get mostPopularRegion {
    if (usersByRegion.isEmpty) return 'N/A';
    return usersByRegion.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Get dominant age group
  String get dominantAgeGroup {
    if (usersByAgeGroup.isEmpty) return 'N/A';
    return usersByAgeGroup.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  @override
  List<Object?> get props => [
        totalUsers,
        activeUsers,
        newUsers,
        returningUsers,
        inactiveUsers,
        userRetentionRate,
        userChurnRate,
        averageSessionDuration,
        usersByRegion,
        usersByAgeGroup,
        usersByGender,
        userGrowthTrend,
        cohortAnalysis,
        periodStart,
        periodEnd,
        behaviorInsights,
        engagement,
      ];
}

/// Daily user data for growth trend analysis
class DailyUserData extends Equatable {
  final DateTime date;
  final int totalUsers;
  final int newUsers;
  final int activeUsers;
  final int returningUsers;
  final double retentionRate;

  const DailyUserData({
    required this.date,
    required this.totalUsers,
    required this.newUsers,
    required this.activeUsers,
    required this.returningUsers,
    required this.retentionRate,
  });

  double get activityRate {
    if (totalUsers == 0) return 0.0;
    return (activeUsers / totalUsers) * 100;
  }

  @override
  List<Object?> get props => [
        date,
        totalUsers,
        newUsers,
        activeUsers,
        returningUsers,
        retentionRate,
      ];
}

/// User cohort data for retention analysis
class UserCohortData extends Equatable {
  final DateTime cohortMonth;
  final int initialUsers;
  final Map<int, int> retentionByMonth;
  final Map<int, double> retentionRateByMonth;

  const UserCohortData({
    required this.cohortMonth,
    required this.initialUsers,
    required this.retentionByMonth,
    required this.retentionRateByMonth,
  });

  double getRetentionRateForMonth(int month) {
    return retentionRateByMonth[month] ?? 0.0;
  }

  @override
  List<Object?> get props => [
        cohortMonth,
        initialUsers,
        retentionByMonth,
        retentionRateByMonth,
      ];
}

/// User behavior insights
class UserBehaviorInsights extends Equatable {
  final List<String> behaviorTrends;
  final List<String> recommendations;
  final List<UserAlert> alerts;
  final UserSegmentation segmentation;
  final UserJourneyAnalysis journeyAnalysis;

  const UserBehaviorInsights({
    required this.behaviorTrends,
    required this.recommendations,
    required this.alerts,
    required this.segmentation,
    required this.journeyAnalysis,
  });

  @override
  List<Object?> get props => [
        behaviorTrends,
        recommendations,
        alerts,
        segmentation,
        journeyAnalysis,
      ];
}

/// User alert for admin attention
class UserAlert extends Equatable {
  final String id;
  final UserAlertType type;
  final String title;
  final String description;
  final AlertSeverity severity;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  const UserAlert({
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

/// User alert types
enum UserAlertType {
  highChurnRate,
  lowEngagement,
  unusualActivity,
  securityConcern,
  supportIssue;

  String get displayName {
    switch (this) {
      case UserAlertType.highChurnRate:
        return 'High Churn Rate';
      case UserAlertType.lowEngagement:
        return 'Low User Engagement';
      case UserAlertType.unusualActivity:
        return 'Unusual User Activity';
      case UserAlertType.securityConcern:
        return 'Security Concern';
      case UserAlertType.supportIssue:
        return 'Support Issue';
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

/// User segmentation analysis
class UserSegmentation extends Equatable {
  final Map<String, int> segmentsByValue;
  final Map<String, int> segmentsByActivity;
  final Map<String, int> segmentsByLifecycle;
  final List<UserSegment> customSegments;

  const UserSegmentation({
    required this.segmentsByValue,
    required this.segmentsByActivity,
    required this.segmentsByLifecycle,
    required this.customSegments,
  });

  @override
  List<Object?> get props => [
        segmentsByValue,
        segmentsByActivity,
        segmentsByLifecycle,
        customSegments,
      ];
}

/// User segment definition
class UserSegment extends Equatable {
  final String id;
  final String name;
  final String description;
  final int userCount;
  final double percentage;
  final Map<String, dynamic> criteria;

  const UserSegment({
    required this.id,
    required this.name,
    required this.description,
    required this.userCount,
    required this.percentage,
    required this.criteria,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        userCount,
        percentage,
        criteria,
      ];
}

/// User journey analysis
class UserJourneyAnalysis extends Equatable {
  final Map<String, double> conversionFunnel;
  final Map<String, double> dropOffPoints;
  final List<String> commonPaths;
  final double averageTimeToConversion;

  const UserJourneyAnalysis({
    required this.conversionFunnel,
    required this.dropOffPoints,
    required this.commonPaths,
    required this.averageTimeToConversion,
  });

  @override
  List<Object?> get props => [
        conversionFunnel,
        dropOffPoints,
        commonPaths,
        averageTimeToConversion,
      ];
}

/// User engagement metrics
class UserEngagementMetrics extends Equatable {
  final double averageSessionsPerUser;
  final double averagePageViewsPerSession;
  final double bounceRate;
  final Map<String, double> featureUsage;
  final Map<String, double> timeSpentByFeature;

  const UserEngagementMetrics({
    required this.averageSessionsPerUser,
    required this.averagePageViewsPerSession,
    required this.bounceRate,
    required this.featureUsage,
    required this.timeSpentByFeature,
  });

  String get mostUsedFeature {
    if (featureUsage.isEmpty) return 'N/A';
    return featureUsage.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  @override
  List<Object?> get props => [
        averageSessionsPerUser,
        averagePageViewsPerSession,
        bounceRate,
        featureUsage,
        timeSpentByFeature,
      ];
}
