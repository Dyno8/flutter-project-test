import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';

import '../../../../shared/services/realtime_booking_service.dart';
import '../../../../core/errors/failures.dart';

/// BLoC for managing real-time booking updates
class RealtimeBookingBloc
    extends Bloc<RealtimeBookingEvent, RealtimeBookingState> {
  final RealtimeBookingService _realtimeBookingService;
  StreamSubscription<Either<Failure, BookingRealtimeData>>?
  _bookingSubscription;

  RealtimeBookingBloc(this._realtimeBookingService)
    : super(RealtimeBookingInitial()) {
    on<StartRealtimeTrackingEvent>(_onStartRealtimeTracking);
    on<StopRealtimeTrackingEvent>(_onStopRealtimeTracking);
    on<UpdateBookingStatusEvent>(_onUpdateBookingStatus);
    on<StartLocationTrackingEvent>(_onStartLocationTracking);
    on<RealtimeBookingUpdatedEvent>(_onRealtimeBookingUpdated);
    on<RealtimeBookingErrorEvent>(_onRealtimeBookingError);
  }

  Future<void> _onStartRealtimeTracking(
    StartRealtimeTrackingEvent event,
    Emitter<RealtimeBookingState> emit,
  ) async {
    emit(RealtimeBookingLoading());

    // Initialize tracking
    final initResult = await _realtimeBookingService.initializeBookingTracking(
      event.bookingId,
    );

    if (initResult.isLeft()) {
      final failure = (initResult as Left).value;
      emit(RealtimeBookingError(failure.message));
      return;
    }

    // Start listening to updates
    _bookingSubscription?.cancel();
    _bookingSubscription = _realtimeBookingService
        .listenToBookingUpdates(event.bookingId)
        .listen((result) {
          result.fold(
            (failure) => add(RealtimeBookingErrorEvent(failure.message)),
            (data) => add(RealtimeBookingUpdatedEvent(data)),
          );
        });

    emit(RealtimeBookingTracking(event.bookingId));
  }

  Future<void> _onStopRealtimeTracking(
    StopRealtimeTrackingEvent event,
    Emitter<RealtimeBookingState> emit,
  ) async {
    _bookingSubscription?.cancel();
    _bookingSubscription = null;

    await _realtimeBookingService.stopBookingTracking(event.bookingId);
    emit(RealtimeBookingInitial());
  }

  Future<void> _onUpdateBookingStatus(
    UpdateBookingStatusEvent event,
    Emitter<RealtimeBookingState> emit,
  ) async {
    final result = await _realtimeBookingService.updateBookingStatus(
      event.bookingId,
      event.status,
      message: event.message,
      partnerLocation: event.partnerLocation,
      estimatedArrival: event.estimatedArrival,
    );

    result.fold(
      (failure) => emit(RealtimeBookingError(failure.message)),
      (_) {}, // Success is handled by the real-time listener
    );
  }

  Future<void> _onStartLocationTracking(
    StartLocationTrackingEvent event,
    Emitter<RealtimeBookingState> emit,
  ) async {
    final result = await _realtimeBookingService.startLocationTracking(
      event.bookingId,
      event.partnerId,
    );

    result.fold(
      (failure) => emit(RealtimeBookingError(failure.message)),
      (_) {}, // Success is handled by the real-time listener
    );
  }

  void _onRealtimeBookingUpdated(
    RealtimeBookingUpdatedEvent event,
    Emitter<RealtimeBookingState> emit,
  ) {
    emit(RealtimeBookingUpdated(event.data));
  }

  void _onRealtimeBookingError(
    RealtimeBookingErrorEvent event,
    Emitter<RealtimeBookingState> emit,
  ) {
    emit(RealtimeBookingError(event.message));
  }

  @override
  Future<void> close() {
    _bookingSubscription?.cancel();
    _realtimeBookingService.dispose();
    return super.close();
  }
}

/// Events
abstract class RealtimeBookingEvent extends Equatable {
  const RealtimeBookingEvent();

  @override
  List<Object?> get props => [];
}

class StartRealtimeTrackingEvent extends RealtimeBookingEvent {
  final String bookingId;

  const StartRealtimeTrackingEvent(this.bookingId);

  @override
  List<Object> get props => [bookingId];
}

class StopRealtimeTrackingEvent extends RealtimeBookingEvent {
  final String bookingId;

  const StopRealtimeTrackingEvent(this.bookingId);

  @override
  List<Object> get props => [bookingId];
}

class UpdateBookingStatusEvent extends RealtimeBookingEvent {
  final String bookingId;
  final String status;
  final String? message;
  final LocationData? partnerLocation;
  final DateTime? estimatedArrival;

  const UpdateBookingStatusEvent({
    required this.bookingId,
    required this.status,
    this.message,
    this.partnerLocation,
    this.estimatedArrival,
  });

  @override
  List<Object?> get props => [
    bookingId,
    status,
    message,
    partnerLocation,
    estimatedArrival,
  ];
}

class StartLocationTrackingEvent extends RealtimeBookingEvent {
  final String bookingId;
  final String partnerId;

  const StartLocationTrackingEvent({
    required this.bookingId,
    required this.partnerId,
  });

  @override
  List<Object> get props => [bookingId, partnerId];
}

class RealtimeBookingUpdatedEvent extends RealtimeBookingEvent {
  final BookingRealtimeData data;

  const RealtimeBookingUpdatedEvent(this.data);

  @override
  List<Object> get props => [data];
}

class RealtimeBookingErrorEvent extends RealtimeBookingEvent {
  final String message;

  const RealtimeBookingErrorEvent(this.message);

  @override
  List<Object> get props => [message];
}

/// States
abstract class RealtimeBookingState extends Equatable {
  const RealtimeBookingState();

  @override
  List<Object?> get props => [];
}

class RealtimeBookingInitial extends RealtimeBookingState {}

class RealtimeBookingLoading extends RealtimeBookingState {}

class RealtimeBookingTracking extends RealtimeBookingState {
  final String bookingId;

  const RealtimeBookingTracking(this.bookingId);

  @override
  List<Object> get props => [bookingId];
}

class RealtimeBookingUpdated extends RealtimeBookingState {
  final BookingRealtimeData data;

  const RealtimeBookingUpdated(this.data);

  @override
  List<Object> get props => [data];
}

class RealtimeBookingError extends RealtimeBookingState {
  final String message;

  const RealtimeBookingError(this.message);

  @override
  List<Object> get props => [message];
}
