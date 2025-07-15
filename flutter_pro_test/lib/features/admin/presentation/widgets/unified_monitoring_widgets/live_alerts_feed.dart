import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/monitoring/alerting_system.dart' as alerting;
import '../../../../../shared/theme/app_colors.dart';
import '../../../../../shared/widgets/custom_card.dart';

/// Live alerts feed widget with real-time updates and animations
class LiveAlertsFeed extends StatefulWidget {
  final List<alerting.AlertIncident> alerts;
  final int maxDisplayCount;
  final bool showTimestamp;
  final VoidCallback? onViewAll;

  const LiveAlertsFeed({
    super.key,
    required this.alerts,
    this.maxDisplayCount = 5,
    this.showTimestamp = true,
    this.onViewAll,
  });

  @override
  State<LiveAlertsFeed> createState() => _LiveAlertsFeedState();
}

class _LiveAlertsFeedState extends State<LiveAlertsFeed>
    with TickerProviderStateMixin {
  final List<AnimationController> _slideControllers = [];
  final List<Animation<Offset>> _slideAnimations = [];
  List<alerting.AlertIncident> _previousAlerts = [];

  @override
  void initState() {
    super.initState();
    _previousAlerts = List.from(widget.alerts);
    _setupAnimations();
  }

  @override
  void didUpdateWidget(LiveAlertsFeed oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.alerts != widget.alerts) {
      _handleAlertsUpdate(oldWidget.alerts);
    }
  }

  void _setupAnimations() {
    _disposeAnimations();
    
    final displayAlerts = widget.alerts.take(widget.maxDisplayCount).toList();
    
    for (int i = 0; i < displayAlerts.length; i++) {
      final controller = AnimationController(
        duration: Duration(milliseconds: 300 + (i * 100)),
        vsync: this,
      );
      
      final animation = Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutCubic,
      ));

      _slideControllers.add(controller);
      _slideAnimations.add(animation);
      
      // Stagger the animations
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted) {
          controller.forward();
        }
      });
    }
  }

  void _handleAlertsUpdate(List<alerting.AlertIncident> oldAlerts) {
    final newAlerts = widget.alerts.where((alert) => 
        !oldAlerts.any((old) => old.id == alert.id)).toList();
    
    if (newAlerts.isNotEmpty) {
      _setupAnimations();
    }
    
    _previousAlerts = List.from(widget.alerts);
  }

  void _disposeAnimations() {
    for (final controller in _slideControllers) {
      controller.dispose();
    }
    _slideControllers.clear();
    _slideAnimations.clear();
  }

  @override
  void dispose() {
    _disposeAnimations();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: 16.h),
          if (widget.alerts.isEmpty)
            _buildEmptyState()
          else
            _buildAlertsList(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          Icons.notifications_active,
          color: widget.alerts.isEmpty ? AppColors.success : AppColors.warning,
          size: 20.sp,
        ),
        SizedBox(width: 8.w),
        Text(
          'Live Alerts Feed',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        if (widget.alerts.isNotEmpty) ...[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(
              '${widget.alerts.length}',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.error,
              ),
            ),
          ),
          SizedBox(width: 8.w),
        ],
        if (widget.onViewAll != null)
          TextButton(
            onPressed: widget.onViewAll,
            child: Text(
              'View All',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.primary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      child: Column(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 48.sp,
            color: AppColors.success,
          ),
          SizedBox(height: 12.h),
          Text(
            'No Active Alerts',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.success,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'All systems are operating normally',
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

  Widget _buildAlertsList() {
    final displayAlerts = widget.alerts.take(widget.maxDisplayCount).toList();
    
    return Column(
      children: [
        ...displayAlerts.asMap().entries.map((entry) {
          final index = entry.key;
          final alert = entry.value;
          
          if (index < _slideAnimations.length) {
            return SlideTransition(
              position: _slideAnimations[index],
              child: _buildAlertItem(alert, index),
            );
          } else {
            return _buildAlertItem(alert, index);
          }
        }),
        if (widget.alerts.length > widget.maxDisplayCount) ...[
          SizedBox(height: 8.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              '... and ${widget.alerts.length - widget.maxDisplayCount} more alerts',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAlertItem(alerting.AlertIncident alert, int index) {
    final severityColor = _getSeverityColor(alert.severity);
    final severityIcon = _getSeverityIcon(alert.severity);
    final isNew = _isNewAlert(alert);

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: isNew ? severityColor.withValues(alpha: 0.05) : Colors.transparent,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: severityColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
        leading: _buildAlertIcon(severityIcon, severityColor, isNew),
        title: Text(
          alert.alertType,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            if (widget.showTimestamp) ...[
              SizedBox(height: 4.h),
              Text(
                _formatTimestamp(alert.timestamp),
                style: TextStyle(
                  fontSize: 10.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
        trailing: _buildSeverityBadge(alert.severity, severityColor),
      ),
    );
  }

  Widget _buildAlertIcon(IconData icon, Color color, bool isNew) {
    if (isNew) {
      return TweenAnimationBuilder<double>(
        duration: const Duration(seconds: 2),
        tween: Tween(begin: 0.5, end: 1.0),
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 16.sp,
                color: color,
              ),
            ),
          );
        },
      );
    } else {
      return Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 16.sp,
          color: color,
        ),
      );
    }
  }

  Widget _buildSeverityBadge(alerting.AlertSeverity severity, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        _getSeverityName(severity),
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  bool _isNewAlert(alerting.AlertIncident alert) {
    return !_previousAlerts.any((prev) => prev.id == alert.id);
  }

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
        return 'CRITICAL';
      case alerting.AlertSeverity.high:
        return 'HIGH';
      case alerting.AlertSeverity.medium:
        return 'MEDIUM';
      case alerting.AlertSeverity.low:
        return 'LOW';
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.day}/${timestamp.month} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}
