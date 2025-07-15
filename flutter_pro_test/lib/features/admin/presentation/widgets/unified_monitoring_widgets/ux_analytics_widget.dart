import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../shared/theme/app_colors.dart';
import '../../../../../shared/widgets/custom_card.dart';

/// Widget for displaying UX analytics in the unified monitoring dashboard
class UXAnalyticsWidget extends StatelessWidget {
  final Map<String, dynamic> analyticsData;
  final bool isCompact;

  const UXAnalyticsWidget({
    super.key,
    required this.analyticsData,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        SizedBox(height: 16.h),
        _buildAnalyticsOverview(),
        if (!isCompact) ...[
          SizedBox(height: 16.h),
          _buildSessionAnalytics(),
          SizedBox(height: 16.h),
          _buildEngagementMetrics(),
        ],
      ],
    );
  }

  Widget _buildHeader() {
    final timestamp = analyticsData['timestamp'] as String?;
    final hasError = analyticsData.containsKey('error');

    return CustomCard(
      child: Row(
        children: [
          Icon(
            hasError ? Icons.error : Icons.people,
            color: hasError ? AppColors.error : AppColors.primary,
            size: 32.sp,
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'UX Analytics',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  hasError ? 'ERROR' : 'ACTIVE',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: hasError ? AppColors.error : AppColors.success,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  hasError 
                      ? 'Failed to load UX analytics data'
                      : 'User experience monitoring is active',
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

  Widget _buildAnalyticsOverview() {
    if (analyticsData.containsKey('error')) {
      return CustomCard(
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 48.sp,
              color: AppColors.error,
            ),
            SizedBox(height: 16.h),
            Text(
              'UX Analytics Error',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.error,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              analyticsData['error'].toString(),
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

    final sessionAnalytics = analyticsData['session_analytics'] as Map<String, dynamic>? ?? {};
    final engagementMetrics = analyticsData['engagement_metrics'] as Map<String, dynamic>? ?? {};
    final uxMetrics = analyticsData['ux_monitoring_metrics'] as Map<String, dynamic>? ?? {};

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isCompact ? 2 : 4,
      childAspectRatio: 1.2,
      crossAxisSpacing: 12.w,
      mainAxisSpacing: 12.h,
      children: [
        _buildMetricCard(
          'Session Active',
          sessionAnalytics['active'] == true ? 'Yes' : 'No',
          Icons.play_circle,
          sessionAnalytics['active'] == true ? AppColors.success : AppColors.textSecondary,
        ),
        _buildMetricCard(
          'Duration',
          '${sessionAnalytics['duration_seconds'] ?? 0}s',
          Icons.timer,
          AppColors.info,
        ),
        _buildMetricCard(
          'Screens Visited',
          '${sessionAnalytics['screens_visited'] ?? 0}',
          Icons.screen_share,
          AppColors.primary,
        ),
        _buildMetricCard(
          'Interactions',
          '${sessionAnalytics['total_interactions'] ?? 0}',
          Icons.touch_app,
          AppColors.success,
        ),
        _buildMetricCard(
          'Engagement Score',
          '${(engagementMetrics['engagement_score'] as num? ?? 0).toStringAsFixed(1)}%',
          Icons.trending_up,
          _getEngagementColor(engagementMetrics['engagement_score'] as num? ?? 0),
        ),
        _buildMetricCard(
          'Bounce Rate',
          '${(engagementMetrics['bounce_rate'] as num? ?? 0).toStringAsFixed(1)}%',
          Icons.trending_down,
          _getBounceRateColor(engagementMetrics['bounce_rate'] as num? ?? 0),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
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
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6.r),
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

  Widget _buildSessionAnalytics() {
    final sessionAnalytics = analyticsData['session_analytics'] as Map<String, dynamic>? ?? {};
    final navigationAnalytics = analyticsData['navigation_analytics'] as Map<String, dynamic>? ?? {};

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Session Analytics',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          _buildAnalyticsRow('Session ID', sessionAnalytics['session_id']?.toString() ?? 'N/A'),
          _buildAnalyticsRow('Start Time', _formatSessionTime(sessionAnalytics['start_time'])),
          _buildAnalyticsRow('Duration', '${sessionAnalytics['duration_seconds'] ?? 0} seconds'),
          _buildAnalyticsRow('Screens Visited', '${sessionAnalytics['screens_visited'] ?? 0}'),
          _buildAnalyticsRow('Total Interactions', '${sessionAnalytics['total_interactions'] ?? 0}'),
          if (navigationAnalytics.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Text(
              'Navigation Flow',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            _buildAnalyticsRow('Most Visited Screen', navigationAnalytics['most_visited_screen']?.toString() ?? 'N/A'),
            _buildAnalyticsRow('Average Time per Screen', '${navigationAnalytics['avg_time_per_screen'] ?? 0}s'),
          ],
        ],
      ),
    );
  }

  Widget _buildEngagementMetrics() {
    final engagementMetrics = analyticsData['engagement_metrics'] as Map<String, dynamic>? ?? {};
    final feedbackAnalytics = analyticsData['feedback_analytics'] as Map<String, dynamic>? ?? {};

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Engagement Metrics',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          _buildAnalyticsRow('Engagement Score', '${(engagementMetrics['engagement_score'] as num? ?? 0).toStringAsFixed(1)}%'),
          _buildAnalyticsRow('Bounce Rate', '${(engagementMetrics['bounce_rate'] as num? ?? 0).toStringAsFixed(1)}%'),
          _buildAnalyticsRow('Session Quality', engagementMetrics['session_quality']?.toString() ?? 'N/A'),
          _buildAnalyticsRow('User Satisfaction', '${(engagementMetrics['user_satisfaction'] as num? ?? 0).toStringAsFixed(1)}/5'),
          if (feedbackAnalytics.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Text(
              'User Feedback',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            _buildAnalyticsRow('Total Feedback', '${feedbackAnalytics['total_feedback'] ?? 0}'),
            _buildAnalyticsRow('Average Rating', '${(feedbackAnalytics['average_rating'] as num? ?? 0).toStringAsFixed(1)}/5'),
            _buildAnalyticsRow('Positive Feedback', '${(feedbackAnalytics['positive_percentage'] as num? ?? 0).toStringAsFixed(1)}%'),
          ],
        ],
      ),
    );
  }

  Widget _buildAnalyticsRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  Color _getEngagementColor(num score) {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.warning;
    return AppColors.error;
  }

  Color _getBounceRateColor(num rate) {
    if (rate <= 30) return AppColors.success;
    if (rate <= 50) return AppColors.warning;
    return AppColors.error;
  }

  String _formatSessionTime(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    
    final dateTime = DateTime.tryParse(timestamp.toString());
    if (dateTime == null) return 'N/A';
    
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
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
