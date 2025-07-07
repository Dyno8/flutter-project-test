import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/notification.dart';

/// Widget for displaying a single notification item in a list
class NotificationListItem extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback? onTap;
  final VoidCallback? onMarkAsRead;
  final VoidCallback? onDelete;
  final bool showActions;

  const NotificationListItem({
    super.key,
    required this.notification,
    this.onTap,
    this.onMarkAsRead,
    this.onDelete,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      elevation: notification.isRead ? 1 : 3,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            border: notification.isRead
                ? null
                : Border.all(
                    color: _getPriorityColor(
                      notification.priority,
                    ).withValues(alpha: 0.3),
                    width: 2,
                  ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with category icon, title, and timestamp
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category icon
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(
                        notification.category,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      notification.category.icon,
                      style: TextStyle(fontSize: 16.sp),
                    ),
                  ),
                  SizedBox(width: 12.w),

                  // Title and timestamp
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: notification.isRead
                                      ? FontWeight.normal
                                      : FontWeight.bold,
                                  color: notification.isRead
                                      ? Colors.grey[600]
                                      : Colors.black87,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (!notification.isRead)
                              Container(
                                width: 8.w,
                                height: 8.w,
                                decoration: BoxDecoration(
                                  color: _getPriorityColor(
                                    notification.priority,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          _formatTimestamp(notification.createdAt),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12.h),

              // Notification body
              Text(
                notification.body,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: notification.isRead
                      ? Colors.grey[600]
                      : Colors.black87,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              // Priority and category badges
              SizedBox(height: 12.h),
              Row(
                children: [
                  // Priority badge
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(
                        notification.priority,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: _getPriorityColor(
                          notification.priority,
                        ).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      notification.priority.displayName,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                        color: _getPriorityColor(notification.priority),
                      ),
                    ),
                  ),

                  SizedBox(width: 8.w),

                  // Category badge
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(
                        notification.category,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: _getCategoryColor(
                          notification.category,
                        ).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      notification.category.displayName,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                        color: _getCategoryColor(notification.category),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Action buttons
                  if (showActions) ...[
                    if (!notification.isRead && onMarkAsRead != null)
                      IconButton(
                        onPressed: onMarkAsRead,
                        icon: Icon(
                          Icons.mark_email_read,
                          size: 20.sp,
                          color: Colors.blue,
                        ),
                        tooltip: 'Mark as read',
                      ),
                    if (onDelete != null)
                      IconButton(
                        onPressed: onDelete,
                        icon: Icon(
                          Icons.delete_outline,
                          size: 20.sp,
                          color: Colors.red,
                        ),
                        tooltip: 'Delete',
                      ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Get color based on notification priority
  Color _getPriorityColor(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.low:
        return Colors.grey;
      case NotificationPriority.normal:
        return Colors.blue;
      case NotificationPriority.high:
        return Colors.orange;
      case NotificationPriority.urgent:
        return Colors.red;
    }
  }

  /// Get color based on notification category
  Color _getCategoryColor(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.booking:
        return Colors.blue;
      case NotificationCategory.job:
        return Colors.green;
      case NotificationCategory.payment:
        return Colors.purple;
      case NotificationCategory.system:
        return Colors.grey;
      case NotificationCategory.promotion:
        return Colors.orange;
      case NotificationCategory.reminder:
        return Colors.amber;
      case NotificationCategory.social:
        return Colors.pink;
    }
  }

  /// Format timestamp for display
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM dd, yyyy').format(timestamp);
    }
  }
}
