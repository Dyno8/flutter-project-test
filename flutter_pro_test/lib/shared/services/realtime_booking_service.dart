import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../../shared/models/booking_model.dart';
import '../../shared/services/firebase_service.dart';
import '../../shared/services/notification_service.dart';
import '../../core/constants/app_constants.dart';

/// Service for real-time booking tracking and updates
class RealtimeBookingService {
  final FirebaseService _firebaseService;
  final NotificationService _notificationService;
  late final DatabaseReference _database;

  // Stream controllers for real-time updates
  final Map<String, StreamController<BookingRealtimeData>> _bookingControllers =
      {};
  final Map<String, StreamController<LocationData>> _locationControllers = {};

  RealtimeBookingService(this._firebaseService, this._notificationService) {
    _database = _firebaseService.realtimeDatabase.ref();
  }

  /// Initialize real-time tracking for a booking
  Future<Either<Failure, void>> initializeBookingTracking(
    String bookingId,
  ) async {
    try {
      // Create real-time booking data structure
      final realtimeData = BookingRealtimeData(
        bookingId: bookingId,
        status: AppConstants.statusPending,
        lastUpdated: DateTime.now(),
        partnerLocation: null,
        estimatedArrival: null,
        isPartnerEnRoute: false,
        messages: [],
      );

      // Store in Realtime Database
      await _database
          .child('bookings')
          .child(bookingId)
          .set(realtimeData.toJson());

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to initialize booking tracking: $e'));
    }
  }

  /// Listen to real-time booking updates
  Stream<Either<Failure, BookingRealtimeData>> listenToBookingUpdates(
    String bookingId,
  ) {
    try {
      if (!_bookingControllers.containsKey(bookingId)) {
        _bookingControllers[bookingId] =
            StreamController<BookingRealtimeData>.broadcast();

        // Listen to Firebase Realtime Database
        _database.child('bookings').child(bookingId).onValue.listen((event) {
          if (event.snapshot.exists) {
            final data = Map<String, dynamic>.from(event.snapshot.value as Map);
            final realtimeData = BookingRealtimeData.fromJson(data);
            _bookingControllers[bookingId]?.add(realtimeData);
          }
        });
      }

      return _bookingControllers[bookingId]!.stream
          .map<Either<Failure, BookingRealtimeData>>((data) => Right(data))
          .handleError(
            (error) => Left(ServerFailure('Real-time update error: $error')),
          );
    } catch (e) {
      return Stream.value(
        Left(ServerFailure('Failed to listen to booking updates: $e')),
      );
    }
  }

  /// Update booking status in real-time
  Future<Either<Failure, void>> updateBookingStatus(
    String bookingId,
    String status, {
    String? message,
    LocationData? partnerLocation,
    DateTime? estimatedArrival,
  }) async {
    try {
      final updates = <String, dynamic>{
        'status': status,
        'lastUpdated': ServerValue.timestamp,
      };

      if (message != null) {
        updates['messages'] = {
          DateTime.now().millisecondsSinceEpoch.toString(): {
            'message': message,
            'timestamp': ServerValue.timestamp,
            'type': 'status_update',
          },
        };
      }

      if (partnerLocation != null) {
        updates['partnerLocation'] = partnerLocation.toJson();
        updates['isPartnerEnRoute'] = true;
      }

      if (estimatedArrival != null) {
        updates['estimatedArrival'] = estimatedArrival.millisecondsSinceEpoch;
      }

      await _database.child('bookings').child(bookingId).update(updates);

      // Send notification to client
      await _sendStatusUpdateNotification(bookingId, status, message);

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to update booking status: $e'));
    }
  }

