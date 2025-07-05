import 'package:equatable/equatable.dart';
import '../../../booking/domain/entities/service.dart';
import '../../../booking/domain/entities/partner.dart';
import '../../domain/entities/payment_request.dart';

/// Base class for all client booking events
abstract class ClientBookingEvent extends Equatable {
  const ClientBookingEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load available services
class LoadAvailableServicesEvent extends ClientBookingEvent {
  const LoadAvailableServicesEvent();
}

/// Event to search services
class SearchServicesEvent extends ClientBookingEvent {
  final String query;

  const SearchServicesEvent(this.query);

  @override
  List<Object?> get props => [query];
}

/// Event to select a service
class SelectServiceEvent extends ClientBookingEvent {
  final Service service;

  const SelectServiceEvent(this.service);

  @override
  List<Object?> get props => [service];
}

/// Event to select date and time
class SelectDateTimeEvent extends ClientBookingEvent {
  final DateTime date;
  final String timeSlot;
  final double hours;

  const SelectDateTimeEvent({
    required this.date,
    required this.timeSlot,
    required this.hours,
  });

  @override
  List<Object?> get props => [date, timeSlot, hours];
}

/// Event to set client location
class SetClientLocationEvent extends ClientBookingEvent {
  final String address;
  final double latitude;
  final double longitude;

  const SetClientLocationEvent({
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [address, latitude, longitude];
}

/// Event to load available partners
class LoadAvailablePartnersEvent extends ClientBookingEvent {
  const LoadAvailablePartnersEvent();
}

/// Event to select a partner
class SelectPartnerEvent extends ClientBookingEvent {
  final Partner partner;

  const SelectPartnerEvent(this.partner);

  @override
  List<Object?> get props => [partner];
}

/// Event to set special instructions
class SetSpecialInstructionsEvent extends ClientBookingEvent {
  final String? instructions;

  const SetSpecialInstructionsEvent(this.instructions);

  @override
  List<Object?> get props => [instructions];
}

/// Event to set urgent booking flag
class SetUrgentBookingEvent extends ClientBookingEvent {
  final bool isUrgent;

  const SetUrgentBookingEvent(this.isUrgent);

  @override
  List<Object?> get props => [isUrgent];
}

/// Event to load payment methods
class LoadPaymentMethodsEvent extends ClientBookingEvent {
  const LoadPaymentMethodsEvent();
}

/// Event to select payment method
class SelectPaymentMethodEvent extends ClientBookingEvent {
  final PaymentMethod paymentMethod;

  const SelectPaymentMethodEvent(this.paymentMethod);

  @override
  List<Object?> get props => [paymentMethod];
}

/// Event to create booking
class CreateBookingEvent extends ClientBookingEvent {
  final String userId;

  const CreateBookingEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Event to process payment
class ProcessPaymentEvent extends ClientBookingEvent {
  final String bookingId;

  const ProcessPaymentEvent(this.bookingId);

  @override
  List<Object?> get props => [bookingId];
}

/// Event to load client booking history
class LoadClientBookingHistoryEvent extends ClientBookingEvent {
  final String userId;

  const LoadClientBookingHistoryEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Event to cancel booking
class CancelBookingEvent extends ClientBookingEvent {
  final String bookingId;
  final String? reason;

  const CancelBookingEvent({
    required this.bookingId,
    this.reason,
  });

  @override
  List<Object?> get props => [bookingId, reason];
}

/// Event to reset booking flow
class ResetBookingFlowEvent extends ClientBookingEvent {
  const ResetBookingFlowEvent();
}

/// Event to clear errors
class ClearErrorEvent extends ClientBookingEvent {
  const ClearErrorEvent();
}

/// Event to go back to previous step
class GoBackStepEvent extends ClientBookingEvent {
  const GoBackStepEvent();
}

/// Event to go to next step
class GoNextStepEvent extends ClientBookingEvent {
  const GoNextStepEvent();
}
