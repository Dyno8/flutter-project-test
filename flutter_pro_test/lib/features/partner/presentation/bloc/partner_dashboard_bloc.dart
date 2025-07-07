import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/job.dart';
import '../../domain/entities/partner_earnings.dart';

import '../../domain/usecases/get_pending_jobs.dart';
import '../../domain/usecases/accept_job.dart';
import '../../domain/usecases/reject_job.dart';
import '../../domain/usecases/manage_job_status.dart';
import '../../domain/services/partner_job_service.dart';
import '../../domain/usecases/get_partner_earnings.dart';
import '../../domain/usecases/manage_availability.dart';
import '../../domain/repositories/partner_job_repository.dart';
import 'partner_dashboard_event.dart';
import 'partner_dashboard_state.dart';

/// BLoC for managing partner dashboard state
class PartnerDashboardBloc
    extends Bloc<PartnerDashboardEvent, PartnerDashboardState> {
  final GetPendingJobs _getPendingJobs;
  final AcceptJob _acceptJob;
  final RejectJob _rejectJob;
  final StartJob _startJob;
  final CompleteJob _completeJob;
  final CancelJob _cancelJob;
  final GetPartnerEarnings _getPartnerEarnings;
  final GetPartnerAvailability _getPartnerAvailability;
  final UpdateAvailabilityStatus _updateAvailabilityStatus;
  final UpdateOnlineStatus _updateOnlineStatus;
  final UpdateWorkingHours _updateWorkingHours;
  final PartnerJobRepository _repository;
  final PartnerJobService? _partnerJobService;

  // Stream subscriptions for real-time updates
  StreamSubscription? _pendingJobsSubscription;
  StreamSubscription? _acceptedJobsSubscription;
  StreamSubscription? _activeJobsSubscription;

  PartnerDashboardBloc({
    required GetPendingJobs getPendingJobs,
    required AcceptJob acceptJob,
    required RejectJob rejectJob,
    required StartJob startJob,
    required CompleteJob completeJob,
    required CancelJob cancelJob,
    required GetPartnerEarnings getPartnerEarnings,
    required GetPartnerAvailability getPartnerAvailability,
    required UpdateAvailabilityStatus updateAvailabilityStatus,
    required UpdateOnlineStatus updateOnlineStatus,
    required UpdateWorkingHours updateWorkingHours,
    required PartnerJobRepository repository,
    PartnerJobService? partnerJobService,
  }) : _getPendingJobs = getPendingJobs,
       _acceptJob = acceptJob,
       _rejectJob = rejectJob,
       _startJob = startJob,
       _completeJob = completeJob,
       _cancelJob = cancelJob,
       _getPartnerEarnings = getPartnerEarnings,
       _getPartnerAvailability = getPartnerAvailability,
       _updateAvailabilityStatus = updateAvailabilityStatus,
       _updateOnlineStatus = updateOnlineStatus,
       _updateWorkingHours = updateWorkingHours,
       _repository = repository,
       _partnerJobService = partnerJobService,
       super(PartnerDashboardInitial()) {
    // Register event handlers
    on<LoadPartnerDashboard>(_onLoadPartnerDashboard);
    on<RefreshPartnerDashboard>(_onRefreshPartnerDashboard);
    on<StartListeningToUpdates>(_onStartListeningToUpdates);
    on<StopListeningToUpdates>(_onStopListeningToUpdates);

    // Job management events
    on<AcceptJobEvent>(_onAcceptJob);
    on<RejectJobEvent>(_onRejectJob);
    on<StartJobEvent>(_onStartJob);
    on<CompleteJobEvent>(_onCompleteJob);
    on<CancelJobEvent>(_onCancelJob);

    // Availability management events
    on<ToggleAvailabilityEvent>(_onToggleAvailability);
    on<UpdateOnlineStatusEvent>(_onUpdateOnlineStatus);
    on<UpdateWorkingHoursEvent>(_onUpdateWorkingHours);
    on<SetTemporaryUnavailabilityEvent>(_onSetTemporaryUnavailability);
    on<ClearTemporaryUnavailabilityEvent>(_onClearTemporaryUnavailability);

    // Earnings events
    on<LoadEarningsEvent>(_onLoadEarnings);
    on<LoadEarningsByDateRangeEvent>(_onLoadEarningsByDateRange);

    // Statistics events
    on<LoadJobStatisticsEvent>(_onLoadJobStatistics);
    on<LoadPerformanceMetricsEvent>(_onLoadPerformanceMetrics);

    // Notification events
    on<MarkJobNotificationAsReadEvent>(_onMarkJobNotificationAsRead);
    on<LoadUnreadNotificationsCountEvent>(_onLoadUnreadNotificationsCount);

    // Error handling events
    on<ClearErrorEvent>(_onClearError);
    on<RetryOperationEvent>(_onRetryOperation);
  }

  @override
  Future<void> close() {
    _pendingJobsSubscription?.cancel();
    _acceptedJobsSubscription?.cancel();
    _activeJobsSubscription?.cancel();
    return super.close();
  }

  /// Load initial dashboard data
  Future<void> _onLoadPartnerDashboard(
    LoadPartnerDashboard event,
    Emitter<PartnerDashboardState> emit,
  ) async {
    emit(PartnerDashboardLoading());

    try {
      // Load all dashboard data in parallel
      final results = await Future.wait([
        _getPendingJobs(GetPendingJobsParams(partnerId: event.partnerId)),
        _repository.getAcceptedJobs(event.partnerId),
        _repository.getJobHistory(event.partnerId, limit: 10),
        _getPartnerEarnings(
          GetPartnerEarningsParams(partnerId: event.partnerId),
        ),
        _getPartnerAvailability(
          GetPartnerAvailabilityParams(partnerId: event.partnerId),
        ),
        _repository.getUnreadNotificationsCount(event.partnerId),
      ]);

      final pendingJobsResult = results[0];
      final acceptedJobsResult = results[1];
      final jobHistoryResult = results[2];
      final earningsResult = results[3];
      final availabilityResult = results[4];
      final notificationsResult = results[5];

      // Check for failures
      if (pendingJobsResult.isLeft() ||
          acceptedJobsResult.isLeft() ||
          jobHistoryResult.isLeft() ||
          earningsResult.isLeft() ||
          availabilityResult.isLeft() ||
          notificationsResult.isLeft()) {
        emit(
          const PartnerDashboardError(message: 'Failed to load dashboard data'),
        );
        return;
      }

      // Extract successful results
      final List<Job> pendingJobs = pendingJobsResult.fold(
        (failure) => <Job>[],
        (jobs) => jobs as List<Job>,
      );
      final List<Job> acceptedJobs = acceptedJobsResult.fold(
        (failure) => <Job>[],
        (jobs) => jobs as List<Job>,
      );
      final List<Job> jobHistory = jobHistoryResult.fold(
        (failure) => <Job>[],
        (jobs) => jobs as List<Job>,
      );
      final earnings = earningsResult.fold(
        (failure) => throw Exception('Earnings not found'),
        (earnings) => earnings as PartnerEarnings,
      );
      final availability = availabilityResult.fold(
        (failure) => throw Exception('Availability not found'),
        (availability) => availability as PartnerAvailability,
      );
      final int unreadCount = notificationsResult.fold(
        (failure) => 0,
        (count) => count as int,
      );

      // Combine accepted jobs and recent history for active jobs
      final activeJobs = <Job>[
        ...acceptedJobs,
        ...jobHistory.where(
          (job) =>
              job.status.name == 'inProgress' || job.status.name == 'accepted',
        ),
      ];

      emit(
        PartnerDashboardLoaded(
          pendingJobs: pendingJobs,
          acceptedJobs: acceptedJobs,
          activeJobs: activeJobs,
          earnings: earnings,
          availability: availability,
          unreadNotificationsCount: unreadCount,
        ),
      );
    } catch (e) {
      emit(PartnerDashboardError(message: 'Failed to load dashboard: $e'));
    }
  }

  /// Refresh dashboard data
  Future<void> _onRefreshPartnerDashboard(
    RefreshPartnerDashboard event,
    Emitter<PartnerDashboardState> emit,
  ) async {
    if (state is PartnerDashboardLoaded) {
      emit(
        PartnerDashboardRefreshing(
          currentState: state as PartnerDashboardLoaded,
        ),
      );
    }

    // Reload dashboard data
    add(LoadPartnerDashboard(partnerId: event.partnerId));
  }

  /// Start listening to real-time updates
  Future<void> _onStartListeningToUpdates(
    StartListeningToUpdates event,
    Emitter<PartnerDashboardState> emit,
  ) async {
    // Cancel existing subscriptions
    await _pendingJobsSubscription?.cancel();
    await _acceptedJobsSubscription?.cancel();
    await _activeJobsSubscription?.cancel();

    // Start listening to pending jobs
    _pendingJobsSubscription = _repository
        .listenToPendingJobs(event.partnerId)
        .listen((result) {
          result.fold(
            (failure) => add(const RetryOperationEvent(partnerId: '')),
            (jobs) {
              if (state is PartnerDashboardLoaded) {
                final currentState = state as PartnerDashboardLoaded;
                emit(
                  currentState.copyWith(
                    pendingJobs: jobs,
                    isListeningToUpdates: true,
                  ),
                );
              }
            },
          );
        });

    // Start listening to accepted jobs
    _acceptedJobsSubscription = _repository
        .listenToAcceptedJobs(event.partnerId)
        .listen((result) {
          result.fold(
            (failure) => add(const RetryOperationEvent(partnerId: '')),
            (jobs) {
              if (state is PartnerDashboardLoaded) {
                final currentState = state as PartnerDashboardLoaded;
                emit(
                  currentState.copyWith(
                    acceptedJobs: jobs,
                    isListeningToUpdates: true,
                  ),
                );
              }
            },
          );
        });

    // Start listening to active jobs
    _activeJobsSubscription = _repository
        .listenToActiveJobs(event.partnerId)
        .listen((result) {
          result.fold(
            (failure) => add(const RetryOperationEvent(partnerId: '')),
            (jobs) {
              if (state is PartnerDashboardLoaded) {
                final currentState = state as PartnerDashboardLoaded;
                emit(
                  currentState.copyWith(
                    activeJobs: jobs,
                    isListeningToUpdates: true,
                  ),
                );
              }
            },
          );
        });

    // Update state to indicate listening is active
    if (state is PartnerDashboardLoaded) {
      final currentState = state as PartnerDashboardLoaded;
      emit(currentState.copyWith(isListeningToUpdates: true));
    }
  }

  /// Stop listening to real-time updates
  Future<void> _onStopListeningToUpdates(
    StopListeningToUpdates event,
    Emitter<PartnerDashboardState> emit,
  ) async {
    await _pendingJobsSubscription?.cancel();
    await _acceptedJobsSubscription?.cancel();
    await _activeJobsSubscription?.cancel();

    if (state is PartnerDashboardLoaded) {
      final currentState = state as PartnerDashboardLoaded;
      emit(currentState.copyWith(isListeningToUpdates: false));
    }
  }

  /// Accept a job
  Future<void> _onAcceptJob(
    AcceptJobEvent event,
    Emitter<PartnerDashboardState> emit,
  ) async {
    emit(JobOperationInProgress(jobId: event.jobId, operation: 'accepting'));

    // Use PartnerJobService if available, otherwise fallback to direct use case
    final result = _partnerJobService != null
        ? await _partnerJobService!.acceptJob(
            jobId: event.jobId,
            partnerId: event.partnerId,
          )
        : await _acceptJob(
            AcceptJobParams(jobId: event.jobId, partnerId: event.partnerId),
          );

    result.fold(
      (failure) => emit(
        JobOperationError(
          jobId: event.jobId,
          operation: 'accepting',
          message: failure.message,
        ),
      ),
      (job) {
        emit(
          JobOperationSuccess(
            jobId: event.jobId,
            operation: 'accepting',
            updatedJob: job,
            message: 'Job accepted successfully',
          ),
        );

        // Refresh dashboard to update job lists
        add(RefreshPartnerDashboard(partnerId: event.partnerId));
      },
    );
  }

  /// Reject a job
  Future<void> _onRejectJob(
    RejectJobEvent event,
    Emitter<PartnerDashboardState> emit,
  ) async {
    emit(JobOperationInProgress(jobId: event.jobId, operation: 'rejecting'));

    final result = await _rejectJob(
      RejectJobParams(
        jobId: event.jobId,
        partnerId: event.partnerId,
        rejectionReason: event.rejectionReason,
      ),
    );

    result.fold(
      (failure) => emit(
        JobOperationError(
          jobId: event.jobId,
          operation: 'rejecting',
          message: failure.message,
        ),
      ),
      (job) {
        emit(
          JobOperationSuccess(
            jobId: event.jobId,
            operation: 'rejecting',
            updatedJob: job,
            message: 'Job rejected successfully',
          ),
        );

        // Refresh dashboard to update job lists
        add(RefreshPartnerDashboard(partnerId: event.partnerId));
      },
    );
  }

  /// Start a job
  Future<void> _onStartJob(
    StartJobEvent event,
    Emitter<PartnerDashboardState> emit,
  ) async {
    emit(JobOperationInProgress(jobId: event.jobId, operation: 'starting'));

    // Use PartnerJobService if available, otherwise fallback to direct use case
    final result = _partnerJobService != null
        ? await _partnerJobService!.startJob(
            jobId: event.jobId,
            partnerId: event.partnerId,
          )
        : await _startJob(
            StartJobParams(jobId: event.jobId, partnerId: event.partnerId),
          );

    result.fold(
      (failure) => emit(
        JobOperationError(
          jobId: event.jobId,
          operation: 'starting',
          message: failure.message,
        ),
      ),
      (job) {
        emit(
          JobOperationSuccess(
            jobId: event.jobId,
            operation: 'starting',
            updatedJob: job,
            message: 'Job started successfully',
          ),
        );

        // Refresh dashboard to update job lists
        add(RefreshPartnerDashboard(partnerId: event.partnerId));
      },
    );
  }

  /// Complete a job
  Future<void> _onCompleteJob(
    CompleteJobEvent event,
    Emitter<PartnerDashboardState> emit,
  ) async {
    emit(JobOperationInProgress(jobId: event.jobId, operation: 'completing'));

    // Use PartnerJobService if available, otherwise fallback to direct use case
    final result = _partnerJobService != null
        ? await _partnerJobService!.completeJob(
            jobId: event.jobId,
            partnerId: event.partnerId,
          )
        : await _completeJob(
            CompleteJobParams(jobId: event.jobId, partnerId: event.partnerId),
          );

    result.fold(
      (failure) => emit(
        JobOperationError(
          jobId: event.jobId,
          operation: 'completing',
          message: failure.message,
        ),
      ),
      (job) {
        emit(
          JobOperationSuccess(
            jobId: event.jobId,
            operation: 'completing',
            updatedJob: job,
            message: 'Job completed successfully',
          ),
        );

        // Refresh dashboard to update job lists and earnings
        add(RefreshPartnerDashboard(partnerId: event.partnerId));
      },
    );
  }

  /// Cancel a job
  Future<void> _onCancelJob(
    CancelJobEvent event,
    Emitter<PartnerDashboardState> emit,
  ) async {
    emit(JobOperationInProgress(jobId: event.jobId, operation: 'cancelling'));

    final result = await _cancelJob(
      CancelJobParams(
        jobId: event.jobId,
        partnerId: event.partnerId,
        cancellationReason: event.cancellationReason,
      ),
    );

    result.fold(
      (failure) => emit(
        JobOperationError(
          jobId: event.jobId,
          operation: 'cancelling',
          message: failure.message,
        ),
      ),
      (job) {
        emit(
          JobOperationSuccess(
            jobId: event.jobId,
            operation: 'cancelling',
            updatedJob: job,
            message: 'Job cancelled successfully',
          ),
        );

        // Refresh dashboard to update job lists
        add(RefreshPartnerDashboard(partnerId: event.partnerId));
      },
    );
  }

  /// Toggle availability
  Future<void> _onToggleAvailability(
    ToggleAvailabilityEvent event,
    Emitter<PartnerDashboardState> emit,
  ) async {
    emit(const AvailabilityUpdateInProgress(operation: 'toggling'));

    final result = await _updateAvailabilityStatus(
      UpdateAvailabilityStatusParams(
        partnerId: event.partnerId,
        isAvailable: event.isAvailable,
        reason: event.reason,
      ),
    );

    result.fold(
      (failure) => emit(AvailabilityUpdateError(message: failure.message)),
      (availability) {
        emit(
          AvailabilityUpdateSuccess(
            updatedAvailability: availability,
            message: event.isAvailable
                ? 'You are now available'
                : 'You are now unavailable',
          ),
        );

        // Update the current state if loaded
        if (state is PartnerDashboardLoaded) {
          final currentState = state as PartnerDashboardLoaded;
          emit(currentState.copyWith(availability: availability));
        }
      },
    );
  }

  /// Update online status
  Future<void> _onUpdateOnlineStatus(
    UpdateOnlineStatusEvent event,
    Emitter<PartnerDashboardState> emit,
  ) async {
    final result = await _updateOnlineStatus(
      UpdateOnlineStatusParams(
        partnerId: event.partnerId,
        isOnline: event.isOnline,
      ),
    );

    result.fold(
      (failure) => emit(AvailabilityUpdateError(message: failure.message)),
      (availability) {
        // Update the current state if loaded
        if (state is PartnerDashboardLoaded) {
          final currentState = state as PartnerDashboardLoaded;
          emit(currentState.copyWith(availability: availability));
        }
      },
    );
  }

  /// Update working hours
  Future<void> _onUpdateWorkingHours(
    UpdateWorkingHoursEvent event,
    Emitter<PartnerDashboardState> emit,
  ) async {
    emit(const AvailabilityUpdateInProgress(operation: 'updating_hours'));

    final result = await _updateWorkingHours(
      UpdateWorkingHoursParams(
        partnerId: event.partnerId,
        workingHours: event.workingHours,
      ),
    );

    result.fold(
      (failure) => emit(AvailabilityUpdateError(message: failure.message)),
      (availability) {
        emit(
          AvailabilityUpdateSuccess(
            updatedAvailability: availability,
            message: 'Working hours updated successfully',
          ),
        );

        // Update the current state if loaded
        if (state is PartnerDashboardLoaded) {
          final currentState = state as PartnerDashboardLoaded;
          emit(currentState.copyWith(availability: availability));
        }
      },
    );
  }

  /// Set temporary unavailability
  Future<void> _onSetTemporaryUnavailability(
    SetTemporaryUnavailabilityEvent event,
    Emitter<PartnerDashboardState> emit,
  ) async {
    emit(const AvailabilityUpdateInProgress(operation: 'setting_unavailable'));

    final result = await _repository.setTemporaryUnavailability(
      event.partnerId,
      event.unavailableUntil,
      event.reason,
    );

    result.fold(
      (failure) => emit(AvailabilityUpdateError(message: failure.message)),
      (availability) {
        emit(
          AvailabilityUpdateSuccess(
            updatedAvailability: availability,
            message: 'Temporary unavailability set',
          ),
        );

        // Update the current state if loaded
        if (state is PartnerDashboardLoaded) {
          final currentState = state as PartnerDashboardLoaded;
          emit(currentState.copyWith(availability: availability));
        }
      },
    );
  }

  /// Clear temporary unavailability
  Future<void> _onClearTemporaryUnavailability(
    ClearTemporaryUnavailabilityEvent event,
    Emitter<PartnerDashboardState> emit,
  ) async {
    emit(const AvailabilityUpdateInProgress(operation: 'clearing_unavailable'));

    final result = await _repository.clearTemporaryUnavailability(
      event.partnerId,
    );

    result.fold(
      (failure) => emit(AvailabilityUpdateError(message: failure.message)),
      (availability) {
        emit(
          AvailabilityUpdateSuccess(
            updatedAvailability: availability,
            message: 'Temporary unavailability cleared',
          ),
        );

        // Update the current state if loaded
        if (state is PartnerDashboardLoaded) {
          final currentState = state as PartnerDashboardLoaded;
          emit(currentState.copyWith(availability: availability));
        }
      },
    );
  }

  /// Load earnings
  Future<void> _onLoadEarnings(
    LoadEarningsEvent event,
    Emitter<PartnerDashboardState> emit,
  ) async {
    emit(EarningsLoading());

    final result = await _getPartnerEarnings(
      GetPartnerEarningsParams(partnerId: event.partnerId),
    );

    result.fold(
      (failure) => emit(EarningsError(message: failure.message)),
      (earnings) => emit(EarningsLoaded(earnings: earnings)),
    );
  }

  /// Load earnings by date range
  Future<void> _onLoadEarningsByDateRange(
    LoadEarningsByDateRangeEvent event,
    Emitter<PartnerDashboardState> emit,
  ) async {
    emit(EarningsLoading());

    final results = await Future.wait([
      _getPartnerEarnings(GetPartnerEarningsParams(partnerId: event.partnerId)),
      _repository.getEarningsByDateRange(
        event.partnerId,
        event.startDate,
        event.endDate,
      ),
    ]);

    final earningsResult = results[0];
    final dailyEarningsResult = results[1];

    if (earningsResult.isLeft() || dailyEarningsResult.isLeft()) {
      emit(const EarningsError(message: 'Failed to load earnings data'));
      return;
    }

    final earnings = earningsResult.fold(
      (failure) => throw Exception('Earnings not found'),
      (earnings) => earnings as PartnerEarnings,
    );
    final dailyEarnings = dailyEarningsResult.fold(
      (failure) => <DailyEarning>[],
      (earnings) => earnings as List<DailyEarning>,
    );

    emit(EarningsLoaded(earnings: earnings, dailyEarnings: dailyEarnings));
  }

  /// Load job statistics
  Future<void> _onLoadJobStatistics(
    LoadJobStatisticsEvent event,
    Emitter<PartnerDashboardState> emit,
  ) async {
    emit(StatisticsLoading());

    final result = await _repository.getJobStatistics(
      event.partnerId,
      startDate: event.startDate,
      endDate: event.endDate,
    );

    result.fold(
      (failure) => emit(StatisticsError(message: failure.message)),
      (statistics) => emit(StatisticsLoaded(statistics: statistics)),
    );
  }

  /// Load performance metrics
  Future<void> _onLoadPerformanceMetrics(
    LoadPerformanceMetricsEvent event,
    Emitter<PartnerDashboardState> emit,
  ) async {
    emit(StatisticsLoading());

    final results = await Future.wait([
      _repository.getJobStatistics(event.partnerId),
      _repository.getPerformanceMetrics(event.partnerId),
    ]);

    final statisticsResult = results[0];
    final metricsResult = results[1];

    if (statisticsResult.isLeft() || metricsResult.isLeft()) {
      emit(const StatisticsError(message: 'Failed to load performance data'));
      return;
    }

    final statistics = statisticsResult.getOrElse(() => <String, dynamic>{});
    final metrics = metricsResult.getOrElse(() => <String, dynamic>{});

    emit(StatisticsLoaded(statistics: statistics, performanceMetrics: metrics));
  }

  /// Mark job notification as read
  Future<void> _onMarkJobNotificationAsRead(
    MarkJobNotificationAsReadEvent event,
    Emitter<PartnerDashboardState> emit,
  ) async {
    final result = await _repository.markJobNotificationAsRead(
      event.partnerId,
      event.jobId,
    );

    result.fold(
      (failure) {
        // Silently fail for notifications
      },
      (_) {
        // Update unread count
        add(LoadUnreadNotificationsCountEvent(partnerId: event.partnerId));
      },
    );
  }

  /// Load unread notifications count
  Future<void> _onLoadUnreadNotificationsCount(
    LoadUnreadNotificationsCountEvent event,
    Emitter<PartnerDashboardState> emit,
  ) async {
    final result = await _repository.getUnreadNotificationsCount(
      event.partnerId,
    );

    result.fold(
      (failure) {
        // Silently fail for notifications count
      },
      (count) {
        if (state is PartnerDashboardLoaded) {
          final currentState = state as PartnerDashboardLoaded;
          emit(currentState.copyWith(unreadNotificationsCount: count));
        } else {
          emit(UnreadNotificationsCountUpdated(count: count));
        }
      },
    );
  }

  /// Clear error
  Future<void> _onClearError(
    ClearErrorEvent event,
    Emitter<PartnerDashboardState> emit,
  ) async {
    if (state is PartnerDashboardError) {
      emit(PartnerDashboardInitial());
    }
  }

  /// Retry operation
  Future<void> _onRetryOperation(
    RetryOperationEvent event,
    Emitter<PartnerDashboardState> emit,
  ) async {
    if (event.partnerId.isNotEmpty) {
      add(LoadPartnerDashboard(partnerId: event.partnerId));
    }
  }
}
