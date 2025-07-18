// Mocks generated by Mockito 5.4.6 from annotations
// in flutter_pro_test/test/integration/notification_integration_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i4;

import 'package:cloud_firestore/cloud_firestore.dart' as _i7;
import 'package:dartz/dartz.dart' as _i2;
import 'package:flutter_pro_test/core/errors/failures.dart' as _i5;
import 'package:flutter_pro_test/features/notifications/domain/entities/notification.dart'
    as _i11;
import 'package:flutter_pro_test/features/partner/domain/entities/job.dart'
    as _i9;
import 'package:flutter_pro_test/features/partner/domain/services/partner_job_service.dart'
    as _i8;
import 'package:flutter_pro_test/shared/models/booking_model.dart' as _i6;
import 'package:flutter_pro_test/shared/services/booking_management_service.dart'
    as _i3;
import 'package:flutter_pro_test/shared/services/realtime_notification_service.dart'
    as _i10;
import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: must_be_immutable
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeEither_0<L, R> extends _i1.SmartFake implements _i2.Either<L, R> {
  _FakeEither_0(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

/// A class which mocks [BookingManagementService].
///
/// See the documentation for Mockito's code generation for more information.
class MockBookingManagementService extends _i1.Mock
    implements _i3.BookingManagementService {
  MockBookingManagementService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.Future<_i2.Either<_i5.Failure, _i6.BookingModel>> createBooking({
    required String? userId,
    required String? serviceId,
    required String? serviceName,
    required DateTime? scheduledDate,
    required String? timeSlot,
    required double? hours,
    required double? totalPrice,
    required String? clientAddress,
    required _i7.GeoPoint? clientLocation,
    String? specialInstructions,
    bool? autoAssignPartner = true,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#createBooking, [], {
              #userId: userId,
              #serviceId: serviceId,
              #serviceName: serviceName,
              #scheduledDate: scheduledDate,
              #timeSlot: timeSlot,
              #hours: hours,
              #totalPrice: totalPrice,
              #clientAddress: clientAddress,
              #clientLocation: clientLocation,
              #specialInstructions: specialInstructions,
              #autoAssignPartner: autoAssignPartner,
            }),
            returnValue:
                _i4.Future<_i2.Either<_i5.Failure, _i6.BookingModel>>.value(
                  _FakeEither_0<_i5.Failure, _i6.BookingModel>(
                    this,
                    Invocation.method(#createBooking, [], {
                      #userId: userId,
                      #serviceId: serviceId,
                      #serviceName: serviceName,
                      #scheduledDate: scheduledDate,
                      #timeSlot: timeSlot,
                      #hours: hours,
                      #totalPrice: totalPrice,
                      #clientAddress: clientAddress,
                      #clientLocation: clientLocation,
                      #specialInstructions: specialInstructions,
                      #autoAssignPartner: autoAssignPartner,
                    }),
                  ),
                ),
          )
          as _i4.Future<_i2.Either<_i5.Failure, _i6.BookingModel>>);

  @override
  _i4.Future<_i2.Either<_i5.Failure, _i6.BookingModel>> acceptBooking(
    String? bookingId,
    String? partnerId,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#acceptBooking, [bookingId, partnerId]),
            returnValue:
                _i4.Future<_i2.Either<_i5.Failure, _i6.BookingModel>>.value(
                  _FakeEither_0<_i5.Failure, _i6.BookingModel>(
                    this,
                    Invocation.method(#acceptBooking, [bookingId, partnerId]),
                  ),
                ),
          )
          as _i4.Future<_i2.Either<_i5.Failure, _i6.BookingModel>>);

  @override
  _i4.Future<_i2.Either<_i5.Failure, _i6.BookingModel>> startBooking(
    String? bookingId,
    String? partnerId,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#startBooking, [bookingId, partnerId]),
            returnValue:
                _i4.Future<_i2.Either<_i5.Failure, _i6.BookingModel>>.value(
                  _FakeEither_0<_i5.Failure, _i6.BookingModel>(
                    this,
                    Invocation.method(#startBooking, [bookingId, partnerId]),
                  ),
                ),
          )
          as _i4.Future<_i2.Either<_i5.Failure, _i6.BookingModel>>);

  @override
  _i4.Future<_i2.Either<_i5.Failure, _i6.BookingModel>> completeBooking(
    String? bookingId,
    String? partnerId,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#completeBooking, [bookingId, partnerId]),
            returnValue:
                _i4.Future<_i2.Either<_i5.Failure, _i6.BookingModel>>.value(
                  _FakeEither_0<_i5.Failure, _i6.BookingModel>(
                    this,
                    Invocation.method(#completeBooking, [bookingId, partnerId]),
                  ),
                ),
          )
          as _i4.Future<_i2.Either<_i5.Failure, _i6.BookingModel>>);

  @override
  _i4.Future<_i2.Either<_i5.Failure, _i6.BookingModel>> cancelBooking(
    String? bookingId,
    String? userId,
    String? cancellationReason,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#cancelBooking, [
              bookingId,
              userId,
              cancellationReason,
            ]),
            returnValue:
                _i4.Future<_i2.Either<_i5.Failure, _i6.BookingModel>>.value(
                  _FakeEither_0<_i5.Failure, _i6.BookingModel>(
                    this,
                    Invocation.method(#cancelBooking, [
                      bookingId,
                      userId,
                      cancellationReason,
                    ]),
                  ),
                ),
          )
          as _i4.Future<_i2.Either<_i5.Failure, _i6.BookingModel>>);

  @override
  _i4.Future<_i2.Either<_i5.Failure, Map<String, dynamic>>>
  getPartnerBookingStats(
    String? partnerId,
    DateTime? startDate,
    DateTime? endDate,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#getPartnerBookingStats, [
              partnerId,
              startDate,
              endDate,
            ]),
            returnValue:
                _i4.Future<_i2.Either<_i5.Failure, Map<String, dynamic>>>.value(
                  _FakeEither_0<_i5.Failure, Map<String, dynamic>>(
                    this,
                    Invocation.method(#getPartnerBookingStats, [
                      partnerId,
                      startDate,
                      endDate,
                    ]),
                  ),
                ),
          )
          as _i4.Future<_i2.Either<_i5.Failure, Map<String, dynamic>>>);
}

