import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../shared/theme/app_colors.dart';
import '../../../../../shared/widgets/custom_card.dart';

/// Widget for displaying business metrics overview in the unified monitoring dashboard
class BusinessMetricsOverviewWidget extends StatelessWidget {
  final Map<String, dynamic> metricsData;
  final bool isCompact;

  const BusinessMetricsOverviewWidget({
    super.key,
    required this.metricsData,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        SizedBox(height: 16.h),
        _buildValidationOverview(),
        if (!isCompact) ...[
          SizedBox(height: 16.h),
          _buildValidationChecks(),
        ],
      ],
    );
  }

  Widget _buildHeader() {
    final status = metricsData['status'] as String? ?? 'unknown';
    final overallScore = metricsData['overallScore'] as num? ?? 0;
    final statusColor = _getStatusColor(status);
    final statusIcon = _getStatusIcon(status);
    final timestamp = metricsData['timestamp'] as String?;

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
                  'Business Metrics Validation',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        '${overallScore.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  _getStatusDescription(status, overallScore),
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
          'Last Validation',
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

  Widget _buildValidationOverview() {
    final checks = metricsData['checks'] as Map<String, dynamic>? ?? {};
    
    if (checks.isEmpty) {
      return CustomCard(
        child: Center(
          child: Text(
            'No business metrics validation data available',
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
      itemCount: checks.length,
      itemBuilder: (context, index) {
        final entry = checks.entries.elementAt(index);
        return _buildValidationCard(entry.key, entry.value);
      },
    );
  }

  Widget _buildValidationCard(String checkName, dynamic checkData) {
    if (checkData is! Map<String, dynamic>) {
      return const SizedBox.shrink();
    }

    final passed = checkData['passed'] as bool? ?? false;
    final score = checkData['score'] as num? ?? 0;
    final statusColor = passed ? AppColors.success : AppColors.error;
    final statusIcon = passed ? Icons.check_circle : Icons.error;

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
          Text(
            '${score.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
          SizedBox(height: 4.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(
              passed ? 'PASSED' : 'FAILED',
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

  Widget _buildValidationChecks() {
    final checks = metricsData['checks'] as Map<String, dynamic>? ?? {};
    
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Validation Check Details',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          ...checks.entries.map((entry) {
            final checkData = entry.value as Map<String, dynamic>;
            return _buildCheckDetailRow(entry.key, checkData);
          }),
        ],
      ),
    );
  }

  Widget _buildCheckDetailRow(String checkName, Map<String, dynamic> data) {
    final passed = data['passed'] as bool? ?? false;
    final score = data['score'] as num? ?? 0;
    final issues = data['issues'] as List? ?? [];
    final recommendations = data['recommendations'] as List? ?? [];
    final statusColor = passed ? AppColors.success : AppColors.error;

    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                  _formatCheckName(checkName),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  '${score.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          if (issues.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.only(left: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Issues:',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  ...issues.take(3).map((issue) => Padding(
                    padding: EdgeInsets.only(bottom: 2.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '• ',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.error,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            issue.toString(),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                  if (issues.length > 3)
                    Text(
                      '... and ${issues.length - 3} more issues',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
          ],
          if (recommendations.isNotEmpty && !passed) ...[
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.only(left: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recommendations:',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.info,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  ...recommendations.take(2).map((recommendation) => Padding(
                    padding: EdgeInsets.only(bottom: 2.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '• ',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.info,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            recommendation.toString(),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ],
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
        return Icons.analytics;
      case 'warning':
        return Icons.warning;
      case 'failed':
      case 'critical':
        return Icons.error;
      default:
        return Icons.help;
    }
  }

  String _getStatusDescription(String status, num score) {
    if (score >= 90) {
      return 'Excellent business metrics validation performance';
    } else if (score >= 70) {
      return 'Good business metrics validation with minor issues';
    } else if (score >= 50) {
      return 'Fair business metrics validation - improvements needed';
    } else {
      return 'Poor business metrics validation - immediate attention required';
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
