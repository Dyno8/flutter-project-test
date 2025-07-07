import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:dartz/dartz.dart';
import 'dart:developer' as developer;
import '../../core/errors/failures.dart';
import '../../features/notifications/domain/entities/notification.dart';
import '../../features/notifications/domain/entities/notification_preferences.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Repository for advanced notification management
  NotificationRepository? _repository;

  // Current user preferences
  NotificationPreferences? _currentPreferences;

  // Notification channels
  static const String _defaultChannelId = 'carenow_default';
  static const String _bookingChannelId = 'carenow_booking';
  static const String _jobChannelId = 'carenow_job';
  static const String _paymentChannelId = 'carenow_payment';
  static const String _urgentChannelId = 'carenow_urgent';

  /// Set the notification repository for advanced features
  void setRepository(NotificationRepository repository) {
    _repository = repository;
  }

  /// Set current user preferences
  void setUserPreferences(NotificationPreferences preferences) {
    _currentPreferences = preferences;
  }

  // Initialize notification service
  Future<void> initialize() async {
    // Request permissions
    await _requestPermissions();

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Create notification channels
    await _createNotificationChannels();

    // Setup FCM handlers
    _setupFCMHandlers();
  }

  // Request notification permissions
  Future<void> _requestPermissions() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    developer.log(
      'Notification permission status: ${settings.authorizationStatus}',
      name: 'NotificationService',
    );
  }

  // Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  // Create notification channels for Android
  Future<void> _createNotificationChannels() async {
    final List<AndroidNotificationChannel> channels = [
      AndroidNotificationChannel(
        _defaultChannelId,
        'General Notifications',
        description: 'General notifications for CareNow app',
        importance: Importance.defaultImportance,
        playSound: true,
      ),
      AndroidNotificationChannel(
        _bookingChannelId,
        'Booking Notifications',
        description: 'Notifications related to bookings',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      ),
      AndroidNotificationChannel(
        _jobChannelId,
        'Job Notifications',
        description: 'Notifications for partner jobs',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      ),
      AndroidNotificationChannel(
        _paymentChannelId,
        'Payment Notifications',
        description: 'Payment and earnings notifications',
        importance: Importance.high,
        playSound: true,
      ),
      AndroidNotificationChannel(
        _urgentChannelId,
        'Urgent Notifications',
        description: 'Urgent notifications requiring immediate attention',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        enableLights: true,
      ),
    ];

    for (final channel in channels) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);
    }
  }

  // Setup FCM message handlers
  void _setupFCMHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

    // Handle notification taps when app is terminated
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
  }

  // Handle foreground messages
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    developer.log(
      'Received foreground message: ${message.messageId}',
      name: 'NotificationService',
    );

    // Show local notification
    await _showLocalNotification(
      title: message.notification?.title ?? 'CareNow',
      body: message.notification?.body ?? '',
      data: message.data,
    );
  }

  // Handle background messages
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    developer.log(
      'Received background message: ${message.messageId}',
      name: 'NotificationService',
    );
  }

  // Handle notification tap
  Future<void> _handleNotificationTap(RemoteMessage message) async {
    developer.log(
      'Notification tapped: ${message.data}',
      name: 'NotificationService',
    );
    // Navigate to appropriate screen based on notification data
    _navigateBasedOnNotification(message.data);
  }

  // Handle local notification tap
  void _onNotificationTapped(NotificationResponse response) {
    developer.log(
      'Local notification tapped: ${response.payload}',
      name: 'NotificationService',
    );
    // Handle local notification tap
  }

  // Show local notification with enhanced features
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
    NotificationCategory? category,
    NotificationPriority? priority,
    String? imageUrl,
  }) async {
    // Check user preferences before showing notification
    if (_currentPreferences != null) {
      final mockNotification = NotificationEntity(
        id: 'temp',
        userId: 'temp',
        title: title,
        body: body,
        type: data?['type'] ?? 'general',
        data: data ?? {},
        createdAt: DateTime.now(),
        isRead: false,
        priority: priority ?? NotificationPriority.normal,
        category: category ?? NotificationCategory.system,
        isScheduled: false,
        isPersistent: false,
      );

      if (!_currentPreferences!.shouldShowNotification(mockNotification)) {
        return; // Don't show notification based on user preferences
      }
    }

    // Determine channel based on category
    String channelId = _getChannelIdForCategory(category);

    final androidDetails = AndroidNotificationDetails(
      channelId,
      _getChannelNameForCategory(category),
      channelDescription: _getChannelDescriptionForCategory(category),
      importance: _getImportanceForPriority(
        priority ?? NotificationPriority.normal,
      ),
      priority: _getPriorityForPriority(
        priority ?? NotificationPriority.normal,
      ),
      showWhen: true,
      playSound: _currentPreferences?.soundEnabled ?? true,
      enableVibration: _currentPreferences?.vibrationEnabled ?? true,
      visibility: _currentPreferences?.showOnLockScreen == true
          ? NotificationVisibility.public
          : NotificationVisibility.private,
      styleInformation: imageUrl != null
          ? BigPictureStyleInformation(
              FilePathAndroidBitmap(imageUrl),
              contentTitle: title,
              summaryText: body,
            )
          : BigTextStyleInformation(body),
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: _currentPreferences?.showPreview ?? true,
      presentBadge: true,
      presentSound: _currentPreferences?.soundEnabled ?? true,
      subtitle: _getCategoryDisplayName(category),
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
      payload: data?.toString(),
    );

    // Save notification to repository if available
    if (_repository != null && data?['userId'] != null) {
      await _saveNotificationToRepository(
        userId: data!['userId'],
        title: title,
        body: body,
        type: data['type'] ?? 'general',
        data: data,
        category: category ?? NotificationCategory.system,
        priority: priority ?? NotificationPriority.normal,
      );
    }
  }

  // Send booking notification
  Future<Either<Failure, void>> sendBookingNotification(
    String? fcmToken,
    String title,
    String body,
    Map<String, dynamic> data,
  ) async {
    try {
      if (fcmToken == null || fcmToken.isEmpty) {
        return const Right(null);
      }

      // In a real app, you would send this through your backend
      // For now, we'll just show a local notification
      await _showLocalNotification(title: title, body: body, data: data);

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to send notification: $e'));
    }
  }

  // Get FCM token
  Future<String?> getFCMToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      developer.log('Error getting FCM token: $e', name: 'NotificationService');
      return null;
    }
  }

  // Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
    } catch (e) {
      // Error subscribing to topic
    }
  }

  // Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
    } catch (e) {
      // Error unsubscribing from topic
    }
  }

  // Navigate based on notification data
  void _navigateBasedOnNotification(Map<String, dynamic> data) {
    final type = data['type'] as String?;

    switch (type) {
      case 'new_booking':
      case 'new_job':
        // Navigate to partner job details
        // Navigate to job details
        break;
      case 'booking_confirmed':
      case 'job_accepted':
        // Navigate to job details
        // Navigate to job details
        break;
      case 'booking_started':
      case 'job_started':
        // Navigate to job tracking
        break;
      case 'booking_completed':
      case 'job_completed':
        // Navigate to earnings or review screen
        break;
      case 'booking_cancelled':
      case 'job_cancelled':
        // Navigate to job history
        break;
      case 'earnings_update':
        // Navigate to earnings screen
        break;
      case 'rating_received':
        // Navigate to profile/ratings
        break;
      default:
        // Navigate to partner dashboard
        break;
    }
  }

  // Partner-specific notification methods

  /// Subscribe to partner notifications
  Future<void> subscribeToPartnerNotifications(String partnerId) async {
    await subscribeToTopic('partner_$partnerId');
    await subscribeToTopic('partner_general');
    // Subscribed to partner notifications
  }

  /// Unsubscribe from partner notifications
  Future<void> unsubscribeFromPartnerNotifications(String partnerId) async {
    await unsubscribeFromTopic('partner_$partnerId');
    await unsubscribeFromTopic('partner_general');
    // Unsubscribed from partner notifications
  }

  /// Send new job notification to partner
  Future<void> sendNewJobNotification({
    required String partnerId,
    required String jobId,
    required String serviceName,
    required String clientName,
    required String earnings,
  }) async {
    await _showLocalNotification(
      title: 'New Job Available!',
      body: '$serviceName for $clientName - Earn $earnings',
      data: {'type': 'new_job', 'jobId': jobId, 'partnerId': partnerId},
    );
  }

  /// Send job status update notification
  Future<void> sendJobStatusNotification({
    required String partnerId,
    required String jobId,
    required String status,
    required String serviceName,
  }) async {
    String title;
    String body;

    switch (status) {
      case 'accepted':
        title = 'Job Accepted';
        body = 'You have accepted the $serviceName job';
        break;
      case 'started':
        title = 'Job Started';
        body = 'You have started the $serviceName job';
        break;
      case 'completed':
        title = 'Job Completed';
        body = 'You have completed the $serviceName job';
        break;
      case 'cancelled':
        title = 'Job Cancelled';
        body = 'The $serviceName job has been cancelled';
        break;
      default:
        title = 'Job Update';
        body = 'Your $serviceName job status has been updated';
    }

    await _showLocalNotification(
      title: title,
      body: body,
      data: {'type': 'job_$status', 'jobId': jobId, 'partnerId': partnerId},
    );
  }

  /// Send earnings update notification
  Future<void> sendEarningsNotification({
    required String partnerId,
    required String amount,
    required String period,
  }) async {
    await _showLocalNotification(
      title: 'Earnings Update',
      body: 'You earned $amount $period',
      data: {'type': 'earnings_update', 'partnerId': partnerId},
    );
  }

  /// Send rating received notification
  Future<void> sendRatingNotification({
    required String partnerId,
    required String jobId,
    required double rating,
    required String? review,
  }) async {
    await _showLocalNotification(
      title: 'New Rating Received',
      body:
          'You received a ${rating.toStringAsFixed(1)} star rating${review != null ? ' with review' : ''}',
      data: {
        'type': 'rating_received',
        'jobId': jobId,
        'partnerId': partnerId,
        'rating': rating.toString(),
      },
    );
  }

  // Schedule local notification
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    Map<String, dynamic>? data,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'carenow_scheduled',
      'CareNow Scheduled',
      channelDescription: 'Scheduled notifications for CareNow',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // For now, just schedule a simple notification
    // In production, you would use timezone package for proper scheduling
    await _localNotifications.show(
      id,
      title,
      body,
      notificationDetails,
      payload: data?.toString(),
    );
  }

  // Cancel scheduled notification
  Future<void> cancelScheduledNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  // Show booking reminder
  Future<void> scheduleBookingReminder({
    required String bookingId,
    required String serviceName,
    required DateTime scheduledDate,
  }) async {
    // Schedule reminder 1 hour before booking
    final reminderTime = scheduledDate.subtract(const Duration(hours: 1));

    if (reminderTime.isAfter(DateTime.now())) {
      await scheduleNotification(
        id: bookingId.hashCode,
        title: 'Nhắc nhở dịch vụ',
        body: 'Dịch vụ $serviceName sẽ bắt đầu trong 1 giờ',
        scheduledDate: reminderTime,
        data: {'type': 'booking_reminder', 'bookingId': bookingId},
      );
    }
  }

  // Helper methods for enhanced notification features

  /// Get channel ID based on notification category
  String _getChannelIdForCategory(NotificationCategory? category) {
    switch (category) {
      case NotificationCategory.booking:
        return _bookingChannelId;
      case NotificationCategory.job:
        return _jobChannelId;
      case NotificationCategory.payment:
        return _paymentChannelId;
      case NotificationCategory.system:
      case NotificationCategory.promotion:
      case NotificationCategory.reminder:
      case NotificationCategory.social:
      case null:
        return _defaultChannelId;
    }
  }

  /// Get channel name based on notification category
  String _getChannelNameForCategory(NotificationCategory? category) {
    switch (category) {
      case NotificationCategory.booking:
        return 'Booking Notifications';
      case NotificationCategory.job:
        return 'Job Notifications';
      case NotificationCategory.payment:
        return 'Payment Notifications';
      case NotificationCategory.system:
        return 'System Notifications';
      case NotificationCategory.promotion:
        return 'Promotional Notifications';
      case NotificationCategory.reminder:
        return 'Reminder Notifications';
      case NotificationCategory.social:
        return 'Social Notifications';
      case null:
        return 'General Notifications';
    }
  }

  /// Get channel description based on notification category
  String _getChannelDescriptionForCategory(NotificationCategory? category) {
    switch (category) {
      case NotificationCategory.booking:
        return 'Notifications related to your bookings';
      case NotificationCategory.job:
        return 'Notifications for partner jobs';
      case NotificationCategory.payment:
        return 'Payment and earnings notifications';
      case NotificationCategory.system:
        return 'System and app notifications';
      case NotificationCategory.promotion:
        return 'Promotional offers and discounts';
      case NotificationCategory.reminder:
        return 'Reminders and scheduled notifications';
      case NotificationCategory.social:
        return 'Social interactions and reviews';
      case null:
        return 'General notifications for CareNow app';
    }
  }

  /// Get Android importance level based on notification priority
  Importance _getImportanceForPriority(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.low:
        return Importance.low;
      case NotificationPriority.normal:
        return Importance.defaultImportance;
      case NotificationPriority.high:
        return Importance.high;
      case NotificationPriority.urgent:
        return Importance.max;
    }
  }

  /// Get Android priority level based on notification priority
  Priority _getPriorityForPriority(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.low:
        return Priority.low;
      case NotificationPriority.normal:
        return Priority.defaultPriority;
      case NotificationPriority.high:
        return Priority.high;
      case NotificationPriority.urgent:
        return Priority.max;
    }
  }

  /// Get category display name for iOS subtitle
  String? _getCategoryDisplayName(NotificationCategory? category) {
    return category?.displayName;
  }

  /// Save notification to repository
  Future<void> _saveNotificationToRepository({
    required String userId,
    required String title,
    required String body,
    required String type,
    required Map<String, dynamic> data,
    required NotificationCategory category,
    required NotificationPriority priority,
  }) async {
    try {
      final notification = NotificationEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        title: title,
        body: body,
        type: type,
        data: data,
        createdAt: DateTime.now(),
        isRead: false,
        priority: priority,
        category: category,
        isScheduled: false,
        isPersistent: false,
      );

      await _repository!.createNotification(notification);
    } catch (e) {
      // Silently fail - notification was already shown to user
      // Failed to save notification to repository
    }
  }

  /// Enhanced notification methods with category and priority support

  /// Send enhanced booking notification
  Future<void> sendEnhancedBookingNotification({
    required String userId,
    required String title,
    required String body,
    required Map<String, dynamic> data,
    NotificationPriority priority = NotificationPriority.high,
    String? imageUrl,
  }) async {
    await _showLocalNotification(
      title: title,
      body: body,
      data: {...data, 'userId': userId},
      category: NotificationCategory.booking,
      priority: priority,
      imageUrl: imageUrl,
    );
  }

  /// Send enhanced job notification
  Future<void> sendEnhancedJobNotification({
    required String userId,
    required String title,
    required String body,
    required Map<String, dynamic> data,
    NotificationPriority priority = NotificationPriority.high,
    String? imageUrl,
  }) async {
    await _showLocalNotification(
      title: title,
      body: body,
      data: {...data, 'userId': userId},
      category: NotificationCategory.job,
      priority: priority,
      imageUrl: imageUrl,
    );
  }

  /// Send enhanced payment notification
  Future<void> sendEnhancedPaymentNotification({
    required String userId,
    required String title,
    required String body,
    required Map<String, dynamic> data,
    NotificationPriority priority = NotificationPriority.high,
    String? imageUrl,
  }) async {
    await _showLocalNotification(
      title: title,
      body: body,
      data: {...data, 'userId': userId},
      category: NotificationCategory.payment,
      priority: priority,
      imageUrl: imageUrl,
    );
  }

  /// Send system notification
  Future<void> sendSystemNotification({
    required String userId,
    required String title,
    required String body,
    required Map<String, dynamic> data,
    NotificationPriority priority = NotificationPriority.normal,
    String? imageUrl,
  }) async {
    await _showLocalNotification(
      title: title,
      body: body,
      data: {...data, 'userId': userId},
      category: NotificationCategory.system,
      priority: priority,
      imageUrl: imageUrl,
    );
  }
}
