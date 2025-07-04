import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ReviewModel extends Equatable {
  final String id;
  final String bookingId;
  final String userId;
  final String partnerId;
  final String serviceId;
  final double rating;
  final String comment;
  final List<String> tags;
  final bool isAnonymous;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ReviewModel({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.partnerId,
    required this.serviceId,
    required this.rating,
    required this.comment,
    required this.tags,
    required this.isAnonymous,
    required this.createdAt,
    this.updatedAt,
  });

  // Factory constructor from Firestore document
  factory ReviewModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReviewModel(
      id: doc.id,
      bookingId: data['bookingId'] ?? '',
      userId: data['userId'] ?? '',
      partnerId: data['partnerId'] ?? '',
      serviceId: data['serviceId'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      comment: data['comment'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      isAnonymous: data['isAnonymous'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  // Factory constructor from Map
  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      id: map['id'] ?? '',
      bookingId: map['bookingId'] ?? '',
      userId: map['userId'] ?? '',
      partnerId: map['partnerId'] ?? '',
      serviceId: map['serviceId'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      comment: map['comment'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      isAnonymous: map['isAnonymous'] ?? false,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] is Timestamp
                ? (map['updatedAt'] as Timestamp).toDate()
                : DateTime.parse(map['updatedAt']))
          : null,
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookingId': bookingId,
      'userId': userId,
      'partnerId': partnerId,
      'serviceId': serviceId,
      'rating': rating,
      'comment': comment,
      'tags': tags,
      'isAnonymous': isAnonymous,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  // Convert to JSON for API calls
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookingId': bookingId,
      'userId': userId,
      'partnerId': partnerId,
      'serviceId': serviceId,
      'rating': rating,
      'comment': comment,
      'tags': tags,
      'isAnonymous': isAnonymous,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Create copy with updated fields
  ReviewModel copyWith({
    String? id,
    String? bookingId,
    String? userId,
    String? partnerId,
    String? serviceId,
    double? rating,
    String? comment,
    List<String>? tags,
    bool? isAnonymous,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      userId: userId ?? this.userId,
      partnerId: partnerId ?? this.partnerId,
      serviceId: serviceId ?? this.serviceId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      tags: tags ?? this.tags,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReviewModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ReviewModel(id: $id, rating: $rating, comment: $comment)';
  }

  // Helper methods
  String get displayRating => rating.toStringAsFixed(1);
  String get formattedDate =>
      '${createdAt.day}/${createdAt.month}/${createdAt.year}';

  bool get isExcellent => rating >= 4.5;
  bool get isGood => rating >= 3.5 && rating < 4.5;
  bool get isAverage => rating >= 2.5 && rating < 3.5;
  bool get isPoor => rating < 2.5;

  String get ratingDescription {
    if (isExcellent) return 'Xuất sắc';
    if (isGood) return 'Tốt';
    if (isAverage) return 'Trung bình';
    return 'Kém';
  }

  // Get star representation
  String get starRepresentation {
    final fullStars = rating.floor();
    final hasHalfStar = (rating - fullStars) >= 0.5;
    final emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0);

    return '★' * fullStars + (hasHalfStar ? '☆' : '') + '☆' * emptyStars;
  }

  // Check if review can be edited (within 24 hours)
  bool get canBeEdited {
    final now = DateTime.now();
    return now.difference(createdAt).inHours < 24;
  }

  // Get truncated comment for display
  String getTruncatedComment(int maxLength) {
    if (comment.length <= maxLength) return comment;
    return '${comment.substring(0, maxLength)}...';
  }

  @override
  List<Object?> get props => [
    id,
    bookingId,
    userId,
    partnerId,
    serviceId,
    rating,
    comment,
    tags,
    isAnonymous,
    createdAt,
    updatedAt,
  ];
}

// Predefined review tags
class ReviewTags {
  static const String professional = 'professional';
  static const String punctual = 'punctual';
  static const String friendly = 'friendly';
  static const String thorough = 'thorough';
  static const String experienced = 'experienced';
  static const String caring = 'caring';
  static const String reliable = 'reliable';
  static const String communicative = 'communicative';
  static const String efficient = 'efficient';
  static const String respectful = 'respectful';

  static const Map<String, String> tagNames = {
    professional: 'Chuyên nghiệp',
    punctual: 'Đúng giờ',
    friendly: 'Thân thiện',
    thorough: 'Tỉ mỉ',
    experienced: 'Có kinh nghiệm',
    caring: 'Chu đáo',
    reliable: 'Đáng tin cậy',
    communicative: 'Giao tiếp tốt',
    efficient: 'Hiệu quả',
    respectful: 'Lịch sự',
  };

  static String getTagName(String tag) {
    return tagNames[tag] ?? tag;
  }

  static List<String> getAllTags() {
    return tagNames.keys.toList();
  }

  static List<String> getPositiveTags() {
    return getAllTags();
  }
}
