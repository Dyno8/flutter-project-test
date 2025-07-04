import 'package:cloud_firestore/cloud_firestore.dart';

class PartnerModel {
  final String uid;
  final String name;
  final String phone;
  final String email;
  final String gender;
  final List<String> services;
  final Map<String, List<String>> workingHours;
  final double rating;
  final int totalReviews;
  final GeoPoint location;
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

  const PartnerModel({
    required this.uid,
    required this.name,
    required this.phone,
    required this.email,
    required this.gender,
    required this.services,
    required this.workingHours,
    required this.rating,
    required this.totalReviews,
    required this.location,
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

  // Factory constructor from Firestore document
  factory PartnerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PartnerModel(
      uid: doc.id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      gender: data['gender'] ?? '',
      services: List<String>.from(data['services'] ?? []),
      workingHours: Map<String, List<String>>.from(
        (data['workingHours'] ?? {}).map(
          (key, value) => MapEntry(key, List<String>.from(value ?? [])),
        ),
      ),
      rating: (data['rating'] ?? 0.0).toDouble(),
      totalReviews: data['totalReviews'] ?? 0,
      location: data['location'] ?? const GeoPoint(0, 0),
      address: data['address'] ?? '',
      bio: data['bio'] ?? '',
      profileImageUrl: data['profileImageUrl'] ?? '',
      certifications: List<String>.from(data['certifications'] ?? []),
      experienceYears: data['experienceYears'] ?? 0,
      pricePerHour: (data['pricePerHour'] ?? 0.0).toDouble(),
      isAvailable: data['isAvailable'] ?? true,
      isVerified: data['isVerified'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
      fcmToken: data['fcmToken'],
    );
  }

  // Factory constructor from Map
  factory PartnerModel.fromMap(Map<String, dynamic> map) {
    return PartnerModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      gender: map['gender'] ?? '',
      services: List<String>.from(map['services'] ?? []),
      workingHours: Map<String, List<String>>.from(
        (map['workingHours'] ?? {}).map(
          (key, value) => MapEntry(key, List<String>.from(value ?? [])),
        ),
      ),
      rating: (map['rating'] ?? 0.0).toDouble(),
      totalReviews: map['totalReviews'] ?? 0,
      location: map['location'] is GeoPoint 
          ? map['location'] 
          : const GeoPoint(0, 0),
      address: map['address'] ?? '',
      bio: map['bio'] ?? '',
      profileImageUrl: map['profileImageUrl'] ?? '',
      certifications: List<String>.from(map['certifications'] ?? []),
      experienceYears: map['experienceYears'] ?? 0,
      pricePerHour: (map['pricePerHour'] ?? 0.0).toDouble(),
      isAvailable: map['isAvailable'] ?? true,
      isVerified: map['isVerified'] ?? false,
      createdAt: map['createdAt'] is Timestamp 
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] is Timestamp 
              ? (map['updatedAt'] as Timestamp).toDate()
              : DateTime.parse(map['updatedAt']))
          : null,
      fcmToken: map['fcmToken'],
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'phone': phone,
      'email': email,
      'gender': gender,
      'services': services,
      'workingHours': workingHours,
      'rating': rating,
      'totalReviews': totalReviews,
      'location': location,
      'address': address,
      'bio': bio,
      'profileImageUrl': profileImageUrl,
      'certifications': certifications,
      'experienceYears': experienceYears,
      'pricePerHour': pricePerHour,
      'isAvailable': isAvailable,
      'isVerified': isVerified,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'fcmToken': fcmToken,
    };
  }

  // Convert to JSON for API calls
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'phone': phone,
      'email': email,
      'gender': gender,
      'services': services,
      'workingHours': workingHours,
      'rating': rating,
      'totalReviews': totalReviews,
      'location': {
        'latitude': location.latitude,
        'longitude': location.longitude,
      },
      'address': address,
      'bio': bio,
      'profileImageUrl': profileImageUrl,
      'certifications': certifications,
      'experienceYears': experienceYears,
      'pricePerHour': pricePerHour,
      'isAvailable': isAvailable,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'fcmToken': fcmToken,
    };
  }

  // Create copy with updated fields
  PartnerModel copyWith({
    String? uid,
    String? name,
    String? phone,
    String? email,
    String? gender,
    List<String>? services,
    Map<String, List<String>>? workingHours,
    double? rating,
    int? totalReviews,
    GeoPoint? location,
    String? address,
    String? bio,
    String? profileImageUrl,
    List<String>? certifications,
    int? experienceYears,
    double? pricePerHour,
    bool? isAvailable,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? fcmToken,
  }) {
    return PartnerModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      services: services ?? this.services,
      workingHours: workingHours ?? this.workingHours,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      location: location ?? this.location,
      address: address ?? this.address,
      bio: bio ?? this.bio,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      certifications: certifications ?? this.certifications,
      experienceYears: experienceYears ?? this.experienceYears,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      isAvailable: isAvailable ?? this.isAvailable,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PartnerModel && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;

  @override
  String toString() {
    return 'PartnerModel(uid: $uid, name: $name, rating: $rating, services: $services)';
  }

  // Helper methods
  bool get hasHighRating => rating >= 4.0;
  bool get isExperienced => experienceYears >= 2;
  String get displayRating => rating.toStringAsFixed(1);
  
  // Check if partner is available on specific day and time
  bool isAvailableAt(String day, String timeSlot) {
    if (!isAvailable) return false;
    final dayHours = workingHours[day.toLowerCase()];
    return dayHours?.contains(timeSlot) ?? false;
  }
  
  // Get all available time slots for a day
  List<String> getAvailableTimeSlotsForDay(String day) {
    return workingHours[day.toLowerCase()] ?? [];
  }
}
