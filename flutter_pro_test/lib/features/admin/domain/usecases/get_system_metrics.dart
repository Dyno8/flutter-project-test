import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/system_metrics.dart';
import '../entities/admin_user.dart';
import '../repositories/analytics_repository.dart';
import '../repositories/admin_repository.dart';

/// Use case for getting system metrics
class GetSystemMetrics implements NoParamsUseCase<SystemMetrics> {
  final AnalyticsRepository analyticsRepository;
  final AdminRepository adminRepository;

  const GetSystemMetrics({
    required this.analyticsRepository,
    required this.adminRepository,
  });

  @override
  Future<Either<Failure, SystemMetrics>> call() async {
    // Check if current admin has permission to view analytics
    final currentAdmin = adminRepository.currentAdmin;
    if (currentAdmin.isEmpty) {
      return const Left(AuthFailure('Admin not authenticated'));
    }

    if (!currentAdmin.canPerformAction(AdminPermission.viewAnalytics)) {
      return const Left(
        AuthFailure('Insufficient permissions to view system metrics'),
      );
    }

    // Get system metrics
    final result = await analyticsRepository.getSystemMetrics();

    return result.fold((failure) => Left(failure), (metrics) async {
      // Log admin activity
      await adminRepository.logAdminActivity(
        adminId: currentAdmin.uid,
        activityType: AdminActivityType.viewDashboard,
        description: 'Viewed system metrics',
        metadata: {
          'timestamp': DateTime.now().toIso8601String(),
          'metricsTimestamp': metrics.timestamp.toIso8601String(),
        },
      );

      return Right(metrics);
    });
  }
}
