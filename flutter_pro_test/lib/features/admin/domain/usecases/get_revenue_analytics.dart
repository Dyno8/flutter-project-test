import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/revenue_analytics.dart';
import '../repositories/analytics_repository.dart';

/// Use case for getting comprehensive revenue analytics
class GetRevenueAnalytics
    implements UseCase<RevenueAnalytics, GetRevenueAnalyticsParams> {
  final AnalyticsRepository repository;

  GetRevenueAnalytics(this.repository);

  @override
  Future<Either<Failure, RevenueAnalytics>> call(
    GetRevenueAnalyticsParams params,
  ) async {
    return await repository.getRevenueAnalytics(
      startDate: params.startDate,
      endDate: params.endDate,
      includeForecasts: params.includeForecasts,
      includeComparisons: params.includeComparisons,
    );
  }
}

/// Parameters for GetRevenueAnalytics use case
class GetRevenueAnalyticsParams {
  final DateTime startDate;
  final DateTime endDate;
  final bool includeForecasts;
  final bool includeComparisons;

  const GetRevenueAnalyticsParams({
    required this.startDate,
    required this.endDate,
    this.includeForecasts = false,
    this.includeComparisons = false,
  });

  /// Create params for current month
  factory GetRevenueAnalyticsParams.currentMonth({
    bool includeForecasts = false,
    bool includeComparisons = false,
  }) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    return GetRevenueAnalyticsParams(
      startDate: startOfMonth,
      endDate: endOfMonth,
      includeForecasts: includeForecasts,
      includeComparisons: includeComparisons,
    );
  }

  /// Create params for last 30 days
  factory GetRevenueAnalyticsParams.last30Days({
    bool includeForecasts = false,
    bool includeComparisons = false,
  }) {
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 30));

    return GetRevenueAnalyticsParams(
      startDate: startDate,
      endDate: now,
      includeForecasts: includeForecasts,
      includeComparisons: includeComparisons,
    );
  }

  /// Create params for last 7 days
  factory GetRevenueAnalyticsParams.last7Days({
    bool includeForecasts = false,
    bool includeComparisons = false,
  }) {
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 7));

    return GetRevenueAnalyticsParams(
      startDate: startDate,
      endDate: now,
      includeForecasts: includeForecasts,
      includeComparisons: includeComparisons,
    );
  }

  /// Create params for current quarter
  factory GetRevenueAnalyticsParams.currentQuarter({
    bool includeForecasts = false,
    bool includeComparisons = false,
  }) {
    final now = DateTime.now();
    final quarter = ((now.month - 1) ~/ 3) + 1;
    final startMonth = (quarter - 1) * 3 + 1;
    final startOfQuarter = DateTime(now.year, startMonth, 1);
    final endOfQuarter = DateTime(now.year, startMonth + 3, 0);

    return GetRevenueAnalyticsParams(
      startDate: startOfQuarter,
      endDate: endOfQuarter,
      includeForecasts: includeForecasts,
      includeComparisons: includeComparisons,
    );
  }

  /// Create params for current year
  factory GetRevenueAnalyticsParams.currentYear({
    bool includeForecasts = false,
    bool includeComparisons = false,
  }) {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final endOfYear = DateTime(now.year, 12, 31);

    return GetRevenueAnalyticsParams(
      startDate: startOfYear,
      endDate: endOfYear,
      includeForecasts: includeForecasts,
      includeComparisons: includeComparisons,
    );
  }

  /// Create custom date range params
  factory GetRevenueAnalyticsParams.customRange({
    required DateTime startDate,
    required DateTime endDate,
    bool includeForecasts = false,
    bool includeComparisons = false,
  }) {
    return GetRevenueAnalyticsParams(
      startDate: startDate,
      endDate: endDate,
      includeForecasts: includeForecasts,
      includeComparisons: includeComparisons,
    );
  }

  /// Get period description
  String get periodDescription {
    final difference = endDate.difference(startDate).inDays;

    if (difference <= 1) {
      return 'Today';
    } else if (difference <= 7) {
      return 'Last 7 days';
    } else if (difference <= 30) {
      return 'Last 30 days';
    } else if (difference <= 90) {
      return 'Last 3 months';
    } else if (difference <= 365) {
      return 'This year';
    } else {
      return 'Custom range';
    }
  }

  /// Check if this is a valid date range
  bool get isValidRange => startDate.isBefore(endDate);

  /// Get the number of days in the range
  int get daysInRange => endDate.difference(startDate).inDays + 1;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GetRevenueAnalyticsParams &&
          runtimeType == other.runtimeType &&
          startDate == other.startDate &&
          endDate == other.endDate &&
          includeForecasts == other.includeForecasts &&
          includeComparisons == other.includeComparisons;

  @override
  int get hashCode =>
      startDate.hashCode ^
      endDate.hashCode ^
      includeForecasts.hashCode ^
      includeComparisons.hashCode;

  @override
  String toString() {
    return 'GetRevenueAnalyticsParams{startDate: $startDate, endDate: $endDate, includeForecasts: $includeForecasts, includeComparisons: $includeComparisons}';
  }
}
