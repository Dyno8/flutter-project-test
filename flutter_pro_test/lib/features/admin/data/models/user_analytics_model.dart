import '../../domain/entities/user_analytics.dart';

/// Data model for UserAnalytics entity
class UserAnalyticsModel extends UserAnalytics {
  const UserAnalyticsModel({
    required super.totalUsers,
    required super.activeUsers,
    required super.newUsers,
    required super.returningUsers,
    required super.inactiveUsers,
    required super.userRetentionRate,
    required super.userChurnRate,
    required super.averageSessionDuration,
    required super.usersByRegion,
    required super.usersByAgeGroup,
    required super.usersByGender,
    required super.userGrowthTrend,
    required super.cohortAnalysis,
    required super.periodStart,
    required super.periodEnd,
    required super.behaviorInsights,
    required super.engagement,
  });

  /// Create from JSON
  factory UserAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return UserAnalyticsModel(
      totalUsers: json['totalUsers'] as int? ?? 0,
      activeUsers: json['activeUsers'] as int? ?? 0,
      newUsers: json['newUsers'] as int? ?? 0,
      returningUsers: json['returningUsers'] as int? ?? 0,
      inactiveUsers: json['inactiveUsers'] as int? ?? 0,
      userRetentionRate: (json['userRetentionRate'] as num?)?.toDouble() ?? 0.0,
      userChurnRate: (json['userChurnRate'] as num?)?.toDouble() ?? 0.0,
      averageSessionDuration: (json['averageSessionDuration'] as num?)?.toDouble() ?? 0.0,
      usersByRegion: Map<String, int>.from(
        (json['usersByRegion'] as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(key, value as int? ?? 0),
        ) ?? {},
      ),
      usersByAgeGroup: Map<String, int>.from(
        (json['usersByAgeGroup'] as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(key, value as int? ?? 0),
        ) ?? {},
      ),
      usersByGender: Map<String, int>.from(
        (json['usersByGender'] as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(key, value as int? ?? 0),
        ) ?? {},
      ),
      userGrowthTrend: (json['userGrowthTrend'] as List<dynamic>?)
          ?.map((item) => DailyUserDataModel.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      cohortAnalysis: (json['cohortAnalysis'] as List<dynamic>?)
          ?.map((item) => UserCohortDataModel.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      periodStart: DateTime.parse(json['periodStart'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
      behaviorInsights: UserBehaviorInsightsModel.fromJson(json['behaviorInsights'] as Map<String, dynamic>),
      engagement: UserEngagementMetricsModel.fromJson(json['engagement'] as Map<String, dynamic>),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'totalUsers': totalUsers,
      'activeUsers': activeUsers,
      'newUsers': newUsers,
      'returningUsers': returningUsers,
      'inactiveUsers': inactiveUsers,
      'userRetentionRate': userRetentionRate,
      'userChurnRate': userChurnRate,
      'averageSessionDuration': averageSessionDuration,
      'usersByRegion': usersByRegion,
      'usersByAgeGroup': usersByAgeGroup,
      'usersByGender': usersByGender,
      'userGrowthTrend': userGrowthTrend.map((item) => (item as DailyUserDataModel).toJson()).toList(),
      'cohortAnalysis': cohortAnalysis.map((item) => (item as UserCohortDataModel).toJson()).toList(),
      'periodStart': periodStart.toIso8601String(),
      'periodEnd': periodEnd.toIso8601String(),
      'behaviorInsights': (behaviorInsights as UserBehaviorInsightsModel).toJson(),
      'engagement': (engagement as UserEngagementMetricsModel).toJson(),
    };
  }

  /// Convert to entity
  UserAnalytics toEntity() => this;

  /// Create mock data for testing
  factory UserAnalyticsModel.mock() {
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 30));
    
    return UserAnalyticsModel(
      totalUsers: 12450,
      activeUsers: 8920,
      newUsers: 1250,
      returningUsers: 7670,
      inactiveUsers: 3530,
      userRetentionRate: 78.5,
      userChurnRate: 12.3,
      averageSessionDuration: 18.5,
      usersByRegion: {
        'Ho Chi Minh City': 6200,
        'Hanoi': 3800,
        'Da Nang': 1450,
        'Can Tho': 1000,
      },
      usersByAgeGroup: {
        '18-25': 2450,
        '26-35': 4890,
        '36-45': 3210,
        '46-55': 1450,
        '55+': 450,
      },
      usersByGender: {
        'Female': 7470,
        'Male': 4680,
        'Other': 300,
      },
      userGrowthTrend: List.generate(30, (index) {
        final date = startDate.add(Duration(days: index));
        return DailyUserDataModel(
          date: date,
          totalUsers: 12000 + (index * 15),
          newUsers: 35 + (index % 10),
          activeUsers: 8500 + (index * 12),
          returningUsers: 7200 + (index * 10),
          retentionRate: 75.0 + (index * 0.1),
        );
      }),
      cohortAnalysis: List.generate(6, (index) {
        final cohortMonth = DateTime(now.year, now.month - index);
        return UserCohortDataModel(
          cohortMonth: cohortMonth,
          initialUsers: 1000 + (index * 100),
          retentionByMonth: {
            1: 850 + (index * 80),
            2: 720 + (index * 70),
            3: 650 + (index * 60),
            6: 580 + (index * 50),
          },
          retentionRateByMonth: {
            1: 85.0 - (index * 2),
            2: 72.0 - (index * 2),
            3: 65.0 - (index * 2),
            6: 58.0 - (index * 2),
          },
        );
      }),
      periodStart: startDate,
      periodEnd: now,
      behaviorInsights: UserBehaviorInsightsModel.mock(),
      engagement: UserEngagementMetricsModel.mock(),
    );
  }
}

/// Data model for DailyUserData
class DailyUserDataModel extends DailyUserData {
  const DailyUserDataModel({
    required super.date,
    required super.totalUsers,
    required super.newUsers,
    required super.activeUsers,
    required super.returningUsers,
    required super.retentionRate,
  });

