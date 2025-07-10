import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/partner_analytics.dart';
import '../repositories/analytics_repository.dart';

/// Use case for getting comprehensive partner analytics
class GetPartnerAnalytics
    implements UseCase<PartnerAnalytics, GetPartnerAnalyticsParams> {
  final AnalyticsRepository repository;

  GetPartnerAnalytics(this.repository);

  @override
  Future<Either<Failure, PartnerAnalytics>> call(
    GetPartnerAnalyticsParams params,
  ) async {
    return await repository.getPartnerAnalytics(
      startDate: params.startDate,
      endDate: params.endDate,
      includePerformanceDetails: params.includePerformanceDetails,
      includeQualityMetrics: params.includeQualityMetrics,
    );
  }
}

/// Parameters for GetPartnerAnalytics use case
class GetPartnerAnalyticsParams {
  final DateTime startDate;
  final DateTime endDate;
  final bool includePerformanceDetails;
  final bool includeQualityMetrics;

  const GetPartnerAnalyticsParams({
    required this.startDate,
    required this.endDate,
    this.includePerformanceDetails = false,
    this.includeQualityMetrics = false,
  });

  /// Create params for current month
  factory GetPartnerAnalyticsParams.currentMonth({
    bool includePerformanceDetails = false,
    bool includeQualityMetrics = false,
  }) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    return GetPartnerAnalyticsParams(
      startDate: startOfMonth,
      endDate: endOfMonth,
      includePerformanceDetails: includePerformanceDetails,
      includeQualityMetrics: includeQualityMetrics,
    );
  }

  /// Create params for last 30 days
  factory GetPartnerAnalyticsParams.last30Days({
    bool includePerformanceDetails = false,
    bool includeQualityMetrics = false,
  }) {
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 30));

    return GetPartnerAnalyticsParams(
      startDate: startDate,
      endDate: now,
      includePerformanceDetails: includePerformanceDetails,
      includeQualityMetrics: includeQualityMetrics,
    );
  }

  /// Create params for last 7 days
  factory GetPartnerAnalyticsParams.last7Days({
    bool includePerformanceDetails = false,
    bool includeQualityMetrics = false,
  }) {
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 7));

    return GetPartnerAnalyticsParams(
      startDate: startDate,
      endDate: now,
      includePerformanceDetails: includePerformanceDetails,
      includeQualityMetrics: includeQualityMetrics,
    );
  }

  /// Create params for current quarter
  factory GetPartnerAnalyticsParams.currentQuarter({
    bool includePerformanceDetails = false,
    bool includeQualityMetrics = false,
  }) {
    final now = DateTime.now();
    final quarter = ((now.month - 1) ~/ 3) + 1;
    final startMonth = (quarter - 1) * 3 + 1;
    final startOfQuarter = DateTime(now.year, startMonth, 1);
    final endOfQuarter = DateTime(now.year, startMonth + 3, 0);

    return GetPartnerAnalyticsParams(
      startDate: startOfQuarter,
      endDate: endOfQuarter,
      includePerformanceDetails: includePerformanceDetails,
      includeQualityMetrics: includeQualityMetrics,
    );
  }

  /// Create params for current year
  factory GetPartnerAnalyticsParams.currentYear({
    bool includePerformanceDetails = false,
    bool includeQualityMetrics = false,
  }) {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final endOfYear = DateTime(now.year, 12, 31);

    return GetPartnerAnalyticsParams(
      startDate: startOfYear,
      endDate: endOfYear,
      includePerformanceDetails: includePerformanceDetails,
      includeQualityMetrics: includeQualityMetrics,
    );
  }

  /// Create custom date range params
  factory GetPartnerAnalyticsParams.customRange({
    required DateTime startDate,
    required DateTime endDate,
    bool includePerformanceDetails = false,
    bool includeQualityMetrics = false,
  }) {
    return GetPartnerAnalyticsParams(
      startDate: startDate,
      endDate: endDate,
      includePerformanceDetails: includePerformanceDetails,
      includeQualityMetrics: includeQualityMetrics,
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
      other is GetPartnerAnalyticsParams &&
          runtimeType == other.runtimeType &&
          startDate == other.startDate &&
          endDate == other.endDate &&
          includePerformanceDetails == other.includePerformanceDetails &&
          includeQualityMetrics == other.includeQualityMetrics;

  @override
  int get hashCode =>
      startDate.hashCode ^
      endDate.hashCode ^
      includePerformanceDetails.hashCode ^
      includeQualityMetrics.hashCode;

  @override
  String toString() {
    return 'GetPartnerAnalyticsParams{startDate: $startDate, endDate: $endDate, includePerformanceDetails: $includePerformanceDetails, includeQualityMetrics: $includeQualityMetrics}';
  }
}
