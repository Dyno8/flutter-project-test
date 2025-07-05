import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_available_services.dart';
import '../../domain/usecases/search_available_partners.dart';
import '../../domain/usecases/create_booking.dart';
import '../../domain/usecases/process_payment.dart';
import '../../domain/usecases/get_client_bookings.dart';
import '../../domain/entities/booking_request.dart';
import '../../domain/entities/payment_request.dart';
import 'client_booking_event.dart';
import 'client_booking_state.dart';

/// BLoC for managing client booking flow
class ClientBookingBloc extends Bloc<ClientBookingEvent, ClientBookingState> {
  final GetAvailableServices _getAvailableServices;
  final SearchAvailablePartners _searchAvailablePartners;
  final CreateBooking _createBooking;
  final ProcessPayment _processPayment;
  final GetAvailablePaymentMethods _getAvailablePaymentMethods;
  final GetClientBookings _getClientBookings;

  ClientBookingBloc({
    required GetAvailableServices getAvailableServices,
    required SearchAvailablePartners searchAvailablePartners,
    required CreateBooking createBooking,
    required ProcessPayment processPayment,
    required GetAvailablePaymentMethods getAvailablePaymentMethods,
    required GetClientBookings getClientBookings,
  }) : _getAvailableServices = getAvailableServices,
       _searchAvailablePartners = searchAvailablePartners,
       _createBooking = createBooking,
       _processPayment = processPayment,
       _getAvailablePaymentMethods = getAvailablePaymentMethods,
       _getClientBookings = getClientBookings,
       super(const ClientBookingInitial()) {
    on<LoadAvailableServicesEvent>(_onLoadAvailableServices);
    on<SearchServicesEvent>(_onSearchServices);
    on<SelectServiceEvent>(_onSelectService);
    on<SelectDateTimeEvent>(_onSelectDateTime);
    on<SetClientLocationEvent>(_onSetClientLocation);
    on<LoadAvailablePartnersEvent>(_onLoadAvailablePartners);
    on<SelectPartnerEvent>(_onSelectPartner);
    on<SetSpecialInstructionsEvent>(_onSetSpecialInstructions);
    on<SetUrgentBookingEvent>(_onSetUrgentBooking);
    on<LoadPaymentMethodsEvent>(_onLoadPaymentMethods);
    on<SelectPaymentMethodEvent>(_onSelectPaymentMethod);
    on<CreateBookingEvent>(_onCreateBooking);
    on<ProcessPaymentEvent>(_onProcessPayment);
    on<LoadClientBookingHistoryEvent>(_onLoadClientBookingHistory);
    on<CancelBookingEvent>(_onCancelBooking);
    on<ResetBookingFlowEvent>(_onResetBookingFlow);
    on<ClearErrorEvent>(_onClearError);
    on<GoBackStepEvent>(_onGoBackStep);
    on<GoNextStepEvent>(_onGoNextStep);
  }

  Future<void> _onLoadAvailableServices(
    LoadAvailableServicesEvent event,
    Emitter<ClientBookingState> emit,
  ) async {
    emit(const ClientBookingLoading());

    final result = await _getAvailableServices(NoParams());
    result.fold(
      (failure) => emit(ClientBookingError(failure.message)),
      (services) => emit(
        ServicesLoadedState(services: services, filteredServices: services),
      ),
    );
  }

  Future<void> _onSearchServices(
    SearchServicesEvent event,
    Emitter<ClientBookingState> emit,
  ) async {
    if (state is ServicesLoadedState) {
      final currentState = state as ServicesLoadedState;
      final filteredServices = event.query.isEmpty
          ? currentState.services
          : currentState.services
                .where(
                  (service) =>
                      service.name.toLowerCase().contains(
                        event.query.toLowerCase(),
                      ) ||
                      service.description.toLowerCase().contains(
                        event.query.toLowerCase(),
                      ),
                )
                .toList();

      emit(
        currentState.copyWith(
          filteredServices: filteredServices,
          searchQuery: event.query,
        ),
      );
    }
  }

  Future<void> _onSelectService(
    SelectServiceEvent event,
    Emitter<ClientBookingState> emit,
  ) async {
    emit(
      BookingFlowState(
        currentStep: BookingStep.dateTimeSelection,
        selectedService: event.service,
      ),
    );
  }

  Future<void> _onSelectDateTime(
    SelectDateTimeEvent event,
    Emitter<ClientBookingState> emit,
  ) async {
    if (state is BookingFlowState) {
      final currentState = state as BookingFlowState;
      emit(
        currentState.copyWith(
          selectedDate: event.date,
          selectedTimeSlot: event.timeSlot,
          selectedHours: event.hours,
          totalPrice: currentState
              .copyWith(selectedHours: event.hours)
              .calculateTotalPrice(),
        ),
      );
    }
  }

