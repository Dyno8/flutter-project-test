import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/system_metrics.dart';
import '../entities/booking_analytics.dart';
import '../entities/revenue_analytics.dart';
import '../entities/user_analytics.dart';
import '../entities/partner_analytics.dart';
import '../entities/report_config.dart';

/// Abstract repository interface for analytics operations
abstract class AnalyticsRepository {
  /// Get real-time system metrics
  Future<Either<Failure, SystemMetrics>> getSystemMetrics();

  /// Stream of real-time system metrics
  Stream<Either<Failure, SystemMetrics>> watchSystemMetrics();

  /// Get booking analytics for a specific period
  Future<Either<Failure, BookingAnalytics>> getBookingAnalytics({
    required DateTime startDate,
    required DateTime endDate,
    String? serviceId,
    String? partnerId,
  });

  /// Get partner analytics
  Future<Either<Failure, PartnerAnalytics>> getPartnerAnalytics({
    required DateTime startDate,
    required DateTime endDate,
    bool includePerformanceDetails = false,
    bool includeQualityMetrics = false,
  });

  /// Get user analytics
  Future<Either<Failure, UserAnalytics>> getUserAnalytics({
    required DateTime startDate,
    required DateTime endDate,
    bool includeCohortAnalysis = false,
    bool includeSegmentation = false,
  });

  /// Get revenue analytics
  Future<Either<Failure, RevenueAnalytics>> getRevenueAnalytics({
    required DateTime startDate,
    required DateTime endDate,
    bool includeForecasts = false,
    bool includeComparisons = false,
  });

  /// Get system health metrics
  Future<Either<Failure, SystemHealth>> getSystemHealth();

  /// Stream of real-time system health
  Stream<Either<Failure, SystemHealth>> watchSystemHealth();

  /// Export analytics data
  Future<Either<Failure, String>> exportAnalyticsData({
    required AnalyticsExportType type,
    required DateTime startDate,
    required DateTime endDate,
    required AnalyticsExportFormat format,
    Map<String, dynamic>? filters,
  });

  /// Get analytics summary for dashboard
  Future<Either<Failure, AnalyticsSummary>> getAnalyticsSummary({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Get comparative analytics (current vs previous period)
  Future<Either<Failure, ComparativeAnalytics>> getComparativeAnalytics({
    required DateTime currentStart,
    required DateTime currentEnd,
    required DateTime previousStart,
    required DateTime previousEnd,
  });

  /// Get top performing metrics
  Future<Either<Failure, TopPerformingMetrics>> getTopPerformingMetrics({
    required DateTime startDate,
    required DateTime endDate,
    int limit = 10,
  });

  /// Get analytics alerts
  Future<Either<Failure, List<AnalyticsAlert>>> getAnalyticsAlerts({
    AnalyticsAlertSeverity? severity,
    bool unreadOnly = false,
    int limit = 50,
  });

  /// Mark analytics alert as read
  Future<Either<Failure, void>> markAlertAsRead(String alertId);

  /// Get custom analytics query results
  Future<Either<Failure, Map<String, dynamic>>> executeCustomQuery({
    required String query,
    Map<String, dynamic>? parameters,
  });

  // Report Generation Methods

  /// Generate analytics report
  Future<Either<Failure, GeneratedReport>> generateReport({
    required ReportConfig config,
    Map<String, dynamic>? customData,
  });

  /// Get report configurations
  Future<Either<Failure, List<ReportConfig>>> getReportConfigs();

  /// Create report configuration
  Future<Either<Failure, ReportConfig>> createReportConfig({
    required String name,
    required String description,
    required ReportType type,
    required ReportFormat format,
    required DateTime startDate,
    required DateTime endDate,
    required List<String> metrics,
    required List<String> dimensions,
    List<ReportFilter> filters = const [],
    ReportSchedule? schedule,
    List<String> recipients = const [],
    Map<String, dynamic> customSettings = const {},
  });

  /// Update report configuration
  Future<Either<Failure, ReportConfig>> updateReportConfig({
    required String id,
    String? name,
    String? description,
    ReportType? type,
    ReportFormat? format,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? metrics,
    List<String>? dimensions,
    List<ReportFilter>? filters,
    ReportSchedule? schedule,
    List<String>? recipients,
    Map<String, dynamic>? customSettings,
  });

  /// Delete report configuration
  Future<Either<Failure, void>> deleteReportConfig(String id);

  /// Get generated reports
  Future<Either<Failure, List<GeneratedReport>>> getGeneratedReports({
    String? configId,
    int limit = 20,
    int offset = 0,
  });
}

/// System health entity
class SystemHealth {
  final SystemHealthStatus status;
  final double apiResponseTime;
  final double errorRate;
  final int activeConnections;
  final double memoryUsage;
  final double cpuUsage;
  final List<SystemAlert> alerts;
  final DateTime lastUpdated;

  const SystemHealth({
    required this.status,
    required this.apiResponseTime,
    required this.errorRate,
    required this.activeConnections,
    required this.memoryUsage,
    required this.cpuUsage,
    required this.alerts,
    required this.lastUpdated,
  });
}

/// System alert
class SystemAlert {
  final String id;
  final String title;
  final String description;
  final SystemAlertSeverity severity;
  final DateTime timestamp;

  const SystemAlert({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.timestamp,
  });
}

/// System alert severity
enum SystemAlertSeverity { info, warning, error, critical }

/// Analytics export types
enum AnalyticsExportType {
  systemMetrics,
  bookingAnalytics,
  partnerAnalytics,
  userAnalytics,
  revenueAnalytics,
  fullReport,
}

/// Analytics export formats
enum AnalyticsExportFormat { csv, excel, pdf, json }

/// Analytics summary for dashboard
class AnalyticsSummary {
  final SystemMetrics systemMetrics;
  final BookingAnalytics bookingAnalytics;
  final double totalRevenue;
  final int totalUsers;
  final int totalPartners;
  final List<String> keyInsights;

  const AnalyticsSummary({
    required this.systemMetrics,
    required this.bookingAnalytics,
    required this.totalRevenue,
    required this.totalUsers,
    required this.totalPartners,
    required this.keyInsights,
  });
}

/// Comparative analytics
class ComparativeAnalytics {
  final AnalyticsSummary currentPeriod;
  final AnalyticsSummary previousPeriod;
  final GrowthMetrics growthMetrics;

  const ComparativeAnalytics({
    required this.currentPeriod,
    required this.previousPeriod,
    required this.growthMetrics,
  });
}

/// Top performing metrics
class TopPerformingMetrics {
  final List<String> topServices;
  final List<PartnerPerformance> topPartners;
  final List<String> topLocations;
  final List<String> topTimeSlots;

  const TopPerformingMetrics({
    required this.topServices,
    required this.topPartners,
    required this.topLocations,
    required this.topTimeSlots,
  });
}

/// Partner performance entity
class PartnerPerformance {
  final String partnerId;
  final String partnerName;
  final double performanceScore;
  final int completedBookings;

  const PartnerPerformance({
    required this.partnerId,
    required this.partnerName,
    required this.performanceScore,
    required this.completedBookings,
  });
}

/// Analytics alert
class AnalyticsAlert {
  final String id;
  final String title;
  final String description;
  final AnalyticsAlertSeverity severity;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic> metadata;

  const AnalyticsAlert({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.timestamp,
    this.isRead = false,
    this.metadata = const {},
  });
}

/// Analytics alert severity
enum AnalyticsAlertSeverity { low, medium, high, critical }
