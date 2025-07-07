import 'dart:convert';
import 'dart:developer' as developer;
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';

import '../../features/notifications/domain/entities/notification.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';

import '../../shared/repositories/user_repository.dart';

/// Service for handling notification actions and navigation
class NotificationActionHandler {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  // Navigation context - will be set by the app
  BuildContext? _navigationContext;
  GoRouter? _router;

  NotificationActionHandler({
    required AuthRepository authRepository,
    required UserRepository userRepository,
  }) : _authRepository = authRepository,
       _userRepository = userRepository;

  /// Set navigation context and router for handling navigation
  void setNavigationContext(BuildContext context, GoRouter router) {
    _navigationContext = context;
    _router = router;
  }

  /// Handle notification tap action
  Future<void> handleNotificationTap({
    required Map<String, dynamic> data,
    String? payload,
  }) async {
    try {
      developer.log(
        'Handling notification tap with data: $data',
        name: 'NotificationActionHandler',
      );

      // Parse payload if provided
      Map<String, dynamic> notificationData = data;
      if (payload != null && payload.isNotEmpty) {
        try {
          final payloadData = jsonDecode(payload);
          if (payloadData is Map<String, dynamic>) {
            notificationData = {...notificationData, ...payloadData};
          }
        } catch (e) {
          developer.log(
            'Error parsing notification payload: $e',
            name: 'NotificationActionHandler',
          );
        }
      }

      // Check if user is authenticated
      final currentUser = _authRepository.currentUser;
      if (currentUser.isEmpty) {
        developer.log(
          'User not authenticated, redirecting to login',
          name: 'NotificationActionHandler',
        );
        _navigateToLogin();
        return;
      }

      // Get notification type and handle accordingly
      final notificationType = notificationData['type'] as String?;
      if (notificationType == null) {
        developer.log(
          'No notification type found in data',
          name: 'NotificationActionHandler',
        );
        return;
      }

      // Handle different notification types
      await _handleNotificationByType(notificationType, notificationData);
    } catch (e) {
      developer.log(
        'Error handling notification tap: $e',
        name: 'NotificationActionHandler',
      );
    }
  }

  /// Handle notification based on its type
  Future<void> _handleNotificationByType(
    String type,
    Map<String, dynamic> data,
  ) async {
    switch (type) {
      // Booking-related notifications
      case NotificationTypes.bookingCreated:
      case NotificationTypes.bookingConfirmed:
      case NotificationTypes.bookingStarted:
      case NotificationTypes.bookingCompleted:
      case NotificationTypes.bookingCancelled:
      case NotificationTypes.bookingReminder:
        await _handleBookingNotification(data);
        break;

      // Job-related notifications (for partners)
      case NotificationTypes.newJobAvailable:
      case NotificationTypes.jobAccepted:
      case NotificationTypes.jobStarted:
      case NotificationTypes.jobCompleted:
      case NotificationTypes.jobCancelled:
        await _handleJobNotification(data);
        break;

      // Payment-related notifications
      case NotificationTypes.paymentReceived:
      case NotificationTypes.paymentFailed:
      case NotificationTypes.earningsUpdate:
        await _handlePaymentNotification(data);
        break;

      // System notifications
      case NotificationTypes.systemMaintenance:
      case NotificationTypes.appUpdate:
      case NotificationTypes.accountUpdate:
        await _handleSystemNotification(data);
        break;

      // Social notifications
      case NotificationTypes.ratingReceived:
      case NotificationTypes.reviewReceived:
        await _handleSocialNotification(data);
        break;

      // Promotional notifications
      case NotificationTypes.specialOffer:
      case NotificationTypes.discount:
        await _handlePromotionalNotification(data);
        break;

      default:
        developer.log(
          'Unknown notification type: $type',
          name: 'NotificationActionHandler',
        );
        _navigateToNotifications();
        break;
    }
  }

  /// Handle booking-related notifications
  Future<void> _handleBookingNotification(Map<String, dynamic> data) async {
    final bookingId = data['bookingId'] as String?;
    if (bookingId == null) {
      developer.log(
        'No booking ID found in notification data',
        name: 'NotificationActionHandler',
      );
      return;
    }

    // Navigate to booking details
    _navigateToBookingDetails(bookingId);
  }

