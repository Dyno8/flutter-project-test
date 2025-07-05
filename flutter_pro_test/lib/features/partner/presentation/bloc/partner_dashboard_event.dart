import 'package:equatable/equatable.dart';

/// Base class for all partner dashboard events
abstract class PartnerDashboardEvent extends Equatable {
  const PartnerDashboardEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load partner dashboard data
class LoadPartnerDashboard extends PartnerDashboardEvent {
  final String partnerId;

  const LoadPartnerDashboard({required this.partnerId});

  @override
  List<Object?> get props => [partnerId];
}

/// Event to refresh dashboard data
class RefreshPartnerDashboard extends PartnerDashboardEvent {
  final String partnerId;

  const RefreshPartnerDashboard({required this.partnerId});

  @override
  List<Object?> get props => [partnerId];
}

/// Event to start listening to real-time updates
class StartListeningToUpdates extends PartnerDashboardEvent {
  final String partnerId;

  const StartListeningToUpdates({required this.partnerId});

  @override
  List<Object?> get props => [partnerId];
}

/// Event to stop listening to real-time updates
class StopListeningToUpdates extends PartnerDashboardEvent {}

/// Job Management Events

/// Event to accept a job
class AcceptJobEvent extends PartnerDashboardEvent {
  final String jobId;
  final String partnerId;

  const AcceptJobEvent({
    required this.jobId,
    required this.partnerId,
  });

  @override
  List<Object?> get props => [jobId, partnerId];
}

/// Event to reject a job
class RejectJobEvent extends PartnerDashboardEvent {
  final String jobId;
  final String partnerId;
  final String rejectionReason;

  const RejectJobEvent({
    required this.jobId,
    required this.partnerId,
    required this.rejectionReason,
  });

  @override
  List<Object?> get props => [jobId, partnerId, rejectionReason];
}

/// Event to start a job
class StartJobEvent extends PartnerDashboardEvent {
  final String jobId;
  final String partnerId;

  const StartJobEvent({
    required this.jobId,
    required this.partnerId,
  });

  @override
  List<Object?> get props => [jobId, partnerId];
}

/// Event to complete a job
class CompleteJobEvent extends PartnerDashboardEvent {
  final String jobId;
  final String partnerId;

  const CompleteJobEvent({
    required this.jobId,
    required this.partnerId,
  });

  @override
  List<Object?> get props => [jobId, partnerId];
}

/// Event to cancel a job
class CancelJobEvent extends PartnerDashboardEvent {
  final String jobId;
  final String partnerId;
  final String cancellationReason;

  const CancelJobEvent({
    required this.jobId,
    required this.partnerId,
    required this.cancellationReason,
  });

  @override
  List<Object?> get props => [jobId, partnerId, cancellationReason];
}

/// Availability Management Events

/// Event to toggle partner availability
class ToggleAvailabilityEvent extends PartnerDashboardEvent {
  final String partnerId;
  final bool isAvailable;
  final String? reason;

  const ToggleAvailabilityEvent({
    required this.partnerId,
    required this.isAvailable,
    this.reason,
  });

  @override
  List<Object?> get props => [partnerId, isAvailable, reason];
}

/// Event to update online status
class UpdateOnlineStatusEvent extends PartnerDashboardEvent {
  final String partnerId;
  final bool isOnline;

  const UpdateOnlineStatusEvent({
    required this.partnerId,
    required this.isOnline,
  });

  @override
  List<Object?> get props => [partnerId, isOnline];
}

/// Event to update working hours
class UpdateWorkingHoursEvent extends PartnerDashboardEvent {
  final String partnerId;
  final Map<String, List<String>> workingHours;

  const UpdateWorkingHoursEvent({
    required this.partnerId,
    required this.workingHours,
  });

  @override
  List<Object?> get props => [partnerId, workingHours];
}

/// Event to set temporary unavailability
class SetTemporaryUnavailabilityEvent extends PartnerDashboardEvent {
  final String partnerId;
  final DateTime unavailableUntil;
  final String reason;

  const SetTemporaryUnavailabilityEvent({
    required this.partnerId,
    required this.unavailableUntil,
    required this.reason,
  });

  @override
  List<Object?> get props => [partnerId, unavailableUntil, reason];
}

/// Event to clear temporary unavailability
class ClearTemporaryUnavailabilityEvent extends PartnerDashboardEvent {
  final String partnerId;

  const ClearTemporaryUnavailabilityEvent({required this.partnerId});

  @override
  List<Object?> get props => [partnerId];
}

/// Earnings Events

/// Event to load earnings data
class LoadEarningsEvent extends PartnerDashboardEvent {
  final String partnerId;

  const LoadEarningsEvent({required this.partnerId});

  @override
  List<Object?> get props => [partnerId];
}

/// Event to load earnings by date range
class LoadEarningsByDateRangeEvent extends PartnerDashboardEvent {
  final String partnerId;
  final DateTime startDate;
  final DateTime endDate;

  const LoadEarningsByDateRangeEvent({
    required this.partnerId,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [partnerId, startDate, endDate];
}

/// Statistics Events

/// Event to load job statistics
class LoadJobStatisticsEvent extends PartnerDashboardEvent {
  final String partnerId;
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadJobStatisticsEvent({
    required this.partnerId,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [partnerId, startDate, endDate];
}

/// Event to load performance metrics
class LoadPerformanceMetricsEvent extends PartnerDashboardEvent {
  final String partnerId;

  const LoadPerformanceMetricsEvent({required this.partnerId});

  @override
  List<Object?> get props => [partnerId];
}

/// Notification Events

/// Event to mark job notification as read
class MarkJobNotificationAsReadEvent extends PartnerDashboardEvent {
  final String partnerId;
  final String jobId;

  const MarkJobNotificationAsReadEvent({
    required this.partnerId,
    required this.jobId,
  });

  @override
  List<Object?> get props => [partnerId, jobId];
}

/// Event to load unread notifications count
class LoadUnreadNotificationsCountEvent extends PartnerDashboardEvent {
  final String partnerId;

  const LoadUnreadNotificationsCountEvent({required this.partnerId});

  @override
  List<Object?> get props => [partnerId];
}

/// Error handling events

/// Event to clear errors
class ClearErrorEvent extends PartnerDashboardEvent {}

/// Event to retry failed operation
class RetryOperationEvent extends PartnerDashboardEvent {
  final String partnerId;

  const RetryOperationEvent({required this.partnerId});

  @override
  List<Object?> get props => [partnerId];
}
