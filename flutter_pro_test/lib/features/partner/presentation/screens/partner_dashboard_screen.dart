import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../bloc/partner_dashboard_bloc.dart';
import '../bloc/partner_dashboard_event.dart';
import '../bloc/partner_dashboard_state.dart';
import '../widgets/partner_dashboard_header.dart';
import '../widgets/job_queue_section.dart';
import '../widgets/earnings_overview_section.dart';
import '../widgets/availability_toggle_section.dart';
import '../widgets/quick_stats_section.dart';

/// Main partner dashboard screen
class PartnerDashboardScreen extends StatefulWidget {
  final String partnerId;

  const PartnerDashboardScreen({
    super.key,
    required this.partnerId,
  });

  @override
  State<PartnerDashboardScreen> createState() => _PartnerDashboardScreenState();
}

class _PartnerDashboardScreenState extends State<PartnerDashboardScreen>
    with WidgetsBindingObserver {
  late PartnerDashboardBloc _dashboardBloc;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _dashboardBloc = di.sl<PartnerDashboardBloc>();
    
    // Load dashboard data
    _dashboardBloc.add(LoadPartnerDashboard(partnerId: widget.partnerId));
    
    // Start listening to real-time updates
    _dashboardBloc.add(StartListeningToUpdates(partnerId: widget.partnerId));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _dashboardBloc.add(StopListeningToUpdates());
    _dashboardBloc.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Update online status based on app lifecycle
    switch (state) {
      case AppLifecycleState.resumed:
        _dashboardBloc.add(UpdateOnlineStatusEvent(
          partnerId: widget.partnerId,
          isOnline: true,
        ));
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        _dashboardBloc.add(UpdateOnlineStatusEvent(
          partnerId: widget.partnerId,
          isOnline: false,
        ));
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _dashboardBloc,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: BlocConsumer<PartnerDashboardBloc, PartnerDashboardState>(
          listener: (context, state) {
            _handleStateChanges(context, state);
          },
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: () async {
                _dashboardBloc.add(RefreshPartnerDashboard(partnerId: widget.partnerId));
                
                // Wait for refresh to complete
                await _dashboardBloc.stream
                    .firstWhere((state) => state is! PartnerDashboardRefreshing);
              },
              child: _buildBody(context, state),
            );
          },
        ),
        floatingActionButton: _buildFloatingActionButton(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context, PartnerDashboardState state) {
    if (state is PartnerDashboardLoading) {
      return const Center(child: LoadingWidget());
    }

    if (state is PartnerDashboardError) {
      return Center(
        child: CustomErrorWidget(
          message: state.message,
          onRetry: () {
            _dashboardBloc.add(LoadPartnerDashboard(partnerId: widget.partnerId));
          },
        ),
      );
    }

    if (state is PartnerDashboardLoaded || state is PartnerDashboardRefreshing) {
      final loadedState = state is PartnerDashboardRefreshing
          ? state.currentState
          : state as PartnerDashboardLoaded;

      return CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 120.h,
            floating: false,
            pinned: true,
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Partner Dashboard',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              // Notifications icon with badge
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {
                      // Navigate to notifications screen
                    },
                  ),
                  if (loadedState.unreadNotificationsCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.error,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 16.w,
                          minHeight: 16.h,
                        ),
                        child: Text(
                          '${loadedState.unreadNotificationsCount}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onError,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              // Settings icon
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {
                  // Navigate to settings screen
                },
              ),
            ],
          ),

          // Dashboard Header
          SliverToBoxAdapter(
            child: PartnerDashboardHeader(
              availability: loadedState.availability,
              earnings: loadedState.earnings,
              onAvailabilityToggle: (isAvailable, reason) {
                _dashboardBloc.add(ToggleAvailabilityEvent(
                  partnerId: widget.partnerId,
                  isAvailable: isAvailable,
                  reason: reason,
                ));
              },
            ),
          ),

          // Quick Stats
          SliverToBoxAdapter(
            child: QuickStatsSection(
              pendingJobsCount: loadedState.pendingJobs.length,
              acceptedJobsCount: loadedState.acceptedJobs.length,
              todayEarnings: loadedState.earnings.todayEarnings,
              averageRating: loadedState.earnings.averageRating,
            ),
          ),

          // Availability Toggle
          SliverToBoxAdapter(
            child: AvailabilityToggleSection(
              availability: loadedState.availability,
              onToggle: (isAvailable, reason) {
                _dashboardBloc.add(ToggleAvailabilityEvent(
                  partnerId: widget.partnerId,
                  isAvailable: isAvailable,
                  reason: reason,
                ));
              },
              onUpdateWorkingHours: (workingHours) {
                _dashboardBloc.add(UpdateWorkingHoursEvent(
                  partnerId: widget.partnerId,
                  workingHours: workingHours,
                ));
              },
            ),
          ),

          // Job Queue
          SliverToBoxAdapter(
            child: JobQueueSection(
              pendingJobs: loadedState.pendingJobs,
              acceptedJobs: loadedState.acceptedJobs,
              onAcceptJob: (jobId) {
                _dashboardBloc.add(AcceptJobEvent(
                  jobId: jobId,
                  partnerId: widget.partnerId,
                ));
              },
              onRejectJob: (jobId, reason) {
                _dashboardBloc.add(RejectJobEvent(
                  jobId: jobId,
                  partnerId: widget.partnerId,
                  rejectionReason: reason,
                ));
              },
              onStartJob: (jobId) {
                _dashboardBloc.add(StartJobEvent(
                  jobId: jobId,
                  partnerId: widget.partnerId,
                ));
              },
              onCompleteJob: (jobId) {
                _dashboardBloc.add(CompleteJobEvent(
                  jobId: jobId,
                  partnerId: widget.partnerId,
                ));
              },
            ),
          ),

          // Earnings Overview
          SliverToBoxAdapter(
            child: EarningsOverviewSection(
              earnings: loadedState.earnings,
              onViewDetails: () {
                // Navigate to detailed earnings screen
                Navigator.pushNamed(
                  context,
                  '/partner/earnings',
                  arguments: widget.partnerId,
                );
              },
            ),
          ),

          // Bottom padding
          SliverToBoxAdapter(
            child: SizedBox(height: 100.h),
          ),
        ],
      );
    }

    return const Center(child: Text('Unknown state'));
  }

  Widget? _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        // Navigate to job history or create new availability slot
        Navigator.pushNamed(
          context,
          '/partner/job-history',
          arguments: widget.partnerId,
        );
      },
      icon: const Icon(Icons.history),
      label: const Text('Job History'),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
    );
  }

  void _handleStateChanges(BuildContext context, PartnerDashboardState state) {
    if (state is JobOperationSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    if (state is JobOperationError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    if (state is AvailabilityUpdateSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    if (state is AvailabilityUpdateError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
