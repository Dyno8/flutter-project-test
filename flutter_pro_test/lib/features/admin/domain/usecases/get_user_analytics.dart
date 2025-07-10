import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_analytics.dart';
import '../repositories/analytics_repository.dart';

/// Use case for getting comprehensive user analytics
class GetUserAnalytics
    implements UseCase<UserAnalytics, GetUserAnalyticsParams> {
  final AnalyticsRepository repository;

  GetUserAnalytics(this.repository);

  @override
  Future<Either<Failure, UserAnalytics>> call(
    GetUserAnalyticsParams params,
  ) async {
    return await repository.getUserAnalytics(
      startDate: params.startDate,
      endDate: params.endDate,
      includeCohortAnalysis: params.includeCohortAnalysis,
      includeSegmentation: params.includeSegmentation,
    );
  }
}

/// Parameters for GetUserAnalytics use case
class GetUserAnalyticsParams {
  final DateTime startDate;
  final DateTime endDate;
  final bool includeCohortAnalysis;
  final bool includeSegmentation;

  const GetUserAnalyticsParams({
    required this.startDate,
    required this.endDate,
    this.includeCohortAnalysis = false,
    this.includeSegmentation = false,
  });

  /// Create params for current month
  factory GetUserAnalyticsParams.currentMonth({
    bool includeCohortAnalysis = false,
    bool includeSegmentation = false,
  }) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    return GetUserAnalyticsParams(
      startDate: startOfMonth,
      endDate: endOfMonth,
      includeCohortAnalysis: includeCohortAnalysis,
      includeSegmentation: includeSegmentation,
    );
  }

  /// Create params for last 30 days
  factory GetUserAnalyticsParams.last30Days({
    bool includeCohortAnalysis = false,
    bool includeSegmentation = false,
  }) {
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 30));

    return GetUserAnalyticsParams(
      startDate: startDate,
      endDate: now,
      includeCohortAnalysis: includeCohortAnalysis,
      includeSegmentation: includeSegmentation,
    );
  }

  /// Create params for last 7 days
  factory GetUserAnalyticsParams.last7Days({
    bool includeCohortAnalysis = false,
    bool includeSegmentation = false,
  }) {
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 7));

    return GetUserAnalyticsParams(
      startDate: startDate,
      endDate: now,
      includeCohortAnalysis: includeCohortAnalysis,
      includeSegmentation: includeSegmentation,
    );
  }

  /// Create params for current quarter
  factory GetUserAnalyticsParams.currentQuarter({
    bool includeCohortAnalysis = false,
    bool includeSegmentation = false,
  }) {
    final now = DateTime.now();
    final quarter = ((now.month - 1) ~/ 3) + 1;
    final startMonth = (quarter - 1) * 3 + 1;
    final startOfQuarter = DateTime(now.year, startMonth, 1);
    final endOfQuarter = DateTime(now.year, startMonth + 3, 0);

    return GetUserAnalyticsParams(
      startDate: startOfQuarter,
      endDate: endOfQuarter,
      includeCohortAnalysis: includeCohortAnalysis,
      includeSegmentation: includeSegmentation,
    );
  }

  /// Create params for current year
  factory GetUserAnalyticsParams.currentYear({
    bool includeCohortAnalysis = false,
    bool includeSegmentation = false,
  }) {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final endOfYear = DateTime(now.year, 12, 31);

    return GetUserAnalyticsParams(
      startDate: startOfYear,
      endDate: endOfYear,
      includeCohortAnalysis: includeCohortAnalysis,
      includeSegmentation: includeSegmentation,
    );
  }

  /// Create custom date range params
  factory GetUserAnalyticsParams.customRange({
    required DateTime startDate,
    required DateTime endDate,
    bool includeCohortAnalysis = false,
    bool includeSegmentation = false,
  }) {
    return GetUserAnalyticsParams(
      startDate: startDate,
      endDate: endDate,
      includeCohortAnalysis: includeCohortAnalysis,
      includeSegmentation: includeSegmentation,
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
      other is GetUserAnalyticsParams &&
          runtimeType == other.runtimeType &&
          startDate == other.startDate &&
          endDate == other.endDate &&
          includeCohortAnalysis == other.includeCohortAnalysis &&
          includeSegmentation == other.includeSegmentation;

  @override
  int get hashCode =>
      startDate.hashCode ^
      endDate.hashCode ^
      includeCohortAnalysis.hashCode ^
      includeSegmentation.hashCode;

  @override
  String toString() {
    return 'GetUserAnalyticsParams{startDate: $startDate, endDate: $endDate, includeCohortAnalysis: $includeCohortAnalysis, includeSegmentation: $includeSegmentation}';
  }
}
