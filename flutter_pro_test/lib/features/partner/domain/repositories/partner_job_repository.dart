import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/job.dart';
import '../entities/partner_earnings.dart';

/// Domain repository interface for partner job management
abstract class PartnerJobRepository {
  // Job Management
  
  /// Get pending jobs for partner
  Future<Either<Failure, List<Job>>> getPendingJobs(String partnerId);
  
  /// Get accepted jobs for partner
  Future<Either<Failure, List<Job>>> getAcceptedJobs(String partnerId);
  
  /// Get job history for partner
  Future<Either<Failure, List<Job>>> getJobHistory(
    String partnerId, {
    JobStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 20,
  });
  
  /// Get job by ID
  Future<Either<Failure, Job>> getJobById(String jobId);
  
  /// Accept a job
  Future<Either<Failure, Job>> acceptJob(String jobId, String partnerId);
  
  /// Reject a job
  Future<Either<Failure, Job>> rejectJob(
    String jobId,
    String partnerId,
    String rejectionReason,
  );
  
  /// Start a job (mark as in progress)
  Future<Either<Failure, Job>> startJob(String jobId, String partnerId);
  
  /// Complete a job
  Future<Either<Failure, Job>> completeJob(String jobId, String partnerId);
  
  /// Cancel a job
  Future<Either<Failure, Job>> cancelJob(
    String jobId,
    String partnerId,
    String cancellationReason,
  );
  
  // Real-time listeners
  
  /// Listen to pending jobs for partner
  Stream<Either<Failure, List<Job>>> listenToPendingJobs(String partnerId);
  
  /// Listen to accepted jobs for partner
  Stream<Either<Failure, List<Job>>> listenToAcceptedJobs(String partnerId);
  
  /// Listen to specific job updates
  Stream<Either<Failure, Job>> listenToJob(String jobId);
  
  /// Listen to all active jobs for partner
  Stream<Either<Failure, List<Job>>> listenToActiveJobs(String partnerId);
  
  // Earnings Management
  
  /// Get partner earnings
  Future<Either<Failure, PartnerEarnings>> getPartnerEarnings(String partnerId);
  
  /// Update partner earnings
  Future<Either<Failure, PartnerEarnings>> updatePartnerEarnings(
    String partnerId,
    double jobEarnings,
  );
  
  /// Get earnings by date range
  Future<Either<Failure, List<DailyEarning>>> getEarningsByDateRange(
    String partnerId,
    DateTime startDate,
    DateTime endDate,
  );
  
  // Availability Management
  
  /// Get partner availability
  Future<Either<Failure, PartnerAvailability>> getPartnerAvailability(String partnerId);
  
  /// Update partner availability status
  Future<Either<Failure, PartnerAvailability>> updateAvailabilityStatus(
    String partnerId,
    bool isAvailable,
    String? reason,
  );
  
  /// Update partner online status
  Future<Either<Failure, PartnerAvailability>> updateOnlineStatus(
    String partnerId,
    bool isOnline,
  );
  
  /// Update working hours
  Future<Either<Failure, PartnerAvailability>> updateWorkingHours(
    String partnerId,
    Map<String, List<String>> workingHours,
  );
  
  /// Block specific dates
  Future<Either<Failure, PartnerAvailability>> blockDates(
    String partnerId,
    List<String> dates,
  );
  
  /// Unblock specific dates
  Future<Either<Failure, PartnerAvailability>> unblockDates(
    String partnerId,
    List<String> dates,
  );
  
  /// Set temporary unavailability
  Future<Either<Failure, PartnerAvailability>> setTemporaryUnavailability(
    String partnerId,
    DateTime unavailableUntil,
    String reason,
  );
  
  /// Clear temporary unavailability
  Future<Either<Failure, PartnerAvailability>> clearTemporaryUnavailability(
    String partnerId,
  );
  
  // Statistics and Analytics
  
  /// Get job statistics for partner
  Future<Either<Failure, Map<String, dynamic>>> getJobStatistics(
    String partnerId, {
    DateTime? startDate,
    DateTime? endDate,
  });
  
  /// Get performance metrics
  Future<Either<Failure, Map<String, dynamic>>> getPerformanceMetrics(
    String partnerId,
  );
  
  // Notifications
  
  /// Mark job notification as read
  Future<Either<Failure, void>> markJobNotificationAsRead(
    String partnerId,
    String jobId,
  );
  
  /// Get unread job notifications count
  Future<Either<Failure, int>> getUnreadNotificationsCount(String partnerId);
}
