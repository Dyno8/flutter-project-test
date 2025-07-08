class AppConstants {
  // App Info
  static const String appName = 'CareNow';
  static const String appVersion = '1.0.0';

  // User Roles
  static const String roleClient = 'client';
  static const String rolePartner = 'partner';

  // Booking Status
  static const String statusPending = 'pending';
  static const String statusConfirmed = 'confirmed';
  static const String statusInProgress = 'in-progress';
  static const String statusCompleted = 'completed';
  static const String statusCancelled = 'cancelled';

  // Payment Status
  static const String paymentPaid = 'paid';
  static const String paymentUnpaid = 'unpaid';

  // Service Types
  static const String serviceElderCare = 'elder_care';
  static const String servicePetCare = 'pet_care';
  static const String serviceChildCare = 'child_care';
  static const String serviceHousekeeping = 'housekeeping';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String partnersCollection = 'partners';
  static const String servicesCollection = 'services';
  static const String bookingsCollection = 'bookings';
  static const String reviewsCollection = 'reviews';
  static const String notificationsCollection = 'notifications';
  static const String notificationPreferencesCollection =
      'notification_preferences';

  // Admin Collections
  static const String adminUsersCollection = 'admin_users';
  static const String adminActivityLogsCollection = 'admin_activity_logs';
  static const String systemMetricsCollection = 'system_metrics';
  static const String systemHealthCollection = 'system_health';
  static const String analyticsExportsCollection = 'analytics_exports';

  // Shared Preferences Keys
  static const String keyUserRole = 'user_role';
  static const String keyUserId = 'user_id';
  static const String keyIsFirstTime = 'is_first_time';

  // API Endpoints (for future use)
  static const String baseUrl = 'https://api.carenow.com';

  // Pagination
  static const int defaultPageSize = 20;

  // Location
  static const double defaultLatitude = 10.8231; // Ho Chi Minh City
  static const double defaultLongitude = 106.6297;
  static const double searchRadius = 10.0; // km
}
