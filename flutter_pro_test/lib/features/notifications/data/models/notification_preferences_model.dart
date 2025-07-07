import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/notification.dart';
import '../../domain/entities/notification_preferences.dart';

/// Data model for NotificationPreferences entity
class NotificationPreferencesModel extends NotificationPreferences {
  const NotificationPreferencesModel({
    required super.userId,
    required super.pushNotificationsEnabled,
    required super.emailNotificationsEnabled,
    required super.smsNotificationsEnabled,
    required super.categoryPreferences,
    required super.priorityPreferences,
    required super.soundEnabled,
    required super.vibrationEnabled,
    required super.showOnLockScreen,
    required super.showPreview,
    super.quietHoursStart,
    super.quietHoursEnd,
    required super.quietHoursEnabled,
    required super.mutedTypes,
    required super.updatedAt,
  });

  /// Create NotificationPreferencesModel from NotificationPreferences entity
  factory NotificationPreferencesModel.fromEntity(NotificationPreferences entity) {
    return NotificationPreferencesModel(
      userId: entity.userId,
      pushNotificationsEnabled: entity.pushNotificationsEnabled,
      emailNotificationsEnabled: entity.emailNotificationsEnabled,
      smsNotificationsEnabled: entity.smsNotificationsEnabled,
      categoryPreferences: entity.categoryPreferences,
      priorityPreferences: entity.priorityPreferences,
      soundEnabled: entity.soundEnabled,
      vibrationEnabled: entity.vibrationEnabled,
      showOnLockScreen: entity.showOnLockScreen,
      showPreview: entity.showPreview,
      quietHoursStart: entity.quietHoursStart,
      quietHoursEnd: entity.quietHoursEnd,
      quietHoursEnabled: entity.quietHoursEnabled,
      mutedTypes: entity.mutedTypes,
      updatedAt: entity.updatedAt,
    );
  }

