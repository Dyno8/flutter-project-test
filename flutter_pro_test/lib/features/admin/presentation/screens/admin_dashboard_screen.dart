import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/animations/loading_animations.dart';
import '../../domain/entities/system_metrics.dart';
import '../bloc/admin_dashboard_bloc.dart';
import '../widgets/admin_app_bar.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/metrics_chart.dart';
import '../widgets/real_time_monitor.dart';

/// Main admin dashboard screen
class AdminDashboardScreen extends StatefulWidget {
  static const String routeName = '/admin-dashboard';

  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Initialize dashboard
    context.read<AdminDashboardBloc>().add(
      AdminDashboardStarted(startDate: _startDate, endDate: _endDate),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AdminAppBar(
        title: 'Dashboard',
        showBackButton: false,
        actions: [
          _buildDateRangeButton(),
          _buildRefreshButton(),
          _buildRealTimeToggle(),
        ],
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildAnalyticsTab(),
                _buildMonitoringTab(),
                _buildManagementTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppColors.surface,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
        indicatorWeight: 3,
        labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
        ),
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Analytics'),
          Tab(text: 'Monitoring'),
          Tab(text: 'Management'),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return BlocBuilder<AdminDashboardBloc, AdminDashboardState>(
      builder: (context, state) {
        if (state is AdminDashboardLoading) {
          return Center(
            child: LoadingAnimations.pulsingDots(
              color: AppColors.primary,
              size: 12.0,
            ),
          );
        }

        if (state is AdminDashboardError) {
          return _buildErrorWidget(state.message);
        }

        if (state is AdminDashboardLoaded) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<AdminDashboardBloc>().add(
                AdminDashboardRefreshRequested(
                  startDate: _startDate,
                  endDate: _endDate,
                ),
              );
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSystemMetricsGrid(state),
                  SizedBox(height: 24.h),
                  _buildBookingMetricsGrid(state),
                  SizedBox(height: 24.h),
                  _buildQuickActions(),
                  SizedBox(height: 24.h),
                  _buildRecentActivity(),
                ],
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildAnalyticsTab() {
    return BlocBuilder<AdminDashboardBloc, AdminDashboardState>(
      builder: (context, state) {
        if (state is AdminDashboardLoaded) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                MetricsChart(
                  title: 'Booking Trends',
                  data: state.bookingAnalytics.bookingsTrend,
                ),
                SizedBox(height: 24.h),
                MetricsChart(
                  title: 'Revenue Analytics',
                  data: [], // Would pass revenue trend data
                ),
                SizedBox(height: 24.h),
                _buildAnalyticsInsights(state),
              ],
            ),
          );
        }
        return _buildLoadingOrError(state);
      },
    );
  }

  Widget _buildMonitoringTab() {
    return BlocBuilder<AdminDashboardBloc, AdminDashboardState>(
      builder: (context, state) {
        if (state is AdminDashboardLoaded) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                RealTimeMonitor(
                  systemMetrics: state.systemMetrics,
                  isRealTimeEnabled: state.isRealTimeEnabled,
                ),
                SizedBox(height: 24.h),
                _buildSystemHealthCards(state),
                SizedBox(height: 24.h),
                _buildAlerts(),
              ],
            ),
          );
        }
        return _buildLoadingOrError(state);
      },
    );
  }

  Widget _buildManagementTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          _buildManagementActions(),
          SizedBox(height: 24.h),
          _buildDataExportSection(),
          SizedBox(height: 24.h),
          _buildSystemConfiguration(),
        ],
      ),
    );
  }

  Widget _buildSystemMetricsGrid(AdminDashboardLoaded state) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16.w,
      mainAxisSpacing: 16.h,
      childAspectRatio: 1.5,
      children: [
        DashboardCard(
          title: 'Total Users',
          value: state.systemMetrics.totalUsers.toString(),
          icon: Icons.people,
          color: AppColors.primary,
          trend: '+12%',
          isPositiveTrend: true,
        ),
        DashboardCard(
          title: 'Total Partners',
          value: state.systemMetrics.totalPartners.toString(),
          icon: Icons.business,
          color: AppColors.success,
          trend: '+8%',
          isPositiveTrend: true,
        ),
        DashboardCard(
          title: 'Total Bookings',
          value: state.systemMetrics.totalBookings.toString(),
          icon: Icons.calendar_today,
          color: AppColors.warning,
          trend: '+15%',
          isPositiveTrend: true,
        ),
        DashboardCard(
          title: 'Total Revenue',
          value: '\$${state.systemMetrics.totalRevenue.toStringAsFixed(0)}',
          icon: Icons.attach_money,
          color: AppColors.info,
          trend: '+22%',
          isPositiveTrend: true,
        ),
      ],
    );
  }

  Widget _buildBookingMetricsGrid(AdminDashboardLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Booking Metrics',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 16.h),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16.w,
          mainAxisSpacing: 16.h,
          childAspectRatio: 1.5,
          children: [
            DashboardCard(
              title: 'Active Bookings',
              value: state.systemMetrics.activeBookings.toString(),
              icon: Icons.pending_actions,
              color: AppColors.primary,
            ),
            DashboardCard(
              title: 'Completed',
              value: state.systemMetrics.completedBookings.toString(),
              icon: Icons.check_circle,
              color: AppColors.success,
            ),
            DashboardCard(
              title: 'Cancelled',
              value: state.systemMetrics.cancelledBookings.toString(),
              icon: Icons.cancel,
              color: AppColors.error,
            ),
            DashboardCard(
              title: 'Avg Rating',
              value: state.systemMetrics.averageRating.toStringAsFixed(1),
              icon: Icons.star,
              color: AppColors.warning,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingOrError(AdminDashboardState state) {
    if (state is AdminDashboardLoading) {
      return Center(
        child: LoadingAnimations.pulsingDots(
          color: AppColors.primary,
          size: 12.0,
        ),
      );
    }

    if (state is AdminDashboardError) {
      return _buildErrorWidget(state.message);
    }

    return const SizedBox.shrink();
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64.sp, color: AppColors.error),
          SizedBox(height: 16.h),
          Text(
            'Error Loading Dashboard',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            message,
            style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () {
              context.read<AdminDashboardBloc>().add(
                AdminDashboardRefreshRequested(
                  startDate: _startDate,
                  endDate: _endDate,
                ),
              );
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // Placeholder methods for other widgets
  Widget _buildDateRangeButton() => IconButton(
    icon: const Icon(Icons.date_range),
    onPressed: () {
      // Implement date range picker
    },
  );

  Widget _buildRefreshButton() => IconButton(
    icon: const Icon(Icons.refresh),
    onPressed: () {
      context.read<AdminDashboardBloc>().add(
        AdminDashboardRefreshRequested(
          startDate: _startDate,
          endDate: _endDate,
        ),
      );
    },
  );

  Widget _buildRealTimeToggle() {
    return BlocBuilder<AdminDashboardBloc, AdminDashboardState>(
      builder: (context, state) {
        final isRealTimeEnabled = state is AdminDashboardLoaded
            ? state.isRealTimeEnabled
            : false;

        return Container(
          margin: EdgeInsets.only(right: 8.w),
          child: Switch.adaptive(
            value: isRealTimeEnabled,
            onChanged: (value) {
              context.read<AdminDashboardBloc>().add(
                AdminDashboardRealTimeToggled(value),
              );
            },
            activeColor: AppColors.success,
          ),
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 16.h),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16.w,
          mainAxisSpacing: 16.h,
          childAspectRatio: 2.5,
          children: [
            _buildQuickActionCard(
              title: 'Refresh Data',
              icon: Icons.refresh,
              color: AppColors.primary,
              onTap: () {
                context.read<AdminDashboardBloc>().add(
                  AdminDashboardRefreshRequested(
                    startDate: _startDate,
                    endDate: _endDate,
                  ),
                );
              },
            ),
            _buildQuickActionCard(
              title: 'Export Data',
              icon: Icons.download,
              color: AppColors.info,
              onTap: () {
                // TODO: Implement data export
              },
            ),
            _buildQuickActionCard(
              title: 'System Health',
              icon: Icons.health_and_safety,
              color: AppColors.success,
              onTap: () {
                // TODO: Navigate to detailed health view
              },
            ),
            _buildQuickActionCard(
              title: 'Maintenance',
              icon: Icons.build,
              color: AppColors.warning,
              onTap: () {
                // TODO: Implement maintenance mode
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 32.w,
              height: 32.h,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(icon, color: color, size: 18.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              _buildActivityItem(
                title: 'New booking created',
                subtitle: 'House cleaning service',
                time: '2 minutes ago',
                icon: Icons.add_circle,
                color: AppColors.success,
              ),
              Divider(height: 24.h, color: AppColors.border),
              _buildActivityItem(
                title: 'Partner registered',
                subtitle: 'John Doe joined as cleaner',
                time: '15 minutes ago',
                icon: Icons.person_add,
                color: AppColors.primary,
              ),
              Divider(height: 24.h, color: AppColors.border),
              _buildActivityItem(
                title: 'Payment processed',
                subtitle: '\$45.00 for booking #1234',
                time: '1 hour ago',
                icon: Icons.payment,
                color: AppColors.info,
              ),
              Divider(height: 24.h, color: AppColors.border),
              _buildActivityItem(
                title: 'System alert resolved',
                subtitle: 'High CPU usage normalized',
                time: '2 hours ago',
                icon: Icons.check_circle,
                color: AppColors.warning,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem({
    required String title,
    required String subtitle,
    required String time,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 32.w,
          height: 32.h,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: color, size: 16.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Text(
          time,
          style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildAnalyticsInsights(AdminDashboardLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analytics Insights',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              _buildInsightItem(
                title: 'Peak Booking Hours',
                value: '2:00 PM - 4:00 PM',
                trend: '+15%',
                isPositive: true,
                icon: Icons.schedule,
              ),
              Divider(height: 24.h, color: AppColors.border),
              _buildInsightItem(
                title: 'Most Popular Service',
                value: 'House Cleaning',
                trend: '45% of bookings',
                isPositive: true,
                icon: Icons.cleaning_services,
              ),
              Divider(height: 24.h, color: AppColors.border),
              _buildInsightItem(
                title: 'Average Rating',
                value: '4.8/5.0',
                trend: '+0.2',
                isPositive: true,
                icon: Icons.star,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInsightItem({
    required String title,
    required String value,
    required String trend,
    required bool isPositive,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          width: 32.w,
          height: 32.h,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: AppColors.primary, size: 16.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: (isPositive ? AppColors.success : AppColors.error)
                .withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            trend,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: isPositive ? AppColors.success : AppColors.error,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSystemHealthCards(AdminDashboardLoaded state) {
    final performance = state.systemMetrics.performance;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'System Health Details',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 16.h),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16.w,
          mainAxisSpacing: 16.h,
          childAspectRatio: 1.2,
          children: [
            _buildHealthMetricCard(
              title: 'API Response',
              value: '${performance.apiResponseTime.toInt()}ms',
              status: _getResponseTimeStatus(performance.apiResponseTime),
              icon: Icons.speed,
            ),
            _buildHealthMetricCard(
              title: 'Error Rate',
              value: '${performance.errorRate.toStringAsFixed(1)}%',
              status: _getErrorRateStatus(performance.errorRate),
              icon: Icons.error_outline,
            ),
            _buildHealthMetricCard(
              title: 'CPU Usage',
              value: '${performance.cpuUsage.toInt()}%',
              status: _getCpuUsageStatus(performance.cpuUsage),
              icon: Icons.memory,
            ),
            _buildHealthMetricCard(
              title: 'Memory Usage',
              value: '${performance.memoryUsage.toInt()}%',
              status: _getMemoryUsageStatus(performance.memoryUsage),
              icon: Icons.storage,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHealthMetricCard({
    required String title,
    required String value,
    required SystemHealthStatus status,
    required IconData icon,
  }) {
    final color = _getHealthStatusColor(status);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32.w,
                height: 32.h,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(icon, color: color, size: 18.sp),
              ),
              const Spacer(),
              Container(
                width: 8.w,
                height: 8.h,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            title,
            style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            status.displayName,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlerts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'System Alerts',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              _buildAlertItem(
                title: 'High Memory Usage',
                message: 'Memory usage is above 80%. Consider optimizing.',
                severity: AlertSeverity.warning,
                time: '5 minutes ago',
              ),
              Divider(height: 24.h, color: AppColors.border),
              _buildAlertItem(
                title: 'Database Connection',
                message: 'All database connections are healthy.',
                severity: AlertSeverity.info,
                time: '1 hour ago',
              ),
              Divider(height: 24.h, color: AppColors.border),
              _buildAlertItem(
                title: 'Backup Completed',
                message: 'Daily backup completed successfully.',
                severity: AlertSeverity.success,
                time: '2 hours ago',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAlertItem({
    required String title,
    required String message,
    required AlertSeverity severity,
    required String time,
  }) {
    final color = _getAlertSeverityColor(severity);
    final icon = _getAlertSeverityIcon(severity);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32.w,
          height: 32.h,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: color, size: 16.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Text(
                message,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildManagementActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Management Actions',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 16.h),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 1,
          crossAxisSpacing: 16.w,
          mainAxisSpacing: 16.h,
          childAspectRatio: 4,
          children: [
            _buildManagementActionCard(
              title: 'User Management',
              subtitle: 'Manage users, roles, and permissions',
              icon: Icons.people,
              color: AppColors.primary,
              onTap: () {
                // TODO: Navigate to user management
              },
            ),
            _buildManagementActionCard(
              title: 'Partner Management',
              subtitle: 'Manage partners, approvals, and ratings',
              icon: Icons.business,
              color: AppColors.success,
              onTap: () {
                // TODO: Navigate to partner management
              },
            ),
            _buildManagementActionCard(
              title: 'Service Management',
              subtitle: 'Manage services, pricing, and availability',
              icon: Icons.cleaning_services,
              color: AppColors.info,
              onTap: () {
                // TODO: Navigate to service management
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildManagementActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: color, size: 24.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textSecondary,
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataExportSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Data Export',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              _buildExportOption(
                title: 'Analytics Report',
                subtitle: 'Export analytics data as PDF or Excel',
                icon: Icons.analytics,
                onTap: () {
                  // TODO: Implement analytics export
                },
              ),
              Divider(height: 24.h, color: AppColors.border),
              _buildExportOption(
                title: 'User Data',
                subtitle: 'Export user information and statistics',
                icon: Icons.people,
                onTap: () {
                  // TODO: Implement user data export
                },
              ),
              Divider(height: 24.h, color: AppColors.border),
              _buildExportOption(
                title: 'Booking Data',
                subtitle: 'Export booking history and details',
                icon: Icons.calendar_today,
                onTap: () {
                  // TODO: Implement booking data export
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExportOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          children: [
            Container(
              width: 32.w,
              height: 32.h,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(icon, color: AppColors.primary, size: 16.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.download, color: AppColors.textSecondary, size: 16.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemConfiguration() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'System Configuration',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              _buildConfigOption(
                title: 'Maintenance Mode',
                subtitle: 'Enable/disable system maintenance',
                isEnabled: false,
                onChanged: (value) {
                  // TODO: Implement maintenance mode toggle
                },
              ),
              Divider(height: 24.h, color: AppColors.border),
              _buildConfigOption(
                title: 'Real-time Updates',
                subtitle: 'Enable real-time dashboard updates',
                isEnabled: true,
                onChanged: (value) {
                  context.read<AdminDashboardBloc>().add(
                    AdminDashboardRealTimeToggled(value),
                  );
                },
              ),
              Divider(height: 24.h, color: AppColors.border),
              _buildConfigOption(
                title: 'Debug Mode',
                subtitle: 'Enable debug logging and diagnostics',
                isEnabled: false,
                onChanged: (value) {
                  // TODO: Implement debug mode toggle
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConfigOption({
    required String title,
    required String subtitle,
    required bool isEnabled,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Switch.adaptive(
          value: isEnabled,
          onChanged: onChanged,
          activeColor: AppColors.success,
        ),
      ],
    );
  }

  // Helper methods for health status
  SystemHealthStatus _getResponseTimeStatus(double responseTime) {
    if (responseTime < 500) return SystemHealthStatus.healthy;
    if (responseTime < 1000) return SystemHealthStatus.warning;
    return SystemHealthStatus.critical;
  }

  SystemHealthStatus _getErrorRateStatus(double errorRate) {
    if (errorRate < 1.0) return SystemHealthStatus.healthy;
    if (errorRate < 3.0) return SystemHealthStatus.warning;
    return SystemHealthStatus.critical;
  }

  SystemHealthStatus _getCpuUsageStatus(double cpuUsage) {
    if (cpuUsage < 50) return SystemHealthStatus.healthy;
    if (cpuUsage < 80) return SystemHealthStatus.warning;
    return SystemHealthStatus.critical;
  }

  SystemHealthStatus _getMemoryUsageStatus(double memoryUsage) {
    if (memoryUsage < 50) return SystemHealthStatus.healthy;
    if (memoryUsage < 80) return SystemHealthStatus.warning;
    return SystemHealthStatus.critical;
  }

  Color _getHealthStatusColor(SystemHealthStatus status) {
    switch (status) {
      case SystemHealthStatus.healthy:
        return AppColors.success;
      case SystemHealthStatus.warning:
        return AppColors.warning;
      case SystemHealthStatus.critical:
        return AppColors.error;
    }
  }

  Color _getAlertSeverityColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.info:
        return AppColors.info;
      case AlertSeverity.success:
        return AppColors.success;
      case AlertSeverity.warning:
        return AppColors.warning;
      case AlertSeverity.error:
        return AppColors.error;
    }
  }

  IconData _getAlertSeverityIcon(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.info:
        return Icons.info;
      case AlertSeverity.success:
        return Icons.check_circle;
      case AlertSeverity.warning:
        return Icons.warning;
      case AlertSeverity.error:
        return Icons.error;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

// Alert severity enum
enum AlertSeverity { info, success, warning, error }
