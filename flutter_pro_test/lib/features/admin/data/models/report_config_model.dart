import '../../domain/entities/report_config.dart';

/// Data model for ReportConfig entity
class ReportConfigModel extends ReportConfig {
  const ReportConfigModel({
    required super.id,
    required super.name,
    required super.description,
    required super.type,
    required super.format,
    required super.startDate,
    required super.endDate,
    required super.metrics,
    required super.dimensions,
    required super.filters,
    super.schedule,
    required super.recipients,
    super.customSettings = const {},
    required super.createdAt,
    required super.updatedAt,
    required super.createdBy,
  });

  /// Create from JSON
  factory ReportConfigModel.fromJson(Map<String, dynamic> json) {
    return ReportConfigModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: ReportType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ReportType.overview,
      ),
      format: ReportFormat.values.firstWhere(
        (e) => e.name == json['format'],
        orElse: () => ReportFormat.pdf,
      ),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      metrics: List<String>.from(json['metrics'] as List<dynamic>? ?? []),
      dimensions: List<String>.from(json['dimensions'] as List<dynamic>? ?? []),
      filters: (json['filters'] as List<dynamic>?)
          ?.map((item) => ReportFilterModel.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      schedule: json['schedule'] != null 
          ? ReportScheduleModel.fromJson(json['schedule'] as Map<String, dynamic>)
          : null,
      recipients: List<String>.from(json['recipients'] as List<dynamic>? ?? []),
      customSettings: Map<String, dynamic>.from(json['customSettings'] as Map<String, dynamic>? ?? {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'format': format.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'metrics': metrics,
      'dimensions': dimensions,
      'filters': filters.map((filter) => (filter as ReportFilterModel).toJson()).toList(),
      'schedule': schedule != null ? (schedule as ReportScheduleModel).toJson() : null,
      'recipients': recipients,
      'customSettings': customSettings,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  /// Convert to entity
  ReportConfig toEntity() => this;

  /// Create mock data for testing
  factory ReportConfigModel.mock() {
    final now = DateTime.now();
    
    return ReportConfigModel(
      id: 'report_config_1',
      name: 'Monthly Revenue Report',
      description: 'Comprehensive monthly revenue analysis and trends',
      type: ReportType.revenue,
      format: ReportFormat.pdf,
      startDate: DateTime(now.year, now.month, 1),
      endDate: DateTime(now.year, now.month + 1, 0),
      metrics: [
        'totalRevenue',
        'monthlyRevenue',
        'averageOrderValue',
        'revenueByService',
      ],
      dimensions: [
        'time',
        'service',
        'region',
      ],
      filters: [
        ReportFilterModel(
          field: 'region',
          operator: FilterOperator.inList,
          value: ['Ho Chi Minh City', 'Hanoi'],
          displayName: 'Major Cities',
        ),
      ],
      schedule: ReportScheduleModel(
        frequency: ScheduleFrequency.monthly,
        dayOfMonth: 1,
        timeOfDay: '09:00',
        timezone: 'Asia/Ho_Chi_Minh',
        isActive: true,
      ),
      recipients: ['admin@carenow.com', 'finance@carenow.com'],
      customSettings: {
        'includeCharts': true,
        'includeComparisons': true,
        'chartTypes': ['line', 'bar', 'pie'],
      },
      createdAt: now.subtract(const Duration(days: 30)),
      updatedAt: now.subtract(const Duration(days: 1)),
      createdBy: 'admin_user_1',
    );
  }
}

/// Data model for ReportFilter
class ReportFilterModel extends ReportFilter {
  const ReportFilterModel({
    required super.field,
    required super.operator,
    required super.value,
    super.displayName,
  });

  factory ReportFilterModel.fromJson(Map<String, dynamic> json) {
    return ReportFilterModel(
      field: json['field'] as String,
      operator: FilterOperator.values.firstWhere(
        (e) => e.name == json['operator'],
        orElse: () => FilterOperator.equals,
      ),
      value: json['value'],
      displayName: json['displayName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'field': field,
      'operator': operator.name,
      'value': value,
      'displayName': displayName,
    };
  }
}

/// Data model for ReportSchedule
class ReportScheduleModel extends ReportSchedule {
  const ReportScheduleModel({
    required super.frequency,
    super.interval = 1,
    super.daysOfWeek = const [],
    super.dayOfMonth = 1,
    required super.timeOfDay,
    required super.timezone,
    super.nextRunDate,
    super.lastRunDate,
    super.isActive = true,
  });

  factory ReportScheduleModel.fromJson(Map<String, dynamic> json) {
    return ReportScheduleModel(
      frequency: ScheduleFrequency.values.firstWhere(
        (e) => e.name == json['frequency'],
        orElse: () => ScheduleFrequency.daily,
      ),
      interval: json['interval'] as int? ?? 1,
      daysOfWeek: List<int>.from(json['daysOfWeek'] as List<dynamic>? ?? []),
      dayOfMonth: json['dayOfMonth'] as int? ?? 1,
      timeOfDay: json['timeOfDay'] as String,
      timezone: json['timezone'] as String,
      nextRunDate: json['nextRunDate'] != null 
          ? DateTime.parse(json['nextRunDate'] as String)
          : null,
      lastRunDate: json['lastRunDate'] != null 
          ? DateTime.parse(json['lastRunDate'] as String)
          : null,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'frequency': frequency.name,
      'interval': interval,
      'daysOfWeek': daysOfWeek,
      'dayOfMonth': dayOfMonth,
      'timeOfDay': timeOfDay,
      'timezone': timezone,
      'nextRunDate': nextRunDate?.toIso8601String(),
      'lastRunDate': lastRunDate?.toIso8601String(),
      'isActive': isActive,
    };
  }
}

/// Data model for GeneratedReport
class GeneratedReportModel extends GeneratedReport {
  const GeneratedReportModel({
    required super.id,
    required super.configId,
    required super.fileName,
    required super.format,
    required super.fileSizeBytes,
    required super.generatedAt,
    required super.generatedBy,
    required super.status,
    super.downloadUrl,
    super.errorMessage,
    super.metadata = const {},
  });

  factory GeneratedReportModel.fromJson(Map<String, dynamic> json) {
    return GeneratedReportModel(
      id: json['id'] as String,
      configId: json['configId'] as String,
      fileName: json['fileName'] as String,
      format: ReportFormat.values.firstWhere(
        (e) => e.name == json['format'],
        orElse: () => ReportFormat.pdf,
      ),
      fileSizeBytes: json['fileSizeBytes'] as int? ?? 0,
      generatedAt: DateTime.parse(json['generatedAt'] as String),
      generatedBy: json['generatedBy'] as String,
      status: ReportStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ReportStatus.pending,
      ),
      downloadUrl: json['downloadUrl'] as String?,
      errorMessage: json['errorMessage'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'configId': configId,
      'fileName': fileName,
      'format': format.name,
      'fileSizeBytes': fileSizeBytes,
      'generatedAt': generatedAt.toIso8601String(),
      'generatedBy': generatedBy,
      'status': status.name,
      'downloadUrl': downloadUrl,
      'errorMessage': errorMessage,
      'metadata': metadata,
    };
  }

  /// Convert to entity
  GeneratedReport toEntity() => this;

  /// Create mock data for testing
  factory GeneratedReportModel.mock() {
    final now = DateTime.now();
    
    return GeneratedReportModel(
      id: 'generated_report_1',
      configId: 'report_config_1',
      fileName: 'monthly_revenue_report_${now.year}_${now.month}.pdf',
      format: ReportFormat.pdf,
      fileSizeBytes: 2048576, // 2MB
      generatedAt: now.subtract(const Duration(hours: 2)),
      generatedBy: 'admin_user_1',
      status: ReportStatus.completed,
      downloadUrl: 'https://storage.carenow.com/reports/monthly_revenue_report_${now.year}_${now.month}.pdf',
      metadata: {
        'totalPages': 15,
        'chartCount': 8,
        'tableCount': 5,
        'generationTimeMs': 12500,
      },
    );
  }
}

/// Available report metrics
class ReportMetrics {
  static const List<String> revenue = [
    'totalRevenue',
    'monthlyRevenue',
    'weeklyRevenue',
    'dailyRevenue',
    'averageOrderValue',
    'totalCommissions',
    'netRevenue',
    'revenueByService',
    'revenueByPartner',
    'revenueByRegion',
    'revenueTrend',
    'monthlyTrend',
  ];

  static const List<String> users = [
    'totalUsers',
    'activeUsers',
    'newUsers',
    'returningUsers',
    'inactiveUsers',
    'userRetentionRate',
    'userChurnRate',
    'averageSessionDuration',
    'usersByRegion',
    'usersByAgeGroup',
    'usersByGender',
    'userGrowthTrend',
    'cohortAnalysis',
  ];

  static const List<String> partners = [
    'totalPartners',
    'activePartners',
    'newPartners',
    'inactivePartners',
    'suspendedPartners',
    'averageRating',
    'averageCompletionRate',
    'averageResponseTime',
    'partnersByRegion',
    'partnersByService',
    'partnersByRating',
    'partnerGrowthTrend',
    'topPerformers',
    'underPerformers',
  ];

  static const List<String> bookings = [
    'totalBookings',
    'completedBookings',
    'cancelledBookings',
    'pendingBookings',
    'inProgressBookings',
    'averageBookingValue',
    'totalBookingValue',
    'bookingsByService',
    'bookingsByTimeSlot',
    'bookingsByStatus',
    'bookingsTrend',
    'completionRate',
    'cancellationRate',
  ];

  static const List<String> system = [
    'totalUsers',
    'totalPartners',
    'totalBookings',
    'activeBookings',
    'totalRevenue',
    'averageRating',
    'systemHealth',
    'apiResponseTime',
    'errorRate',
    'activeConnections',
  ];

  /// Get metrics for report type
  static List<String> getMetricsForType(ReportType type) {
    switch (type) {
      case ReportType.revenue:
        return revenue;
      case ReportType.users:
        return users;
      case ReportType.partners:
        return partners;
      case ReportType.bookings:
        return bookings;
      case ReportType.overview:
        return system;
      case ReportType.performance:
        return [...system, ...bookings.take(5)];
      case ReportType.custom:
        return [...revenue, ...users, ...partners, ...bookings];
    }
  }
}

/// Available report dimensions
class ReportDimensions {
  static const List<String> time = [
    'date',
    'hour',
    'dayOfWeek',
    'week',
    'month',
    'quarter',
    'year',
  ];

  static const List<String> geography = [
    'region',
    'city',
    'district',
    'country',
  ];

  static const List<String> service = [
    'serviceType',
    'serviceCategory',
    'serviceDuration',
    'servicePrice',
  ];

  static const List<String> user = [
    'userType',
    'userSegment',
    'ageGroup',
    'gender',
    'registrationDate',
  ];

  static const List<String> partner = [
    'partnerType',
    'partnerRating',
    'partnerExperience',
    'partnerServices',
  ];

  /// Get all available dimensions
  static List<String> get all => [
    ...time,
    ...geography,
    ...service,
    ...user,
    ...partner,
  ];

  /// Get dimensions for report type
  static List<String> getDimensionsForType(ReportType type) {
    switch (type) {
      case ReportType.revenue:
        return [...time, ...geography, ...service];
      case ReportType.users:
        return [...time, ...geography, ...user];
      case ReportType.partners:
        return [...time, ...geography, ...partner];
      case ReportType.bookings:
        return [...time, ...geography, ...service, ...user];
      case ReportType.overview:
      case ReportType.performance:
        return time;
      case ReportType.custom:
        return all;
    }
  }
}
