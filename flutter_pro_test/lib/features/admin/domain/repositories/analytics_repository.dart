import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/system_metrics.dart';
import '../entities/booking_analytics.dart';

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
    String? serviceId,
  });

  /// Get user analytics
  Future<Either<Failure, UserAnalytics>> getUserAnalytics({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Get revenue analytics
  Future<Either<Failure, RevenueAnalytics>> getRevenueAnalytics({
    required DateTime startDate,
    required DateTime endDate,
    String? serviceId,
    String? partnerId,
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
}

/// Partner analytics entity
class PartnerAnalytics {
  final int totalPartners;
  final int activePartners;
  final int verifiedPartners;
  final double averageRating;
  final List<PartnerPerformance> topPerformingPartners;
  final Map<String, int> partnersByService;
  final List<PartnerEarningData> partnerEarnings;
  final DateTime periodStart;
  final DateTime periodEnd;

  const PartnerAnalytics({
    required this.totalPartners,
    required this.activePartners,
    required this.verifiedPartners,
    required this.averageRating,
    required this.topPerformingPartners,
    required this.partnersByService,
    required this.partnerEarnings,
    required this.periodStart,
    required this.periodEnd,
  });
}

/// Partner performance data
class PartnerPerformance {
  final String partnerId;
  final String partnerName;
  final double rating;
  final int completedBookings;
  final double totalEarnings;
  final double completionRate;

  const PartnerPerformance({
    required this.partnerId,
    required this.partnerName,
    required this.rating,
    required this.completedBookings,
    required this.totalEarnings,
    required this.completionRate,
  });
}

/// Partner earning data
class PartnerEarningData {
  final String partnerId;
  final String partnerName;
  final DateTime date;
  final double earnings;
  final int bookingsCompleted;

  const PartnerEarningData({
    required this.partnerId,
    required this.partnerName,
    required this.date,
    required this.earnings,
    required this.bookingsCompleted,
  });
}

/// User analytics entity
class UserAnalytics {
  final int totalUsers;
  final int activeUsers;
  final int newUsersToday;
  final double userRetentionRate;
  final Map<String, int> usersByLocation;
  final UserEngagementData userEngagement;
  final DateTime periodStart;
  final DateTime periodEnd;

  const UserAnalytics({
    required this.totalUsers,
    required this.activeUsers,
    required this.newUsersToday,
    required this.userRetentionRate,
    required this.usersByLocation,
    required this.userEngagement,
    required this.periodStart,
    required this.periodEnd,
  });
}

/// User engagement data
class UserEngagementData {
  final double averageSessionDuration;
  final int averageBookingsPerUser;
  final double userSatisfactionScore;
  final Map<String, int> featureUsage;

  const UserEngagementData({
    required this.averageSessionDuration,
    required this.averageBookingsPerUser,
    required this.userSatisfactionScore,
    required this.featureUsage,
  });
}

/// Revenue analytics entity
class RevenueAnalytics {
  final double totalRevenue;
  final double monthlyRevenue;
  final double dailyRevenue;
  final Map<String, double> revenueByService;
  final List<DailyRevenueData> revenueTrend;
  final double commissionEarned;
  final double averageOrderValue;
  final DateTime periodStart;
  final DateTime periodEnd;

  const RevenueAnalytics({
    required this.totalRevenue,
    required this.monthlyRevenue,
    required this.dailyRevenue,
    required this.revenueByService,
    required this.revenueTrend,
    required this.commissionEarned,
    required this.averageOrderValue,
    required this.periodStart,
    required this.periodEnd,
  });
}

/// Daily revenue data
class DailyRevenueData {
  final DateTime date;
  final double revenue;
  final int bookingsCount;

  const DailyRevenueData({
    required this.date,
    required this.revenue,
    required this.bookingsCount,
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
enum SystemAlertSeverity {
  info,
  warning,
  error,
  critical;
}

/// Analytics export types
enum AnalyticsExportType {
  systemMetrics,
  bookingAnalytics,
  partnerAnalytics,
  userAnalytics,
  revenueAnalytics,
  fullReport;
}

/// Analytics export formats
enum AnalyticsExportFormat {
  csv,
  excel,
  pdf,
  json;
}

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
enum AnalyticsAlertSeverity {
  low,
  medium,
  high,
  critical;
}