  /// Create NotificationPreferencesModel from Firestore document
  factory NotificationPreferencesModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return NotificationPreferencesModel(
      userId: doc.id,
      pushNotificationsEnabled: data['pushNotificationsEnabled'] ?? true,
      emailNotificationsEnabled: data['emailNotificationsEnabled'] ?? true,
      smsNotificationsEnabled: data['smsNotificationsEnabled'] ?? false,
      categoryPreferences: _parseCategoryPreferences(data['categoryPreferences']),
      priorityPreferences: _parsePriorityPreferences(data['priorityPreferences']),
      soundEnabled: data['soundEnabled'] ?? true,
      vibrationEnabled: data['vibrationEnabled'] ?? true,
      showOnLockScreen: data['showOnLockScreen'] ?? true,
      showPreview: data['showPreview'] ?? true,
      quietHoursStart: data['quietHoursStart'],
      quietHoursEnd: data['quietHoursEnd'],
      quietHoursEnabled: data['quietHoursEnabled'] ?? false,
      mutedTypes: List<String>.from(data['mutedTypes'] ?? []),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Create NotificationPreferencesModel from JSON
  factory NotificationPreferencesModel.fromJson(Map<String, dynamic> json) {
    return NotificationPreferencesModel(
      userId: json['userId'] ?? '',
      pushNotificationsEnabled: json['pushNotificationsEnabled'] ?? true,
      emailNotificationsEnabled: json['emailNotificationsEnabled'] ?? true,
      smsNotificationsEnabled: json['smsNotificationsEnabled'] ?? false,
      categoryPreferences: _parseCategoryPreferences(json['categoryPreferences']),
      priorityPreferences: _parsePriorityPreferences(json['priorityPreferences']),
      soundEnabled: json['soundEnabled'] ?? true,
      vibrationEnabled: json['vibrationEnabled'] ?? true,
      showOnLockScreen: json['showOnLockScreen'] ?? true,
      showPreview: json['showPreview'] ?? true,
      quietHoursStart: json['quietHoursStart'],
      quietHoursEnd: json['quietHoursEnd'],
      quietHoursEnabled: json['quietHoursEnabled'] ?? false,
      mutedTypes: List<String>.from(json['mutedTypes'] ?? []),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  /// Convert to Firestore document data
  Map<String, dynamic> toFirestore() {
    return {
      'pushNotificationsEnabled': pushNotificationsEnabled,
      'emailNotificationsEnabled': emailNotificationsEnabled,
      'smsNotificationsEnabled': smsNotificationsEnabled,
      'categoryPreferences': _categoryPreferencesToMap(categoryPreferences),
      'priorityPreferences': _priorityPreferencesToMap(priorityPreferences),
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'showOnLockScreen': showOnLockScreen,
      'showPreview': showPreview,
      'quietHoursStart': quietHoursStart,
      'quietHoursEnd': quietHoursEnd,
      'quietHoursEnabled': quietHoursEnabled,
      'mutedTypes': mutedTypes,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'pushNotificationsEnabled': pushNotificationsEnabled,
      'emailNotificationsEnabled': emailNotificationsEnabled,
      'smsNotificationsEnabled': smsNotificationsEnabled,
      'categoryPreferences': _categoryPreferencesToMap(categoryPreferences),
      'priorityPreferences': _priorityPreferencesToMap(priorityPreferences),
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'showOnLockScreen': showOnLockScreen,
      'showPreview': showPreview,
      'quietHoursStart': quietHoursStart,
      'quietHoursEnd': quietHoursEnd,
      'quietHoursEnabled': quietHoursEnabled,
      'mutedTypes': mutedTypes,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  @override
  NotificationPreferencesModel copyWith({
    String? userId,
    bool? pushNotificationsEnabled,
    bool? emailNotificationsEnabled,
    bool? smsNotificationsEnabled,
    Map<NotificationCategory, bool>? categoryPreferences,
    Map<NotificationPriority, bool>? priorityPreferences,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? showOnLockScreen,
    bool? showPreview,
    String? quietHoursStart,
    String? quietHoursEnd,
    bool? quietHoursEnabled,
    List<String>? mutedTypes,
    DateTime? updatedAt,
  }) {
    return NotificationPreferencesModel(
      userId: userId ?? this.userId,
      pushNotificationsEnabled: pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      emailNotificationsEnabled: emailNotificationsEnabled ?? this.emailNotificationsEnabled,
      smsNotificationsEnabled: smsNotificationsEnabled ?? this.smsNotificationsEnabled,
      categoryPreferences: categoryPreferences ?? this.categoryPreferences,
      priorityPreferences: priorityPreferences ?? this.priorityPreferences,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      showOnLockScreen: showOnLockScreen ?? this.showOnLockScreen,
      showPreview: showPreview ?? this.showPreview,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      mutedTypes: mutedTypes ?? this.mutedTypes,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Parse category preferences from dynamic data
  static Map<NotificationCategory, bool> _parseCategoryPreferences(dynamic data) {
    if (data == null) {
      return NotificationPreferences.defaultPreferences('').categoryPreferences;
    }

    final Map<String, dynamic> map = Map<String, dynamic>.from(data);
    final result = <NotificationCategory, bool>{};

    for (final category in NotificationCategory.values) {
      result[category] = map[category.name] ?? true;
    }

    return result;
  }

  /// Parse priority preferences from dynamic data
  static Map<NotificationPriority, bool> _parsePriorityPreferences(dynamic data) {
    if (data == null) {
      return NotificationPreferences.defaultPreferences('').priorityPreferences;
    }

    final Map<String, dynamic> map = Map<String, dynamic>.from(data);
    final result = <NotificationPriority, bool>{};

    for (final priority in NotificationPriority.values) {
      result[priority] = map[priority.name] ?? true;
    }

    return result;
  }

  /// Convert category preferences to map for storage
  static Map<String, bool> _categoryPreferencesToMap(Map<NotificationCategory, bool> preferences) {
    final result = <String, bool>{};
    preferences.forEach((category, enabled) {
      result[category.name] = enabled;
    });
    return result;
  }

  /// Convert priority preferences to map for storage
  static Map<String, bool> _priorityPreferencesToMap(Map<NotificationPriority, bool> preferences) {
    final result = <String, bool>{};
    preferences.forEach((priority, enabled) {
      result[priority.name] = enabled;
    });
    return result;
  }
}
