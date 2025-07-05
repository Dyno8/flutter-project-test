import 'package:equatable/equatable.dart';

/// Domain entity representing a review/rating
class Review extends Equatable {
  final String id;
  final String bookingId;
  final String userId;
  final String partnerId;
  final String serviceId;
  final int rating; // 1-5 stars
  final String? comment;
  final List<String> tags; // e.g., ['punctual', 'professional', 'friendly']
  final bool isRecommended;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Review({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.partnerId,
    required this.serviceId,
    required this.rating,
    this.comment,
    this.tags = const [],
    this.isRecommended = true,
    required this.createdAt,
    this.updatedAt,
  });

  /// Check if rating is valid (1-5 stars)
  bool get isValidRating => rating >= 1 && rating <= 5;

  /// Get rating as stars string
  String get starsDisplay => '★' * rating + '☆' * (5 - rating);

  /// Check if review is positive (4-5 stars)
  bool get isPositive => rating >= 4;

  /// Check if review is negative (1-2 stars)
  bool get isNegative => rating <= 2;

  /// Check if review is neutral (3 stars)
  bool get isNeutral => rating == 3;

  /// Get formatted date
  String get formattedDate {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  /// Get rating color based on score
  String get ratingColorHex {
    switch (rating) {
      case 5:
        return '#4CAF50'; // Green
      case 4:
        return '#8BC34A'; // Light Green
      case 3:
        return '#FFC107'; // Amber
      case 2:
        return '#FF9800'; // Orange
      case 1:
        return '#F44336'; // Red
      default:
        return '#9E9E9E'; // Grey
    }
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
        isRecommended,
        createdAt,
        updatedAt,
      ];

  Review copyWith({
    String? id,
    String? bookingId,
    String? userId,
    String? partnerId,
    String? serviceId,
    int? rating,
    String? comment,
    List<String>? tags,
    bool? isRecommended,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Review(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      userId: userId ?? this.userId,
      partnerId: partnerId ?? this.partnerId,
      serviceId: serviceId ?? this.serviceId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      tags: tags ?? this.tags,
      isRecommended: isRecommended ?? this.isRecommended,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Review(id: $id, bookingId: $bookingId, rating: $rating, '
        'comment: $comment, isRecommended: $isRecommended)';
  }
}

/// Domain entity for creating a new review
class ReviewRequest extends Equatable {
  final String bookingId;
  final String userId;
  final String partnerId;
  final String serviceId;
  final int rating;
  final String? comment;
  final List<String> tags;
  final bool isRecommended;

  const ReviewRequest({
    required this.bookingId,
    required this.userId,
    required this.partnerId,
    required this.serviceId,
    required this.rating,
    this.comment,
    this.tags = const [],
    this.isRecommended = true,
  });

  /// Check if review request is valid
  bool get isValid {
    return rating >= 1 && 
           rating <= 5 && 
           bookingId.isNotEmpty && 
           userId.isNotEmpty && 
           partnerId.isNotEmpty &&
           serviceId.isNotEmpty;
  }

  @override
  List<Object?> get props => [
        bookingId,
        userId,
        partnerId,
        serviceId,
        rating,
        comment,
        tags,
        isRecommended,
      ];

  ReviewRequest copyWith({
    String? bookingId,
    String? userId,
    String? partnerId,
    String? serviceId,
    int? rating,
    String? comment,
    List<String>? tags,
    bool? isRecommended,
  }) {
    return ReviewRequest(
      bookingId: bookingId ?? this.bookingId,
      userId: userId ?? this.userId,
      partnerId: partnerId ?? this.partnerId,
      serviceId: serviceId ?? this.serviceId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      tags: tags ?? this.tags,
      isRecommended: isRecommended ?? this.isRecommended,
    );
  }

  @override
  String toString() {
    return 'ReviewRequest(bookingId: $bookingId, rating: $rating, '
        'comment: $comment, isRecommended: $isRecommended)';
  }
}
