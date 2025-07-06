import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../models/booking_model.dart';
import '../models/partner_model.dart';
import '../repositories/booking_repository.dart';
import '../repositories/partner_repository.dart';
import '../repositories/user_repository.dart';
import '../services/validation_service.dart';
import '../services/partner_matching_service.dart';
import '../services/notification_service.dart';
import '../../core/errors/failures.dart';
import '../../core/constants/app_constants.dart';

class BookingManagementService {
  final BookingRepository _bookingRepository = BookingRepository();
  final PartnerRepository _partnerRepository = PartnerRepository();
  final UserRepository _userRepository = UserRepository();
  final ValidationService _validationService = ValidationService();
  final PartnerMatchingService _partnerMatchingService =
      PartnerMatchingService();
  final NotificationService _notificationService = NotificationService();

  // Create a new booking with automatic partner matching
  Future<Either<Failure, BookingModel>> createBooking({
    required String userId,
    required String serviceId,
    required String serviceName,
    required DateTime scheduledDate,
    required String timeSlot,
    required double hours,
    required double totalPrice,
    required String clientAddress,
    required GeoPoint clientLocation,
    String? specialInstructions,
    bool autoAssignPartner = true,
  }) async {
    try {
      // Validate booking data
      final validationResult = _validationService.validateBooking(
        scheduledDate: scheduledDate,
        timeSlot: timeSlot,
        hours: hours,
        totalPrice: totalPrice,
        clientAddress: clientAddress,
      );

      if (!validationResult.isValid) {
        return Left(ValidationFailure(validationResult.errorMessage));
      }

      // Create booking model
      final booking = BookingModel(
        id: '', // Will be set by Firestore
        userId: userId,
        partnerId: '', // Will be assigned later
        serviceId: serviceId,
        serviceName: serviceName,
        scheduledDate: scheduledDate,
        timeSlot: timeSlot,
        hours: hours,
        totalPrice: totalPrice,
        status: AppConstants.statusPending,
        paymentStatus: AppConstants.paymentUnpaid,
        clientAddress: clientAddress,
        clientLocation: clientLocation,
        specialInstructions: specialInstructions,
        createdAt: DateTime.now(),
      );

      // Create booking in database
      final createResult = await _bookingRepository.createBooking(booking);
      if (createResult is Left) {
        return createResult;
      }

      var createdBooking = (createResult as Right).value;

      // Auto-assign partner if requested
      if (autoAssignPartner) {
        final assignResult = await _assignPartnerToBooking(
          createdBooking.id,
          [serviceId],
          clientLocation,
          scheduledDate,
          timeSlot,
        );

        if (assignResult is Right) {
          final assignedPartner = (assignResult as Right).value;
          if (assignedPartner != null) {
            createdBooking = createdBooking.copyWith(
              partnerId: assignedPartner.uid,
              status: AppConstants.statusConfirmed,
            );

            // Update booking with assigned partner
            await _bookingRepository.updateBookingStatus(
              createdBooking.id,
              AppConstants.statusConfirmed,
            );

            // Send notification to partner
            await _notificationService.sendBookingNotification(
              assignedPartner.fcmToken,
              'Booking mới',
              'Bạn có một booking mới cho dịch vụ $serviceName',
              {'bookingId': createdBooking.id, 'type': 'new_booking'},
            );
          }
        }
      }

      return Right(createdBooking);
    } catch (e) {
      return Left(ServerFailure('Failed to create booking: $e'));
    }
  }

