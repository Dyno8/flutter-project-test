import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../domain/entities/notification.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../bloc/notification_state.dart';
import '../widgets/notification_list_item.dart';

/// Screen for displaying user notifications
class NotificationsScreen extends StatefulWidget {
  final String userId;

  const NotificationsScreen({
    super.key,
    required this.userId,
  });

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      // Load more notifications when near bottom
      final state = context.read<NotificationBloc>().state;
      if (state is NotificationsLoaded && state.hasMore) {
        context.read<NotificationBloc>().add(
              LoadUserNotificationsEvent(
                userId: widget.userId,
                lastNotificationId: state.lastNotificationId,
              ),
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<NotificationBloc>()
        ..add(LoadUserNotificationsEvent(userId: widget.userId))
        ..add(StartListeningToNotificationsEvent(userId: widget.userId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Notifications'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'Unread'),
              Tab(text: 'Categories'),
            ],
          ),
          actions: [
            BlocBuilder<NotificationBloc, NotificationState>(
              builder: (context, state) {
                if (state is NotificationsLoaded && state.unreadCount > 0) {
                  return IconButton(
                    onPressed: () {
                      context.read<NotificationBloc>().add(
                            MarkAllNotificationsAsReadEvent(userId: widget.userId),
                          );
                    },
                    icon: const Icon(Icons.mark_email_read),
                    tooltip: 'Mark all as read',
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'refresh':
                    context.read<NotificationBloc>().add(
                          RefreshNotificationsEvent(userId: widget.userId),
                        );
                    break;
                  case 'delete_all':
                    _showDeleteAllDialog();
                    break;
                  case 'settings':
                    // Navigate to notification settings
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'refresh',
                  child: Row(
                    children: [
                      Icon(Icons.refresh),
                      SizedBox(width: 8),
                      Text('Refresh'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete_all',
                  child: Row(
                    children: [
                      Icon(Icons.delete_sweep),
                      SizedBox(width: 8),
                      Text('Delete All'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Icons.settings),
                      SizedBox(width: 8),
                      Text('Settings'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildAllNotificationsTab(),
            _buildUnreadNotificationsTab(),
            _buildCategoriesTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildAllNotificationsTab() {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        if (state is NotificationLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is NotificationError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64.sp,
                  color: Colors.red,
                ),
                SizedBox(height: 16.h),
                Text(
                  'Error loading notifications',
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.h),
                Text(
                  state.message,
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: () {
                    context.read<NotificationBloc>().add(
                          LoadUserNotificationsEvent(userId: widget.userId),
                        );
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is NotificationsLoaded) {
          if (state.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64.sp,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'No notifications yet',
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'You\'ll see notifications here when you receive them',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<NotificationBloc>().add(
                    RefreshNotificationsEvent(userId: widget.userId),
                  );
            },
            child: ListView.builder(
              controller: _scrollController,
              itemCount: state.notifications.length + (state.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == state.notifications.length) {
                  // Loading indicator for pagination
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final notification = state.notifications[index];
                return NotificationListItem(
                  notification: notification,
                  onTap: () => _onNotificationTap(notification),
                  onMarkAsRead: notification.isRead
                      ? null
                      : () => _markAsRead(notification.id),
                  onDelete: () => _deleteNotification(notification.id),
                );
              },
            ),
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildUnreadNotificationsTab() {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        // Similar to all notifications but filtered for unread
        if (state is NotificationsLoaded) {
          final unreadNotifications = state.notifications.where((n) => !n.isRead).toList();
          
          if (unreadNotifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.mark_email_read,
                    size: 64.sp,
                    color: Colors.green,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'All caught up!',
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'You have no unread notifications',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: unreadNotifications.length,
            itemBuilder: (context, index) {
              final notification = unreadNotifications[index];
              return NotificationListItem(
                notification: notification,
                onTap: () => _onNotificationTap(notification),
                onMarkAsRead: () => _markAsRead(notification.id),
                onDelete: () => _deleteNotification(notification.id),
              );
            },
          );
        }

        return _buildAllNotificationsTab(); // Fallback to all notifications
      },
    );
  }

  Widget _buildCategoriesTab() {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        if (state is NotificationsLoaded) {
          final categories = NotificationCategory.values;
          
          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final categoryNotifications = state.notifications
                  .where((n) => n.category == category)
                  .toList();
              
              return ExpansionTile(
                leading: Text(
                  category.icon,
                  style: TextStyle(fontSize: 24.sp),
                ),
                title: Text(
                  category.displayName,
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  '${categoryNotifications.length} notifications',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                ),
                children: categoryNotifications.map((notification) {
                  return NotificationListItem(
                    notification: notification,
                    onTap: () => _onNotificationTap(notification),
                    onMarkAsRead: notification.isRead
                        ? null
                        : () => _markAsRead(notification.id),
                    onDelete: () => _deleteNotification(notification.id),
                    showActions: false,
                  );
                }).toList(),
              );
            },
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  void _onNotificationTap(NotificationEntity notification) {
    if (!notification.isRead) {
      _markAsRead(notification.id);
    }
    
    // Handle navigation based on notification type
    // This would typically navigate to the relevant screen
    // based on the notification data
  }

  void _markAsRead(String notificationId) {
    context.read<NotificationBloc>().add(
          MarkNotificationAsReadEvent(notificationId: notificationId),
        );
  }

  void _deleteNotification(String notificationId) {
    context.read<NotificationBloc>().add(
          DeleteNotificationEvent(notificationId: notificationId),
        );
  }

  void _showDeleteAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Notifications'),
        content: const Text(
          'Are you sure you want to delete all notifications? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<NotificationBloc>().add(
                    DeleteAllNotificationsEvent(userId: widget.userId),
                  );
            },
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }
}
