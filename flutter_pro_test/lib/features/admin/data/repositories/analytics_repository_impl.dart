import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/system_metrics.dart';
import '../../domain/entities/booking_analytics.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../datasources/analytics_remote_data_source.dart';

/// Implementation of AnalyticsRepository
class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AnalyticsRemoteDataSource remoteDataSource;

  AnalyticsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, SystemMetrics>> getSystemMetrics() async {
    try {
      final metricsModel = await remoteDataSource.getSystemMetrics();
      return Right(metricsModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get system metrics: $e'));
    }
  }

  @override
  Stream<Either<Failure, SystemMetrics>> watchSystemMetrics() {
    return remoteDataSource
        .watchSystemMetrics()
        .map(
          (metricsModel) =>
              Right<Failure, SystemMetrics>(metricsModel.toEntity()),
        )
        .handleError((error) {
          if (error is ServerException) {
            return Left<Failure, SystemMetrics>(ServerFailure(error.message));
          }
          return Left<Failure, SystemMetrics>(
            ServerFailure('Failed to watch system metrics: $error'),
          );
        });
  }

  @override
  Future<Either<Failure, BookingAnalytics>> getBookingAnalytics({
    required DateTime startDate,
    required DateTime endDate,
    String? serviceId,
    String? partnerId,
  }) async {
    try {
      final analytics = await remoteDataSource.getBookingAnalytics(
        startDate: startDate,
        endDate: endDate,
        serviceId: serviceId,
        partnerId: partnerId,
      );
      return Right(analytics);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get booking analytics: $e'));
    }
  }

  @override
  Future<Either<Failure, PartnerAnalytics>> getPartnerAnalytics({
    required DateTime startDate,
    required DateTime endDate,
    String? serviceId,
  }) async {
    try {
      final analytics = await remoteDataSource.getPartnerAnalytics(
        startDate: startDate,
        endDate: endDate,
        serviceId: serviceId,
      );
      return Right(analytics);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get partner analytics: $e'));
    }
  }

  @override
  Future<Either<Failure, UserAnalytics>> getUserAnalytics({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final analytics = await remoteDataSource.getUserAnalytics(
        startDate: startDate,
        endDate: endDate,
      );
      return Right(analytics);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get user analytics: $e'));
    }
  }

  @override
  Future<Either<Failure, RevenueAnalytics>> getRevenueAnalytics({
    required DateTime startDate,
    required DateTime endDate,
    String? serviceId,
    String? partnerId,
  }) async {
    try {
      final analytics = await remoteDataSource.getRevenueAnalytics(
        startDate: startDate,
        endDate: endDate,
        serviceId: serviceId,
        partnerId: partnerId,
      );
      return Right(analytics);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get revenue analytics: $e'));
    }
  }

  @override
  Future<Either<Failure, SystemHealth>> getSystemHealth() async {
    try {
      final health = await remoteDataSource.getSystemHealth();
      return Right(health);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get system health: $e'));
    }
  }

  @override
  Stream<Either<Failure, SystemHealth>> watchSystemHealth() {
    return remoteDataSource
        .watchSystemHealth()
        .map((health) => Right<Failure, SystemHealth>(health))
        .handleError((error) {
          if (error is ServerException) {
            return Left<Failure, SystemHealth>(ServerFailure(error.message));
          }
          return Left<Failure, SystemHealth>(
            ServerFailure('Failed to watch system health: $error'),
          );
        });
  }

  @override
  Future<Either<Failure, String>> exportAnalyticsData({
    required AnalyticsExportType type,
    required DateTime startDate,
    required DateTime endDate,
    required AnalyticsExportFormat format,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final exportId = await remoteDataSource.exportAnalyticsData(
        type: type,
        startDate: startDate,
        endDate: endDate,
        format: format,
        filters: filters,
      );
      return Right(exportId);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to export analytics data: $e'));
    }
  }

  @override
  Future<Either<Failure, AnalyticsSummary>> getAnalyticsSummary({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Get all required analytics data
      final systemMetricsResult = await getSystemMetrics();
      final bookingAnalyticsResult = await getBookingAnalytics(
        startDate: startDate,
        endDate: endDate,
      );
      final revenueAnalyticsResult = await getRevenueAnalytics(
        startDate: startDate,
        endDate: endDate,
      );

      return systemMetricsResult.fold(
        (failure) => Left(failure),
        (systemMetrics) => bookingAnalyticsResult.fold(
          (failure) => Left(failure),
          (bookingAnalytics) => revenueAnalyticsResult.fold(
            (failure) => Left(failure),
            (revenueAnalytics) {
              final summary = AnalyticsSummary(
                systemMetrics: systemMetrics,
                bookingAnalytics: bookingAnalytics,
                totalRevenue: revenueAnalytics.totalRevenue,
                totalUsers: systemMetrics.totalUsers,
                totalPartners: systemMetrics.totalPartners,
                keyInsights: _generateKeyInsights(
                  systemMetrics,
                  bookingAnalytics,
                  revenueAnalytics,
                ),
              );
              return Right(summary);
            },
          ),
        ),
      );
    } catch (e) {
      return Left(ServerFailure('Failed to get analytics summary: $e'));
    }
  }

  @override
  Future<Either<Failure, ComparativeAnalytics>> getComparativeAnalytics({
    required DateTime currentStart,
    required DateTime currentEnd,
    required DateTime previousStart,
    required DateTime previousEnd,
  }) async {
    try {
      final currentSummaryResult = await getAnalyticsSummary(
        startDate: currentStart,
        endDate: currentEnd,
      );
      final previousSummaryResult = await getAnalyticsSummary(
        startDate: previousStart,
        endDate: previousEnd,
      );

      return currentSummaryResult.fold(
        (failure) => Left(failure),
        (currentSummary) => previousSummaryResult.fold(
          (failure) => Left(failure),
          (previousSummary) {
            final growthMetrics = currentSummary.systemMetrics.getGrowthMetrics(
              previousSummary.systemMetrics,
            );

            final comparative = ComparativeAnalytics(
              currentPeriod: currentSummary,
              previousPeriod: previousSummary,
              growthMetrics: growthMetrics,
            );
            return Right(comparative);
          },
        ),
      );
    } catch (e) {
      return Left(ServerFailure('Failed to get comparative analytics: $e'));
    }
  }

  @override
  Future<Either<Failure, TopPerformingMetrics>> getTopPerformingMetrics({
    required DateTime startDate,
    required DateTime endDate,
    int limit = 10,
  }) async {
    try {
      // This would typically aggregate data from multiple sources
      // For now, return mock data
      const topMetrics = TopPerformingMetrics(
        topServices: ['House Cleaning', 'Plumbing', 'Electrical'],
        topPartners: [],
        topLocations: ['Ho Chi Minh City', 'Hanoi', 'Da Nang'],
        topTimeSlots: ['9:00 AM', '2:00 PM', '10:00 AM'],
      );
      return const Right(topMetrics);
    } catch (e) {
      return Left(ServerFailure('Failed to get top performing metrics: $e'));
    }
  }

  @override
  Future<Either<Failure, List<AnalyticsAlert>>> getAnalyticsAlerts({
    AnalyticsAlertSeverity? severity,
    bool unreadOnly = false,
    int limit = 50,
  }) async {
    try {
      // This would typically query alerts from the database
      // For now, return mock data
      final alerts = <AnalyticsAlert>[
        AnalyticsAlert(
          id: '1',
          title: 'High Cancellation Rate',
          description:
              'Booking cancellation rate has increased by 15% this week',
          severity: AnalyticsAlertSeverity.high,
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          isRead: false,
        ),
        AnalyticsAlert(
          id: '2',
          title: 'Revenue Milestone',
          description: 'Monthly revenue target achieved ahead of schedule',
          severity: AnalyticsAlertSeverity.low,
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          isRead: true,
        ),
      ];

      var filteredAlerts = alerts;

      if (severity != null) {
        filteredAlerts = filteredAlerts
            .where((alert) => alert.severity == severity)
            .toList();
      }

      if (unreadOnly) {
        filteredAlerts = filteredAlerts
            .where((alert) => !alert.isRead)
            .toList();
      }

      if (filteredAlerts.length > limit) {
        filteredAlerts = filteredAlerts.take(limit).toList();
      }

      return Right(filteredAlerts);
    } catch (e) {
      return Left(ServerFailure('Failed to get analytics alerts: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> markAlertAsRead(String alertId) async {
    try {
      // This would typically update the alert in the database
      // For now, just return success
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to mark alert as read: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> executeCustomQuery({
    required String query,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      // This would typically execute a custom analytics query
      // For now, return mock data
      final result = <String, dynamic>{
        'query': query,
        'parameters': parameters,
        'results': [],
        'executedAt': DateTime.now().toIso8601String(),
      };
      return Right(result);
    } catch (e) {
      return Left(ServerFailure('Failed to execute custom query: $e'));
    }
  }

  List<String> _generateKeyInsights(
    SystemMetrics systemMetrics,
    BookingAnalytics bookingAnalytics,
    RevenueAnalytics revenueAnalytics,
  ) {
    final insights = <String>[];

    // Booking completion rate insight
    if (bookingAnalytics.completionRate > 90) {
      insights.add(
        'Excellent booking completion rate of ${bookingAnalytics.completionRate.toStringAsFixed(1)}%',
      );
    } else if (bookingAnalytics.completionRate < 70) {
      insights.add(
        'Booking completion rate needs attention: ${bookingAnalytics.completionRate.toStringAsFixed(1)}%',
      );
    }

    // Revenue insight
    if (revenueAnalytics.totalRevenue > 100000) {
      insights.add(
        'Strong revenue performance: \$${revenueAnalytics.totalRevenue.toStringAsFixed(0)}',
      );
    }

    // System performance insight
    if (systemMetrics.performance.healthStatus == SystemHealthStatus.healthy) {
      insights.add('All systems operating normally');
    } else {
      insights.add('System performance requires attention');
    }

    // Partner utilization insight
    if (systemMetrics.partnerUtilizationRate > 80) {
      insights.add(
        'High partner utilization rate: ${systemMetrics.partnerUtilizationRate.toStringAsFixed(1)}%',
      );
    }

    return insights;
  }
}
