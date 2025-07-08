import 'package:equatable/equatable.dart';

/// Booking analytics entity for admin dashboard
class BookingAnalytics extends Equatable {
  final int totalBookings;
  final int completedBookings;
  final int cancelledBookings;
  final int pendingBookings;
  final int inProgressBookings;
  final double averageBookingValue;
  final double totalBookingValue;
  final Map<String, int> bookingsByService;
  final Map<String, int> bookingsByTimeSlot;
  final Map<String, int> bookingsByStatus;
  final List<DailyBookingData> bookingsTrend;
  final DateTime periodStart;
  final DateTime periodEnd;
  final BookingInsights insights;

  const BookingAnalytics({
    required this.totalBookings,
    required this.completedBookings,
    required this.cancelledBookings,
    required this.pendingBookings,
    required this.inProgressBookings,
    required this.averageBookingValue,
    required this.totalBookingValue,
    required this.bookingsByService,
    required this.bookingsByTimeSlot,
    required this.bookingsByStatus,
    required this.bookingsTrend,
    required this.periodStart,
    required this.periodEnd,
    required this.insights,
  });

  /// Calculate completion rate
  double get completionRate {
    if (totalBookings == 0) return 0.0;
    return (completedBookings / totalBookings) * 100;
  }

  /// Calculate cancellation rate
  double get cancellationRate {
    if (totalBookings == 0) return 0.0;
    return (cancelledBookings / totalBookings) * 100;
  }

  /// Calculate success rate (completed / (completed + cancelled))
  double get successRate {
    final resolvedBookings = completedBookings + cancelledBookings;
    if (resolvedBookings == 0) return 0.0;
    return (completedBookings / resolvedBookings) * 100;
  }

  /// Get most popular service
  String get mostPopularService {
    if (bookingsByService.isEmpty) return 'N/A';
    return bookingsByService.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Get most popular time slot
  String get mostPopularTimeSlot {
    if (bookingsByTimeSlot.isEmpty) return 'N/A';
    return bookingsByTimeSlot.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Get booking growth rate
  double getGrowthRate(BookingAnalytics? previousPeriod) {
    if (previousPeriod == null || previousPeriod.totalBookings == 0) {
      return totalBookings > 0 ? 100.0 : 0.0;
    }
    return ((totalBookings - previousPeriod.totalBookings) / 
            previousPeriod.totalBookings) * 100;
  }

  @override
  List<Object?> get props => [
        totalBookings,
        completedBookings,
        cancelledBookings,
        pendingBookings,
        inProgressBookings,
        averageBookingValue,
        totalBookingValue,
        bookingsByService,
        bookingsByTimeSlot,
        bookingsByStatus,
        bookingsTrend,
        periodStart,
        periodEnd,
        insights,
      ];
}

/// Daily booking data for trend analysis
class DailyBookingData extends Equatable {
  final DateTime date;
  final int totalBookings;
  final int completedBookings;
  final int cancelledBookings;
  final double totalValue;

  const DailyBookingData({
    required this.date,
    required this.totalBookings,
    required this.completedBookings,
    required this.cancelledBookings,
    required this.totalValue,
  });

  double get completionRate {
    if (totalBookings == 0) return 0.0;
    return (completedBookings / totalBookings) * 100;
  }

  @override
  List<Object?> get props => [
        date,
        totalBookings,
        completedBookings,
        cancelledBookings,
        totalValue,
      ];
}

/// Booking insights and recommendations
class BookingInsights extends Equatable {
  final List<String> trends;
  final List<String> recommendations;
  final List<BookingAlert> alerts;
  final PeakHoursAnalysis peakHours;
  final ServicePerformance servicePerformance;

  const BookingInsights({
    required this.trends,
    required this.recommendations,
    required this.alerts,
    required this.peakHours,
    required this.servicePerformance,
  });

  @override
  List<Object?> get props => [
        trends,
        recommendations,
        alerts,
        peakHours,
        servicePerformance,
      ];
}

/// Booking alert for admin attention
class BookingAlert extends Equatable {
  final String id;
  final BookingAlertType type;
  final String title;
  final String description;
  final BookingAlertSeverity severity;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  const BookingAlert({
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

/// Booking alert types
enum BookingAlertType {
  highCancellationRate,
  lowCompletionRate,
  unusualBookingPattern,
  serviceIssue,
  partnerIssue;

  String get displayName {
    switch (this) {
      case BookingAlertType.highCancellationRate:
        return 'High Cancellation Rate';
      case BookingAlertType.lowCompletionRate:
        return 'Low Completion Rate';
      case BookingAlertType.unusualBookingPattern:
        return 'Unusual Booking Pattern';
      case BookingAlertType.serviceIssue:
        return 'Service Issue';
      case BookingAlertType.partnerIssue:
        return 'Partner Issue';
    }
  }
}

/// Booking alert severity
enum BookingAlertSeverity {
  low,
  medium,
  high,
  critical;

  String get displayName {
    switch (this) {
      case BookingAlertSeverity.low:
        return 'Low';
      case BookingAlertSeverity.medium:
        return 'Medium';
      case BookingAlertSeverity.high:
        return 'High';
      case BookingAlertSeverity.critical:
        return 'Critical';
    }
  }
}

/// Peak hours analysis
class PeakHoursAnalysis extends Equatable {
  final List<String> peakHours;
  final List<String> lowHours;
  final Map<String, double> hourlyDistribution;

  const PeakHoursAnalysis({
    required this.peakHours,
    required this.lowHours,
    required this.hourlyDistribution,
  });

  @override
  List<Object?> get props => [
        peakHours,
        lowHours,
        hourlyDistribution,
      ];
}

/// Service performance analysis
class ServicePerformance extends Equatable {
  final Map<String, double> serviceCompletionRates;
  final Map<String, double> serviceAverageRatings;
  final Map<String, double> serviceRevenue;
  final List<String> topPerformingServices;
  final List<String> underperformingServices;

  const ServicePerformance({
    required this.serviceCompletionRates,
    required this.serviceAverageRatings,
    required this.serviceRevenue,
    required this.topPerformingServices,
    required this.underperformingServices,
  });

  @override
  List<Object?> get props => [
        serviceCompletionRates,
        serviceAverageRatings,
        serviceRevenue,
        topPerformingServices,
        underperformingServices,
      ];
}