/// A class which mocks [PartnerJobService].
///
/// See the documentation for Mockito's code generation for more information.
class MockPartnerJobService extends _i1.Mock implements _i8.PartnerJobService {
  MockPartnerJobService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.Future<_i2.Either<_i5.Failure, _i9.Job>> acceptJob({
    required String? jobId,
    required String? partnerId,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#acceptJob, [], {
              #jobId: jobId,
              #partnerId: partnerId,
            }),
            returnValue: _i4.Future<_i2.Either<_i5.Failure, _i9.Job>>.value(
              _FakeEither_0<_i5.Failure, _i9.Job>(
                this,
                Invocation.method(#acceptJob, [], {
                  #jobId: jobId,
                  #partnerId: partnerId,
                }),
              ),
            ),
          )
          as _i4.Future<_i2.Either<_i5.Failure, _i9.Job>>);

  @override
  _i4.Future<_i2.Either<_i5.Failure, _i9.Job>> rejectJob({
    required String? jobId,
    required String? partnerId,
    required String? rejectionReason,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#rejectJob, [], {
              #jobId: jobId,
              #partnerId: partnerId,
              #rejectionReason: rejectionReason,
            }),
            returnValue: _i4.Future<_i2.Either<_i5.Failure, _i9.Job>>.value(
              _FakeEither_0<_i5.Failure, _i9.Job>(
                this,
                Invocation.method(#rejectJob, [], {
                  #jobId: jobId,
                  #partnerId: partnerId,
                  #rejectionReason: rejectionReason,
                }),
              ),
            ),
          )
          as _i4.Future<_i2.Either<_i5.Failure, _i9.Job>>);

  @override
  _i4.Future<_i2.Either<_i5.Failure, _i9.Job>> startJob({
    required String? jobId,
    required String? partnerId,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#startJob, [], {
              #jobId: jobId,
              #partnerId: partnerId,
            }),
            returnValue: _i4.Future<_i2.Either<_i5.Failure, _i9.Job>>.value(
              _FakeEither_0<_i5.Failure, _i9.Job>(
                this,
                Invocation.method(#startJob, [], {
                  #jobId: jobId,
                  #partnerId: partnerId,
                }),
              ),
            ),
          )
          as _i4.Future<_i2.Either<_i5.Failure, _i9.Job>>);

  @override
  _i4.Future<_i2.Either<_i5.Failure, _i9.Job>> completeJob({
    required String? jobId,
    required String? partnerId,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#completeJob, [], {
              #jobId: jobId,
              #partnerId: partnerId,
            }),
            returnValue: _i4.Future<_i2.Either<_i5.Failure, _i9.Job>>.value(
              _FakeEither_0<_i5.Failure, _i9.Job>(
                this,
                Invocation.method(#completeJob, [], {
                  #jobId: jobId,
                  #partnerId: partnerId,
                }),
              ),
            ),
          )
          as _i4.Future<_i2.Either<_i5.Failure, _i9.Job>>);

  @override
  _i4.Future<_i2.Either<_i5.Failure, _i9.Job>> cancelJob({
    required String? jobId,
    required String? partnerId,
    required String? cancellationReason,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#cancelJob, [], {
              #jobId: jobId,
              #partnerId: partnerId,
              #cancellationReason: cancellationReason,
            }),
            returnValue: _i4.Future<_i2.Either<_i5.Failure, _i9.Job>>.value(
              _FakeEither_0<_i5.Failure, _i9.Job>(
                this,
                Invocation.method(#cancelJob, [], {
                  #jobId: jobId,
                  #partnerId: partnerId,
                  #cancellationReason: cancellationReason,
                }),
              ),
            ),
          )
          as _i4.Future<_i2.Either<_i5.Failure, _i9.Job>>);
}