  /// Start location tracking for partner
  Future<Either<Failure, void>> startLocationTracking(
    String bookingId,
    String partnerId,
  ) async {
    try {
      // Check location permissions
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requestResult = await Geolocator.requestPermission();
        if (requestResult == LocationPermission.denied) {
          return Left(ServerFailure('Location permission denied'));
        }
      }

      // Start location stream
      final locationStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10, // Update every 10 meters
        ),
      );

      locationStream.listen((position) {
        final locationData = LocationData(
          latitude: position.latitude,
          longitude: position.longitude,
          timestamp: DateTime.now(),
          accuracy: position.accuracy,
        );

        // Update partner location in real-time
        _updatePartnerLocation(bookingId, locationData);
      });

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to start location tracking: $e'));
    }
  }

  /// Update partner location in real-time
  Future<void> _updatePartnerLocation(
    String bookingId,
    LocationData location,
  ) async {
    try {
      await _database
          .child('bookings')
          .child(bookingId)
          .child('partnerLocation')
          .set(location.toJson());
    } catch (e) {
      print('Error updating partner location: $e');
    }
  }

  /// Send status update notification
  Future<void> _sendStatusUpdateNotification(
    String bookingId,
    String status,
    String? message,
  ) async {
    try {
      // Get booking details from Firestore
      final bookingDoc = await _firebaseService.getDocument(
        AppConstants.bookingsCollection,
        bookingId,
      );

      if (bookingDoc.exists) {
        final booking = BookingModel.fromFirestore(bookingDoc);

        // Get user FCM token
        final userDoc = await _firebaseService.getDocument(
          AppConstants.usersCollection,
          booking.userId,
        );

        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          final fcmToken = userData['fcmToken'] as String?;

          if (fcmToken != null) {
            final title = _getStatusNotificationTitle(status);
            final body =
                message ??
                _getStatusNotificationBody(status, booking.serviceName);

            await _notificationService.sendBookingNotification(
              fcmToken,
              title,
              body,
              {
                'bookingId': bookingId,
                'type': 'status_update',
                'status': status,
              },
            );
          }
        }
      }
    } catch (e) {
      print('Error sending status notification: $e');
    }
  }

  /// Get notification title for status
  String _getStatusNotificationTitle(String status) {
    switch (status) {
      case AppConstants.statusConfirmed:
        return 'Booking Confirmed';
      case AppConstants.statusInProgress:
        return 'Service Started';
      case AppConstants.statusCompleted:
        return 'Service Completed';
      default:
        return 'Booking Update';
    }
  }

  /// Get notification body for status
  String _getStatusNotificationBody(String status, String serviceName) {
    switch (status) {
      case AppConstants.statusConfirmed:
        return 'Your $serviceName booking has been confirmed. Partner is on the way!';
      case AppConstants.statusInProgress:
        return 'Your $serviceName service has started.';
      case AppConstants.statusCompleted:
        return 'Your $serviceName service has been completed. Please rate your experience.';
      default:
        return 'Your $serviceName booking has been updated.';
    }
  }

  /// Stop tracking for a booking
  Future<void> stopBookingTracking(String bookingId) async {
    try {
      // Close stream controller
      _bookingControllers[bookingId]?.close();
      _bookingControllers.remove(bookingId);

      // Remove from Realtime Database
      await _database.child('bookings').child(bookingId).remove();
    } catch (e) {
      print('Error stopping booking tracking: $e');
    }
  }

  /// Dispose all resources
  void dispose() {
    for (final controller in _bookingControllers.values) {
      controller.close();
    }
    _bookingControllers.clear();

    for (final controller in _locationControllers.values) {
      controller.close();
    }
    _locationControllers.clear();
  }
}

/// Real-time booking data model
class BookingRealtimeData {
  final String bookingId;
  final String status;
  final DateTime lastUpdated;
  final LocationData? partnerLocation;
  final DateTime? estimatedArrival;
  final bool isPartnerEnRoute;
  final List<RealtimeMessage> messages;

  BookingRealtimeData({
    required this.bookingId,
    required this.status,
    required this.lastUpdated,
    this.partnerLocation,
    this.estimatedArrival,
    required this.isPartnerEnRoute,
    required this.messages,
  });

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'status': status,
      'lastUpdated': lastUpdated.millisecondsSinceEpoch,
      'partnerLocation': partnerLocation?.toJson(),
      'estimatedArrival': estimatedArrival?.millisecondsSinceEpoch,
      'isPartnerEnRoute': isPartnerEnRoute,
      'messages': messages.map((m) => m.toJson()).toList(),
    };
  }

  factory BookingRealtimeData.fromJson(Map<String, dynamic> json) {
    return BookingRealtimeData(
      bookingId: json['bookingId'] ?? '',
      status: json['status'] ?? '',
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(
        json['lastUpdated'] ?? 0,
      ),
      partnerLocation: json['partnerLocation'] != null
          ? LocationData.fromJson(
              Map<String, dynamic>.from(json['partnerLocation']),
            )
          : null,
      estimatedArrival: json['estimatedArrival'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['estimatedArrival'])
          : null,
      isPartnerEnRoute: json['isPartnerEnRoute'] ?? false,
      messages:
          (json['messages'] as List<dynamic>?)
              ?.map(
                (m) => RealtimeMessage.fromJson(Map<String, dynamic>.from(m)),
              )
              .toList() ??
          [],
    );
  }
}

/// Location data model
class LocationData {
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final double accuracy;

  LocationData({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.accuracy,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'accuracy': accuracy,
    };
  }

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] ?? 0),
      accuracy: (json['accuracy'] ?? 0.0).toDouble(),
    );
  }
}

/// Real-time message model
class RealtimeMessage {
  final String message;
  final DateTime timestamp;
  final String type;

  RealtimeMessage({
    required this.message,
    required this.timestamp,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'type': type,
    };
  }

  factory RealtimeMessage.fromJson(Map<String, dynamic> json) {
    return RealtimeMessage(
      message: json['message'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] ?? 0),
      type: json['type'] ?? '',
    );
  }
}
