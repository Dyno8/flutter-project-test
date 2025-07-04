import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Enum for user roles
enum UserRole {
  client,
  partner;

  String get displayName {
    switch (this) {
      case UserRole.client:
        return 'Khách hàng';
      case UserRole.partner:
        return 'Đối tác';
    }
  }

  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'partner':
        return UserRole.partner;
      default:
        return UserRole.client;
    }
  }
}

/// Model representing a user profile (both client and partner)
class UserProfileModel extends Equatable {
  final String uid;
  final String email;
  final String displayName;
  final String? phoneNumber;
  final String? avatar;
  final UserRole role;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? address;
  final String? city;
  final String? district;
  final double? latitude;
  final double? longitude;
  final String? bio;
  final List<String> preferences; // for clients: preferred services, for partners: specializations
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final bool isProfileComplete;
  final String? fcmToken;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const UserProfileModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.phoneNumber,
    this.avatar,
    this.role = UserRole.client,
    this.gender,
    this.dateOfBirth,
    this.address,
    this.city,
    this.district,
    this.latitude,
    this.longitude,
    this.bio,
    this.preferences = const [],
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    this.isProfileComplete = false,
    this.fcmToken,
    required this.createdAt,
    this.updatedAt,
  });

  /// Create UserProfileModel from Firestore document
  factory UserProfileModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfileModel(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      phoneNumber: data['phoneNumber'],
      avatar: data['avatar'],
      role: UserRole.fromString(data['role'] ?? 'client'),
      gender: data['gender'],
      dateOfBirth: data['dateOfBirth'] != null
          ? (data['dateOfBirth'] as Timestamp).toDate()
          : null,
      address: data['address'],
      city: data['city'],
      district: data['district'],
      latitude: data['latitude']?.toDouble(),
      longitude: data['longitude']?.toDouble(),
      bio: data['bio'],
      preferences: List<String>.from(data['preferences'] ?? []),
      isEmailVerified: data['isEmailVerified'] ?? false,
      isPhoneVerified: data['isPhoneVerified'] ?? false,
      isProfileComplete: data['isProfileComplete'] ?? false,
      fcmToken: data['fcmToken'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Create UserProfileModel from Map
  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      phoneNumber: map['phoneNumber'],
      avatar: map['avatar'],
      role: UserRole.fromString(map['role'] ?? 'client'),
      gender: map['gender'],
      dateOfBirth: map['dateOfBirth'] != null
          ? (map['dateOfBirth'] is Timestamp
              ? (map['dateOfBirth'] as Timestamp).toDate()
              : DateTime.parse(map['dateOfBirth']))
          : null,
      address: map['address'],
      city: map['city'],
      district: map['district'],
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      bio: map['bio'],
      preferences: List<String>.from(map['preferences'] ?? []),
      isEmailVerified: map['isEmailVerified'] ?? false,
      isPhoneVerified: map['isPhoneVerified'] ?? false,
      isProfileComplete: map['isProfileComplete'] ?? false,
      fcmToken: map['fcmToken'],
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

  /// Convert UserProfileModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'avatar': avatar,
      'role': role.name,
      'gender': gender,
      'dateOfBirth': dateOfBirth != null ? Timestamp.fromDate(dateOfBirth!) : null,
      'address': address,
      'city': city,
      'district': district,
      'latitude': latitude,
      'longitude': longitude,
      'bio': bio,
      'preferences': preferences,
      'isEmailVerified': isEmailVerified,
      'isPhoneVerified': isPhoneVerified,
      'isProfileComplete': isProfileComplete,
      'fcmToken': fcmToken,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  /// Convert UserProfileModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'avatar': avatar,
      'role': role.name,
      'gender': gender,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'address': address,
      'city': city,
      'district': district,
      'latitude': latitude,
      'longitude': longitude,
      'bio': bio,
      'preferences': preferences,
      'isEmailVerified': isEmailVerified,
      'isPhoneVerified': isPhoneVerified,
      'isProfileComplete': isProfileComplete,
      'fcmToken': fcmToken,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  UserProfileModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? phoneNumber,
    String? avatar,
    UserRole? role,
    String? gender,
    DateTime? dateOfBirth,
    String? address,
    String? city,
    String? district,
    double? latitude,
    double? longitude,
    String? bio,
    List<String>? preferences,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    bool? isProfileComplete,
    String? fcmToken,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfileModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatar: avatar ?? this.avatar,
      role: role ?? this.role,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      address: address ?? this.address,
      city: city ?? this.city,
      district: district ?? this.district,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      bio: bio ?? this.bio,
      preferences: preferences ?? this.preferences,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get user's age from date of birth
  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  /// Get formatted age string
  String get ageString {
    final userAge = age;
    return userAge != null ? '$userAge tuổi' : 'Chưa cập nhật';
  }

  /// Get full address string
  String get fullAddress {
    final parts = <String>[];
    if (address != null && address!.isNotEmpty) parts.add(address!);
    if (district != null && district!.isNotEmpty) parts.add(district!);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    return parts.join(', ');
  }

  /// Check if user has location data
  bool get hasLocation => latitude != null && longitude != null;

  /// Check if user has complete contact info
  bool get hasCompleteContactInfo {
    return phoneNumber != null && 
           phoneNumber!.isNotEmpty && 
           isPhoneVerified && 
           isEmailVerified;
  }

  /// Get profile completion percentage
  double get profileCompletionPercentage {
    int completedFields = 0;
    int totalFields = 10;

    if (displayName.isNotEmpty) completedFields++;
    if (phoneNumber != null && phoneNumber!.isNotEmpty) completedFields++;
    if (avatar != null && avatar!.isNotEmpty) completedFields++;
    if (gender != null) completedFields++;
    if (dateOfBirth != null) completedFields++;
    if (address != null && address!.isNotEmpty) completedFields++;
    if (city != null && city!.isNotEmpty) completedFields++;
    if (bio != null && bio!.isNotEmpty) completedFields++;
    if (isEmailVerified) completedFields++;
    if (isPhoneVerified) completedFields++;

    return (completedFields / totalFields) * 100;
  }

  /// Get initials for avatar placeholder
  String get initials {
    if (displayName.isEmpty) return 'U';
    final names = displayName.split(' ');
    if (names.length == 1) {
      return names[0].substring(0, 1).toUpperCase();
    } else {
      return '${names[0].substring(0, 1)}${names[names.length - 1].substring(0, 1)}'.toUpperCase();
    }
  }

  @override
  List<Object?> get props => [
        uid,
        email,
        displayName,
        phoneNumber,
        avatar,
        role,
        gender,
        dateOfBirth,
        address,
        city,
        district,
        latitude,
        longitude,
        bio,
        preferences,
        isEmailVerified,
        isPhoneVerified,
        isProfileComplete,
        fcmToken,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'UserProfileModel(uid: $uid, displayName: $displayName, role: ${role.name})';
  }
}
