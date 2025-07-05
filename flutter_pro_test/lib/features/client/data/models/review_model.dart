import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/review.dart';

/// Data model for Review with Firestore serialization
class ReviewModel extends Review {
  const ReviewModel({
    required super.id,
    required super.bookingId,
    required super.userId,
    required super.partnerId,
    required super.serviceId,
    required super.rating,
    super.comment,
    super.tags = const [],
    super.isRecommended = true,
    required super.createdAt,
    super.updatedAt,
  });

  /// Create ReviewModel from domain entity
  factory ReviewModel.fromEntity(Review entity) {
    return ReviewModel(
      id: entity.id,
      bookingId: entity.bookingId,
      userId: entity.userId,
      partnerId: entity.partnerId,
      serviceId: entity.serviceId,
      rating: entity.rating,
      comment: entity.comment,
      tags: entity.tags,
      isRecommended: entity.isRecommended,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Create ReviewModel from Firestore document
  factory ReviewModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReviewModel(
      id: doc.id,
      bookingId: data['bookingId'] ?? '',
      userId: data['userId'] ?? '',
      partnerId: data['partnerId'] ?? '',
      serviceId: data['serviceId'] ?? '',
      rating: data['rating'] ?? 1,
      comment: data['comment'],
      tags: data['tags'] != null ? List<String>.from(data['tags']) : [],
      isRecommended: data['isRecommended'] ?? true,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Create ReviewModel from Map
  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      id: map['id'] ?? '',
      bookingId: map['bookingId'] ?? '',
      userId: map['userId'] ?? '',
      partnerId: map['partnerId'] ?? '',
      serviceId: map['serviceId'] ?? '',
      rating: map['rating'] ?? 1,
      comment: map['comment'],
      tags: map['tags'] != null ? List<String>.from(map['tags']) : [],
      isRecommended: map['isRecommended'] ?? true,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : (map['createdAt'] != null 
              ? DateTime.parse(map['createdAt'])
              : DateTime.now()),
      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : (map['updatedAt'] != null 
              ? DateTime.parse(map['updatedAt'])
              : null),
    );
  }

  /// Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
      'userId': userId,
      'partnerId': partnerId,
      'serviceId': serviceId,
      'rating': rating,
      'comment': comment,
      'tags': tags,
      'isRecommended': isRecommended,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  /// Convert to domain entity
  Review toEntity() {
    return Review(
      id: id,
      bookingId: bookingId,
      userId: userId,
      partnerId: partnerId,
      serviceId: serviceId,
      rating: rating,
      comment: comment,
      tags: tags,
      isRecommended: isRecommended,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  String toString() {
    return 'ReviewModel(id: $id, bookingId: $bookingId, rating: $rating, '
        'comment: $comment, isRecommended: $isRecommended)';
  }
}

/// Data model for ReviewRequest with Firestore serialization
class ReviewRequestModel extends ReviewRequest {
  const ReviewRequestModel({
    required super.bookingId,
    required super.userId,
    required super.partnerId,
    required super.serviceId,
    required super.rating,
    super.comment,
    super.tags = const [],
    super.isRecommended = true,
  });

  /// Create ReviewRequestModel from domain entity
  factory ReviewRequestModel.fromEntity(ReviewRequest entity) {
    return ReviewRequestModel(
      bookingId: entity.bookingId,
      userId: entity.userId,
      partnerId: entity.partnerId,
      serviceId: entity.serviceId,
      rating: entity.rating,
      comment: entity.comment,
      tags: entity.tags,
      isRecommended: entity.isRecommended,
    );
  }

  /// Create ReviewRequestModel from Map
  factory ReviewRequestModel.fromMap(Map<String, dynamic> map) {
    return ReviewRequestModel(
      bookingId: map['bookingId'] ?? '',
      userId: map['userId'] ?? '',
      partnerId: map['partnerId'] ?? '',
      serviceId: map['serviceId'] ?? '',
      rating: map['rating'] ?? 1,
      comment: map['comment'],
      tags: map['tags'] != null ? List<String>.from(map['tags']) : [],
      isRecommended: map['isRecommended'] ?? true,
    );
  }

  /// Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
      'userId': userId,
      'partnerId': partnerId,
      'serviceId': serviceId,
      'rating': rating,
      'comment': comment,
      'tags': tags,
      'isRecommended': isRecommended,
    };
  }

  /// Convert to domain entity
  ReviewRequest toEntity() {
    return ReviewRequest(
      bookingId: bookingId,
      userId: userId,
      partnerId: partnerId,
      serviceId: serviceId,
      rating: rating,
      comment: comment,
      tags: tags,
      isRecommended: isRecommended,
    );
  }

  @override
  String toString() {
    return 'ReviewRequestModel(bookingId: $bookingId, rating: $rating, '
        'comment: $comment, isRecommended: $isRecommended)';
  }
}
