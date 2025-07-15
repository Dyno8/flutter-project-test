import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../shared/theme/app_colors.dart';
import '../../../../../shared/widgets/custom_card.dart';

/// Widget for displaying security status in the unified monitoring dashboard
class SecurityStatusWidget extends StatelessWidget {
  final Map<String, dynamic> securityData;
  final bool isCompact;

  const SecurityStatusWidget({
    super.key,
    required this.securityData,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        SizedBox(height: 16.h),
        _buildSecurityOverview(),
        if (!isCompact) ...[
          SizedBox(height: 16.h),
          _buildSecurityAlerts(),
        ],
      ],
    );
  }

  Widget _buildHeader() {
    final monitoringStatus = securityData['monitoring_status'] as Map<String, dynamic>? ?? {};
    final isInitialized = monitoringStatus['initialized'] as bool? ?? false;
    final isActive = monitoringStatus['monitoring_active'] as bool? ?? false;
    final serviceStatus = monitoringStatus['service_status'] as String? ?? 'unknown';
    
    final overallStatus = _getOverallSecurityStatus();
    final statusColor = _getStatusColor(overallStatus);
    final statusIcon = _getStatusIcon(overallStatus);
    final timestamp = securityData['timestamp'] as String?;

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
                  'Security Monitoring',
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
                  _getStatusDescription(overallStatus, isInitialized, isActive),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (timestamp != null) _buildTimestamp(timestamp),
        ],
      ),
    );
  }

  Widget _buildTimestamp(String timestamp) {
    final updateTime = DateTime.tryParse(timestamp);
    if (updateTime == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'Last Check',
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

  Widget _buildSecurityOverview() {
    final monitoringStatus = securityData['monitoring_status'] as Map<String, dynamic>? ?? {};
    final securityAlerts = securityData['security_alerts'] as List? ?? [];
    
    final isInitialized = monitoringStatus['initialized'] as bool? ?? false;
    final isActive = monitoringStatus['monitoring_active'] as bool? ?? false;
    final serviceStatus = monitoringStatus['service_status'] as String? ?? 'unknown';

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isCompact ? 2 : 3,
      childAspectRatio: 1.2,
      crossAxisSpacing: 12.w,
      mainAxisSpacing: 12.h,
      children: [
        _buildStatusCard(
          'Service Status',
          serviceStatus,
          _getServiceStatusIcon(serviceStatus),
          _getStatusColor(serviceStatus),
        ),
        _buildStatusCard(
          'Monitoring',
          isActive ? 'Active' : 'Inactive',
          isActive ? Icons.visibility : Icons.visibility_off,
          isActive ? AppColors.success : AppColors.error,
        ),
        _buildStatusCard(
          'Initialization',
          isInitialized ? 'Ready' : 'Not Ready',
          isInitialized ? Icons.check_circle : Icons.error,
          isInitialized ? AppColors.success : AppColors.error,
        ),
        _buildStatusCard(
          'Security Alerts',
          '${securityAlerts.length}',
          securityAlerts.isEmpty ? Icons.shield : Icons.warning,
          securityAlerts.isEmpty ? AppColors.success : AppColors.warning,
        ),
      ],
    );
  }

  Widget _buildStatusCard(String title, String value, IconData icon, Color color) {
    return CustomCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 24.sp,
          ),
          SizedBox(height: 8.h),
          Text(
            title,
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
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityAlerts() {
    final securityAlerts = securityData['security_alerts'] as List? ?? [];
    
    if (securityAlerts.isEmpty) {
      return CustomCard(
        child: Column(
          children: [
            Icon(
              Icons.shield_outlined,
              size: 48.sp,
              color: AppColors.success,
            ),
            SizedBox(height: 16.h),
            Text(
              'No Security Alerts',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.success,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'All security monitoring systems are operating normally',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning,
                color: AppColors.warning,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Security Alerts (${securityAlerts.length})',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ...securityAlerts.take(5).map((alert) => _buildAlertItem(alert)),
          if (securityAlerts.length > 5) ...[
            SizedBox(height: 8.h),
            Center(
              child: Text(
                '... and ${securityAlerts.length - 5} more alerts',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAlertItem(dynamic alert) {
    if (alert is! Map<String, dynamic>) return const SizedBox.shrink();

    final alertType = alert['alert_type'] as String? ?? 'Unknown';
    final description = alert['description'] as String? ?? '';
    final severity = alert['severity'] as String? ?? 'medium';
    final timestamp = alert['timestamp'] as String?;
    final severityColor = _getSeverityColor(severity);

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Icon(
            Icons.security,
            color: severityColor,
            size: 16.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alertType,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (description.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: severityColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  severity.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: severityColor,
                  ),
                ),
              ),
              if (timestamp != null) ...[
                SizedBox(height: 2.h),
                Text(
                  _formatTime(DateTime.tryParse(timestamp) ?? DateTime.now()),
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // Helper methods
  String _getOverallSecurityStatus() {
    final monitoringStatus = securityData['monitoring_status'] as Map<String, dynamic>? ?? {};
    final securityAlerts = securityData['security_alerts'] as List? ?? [];
    
    final isInitialized = monitoringStatus['initialized'] as bool? ?? false;
    final isActive = monitoringStatus['monitoring_active'] as bool? ?? false;
    final serviceStatus = monitoringStatus['service_status'] as String? ?? 'unknown';

    if (!isInitialized) {
      return 'not_ready';
    } else if (securityAlerts.isNotEmpty) {
      return 'warning';
    } else if (isActive && serviceStatus == 'operational') {
      return 'operational';
    } else {
      return 'inactive';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'operational':
      case 'active':
      case 'ready':
        return AppColors.success;
      case 'warning':
      case 'inactive':
        return AppColors.warning;
      case 'not_ready':
      case 'error':
      case 'failed':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'operational':
      case 'active':
      case 'ready':
        return Icons.shield;
      case 'warning':
      case 'inactive':
        return Icons.warning;
      case 'not_ready':
      case 'error':
      case 'failed':
        return Icons.error;
      default:
        return Icons.help;
    }
  }

  IconData _getServiceStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'operational':
        return Icons.check_circle;
      case 'warning':
        return Icons.warning;
      case 'error':
        return Icons.error;
      default:
        return Icons.help;
    }
  }

  String _getStatusDescription(String status, bool isInitialized, bool isActive) {
    if (!isInitialized) {
      return 'Security monitoring service is not initialized';
    } else if (!isActive) {
      return 'Security monitoring is inactive';
    } else {
      switch (status.toLowerCase()) {
        case 'operational':
          return 'Security monitoring is active and operational';
        case 'warning':
          return 'Security alerts detected - review required';
        case 'error':
          return 'Security monitoring errors detected';
        default:
          return 'Security monitoring status unknown';
      }
    }
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return AppColors.error;
      case 'high':
        return AppColors.warning;
      case 'medium':
        return AppColors.info;
      case 'low':
        return AppColors.textSecondary;
      default:
        return AppColors.textSecondary;
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
      return '${dateTime.day}/${dateTime.month}';
    }
  }
}
