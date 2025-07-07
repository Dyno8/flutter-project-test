import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/notification.dart';

/// Data model for Notification entity
class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.body,
    required super.type,
    required super.data,
    required super.createdAt,
    super.readAt,
    required super.isRead,
    required super.priority,
    required super.category,
    super.imageUrl,
    super.actionUrl,
    super.scheduledAt,
    required super.isScheduled,
    required super.isPersistent,
  });

  /// Create NotificationModel from NotificationEntity
  factory NotificationModel.fromEntity(NotificationEntity entity) {
    return NotificationModel(
      id: entity.id,
      userId: entity.userId,
      title: entity.title,
      body: entity.body,
      type: entity.type,
      data: entity.data,
      createdAt: entity.createdAt,
      readAt: entity.readAt,
      isRead: entity.isRead,
      priority: entity.priority,
      category: entity.category,
      imageUrl: entity.imageUrl,
      actionUrl: entity.actionUrl,
      scheduledAt: entity.scheduledAt,
      isScheduled: entity.isScheduled,
      isPersistent: entity.isPersistent,
    );
  }

  /// Create NotificationModel from Firestore document
  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return NotificationModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      type: data['type'] ?? '',
      data: Map<String, dynamic>.from(data['data'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      readAt: (data['readAt'] as Timestamp?)?.toDate(),
      isRead: data['isRead'] ?? false,
      priority: _priorityFromString(data['priority'] ?? 'normal'),
      category: _categoryFromString(data['category'] ?? 'system'),
      imageUrl: data['imageUrl'],
      actionUrl: data['actionUrl'],
      scheduledAt: (data['scheduledAt'] as Timestamp?)?.toDate(),
      isScheduled: data['isScheduled'] ?? false,
      isPersistent: data['isPersistent'] ?? false,
    );
  }

  /// Create NotificationModel from JSON
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: json['type'] ?? '',
      data: Map<String, dynamic>.from(json['data'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
      isRead: json['isRead'] ?? false,
      priority: _priorityFromString(json['priority'] ?? 'normal'),
      category: _categoryFromString(json['category'] ?? 'system'),
      imageUrl: json['imageUrl'],
      actionUrl: json['actionUrl'],
      scheduledAt: json['scheduledAt'] != null ? DateTime.parse(json['scheduledAt']) : null,
      isScheduled: json['isScheduled'] ?? false,
      isPersistent: json['isPersistent'] ?? false,
    );
  }

  /// Convert to Firestore document data
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'body': body,
      'type': type,
      'data': data,
      'createdAt': Timestamp.fromDate(createdAt),
      'readAt': readAt != null ? Timestamp.fromDate(readAt!) : null,
      'isRead': isRead,
      'priority': priority.name,
      'category': category.name,
      'imageUrl': imageUrl,
      'actionUrl': actionUrl,
      'scheduledAt': scheduledAt != null ? Timestamp.fromDate(scheduledAt!) : null,
      'isScheduled': isScheduled,
      'isPersistent': isPersistent,
    };
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'body': body,
      'type': type,
      'data': data,
      'createdAt': createdAt.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
      'isRead': isRead,
      'priority': priority.name,
      'category': category.name,
      'imageUrl': imageUrl,
      'actionUrl': actionUrl,
      'scheduledAt': scheduledAt?.toIso8601String(),
      'isScheduled': isScheduled,
      'isPersistent': isPersistent,
    };
  }

  /// Create a copy with updated fields
  @override
  NotificationModel copyWith({
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
    return NotificationModel(
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

  /// Convert string to NotificationPriority
  static NotificationPriority _priorityFromString(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return NotificationPriority.low;
      case 'normal':
        return NotificationPriority.normal;
      case 'high':
        return NotificationPriority.high;
      case 'urgent':
        return NotificationPriority.urgent;
      default:
        return NotificationPriority.normal;
    }
  }

  /// Convert string to NotificationCategory
  static NotificationCategory _categoryFromString(String category) {
    switch (category.toLowerCase()) {
      case 'booking':
        return NotificationCategory.booking;
      case 'job':
        return NotificationCategory.job;
      case 'payment':
        return NotificationCategory.payment;
      case 'system':
        return NotificationCategory.system;
      case 'promotion':
        return NotificationCategory.promotion;
      case 'reminder':
        return NotificationCategory.reminder;
      case 'social':
        return NotificationCategory.social;
      default:
        return NotificationCategory.system;
    }
  }
}
