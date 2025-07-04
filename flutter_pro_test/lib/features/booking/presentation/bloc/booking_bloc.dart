import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/booking.dart';
import '../../domain/entities/booking_request.dart';
import '../../domain/entities/service.dart';
import '../../domain/entities/partner.dart';
import '../../domain/usecases/create_booking.dart';
import '../../domain/usecases/get_user_bookings.dart';
import '../../domain/usecases/get_available_services.dart';
import '../../domain/usecases/get_available_partners.dart';
import '../../domain/usecases/cancel_booking.dart';
import 'booking_event.dart';
import 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final CreateBooking _createBooking;
  final GetUserBookings _getUserBookings;
  final GetAvailableServices _getAvailableServices;
  final GetAvailablePartners _getAvailablePartners;
  final CancelBooking _cancelBooking;

  // Current booking flow state
  Service? _selectedService;
  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  double? _selectedHours;
  Partner? _selectedPartner;
  String? _clientAddress;
  double? _clientLatitude;
  double? _clientLongitude;
  String? _specialInstructions;
  List<Service> _allServices = [];
  List<Partner> _availablePartners = [];

  BookingBloc({
    required CreateBooking createBooking,
    required GetUserBookings getUserBookings,
    required GetAvailableServices getAvailableServices,
    required GetAvailablePartners getAvailablePartners,
    required CancelBooking cancelBooking,
  }) : _createBooking = createBooking,
       _getUserBookings = getUserBookings,
       _getAvailableServices = getAvailableServices,
       _getAvailablePartners = getAvailablePartners,
       _cancelBooking = cancelBooking,
       super(BookingInitial()) {
    on<LoadServicesEvent>(_onLoadServices);
    on<SelectServiceEvent>(_onSelectService);
    on<SelectDateEvent>(_onSelectDate);
    on<SelectTimeSlotEvent>(_onSelectTimeSlot);
    on<LoadAvailablePartnersEvent>(_onLoadAvailablePartners);
    on<SelectPartnerEvent>(_onSelectPartner);
    on<SetClientAddressEvent>(_onSetClientAddress);
    on<SetSpecialInstructionsEvent>(_onSetSpecialInstructions);
    on<CreateBookingEvent>(_onCreateBooking);
    on<LoadUserBookingsEvent>(_onLoadUserBookings);
    on<CancelBookingEvent>(_onCancelBooking);
    on<ResetBookingFlowEvent>(_onResetBookingFlow);
    on<ClearBookingErrorEvent>(_onClearBookingError);
  }

  Future<void> _onLoadServices(
    LoadServicesEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());

    final result = await _getAvailableServices(NoParams());
    result.fold((failure) => emit(BookingError(failure.message)), (services) {
      _allServices = services;
      emit(ServicesLoaded(services));
    });
  }

  void _onSelectService(SelectServiceEvent event, Emitter<BookingState> emit) {
    _selectedService = _allServices.firstWhere((s) => s.id == event.serviceId);
    emit(
      ServiceSelected(
        selectedService: _selectedService!,
        allServices: _allServices,
      ),
    );
  }

  void _onSelectDate(SelectDateEvent event, Emitter<BookingState> emit) {
    _selectedDate = event.selectedDate;
    if (_selectedService != null) {
      emit(
        DateTimeSelected(
          selectedService: _selectedService!,
          selectedDate: _selectedDate!,
          selectedTimeSlot: _selectedTimeSlot,
          selectedHours: _selectedHours,
          allServices: _allServices,
        ),
      );
    }
  }

  void _onSelectTimeSlot(
    SelectTimeSlotEvent event,
    Emitter<BookingState> emit,
  ) {
    _selectedTimeSlot = event.timeSlot;
    _selectedHours = event.hours;
    if (_selectedService != null && _selectedDate != null) {
      emit(
        DateTimeSelected(
          selectedService: _selectedService!,
          selectedDate: _selectedDate!,
          selectedTimeSlot: _selectedTimeSlot,
          selectedHours: _selectedHours,
          allServices: _allServices,
        ),
      );
    }
  }

  Future<void> _onLoadAvailablePartners(
    LoadAvailablePartnersEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(
      PartnersLoading(
        selectedService: _selectedService!,
        selectedDate: _selectedDate!,
        selectedTimeSlot: _selectedTimeSlot!,
        selectedHours: _selectedHours!,
      ),
    );

    final result = await _getAvailablePartners(
      GetAvailablePartnersParams(
        serviceId: event.serviceId,
        date: event.date,
        timeSlot: event.timeSlot,
        clientLatitude: event.clientLatitude,
        clientLongitude: event.clientLongitude,
      ),
    );

    result.fold((failure) => emit(BookingError(failure.message)), (partners) {
      _availablePartners = partners;
      emit(
        PartnersLoaded(
          selectedService: _selectedService!,
          selectedDate: _selectedDate!,
          selectedTimeSlot: _selectedTimeSlot!,
          selectedHours: _selectedHours!,
          availablePartners: partners,
        ),
      );
    });
  }

  void _onSelectPartner(SelectPartnerEvent event, Emitter<BookingState> emit) {
    _selectedPartner = _availablePartners.firstWhere(
      (p) => p.uid == event.partnerId,
    );
    emit(
      PartnerSelected(
        selectedService: _selectedService!,
        selectedDate: _selectedDate!,
        selectedTimeSlot: _selectedTimeSlot!,
        selectedHours: _selectedHours!,
        selectedPartner: _selectedPartner!,
        availablePartners: _availablePartners,
      ),
    );
  }

  void _onSetClientAddress(
    SetClientAddressEvent event,
    Emitter<BookingState> emit,
  ) {
    _clientAddress = event.address;
    _clientLatitude = event.latitude;
    _clientLongitude = event.longitude;

    if (_isBookingReadyForConfirmation()) {
      emit(
        BookingReadyForConfirmation(
          selectedService: _selectedService!,
          selectedDate: _selectedDate!,
          selectedTimeSlot: _selectedTimeSlot!,
          selectedHours: _selectedHours!,
          selectedPartner: _selectedPartner!,
          clientAddress: _clientAddress!,
          clientLatitude: _clientLatitude!,
          clientLongitude: _clientLongitude!,
          specialInstructions: _specialInstructions,
          totalPrice: _calculateTotalPrice(),
        ),
      );
    }
  }

  void _onSetSpecialInstructions(
    SetSpecialInstructionsEvent event,
    Emitter<BookingState> emit,
  ) {
    _specialInstructions = event.instructions;

    if (_isBookingReadyForConfirmation()) {
      emit(
        BookingReadyForConfirmation(
          selectedService: _selectedService!,
          selectedDate: _selectedDate!,
          selectedTimeSlot: _selectedTimeSlot!,
          selectedHours: _selectedHours!,
          selectedPartner: _selectedPartner!,
          clientAddress: _clientAddress!,
          clientLatitude: _clientLatitude!,
          clientLongitude: _clientLongitude!,
          specialInstructions: _specialInstructions,
          totalPrice: _calculateTotalPrice(),
        ),
      );
    }
  }

  Future<void> _onCreateBooking(
    CreateBookingEvent event,
    Emitter<BookingState> emit,
  ) async {
    if (!_isBookingReadyForConfirmation()) {
      emit(const BookingError('Booking information is incomplete'));
      return;
    }

    emit(BookingCreating());

    final bookingRequest = BookingRequest(
      userId: event.userId,
      serviceId: _selectedService!.id,
      serviceName: _selectedService!.name,
      scheduledDate: _selectedDate!,
      timeSlot: _selectedTimeSlot!,
      hours: _selectedHours!,
      totalPrice: _calculateTotalPrice(),
      clientAddress: _clientAddress!,
      clientLatitude: _clientLatitude!,
      clientLongitude: _clientLongitude!,
      specialInstructions: _specialInstructions,
      preferredPartnerId: _selectedPartner?.uid,
    );

    final result = await _createBooking(
      CreateBookingParams(request: bookingRequest),
    );
    result.fold(
      (failure) => emit(BookingError(failure.message)),
      (booking) => emit(BookingCreated(booking)),
    );
  }

  Future<void> _onLoadUserBookings(
    LoadUserBookingsEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());

    final result = await _getUserBookings(
      GetUserBookingsParams(userId: event.userId, status: event.status),
    );

    result.fold(
      (failure) => emit(BookingError(failure.message)),
      (bookings) => emit(UserBookingsLoaded(bookings)),
    );
  }

  Future<void> _onCancelBooking(
    CancelBookingEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());

    final result = await _cancelBooking(
      CancelBookingParams(
        bookingId: event.bookingId,
        cancellationReason: event.cancellationReason,
      ),
    );

    result.fold(
      (failure) => emit(BookingError(failure.message)),
      (booking) => emit(BookingCancelled(booking)),
    );
  }

  void _onResetBookingFlow(
    ResetBookingFlowEvent event,
    Emitter<BookingState> emit,
  ) {
    _selectedService = null;
    _selectedDate = null;
    _selectedTimeSlot = null;
    _selectedHours = null;
    _selectedPartner = null;
    _clientAddress = null;
    _clientLatitude = null;
    _clientLongitude = null;
    _specialInstructions = null;
    _availablePartners = [];
    emit(BookingInitial());
  }

  void _onClearBookingError(
    ClearBookingErrorEvent event,
    Emitter<BookingState> emit,
  ) {
    emit(BookingInitial());
  }

  // Helper methods
  bool _isBookingReadyForConfirmation() {
    return _selectedService != null &&
        _selectedDate != null &&
        _selectedTimeSlot != null &&
        _selectedHours != null &&
        _selectedPartner != null &&
        _clientAddress != null &&
        _clientLatitude != null &&
        _clientLongitude != null;
  }

  double _calculateTotalPrice() {
    if (_selectedService == null || _selectedHours == null) return 0.0;
    return _selectedService!.basePrice * _selectedHours!;
  }
}
