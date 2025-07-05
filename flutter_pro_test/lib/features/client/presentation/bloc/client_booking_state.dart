import 'package:equatable/equatable.dart';
import '../../../booking/domain/entities/service.dart';
import '../../../booking/domain/entities/partner.dart';
import '../../../booking/domain/entities/booking.dart';
import '../../domain/entities/payment_request.dart';
import '../../domain/entities/payment_result.dart';

/// Enum for booking flow steps
enum BookingStep {
  serviceSelection,
  dateTimeSelection,
  partnerSelection,
  bookingDetails,
  paymentMethod,
  confirmation,
  completed,
}

/// Base class for all client booking states
abstract class ClientBookingState extends Equatable {
  const ClientBookingState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ClientBookingInitial extends ClientBookingState {
  const ClientBookingInitial();
}

/// Loading state
class ClientBookingLoading extends ClientBookingState {
  const ClientBookingLoading();
}

/// Error state
class ClientBookingError extends ClientBookingState {
  final String message;

  const ClientBookingError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Services loaded state
class ServicesLoadedState extends ClientBookingState {
  final List<Service> services;
  final List<Service> filteredServices;
  final String? searchQuery;

  const ServicesLoadedState({
    required this.services,
    required this.filteredServices,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [services, filteredServices, searchQuery];

  ServicesLoadedState copyWith({
    List<Service>? services,
    List<Service>? filteredServices,
    String? searchQuery,
  }) {
    return ServicesLoadedState(
      services: services ?? this.services,
      filteredServices: filteredServices ?? this.filteredServices,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

/// Booking flow state with all selected data
class BookingFlowState extends ClientBookingState {
  final BookingStep currentStep;
  final Service? selectedService;
  final DateTime? selectedDate;
  final String? selectedTimeSlot;
  final double? selectedHours;
  final String? clientAddress;
  final double? clientLatitude;
  final double? clientLongitude;
  final List<Partner>? availablePartners;
  final Partner? selectedPartner;
  final String? specialInstructions;
  final bool isUrgent;
  final List<PaymentMethod>? paymentMethods;
  final PaymentMethod? selectedPaymentMethod;
  final double? totalPrice;
  final bool isLoading;
  final String? error;

  const BookingFlowState({
    required this.currentStep,
    this.selectedService,
    this.selectedDate,
    this.selectedTimeSlot,
    this.selectedHours,
    this.clientAddress,
    this.clientLatitude,
    this.clientLongitude,
    this.availablePartners,
    this.selectedPartner,
    this.specialInstructions,
    this.isUrgent = false,
    this.paymentMethods,
    this.selectedPaymentMethod,
    this.totalPrice,
    this.isLoading = false,
    this.error,
  });

  @override
  List<Object?> get props => [
        currentStep,
        selectedService,
        selectedDate,
        selectedTimeSlot,
        selectedHours,
        clientAddress,
        clientLatitude,
        clientLongitude,
        availablePartners,
        selectedPartner,
        specialInstructions,
        isUrgent,
        paymentMethods,
        selectedPaymentMethod,
        totalPrice,
        isLoading,
        error,
      ];

  /// Check if current step is valid and can proceed
  bool get canProceedToNextStep {
    switch (currentStep) {
      case BookingStep.serviceSelection:
        return selectedService != null;
      case BookingStep.dateTimeSelection:
        return selectedDate != null && 
               selectedTimeSlot != null && 
               selectedHours != null;
      case BookingStep.partnerSelection:
        return selectedPartner != null;
      case BookingStep.bookingDetails:
        return clientAddress != null && 
               clientLatitude != null && 
               clientLongitude != null;
      case BookingStep.paymentMethod:
        return selectedPaymentMethod != null;
      case BookingStep.confirmation:
        return true;
      case BookingStep.completed:
        return false;
    }
  }

  /// Check if can go back to previous step
  bool get canGoBack {
    return currentStep != BookingStep.serviceSelection && 
           currentStep != BookingStep.completed;
  }

  /// Calculate total price
  double calculateTotalPrice() {
    if (selectedService == null || selectedHours == null) return 0.0;
    
    double basePrice = selectedService!.basePrice * selectedHours!;
    
    // Add urgent fee if applicable
    if (isUrgent) {
      basePrice *= 1.2; // 20% urgent fee
    }
    
    return basePrice;
  }

  BookingFlowState copyWith({
    BookingStep? currentStep,
    Service? selectedService,
    DateTime? selectedDate,
    String? selectedTimeSlot,
    double? selectedHours,
    String? clientAddress,
    double? clientLatitude,
    double? clientLongitude,
    List<Partner>? availablePartners,
    Partner? selectedPartner,
    String? specialInstructions,
    bool? isUrgent,
    List<PaymentMethod>? paymentMethods,
    PaymentMethod? selectedPaymentMethod,
    double? totalPrice,
    bool? isLoading,
    String? error,
  }) {
    return BookingFlowState(
      currentStep: currentStep ?? this.currentStep,
      selectedService: selectedService ?? this.selectedService,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTimeSlot: selectedTimeSlot ?? this.selectedTimeSlot,
      selectedHours: selectedHours ?? this.selectedHours,
      clientAddress: clientAddress ?? this.clientAddress,
      clientLatitude: clientLatitude ?? this.clientLatitude,
      clientLongitude: clientLongitude ?? this.clientLongitude,
      availablePartners: availablePartners ?? this.availablePartners,
      selectedPartner: selectedPartner ?? this.selectedPartner,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      isUrgent: isUrgent ?? this.isUrgent,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      selectedPaymentMethod: selectedPaymentMethod ?? this.selectedPaymentMethod,
      totalPrice: totalPrice ?? this.totalPrice,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Booking created state
class BookingCreatedState extends ClientBookingState {
  final Booking booking;

  const BookingCreatedState(this.booking);

  @override
  List<Object?> get props => [booking];
}

/// Payment processing state
class PaymentProcessingState extends ClientBookingState {
  final String bookingId;

  const PaymentProcessingState(this.bookingId);

  @override
  List<Object?> get props => [bookingId];
}

/// Payment completed state
class PaymentCompletedState extends ClientBookingState {
  final PaymentResult paymentResult;
  final Booking booking;

  const PaymentCompletedState({
    required this.paymentResult,
    required this.booking,
  });

  @override
  List<Object?> get props => [paymentResult, booking];
}

/// Booking history loaded state
class BookingHistoryLoadedState extends ClientBookingState {
  final List<Booking> bookings;

  const BookingHistoryLoadedState(this.bookings);

  @override
  List<Object?> get props => [bookings];
}

/// Booking cancelled state
class BookingCancelledState extends ClientBookingState {
  final String bookingId;

  const BookingCancelledState(this.bookingId);

  @override
  List<Object?> get props => [bookingId];
}