  Future<void> _onSetClientLocation(
    SetClientLocationEvent event,
    Emitter<ClientBookingState> emit,
  ) async {
    if (state is BookingFlowState) {
      final currentState = state as BookingFlowState;
      emit(
        currentState.copyWith(
          clientAddress: event.address,
          clientLatitude: event.latitude,
          clientLongitude: event.longitude,
        ),
      );
    }
  }

  Future<void> _onLoadAvailablePartners(
    LoadAvailablePartnersEvent event,
    Emitter<ClientBookingState> emit,
  ) async {
    if (state is BookingFlowState) {
      final currentState = state as BookingFlowState;

      if (currentState.selectedService == null ||
          currentState.selectedDate == null ||
          currentState.selectedTimeSlot == null) {
        emit(
          currentState.copyWith(error: 'Missing required booking information'),
        );
        return;
      }

      emit(currentState.copyWith(isLoading: true, error: null));

      final result = await _searchAvailablePartners(
        SearchAvailablePartnersParams(
          serviceId: currentState.selectedService!.id,
          date: currentState.selectedDate!,
          timeSlot: currentState.selectedTimeSlot!,
          clientLatitude: currentState.clientLatitude,
          clientLongitude: currentState.clientLongitude,
        ),
      );

      result.fold(
        (failure) => emit(
          currentState.copyWith(isLoading: false, error: failure.message),
        ),
        (partners) => emit(
          currentState.copyWith(
            currentStep: BookingStep.partnerSelection,
            availablePartners: partners,
            isLoading: false,
            error: null,
          ),
        ),
      );
    }
  }

  Future<void> _onSelectPartner(
    SelectPartnerEvent event,
    Emitter<ClientBookingState> emit,
  ) async {
    if (state is BookingFlowState) {
      final currentState = state as BookingFlowState;
      emit(currentState.copyWith(selectedPartner: event.partner));
    }
  }

  Future<void> _onSetSpecialInstructions(
    SetSpecialInstructionsEvent event,
    Emitter<ClientBookingState> emit,
  ) async {
    if (state is BookingFlowState) {
      final currentState = state as BookingFlowState;
      emit(currentState.copyWith(specialInstructions: event.instructions));
    }
  }

  Future<void> _onSetUrgentBooking(
    SetUrgentBookingEvent event,
    Emitter<ClientBookingState> emit,
  ) async {
    if (state is BookingFlowState) {
      final currentState = state as BookingFlowState;
      emit(
        currentState.copyWith(
          isUrgent: event.isUrgent,
          totalPrice: currentState
              .copyWith(isUrgent: event.isUrgent)
              .calculateTotalPrice(),
        ),
      );
    }
  }

  Future<void> _onLoadPaymentMethods(
    LoadPaymentMethodsEvent event,
    Emitter<ClientBookingState> emit,
  ) async {
    if (state is BookingFlowState) {
      final currentState = state as BookingFlowState;
      emit(currentState.copyWith(isLoading: true, error: null));

      final result = await _getAvailablePaymentMethods(NoParams());
      result.fold(
        (failure) => emit(
          currentState.copyWith(isLoading: false, error: failure.message),
        ),
        (paymentMethods) => emit(
          currentState.copyWith(
            currentStep: BookingStep.paymentMethod,
            paymentMethods: paymentMethods,
            isLoading: false,
            error: null,
          ),
        ),
      );
    }
  }

  Future<void> _onSelectPaymentMethod(
    SelectPaymentMethodEvent event,
    Emitter<ClientBookingState> emit,
  ) async {
    if (state is BookingFlowState) {
      final currentState = state as BookingFlowState;
      emit(currentState.copyWith(selectedPaymentMethod: event.paymentMethod));
    }
  }

  Future<void> _onCreateBooking(
    CreateBookingEvent event,
    Emitter<ClientBookingState> emit,
  ) async {
    if (state is BookingFlowState) {
      final currentState = state as BookingFlowState;

      if (!_isBookingValid(currentState)) {
        emit(currentState.copyWith(error: 'Booking information is incomplete'));
        return;
      }

      emit(currentState.copyWith(isLoading: true, error: null));

      final bookingRequest = BookingRequest(
        userId: event.userId,
        serviceId: currentState.selectedService!.id,
        partnerId: currentState.selectedPartner?.uid,
        scheduledDate: currentState.selectedDate!,
        timeSlot: currentState.selectedTimeSlot!,
        hours: currentState.selectedHours!,
        clientAddress: currentState.clientAddress!,
        clientLatitude: currentState.clientLatitude!,
        clientLongitude: currentState.clientLongitude!,
        specialInstructions: currentState.specialInstructions,
        isUrgent: currentState.isUrgent,
      );

      final result = await _createBooking(bookingRequest);
      result.fold(
        (failure) => emit(
          currentState.copyWith(isLoading: false, error: failure.message),
        ),
        (booking) => emit(BookingCreatedState(booking)),
      );
    }
  }