  factory DailyUserDataModel.fromJson(Map<String, dynamic> json) {
    return DailyUserDataModel(
      date: DateTime.parse(json['date'] as String),
      totalUsers: json['totalUsers'] as int? ?? 0,
      newUsers: json['newUsers'] as int? ?? 0,
      activeUsers: json['activeUsers'] as int? ?? 0,
      returningUsers: json['returningUsers'] as int? ?? 0,
      retentionRate: (json['retentionRate'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'totalUsers': totalUsers,
      'newUsers': newUsers,
      'activeUsers': activeUsers,
      'returningUsers': returningUsers,
      'retentionRate': retentionRate,
    };
  }
}

/// Data model for UserCohortData
class UserCohortDataModel extends UserCohortData {
  const UserCohortDataModel({
    required super.cohortMonth,
    required super.initialUsers,
    required super.retentionByMonth,
    required super.retentionRateByMonth,
  });

  factory UserCohortDataModel.fromJson(Map<String, dynamic> json) {
    return UserCohortDataModel(
      cohortMonth: DateTime.parse(json['cohortMonth'] as String),
      initialUsers: json['initialUsers'] as int? ?? 0,
      retentionByMonth: Map<int, int>.from(
        (json['retentionByMonth'] as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(int.parse(key), value as int? ?? 0),
        ) ?? {},
      ),
      retentionRateByMonth: Map<int, double>.from(
        (json['retentionRateByMonth'] as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(int.parse(key), (value as num?)?.toDouble() ?? 0.0),
        ) ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cohortMonth': cohortMonth.toIso8601String(),
      'initialUsers': initialUsers,
      'retentionByMonth': retentionByMonth.map((key, value) => MapEntry(key.toString(), value)),
      'retentionRateByMonth': retentionRateByMonth.map((key, value) => MapEntry(key.toString(), value)),
    };
  }
}

/// Data model for UserBehaviorInsights
class UserBehaviorInsightsModel extends UserBehaviorInsights {
  const UserBehaviorInsightsModel({
    required super.behaviorTrends,
    required super.recommendations,
    required super.alerts,
    required super.segmentation,
    required super.journeyAnalysis,
  });

  factory UserBehaviorInsightsModel.fromJson(Map<String, dynamic> json) {
    return UserBehaviorInsightsModel(
      behaviorTrends: List<String>.from(json['behaviorTrends'] as List<dynamic>? ?? []),
      recommendations: List<String>.from(json['recommendations'] as List<dynamic>? ?? []),
      alerts: (json['alerts'] as List<dynamic>?)
          ?.map((item) => UserAlertModel.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      segmentation: UserSegmentationModel.fromJson(json['segmentation'] as Map<String, dynamic>),
      journeyAnalysis: UserJourneyAnalysisModel.fromJson(json['journeyAnalysis'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'behaviorTrends': behaviorTrends,
      'recommendations': recommendations,
      'alerts': alerts.map((alert) => (alert as UserAlertModel).toJson()).toList(),
      'segmentation': (segmentation as UserSegmentationModel).toJson(),
      'journeyAnalysis': (journeyAnalysis as UserJourneyAnalysisModel).toJson(),
    };
  }

  factory UserBehaviorInsightsModel.mock() {
    return UserBehaviorInsightsModel(
      behaviorTrends: [
        'User engagement increased by 25% this month',
        'Mobile app usage dominates with 78% of sessions',
        'Peak usage hours are between 6-9 PM',
      ],
      recommendations: [
        'Implement push notifications for inactive users',
        'Optimize mobile app performance',
        'Create targeted campaigns for high-value segments',
      ],
      alerts: [],
      segmentation: UserSegmentationModel.mock(),
      journeyAnalysis: UserJourneyAnalysisModel.mock(),
    );
  }
}

/// Data model for UserAlert
class UserAlertModel extends UserAlert {
  const UserAlertModel({
    required super.id,
    required super.type,
    required super.title,
    required super.description,
    required super.severity,
    required super.timestamp,
    super.metadata = const {},
  });

  factory UserAlertModel.fromJson(Map<String, dynamic> json) {
    return UserAlertModel(
      id: json['id'] as String,
      type: UserAlertType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => UserAlertType.highChurnRate,
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

/// Data model for UserSegmentation
class UserSegmentationModel extends UserSegmentation {
  const UserSegmentationModel({
    required super.segmentsByValue,
    required super.segmentsByActivity,
    required super.segmentsByLifecycle,
    required super.customSegments,
  });

  factory UserSegmentationModel.fromJson(Map<String, dynamic> json) {
    return UserSegmentationModel(
      segmentsByValue: Map<String, int>.from(
        (json['segmentsByValue'] as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(key, value as int? ?? 0),
        ) ?? {},
      ),
      segmentsByActivity: Map<String, int>.from(
        (json['segmentsByActivity'] as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(key, value as int? ?? 0),
        ) ?? {},
      ),
      segmentsByLifecycle: Map<String, int>.from(
        (json['segmentsByLifecycle'] as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(key, value as int? ?? 0),
        ) ?? {},
      ),
      customSegments: (json['customSegments'] as List<dynamic>?)
          ?.map((item) => UserSegmentModel.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'segmentsByValue': segmentsByValue,
      'segmentsByActivity': segmentsByActivity,
      'segmentsByLifecycle': segmentsByLifecycle,
      'customSegments': customSegments.map((segment) => (segment as UserSegmentModel).toJson()).toList(),
    };
  }

  factory UserSegmentationModel.mock() {
    return const UserSegmentationModel(
      segmentsByValue: {
        'High Value': 1250,
        'Medium Value': 4890,
        'Low Value': 6310,
      },
      segmentsByActivity: {
        'Very Active': 2450,
        'Active': 4890,
        'Moderate': 3210,
        'Inactive': 1900,
      },
      segmentsByLifecycle: {
        'New': 1250,
        'Growing': 3890,
        'Mature': 5210,
        'Declining': 2100,
      },
      customSegments: [],
    );
  }
}

/// Data model for UserSegment
class UserSegmentModel extends UserSegment {
  const UserSegmentModel({
    required super.id,
    required super.name,
    required super.description,
    required super.userCount,
    required super.percentage,
    required super.criteria,
  });

  factory UserSegmentModel.fromJson(Map<String, dynamic> json) {
    return UserSegmentModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      userCount: json['userCount'] as int? ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
      criteria: Map<String, dynamic>.from(json['criteria'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'userCount': userCount,
      'percentage': percentage,
      'criteria': criteria,
    };
  }
}

/// Data model for UserJourneyAnalysis
class UserJourneyAnalysisModel extends UserJourneyAnalysis {
  const UserJourneyAnalysisModel({
    required super.conversionFunnel,
    required super.dropOffPoints,
    required super.commonPaths,
    required super.averageTimeToConversion,
  });

  factory UserJourneyAnalysisModel.fromJson(Map<String, dynamic> json) {
    return UserJourneyAnalysisModel(
      conversionFunnel: Map<String, double>.from(
        (json['conversionFunnel'] as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(key, (value as num?)?.toDouble() ?? 0.0),
        ) ?? {},
      ),
      dropOffPoints: Map<String, double>.from(
        (json['dropOffPoints'] as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(key, (value as num?)?.toDouble() ?? 0.0),
        ) ?? {},
      ),
      commonPaths: List<String>.from(json['commonPaths'] as List<dynamic>? ?? []),
      averageTimeToConversion: (json['averageTimeToConversion'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conversionFunnel': conversionFunnel,
      'dropOffPoints': dropOffPoints,
      'commonPaths': commonPaths,
      'averageTimeToConversion': averageTimeToConversion,
    };
  }

  factory UserJourneyAnalysisModel.mock() {
    return const UserJourneyAnalysisModel(
      conversionFunnel: {
        'Landing': 100.0,
        'Registration': 65.0,
        'First Booking': 45.0,
        'Repeat Booking': 28.0,
      },
      dropOffPoints: {
        'Registration Form': 35.0,
        'Payment Page': 20.0,
        'Service Selection': 15.0,
      },
      commonPaths: [
        'Landing → Registration → First Booking',
        'Landing → Browse Services → Registration → Booking',
        'Landing → Registration → Profile Setup → Booking',
      ],
      averageTimeToConversion: 4.5,
    );
  }
}

/// Data model for UserEngagementMetrics
class UserEngagementMetricsModel extends UserEngagementMetrics {
  const UserEngagementMetricsModel({
    required super.averageSessionsPerUser,
    required super.averagePageViewsPerSession,
    required super.bounceRate,
    required super.featureUsage,
    required super.timeSpentByFeature,
  });

  factory UserEngagementMetricsModel.fromJson(Map<String, dynamic> json) {
    return UserEngagementMetricsModel(
      averageSessionsPerUser: (json['averageSessionsPerUser'] as num?)?.toDouble() ?? 0.0,
      averagePageViewsPerSession: (json['averagePageViewsPerSession'] as num?)?.toDouble() ?? 0.0,
      bounceRate: (json['bounceRate'] as num?)?.toDouble() ?? 0.0,
      featureUsage: Map<String, double>.from(
        (json['featureUsage'] as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(key, (value as num?)?.toDouble() ?? 0.0),
        ) ?? {},
      ),
      timeSpentByFeature: Map<String, double>.from(
        (json['timeSpentByFeature'] as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(key, (value as num?)?.toDouble() ?? 0.0),
        ) ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'averageSessionsPerUser': averageSessionsPerUser,
      'averagePageViewsPerSession': averagePageViewsPerSession,
      'bounceRate': bounceRate,
      'featureUsage': featureUsage,
      'timeSpentByFeature': timeSpentByFeature,
    };
  }

  factory UserEngagementMetricsModel.mock() {
    return const UserEngagementMetricsModel(
      averageSessionsPerUser: 3.2,
      averagePageViewsPerSession: 8.5,
      bounceRate: 25.3,
      featureUsage: {
        'Service Booking': 85.2,
        'Profile Management': 45.8,
        'Payment History': 32.1,
        'Support Chat': 18.9,
      },
      timeSpentByFeature: {
        'Service Booking': 12.5,
        'Profile Management': 4.2,
        'Payment History': 2.8,
        'Support Chat': 8.1,
      },
    );
  }
}
