import 'package:equatable/equatable.dart';

import '../../domain/entities/booking.dart';

abstract class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object?> get props => [];
}

// Service Selection Events
class LoadServicesEvent extends BookingEvent {}

class SelectServiceEvent extends BookingEvent {
  final String serviceId;
  final String serviceName;
  final double basePrice;

  const SelectServiceEvent({
    required this.serviceId,
    required this.serviceName,
    required this.basePrice,
  });

  @override
  List<Object?> get props => [serviceId, serviceName, basePrice];
}

// Date & Time Selection Events
class SelectDateEvent extends BookingEvent {
  final DateTime selectedDate;

  const SelectDateEvent(this.selectedDate);

  @override
  List<Object?> get props => [selectedDate];
}

class SelectTimeSlotEvent extends BookingEvent {
  final String timeSlot;
  final double hours;

  const SelectTimeSlotEvent({required this.timeSlot, required this.hours});

  @override
  List<Object?> get props => [timeSlot, hours];
}

// Partner Selection Events
class LoadAvailablePartnersEvent extends BookingEvent {
  final String serviceId;
  final DateTime date;
  final String timeSlot;
  final double? clientLatitude;
  final double? clientLongitude;

  const LoadAvailablePartnersEvent({
    required this.serviceId,
    required this.date,
    required this.timeSlot,
    this.clientLatitude,
    this.clientLongitude,
  });

  @override
  List<Object?> get props => [
    serviceId,
    date,
    timeSlot,
    clientLatitude,
    clientLongitude,
  ];
}

class SelectPartnerEvent extends BookingEvent {
  final String partnerId;
  final String partnerName;
  final double partnerPrice;

  const SelectPartnerEvent({
    required this.partnerId,
    required this.partnerName,
    required this.partnerPrice,
  });

  @override
  List<Object?> get props => [partnerId, partnerName, partnerPrice];
}

// Address & Instructions Events
class SetClientAddressEvent extends BookingEvent {
  final String address;
  final double latitude;
  final double longitude;

  const SetClientAddressEvent({
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [address, latitude, longitude];
}

class SetSpecialInstructionsEvent extends BookingEvent {
  final String instructions;

  const SetSpecialInstructionsEvent(this.instructions);

  @override
  List<Object?> get props => [instructions];
}

// Booking Creation Events
class CreateBookingEvent extends BookingEvent {
  final String userId;

  const CreateBookingEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class ConfirmBookingEvent extends BookingEvent {
  final String bookingId;
  final String partnerId;

  const ConfirmBookingEvent({required this.bookingId, required this.partnerId});

  @override
  List<Object?> get props => [bookingId, partnerId];
}

// Booking Management Events
class LoadUserBookingsEvent extends BookingEvent {
  final String userId;
  final BookingStatus? status;

  const LoadUserBookingsEvent({required this.userId, this.status});

  @override
  List<Object?> get props => [userId, status];
}

class LoadPartnerBookingsEvent extends BookingEvent {
  final String partnerId;
  final BookingStatus? status;

  const LoadPartnerBookingsEvent({required this.partnerId, this.status});

  @override
  List<Object?> get props => [partnerId, status];
}

class CancelBookingEvent extends BookingEvent {
  final String bookingId;
  final String cancellationReason;

  const CancelBookingEvent({
    required this.bookingId,
    required this.cancellationReason,
  });

  @override
  List<Object?> get props => [bookingId, cancellationReason];
}

class StartBookingEvent extends BookingEvent {
  final String bookingId;
  final String partnerId;

  const StartBookingEvent({required this.bookingId, required this.partnerId});

  @override
  List<Object?> get props => [bookingId, partnerId];
}

class CompleteBookingEvent extends BookingEvent {
  final String bookingId;
  final String partnerId;

  const CompleteBookingEvent({
    required this.bookingId,
    required this.partnerId,
  });

  @override
  List<Object?> get props => [bookingId, partnerId];
}

// Reset Events
class ResetBookingFlowEvent extends BookingEvent {}

class ClearBookingErrorEvent extends BookingEvent {}
