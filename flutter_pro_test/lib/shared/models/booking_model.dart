import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String id;
  final String userId;
  final String partnerId;
  final String serviceId;
  final String serviceName;
  final DateTime scheduledDate;
  final String timeSlot;
  final double hours;
  final double totalPrice;
  final String status;
  final String paymentStatus;
  final String? paymentMethod;
  final String? paymentTransactionId;
  final String clientAddress;
  final GeoPoint clientLocation;
  final String? specialInstructions;
  final String? cancellationReason;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const BookingModel({
    required this.id,
    required this.userId,
    required this.partnerId,
    required this.serviceId,
    required this.serviceName,
    required this.scheduledDate,
    required this.timeSlot,
    required this.hours,
    required this.totalPrice,
    required this.status,
    required this.paymentStatus,
    this.paymentMethod,
    this.paymentTransactionId,
    required this.clientAddress,
    required this.clientLocation,
    this.specialInstructions,
    this.cancellationReason,
    this.completedAt,
    this.cancelledAt,
    required this.createdAt,
    this.updatedAt,
  });

  // Factory constructor from Firestore document
  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookingModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      partnerId: data['partnerId'] ?? '',
      serviceId: data['serviceId'] ?? '',
      serviceName: data['serviceName'] ?? '',
      scheduledDate: (data['scheduledDate'] as Timestamp).toDate(),
      timeSlot: data['timeSlot'] ?? '',
      hours: (data['hours'] ?? 1.0).toDouble(),
      totalPrice: (data['totalPrice'] ?? 0.0).toDouble(),
      status: data['status'] ?? 'pending',
      paymentStatus: data['paymentStatus'] ?? 'unpaid',
      paymentMethod: data['paymentMethod'],
      paymentTransactionId: data['paymentTransactionId'],
      clientAddress: data['clientAddress'] ?? '',
      clientLocation: data['clientLocation'] ?? const GeoPoint(0, 0),
      specialInstructions: data['specialInstructions'],
      cancellationReason: data['cancellationReason'],
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
    );
  }

  // Factory constructor from Map
  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      partnerId: map['partnerId'] ?? '',
      serviceId: map['serviceId'] ?? '',
      serviceName: map['serviceName'] ?? '',
      scheduledDate: map['scheduledDate'] is Timestamp 
          ? (map['scheduledDate'] as Timestamp).toDate()
          : DateTime.parse(map['scheduledDate']),
      timeSlot: map['timeSlot'] ?? '',
      hours: (map['hours'] ?? 1.0).toDouble(),
      totalPrice: (map['totalPrice'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'pending',
      paymentStatus: map['paymentStatus'] ?? 'unpaid',
      paymentMethod: map['paymentMethod'],
      paymentTransactionId: map['paymentTransactionId'],
      clientAddress: map['clientAddress'] ?? '',
      clientLocation: map['clientLocation'] is GeoPoint 
          ? map['clientLocation'] 
          : const GeoPoint(0, 0),
      specialInstructions: map['specialInstructions'],
      cancellationReason: map['cancellationReason'],
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
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'partnerId': partnerId,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'scheduledDate': Timestamp.fromDate(scheduledDate),
      'timeSlot': timeSlot,
      'hours': hours,
      'totalPrice': totalPrice,
      'status': status,
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'paymentTransactionId': paymentTransactionId,
      'clientAddress': clientAddress,
      'clientLocation': clientLocation,
      'specialInstructions': specialInstructions,
      'cancellationReason': cancellationReason,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'cancelledAt': cancelledAt != null ? Timestamp.fromDate(cancelledAt!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  // Convert to JSON for API calls
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'partnerId': partnerId,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'scheduledDate': scheduledDate.toIso8601String(),
      'timeSlot': timeSlot,
      'hours': hours,
      'totalPrice': totalPrice,
      'status': status,
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'paymentTransactionId': paymentTransactionId,
      'clientAddress': clientAddress,
      'clientLocation': {
        'latitude': clientLocation.latitude,
        'longitude': clientLocation.longitude,
      },
      'specialInstructions': specialInstructions,
      'cancellationReason': cancellationReason,
      'completedAt': completedAt?.toIso8601String(),
      'cancelledAt': cancelledAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Create copy with updated fields
  BookingModel copyWith({
    String? id,
    String? userId,
    String? partnerId,
    String? serviceId,
    String? serviceName,
    DateTime? scheduledDate,
    String? timeSlot,
    double? hours,
    double? totalPrice,
    String? status,
    String? paymentStatus,
    String? paymentMethod,
    String? paymentTransactionId,
    String? clientAddress,
    GeoPoint? clientLocation,
    String? specialInstructions,
    String? cancellationReason,
    DateTime? completedAt,
    DateTime? cancelledAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BookingModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      partnerId: partnerId ?? this.partnerId,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      timeSlot: timeSlot ?? this.timeSlot,
      hours: hours ?? this.hours,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentTransactionId: paymentTransactionId ?? this.paymentTransactionId,
      clientAddress: clientAddress ?? this.clientAddress,
      clientLocation: clientLocation ?? this.clientLocation,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      completedAt: completedAt ?? this.completedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BookingModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'BookingModel(id: $id, serviceName: $serviceName, status: $status, scheduledDate: $scheduledDate)';
  }

  // Helper methods
  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isInProgress => status == 'in-progress';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
  
  bool get isPaid => paymentStatus == 'paid';
  bool get isUnpaid => paymentStatus == 'unpaid';
  
  String get formattedPrice => '${totalPrice.toStringAsFixed(0)}k VND';
  String get formattedDate => '${scheduledDate.day}/${scheduledDate.month}/${scheduledDate.year}';
  String get formattedDateTime => '$formattedDate - $timeSlot';
  
  // Check if booking can be cancelled
  bool get canBeCancelled {
    if (isCancelled || isCompleted) return false;
    final now = DateTime.now();
    final bookingDateTime = DateTime(
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      int.parse(timeSlot.split(':')[0]),
      int.parse(timeSlot.split(':')[1]),
    );
    // Can cancel if booking is more than 2 hours away
    return bookingDateTime.difference(now).inHours > 2;
  }
  
  // Get status display text
  String get statusDisplayText {
    switch (status) {
      case 'pending':
        return 'Chờ xác nhận';
      case 'confirmed':
        return 'Đã xác nhận';
      case 'in-progress':
        return 'Đang thực hiện';
      case 'completed':
        return 'Hoàn thành';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return status;
    }
  }
  
  // Get payment status display text
  String get paymentStatusDisplayText {
    switch (paymentStatus) {
      case 'paid':
        return 'Đã thanh toán';
      case 'unpaid':
        return 'Chưa thanh toán';
      default:
        return paymentStatus;
    }
  }
}
