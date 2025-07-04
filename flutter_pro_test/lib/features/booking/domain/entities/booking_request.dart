import 'package:equatable/equatable.dart';

/// Domain entity for booking request (used when creating a new booking)
class BookingRequest extends Equatable {
  final String userId;
  final String serviceId;
  final String serviceName;
  final DateTime scheduledDate;
  final String timeSlot;
  final double hours;
  final double totalPrice;
  final String clientAddress;
  final double clientLatitude;
  final double clientLongitude;
  final String? specialInstructions;
  final String? preferredPartnerId; // Optional: if client wants specific partner
  final bool autoAssignPartner;

  const BookingRequest({
    required this.userId,
    required this.serviceId,
    required this.serviceName,
    required this.scheduledDate,
    required this.timeSlot,
    required this.hours,
    required this.totalPrice,
    required this.clientAddress,
    required this.clientLatitude,
    required this.clientLongitude,
    this.specialInstructions,
    this.preferredPartnerId,
    this.autoAssignPartner = true,
  });

  // Helper methods
  String get formattedPrice => '${totalPrice.toStringAsFixed(0)}k VND';
  String get formattedDate =>
      '${scheduledDate.day}/${scheduledDate.month}/${scheduledDate.year}';
  String get formattedDateTime => '$formattedDate - $timeSlot';

  // Validation
  bool get isValid {
    return userId.isNotEmpty &&
        serviceId.isNotEmpty &&
        serviceName.isNotEmpty &&
        scheduledDate.isAfter(DateTime.now()) &&
        timeSlot.isNotEmpty &&
        hours > 0 &&
        totalPrice > 0 &&
        clientAddress.isNotEmpty;
  }

  List<String> get validationErrors {
    final errors = <String>[];
    
    if (userId.isEmpty) errors.add('User ID is required');
    if (serviceId.isEmpty) errors.add('Service ID is required');
    if (serviceName.isEmpty) errors.add('Service name is required');
    if (!scheduledDate.isAfter(DateTime.now())) {
      errors.add('Scheduled date must be in the future');
    }
    if (timeSlot.isEmpty) errors.add('Time slot is required');
    if (hours <= 0) errors.add('Hours must be greater than 0');
    if (totalPrice <= 0) errors.add('Total price must be greater than 0');
    if (clientAddress.isEmpty) errors.add('Client address is required');
    
    return errors;
  }

  @override
  List<Object?> get props => [
        userId,
        serviceId,
        serviceName,
        scheduledDate,
        timeSlot,
        hours,
        totalPrice,
        clientAddress,
        clientLatitude,
        clientLongitude,
        specialInstructions,
        preferredPartnerId,
        autoAssignPartner,
      ];

  @override
  String toString() {
    return 'BookingRequest(serviceId: $serviceId, scheduledDate: $scheduledDate, timeSlot: $timeSlot)';
  }
}
