import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../bloc/admin_dashboard_bloc.dart';
import '../widgets/charts/charts.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/kpi_overview.dart';
import '../widgets/quick_actions.dart';

/// Advanced admin dashboard screen with comprehensive analytics and reporting
class AdvancedAdminDashboardScreen extends StatefulWidget {
  const AdvancedAdminDashboardScreen({super.key});

  @override
  State<AdvancedAdminDashboardScreen> createState() =>
      _AdvancedAdminDashboardScreenState();
}

class _AdvancedAdminDashboardScreenState
    extends State<AdvancedAdminDashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AdminDashboardBloc _dashboardBloc;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _dashboardBloc = context.read<AdminDashboardBloc>();
    _loadDashboardData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadDashboardData() {
    final now = DateTime.now();
    final startDate = DateTime(
      now.year,
      now.month,
      1,
    ); // Start of current month
    final endDate = now;

    _dashboardBloc.add(
      AdminDashboardStarted(startDate: startDate, endDate: endDate),
    );
  }

  void _refreshData() {
    final now = DateTime.now();
    final startDate = DateTime(
      now.year,
      now.month,
      1,
    ); // Start of current month
    final endDate = now;

    _dashboardBloc.add(
      AdminDashboardRefreshRequested(startDate: startDate, endDate: endDate),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<AdminDashboardBloc, AdminDashboardState>(
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              // Dashboard Header
              SliverToBoxAdapter(
                child: DashboardHeader(
                  onRefresh: _refreshData,
                  isLoading: state is AdminDashboardLoading,
                ),
              ),

              // KPI Overview
              SliverToBoxAdapter(child: _buildKPIOverview(state)),

              // Quick Actions
              SliverToBoxAdapter(
                child: QuickActions(
                  onExportReports: _handleExportReports,
                  onManageUsers: _handleManageUsers,
                  onManagePartners: _handleManagePartners,
                  onSystemSettings: _handleSystemSettings,
                ),
              ),

              // Analytics Tabs
              SliverToBoxAdapter(child: _buildAnalyticsTabs(state)),

              // Tab Content
              SliverFillRemaining(child: _buildTabContent(state)),
            ],
          );
        },
      ),
    );
  }

  /// Build KPI overview section
  Widget _buildKPIOverview(AdminDashboardState state) {
    if (state is AdminDashboardLoading) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: LoadingWidget(),
      );
    }

    if (state is AdminDashboardError) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: CustomErrorWidget(message: state.message, onRetry: _refreshData),
      );
    }

    if (state is AdminDashboardLoaded) {
      return KPIOverview(
        systemMetrics: state.systemMetrics,
        bookingAnalytics: state.bookingAnalytics,
      );
    }

    return const SizedBox.shrink();
  }

  /// Build analytics tabs
  Widget _buildAnalyticsTabs(AdminDashboardState state) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: AppColors.primary,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
        ),
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Revenue'),
          Tab(text: 'Users'),
          Tab(text: 'Partners'),
          Tab(text: 'Reports'),
        ],
      ),
    );
  }

  /// Build tab content
  Widget _buildTabContent(AdminDashboardState state) {
    return Container(
      margin: EdgeInsets.all(16.w),
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(state),
          _buildRevenueTab(state),
          _buildUsersTab(state),
          _buildPartnersTab(state),
          _buildReportsTab(state),
        ],
      ),
    );
  }

  /// Build overview tab
  Widget _buildOverviewTab(AdminDashboardState state) {
    if (state is! AdminDashboardLoaded) {
      return _buildLoadingOrError(state);
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h),

          // System Health Overview
          _buildSectionTitle('System Health'),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: ChartFactory.performanceDonutChart(
                  title: 'System Performance',
                  data: [
                    PieChartDataPoint(
                      label: 'Healthy',
                      value: 85,
                      color: Colors.green,
                    ),
                    PieChartDataPoint(
                      label: 'Warning',
                      value: 10,
                      color: Colors.orange,
                    ),
                    PieChartDataPoint(
                      label: 'Critical',
                      value: 5,
                      color: Colors.red,
                    ),
                  ],
                  height: 250,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: ChartFactory.revenueTrendChart(
                  title: 'Revenue Trend (7 days)',
                  data: _generateSampleRevenueData(),
                  height: 250,
                ),
              ),
            ],
          ),

          SizedBox(height: 24.h),

          // Recent Activity
          _buildSectionTitle('Recent Activity'),
          SizedBox(height: 12.h),
          _buildRecentActivityList(state),
        ],
      ),
    );
  }

  /// Build revenue tab
  Widget _buildRevenueTab(AdminDashboardState state) {
    if (state is! AdminDashboardLoaded) {
      return _buildLoadingOrError(state);
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h),

          // Revenue Overview
          ChartFactory.revenueTrendChart(
            title: 'Revenue Trend (30 days)',
            data: _generateSampleRevenueData(days: 30),
            subtitle: 'Daily revenue over the past month',
            height: 300,
          ),

          SizedBox(height: 16.h),

          Row(
            children: [
              Expanded(
                child: ChartFactory.serviceDistributionChart(
                  title: 'Revenue by Service',
                  data: _generateServiceRevenueData(),
                  height: 300,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: ChartFactory.monthlyComparisonChart(
                  title: 'Monthly Comparison',
                  data: _generateMonthlyComparisonData(),
                  height: 300,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build users tab
  Widget _buildUsersTab(AdminDashboardState state) {
    if (state is! AdminDashboardLoaded) {
      return _buildLoadingOrError(state);
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h),

          // User Growth
          ChartFactory.growthAreaChart(
            title: 'User Growth',
            dataSeries: [
              ChartDataSeries(
                name: 'Total Users',
                data: _generateUserGrowthData(),
                color: ChartTheme.primaryColors[0],
              ),
              ChartDataSeries(
                name: 'Active Users',
                data: _generateActiveUserData(),
                color: ChartTheme.primaryColors[1],
              ),
            ],
            height: 300,
          ),

          SizedBox(height: 16.h),

          Row(
            children: [
              Expanded(
                child: ChartFactory.serviceDistributionChart(
                  title: 'Users by Region',
                  data: _generateUserRegionData(),
                  height: 300,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: ChartFactory.monthlyComparisonChart(
                  title: 'User Engagement',
                  data: _generateUserEngagementData(),
                  height: 300,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build partners tab
  Widget _buildPartnersTab(AdminDashboardState state) {
    if (state is! AdminDashboardLoaded) {
      return _buildLoadingOrError(state);
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h),

          // Partner Performance
          ChartFactory.revenueTrendChart(
            title: 'Partner Performance',
            data: _generatePartnerPerformanceData(),
            subtitle: 'Average rating over time',
            height: 300,
          ),

          SizedBox(height: 16.h),

          Row(
            children: [
              Expanded(
                child: ChartFactory.serviceDistributionChart(
                  title: 'Partners by Service',
                  data: _generatePartnerServiceData(),
                  height: 300,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: ChartFactory.performanceDonutChart(
                  title: 'Partner Status',
                  data: _generatePartnerStatusData(),
                  height: 300,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build reports tab
  Widget _buildReportsTab(AdminDashboardState state) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h),

          _buildSectionTitle('Generate Reports'),
          SizedBox(height: 12.h),

          // Report generation UI will be implemented in task 9.5.6
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.border.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.assessment,
                  size: 48.r,
                  color: AppColors.textSecondary,
                ),
                SizedBox(height: 16.h),
                Text(
                  'Report Generation',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Advanced report generation features will be available soon.',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build section title
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  /// Build loading or error state
  Widget _buildLoadingOrError(AdminDashboardState state) {
    if (state is AdminDashboardLoading) {
      return const Center(child: LoadingWidget());
    }

    if (state is AdminDashboardError) {
      return Center(
        child: CustomErrorWidget(message: state.message, onRetry: _refreshData),
      );
    }

    return const SizedBox.shrink();
  }

  /// Build recent activity list
  Widget _buildRecentActivityList(AdminDashboardLoaded state) {
    final activities = [
      'New booking created by John Doe',
      'Partner Jane Smith completed a job',
      'Payment processed for booking #1234',
      'New user registered: Mike Johnson',
      'System backup completed successfully',
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: activities.length,
        separatorBuilder: (context, index) =>
            Divider(color: AppColors.border.withOpacity(0.3), height: 1),
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              radius: 16.r,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Icon(
                Icons.notifications,
                size: 16.r,
                color: AppColors.primary,
              ),
            ),
            title: Text(
              activities[index],
              style: TextStyle(fontSize: 14.sp, color: AppColors.textPrimary),
            ),
            subtitle: Text(
              '${index + 1} hour${index == 0 ? '' : 's'} ago',
              style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
            ),
          );
        },
      ),
    );
  }

  // Sample data generators (these would be replaced with real data)
  List<ChartDataPoint> _generateSampleRevenueData({int days = 7}) {
    return List.generate(days, (index) {
      return ChartDataPoint(
        x: index.toDouble(),
        y: 1000 + (index * 150) + (index % 3 * 200),
        label: 'Day ${index + 1}',
      );
    });
  }

  List<PieChartDataPoint> _generateServiceRevenueData() {
    return [
      PieChartDataPoint(
        label: 'Home Cleaning',
        value: 45000,
        color: ChartTheme.primaryColors[0],
      ),
      PieChartDataPoint(
        label: 'Plumbing',
        value: 32000,
        color: ChartTheme.primaryColors[1],
      ),
      PieChartDataPoint(
        label: 'Electrical',
        value: 28000,
        color: ChartTheme.primaryColors[2],
      ),
      PieChartDataPoint(
        label: 'Gardening',
        value: 18000,
        color: ChartTheme.primaryColors[3],
      ),
    ];
  }

  List<BarChartDataPoint> _generateMonthlyComparisonData() {
    return [
      BarChartDataPoint(label: 'Jan', value: 85000),
      BarChartDataPoint(label: 'Feb', value: 92000),
      BarChartDataPoint(label: 'Mar', value: 78000),
      BarChartDataPoint(label: 'Apr', value: 105000),
      BarChartDataPoint(label: 'May', value: 98000),
      BarChartDataPoint(label: 'Jun', value: 112000),
    ];
  }

  List<ChartDataPoint> _generateUserGrowthData() {
    return List.generate(30, (index) {
      return ChartDataPoint(
        x: index.toDouble(),
        y: 10000 + (index * 50),
        label: 'Day ${index + 1}',
      );
    });
  }

  List<ChartDataPoint> _generateActiveUserData() {
    return List.generate(30, (index) {
      return ChartDataPoint(
        x: index.toDouble(),
        y: 7500 + (index * 35),
        label: 'Day ${index + 1}',
      );
    });
  }

  List<PieChartDataPoint> _generateUserRegionData() {
    return [
      PieChartDataPoint(
        label: 'Ho Chi Minh City',
        value: 6200,
        color: ChartTheme.primaryColors[0],
      ),
      PieChartDataPoint(
        label: 'Hanoi',
        value: 3800,
        color: ChartTheme.primaryColors[1],
      ),
      PieChartDataPoint(
        label: 'Da Nang',
        value: 1450,
        color: ChartTheme.primaryColors[2],
      ),
      PieChartDataPoint(
        label: 'Can Tho',
        value: 1000,
        color: ChartTheme.primaryColors[3],
      ),
    ];
  }

  List<BarChartDataPoint> _generateUserEngagementData() {
    return [
      BarChartDataPoint(label: 'Sessions', value: 85),
      BarChartDataPoint(label: 'Page Views', value: 92),
      BarChartDataPoint(label: 'Bookings', value: 78),
      BarChartDataPoint(label: 'Reviews', value: 65),
    ];
  }

  List<ChartDataPoint> _generatePartnerPerformanceData() {
    return List.generate(30, (index) {
      return ChartDataPoint(
        x: index.toDouble(),
        y: 4.0 + (index * 0.01),
        label: 'Day ${index + 1}',
      );
    });
  }

  List<PieChartDataPoint> _generatePartnerServiceData() {
    return [
      PieChartDataPoint(
        label: 'Home Cleaning',
        value: 450,
        color: ChartTheme.primaryColors[0],
      ),
      PieChartDataPoint(
        label: 'Plumbing',
        value: 320,
        color: ChartTheme.primaryColors[1],
      ),
      PieChartDataPoint(
        label: 'Electrical',
        value: 280,
        color: ChartTheme.primaryColors[2],
      ),
      PieChartDataPoint(
        label: 'Gardening',
        value: 200,
        color: ChartTheme.primaryColors[3],
      ),
    ];
  }

  List<PieChartDataPoint> _generatePartnerStatusData() {
    return [
      PieChartDataPoint(label: 'Active', value: 890, color: Colors.green),
      PieChartDataPoint(label: 'Inactive', value: 285, color: Colors.orange),
      PieChartDataPoint(label: 'Suspended', value: 75, color: Colors.red),
    ];
  }

  // Action handlers
  void _handleExportReports() {
    // Implementation for task 9.5.6
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export functionality coming soon')),
    );
  }

  void _handleManageUsers() {
    // Navigate to user management
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User management coming soon')),
    );
  }

  void _handleManagePartners() {
    // Navigate to partner management
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Partner management coming soon')),
    );
  }

  void _handleSystemSettings() {
    // Navigate to system settings
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('System settings coming soon')),
    );
  }
}
