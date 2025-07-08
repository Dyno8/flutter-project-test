import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/booking_analytics.dart';
import '../entities/admin_user.dart';
import '../repositories/analytics_repository.dart';
import '../repositories/admin_repository.dart';

/// Use case for getting booking analytics
class GetBookingAnalytics implements UseCase<BookingAnalytics, GetBookingAnalyticsParams> {
  final AnalyticsRepository analyticsRepository;
  final AdminRepository adminRepository;

  const GetBookingAnalytics({
    required this.analyticsRepository,
    required this.adminRepository,
  });

  @override
  Future<Either<Failure, BookingAnalytics>> call(GetBookingAnalyticsParams params) async {
    // Check if current admin has permission to view analytics
    final currentAdmin = adminRepository.currentAdmin;
    if (currentAdmin.isEmpty) {
      return const Left(AuthFailure('Admin not authenticated'));
    }

    if (!currentAdmin.canPerformAction(AdminPermission.viewAnalytics)) {
      return const Left(AuthFailure('Insufficient permissions to view booking analytics'));
    }

    // Validate date range
    if (params.startDate.isAfter(params.endDate)) {
      return const Left(ValidationFailure('Start date must be before end date'));
    }

    // Check if date range is not too large (max 1 year)
    final daysDifference = params.endDate.difference(params.startDate).inDays;
    if (daysDifference > 365) {
      return const Left(ValidationFailure('Date range cannot exceed 365 days'));
    }

    // Get booking analytics
    final result = await analyticsRepository.getBookingAnalytics(
      startDate: params.startDate,
      endDate: params.endDate,
      serviceId: params.serviceId,
      partnerId: params.partnerId,
    );

    return result.fold(
      (failure) => Left(failure),
      (analytics) async {
        // Log admin activity
        await adminRepository.logAdminActivity(
          adminId: currentAdmin.uid,
          activityType: AdminActivityType.viewAnalytics,
          description: 'Viewed booking analytics',
          metadata: {
            'startDate': params.startDate.toIso8601String(),
            'endDate': params.endDate.toIso8601String(),
            'serviceId': params.serviceId,
            'partnerId': params.partnerId,
            'totalBookings': analytics.totalBookings,
            'completionRate': analytics.completionRate,
          },
        );

        return Right(analytics);
      },
    );
  }
}

/// Parameters for getting booking analytics
class GetBookingAnalyticsParams extends Equatable {
  final DateTime startDate;
  final DateTime endDate;
  final String? serviceId;
  final String? partnerId;

  const GetBookingAnalyticsParams({
    required this.startDate,
    required this.endDate,
    this.serviceId,
    this.partnerId,
  });

  @override
  List<Object?> get props => [startDate, endDate, serviceId, partnerId];
}
