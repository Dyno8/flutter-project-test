import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../shared/theme/app_colors.dart';
import '../../../../../shared/widgets/custom_card.dart';

/// Widget for displaying comprehensive system health overview
class SystemHealthOverviewWidget extends StatelessWidget {
  final Map<String, dynamic> healthData;
  final bool isCompact;

  const SystemHealthOverviewWidget({
    super.key,
    required this.healthData,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        SizedBox(height: 16.h),
        _buildHealthChecksGrid(),
        if (!isCompact) ...[
          SizedBox(height: 16.h),
          _buildDetailedHealthInfo(),
        ],
      ],
    );
  }

  Widget _buildHeader() {
    final overallStatus = _getOverallHealthStatus();
    final statusColor = _getStatusColor(overallStatus);
    final statusIcon = _getStatusIcon(overallStatus);

    return CustomCard(
      child: Row(
        children: [
          Icon(
            statusIcon,
            color: statusColor,
            size: 32.sp,
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'System Health Status',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  overallStatus.toUpperCase(),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _getStatusDescription(overallStatus),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          _buildLastUpdateInfo(),
        ],
      ),
    );
  }

  Widget _buildLastUpdateInfo() {
    final timestamp = healthData['timestamp'] as String?;
    if (timestamp == null) return const SizedBox.shrink();

    final updateTime = DateTime.tryParse(timestamp);
    if (updateTime == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'Last Updated',
          style: TextStyle(
            fontSize: 10.sp,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          _formatTime(updateTime),
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildHealthChecksGrid() {
    final productionHealth = healthData['production_health'] as Map<String, dynamic>?;
    final healthCheck = healthData['health_check'] as Map<String, dynamic>?;

    final checks = <String, Map<String, dynamic>>{};

    // Add production health checks
    if (productionHealth != null) {
      final healthChecks = productionHealth['checks'] as Map<String, dynamic>?;
      if (healthChecks != null) {
        checks.addAll(healthChecks.cast<String, Map<String, dynamic>>());
      }
    }

    // Add basic health check
    if (healthCheck != null) {
      checks['overall'] = healthCheck;
    }

    if (checks.isEmpty) {
      return CustomCard(
        child: Center(
          child: Text(
            'No health check data available',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isCompact ? 2 : 3,
        childAspectRatio: 1.5,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
      ),
      itemCount: checks.length,
      itemBuilder: (context, index) {
        final entry = checks.entries.elementAt(index);
        return _buildHealthCheckCard(entry.key, entry.value);
      },
    );
  }

  Widget _buildHealthCheckCard(String checkName, Map<String, dynamic> checkData) {
    final status = checkData['status'] as String? ?? 'unknown';
    final statusColor = _getStatusColor(status);
    final statusIcon = _getStatusIcon(status);

    return CustomCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            statusIcon,
            color: statusColor,
            size: 24.sp,
          ),
          SizedBox(height: 8.h),
          Text(
            _formatCheckName(checkName),
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              status.toUpperCase(),
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedHealthInfo() {
    final productionHealth = healthData['production_health'] as Map<String, dynamic>?;
    if (productionHealth == null) return const SizedBox.shrink();

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detailed Health Information',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          _buildHealthMetrics(productionHealth),
        ],
      ),
    );
  }

  Widget _buildHealthMetrics(Map<String, dynamic> healthData) {
    final checks = healthData['checks'] as Map<String, dynamic>? ?? {};
    
    return Column(
      children: checks.entries.map((entry) {
        final checkName = entry.key;
        final checkData = entry.value as Map<String, dynamic>;
        
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: _buildMetricRow(checkName, checkData),
        );
      }).toList(),
    );
  }

  Widget _buildMetricRow(String name, Map<String, dynamic> data) {
    final status = data['status'] as String? ?? 'unknown';
    final statusColor = _getStatusColor(status);

    return Row(
      children: [
        Container(
          width: 8.w,
          height: 8.h,
          decoration: BoxDecoration(
            color: statusColor,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            _formatCheckName(name),
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Text(
          status.toUpperCase(),
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: statusColor,
          ),
        ),
      ],
    );
  }

  // Helper methods
  String _getOverallHealthStatus() {
    final productionHealth = healthData['production_health'] as Map<String, dynamic>?;
    final healthCheck = healthData['health_check'] as Map<String, dynamic>?;

    // Check production health status
    if (productionHealth != null) {
      final overallStatus = productionHealth['overallStatus'] as String?;
      if (overallStatus != null) {
        return overallStatus;
      }
    }

    // Check basic health check status
    if (healthCheck != null) {
      final status = healthCheck['status'] as String?;
      if (status != null) {
        return status;
      }
    }

    return 'unknown';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'healthy':
      case 'ok':
      case 'passed':
        return AppColors.success;
      case 'warning':
        return AppColors.warning;
      case 'critical':
      case 'error':
      case 'failed':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'healthy':
      case 'ok':
      case 'passed':
        return Icons.check_circle;
      case 'warning':
        return Icons.warning;
      case 'critical':
      case 'error':
      case 'failed':
        return Icons.error;
      default:
        return Icons.help;
    }
  }

  String _getStatusDescription(String status) {
    switch (status.toLowerCase()) {
      case 'healthy':
      case 'ok':
      case 'passed':
        return 'All system components are functioning normally';
      case 'warning':
        return 'Some components need attention';
      case 'critical':
      case 'error':
      case 'failed':
        return 'Critical issues detected - immediate action required';
      default:
        return 'System status is unknown';
    }
  }

  String _formatCheckName(String name) {
    return name
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
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
      return '${dateTime.day}/${dateTime.month} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}