  bool _isBookingValid(BookingFlowState state) {
    return state.selectedService != null &&
        state.selectedDate != null &&
        state.selectedTimeSlot != null &&
        state.selectedHours != null &&
        state.clientAddress != null &&
        state.clientLatitude != null &&
        state.clientLongitude != null;
  }

  Future<void> _onProcessPayment(
    ProcessPaymentEvent event,
    Emitter<ClientBookingState> emit,
  ) async {
    if (state is BookingCreatedState) {
      final currentState = state as BookingCreatedState;
      emit(PaymentProcessingState(event.bookingId));

      // Get payment method from previous booking flow state
      // This would need to be stored or passed differently in a real implementation
      final paymentRequest = PaymentRequest(
        bookingId: event.bookingId,
        amount: currentState.booking.totalPrice,
        currency: 'VND',
        paymentMethod: const PaymentMethod(
          id: 'mock',
          type: PaymentMethodType.mock,
          name: 'mock',
          displayName: 'Mock Payment',
        ),
      );

      final result = await _processPayment(paymentRequest);
      result.fold(
        (failure) => emit(ClientBookingError(failure.message)),
        (paymentResult) => emit(
          PaymentCompletedState(
            paymentResult: paymentResult,
            booking: currentState.booking,
          ),
        ),
      );
    }
  }

  Future<void> _onLoadClientBookingHistory(
    LoadClientBookingHistoryEvent event,
    Emitter<ClientBookingState> emit,
  ) async {
    emit(const ClientBookingLoading());

    final result = await _getClientBookings(
      GetClientBookingsParams(userId: event.userId),
    );
    result.fold(
      (failure) => emit(ClientBookingError(failure.message)),
      (bookings) => emit(BookingHistoryLoadedState(bookings)),
    );
  }

  Future<void> _onCancelBooking(
    CancelBookingEvent event,
    Emitter<ClientBookingState> emit,
  ) async {
    // Implementation would depend on having a cancel booking use case
    emit(BookingCancelledState(event.bookingId));
  }

  Future<void> _onResetBookingFlow(
    ResetBookingFlowEvent event,
    Emitter<ClientBookingState> emit,
  ) async {
    emit(const ClientBookingInitial());
  }

  Future<void> _onClearError(
    ClearErrorEvent event,
    Emitter<ClientBookingState> emit,
  ) async {
    if (state is BookingFlowState) {
      final currentState = state as BookingFlowState;
      emit(currentState.copyWith(error: null));
    }
  }

  Future<void> _onGoBackStep(
    GoBackStepEvent event,
    Emitter<ClientBookingState> emit,
  ) async {
    if (state is BookingFlowState) {
      final currentState = state as BookingFlowState;
      if (currentState.canGoBack) {
        final previousStep = _getPreviousStep(currentState.currentStep);
        emit(currentState.copyWith(currentStep: previousStep, error: null));
      }
    }
  }

  Future<void> _onGoNextStep(
    GoNextStepEvent event,
    Emitter<ClientBookingState> emit,
  ) async {
    if (state is BookingFlowState) {
      final currentState = state as BookingFlowState;
      if (currentState.canProceedToNextStep) {
        final nextStep = _getNextStep(currentState.currentStep);
        emit(currentState.copyWith(currentStep: nextStep, error: null));
      }
    }
  }

  BookingStep _getPreviousStep(BookingStep currentStep) {
    switch (currentStep) {
      case BookingStep.dateTimeSelection:
        return BookingStep.serviceSelection;
      case BookingStep.partnerSelection:
        return BookingStep.dateTimeSelection;
      case BookingStep.bookingDetails:
        return BookingStep.partnerSelection;
      case BookingStep.paymentMethod:
        return BookingStep.bookingDetails;
      case BookingStep.confirmation:
        return BookingStep.paymentMethod;
      default:
        return currentStep;
    }
  }

  BookingStep _getNextStep(BookingStep currentStep) {
    switch (currentStep) {
      case BookingStep.serviceSelection:
        return BookingStep.dateTimeSelection;
      case BookingStep.dateTimeSelection:
        return BookingStep.partnerSelection;
      case BookingStep.partnerSelection:
        return BookingStep.bookingDetails;
      case BookingStep.bookingDetails:
        return BookingStep.paymentMethod;
      case BookingStep.paymentMethod:
        return BookingStep.confirmation;
      case BookingStep.confirmation:
        return BookingStep.completed;
      default:
        return currentStep;
    }
  }
}