/// A class which mocks [RealtimeNotificationService].
///
/// See the documentation for Mockito's code generation for more information.
class MockRealtimeNotificationService extends _i1.Mock
    implements _i10.RealtimeNotificationService {
  MockRealtimeNotificationService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.Stream<int> get unreadCountStream =>
      (super.noSuchMethod(
            Invocation.getter(#unreadCountStream),
            returnValue: _i4.Stream<int>.empty(),
          )
          as _i4.Stream<int>);

  @override
  _i4.Stream<List<_i11.NotificationEntity>> get notificationsStream =>
      (super.noSuchMethod(
            Invocation.getter(#notificationsStream),
            returnValue: _i4.Stream<List<_i11.NotificationEntity>>.empty(),
          )
          as _i4.Stream<List<_i11.NotificationEntity>>);

  @override
  _i4.Stream<_i11.NotificationEntity> get newNotificationStream =>
      (super.noSuchMethod(
            Invocation.getter(#newNotificationStream),
            returnValue: _i4.Stream<_i11.NotificationEntity>.empty(),
          )
          as _i4.Stream<_i11.NotificationEntity>);

  @override
  _i4.Future<_i2.Either<_i5.Failure, void>> initializeForUser(String? userId) =>
      (super.noSuchMethod(
            Invocation.method(#initializeForUser, [userId]),
            returnValue: _i4.Future<_i2.Either<_i5.Failure, void>>.value(
              _FakeEither_0<_i5.Failure, void>(
                this,
                Invocation.method(#initializeForUser, [userId]),
              ),
            ),
          )
          as _i4.Future<_i2.Either<_i5.Failure, void>>);

  @override
  _i4.Future<_i2.Either<_i5.Failure, int>> getCurrentUnreadCount() =>
      (super.noSuchMethod(
            Invocation.method(#getCurrentUnreadCount, []),
            returnValue: _i4.Future<_i2.Either<_i5.Failure, int>>.value(
              _FakeEither_0<_i5.Failure, int>(
                this,
                Invocation.method(#getCurrentUnreadCount, []),
              ),
            ),
          )
          as _i4.Future<_i2.Either<_i5.Failure, int>>);

  @override
  _i4.Future<_i2.Either<_i5.Failure, void>> markNotificationAsRead(
    String? notificationId,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#markNotificationAsRead, [notificationId]),
            returnValue: _i4.Future<_i2.Either<_i5.Failure, void>>.value(
              _FakeEither_0<_i5.Failure, void>(
                this,
                Invocation.method(#markNotificationAsRead, [notificationId]),
              ),
            ),
          )
          as _i4.Future<_i2.Either<_i5.Failure, void>>);

  @override
  _i4.Future<_i2.Either<_i5.Failure, void>> markAllNotificationsAsRead() =>
      (super.noSuchMethod(
            Invocation.method(#markAllNotificationsAsRead, []),
            returnValue: _i4.Future<_i2.Either<_i5.Failure, void>>.value(
              _FakeEither_0<_i5.Failure, void>(
                this,
                Invocation.method(#markAllNotificationsAsRead, []),
              ),
            ),
          )
          as _i4.Future<_i2.Either<_i5.Failure, void>>);

  @override
  _i4.Future<_i2.Either<_i5.Failure, void>> sendTestNotification() =>
      (super.noSuchMethod(
            Invocation.method(#sendTestNotification, []),
            returnValue: _i4.Future<_i2.Either<_i5.Failure, void>>.value(
              _FakeEither_0<_i5.Failure, void>(
                this,
                Invocation.method(#sendTestNotification, []),
              ),
            ),
          )
          as _i4.Future<_i2.Either<_i5.Failure, void>>);

  @override
  _i4.Future<void> stopListening() =>
      (super.noSuchMethod(
            Invocation.method(#stopListening, []),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);

  @override
  void dispose() => super.noSuchMethod(
    Invocation.method(#dispose, []),
    returnValueForMissingStub: null,
  );
}
