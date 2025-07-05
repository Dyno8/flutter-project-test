import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../core/errors/failures.dart';
import '../repositories/base_repository.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Initialize notification service
  Future<void> initialize() async {
    // Request permissions
    await _requestPermissions();

    // Initialize local notifications
    await _initializeLocalNotifications();

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

    print('Notification permission status: ${settings.authorizationStatus}');
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
    print('Received foreground message: ${message.messageId}');

    // Show local notification
    await _showLocalNotification(
      title: message.notification?.title ?? 'CareNow',
      body: message.notification?.body ?? '',
      data: message.data,
    );
  }

  // Handle background messages
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    print('Received background message: ${message.messageId}');
  }

  // Handle notification tap
  Future<void> _handleNotificationTap(RemoteMessage message) async {
    print('Notification tapped: ${message.data}');
    // Navigate to appropriate screen based on notification data
    _navigateBasedOnNotification(message.data);
  }

  // Handle local notification tap
  void _onNotificationTapped(NotificationResponse response) {
    print('Local notification tapped: ${response.payload}');
    // Handle local notification tap
  }

  // Show local notification
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'carenow_channel',
      'CareNow Notifications',
      channelDescription: 'Notifications for CareNow app',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
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

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
      payload: data?.toString(),
    );
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
      print('Error getting FCM token: $e');
      return null;
    }
  }

  // Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
    } catch (e) {
      print('Error subscribing to topic: $e');
    }
  }

  // Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
    } catch (e) {
      print('Error unsubscribing from topic: $e');
    }
  }

  // Navigate based on notification data
  void _navigateBasedOnNotification(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    final bookingId = data['bookingId'] as String?;
    final jobId = data['jobId'] as String?;

    switch (type) {
      case 'new_booking':
      case 'new_job':
        // Navigate to partner job details
        print('Navigate to job details: ${jobId ?? bookingId}');
        break;
      case 'booking_confirmed':
      case 'job_accepted':
        // Navigate to job details
        print('Navigate to job details: ${jobId ?? bookingId}');
        break;
      case 'booking_started':
      case 'job_started':
        // Navigate to job tracking
        print('Navigate to job tracking: ${jobId ?? bookingId}');
        break;
      case 'booking_completed':
      case 'job_completed':
        // Navigate to earnings or review screen
        print('Navigate to earnings screen');
        break;
      case 'booking_cancelled':
      case 'job_cancelled':
        // Navigate to job history
        print('Navigate to job history');
        break;
      case 'earnings_update':
        // Navigate to earnings screen
        print('Navigate to earnings screen');
        break;
      case 'rating_received':
        // Navigate to profile/ratings
        print('Navigate to profile ratings');
        break;
      default:
        // Navigate to partner dashboard
        print('Navigate to partner dashboard');
        break;
    }
  }

  // Partner-specific notification methods

  /// Subscribe to partner notifications
  Future<void> subscribeToPartnerNotifications(String partnerId) async {
    await subscribeToTopic('partner_$partnerId');
    await subscribeToTopic('partner_general');
    print('Subscribed to partner notifications: $partnerId');
  }

  /// Unsubscribe from partner notifications
  Future<void> unsubscribeFromPartnerNotifications(String partnerId) async {
    await unsubscribeFromTopic('partner_$partnerId');
    await unsubscribeFromTopic('partner_general');
    print('Unsubscribed from partner notifications: $partnerId');
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
}
