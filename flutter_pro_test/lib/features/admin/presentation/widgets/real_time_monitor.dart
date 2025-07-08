import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../domain/entities/system_metrics.dart';
import 'dashboard_card.dart';

/// Widget for real-time system monitoring
class RealTimeMonitor extends StatefulWidget {
  final SystemMetrics systemMetrics;
  final bool isRealTimeEnabled;

  const RealTimeMonitor({
    super.key,
    required this.systemMetrics,
    required this.isRealTimeEnabled,
  });

  @override
  State<RealTimeMonitor> createState() => _RealTimeMonitorState();
}

class _RealTimeMonitorState extends State<RealTimeMonitor>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.isRealTimeEnabled) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(RealTimeMonitor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRealTimeEnabled != oldWidget.isRealTimeEnabled) {
      if (widget.isRealTimeEnabled) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        SizedBox(height: 16.h),
        _buildSystemHealthCard(),
        SizedBox(height: 16.h),
        _buildPerformanceMetrics(),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Text(
          'System Monitoring',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        _buildRealTimeIndicator(),
      ],
    );
  }

  Widget _buildRealTimeIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: widget.isRealTimeEnabled
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.textSecondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: widget.isRealTimeEnabled
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.textSecondary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: widget.isRealTimeEnabled ? _pulseAnimation.value : 1.0,
                child: Container(
                  width: 8.w,
                  height: 8.h,
                  decoration: BoxDecoration(
                    color: widget.isRealTimeEnabled
                        ? AppColors.success
                        : AppColors.textSecondary,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          ),
          SizedBox(width: 8.w),
          Text(
            widget.isRealTimeEnabled ? 'Live' : 'Static',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: widget.isRealTimeEnabled
                  ? AppColors.success
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemHealthCard() {
    final healthStatus = widget.systemMetrics.performance.healthStatus;
    final statusColor = _getHealthStatusColor(healthStatus);

    return DashboardCard(
      title: 'System Health',
      value: healthStatus.displayName,
      icon: _getHealthStatusIcon(healthStatus),
      color: statusColor,
      customContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  _getHealthStatusIcon(healthStatus),
                  color: statusColor,
                  size: 20.sp,
                ),
              ),
              const Spacer(),
              Text(
                'Last updated: ${_formatTime(widget.systemMetrics.timestamp)}',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            'System Health',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            healthStatus.displayName,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: statusColor,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            healthStatus.description,
            style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetrics() {
    final performance = widget.systemMetrics.performance;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16.w,
      mainAxisSpacing: 16.h,
      childAspectRatio: 1.8,
      children: [
        _buildMetricCard(
          'API Response',
          '${performance.apiResponseTime.toStringAsFixed(0)}ms',
          Icons.speed,
          _getResponseTimeColor(performance.apiResponseTime),
        ),
        _buildMetricCard(
          'Error Rate',
          '${performance.errorRate.toStringAsFixed(1)}%',
          Icons.error_outline,
          _getErrorRateColor(performance.errorRate),
        ),
        _buildMetricCard(
          'CPU Usage',
          '${performance.cpuUsage.toStringAsFixed(1)}%',
          Icons.memory,
          _getCpuUsageColor(performance.cpuUsage),
        ),
        _buildMetricCard(
          'Memory Usage',
          '${performance.memoryUsage.toStringAsFixed(1)}%',
          Icons.storage,
          _getMemoryUsageColor(performance.memoryUsage),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16.sp),
              const Spacer(),
              Container(
                width: 8.w,
                height: 8.h,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            title,
            style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary),
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
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

  IconData _getHealthStatusIcon(SystemHealthStatus status) {
    switch (status) {
      case SystemHealthStatus.healthy:
        return Icons.check_circle;
      case SystemHealthStatus.warning:
        return Icons.warning;
      case SystemHealthStatus.critical:
        return Icons.error;
    }
  }

  Color _getResponseTimeColor(double responseTime) {
    if (responseTime < 500) return AppColors.success;
    if (responseTime < 1000) return AppColors.warning;
    return AppColors.error;
  }

  Color _getErrorRateColor(double errorRate) {
    if (errorRate < 1.0) return AppColors.success;
    if (errorRate < 3.0) return AppColors.warning;
    return AppColors.error;
  }

  Color _getCpuUsageColor(double cpuUsage) {
    if (cpuUsage < 50) return AppColors.success;
    if (cpuUsage < 80) return AppColors.warning;
    return AppColors.error;
  }

  Color _getMemoryUsageColor(double memoryUsage) {
    if (memoryUsage < 60) return AppColors.success;
    if (memoryUsage < 85) return AppColors.warning;
    return AppColors.error;
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
