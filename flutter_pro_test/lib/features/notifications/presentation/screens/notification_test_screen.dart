import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../shared/services/notification_service.dart';
import '../../domain/entities/notification.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../bloc/notification_state.dart';
import 'notifications_screen.dart';
import 'notification_preferences_screen.dart';

/// Test screen for demonstrating notification system functionality
class NotificationTestScreen extends StatefulWidget {
  const NotificationTestScreen({super.key});

  @override
  State<NotificationTestScreen> createState() => _NotificationTestScreenState();
}

class _NotificationTestScreenState extends State<NotificationTestScreen> {
  final String testUserId = 'test_user_123';
  late NotificationService notificationService;

  @override
  void initState() {
    super.initState();
    notificationService = di.sl<NotificationService>();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<NotificationBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Notification System Test'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Text(
                'CareNow Notification System',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                'Test the enhanced notification features',
                style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32.h),

              // Test Notification Buttons
              _buildSectionTitle('Create Test Notifications'),
              SizedBox(height: 16.h),

              _buildTestButton(
                'Booking Notification',
                'Create a high-priority booking notification',
                Colors.blue,
                () => _createTestNotification(
                  title: 'Booking Confirmed! 📅',
                  body:
                      'Your elderly care service has been confirmed for tomorrow at 2:00 PM',
                  type: NotificationTypes.bookingConfirmed,
                  category: NotificationCategory.booking,
                  priority: NotificationPriority.high,
                  data: {
                    'bookingId': 'booking_123',
                    'serviceType': 'elderly_care',
                  },
                ),
              ),

              SizedBox(height: 12.h),

              _buildTestButton(
                'Job Notification',
                'Create an urgent job notification for partners',
                Colors.green,
                () => _createTestNotification(
                  title: 'New Job Available! 💼',
                  body: 'Pet care job near you - Earn \$45 for 3 hours',
                  type: NotificationTypes.newJobAvailable,
                  category: NotificationCategory.job,
                  priority: NotificationPriority.urgent,
                  data: {'jobId': 'job_456', 'earnings': '45', 'duration': '3'},
                ),
              ),

              SizedBox(height: 12.h),

              _buildTestButton(
                'Payment Notification',
                'Create a payment received notification',
                Colors.purple,
                () => _createTestNotification(
                  title: 'Payment Received! 💰',
                  body: 'You received \$75 for your housekeeping service',
                  type: NotificationTypes.paymentReceived,
                  category: NotificationCategory.payment,
                  priority: NotificationPriority.normal,
                  data: {
                    'amount': '75',
                    'currency': 'USD',
                    'serviceType': 'housekeeping',
                  },
                ),
              ),

              SizedBox(height: 12.h),

              _buildTestButton(
                'System Notification',
                'Create a low-priority system notification',
                Colors.grey,
                () => _createTestNotification(
                  title: 'App Update Available 🔄',
                  body:
                      'A new version of CareNow is available with improved features',
                  type: NotificationTypes.appUpdate,
                  category: NotificationCategory.system,
                  priority: NotificationPriority.low,
                  data: {
                    'version': '2.1.0',
                    'features': 'Enhanced notifications',
                  },
                ),
              ),

              SizedBox(height: 32.h),

              // Navigation Buttons
              _buildSectionTitle('Notification Management'),
              SizedBox(height: 16.h),

              _buildNavigationButton(
                'View All Notifications',
                'See all notifications with filtering and management',
                Icons.notifications,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        NotificationsScreen(userId: testUserId),
                  ),
                ),
              ),

              SizedBox(height: 12.h),

              _buildNavigationButton(
                'Notification Settings',
                'Manage notification preferences and quiet hours',
                Icons.settings,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        NotificationPreferencesScreen(userId: testUserId),
                  ),
                ),
              ),

              SizedBox(height: 32.h),

              // Status Display
              BlocBuilder<NotificationBloc, NotificationState>(
                builder: (context, state) {
                  return Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'System Status',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          _getStatusText(state),
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: _getStatusColor(state),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTestButton(
    String title,
    String subtitle,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.all(16.w),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4.h),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButton(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.all(16.w),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        side: BorderSide(color: Colors.blue),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 24.sp),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: Colors.blue, size: 16.sp),
        ],
      ),
    );
  }

  void _createTestNotification({
    required String title,
    required String body,
    required String type,
    required NotificationCategory category,
    required NotificationPriority priority,
    required Map<String, dynamic> data,
  }) {
    context.read<NotificationBloc>().add(
      CreateNotificationEvent(
        userId: testUserId,
        title: title,
        body: body,
        type: type,
        data: {...data, 'userId': testUserId},
        category: category,
        priority: priority,
      ),
    );

    // Also show local notification
    notificationService.sendEnhancedBookingNotification(
      userId: testUserId,
      title: title,
      body: body,
      data: {...data, 'userId': testUserId},
      priority: priority,
    );

    // Show success snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title created successfully!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _getStatusText(NotificationState state) {
    if (state is NotificationLoading) {
      return 'Processing notification...';
    } else if (state is NotificationCreated) {
      return 'Notification created successfully!';
    } else if (state is NotificationError) {
      return 'Error: ${state.message}';
    } else if (state is NotificationsLoaded) {
      return 'Loaded ${state.notifications.length} notifications (${state.unreadCount} unread)';
    } else if (state is NotificationPreferencesLoaded) {
      return 'Preferences loaded successfully';
    } else {
      return 'Notification system ready';
    }
  }

  Color _getStatusColor(NotificationState state) {
    if (state is NotificationLoading) {
      return Colors.orange;
    } else if (state is NotificationCreated) {
      return Colors.green;
    } else if (state is NotificationError) {
      return Colors.red;
    } else {
      return Colors.blue;
    }
  }
}