  /// Handle job-related notifications (for partners)
  Future<void> _handleJobNotification(Map<String, dynamic> data) async {
    final jobId = data['jobId'] as String?;
    final bookingId = data['bookingId'] as String?;

    if (jobId == null && bookingId == null) {
      developer.log(
        'No job ID or booking ID found in notification data',
        name: 'NotificationActionHandler',
      );
      return;
    }

    // Check if user is a partner
    final userResult = await _userRepository.getCurrentUser();
    if (userResult.isRight()) {
      final user = (userResult as Right).value;
      if (user != null && user.isPartner) {
        // Navigate to partner job details
        _navigateToPartnerJobDetails(jobId ?? bookingId!);
      } else {
        // Navigate to client booking details
        _navigateToBookingDetails(bookingId ?? jobId!);
      }
    } else {
      // Fallback to notifications screen
      _navigateToNotifications();
    }
  }

  /// Handle payment-related notifications
  Future<void> _handlePaymentNotification(Map<String, dynamic> data) async {
    final bookingId = data['bookingId'] as String?;
    final type = data['type'] as String?;

    if (type == NotificationTypes.earningsUpdate) {
      // Navigate to partner earnings screen
      _navigateToPartnerEarnings();
    } else if (bookingId != null) {
      // Navigate to booking details for payment-related notifications
      _navigateToBookingDetails(bookingId);
    } else {
      // Navigate to general payment/earnings screen
      _navigateToPaymentHistory();
    }
  }

  /// Handle system notifications
  Future<void> _handleSystemNotification(Map<String, dynamic> data) async {
    final type = data['type'] as String?;

    switch (type) {
      case NotificationTypes.appUpdate:
        // Could open app store or update screen
        _navigateToSettings();
        break;
      case NotificationTypes.accountUpdate:
        // Navigate to profile/account settings
        _navigateToProfile();
        break;
      default:
        // Navigate to notifications for system maintenance, etc.
        _navigateToNotifications();
        break;
    }
  }

  /// Handle social notifications (ratings, reviews)
  Future<void> _handleSocialNotification(Map<String, dynamic> data) async {
    final bookingId = data['bookingId'] as String?;

    if (bookingId != null) {
      // Navigate to booking details to see rating/review
      _navigateToBookingDetails(bookingId);
    } else {
      // Navigate to reviews/ratings screen
      _navigateToReviews();
    }
  }

  /// Handle promotional notifications
  Future<void> _handlePromotionalNotification(Map<String, dynamic> data) async {
    final actionUrl = data['actionUrl'] as String?;

    if (actionUrl != null) {
      // Navigate to specific promotional page
      _navigateToUrl(actionUrl);
    } else {
      // Navigate to promotions/offers screen
      _navigateToPromotions();
    }
  }

  // Navigation helper methods
  void _navigateToLogin() {
    _router?.go('/login');
  }

  void _navigateToNotifications() {
    _router?.go('/notifications');
  }

  void _navigateToBookingDetails(String bookingId) {
    _router?.go('/booking/$bookingId');
  }

  void _navigateToPartnerJobDetails(String jobId) {
    _router?.go('/partner/job/$jobId');
  }

  void _navigateToPartnerEarnings() {
    _router?.go('/partner/earnings');
  }

  void _navigateToPaymentHistory() {
    _router?.go('/payment/history');
  }

  void _navigateToSettings() {
    _router?.go('/settings');
  }

  void _navigateToProfile() {
    _router?.go('/profile');
  }

  void _navigateToReviews() {
    _router?.go('/reviews');
  }

  void _navigateToPromotions() {
    _router?.go('/promotions');
  }

  void _navigateToUrl(String url) {
    // Handle custom URL navigation
    if (url.startsWith('/')) {
      _router?.go(url);
    } else {
      // Handle external URLs if needed
      developer.log(
        'External URL navigation not implemented: $url',
        name: 'NotificationActionHandler',
      );
    }
  }
}
