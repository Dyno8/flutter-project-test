import 'package:equatable/equatable.dart';

/// Notification entity representing a notification in the domain layer
class NotificationEntity extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String type;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final DateTime? readAt;
  final bool isRead;
  final NotificationPriority priority;
  final NotificationCategory category;
  final String? imageUrl;
  final String? actionUrl;
  final DateTime? scheduledAt;
  final bool isScheduled;
  final bool isPersistent;

  const NotificationEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    required this.data,
    required this.createdAt,
    this.readAt,
    required this.isRead,
    required this.priority,
    required this.category,
    this.imageUrl,
    this.actionUrl,
    this.scheduledAt,
    required this.isScheduled,
    required this.isPersistent,
  });

  /// Create a copy with updated fields
  NotificationEntity copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    String? type,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    DateTime? readAt,
    bool? isRead,
    NotificationPriority? priority,
    NotificationCategory? category,
    String? imageUrl,
    String? actionUrl,
    DateTime? scheduledAt,
    bool? isScheduled,
    bool? isPersistent,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      isRead: isRead ?? this.isRead,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      actionUrl: actionUrl ?? this.actionUrl,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      isScheduled: isScheduled ?? this.isScheduled,
      isPersistent: isPersistent ?? this.isPersistent,
    );
  }

  /// Mark notification as read
  NotificationEntity markAsRead() {
    return copyWith(
      isRead: true,
      readAt: DateTime.now(),
    );
  }

  /// Check if notification is expired (for scheduled notifications)
  bool get isExpired {
    if (!isScheduled || scheduledAt == null) return false;
    return DateTime.now().isAfter(scheduledAt!.add(const Duration(days: 7)));
  }

  /// Check if notification should be shown now
  bool get shouldShowNow {
    if (!isScheduled || scheduledAt == null) return true;
    return DateTime.now().isAfter(scheduledAt!);
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        body,
        type,
        data,
        createdAt,
        readAt,
        isRead,
        priority,
        category,
        imageUrl,
        actionUrl,
        scheduledAt,
        isScheduled,
        isPersistent,
      ];
}

/// Notification priority levels
enum NotificationPriority {
  low,
  normal,
  high,
  urgent;

  /// Get priority display name
  String get displayName {
    switch (this) {
      case NotificationPriority.low:
        return 'Low';
      case NotificationPriority.normal:
        return 'Normal';
      case NotificationPriority.high:
        return 'High';
      case NotificationPriority.urgent:
        return 'Urgent';
    }
  }

  /// Get priority value for sorting
  int get value {
    switch (this) {
      case NotificationPriority.low:
        return 1;
      case NotificationPriority.normal:
        return 2;
      case NotificationPriority.high:
        return 3;
      case NotificationPriority.urgent:
        return 4;
    }
  }
}

/// Notification categories for organization
enum NotificationCategory {
  booking,
  job,
  payment,
  system,
  promotion,
  reminder,
  social;

  /// Get category display name
  String get displayName {
    switch (this) {
      case NotificationCategory.booking:
        return 'Booking';
      case NotificationCategory.job:
        return 'Job';
      case NotificationCategory.payment:
        return 'Payment';
      case NotificationCategory.system:
        return 'System';
      case NotificationCategory.promotion:
        return 'Promotion';
      case NotificationCategory.reminder:
        return 'Reminder';
      case NotificationCategory.social:
        return 'Social';
    }
  }

  /// Get category icon
  String get icon {
    switch (this) {
      case NotificationCategory.booking:
        return '📅';
      case NotificationCategory.job:
        return '💼';
      case NotificationCategory.payment:
        return '💰';
      case NotificationCategory.system:
        return '⚙️';
      case NotificationCategory.promotion:
        return '🎉';
      case NotificationCategory.reminder:
        return '⏰';
      case NotificationCategory.social:
        return '👥';
    }
  }
}

/// Notification types for specific actions
class NotificationTypes {
  // Booking notifications
  static const String bookingCreated = 'booking_created';
  static const String bookingConfirmed = 'booking_confirmed';
  static const String bookingStarted = 'booking_started';
  static const String bookingCompleted = 'booking_completed';
  static const String bookingCancelled = 'booking_cancelled';
  static const String bookingReminder = 'booking_reminder';

  // Job notifications (for partners)
  static const String newJobAvailable = 'new_job_available';
  static const String jobAccepted = 'job_accepted';
  static const String jobStarted = 'job_started';
  static const String jobCompleted = 'job_completed';
  static const String jobCancelled = 'job_cancelled';

  // Payment notifications
  static const String paymentReceived = 'payment_received';
  static const String paymentFailed = 'payment_failed';
  static const String earningsUpdate = 'earnings_update';

  // System notifications
  static const String systemMaintenance = 'system_maintenance';
  static const String appUpdate = 'app_update';
  static const String accountUpdate = 'account_update';

  // Social notifications
  static const String ratingReceived = 'rating_received';
  static const String reviewReceived = 'review_received';

  // Promotion notifications
  static const String specialOffer = 'special_offer';
  static const String discount = 'discount';

  /// Get all notification types
  static List<String> get allTypes => [
        bookingCreated,
        bookingConfirmed,
        bookingStarted,
        bookingCompleted,
        bookingCancelled,
        bookingReminder,
        newJobAvailable,
        jobAccepted,
        jobStarted,
        jobCompleted,
        jobCancelled,
        paymentReceived,
        paymentFailed,
        earningsUpdate,
        systemMaintenance,
        appUpdate,
        accountUpdate,
        ratingReceived,
        reviewReceived,
        specialOffer,
        discount,
      ];
}