  // Assign partner to existing booking
  Future<Either<Failure, PartnerModel?>> _assignPartnerToBooking(
    String bookingId,
    List<String> serviceTypes,
    GeoPoint clientLocation,
    DateTime scheduledDate,
    String timeSlot,
  ) async {
    final partnerResult = await _partnerMatchingService.autoAssignPartner(
      serviceTypes: serviceTypes,
      clientLocation: clientLocation,
      scheduledDate: scheduledDate,
      timeSlot: timeSlot,
    );

    if (partnerResult is Left) {
      return partnerResult;
    }

    final partner = (partnerResult as Right).value;
    if (partner != null) {
      // Update booking with partner ID
      await _bookingRepository.update(bookingId, {
        'partnerId': partner.uid,
        'status': AppConstants.statusConfirmed,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    return Right(partner);
  }

  // Partner accepts a booking
  Future<Either<Failure, BookingModel>> acceptBooking(
    String bookingId,
    String partnerId,
  ) async {
    try {
      // Get booking details
      final bookingResult = await _bookingRepository.getById(bookingId);
      if (bookingResult is Left) {
        return bookingResult;
      }

      final booking = (bookingResult as Right).value;

      // Validate partner can accept this booking
      if (booking.partnerId.isNotEmpty && booking.partnerId != partnerId) {
        return Left(
          ValidationFailure('Booking đã được assign cho partner khác'),
        );
      }

      if (booking.status != AppConstants.statusPending) {
        return Left(ValidationFailure('Booking không thể accept'));
      }

      // Update booking status
      final updateResult = await _bookingRepository.updateBookingStatus(
        bookingId,
        AppConstants.statusConfirmed,
      );

      if (updateResult is Left) {
        return updateResult;
      }

      final updatedBooking = (updateResult as Right).value;

      // Update booking with partner ID if not set
      if (booking.partnerId.isEmpty) {
        await _bookingRepository.update(bookingId, {
          'partnerId': partnerId,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // Send notification to client
      final userResult = await _userRepository.getById(booking.userId);
      if (userResult is Right) {
        final user = (userResult as Right).value;
        await _notificationService.sendBookingNotification(
          user.fcmToken,
          'Booking được xác nhận',
          'Booking ${booking.serviceName} của bạn đã được xác nhận',
          {'bookingId': bookingId, 'type': 'booking_confirmed'},
        );
      }

      return Right(updatedBooking);
    } catch (e) {
      return Left(ServerFailure('Failed to accept booking: $e'));
    }
  }

  // Start a booking (partner marks as in-progress)
  Future<Either<Failure, BookingModel>> startBooking(
    String bookingId,
    String partnerId,
  ) async {
    try {
      final bookingResult = await _bookingRepository.getById(bookingId);
      if (bookingResult is Left) {
        return bookingResult;
      }

      final booking = (bookingResult as Right).value;

      // Validate partner can start this booking
      if (booking.partnerId != partnerId) {
        return Left(ValidationFailure('Bạn không có quyền start booking này'));
      }

      if (booking.status != AppConstants.statusConfirmed) {
        return Left(ValidationFailure('Booking chưa được confirm'));
      }

      // Update booking status
      final updateResult = await _bookingRepository.updateBookingStatus(
        bookingId,
        AppConstants.statusInProgress,
      );

      if (updateResult is Left) {
        return updateResult;
      }

      final updatedBooking = (updateResult as Right).value;

      // Send notification to client
      final userResult = await _userRepository.getById(booking.userId);
      if (userResult is Right) {
        final user = (userResult as Right).value;
        await _notificationService.sendBookingNotification(
          user.fcmToken,
          'Dịch vụ bắt đầu',
          'Dịch vụ ${booking.serviceName} đã bắt đầu',
          {'bookingId': bookingId, 'type': 'booking_started'},
        );
      }

      return Right(updatedBooking);
    } catch (e) {
      return Left(ServerFailure('Failed to start booking: $e'));
    }
  }

  // Complete a booking
  Future<Either<Failure, BookingModel>> completeBooking(
    String bookingId,
    String partnerId,
  ) async {
    try {
      final bookingResult = await _bookingRepository.getById(bookingId);
      if (bookingResult is Left) {
        return bookingResult;
      }

      final booking = (bookingResult as Right).value;

      // Validate partner can complete this booking
      if (booking.partnerId != partnerId) {
        return Left(
          ValidationFailure('Bạn không có quyền complete booking này'),
        );
      }

      if (booking.status != AppConstants.statusInProgress) {
        return Left(ValidationFailure('Booking chưa được start'));
      }

      // Update booking status
      final updateResult = await _bookingRepository.updateBookingStatus(
        bookingId,
        AppConstants.statusCompleted,
      );

      if (updateResult is Left) {
        return updateResult;
      }

      final updatedBooking = (updateResult as Right).value;

      // Send notification to client
      final userResult = await _userRepository.getById(booking.userId);
      if (userResult is Right) {
        final user = (userResult as Right).value;
        await _notificationService.sendBookingNotification(
          user.fcmToken,
          'Dịch vụ hoàn thành',
          'Dịch vụ ${booking.serviceName} đã hoàn thành. Vui lòng đánh giá!',
          {'bookingId': bookingId, 'type': 'booking_completed'},
        );
      }

      return Right(updatedBooking);
    } catch (e) {
      return Left(ServerFailure('Failed to complete booking: $e'));
    }
  }

  // Cancel a booking
  Future<Either<Failure, BookingModel>> cancelBooking(
    String bookingId,
    String userId,
    String cancellationReason,
  ) async {
    try {
      final bookingResult = await _bookingRepository.getById(bookingId);
      if (bookingResult is Left) {
        return bookingResult;
      }

      final booking = (bookingResult as Right).value;

      // Validate user can cancel this booking
      if (booking.userId != userId) {
        return Left(ValidationFailure('Bạn không có quyền cancel booking này'));
      }

      if (!booking.canBeCancelled) {
        return Left(ValidationFailure('Booking không thể cancel'));
      }

      // Update booking status
      final updateResult = await _bookingRepository.updateBookingStatus(
        bookingId,
        AppConstants.statusCancelled,
        cancellationReason: cancellationReason,
      );

      if (updateResult is Left) {
        return updateResult;
      }

      final updatedBooking = (updateResult as Right).value;

      // Send notification to partner if assigned
      if (booking.partnerId.isNotEmpty) {
        final partnerResult = await _partnerRepository.getById(
          booking.partnerId,
        );
        if (partnerResult is Right) {
          final partner = (partnerResult as Right).value;
          await _notificationService.sendBookingNotification(
            partner.fcmToken,
            'Booking bị hủy',
            'Booking ${booking.serviceName} đã bị hủy bởi khách hàng',
            {'bookingId': bookingId, 'type': 'booking_cancelled'},
          );
        }
      }

      return Right(updatedBooking);
    } catch (e) {
      return Left(ServerFailure('Failed to cancel booking: $e'));
    }
  }

  // Get booking statistics for partner
  Future<Either<Failure, Map<String, dynamic>>> getPartnerBookingStats(
    String partnerId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final bookingsResult = await _bookingRepository.getBookingsByDateRange(
        partnerId,
        startDate,
        endDate,
        isPartner: true,
      );

      if (bookingsResult is Left) {
        return Left((bookingsResult as Left).value);
      }

      final bookings = (bookingsResult as Right).value;

      final stats = <String, dynamic>{
        'totalBookings': bookings.length,
        'completedBookings': bookings.where((b) => b.isCompleted).length,
        'cancelledBookings': bookings.where((b) => b.isCancelled).length,
        'totalEarnings': bookings
            .where((b) => b.isCompleted && b.isPaid)
            .fold<double>(0.0, (total, b) => total + b.totalPrice),
        'averageRating': 0.0, // Will be calculated from reviews
        'totalHours': bookings
            .where((b) => b.isCompleted)
            .fold<double>(0.0, (total, b) => total + b.hours),
      };

      return Right(stats);
    } catch (e) {
      return Left(ServerFailure('Failed to get partner booking stats: $e'));
    }
  }
}
