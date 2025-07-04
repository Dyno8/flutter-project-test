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

    switch (type) {
      case 'new_booking':
        // Navigate to partner booking details
        print('Navigate to booking details: $bookingId');
        break;
      case 'booking_confirmed':
        // Navigate to client booking details
        print('Navigate to booking details: $bookingId');
        break;
      case 'booking_started':
        // Navigate to booking tracking
        print('Navigate to booking tracking: $bookingId');
        break;
      case 'booking_completed':
        // Navigate to review screen
        print('Navigate to review screen: $bookingId');
        break;
      case 'booking_cancelled':
        // Navigate to booking history
        print('Navigate to booking history');
        break;
      default:
        // Navigate to home
        print('Navigate to home');
        break;
    }
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
