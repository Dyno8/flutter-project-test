import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/monitoring/alerting_system.dart' as alerting;
import '../../../../../shared/theme/app_colors.dart';
import '../../../../../shared/widgets/custom_card.dart';

/// Widget for displaying alerts summary in the unified monitoring dashboard
class AlertsSummaryWidget extends StatelessWidget {
  final List<alerting.AlertIncident> activeAlerts;
  final bool isCompact;

  const AlertsSummaryWidget({
    super.key,
    required this.activeAlerts,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        SizedBox(height: 16.h),
        if (activeAlerts.isEmpty)
          _buildNoAlertsCard()
        else ...[
          _buildAlertsSummaryCards(),
          if (!isCompact) ...[
            SizedBox(height: 16.h),
            _buildRecentAlertsList(),
          ],
        ],
      ],
    );
  }

  Widget _buildHeader() {
    final criticalCount = activeAlerts
        .where((alert) => alert.severity == alerting.AlertSeverity.critical)
        .length;
    final highCount = activeAlerts
        .where((alert) => alert.severity == alerting.AlertSeverity.high)
        .length;
    final mediumCount = activeAlerts
        .where((alert) => alert.severity == alerting.AlertSeverity.medium)
        .length;

    return CustomCard(
      child: Row(
        children: [
          Icon(
            activeAlerts.isEmpty ? Icons.check_circle : Icons.warning,
            color: activeAlerts.isEmpty ? AppColors.success : AppColors.warning,
            size: 32.sp,
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Active Alerts',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${activeAlerts.length} Total',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: activeAlerts.isEmpty ? AppColors.success : AppColors.warning,
                  ),
                ),
                if (activeAlerts.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    'Critical: $criticalCount • High: $highCount • Medium: $mediumCount',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (activeAlerts.isNotEmpty)
            _buildAlertStatusIndicator(),
        ],
      ),
    );
  }

  Widget _buildAlertStatusIndicator() {
    final hasCritical = activeAlerts
        .any((alert) => alert.severity == alerting.AlertSeverity.critical);
    final hasHigh = activeAlerts
        .any((alert) => alert.severity == alerting.AlertSeverity.high);

    Color indicatorColor;
    String statusText;

    if (hasCritical) {
      indicatorColor = AppColors.error;
      statusText = 'CRITICAL';
    } else if (hasHigh) {
      indicatorColor = AppColors.warning;
      statusText = 'HIGH';
    } else {
      indicatorColor = AppColors.info;
      statusText = 'MEDIUM';
    }

    return Column(
      children: [
        Container(
          width: 12.w,
          height: 12.h,
          decoration: BoxDecoration(
            color: indicatorColor,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          statusText,
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.bold,
            color: indicatorColor,
          ),
        ),
      ],
    );
  }

  Widget _buildNoAlertsCard() {
    return CustomCard(
      child: Column(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 48.sp,
            color: AppColors.success,
          ),
          SizedBox(height: 16.h),
          Text(
            'No Active Alerts',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.success,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'All systems are operating normally',
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

  Widget _buildAlertsSummaryCards() {
    final alertsBySeverity = <alerting.AlertSeverity, List<alerting.AlertIncident>>{};
    
    for (final alert in activeAlerts) {
      alertsBySeverity.putIfAbsent(alert.severity, () => []).add(alert);
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
      itemCount: alertsBySeverity.length,
      itemBuilder: (context, index) {
        final entry = alertsBySeverity.entries.elementAt(index);
        return _buildSeverityCard(entry.key, entry.value);
      },
    );
  }

  Widget _buildSeverityCard(alerting.AlertSeverity severity, List<alerting.AlertIncident> alerts) {
    final severityColor = _getSeverityColor(severity);
    final severityIcon = _getSeverityIcon(severity);
    final severityName = _getSeverityName(severity);

    return CustomCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            severityIcon,
            color: severityColor,
            size: 24.sp,
          ),
          SizedBox(height: 8.h),
          Text(
            severityName,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: severityColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              '${alerts.length}',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: severityColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentAlertsList() {
    final recentAlerts = activeAlerts.take(5).toList();

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Alerts',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          ...recentAlerts.map((alert) => _buildAlertItem(alert)),
          if (activeAlerts.length > 5) ...[
            SizedBox(height: 8.h),
            Center(
              child: Text(
                '... and ${activeAlerts.length - 5} more alerts',
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

  Widget _buildAlertItem(alerting.AlertIncident alert) {
    final severityColor = _getSeverityColor(alert.severity);
    final severityIcon = _getSeverityIcon(alert.severity);

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Icon(
            severityIcon,
            color: severityColor,
            size: 16.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.alertType,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (alert.message.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    alert.message,
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
                  _getSeverityName(alert.severity),
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: severityColor,
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                _formatTime(alert.timestamp),
                style: TextStyle(
                  fontSize: 10.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper methods
  Color _getSeverityColor(alerting.AlertSeverity severity) {
    switch (severity) {
      case alerting.AlertSeverity.critical:
        return AppColors.error;
      case alerting.AlertSeverity.high:
        return AppColors.warning;
      case alerting.AlertSeverity.medium:
        return AppColors.info;
      case alerting.AlertSeverity.low:
        return AppColors.textSecondary;
    }
  }

  IconData _getSeverityIcon(alerting.AlertSeverity severity) {
    switch (severity) {
      case alerting.AlertSeverity.critical:
        return Icons.error;
      case alerting.AlertSeverity.high:
        return Icons.warning;
      case alerting.AlertSeverity.medium:
        return Icons.info;
      case alerting.AlertSeverity.low:
        return Icons.notifications;
    }
  }

  String _getSeverityName(alerting.AlertSeverity severity) {
    switch (severity) {
      case alerting.AlertSeverity.critical:
        return 'Critical';
      case alerting.AlertSeverity.high:
        return 'High';
      case alerting.AlertSeverity.medium:
        return 'Medium';
      case alerting.AlertSeverity.low:
        return 'Low';
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
