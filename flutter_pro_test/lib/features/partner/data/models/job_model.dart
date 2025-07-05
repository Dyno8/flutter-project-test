import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/job.dart';

/// Data model for Job entity
class JobModel extends Equatable {
  final String id;
  final String bookingId;
  final String partnerId;
  final String userId;
  final String clientName;
  final String clientPhone;
  final String serviceId;
  final String serviceName;
  final DateTime scheduledDate;
  final String timeSlot;
  final double hours;
  final double totalPrice;
  final double partnerEarnings;
  final String status;
  final String priority;
  final String clientAddress;
  final GeoPoint clientLocation;
  final String? specialInstructions;
  final String? rejectionReason;
  final DateTime? acceptedAt;
  final DateTime? rejectedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isUrgent;
  final double? distanceFromPartner;

  const JobModel({
    required this.id,
    required this.bookingId,
    required this.partnerId,
    required this.userId,
    required this.clientName,
    required this.clientPhone,
    required this.serviceId,
    required this.serviceName,
    required this.scheduledDate,
    required this.timeSlot,
    required this.hours,
    required this.totalPrice,
    required this.partnerEarnings,
    required this.status,
    required this.priority,
    required this.clientAddress,
    required this.clientLocation,
    this.specialInstructions,
    this.rejectionReason,
    this.acceptedAt,
    this.rejectedAt,
    this.startedAt,
    this.completedAt,
    this.cancelledAt,
    required this.createdAt,
    this.updatedAt,
    this.isUrgent = false,
    this.distanceFromPartner,
  });

