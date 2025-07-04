import 'package:equatable/equatable.dart';
import '../../domain/entities/booking.dart';
import '../../domain/entities/service.dart';
import '../../domain/entities/partner.dart';

abstract class BookingState extends Equatable {
  const BookingState();

  @override
  List<Object?> get props => [];
}

class BookingInitial extends BookingState {}

class BookingLoading extends BookingState {}

class BookingError extends BookingState {
  final String message;

  const BookingError(this.message);

  @override
  List<Object?> get props => [message];
}

// Service Selection States
class ServicesLoaded extends BookingState {
  final List<Service> services;

  const ServicesLoaded(this.services);

  @override
  List<Object?> get props => [services];
}

class ServiceSelected extends BookingState {
  final Service selectedService;
  final List<Service> allServices;

  const ServiceSelected({
    required this.selectedService,
    required this.allServices,
  });

  @override
  List<Object?> get props => [selectedService, allServices];
}

// Date & Time Selection States
class DateTimeSelected extends BookingState {
  final Service selectedService;
  final DateTime selectedDate;
  final String? selectedTimeSlot;
  final double? selectedHours;
  final List<Service> allServices;

  const DateTimeSelected({
    required this.selectedService,
    required this.selectedDate,
    this.selectedTimeSlot,
    this.selectedHours,
    required this.allServices,
  });

  @override
  List<Object?> get props => [
        selectedService,
        selectedDate,
        selectedTimeSlot,
        selectedHours,
        allServices,
      ];
}

// Partner Selection States
class PartnersLoading extends BookingState {
  final Service selectedService;
  final DateTime selectedDate;
  final String selectedTimeSlot;
  final double selectedHours;

  const PartnersLoading({
    required this.selectedService,
    required this.selectedDate,
    required this.selectedTimeSlot,
    required this.selectedHours,
  });

  @override
  List<Object?> get props => [selectedService, selectedDate, selectedTimeSlot, selectedHours];
}

class PartnersLoaded extends BookingState {
  final Service selectedService;
  final DateTime selectedDate;
  final String selectedTimeSlot;
  final double selectedHours;
  final List<Partner> availablePartners;

  const PartnersLoaded({
    required this.selectedService,
    required this.selectedDate,
    required this.selectedTimeSlot,
    required this.selectedHours,
    required this.availablePartners,
  });

  @override
  List<Object?> get props => [
        selectedService,
        selectedDate,
        selectedTimeSlot,
        selectedHours,
        availablePartners,
      ];
}

class PartnerSelected extends BookingState {
  final Service selectedService;
  final DateTime selectedDate;
  final String selectedTimeSlot;
  final double selectedHours;
  final Partner selectedPartner;
  final List<Partner> availablePartners;

  const PartnerSelected({
    required this.selectedService,
    required this.selectedDate,
    required this.selectedTimeSlot,
    required this.selectedHours,
    required this.selectedPartner,
    required this.availablePartners,
  });

  @override
  List<Object?> get props => [
        selectedService,
        selectedDate,
        selectedTimeSlot,
        selectedHours,
        selectedPartner,
        availablePartners,
      ];
}

// Booking Confirmation States
class BookingReadyForConfirmation extends BookingState {
  final Service selectedService;
  final DateTime selectedDate;
  final String selectedTimeSlot;
  final double selectedHours;
  final Partner selectedPartner;
  final String clientAddress;
  final double clientLatitude;
  final double clientLongitude;
  final String? specialInstructions;
  final double totalPrice;

  const BookingReadyForConfirmation({
    required this.selectedService,
    required this.selectedDate,
    required this.selectedTimeSlot,
    required this.selectedHours,
    required this.selectedPartner,
    required this.clientAddress,
    required this.clientLatitude,
    required this.clientLongitude,
    this.specialInstructions,
    required this.totalPrice,
  });

  @override
  List<Object?> get props => [
        selectedService,
        selectedDate,
        selectedTimeSlot,
        selectedHours,
        selectedPartner,
        clientAddress,
        clientLatitude,
        clientLongitude,
        specialInstructions,
        totalPrice,
      ];
}

class BookingCreating extends BookingState {}

class BookingCreated extends BookingState {
  final Booking booking;

  const BookingCreated(this.booking);

  @override
  List<Object?> get props => [booking];
}

class BookingConfirmed extends BookingState {
  final Booking booking;

  const BookingConfirmed(this.booking);

  @override
  List<Object?> get props => [booking];
}

// Booking Management States
class UserBookingsLoaded extends BookingState {
  final List<Booking> bookings;

  const UserBookingsLoaded(this.bookings);

  @override
  List<Object?> get props => [bookings];
}

class PartnerBookingsLoaded extends BookingState {
  final List<Booking> bookings;

  const PartnerBookingsLoaded(this.bookings);

  @override
  List<Object?> get props => [bookings];
}

class BookingUpdated extends BookingState {
  final Booking booking;

  const BookingUpdated(this.booking);

  @override
  List<Object?> get props => [booking];
}

class BookingCancelled extends BookingState {
  final Booking booking;

  const BookingCancelled(this.booking);

  @override
  List<Object?> get props => [booking];
}

class BookingStarted extends BookingState {
  final Booking booking;

  const BookingStarted(this.booking);

  @override
  List<Object?> get props => [booking];
}

class BookingCompleted extends BookingState {
  final Booking booking;

  const BookingCompleted(this.booking);

  @override
  List<Object?> get props => [booking];
}
