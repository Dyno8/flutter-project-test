import 'package:equatable/equatable.dart';

/// Domain entity for partner
class Partner extends Equatable {
  final String uid;
  final String name;
  final String phone;
  final String email;
  final String gender;
  final List<String> services;
  final Map<String, List<String>> workingHours;
  final double rating;
  final int totalReviews;
  final double latitude;
  final double longitude;
  final String address;
  final String bio;
  final String profileImageUrl;
  final List<String> certifications;
  final int experienceYears;
  final double pricePerHour;
  final bool isAvailable;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? fcmToken;

  const Partner({
    required this.uid,
    required this.name,
    required this.phone,
    required this.email,
    required this.gender,
    required this.services,
    required this.workingHours,
    required this.rating,
    required this.totalReviews,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.bio,
    required this.profileImageUrl,
    required this.certifications,
    required this.experienceYears,
    required this.pricePerHour,
    required this.isAvailable,
    required this.isVerified,
    required this.createdAt,
    this.updatedAt,
    this.fcmToken,
  });

  // Helper methods
  String get formattedRating => rating.toStringAsFixed(1);
  String get formattedPrice => '${pricePerHour.toStringAsFixed(0)}k VND/giờ';
  String get experienceText => '$experienceYears năm kinh nghiệm';

  // Check if partner provides a specific service
  bool providesService(String serviceId) {
    return services.contains(serviceId);
  }

  // Check if partner is available on a specific day and time
  bool isAvailableAt(String dayOfWeek, String timeSlot) {
    if (!isAvailable) return false;
    
    final daySchedule = workingHours[dayOfWeek.toLowerCase()];
    if (daySchedule == null || daySchedule.isEmpty) return false;

    // Simple time slot checking - can be enhanced with more complex logic
    return daySchedule.any((slot) => slot.contains(timeSlot.split(':')[0]));
  }

  // Calculate distance from client location (simplified)
  double distanceFrom(double clientLat, double clientLng) {
    // This is a simplified distance calculation
    // In a real app, you'd use a proper distance calculation algorithm
    final latDiff = (latitude - clientLat).abs();
    final lngDiff = (longitude - clientLng).abs();
    return (latDiff + lngDiff) * 111; // Rough km conversion
  }

  @override
  List<Object?> get props => [
        uid,
        name,
        phone,
        email,
        gender,
        services,
        workingHours,
        rating,
        totalReviews,
        latitude,
        longitude,
        address,
        bio,
        profileImageUrl,
        certifications,
        experienceYears,
        pricePerHour,
        isAvailable,
        isVerified,
        createdAt,
        updatedAt,
        fcmToken,
      ];

  @override
  String toString() {
    return 'Partner(uid: $uid, name: $name, rating: $rating, services: $services)';
  }
}
