import 'package:equatable/equatable.dart';

/// Domain entity representing a booking request from client
class BookingRequest extends Equatable {
  final String userId;
  final String serviceId;
  final String? partnerId; // Optional - can be auto-assigned
  final DateTime scheduledDate;
  final String timeSlot;
  final double hours;
  final String clientAddress;
  final double clientLatitude;
  final double clientLongitude;
  final String? specialInstructions;
  final bool isUrgent;
  final double? maxDistance; // For partner matching
  final List<String>? preferredPartnerIds; // Preferred partners

  const BookingRequest({
    required this.userId,
    required this.serviceId,
    this.partnerId,
    required this.scheduledDate,
    required this.timeSlot,
    required this.hours,
    required this.clientAddress,
    required this.clientLatitude,
    required this.clientLongitude,
    this.specialInstructions,
    this.isUrgent = false,
    this.maxDistance = 50.0,
    this.preferredPartnerIds,
  });

  /// Calculate total price based on service base price
  double calculateTotalPrice(double serviceBasePrice) {
    double baseTotal = serviceBasePrice * hours;
    
    // Add urgent fee if applicable
    if (isUrgent) {
      baseTotal *= 1.2; // 20% urgent fee
    }
    
    return baseTotal;
  }

  /// Check if booking is for today
  bool get isToday {
    final now = DateTime.now();
    return scheduledDate.year == now.year &&
           scheduledDate.month == now.month &&
           scheduledDate.day == now.day;
  }

  /// Check if booking is for tomorrow
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return scheduledDate.year == tomorrow.year &&
           scheduledDate.month == tomorrow.month &&
           scheduledDate.day == tomorrow.day;
  }

  /// Get formatted date string
  String get formattedDate {
    return '${scheduledDate.day}/${scheduledDate.month}/${scheduledDate.year}';
  }

  /// Get formatted date and time string
  String get formattedDateTime {
    return '$formattedDate - $timeSlot';
  }

  /// Check if the booking request is valid
  bool get isValid {
    // Check if scheduled date is in the future
    final now = DateTime.now();
    final bookingDateTime = DateTime(
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      int.parse(timeSlot.split(':')[0]),
      int.parse(timeSlot.split(':')[1]),
    );
    
    if (bookingDateTime.isBefore(now)) {
      return false;
    }

    // Check required fields
    if (userId.isEmpty || serviceId.isEmpty || clientAddress.isEmpty) {
      return false;
    }

    // Check hours is positive
    if (hours <= 0) {
      return false;
    }

    // Check coordinates are valid
    if (clientLatitude < -90 || clientLatitude > 90 ||
        clientLongitude < -180 || clientLongitude > 180) {
      return false;
    }

    return true;
  }

  @override
  List<Object?> get props => [
        userId,
        serviceId,
        partnerId,
        scheduledDate,
        timeSlot,
        hours,
        clientAddress,
        clientLatitude,
        clientLongitude,
        specialInstructions,
        isUrgent,
        maxDistance,
        preferredPartnerIds,
      ];

  BookingRequest copyWith({
    String? userId,
    String? serviceId,
    String? partnerId,
    DateTime? scheduledDate,
    String? timeSlot,
    double? hours,
    String? clientAddress,
    double? clientLatitude,
    double? clientLongitude,
    String? specialInstructions,
    bool? isUrgent,
    double? maxDistance,
    List<String>? preferredPartnerIds,
  }) {
    return BookingRequest(
      userId: userId ?? this.userId,
      serviceId: serviceId ?? this.serviceId,
      partnerId: partnerId ?? this.partnerId,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      timeSlot: timeSlot ?? this.timeSlot,
      hours: hours ?? this.hours,
      clientAddress: clientAddress ?? this.clientAddress,
      clientLatitude: clientLatitude ?? this.clientLatitude,
      clientLongitude: clientLongitude ?? this.clientLongitude,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      isUrgent: isUrgent ?? this.isUrgent,
      maxDistance: maxDistance ?? this.maxDistance,
      preferredPartnerIds: preferredPartnerIds ?? this.preferredPartnerIds,
    );
  }

  @override
  String toString() {
    return 'BookingRequest(userId: $userId, serviceId: $serviceId, '
        'partnerId: $partnerId, scheduledDate: $scheduledDate, '
        'timeSlot: $timeSlot, hours: $hours, isUrgent: $isUrgent)';
  }
}
