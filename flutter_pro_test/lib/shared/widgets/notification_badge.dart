import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../services/realtime_notification_service.dart';
import '../../core/di/injection_container.dart' as di;

/// Widget that displays a notification badge with real-time unread count
class NotificationBadge extends StatefulWidget {
  final Widget child;
  final bool showBadge;
  final Color? badgeColor;
  final Color? textColor;
  final double? badgeSize;
  final VoidCallback? onTap;

  const NotificationBadge({
    super.key,
    required this.child,
    this.showBadge = true,
    this.badgeColor,
    this.textColor,
    this.badgeSize,
    this.onTap,
  });

  @override
  State<NotificationBadge> createState() => _NotificationBadgeState();
}

class _NotificationBadgeState extends State<NotificationBadge> {
  late final RealtimeNotificationService _realtimeService;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _realtimeService = di.sl<RealtimeNotificationService>();
    _setupRealtimeListener();
  }

  void _setupRealtimeListener() {
    // Listen to unread count changes
    _realtimeService.unreadCountStream.listen((count) {
      if (mounted) {
        setState(() {
          _unreadCount = count;
        });
      }
    });

    // Initialize for current user if authenticated
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _realtimeService.initializeForUser(authState.user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // Initialize real-time service for authenticated user
          _realtimeService.initializeForUser(state.user.uid);
        } else if (state is AuthUnauthenticated) {
          // Stop listening when user logs out
          _realtimeService.stopListening();
          setState(() {
            _unreadCount = 0;
          });
        }
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            widget.child,
            if (widget.showBadge && _unreadCount > 0)
              Positioned(
                right: -6.w,
                top: -6.h,
                child: Container(
                  width: widget.badgeSize ?? 18.w,
                  height: widget.badgeSize ?? 18.h,
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  decoration: BoxDecoration(
                    color: widget.badgeColor ?? Colors.red,
                    borderRadius: BorderRadius.circular(9.r),
                    border: Border.all(color: Colors.white, width: 1.w),
                  ),
                  child: Center(
                    child: Text(
                      _unreadCount > 99 ? '99+' : _unreadCount.toString(),
                      style: TextStyle(
                        color: widget.textColor ?? Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Widget that shows a notification icon with badge
class NotificationIconWithBadge extends StatelessWidget {
  final IconData icon;
  final double? size;
  final Color? color;
  final Color? badgeColor;
  final VoidCallback? onTap;

  const NotificationIconWithBadge({
    super.key,
    this.icon = Icons.notifications,
    this.size,
    this.color,
    this.badgeColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationBadge(
      badgeColor: badgeColor,
      onTap: onTap,
      child: Icon(
        icon,
        size: size ?? 24.sp,
        color: color ?? Theme.of(context).iconTheme.color,
      ),
    );
  }
}

/// Widget that displays real-time notification updates as snackbars or overlays
class NotificationListener extends StatefulWidget {
  final Widget child;
  final bool showSnackbars;
  final bool showOverlays;

  const NotificationListener({
    super.key,
    required this.child,
    this.showSnackbars = true,
    this.showOverlays = false,
  });

  @override
  State<NotificationListener> createState() => _NotificationListenerState();
}

class _NotificationListenerState extends State<NotificationListener> {
  late final RealtimeNotificationService _realtimeService;

  @override
  void initState() {
    super.initState();
    _realtimeService = di.sl<RealtimeNotificationService>();
    _setupNotificationListener();
  }

  void _setupNotificationListener() {
    // Listen to new notifications
    _realtimeService.newNotificationStream.listen((notification) {
      if (mounted) {
        if (widget.showSnackbars) {
          _showNotificationSnackbar(notification);
        }
        if (widget.showOverlays) {
          _showNotificationOverlay(notification);
        }
      }
    });
  }

  void _showNotificationSnackbar(notification) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
            ),
            SizedBox(height: 4.h),
            Text(notification.body, style: TextStyle(fontSize: 12.sp)),
          ],
        ),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'View',
          onPressed: () {
            // Navigate to notification details
            // This could use the NotificationActionHandler
          },
        ),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16.w),
      ),
    );
  }

  void _showNotificationOverlay(notification) {
    // Implementation for overlay notifications
    // This could show a custom overlay widget
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: Text(notification.title),
        content: Text(notification.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Dismiss'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to notification details
            },
            child: const Text('View'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Mixin for widgets that need notification functionality
mixin NotificationMixin<T extends StatefulWidget> on State<T> {
  late final RealtimeNotificationService realtimeNotificationService;

  @override
  void initState() {
    super.initState();
    realtimeNotificationService = di.sl<RealtimeNotificationService>();
  }

  /// Get current unread notification count
  Future<int> getUnreadNotificationCount() async {
    final result = await realtimeNotificationService.getCurrentUnreadCount();
    return result.fold((failure) => 0, (count) => count);
  }

  /// Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    await realtimeNotificationService.markNotificationAsRead(notificationId);
  }

  /// Mark all notifications as read
  Future<void> markAllNotificationsAsRead() async {
    await realtimeNotificationService.markAllNotificationsAsRead();
  }
}
