import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/booking_request.dart';

/// Data model for BookingRequest with Firestore serialization
class BookingRequestModel extends BookingRequest {
  const BookingRequestModel({
    required super.userId,
    required super.serviceId,
    super.partnerId,
    required super.scheduledDate,
    required super.timeSlot,
    required super.hours,
    required super.clientAddress,
    required super.clientLatitude,
    required super.clientLongitude,
    super.specialInstructions,
    super.isUrgent = false,
    super.maxDistance = 50.0,
    super.preferredPartnerIds,
  });

  /// Create BookingRequestModel from domain entity
  factory BookingRequestModel.fromEntity(BookingRequest entity) {
    return BookingRequestModel(
      userId: entity.userId,
      serviceId: entity.serviceId,
      partnerId: entity.partnerId,
      scheduledDate: entity.scheduledDate,
      timeSlot: entity.timeSlot,
      hours: entity.hours,
      clientAddress: entity.clientAddress,
      clientLatitude: entity.clientLatitude,
      clientLongitude: entity.clientLongitude,
      specialInstructions: entity.specialInstructions,
      isUrgent: entity.isUrgent,
      maxDistance: entity.maxDistance,
      preferredPartnerIds: entity.preferredPartnerIds,
    );
  }

  /// Create BookingRequestModel from Firestore document
  factory BookingRequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookingRequestModel(
      userId: data['userId'] ?? '',
      serviceId: data['serviceId'] ?? '',
      partnerId: data['partnerId'],
      scheduledDate: data['scheduledDate'] != null
          ? (data['scheduledDate'] as Timestamp).toDate()
          : DateTime.now(),
      timeSlot: data['timeSlot'] ?? '',
      hours: (data['hours'] ?? 0).toDouble(),
      clientAddress: data['clientAddress'] ?? '',
      clientLatitude: (data['clientLatitude'] ?? 0).toDouble(),
      clientLongitude: (data['clientLongitude'] ?? 0).toDouble(),
      specialInstructions: data['specialInstructions'],
      isUrgent: data['isUrgent'] ?? false,
      maxDistance: (data['maxDistance'] ?? 50.0).toDouble(),
      preferredPartnerIds: data['preferredPartnerIds'] != null
          ? List<String>.from(data['preferredPartnerIds'])
          : null,
    );
  }

  /// Create BookingRequestModel from Map
  factory BookingRequestModel.fromMap(Map<String, dynamic> map) {
    return BookingRequestModel(
      userId: map['userId'] ?? '',
      serviceId: map['serviceId'] ?? '',
      partnerId: map['partnerId'],
      scheduledDate: map['scheduledDate'] is Timestamp
          ? (map['scheduledDate'] as Timestamp).toDate()
          : (map['scheduledDate'] != null 
              ? DateTime.parse(map['scheduledDate'])
              : DateTime.now()),
      timeSlot: map['timeSlot'] ?? '',
      hours: (map['hours'] ?? 0).toDouble(),
      clientAddress: map['clientAddress'] ?? '',
      clientLatitude: (map['clientLatitude'] ?? 0).toDouble(),
      clientLongitude: (map['clientLongitude'] ?? 0).toDouble(),
      specialInstructions: map['specialInstructions'],
      isUrgent: map['isUrgent'] ?? false,
      maxDistance: (map['maxDistance'] ?? 50.0).toDouble(),
      preferredPartnerIds: map['preferredPartnerIds'] != null
          ? List<String>.from(map['preferredPartnerIds'])
          : null,
    );
  }

  /// Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'serviceId': serviceId,
      'partnerId': partnerId,
      'scheduledDate': Timestamp.fromDate(scheduledDate),
      'timeSlot': timeSlot,
      'hours': hours,
      'clientAddress': clientAddress,
      'clientLatitude': clientLatitude,
      'clientLongitude': clientLongitude,
      'specialInstructions': specialInstructions,
      'isUrgent': isUrgent,
      'maxDistance': maxDistance,
      'preferredPartnerIds': preferredPartnerIds,
    };
  }

  /// Convert to domain entity
  BookingRequest toEntity() {
    return BookingRequest(
      userId: userId,
      serviceId: serviceId,
      partnerId: partnerId,
      scheduledDate: scheduledDate,
      timeSlot: timeSlot,
      hours: hours,
      clientAddress: clientAddress,
      clientLatitude: clientLatitude,
      clientLongitude: clientLongitude,
      specialInstructions: specialInstructions,
      isUrgent: isUrgent,
      maxDistance: maxDistance,
      preferredPartnerIds: preferredPartnerIds,
    );
  }

  @override
  String toString() {
    return 'BookingRequestModel(userId: $userId, serviceId: $serviceId, '
        'partnerId: $partnerId, scheduledDate: $scheduledDate, '
        'timeSlot: $timeSlot, hours: $hours, isUrgent: $isUrgent)';
  }
}
