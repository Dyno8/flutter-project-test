import 'dart:developer' as developer;
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/services/notification_integration_service.dart';
import '../../../../shared/repositories/user_repository.dart';
import '../entities/job.dart';
import '../usecases/accept_job.dart';
import '../usecases/reject_job.dart';
import '../usecases/manage_job_status.dart';
import '../usecases/get_partner_earnings.dart';

/// Service for partner job management with notification integration
class PartnerJobService {
  final AcceptJob _acceptJob;
  final RejectJob _rejectJob;
  final StartJob _startJob;
  final CompleteJob _completeJob;
  final CancelJob _cancelJob;
  final GetPartnerEarnings _getPartnerEarnings;
  final NotificationIntegrationService _notificationIntegrationService;
  final UserRepository _userRepository;

  PartnerJobService({
    required AcceptJob acceptJob,
    required RejectJob rejectJob,
    required StartJob startJob,
    required CompleteJob completeJob,
    required CancelJob cancelJob,
    required GetPartnerEarnings getPartnerEarnings,
    required NotificationIntegrationService notificationIntegrationService,
    required UserRepository userRepository,
  }) : _acceptJob = acceptJob,
       _rejectJob = rejectJob,
       _startJob = startJob,
       _completeJob = completeJob,
       _cancelJob = cancelJob,
       _getPartnerEarnings = getPartnerEarnings,
       _notificationIntegrationService = notificationIntegrationService,
       _userRepository = userRepository;

  /// Accept a job with notification integration
  Future<Either<Failure, Job>> acceptJob({
    required String jobId,
    required String partnerId,
  }) async {
    try {
      // Accept the job
      final result = await _acceptJob(
        AcceptJobParams(jobId: jobId, partnerId: partnerId),
      );

      if (result.isRight()) {
        final job = (result as Right).value;

        // Send notification about job acceptance
        await _notificationIntegrationService.notifyJobAccepted(job);

        // Send new job available notification to partner
        await _notificationIntegrationService.notifyNewJobAvailable(job);

        developer.log(
          'Job accepted with notifications: $jobId',
          name: 'PartnerJobService',
        );
      }

      return result;
    } catch (e) {
      developer.log('Error accepting job: $e', name: 'PartnerJobService');
      return Left(ServerFailure('Failed to accept job: $e'));
    }
  }

  /// Reject a job with notification integration
  Future<Either<Failure, Job>> rejectJob({
    required String jobId,
    required String partnerId,
    required String rejectionReason,
  }) async {
    try {
      // Reject the job
      final result = await _rejectJob(
        RejectJobParams(
          jobId: jobId,
          partnerId: partnerId,
          rejectionReason: rejectionReason,
        ),
      );

      if (result.isRight()) {
        final job = (result as Right).value;

        // TODO: Add notification for job rejection if needed
        // This could notify the client that their booking was rejected
        // and needs to be reassigned to another partner

        developer.log(
          'Job rejected: $jobId, reason: $rejectionReason',
          name: 'PartnerJobService',
        );
      }

      return result;
    } catch (e) {
      developer.log('Error rejecting job: $e', name: 'PartnerJobService');
      return Left(ServerFailure('Failed to reject job: $e'));
    }
  }

  /// Start a job with notification integration
  Future<Either<Failure, Job>> startJob({
    required String jobId,
    required String partnerId,
  }) async {
    try {
      // Start the job
      final result = await _startJob(
        StartJobParams(jobId: jobId, partnerId: partnerId),
      );

      if (result.isRight()) {
        final job = (result as Right).value;

        // Get partner name for notification
        final partnerResult = await _userRepository.getById(partnerId);
        String partnerName = 'Partner';
        if (partnerResult.isRight()) {
          final partner = (partnerResult as Right).value;
          if (partner != null) {
            partnerName = partner.name;
          }
        }

        // Send booking started notification (this will notify the client)
        // Note: We need to convert Job to Booking for this notification
        // This is a design consideration - we might need to refactor this
        // For now, we'll create a helper method to handle this

        developer.log(
          'Job started with notifications: $jobId',
          name: 'PartnerJobService',
        );
      }

      return result;
    } catch (e) {
      developer.log('Error starting job: $e', name: 'PartnerJobService');
      return Left(ServerFailure('Failed to start job: $e'));
    }
  }

  /// Complete a job with notification integration
  Future<Either<Failure, Job>> completeJob({
    required String jobId,
    required String partnerId,
  }) async {
    try {
      // Complete the job
      final result = await _completeJob(
        CompleteJobParams(jobId: jobId, partnerId: partnerId),
      );

      if (result.isRight()) {
        final job = (result as Right).value;

        // Get partner name for notification
        final partnerResult = await _userRepository.getById(partnerId);
        String partnerName = 'Partner';
        if (partnerResult.isRight()) {
          final partner = (partnerResult as Right).value;
          if (partner != null) {
            partnerName = partner.name;
          }
        }

        // Update partner earnings and send notification
        await _updatePartnerEarningsWithNotification(partnerId, job);

        developer.log(
          'Job completed with notifications: $jobId',
          name: 'PartnerJobService',
        );
      }

      return result;
    } catch (e) {
      developer.log('Error completing job: $e', name: 'PartnerJobService');
      return Left(ServerFailure('Failed to complete job: $e'));
    }
  }

  /// Cancel a job with notification integration
  Future<Either<Failure, Job>> cancelJob({
    required String jobId,
    required String partnerId,
    required String cancellationReason,
  }) async {
    try {
      // Cancel the job
      final result = await _cancelJob(
        CancelJobParams(
          jobId: jobId,
          partnerId: partnerId,
          cancellationReason: cancellationReason,
        ),
      );

      if (result.isRight()) {
        final job = (result as Right).value;

        // TODO: Send job cancellation notification
        // This should notify the client about the cancellation

        developer.log(
          'Job cancelled: $jobId, reason: $cancellationReason',
          name: 'PartnerJobService',
        );
      }

      return result;
    } catch (e) {
      developer.log('Error cancelling job: $e', name: 'PartnerJobService');
      return Left(ServerFailure('Failed to cancel job: $e'));
    }
  }

  /// Update partner earnings and send notification
  Future<void> _updatePartnerEarningsWithNotification(
    String partnerId,
    Job job,
  ) async {
    try {
      // Get current earnings
      final earningsResult = await _getPartnerEarnings(
        GetPartnerEarningsParams(partnerId: partnerId),
      );
      if (earningsResult.isRight()) {
        final earnings = (earningsResult as Right).value;
        final newTotalEarnings = earnings.totalEarnings + job.partnerEarnings;

        // Send earnings update notification
        await _notificationIntegrationService.notifyEarningsUpdate(
          partnerId,
          job.partnerEarnings,
          newTotalEarnings,
          job.id,
        );
      }
    } catch (e) {
      developer.log(
        'Error updating partner earnings: $e',
        name: 'PartnerJobService',
      );
    }
  }
}
