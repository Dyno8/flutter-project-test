import 'package:equatable/equatable.dart';

/// System metrics entity for admin dashboard
class SystemMetrics extends Equatable {
  final int totalUsers;
  final int totalPartners;
  final int totalBookings;
  final int activeBookings;
  final int completedBookings;
  final int cancelledBookings;
  final double totalRevenue;
  final double monthlyRevenue;
  final double dailyRevenue;
  final double averageRating;
  final int totalReviews;
  final DateTime timestamp;
  final SystemPerformance performance;

  const SystemMetrics({
    required this.totalUsers,
    required this.totalPartners,
    required this.totalBookings,
    required this.activeBookings,
    required this.completedBookings,
    required this.cancelledBookings,
    required this.totalRevenue,
    required this.monthlyRevenue,
    required this.dailyRevenue,
    required this.averageRating,
    required this.totalReviews,
    required this.timestamp,
    required this.performance,
  });

  /// Calculate booking completion rate
  double get bookingCompletionRate {
    if (totalBookings == 0) return 0.0;
    return (completedBookings / totalBookings) * 100;
  }

  /// Calculate booking cancellation rate
  double get bookingCancellationRate {
    if (totalBookings == 0) return 0.0;
    return (cancelledBookings / totalBookings) * 100;
  }

  /// Calculate average revenue per booking
  double get averageRevenuePerBooking {
    if (completedBookings == 0) return 0.0;
    return totalRevenue / completedBookings;
  }

  /// Calculate partner utilization rate
  double get partnerUtilizationRate {
    if (totalPartners == 0) return 0.0;
    // Assuming active bookings indicate partner utilization
    return (activeBookings / totalPartners) * 100;
  }

  /// Calculate system health as a numeric value (0.0 to 1.0)
  double get systemHealth {
    // Base health score on performance metrics
    double healthScore = 1.0;

    // Reduce score based on error rate (0-10% range)
    if (performance.errorRate > 0) {
      healthScore -= (performance.errorRate / 10.0).clamp(0.0, 0.3);
    }

    // Reduce score based on API response time (0-3000ms range)
    if (performance.apiResponseTime > 500) {
      healthScore -= ((performance.apiResponseTime - 500) / 2500.0).clamp(
        0.0,
        0.3,
      );
    }

    // Reduce score based on CPU usage (0-100% range)
    if (performance.cpuUsage > 50) {
      healthScore -= ((performance.cpuUsage - 50) / 50.0).clamp(0.0, 0.2);
    }

    // Reduce score based on memory usage (0-100% range)
    if (performance.memoryUsage > 50) {
      healthScore -= ((performance.memoryUsage - 50) / 50.0).clamp(0.0, 0.2);
    }

    return healthScore.clamp(0.0, 1.0);
  }

  /// Get growth metrics compared to previous period
  GrowthMetrics getGrowthMetrics(SystemMetrics? previousMetrics) {
    if (previousMetrics == null) {
      return const GrowthMetrics(
        userGrowth: 0.0,
        partnerGrowth: 0.0,
        bookingGrowth: 0.0,
        revenueGrowth: 0.0,
      );
    }

    return GrowthMetrics(
      userGrowth: _calculateGrowthRate(previousMetrics.totalUsers, totalUsers),
      partnerGrowth: _calculateGrowthRate(
        previousMetrics.totalPartners,
        totalPartners,
      ),
      bookingGrowth: _calculateGrowthRate(
        previousMetrics.totalBookings,
        totalBookings,
      ),
      revenueGrowth: _calculateGrowthRate(
        previousMetrics.totalRevenue,
        totalRevenue,
      ),
    );
  }

  double _calculateGrowthRate(num previous, num current) {
    if (previous == 0) return current > 0 ? 100.0 : 0.0;
    return ((current - previous) / previous) * 100;
  }

  @override
  List<Object?> get props => [
    totalUsers,
    totalPartners,
    totalBookings,
    activeBookings,
    completedBookings,
    cancelledBookings,
    totalRevenue,
    monthlyRevenue,
    dailyRevenue,
    averageRating,
    totalReviews,
    timestamp,
    performance,
  ];
}

/// System performance metrics
class SystemPerformance extends Equatable {
  final double apiResponseTime;
  final double errorRate;
  final int activeConnections;
  final double memoryUsage;
  final double cpuUsage;
  final double diskUsage;
  final int requestsPerMinute;
  final DateTime lastUpdated;

  const SystemPerformance({
    required this.apiResponseTime,
    required this.errorRate,
    required this.activeConnections,
    required this.memoryUsage,
    required this.cpuUsage,
    required this.diskUsage,
    required this.requestsPerMinute,
    required this.lastUpdated,
  });

  /// Get system health status
  SystemHealthStatus get healthStatus {
    if (errorRate > 5.0 ||
        apiResponseTime > 2000 ||
        cpuUsage > 90 ||
        memoryUsage > 90) {
      return SystemHealthStatus.critical;
    } else if (errorRate > 2.0 ||
        apiResponseTime > 1000 ||
        cpuUsage > 70 ||
        memoryUsage > 70) {
      return SystemHealthStatus.warning;
    } else {
      return SystemHealthStatus.healthy;
    }
  }

  @override
  List<Object?> get props => [
    apiResponseTime,
    errorRate,
    activeConnections,
    memoryUsage,
    cpuUsage,
    diskUsage,
    requestsPerMinute,
    lastUpdated,
  ];
}

/// Growth metrics for comparison
class GrowthMetrics extends Equatable {
  final double userGrowth;
  final double partnerGrowth;
  final double bookingGrowth;
  final double revenueGrowth;

  const GrowthMetrics({
    required this.userGrowth,
    required this.partnerGrowth,
    required this.bookingGrowth,
    required this.revenueGrowth,
  });

  @override
  List<Object?> get props => [
    userGrowth,
    partnerGrowth,
    bookingGrowth,
    revenueGrowth,
  ];
}

/// System health status
enum SystemHealthStatus {
  healthy,
  warning,
  critical;

  String get displayName {
    switch (this) {
      case SystemHealthStatus.healthy:
        return 'Healthy';
      case SystemHealthStatus.warning:
        return 'Warning';
      case SystemHealthStatus.critical:
        return 'Critical';
    }
  }

  String get description {
    switch (this) {
      case SystemHealthStatus.healthy:
        return 'All systems operating normally';
      case SystemHealthStatus.warning:
        return 'Some metrics require attention';
      case SystemHealthStatus.critical:
        return 'Critical issues detected';
    }
  }
}
