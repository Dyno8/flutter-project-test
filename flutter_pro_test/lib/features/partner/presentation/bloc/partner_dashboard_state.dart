import 'package:equatable/equatable.dart';
import '../../domain/entities/job.dart';
import '../../domain/entities/partner_earnings.dart';

/// Base class for all partner dashboard states
abstract class PartnerDashboardState extends Equatable {
  const PartnerDashboardState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class PartnerDashboardInitial extends PartnerDashboardState {}

/// Loading state
class PartnerDashboardLoading extends PartnerDashboardState {}

/// Loaded state with all dashboard data
class PartnerDashboardLoaded extends PartnerDashboardState {
  final List<Job> pendingJobs;
  final List<Job> acceptedJobs;
  final List<Job> activeJobs;
  final PartnerEarnings earnings;
  final PartnerAvailability availability;
  final Map<String, dynamic>? statistics;
  final Map<String, dynamic>? performanceMetrics;
  final int unreadNotificationsCount;
  final bool isListeningToUpdates;

  const PartnerDashboardLoaded({
    required this.pendingJobs,
    required this.acceptedJobs,
    required this.activeJobs,
    required this.earnings,
    required this.availability,
    this.statistics,
    this.performanceMetrics,
    this.unreadNotificationsCount = 0,
    this.isListeningToUpdates = false,
  });

  /// Copy with method for state updates
  PartnerDashboardLoaded copyWith({
    List<Job>? pendingJobs,
    List<Job>? acceptedJobs,
    List<Job>? activeJobs,
    PartnerEarnings? earnings,
    PartnerAvailability? availability,
    Map<String, dynamic>? statistics,
    Map<String, dynamic>? performanceMetrics,
    int? unreadNotificationsCount,
    bool? isListeningToUpdates,
  }) {
    return PartnerDashboardLoaded(
      pendingJobs: pendingJobs ?? this.pendingJobs,
      acceptedJobs: acceptedJobs ?? this.acceptedJobs,
      activeJobs: activeJobs ?? this.activeJobs,
      earnings: earnings ?? this.earnings,
      availability: availability ?? this.availability,
      statistics: statistics ?? this.statistics,
      performanceMetrics: performanceMetrics ?? this.performanceMetrics,
      unreadNotificationsCount: unreadNotificationsCount ?? this.unreadNotificationsCount,
      isListeningToUpdates: isListeningToUpdates ?? this.isListeningToUpdates,
    );
  }

  @override
  List<Object?> get props => [
        pendingJobs,
        acceptedJobs,
        activeJobs,
        earnings,
        availability,
        statistics,
        performanceMetrics,
        unreadNotificationsCount,
        isListeningToUpdates,
      ];
}

/// Error state
class PartnerDashboardError extends PartnerDashboardState {
  final String message;
  final String? errorCode;

  const PartnerDashboardError({
    required this.message,
    this.errorCode,
  });

  @override
  List<Object?> get props => [message, errorCode];
}

/// Job operation states

/// Job operation in progress
class JobOperationInProgress extends PartnerDashboardState {
  final String jobId;
  final String operation; // 'accepting', 'rejecting', 'starting', 'completing', 'cancelling'

  const JobOperationInProgress({
    required this.jobId,
    required this.operation,
  });

  @override
  List<Object?> get props => [jobId, operation];
}

/// Job operation success
class JobOperationSuccess extends PartnerDashboardState {
  final String jobId;
  final String operation;
  final Job updatedJob;
  final String message;

  const JobOperationSuccess({
    required this.jobId,
    required this.operation,
    required this.updatedJob,
    required this.message,
  });

  @override
  List<Object?> get props => [jobId, operation, updatedJob, message];
}

/// Job operation error
class JobOperationError extends PartnerDashboardState {
  final String jobId;
  final String operation;
  final String message;

  const JobOperationError({
    required this.jobId,
    required this.operation,
    required this.message,
  });

  @override
  List<Object?> get props => [jobId, operation, message];
}

/// Availability operation states

/// Availability update in progress
class AvailabilityUpdateInProgress extends PartnerDashboardState {
  final String operation; // 'toggling', 'updating_hours', 'setting_unavailable', 'clearing_unavailable'

  const AvailabilityUpdateInProgress({required this.operation});

  @override
  List<Object?> get props => [operation];
}

/// Availability update success
class AvailabilityUpdateSuccess extends PartnerDashboardState {
  final PartnerAvailability updatedAvailability;
  final String message;

  const AvailabilityUpdateSuccess({
    required this.updatedAvailability,
    required this.message,
  });

  @override
  List<Object?> get props => [updatedAvailability, message];
}

/// Availability update error
class AvailabilityUpdateError extends PartnerDashboardState {
  final String message;

  const AvailabilityUpdateError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Earnings states

/// Earnings loading
class EarningsLoading extends PartnerDashboardState {}

/// Earnings loaded
class EarningsLoaded extends PartnerDashboardState {
  final PartnerEarnings earnings;
  final List<DailyEarning>? dailyEarnings;

  const EarningsLoaded({
    required this.earnings,
    this.dailyEarnings,
  });

  @override
  List<Object?> get props => [earnings, dailyEarnings];
}

/// Earnings error
class EarningsError extends PartnerDashboardState {
  final String message;

  const EarningsError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Statistics states

/// Statistics loading
class StatisticsLoading extends PartnerDashboardState {}

/// Statistics loaded
class StatisticsLoaded extends PartnerDashboardState {
  final Map<String, dynamic> statistics;
  final Map<String, dynamic>? performanceMetrics;

  const StatisticsLoaded({
    required this.statistics,
    this.performanceMetrics,
  });

  @override
  List<Object?> get props => [statistics, performanceMetrics];
}

/// Statistics error
class StatisticsError extends PartnerDashboardState {
  final String message;

  const StatisticsError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Real-time update states

/// Real-time jobs updated
class RealTimeJobsUpdated extends PartnerDashboardState {
  final List<Job> pendingJobs;
  final List<Job> acceptedJobs;
  final List<Job> activeJobs;

  const RealTimeJobsUpdated({
    required this.pendingJobs,
    required this.acceptedJobs,
    required this.activeJobs,
  });

  @override
  List<Object?> get props => [pendingJobs, acceptedJobs, activeJobs];
}

/// Real-time job updated
class RealTimeJobUpdated extends PartnerDashboardState {
  final Job updatedJob;

  const RealTimeJobUpdated({required this.updatedJob});

  @override
  List<Object?> get props => [updatedJob];
}

/// Notification states

/// Notification marked as read
class NotificationMarkedAsRead extends PartnerDashboardState {
  final String jobId;
  final int newUnreadCount;

  const NotificationMarkedAsRead({
    required this.jobId,
    required this.newUnreadCount,
  });

  @override
  List<Object?> get props => [jobId, newUnreadCount];
}

/// Unread notifications count updated
class UnreadNotificationsCountUpdated extends PartnerDashboardState {
  final int count;

  const UnreadNotificationsCountUpdated({required this.count});

  @override
  List<Object?> get props => [count];
}

/// Refreshing state (for pull-to-refresh)
class PartnerDashboardRefreshing extends PartnerDashboardState {
  final PartnerDashboardLoaded currentState;

  const PartnerDashboardRefreshing({required this.currentState});

  @override
  List<Object?> get props => [currentState];
}
