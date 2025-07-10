import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../domain/entities/system_metrics.dart';
import '../../domain/entities/booking_analytics.dart';
import 'charts/charts.dart';

/// KPI overview widget displaying key performance indicators
class KPIOverview extends StatelessWidget {
  final SystemMetrics systemMetrics;
  final BookingAnalytics bookingAnalytics;

  const KPIOverview({
    super.key,
    required this.systemMetrics,
    required this.bookingAnalytics,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Key Performance Indicators',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),

          // KPI Grid
          ChartFactory.kpiDashboard(
            kpis: _buildKPICards(),
            crossAxisCount: _getCrossAxisCount(context),
            childAspectRatio: 1.8,
          ),
        ],
      ),
    );
  }

  /// Build KPI cards
  List<KPICard> _buildKPICards() {
    return [
      // Total Users
      KPICard(
        title: 'Total Users',
        value: ChartUtils.formatNumber(systemMetrics.totalUsers.toDouble()),
        subtitle: 'Registered users',
        icon: Icons.people_outline,
        color: AppColors.primary,
        trend: _calculateUserTrend(),
        isPositiveTrend: true,
      ),

      // Active Bookings
      KPICard(
        title: 'Active Bookings',
        value:
            (bookingAnalytics.pendingBookings +
                    bookingAnalytics.inProgressBookings)
                .toString(),
        subtitle: 'Currently active',
        icon: Icons.event_available,
        color: AppColors.success,
        trend: _calculateBookingTrend(),
        isPositiveTrend: true,
      ),

      // Total Revenue
      KPICard(
        title: 'Total Revenue',
        value: ChartUtils.formatCurrency(bookingAnalytics.totalBookingValue),
        subtitle: 'This month',
        icon: Icons.attach_money,
        color: AppColors.warning,
        trend: _calculateRevenueTrend(),
        isPositiveTrend: true,
      ),

      // Average Rating
      KPICard(
        title: 'Average Rating',
        value: systemMetrics.averageRating.toStringAsFixed(1),
        subtitle: 'Service quality',
        icon: Icons.star_outline,
        color: AppColors.info,
        trend: _calculateRatingTrend(),
        isPositiveTrend: true,
      ),

      // Completion Rate
      KPICard(
        title: 'Completion Rate',
        value: ChartUtils.formatPercentage(bookingAnalytics.completionRate),
        subtitle: 'Successfully completed',
        icon: Icons.check_circle_outline,
        color: AppColors.success,
        trend: _calculateCompletionTrend(),
        isPositiveTrend: true,
      ),

      // Response Time
      KPICard(
        title: 'Avg Response Time',
        value:
            '${systemMetrics.performance.apiResponseTime.toStringAsFixed(1)}ms',
        subtitle: 'System performance',
        icon: Icons.speed,
        color: _getResponseTimeColor(),
        trend: _calculateResponseTimeTrend(),
        isPositiveTrend: false, // Lower is better for response time
      ),

      // Active Partners
      KPICard(
        title: 'Active Partners',
        value: systemMetrics.totalPartners.toString(),
        subtitle: 'Service providers',
        icon: Icons.business_center_outlined,
        color: AppColors.secondary,
        trend: _calculatePartnerTrend(),
        isPositiveTrend: true,
      ),

      // System Health
      KPICard(
        title: 'System Health',
        value: '${(systemMetrics.systemHealth * 100).toStringAsFixed(0)}%',
        subtitle: 'Overall status',
        icon: Icons.health_and_safety_outlined,
        color: _getSystemHealthColor(),
        trend: _calculateSystemHealthTrend(),
        isPositiveTrend: true,
      ),
    ];
  }

  /// Get cross axis count based on screen size
  int _getCrossAxisCount(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 1200) return 4;
    if (screenWidth > 800) return 3;
    if (screenWidth > 600) return 2;
    return 1;
  }

  /// Calculate user trend (mock implementation)
  String _calculateUserTrend() {
    // In real implementation, this would compare with previous period
    return '+12.5%';
  }

  /// Calculate booking trend (mock implementation)
  String _calculateBookingTrend() {
    return '+8.3%';
  }

  /// Calculate revenue trend (mock implementation)
  String _calculateRevenueTrend() {
    return '+15.7%';
  }

  /// Calculate rating trend (mock implementation)
  String _calculateRatingTrend() {
    return '+0.2';
  }

  /// Calculate completion trend (mock implementation)
  String _calculateCompletionTrend() {
    return '+3.1%';
  }

  /// Calculate response time trend (mock implementation)
  String _calculateResponseTimeTrend() {
    return '-5.2%'; // Negative is good for response time
  }

  /// Calculate partner trend (mock implementation)
  String _calculatePartnerTrend() {
    return '+6.8%';
  }

  /// Calculate system health trend (mock implementation)
  String _calculateSystemHealthTrend() {
    return '+2.1%';
  }

  /// Get response time color based on performance
  Color _getResponseTimeColor() {
    if (systemMetrics.performance.apiResponseTime < 100) {
      return AppColors.success;
    } else if (systemMetrics.performance.apiResponseTime < 300) {
      return AppColors.warning;
    } else {
      return AppColors.error;
    }
  }

  /// Get system health color based on status
  Color _getSystemHealthColor() {
    if (systemMetrics.systemHealth >= 0.9) {
      return AppColors.success;
    } else if (systemMetrics.systemHealth >= 0.7) {
      return AppColors.warning;
    } else {
      return AppColors.error;
    }
  }
}