  /// Factory constructor from Firestore document
  factory JobModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return JobModel(
      id: doc.id,
      bookingId: data['bookingId'] ?? '',
      partnerId: data['partnerId'] ?? '',
      userId: data['userId'] ?? '',
      clientName: data['clientName'] ?? '',
      clientPhone: data['clientPhone'] ?? '',
      serviceId: data['serviceId'] ?? '',
      serviceName: data['serviceName'] ?? '',
      scheduledDate: (data['scheduledDate'] as Timestamp).toDate(),
      timeSlot: data['timeSlot'] ?? '',
      hours: (data['hours'] ?? 1.0).toDouble(),
      totalPrice: (data['totalPrice'] ?? 0.0).toDouble(),
      partnerEarnings: (data['partnerEarnings'] ?? 0.0).toDouble(),
      status: data['status'] ?? 'pending',
      priority: data['priority'] ?? 'normal',
      clientAddress: data['clientAddress'] ?? '',
      clientLocation: data['clientLocation'] ?? const GeoPoint(0, 0),
      specialInstructions: data['specialInstructions'],
      rejectionReason: data['rejectionReason'],
      acceptedAt: data['acceptedAt'] != null 
          ? (data['acceptedAt'] as Timestamp).toDate() 
          : null,
      rejectedAt: data['rejectedAt'] != null 
          ? (data['rejectedAt'] as Timestamp).toDate() 
          : null,
      startedAt: data['startedAt'] != null 
          ? (data['startedAt'] as Timestamp).toDate() 
          : null,
      completedAt: data['completedAt'] != null 
          ? (data['completedAt'] as Timestamp).toDate() 
          : null,
      cancelledAt: data['cancelledAt'] != null 
          ? (data['cancelledAt'] as Timestamp).toDate() 
          : null,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
      isUrgent: data['isUrgent'] ?? false,
      distanceFromPartner: data['distanceFromPartner']?.toDouble(),
    );
  }

  /// Factory constructor from Map
  factory JobModel.fromMap(Map<String, dynamic> map) {
    return JobModel(
      id: map['id'] ?? '',
      bookingId: map['bookingId'] ?? '',
      partnerId: map['partnerId'] ?? '',
      userId: map['userId'] ?? '',
      clientName: map['clientName'] ?? '',
      clientPhone: map['clientPhone'] ?? '',
      serviceId: map['serviceId'] ?? '',
      serviceName: map['serviceName'] ?? '',
      scheduledDate: map['scheduledDate'] is Timestamp
          ? (map['scheduledDate'] as Timestamp).toDate()
          : DateTime.parse(map['scheduledDate']),
      timeSlot: map['timeSlot'] ?? '',
      hours: (map['hours'] ?? 1.0).toDouble(),
      totalPrice: (map['totalPrice'] ?? 0.0).toDouble(),
      partnerEarnings: (map['partnerEarnings'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'pending',
      priority: map['priority'] ?? 'normal',
      clientAddress: map['clientAddress'] ?? '',
      clientLocation: map['clientLocation'] is GeoPoint
          ? map['clientLocation']
          : GeoPoint(
              map['clientLocation']['latitude'] ?? 0.0,
              map['clientLocation']['longitude'] ?? 0.0,
            ),
      specialInstructions: map['specialInstructions'],
      rejectionReason: map['rejectionReason'],
      acceptedAt: map['acceptedAt'] != null
          ? (map['acceptedAt'] is Timestamp
              ? (map['acceptedAt'] as Timestamp).toDate()
              : DateTime.parse(map['acceptedAt']))
          : null,
      rejectedAt: map['rejectedAt'] != null
          ? (map['rejectedAt'] is Timestamp
              ? (map['rejectedAt'] as Timestamp).toDate()
              : DateTime.parse(map['rejectedAt']))
          : null,
      startedAt: map['startedAt'] != null
          ? (map['startedAt'] is Timestamp
              ? (map['startedAt'] as Timestamp).toDate()
              : DateTime.parse(map['startedAt']))
          : null,
      completedAt: map['completedAt'] != null
          ? (map['completedAt'] is Timestamp
              ? (map['completedAt'] as Timestamp).toDate()
              : DateTime.parse(map['completedAt']))
          : null,
      cancelledAt: map['cancelledAt'] != null
          ? (map['cancelledAt'] is Timestamp
              ? (map['cancelledAt'] as Timestamp).toDate()
              : DateTime.parse(map['cancelledAt']))
          : null,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] is Timestamp
              ? (map['updatedAt'] as Timestamp).toDate()
              : DateTime.parse(map['updatedAt']))
          : null,
      isUrgent: map['isUrgent'] ?? false,
      distanceFromPartner: map['distanceFromPartner']?.toDouble(),
    );
  }

  /// Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookingId': bookingId,
      'partnerId': partnerId,
      'userId': userId,
      'clientName': clientName,
      'clientPhone': clientPhone,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'scheduledDate': Timestamp.fromDate(scheduledDate),
      'timeSlot': timeSlot,
      'hours': hours,
      'totalPrice': totalPrice,
      'partnerEarnings': partnerEarnings,
      'status': status,
      'priority': priority,
      'clientAddress': clientAddress,
      'clientLocation': clientLocation,
      'specialInstructions': specialInstructions,
      'rejectionReason': rejectionReason,
      'acceptedAt': acceptedAt != null ? Timestamp.fromDate(acceptedAt!) : null,
      'rejectedAt': rejectedAt != null ? Timestamp.fromDate(rejectedAt!) : null,
      'startedAt': startedAt != null ? Timestamp.fromDate(startedAt!) : null,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'cancelledAt': cancelledAt != null ? Timestamp.fromDate(cancelledAt!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'isUrgent': isUrgent,
      'distanceFromPartner': distanceFromPartner,
    };
  }

  /// Convert to domain entity
  Job toEntity() {
    return Job(
      id: id,
      bookingId: bookingId,
      partnerId: partnerId,
      userId: userId,
      clientName: clientName,
      clientPhone: clientPhone,
      serviceId: serviceId,
      serviceName: serviceName,
      scheduledDate: scheduledDate,
      timeSlot: timeSlot,
      hours: hours,
      totalPrice: totalPrice,
      partnerEarnings: partnerEarnings,
      status: JobStatus.fromString(status),
      priority: JobPriority.fromString(priority),
      clientAddress: clientAddress,
      clientLatitude: clientLocation.latitude,
      clientLongitude: clientLocation.longitude,
      specialInstructions: specialInstructions,
      rejectionReason: rejectionReason,
      acceptedAt: acceptedAt,
      rejectedAt: rejectedAt,
      startedAt: startedAt,
      completedAt: completedAt,
      cancelledAt: cancelledAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isUrgent: isUrgent,
      distanceFromPartner: distanceFromPartner,
    );
  }

  /// Create from domain entity
  factory JobModel.fromEntity(Job job) {
    return JobModel(
      id: job.id,
      bookingId: job.bookingId,
      partnerId: job.partnerId,
      userId: job.userId,
      clientName: job.clientName,
      clientPhone: job.clientPhone,
      serviceId: job.serviceId,
      serviceName: job.serviceName,
      scheduledDate: job.scheduledDate,
      timeSlot: job.timeSlot,
      hours: job.hours,
      totalPrice: job.totalPrice,
      partnerEarnings: job.partnerEarnings,
      status: job.status.name,
      priority: job.priority.name,
      clientAddress: job.clientAddress,
      clientLocation: GeoPoint(job.clientLatitude, job.clientLongitude),
      specialInstructions: job.specialInstructions,
      rejectionReason: job.rejectionReason,
      acceptedAt: job.acceptedAt,
      rejectedAt: job.rejectedAt,
      startedAt: job.startedAt,
      completedAt: job.completedAt,
      cancelledAt: job.cancelledAt,
      createdAt: job.createdAt,
      updatedAt: job.updatedAt,
      isUrgent: job.isUrgent,
      distanceFromPartner: job.distanceFromPartner,
    );
  }

  @override
  List<Object?> get props => [
        id,
        bookingId,
        partnerId,
        userId,
        clientName,
        clientPhone,
        serviceId,
        serviceName,
        scheduledDate,
        timeSlot,
        hours,
        totalPrice,
        partnerEarnings,
        status,
        priority,
        clientAddress,
        clientLocation,
        specialInstructions,
        rejectionReason,
        acceptedAt,
        rejectedAt,
        startedAt,
        completedAt,
        cancelledAt,
        createdAt,
        updatedAt,
        isUrgent,
        distanceFromPartner,
      ];
}
