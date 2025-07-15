import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../shared/theme/app_colors.dart';
import '../../../../../shared/widgets/custom_card.dart';

/// Widget for displaying performance metrics in the unified monitoring dashboard
class PerformanceMetricsWidget extends StatelessWidget {
  final Map<String, dynamic> performanceData;
  final bool isCompact;

  const PerformanceMetricsWidget({
    super.key,
    required this.performanceData,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        SizedBox(height: 16.h),
        _buildPerformanceOverview(),
        if (!isCompact) ...[
          SizedBox(height: 16.h),
          _buildValidationDetails(),
          SizedBox(height: 16.h),
          _buildViolations(),
        ],
      ],
    );
  }

  Widget _buildHeader() {
    final overallStatus = performanceData['overallStatus'] as String? ?? 'unknown';
    final statusColor = _getStatusColor(overallStatus);
    final statusIcon = _getStatusIcon(overallStatus);
    final timestamp = performanceData['timestamp'] as String?;

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
                  'Performance Metrics',
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

  Widget _buildPerformanceOverview() {
    final validations = performanceData['validations'] as Map<String, dynamic>? ?? {};
    
    if (validations.isEmpty) {
      return CustomCard(
        child: Center(
          child: Text(
            'No performance validation data available',
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
        childAspectRatio: 1.2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
      ),
      itemCount: validations.length,
      itemBuilder: (context, index) {
        final entry = validations.entries.elementAt(index);
        return _buildValidationCard(entry.key, entry.value);
      },
    );
  }

  Widget _buildValidationCard(String metricName, dynamic validationData) {
    if (validationData is! Map<String, dynamic>) {
      return const SizedBox.shrink();
    }

    final status = validationData['status'] as String? ?? 'unknown';
    final currentValue = validationData['currentValue'] as num? ?? 0;
    final threshold = validationData['threshold'] as num? ?? 0;
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
            _formatMetricName(metricName),
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
          Text(
            _formatMetricValue(metricName, currentValue),
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
          if (threshold > 0) ...[
            SizedBox(height: 2.h),
            Text(
              'Limit: ${_formatMetricValue(metricName, threshold)}',
              style: TextStyle(
                fontSize: 10.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          SizedBox(height: 4.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6.r),
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

  Widget _buildValidationDetails() {
    final validations = performanceData['validations'] as Map<String, dynamic>? ?? {};
    
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Validation Details',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          ...validations.entries.map((entry) {
            final validationData = entry.value as Map<String, dynamic>;
            return _buildValidationDetailRow(entry.key, validationData);
          }),
        ],
      ),
    );
  }

  Widget _buildValidationDetailRow(String metricName, Map<String, dynamic> data) {
    final status = data['status'] as String? ?? 'unknown';
    final message = data['message'] as String? ?? '';
    final statusColor = _getStatusColor(status);

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8.w,
            height: 8.h,
            margin: EdgeInsets.only(top: 6.h),
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatMetricName(metricName),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (message.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6.r),
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

  Widget _buildViolations() {
    final violations = performanceData['violations'] as List? ?? [];
    
    if (violations.isEmpty) {
      return CustomCard(
        child: Column(
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 32.sp,
              color: AppColors.success,
            ),
            SizedBox(height: 8.h),
            Text(
              'No Performance Violations',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.success,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'All performance metrics are within acceptable limits',
              style: TextStyle(
                fontSize: 12.sp,
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
                color: AppColors.error,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Performance Violations (${violations.length})',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ...violations.take(5).map((violation) => _buildViolationItem(violation)),
          if (violations.length > 5) ...[
            SizedBox(height: 8.h),
            Center(
              child: Text(
                '... and ${violations.length - 5} more violations',
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

  Widget _buildViolationItem(dynamic violation) {
    if (violation is! Map<String, dynamic>) return const SizedBox.shrink();

    final metric = violation['metric'] as String? ?? '';
    final message = violation['message'] as String? ?? '';
    final severity = violation['severity'] as String? ?? 'medium';
    final severityColor = _getSeverityColor(severity);

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: severityColor,
            size: 16.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatMetricName(metric),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (message.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: severityColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              severity.toUpperCase(),
              style: TextStyle(
                fontSize: 9.sp,
                fontWeight: FontWeight.bold,
                color: severityColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'passed':
      case 'healthy':
        return AppColors.success;
      case 'warning':
        return AppColors.warning;
      case 'failed':
      case 'critical':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'passed':
      case 'healthy':
        return Icons.check_circle;
      case 'warning':
        return Icons.warning;
      case 'failed':
      case 'critical':
        return Icons.error;
      default:
        return Icons.help;
    }
  }

  String _getStatusDescription(String status) {
    switch (status.toLowerCase()) {
      case 'passed':
        return 'All performance metrics are within acceptable limits';
      case 'warning':
        return 'Some performance metrics need attention';
      case 'failed':
        return 'Performance issues detected - optimization required';
      default:
        return 'Performance status unknown';
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

  String _formatMetricName(String name) {
    return name
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String _formatMetricValue(String metricName, num value) {
    if (metricName.contains('time') || metricName.contains('response')) {
      return '${value.toStringAsFixed(0)}ms';
    } else if (metricName.contains('memory')) {
      return '${(value / (1024 * 1024)).toStringAsFixed(1)}MB';
    } else if (metricName.contains('rate')) {
      return '${(value * 100).toStringAsFixed(1)}%';
    } else {
      return value.toString();
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
      return '${dateTime.day}/${dateTime.month} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}
