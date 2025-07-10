import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../data/services/realtime_analytics_service.dart';
import '../../domain/entities/system_metrics.dart';
import '../../domain/entities/booking_analytics.dart';
import 'charts/charts.dart';

/// Real-time dashboard widget with live data updates
class RealtimeDashboardWidget extends StatefulWidget {
  final RealtimeAnalyticsService analyticsService;

  const RealtimeDashboardWidget({super.key, required this.analyticsService});

  @override
  State<RealtimeDashboardWidget> createState() =>
      _RealtimeDashboardWidgetState();
}

class _RealtimeDashboardWidgetState extends State<RealtimeDashboardWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  SystemMetrics? _currentMetrics;
  BookingAnalytics? _currentBookingAnalytics;
  double _currentRevenue = 0;
  int _currentUserCount = 0;
  int _currentActiveBookings = 0;
  Map<String, int> _currentPartnerStatus = {};

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _subscribeToStreams();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _pulseController.repeat(reverse: true);
  }

  void _subscribeToStreams() {
    // Subscribe to system metrics stream
    widget.analyticsService.getSystemMetricsStream().listen((metrics) {
      if (mounted) {
        setState(() {
          _currentMetrics = metrics;
        });
        _triggerUpdateAnimation();
      }
    });

    // Subscribe to booking analytics stream
    widget.analyticsService.getBookingAnalyticsStream().listen((analytics) {
      if (mounted) {
        setState(() {
          _currentBookingAnalytics = analytics;
        });
        _triggerUpdateAnimation();
      }
    });

    // Subscribe to revenue stream
    widget.analyticsService.getRevenueStream().listen((revenue) {
      if (mounted) {
        setState(() {
          _currentRevenue = revenue;
        });
        _triggerUpdateAnimation();
      }
    });

    // Subscribe to user count stream
    widget.analyticsService.getUserCountStream().listen((userCount) {
      if (mounted) {
        setState(() {
          _currentUserCount = userCount;
        });
        _triggerUpdateAnimation();
      }
    });

    // Subscribe to active bookings stream
    widget.analyticsService.getActiveBookingsStream().listen((activeBookings) {
      if (mounted) {
        setState(() {
          _currentActiveBookings = activeBookings;
        });
        _triggerUpdateAnimation();
      }
    });

    // Subscribe to partner status stream
    widget.analyticsService.getPartnerStatusStream().listen((partnerStatus) {
      if (mounted) {
        setState(() {
          _currentPartnerStatus = partnerStatus;
        });
        _triggerUpdateAnimation();
      }
    });
  }

  void _triggerUpdateAnimation() {
    _pulseController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  /// Build widget header
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.border.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 12.w,
                  height: 12.h,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.success.withOpacity(0.5),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          SizedBox(width: 12.w),
          Text(
            'Real-time Analytics',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          Text(
            'Live',
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.success,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Build widget content
  Widget _buildContent() {
    if (_currentMetrics == null || _currentBookingAnalytics == null) {
      return _buildLoadingState();
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          _buildRealtimeKPIs(),
          SizedBox(height: 24.h),
          _buildRealtimeCharts(),
          SizedBox(height: 24.h),
          _buildActivityFeed(),
        ],
      ),
    );
  }

  /// Build loading state
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          SizedBox(height: 16.h),
          Text(
            'Connecting to real-time data...',
            style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  /// Build real-time KPIs
  Widget _buildRealtimeKPIs() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2.0,
      crossAxisSpacing: 16.w,
      mainAxisSpacing: 16.h,
      children: [
        _buildRealtimeKPI(
          title: 'Total Revenue',
          value: ChartUtils.formatCurrency(_currentRevenue),
          icon: Icons.attach_money,
          color: AppColors.success,
          isUpdating: true,
        ),
        _buildRealtimeKPI(
          title: 'Active Users',
          value: ChartUtils.formatNumber(_currentUserCount.toDouble()),
          icon: Icons.people,
          color: AppColors.primary,
          isUpdating: true,
        ),
        _buildRealtimeKPI(
          title: 'Active Bookings',
          value: _currentActiveBookings.toString(),
          icon: Icons.event_available,
          color: AppColors.warning,
          isUpdating: true,
        ),
        _buildRealtimeKPI(
          title: 'System Health',
          value: '${(_currentMetrics!.systemHealth * 100).toStringAsFixed(1)}%',
          icon: Icons.health_and_safety,
          color: _getSystemHealthColor(),
          isUpdating: true,
        ),
      ],
    );
  }

  /// Build individual real-time KPI
  Widget _buildRealtimeKPI({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    bool isUpdating = false,
  }) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: isUpdating
                  ? color.withOpacity(_pulseAnimation.value * 0.5)
                  : AppColors.border.withOpacity(0.3),
              width: isUpdating ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 20.r),
                  const Spacer(),
                  if (isUpdating)
                    Container(
                      width: 8.w,
                      height: 8.h,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Build real-time charts
  Widget _buildRealtimeCharts() {
    return Row(
      children: [
        Expanded(child: _buildPartnerStatusChart()),
        SizedBox(width: 16.w),
        Expanded(child: _buildBookingTrendChart()),
      ],
    );
  }

  /// Build partner status chart
  Widget _buildPartnerStatusChart() {
    if (_currentPartnerStatus.isEmpty) {
      return const SizedBox.shrink();
    }

    final data = _currentPartnerStatus.entries.map((entry) {
      Color color;
      switch (entry.key) {
        case 'active':
          color = AppColors.success;
          break;
        case 'inactive':
          color = AppColors.warning;
          break;
        case 'suspended':
          color = AppColors.error;
          break;
        default:
          color = AppColors.textSecondary;
      }

      return PieChartDataPoint(
        label: entry.key.toUpperCase(),
        value: entry.value.toDouble(),
        color: color,
      );
    }).toList();

    return DonutChartWidget(
      title: 'Partner Status',
      subtitle: 'Real-time updates',
      data: data,
      height: 250,
      showPercentages: true,
    );
  }

  /// Build booking trend chart
  Widget _buildBookingTrendChart() {
    if (_currentBookingAnalytics?.bookingsTrend.isEmpty ?? true) {
      return const SizedBox.shrink();
    }

    final data = _currentBookingAnalytics!.bookingsTrend.asMap().entries.map((
      entry,
    ) {
      return ChartDataPoint(
        x: entry.key.toDouble(),
        y: entry.value.totalBookings.toDouble(),
        label: 'Day ${entry.key + 1}',
      );
    }).toList();

    return LineChartWidget(
      title: 'Booking Trend',
      subtitle: 'Last 7 days',
      dataSeries: [
        ChartDataSeries(name: 'Bookings', data: data, color: AppColors.primary),
      ],
      height: 250,
      showArea: true,
      showDots: true,
    );
  }

  /// Build activity feed
  Widget _buildActivityFeed() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Text(
                  'Live Activity Feed',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 8.w,
                  height: 8.h,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
          Divider(color: AppColors.border.withOpacity(0.3), height: 1),
          _buildActivityList(),
        ],
      ),
    );
  }

  /// Build activity list
  Widget _buildActivityList() {
    // Mock activity data - in real implementation, this would come from the service
    final activities = [
      {
        'type': 'booking',
        'message': 'New booking created',
        'time': '2 seconds ago',
      },
      {
        'type': 'user',
        'message': 'New user registered',
        'time': '15 seconds ago',
      },
      {
        'type': 'payment',
        'message': 'Payment processed',
        'time': '32 seconds ago',
      },
      {
        'type': 'partner',
        'message': 'Partner completed job',
        'time': '1 minute ago',
      },
      {
        'type': 'system',
        'message': 'System backup completed',
        'time': '3 minutes ago',
      },
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activities.length,
      separatorBuilder: (context, index) =>
          Divider(color: AppColors.border.withOpacity(0.3), height: 1),
      itemBuilder: (context, index) {
        final activity = activities[index];
        return _buildActivityItem(activity);
      },
    );
  }

  /// Build activity item
  Widget _buildActivityItem(Map<String, String> activity) {
    IconData icon;
    Color color;

    switch (activity['type']) {
      case 'booking':
        icon = Icons.event_available;
        color = AppColors.primary;
        break;
      case 'user':
        icon = Icons.person_add;
        color = AppColors.success;
        break;
      case 'payment':
        icon = Icons.payment;
        color = AppColors.warning;
        break;
      case 'partner':
        icon = Icons.business_center;
        color = AppColors.info;
        break;
      case 'system':
        icon = Icons.settings;
        color = AppColors.textSecondary;
        break;
      default:
        icon = Icons.notifications;
        color = AppColors.textSecondary;
    }

    return ListTile(
      leading: CircleAvatar(
        radius: 16.r,
        backgroundColor: color.withOpacity(0.1),
        child: Icon(icon, size: 16.r, color: color),
      ),
      title: Text(
        activity['message']!,
        style: TextStyle(fontSize: 14.sp, color: AppColors.textPrimary),
      ),
      subtitle: Text(
        activity['time']!,
        style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
      ),
      dense: true,
    );
  }

  /// Get system health color
  Color _getSystemHealthColor() {
    if (_currentMetrics == null) return AppColors.textSecondary;

    if (_currentMetrics!.systemHealth >= 0.9) {
      return AppColors.success;
    } else if (_currentMetrics!.systemHealth >= 0.7) {
      return AppColors.warning;
    } else {
      return AppColors.error;
    }
  }
}
