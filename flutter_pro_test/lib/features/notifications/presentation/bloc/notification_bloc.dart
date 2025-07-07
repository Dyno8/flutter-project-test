import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_user_notifications.dart';
import '../../domain/usecases/get_unread_notifications.dart';
import '../../domain/usecases/mark_notification_as_read.dart';
import '../../domain/usecases/create_notification.dart';
import '../../domain/usecases/send_push_notification.dart';
import '../../domain/usecases/get_notification_preferences.dart';
import '../../domain/usecases/update_notification_preferences.dart';
import '../../domain/repositories/notification_repository.dart';

import 'notification_event.dart';
import 'notification_state.dart';

/// BLoC for managing notification state and operations
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetUserNotifications _getUserNotifications;
  final GetUnreadNotifications _getUnreadNotifications;
  final MarkNotificationAsRead _markNotificationAsRead;
  final CreateNotification _createNotification;
  final SendPushNotification _sendPushNotification;
  final GetNotificationPreferences _getNotificationPreferences;
  final UpdateNotificationPreferences _updateNotificationPreferences;
  final NotificationRepository _repository;

  // Stream subscriptions for real-time updates
  StreamSubscription? _notificationsSubscription;
  StreamSubscription? _unreadCountSubscription;

  NotificationBloc({
    required GetUserNotifications getUserNotifications,
    required GetUnreadNotifications getUnreadNotifications,
    required MarkNotificationAsRead markNotificationAsRead,
    required CreateNotification createNotification,
    required SendPushNotification sendPushNotification,
    required GetNotificationPreferences getNotificationPreferences,
    required UpdateNotificationPreferences updateNotificationPreferences,
    required NotificationRepository repository,
  }) : _getUserNotifications = getUserNotifications,
       _getUnreadNotifications = getUnreadNotifications,
       _markNotificationAsRead = markNotificationAsRead,
       _createNotification = createNotification,
       _sendPushNotification = sendPushNotification,
       _getNotificationPreferences = getNotificationPreferences,
       _updateNotificationPreferences = updateNotificationPreferences,
       _repository = repository,
       super(const NotificationInitial()) {
    // Register event handlers
    on<LoadUserNotificationsEvent>(_onLoadUserNotifications);
    on<LoadUnreadNotificationsEvent>(_onLoadUnreadNotifications);
    on<LoadNotificationsByCategoryEvent>(_onLoadNotificationsByCategory);
    on<LoadNotificationsByTypeEvent>(_onLoadNotificationsByType);
    on<RefreshNotificationsEvent>(_onRefreshNotifications);

    on<MarkNotificationAsReadEvent>(_onMarkNotificationAsRead);
    on<MarkAllNotificationsAsReadEvent>(_onMarkAllNotificationsAsRead);
    on<DeleteNotificationEvent>(_onDeleteNotification);
    on<DeleteAllNotificationsEvent>(_onDeleteAllNotifications);
    on<CreateNotificationEvent>(_onCreateNotification);

    on<StartListeningToNotificationsEvent>(_onStartListeningToNotifications);
    on<StopListeningToNotificationsEvent>(_onStopListeningToNotifications);
    on<NotificationsUpdatedEvent>(_onNotificationsUpdated);
    on<UnreadCountUpdatedEvent>(_onUnreadCountUpdated);

    on<SendPushNotificationEvent>(_onSendPushNotification);
    on<SendBulkPushNotificationEvent>(_onSendBulkPushNotification);

    on<ScheduleNotificationEvent>(_onScheduleNotification);
    on<CancelScheduledNotificationEvent>(_onCancelScheduledNotification);
    on<LoadScheduledNotificationsEvent>(_onLoadScheduledNotifications);

    on<LoadNotificationPreferencesEvent>(_onLoadNotificationPreferences);
    on<UpdateNotificationPreferencesEvent>(_onUpdateNotificationPreferences);
    on<ToggleCategoryPreferenceEvent>(_onToggleCategoryPreference);
    on<TogglePriorityPreferenceEvent>(_onTogglePriorityPreference);
    on<SetQuietHoursEvent>(_onSetQuietHours);

    on<LoadNotificationStatsEvent>(_onLoadNotificationStats);

    on<ClearNotificationErrorEvent>(_onClearError);
    on<RetryNotificationOperationEvent>(_onRetryOperation);
  }

  @override
  Future<void> close() {
    _notificationsSubscription?.cancel();
    _unreadCountSubscription?.cancel();
    return super.close();
  }

  /// Load user notifications
  Future<void> _onLoadUserNotifications(
    LoadUserNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationLoading());

    final result = await _getUserNotifications(
      GetUserNotificationsParams(
        userId: event.userId,
        limit: event.limit,
        lastNotificationId: event.lastNotificationId,
      ),
    );

    await result.fold(
      (failure) async => emit(NotificationError(message: failure.message)),
      (notifications) async {
        // Also get unread count
        final unreadResult = await _repository.getUnreadCount(event.userId);
        final unreadCount = unreadResult.fold((l) => 0, (count) => count);

        emit(
          NotificationsLoaded(
            notifications: notifications,
            unreadCount: unreadCount,
            hasMore: notifications.length >= (event.limit ?? 20),
            lastNotificationId: notifications.isNotEmpty
                ? notifications.last.id
                : null,
          ),
        );
      },
    );
  }

  /// Load unread notifications
  Future<void> _onLoadUnreadNotifications(
    LoadUnreadNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationLoading());

    final result = await _getUnreadNotifications(
      GetUnreadNotificationsParams(userId: event.userId),
    );

    result.fold(
      (failure) => emit(NotificationError(message: failure.message)),
      (notifications) => emit(
        UnreadNotificationsLoaded(
          unreadNotifications: notifications,
          count: notifications.length,
        ),
      ),
    );
  }

  /// Load notifications by category
  Future<void> _onLoadNotificationsByCategory(
    LoadNotificationsByCategoryEvent event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationLoading());

    final result = await _repository.getNotificationsByCategory(
      event.userId,
      event.category,
      limit: event.limit,
    );

    result.fold(
      (failure) => emit(NotificationError(message: failure.message)),
      (notifications) => emit(
        NotificationsByCategoryLoaded(
          notifications: notifications,
          category: event.category,
        ),
      ),
    );
  }

  /// Load notifications by type
  Future<void> _onLoadNotificationsByType(
    LoadNotificationsByTypeEvent event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationLoading());

    final result = await _repository.getNotificationsByType(
      event.userId,
      event.type,
      limit: event.limit,
    );

    result.fold(
      (failure) => emit(NotificationError(message: failure.message)),
      (notifications) => emit(
        NotificationsByTypeLoaded(
          notifications: notifications,
          type: event.type,
        ),
      ),
    );
  }

  /// Refresh notifications
  Future<void> _onRefreshNotifications(
    RefreshNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    // Don't show loading state for refresh
    final result = await _getUserNotifications(
      GetUserNotificationsParams(userId: event.userId),
    );

    await result.fold(
      (failure) async => emit(NotificationError(message: failure.message)),
      (notifications) async {
        final unreadResult = await _repository.getUnreadCount(event.userId);
        final unreadCount = unreadResult.fold((l) => 0, (count) => count);

        emit(
          NotificationsLoaded(
            notifications: notifications,
            unreadCount: unreadCount,
            hasMore: notifications.length >= 20,
            lastNotificationId: notifications.isNotEmpty
                ? notifications.last.id
                : null,
          ),
        );
      },
    );
  }

  /// Mark notification as read
  Future<void> _onMarkNotificationAsRead(
    MarkNotificationAsReadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await _markNotificationAsRead(
      MarkNotificationAsReadParams(notificationId: event.notificationId),
    );

    result.fold(
      (failure) => emit(NotificationError(message: failure.message)),
      (notification) {
        emit(NotificationMarkedAsRead(notification: notification));

        // Update current state if it's NotificationsLoaded
        if (state is NotificationsLoaded) {
          final currentState = state as NotificationsLoaded;
          emit(currentState.updateNotification(notification));
        }
      },
    );
  }

  /// Mark all notifications as read
  Future<void> _onMarkAllNotificationsAsRead(
    MarkAllNotificationsAsReadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await _repository.markAllAsRead(event.userId);

    result.fold(
      (failure) => emit(NotificationError(message: failure.message)),
      (_) {
        emit(const AllNotificationsMarkedAsRead());

        // Update current state if it's NotificationsLoaded
        if (state is NotificationsLoaded) {
          final currentState = state as NotificationsLoaded;
          emit(currentState.markAllAsRead());
        }
      },
    );
  }

  /// Delete notification
  Future<void> _onDeleteNotification(
    DeleteNotificationEvent event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await _repository.deleteNotification(event.notificationId);

    result.fold(
      (failure) => emit(NotificationError(message: failure.message)),
      (_) {
        emit(NotificationDeleted(notificationId: event.notificationId));

        // Update current state if it's NotificationsLoaded
        if (state is NotificationsLoaded) {
          final currentState = state as NotificationsLoaded;
          emit(currentState.removeNotification(event.notificationId));
        }
      },
    );
  }

  /// Delete all notifications
  Future<void> _onDeleteAllNotifications(
    DeleteAllNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await _repository.deleteAllNotifications(event.userId);

    result.fold(
      (failure) => emit(NotificationError(message: failure.message)),
      (_) => emit(const AllNotificationsDeleted()),
    );
  }

  /// Create notification
  Future<void> _onCreateNotification(
    CreateNotificationEvent event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await _createNotification(
      CreateNotificationParams(
        userId: event.userId,
        title: event.title,
        body: event.body,
        type: event.type,
        data: event.data,
        priority: event.priority,
        category: event.category,
        imageUrl: event.imageUrl,
        actionUrl: event.actionUrl,
        isPersistent: event.isPersistent,
      ),
    );

    result.fold(
      (failure) => emit(NotificationError(message: failure.message)),
      (notification) => emit(NotificationCreated(notification: notification)),
    );
  }

  /// Start listening to real-time notifications
  Future<void> _onStartListeningToNotifications(
    StartListeningToNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    // Cancel existing subscriptions
    await _notificationsSubscription?.cancel();
    await _unreadCountSubscription?.cancel();

    emit(NotificationListeningStarted(userId: event.userId));

    // Listen to notifications
    _notificationsSubscription = _repository
        .listenToUserNotifications(event.userId)
        .listen((result) {
          result.fold(
            (failure) => add(const ClearNotificationErrorEvent()),
            (notifications) =>
                add(NotificationsUpdatedEvent(notifications: notifications)),
          );
        });

    // Listen to unread count
    _unreadCountSubscription = _repository
        .listenToUnreadCount(event.userId)
        .listen((result) {
          result.fold(
            (failure) => add(const ClearNotificationErrorEvent()),
            (count) => add(UnreadCountUpdatedEvent(count: count)),
          );
        });
  }

  /// Stop listening to real-time notifications
  Future<void> _onStopListeningToNotifications(
    StopListeningToNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    await _notificationsSubscription?.cancel();
    await _unreadCountSubscription?.cancel();
    _notificationsSubscription = null;
    _unreadCountSubscription = null;

    emit(const NotificationListeningStopped());
  }

  /// Handle real-time notifications update
  void _onNotificationsUpdated(
    NotificationsUpdatedEvent event,
    Emitter<NotificationState> emit,
  ) {
    final unreadCount = event.notifications.where((n) => !n.isRead).length;
    emit(
      NotificationRealTimeUpdated(
        notifications: event.notifications,
        unreadCount: unreadCount,
      ),
    );
  }

  /// Handle unread count update
  void _onUnreadCountUpdated(
    UnreadCountUpdatedEvent event,
    Emitter<NotificationState> emit,
  ) {
    emit(NotificationUnreadCountUpdated(count: event.count));
  }

  /// Send push notification
  Future<void> _onSendPushNotification(
    SendPushNotificationEvent event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await _sendPushNotification(
      SendPushNotificationParams(
        userId: event.userId,
        title: event.title,
        body: event.body,
        data: event.data,
        imageUrl: event.imageUrl,
      ),
    );

    result.fold(
      (failure) => emit(NotificationError(message: failure.message)),
      (_) => emit(const PushNotificationSent()),
    );
  }

  /// Send bulk push notification
  Future<void> _onSendBulkPushNotification(
    SendBulkPushNotificationEvent event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await _repository.sendBulkPushNotification(
      userIds: event.userIds,
      title: event.title,
      body: event.body,
      data: event.data,
      imageUrl: event.imageUrl,
    );

    result.fold(
      (failure) => emit(NotificationError(message: failure.message)),
      (_) => emit(const BulkPushNotificationSent()),
    );
  }

  /// Schedule notification
  Future<void> _onScheduleNotification(
    ScheduleNotificationEvent event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await _repository.scheduleNotification(
      userId: event.userId,
      title: event.title,
      body: event.body,
      scheduledAt: event.scheduledAt,
      type: event.type,
      data: event.data,
      priority: event.priority,
      category: event.category,
    );

    result.fold(
      (failure) => emit(NotificationError(message: failure.message)),
      (notification) => emit(NotificationScheduled(notification: notification)),
    );
  }

  /// Cancel scheduled notification
  Future<void> _onCancelScheduledNotification(
    CancelScheduledNotificationEvent event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await _repository.cancelScheduledNotification(
      event.notificationId,
    );

    result.fold(
      (failure) => emit(NotificationError(message: failure.message)),
      (_) => emit(
        ScheduledNotificationCancelled(notificationId: event.notificationId),
      ),
    );
  }

  /// Load scheduled notifications
  Future<void> _onLoadScheduledNotifications(
    LoadScheduledNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationLoading());

    final result = await _repository.getScheduledNotifications(event.userId);

    result.fold(
      (failure) => emit(NotificationError(message: failure.message)),
      (notifications) => emit(
        ScheduledNotificationsLoaded(scheduledNotifications: notifications),
      ),
    );
  }

  /// Load notification preferences
  Future<void> _onLoadNotificationPreferences(
    LoadNotificationPreferencesEvent event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationLoading());

    final result = await _getNotificationPreferences(
      GetNotificationPreferencesParams(userId: event.userId),
    );

    result.fold(
      (failure) => emit(NotificationError(message: failure.message)),
      (preferences) =>
          emit(NotificationPreferencesLoaded(preferences: preferences)),
    );
  }

  /// Update notification preferences
  Future<void> _onUpdateNotificationPreferences(
    UpdateNotificationPreferencesEvent event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await _updateNotificationPreferences(
      UpdateNotificationPreferencesParams(preferences: event.preferences),
    );

    result.fold(
      (failure) => emit(NotificationError(message: failure.message)),
      (preferences) =>
          emit(NotificationPreferencesUpdated(preferences: preferences)),
    );
  }

  /// Toggle category preference
  Future<void> _onToggleCategoryPreference(
    ToggleCategoryPreferenceEvent event,
    Emitter<NotificationState> emit,
  ) async {
    // First get current preferences
    final result = await _getNotificationPreferences(
      GetNotificationPreferencesParams(userId: event.userId),
    );

    result.fold(
      (failure) => emit(NotificationError(message: failure.message)),
      (preferences) async {
        final updatedPreferences = preferences.toggleCategory(event.category);

        final updateResult = await _updateNotificationPreferences(
          UpdateNotificationPreferencesParams(preferences: updatedPreferences),
        );

        updateResult.fold(
          (failure) => emit(NotificationError(message: failure.message)),
          (newPreferences) =>
              emit(NotificationPreferencesUpdated(preferences: newPreferences)),
        );
      },
    );
  }

  /// Toggle priority preference
  Future<void> _onTogglePriorityPreference(
    TogglePriorityPreferenceEvent event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await _getNotificationPreferences(
      GetNotificationPreferencesParams(userId: event.userId),
    );

    result.fold(
      (failure) => emit(NotificationError(message: failure.message)),
      (preferences) async {
        final updatedPreferences = preferences.togglePriority(event.priority);

        final updateResult = await _updateNotificationPreferences(
          UpdateNotificationPreferencesParams(preferences: updatedPreferences),
        );

        updateResult.fold(
          (failure) => emit(NotificationError(message: failure.message)),
          (newPreferences) =>
              emit(NotificationPreferencesUpdated(preferences: newPreferences)),
        );
      },
    );
  }

  /// Set quiet hours
  Future<void> _onSetQuietHours(
    SetQuietHoursEvent event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await _getNotificationPreferences(
      GetNotificationPreferencesParams(userId: event.userId),
    );

    result.fold(
      (failure) => emit(NotificationError(message: failure.message)),
      (preferences) async {
        final updatedPreferences = preferences.setQuietHours(
          start: event.start,
          end: event.end,
          enabled: event.enabled,
        );

        final updateResult = await _updateNotificationPreferences(
          UpdateNotificationPreferencesParams(preferences: updatedPreferences),
        );

        updateResult.fold(
          (failure) => emit(NotificationError(message: failure.message)),
          (newPreferences) =>
              emit(NotificationPreferencesUpdated(preferences: newPreferences)),
        );
      },
    );
  }

  /// Load notification statistics
  Future<void> _onLoadNotificationStats(
    LoadNotificationStatsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationLoading());

    final result = await _repository.getNotificationStats(
      event.userId,
      startDate: event.startDate,
      endDate: event.endDate,
    );

    result.fold(
      (failure) => emit(NotificationError(message: failure.message)),
      (stats) => emit(NotificationStatsLoaded(stats: stats)),
    );
  }

  /// Clear error
  void _onClearError(
    ClearNotificationErrorEvent event,
    Emitter<NotificationState> emit,
  ) {
    emit(const NotificationInitial());
  }

  /// Retry operation
  void _onRetryOperation(
    RetryNotificationOperationEvent event,
    Emitter<NotificationState> emit,
  ) {
    // This would typically retry the last failed operation
    // For now, just clear the error state
    emit(const NotificationInitial());
  }
}
