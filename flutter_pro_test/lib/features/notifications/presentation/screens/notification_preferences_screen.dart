import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../domain/entities/notification.dart';
import '../../domain/entities/notification_preferences.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../bloc/notification_state.dart';

/// Screen for managing notification preferences
class NotificationPreferencesScreen extends StatelessWidget {
  final String userId;

  const NotificationPreferencesScreen({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<NotificationBloc>()
        ..add(LoadNotificationPreferencesEvent(userId: userId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Notification Settings'),
        ),
        body: BlocBuilder<NotificationBloc, NotificationState>(
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
                      'Error loading preferences',
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
                              LoadNotificationPreferencesEvent(userId: userId),
                            );
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is NotificationPreferencesLoaded) {
              return _buildPreferencesContent(context, state.preferences);
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildPreferencesContent(BuildContext context, NotificationPreferences preferences) {
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        // General Settings
        _buildSectionHeader('General Settings'),
        _buildSwitchTile(
          context,
          title: 'Push Notifications',
          subtitle: 'Receive push notifications on this device',
          value: preferences.pushNotificationsEnabled,
          onChanged: (value) {
            final updatedPreferences = preferences.copyWith(
              pushNotificationsEnabled: value,
            );
            context.read<NotificationBloc>().add(
                  UpdateNotificationPreferencesEvent(preferences: updatedPreferences),
                );
          },
        ),
        _buildSwitchTile(
          context,
          title: 'Email Notifications',
          subtitle: 'Receive notifications via email',
          value: preferences.emailNotificationsEnabled,
          onChanged: (value) {
            final updatedPreferences = preferences.copyWith(
              emailNotificationsEnabled: value,
            );
            context.read<NotificationBloc>().add(
                  UpdateNotificationPreferencesEvent(preferences: updatedPreferences),
                );
          },
        ),
        _buildSwitchTile(
          context,
          title: 'SMS Notifications',
          subtitle: 'Receive notifications via SMS',
          value: preferences.smsNotificationsEnabled,
          onChanged: (value) {
            final updatedPreferences = preferences.copyWith(
              smsNotificationsEnabled: value,
            );
            context.read<NotificationBloc>().add(
                  UpdateNotificationPreferencesEvent(preferences: updatedPreferences),
                );
          },
        ),

        SizedBox(height: 24.h),

        // Sound & Vibration
        _buildSectionHeader('Sound & Vibration'),
        _buildSwitchTile(
          context,
          title: 'Sound',
          subtitle: 'Play sound for notifications',
          value: preferences.soundEnabled,
          onChanged: (value) {
            final updatedPreferences = preferences.copyWith(soundEnabled: value);
            context.read<NotificationBloc>().add(
                  UpdateNotificationPreferencesEvent(preferences: updatedPreferences),
                );
          },
        ),
        _buildSwitchTile(
          context,
          title: 'Vibration',
          subtitle: 'Vibrate for notifications',
          value: preferences.vibrationEnabled,
          onChanged: (value) {
            final updatedPreferences = preferences.copyWith(vibrationEnabled: value);
            context.read<NotificationBloc>().add(
                  UpdateNotificationPreferencesEvent(preferences: updatedPreferences),
                );
          },
        ),

        SizedBox(height: 24.h),

        // Privacy Settings
        _buildSectionHeader('Privacy'),
        _buildSwitchTile(
          context,
          title: 'Show on Lock Screen',
          subtitle: 'Display notifications on lock screen',
          value: preferences.showOnLockScreen,
          onChanged: (value) {
            final updatedPreferences = preferences.copyWith(showOnLockScreen: value);
            context.read<NotificationBloc>().add(
                  UpdateNotificationPreferencesEvent(preferences: updatedPreferences),
                );
          },
        ),
        _buildSwitchTile(
          context,
          title: 'Show Preview',
          subtitle: 'Show notification content in preview',
          value: preferences.showPreview,
          onChanged: (value) {
            final updatedPreferences = preferences.copyWith(showPreview: value);
            context.read<NotificationBloc>().add(
                  UpdateNotificationPreferencesEvent(preferences: updatedPreferences),
                );
          },
        ),

        SizedBox(height: 24.h),

        // Quiet Hours
        _buildSectionHeader('Quiet Hours'),
        _buildSwitchTile(
          context,
          title: 'Enable Quiet Hours',
          subtitle: 'Limit notifications during specified hours',
          value: preferences.quietHoursEnabled,
          onChanged: (value) {
            final updatedPreferences = preferences.copyWith(quietHoursEnabled: value);
            context.read<NotificationBloc>().add(
                  UpdateNotificationPreferencesEvent(preferences: updatedPreferences),
                );
          },
        ),
        if (preferences.quietHoursEnabled) ...[
          ListTile(
            title: const Text('Start Time'),
            subtitle: Text(preferences.quietHoursStart ?? '22:00'),
            trailing: const Icon(Icons.access_time),
            onTap: () => _selectTime(
              context,
              preferences.quietHoursStart ?? '22:00',
              (time) {
                final updatedPreferences = preferences.copyWith(quietHoursStart: time);
                context.read<NotificationBloc>().add(
                      UpdateNotificationPreferencesEvent(preferences: updatedPreferences),
                    );
              },
            ),
          ),
          ListTile(
            title: const Text('End Time'),
            subtitle: Text(preferences.quietHoursEnd ?? '08:00'),
            trailing: const Icon(Icons.access_time),
            onTap: () => _selectTime(
              context,
              preferences.quietHoursEnd ?? '08:00',
              (time) {
                final updatedPreferences = preferences.copyWith(quietHoursEnd: time);
                context.read<NotificationBloc>().add(
                      UpdateNotificationPreferencesEvent(preferences: updatedPreferences),
                    );
              },
            ),
          ),
        ],

        SizedBox(height: 24.h),

        // Categories
        _buildSectionHeader('Notification Categories'),
        ...NotificationCategory.values.map((category) {
          return _buildSwitchTile(
            context,
            title: '${category.icon} ${category.displayName}',
            subtitle: _getCategoryDescription(category),
            value: preferences.categoryPreferences[category] ?? true,
            onChanged: (value) {
              context.read<NotificationBloc>().add(
                    ToggleCategoryPreferenceEvent(
                      userId: userId,
                      category: category,
                    ),
                  );
            },
          );
        }),

        SizedBox(height: 24.h),

        // Priority Levels
        _buildSectionHeader('Priority Levels'),
        ...NotificationPriority.values.map((priority) {
          return _buildSwitchTile(
            context,
            title: priority.displayName,
            subtitle: _getPriorityDescription(priority),
            value: preferences.priorityPreferences[priority] ?? true,
            onChanged: (value) {
              context.read<NotificationBloc>().add(
                    TogglePriorityPreferenceEvent(
                      userId: userId,
                      priority: priority,
                    ),
                  );
            },
          );
        }),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(
        title,
        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.blue,
    );
  }

  Future<void> _selectTime(
    BuildContext context,
    String currentTime,
    ValueChanged<String> onTimeSelected,
  ) async {
    final timeParts = currentTime.split(':');
    final initialTime = TimeOfDay(
      hour: int.parse(timeParts[0]),
      minute: int.parse(timeParts[1]),
    );

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (selectedTime != null) {
      final formattedTime = '${selectedTime.hour.toString().padLeft(2, '0')}:'
          '${selectedTime.minute.toString().padLeft(2, '0')}';
      onTimeSelected(formattedTime);
    }
  }

  String _getCategoryDescription(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.booking:
        return 'Booking confirmations, updates, and reminders';
      case NotificationCategory.job:
        return 'New job opportunities and job status updates';
      case NotificationCategory.payment:
        return 'Payment confirmations and earnings updates';
      case NotificationCategory.system:
        return 'App updates and system notifications';
      case NotificationCategory.promotion:
        return 'Special offers and promotional content';
      case NotificationCategory.reminder:
        return 'Scheduled reminders and alerts';
      case NotificationCategory.social:
        return 'Reviews, ratings, and social interactions';
    }
  }

  String _getPriorityDescription(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.low:
        return 'Non-urgent informational notifications';
      case NotificationPriority.normal:
        return 'Standard notifications';
      case NotificationPriority.high:
        return 'Important notifications requiring attention';
      case NotificationPriority.urgent:
        return 'Critical notifications requiring immediate action';
    }
  }
}
