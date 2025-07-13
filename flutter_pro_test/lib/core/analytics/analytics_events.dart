/// Comprehensive analytics events for CareNow MVP
/// Defines all custom events, parameters, and user properties for tracking
class AnalyticsEvents {
  // Private constructor to prevent instantiation
  AnalyticsEvents._();

  // ========== USER AUTHENTICATION EVENTS ==========
  static const String userSignUp = 'user_sign_up';
  static const String userSignIn = 'user_sign_in';
  static const String userSignOut = 'user_sign_out';
  static const String passwordReset = 'password_reset';
  static const String emailVerification = 'email_verification';
  static const String profileCompleted = 'profile_completed';

  // ========== BOOKING EVENTS ==========
  static const String bookingStarted = 'booking_started';
  static const String bookingCompleted = 'booking_completed';
  static const String bookingCancelled = 'booking_cancelled';
  static const String bookingModified = 'booking_modified';
  static const String bookingPaymentCompleted = 'booking_payment_completed';
  static const String bookingPaymentFailed = 'booking_payment_failed';
  static const String bookingRescheduled = 'booking_rescheduled';
  static const String bookingReviewed = 'booking_reviewed';

  // ========== PARTNER EVENTS ==========
  static const String partnerRegistration = 'partner_registration';
  static const String partnerProfileCompleted = 'partner_profile_completed';
  static const String partnerJobAccepted = 'partner_job_accepted';
  static const String partnerJobDeclined = 'partner_job_declined';
  static const String partnerJobCompleted = 'partner_job_completed';
  static const String partnerEarningsViewed = 'partner_earnings_viewed';
  static const String partnerAvailabilityUpdated = 'partner_availability_updated';

  // ========== SERVICE EVENTS ==========
  static const String serviceViewed = 'service_viewed';
  static const String serviceSelected = 'service_selected';
  static const String serviceSearched = 'service_searched';
  static const String serviceCategoryViewed = 'service_category_viewed';
  static const String serviceProviderViewed = 'service_provider_viewed';

  // ========== PAYMENT EVENTS ==========
  static const String paymentMethodAdded = 'payment_method_added';
  static const String paymentMethodRemoved = 'payment_method_removed';
  static const String paymentProcessed = 'payment_processed';
  static const String paymentFailed = 'payment_failed';
  static const String refundRequested = 'refund_requested';
  static const String refundProcessed = 'refund_processed';

  // ========== NOTIFICATION EVENTS ==========
  static const String notificationReceived = 'notification_received';
  static const String notificationOpened = 'notification_opened';
  static const String notificationDismissed = 'notification_dismissed';
  static const String pushPermissionGranted = 'push_permission_granted';
  static const String pushPermissionDenied = 'push_permission_denied';

  // ========== ADMIN EVENTS ==========
  static const String adminLogin = 'admin_login';
  static const String adminDashboardViewed = 'admin_dashboard_viewed';
  static const String adminUserManagement = 'admin_user_management';
  static const String adminPartnerManagement = 'admin_partner_management';
  static const String adminAnalyticsViewed = 'admin_analytics_viewed';
  static const String adminReportGenerated = 'admin_report_generated';
  static const String adminSystemMonitoring = 'admin_system_monitoring';

  // ========== APP LIFECYCLE EVENTS ==========
  static const String appOpened = 'app_opened';
  static const String appClosed = 'app_closed';
  static const String appBackgrounded = 'app_backgrounded';
  static const String appForegrounded = 'app_foregrounded';
  static const String appCrashed = 'app_crashed';
  static const String appUpdated = 'app_updated';

  // ========== PERFORMANCE EVENTS ==========
  static const String screenLoadTime = 'screen_load_time';
  static const String apiResponseTime = 'api_response_time';
  static const String imageLoadTime = 'image_load_time';
  static const String databaseQueryTime = 'database_query_time';
  static const String performanceIssue = 'performance_issue';

  // ========== ERROR EVENTS ==========
  static const String errorOccurred = 'error_occurred';
  static const String networkError = 'network_error';
  static const String validationError = 'validation_error';
  static const String authenticationError = 'authentication_error';
  static const String permissionError = 'permission_error';

  // ========== ENGAGEMENT EVENTS ==========
  static const String featureUsed = 'feature_used';
  static const String tutorialStarted = 'tutorial_started';
  static const String tutorialCompleted = 'tutorial_completed';
  static const String helpViewed = 'help_viewed';
  static const String feedbackSubmitted = 'feedback_submitted';
  static const String shareAction = 'share_action';

  // ========== BUSINESS METRICS EVENTS ==========
  static const String revenueGenerated = 'revenue_generated';
  static const String conversionFunnel = 'conversion_funnel';
  static const String userRetention = 'user_retention';
  static const String churnPrediction = 'churn_prediction';
  static const String lifetimeValue = 'lifetime_value';
}

/// Analytics event parameters for consistent tracking
class AnalyticsParameters {
  // Private constructor to prevent instantiation
  AnalyticsParameters._();

  // ========== COMMON PARAMETERS ==========
  static const String userId = 'user_id';
  static const String userType = 'user_type';
  static const String sessionId = 'session_id';
  static const String timestamp = 'timestamp';
  static const String platform = 'platform';
  static const String appVersion = 'app_version';
  static const String environment = 'environment';

  // ========== USER PARAMETERS ==========
  static const String userAge = 'user_age';
  static const String userGender = 'user_gender';
  static const String userLocation = 'user_location';
  static const String userRegistrationDate = 'user_registration_date';
  static const String userTier = 'user_tier';

  // ========== BOOKING PARAMETERS ==========
  static const String bookingId = 'booking_id';
  static const String serviceId = 'service_id';
  static const String serviceName = 'service_name';
  static const String serviceCategory = 'service_category';
  static const String partnerId = 'partner_id';
  static const String partnerName = 'partner_name';
  static const String bookingDate = 'booking_date';
  static const String bookingTime = 'booking_time';
  static const String bookingDuration = 'booking_duration';
  static const String bookingAmount = 'booking_amount';
  static const String bookingStatus = 'booking_status';

  // ========== PAYMENT PARAMETERS ==========
  static const String paymentMethod = 'payment_method';
  static const String paymentAmount = 'payment_amount';
  static const String paymentCurrency = 'payment_currency';
  static const String paymentStatus = 'payment_status';
  static const String transactionId = 'transaction_id';
  static const String paymentProvider = 'payment_provider';

  // ========== PERFORMANCE PARAMETERS ==========
  static const String loadTime = 'load_time';
  static const String responseTime = 'response_time';
  static const String screenName = 'screen_name';
  static const String apiEndpoint = 'api_endpoint';
  static const String errorType = 'error_type';
  static const String errorMessage = 'error_message';
  static const String errorCode = 'error_code';

  // ========== ENGAGEMENT PARAMETERS ==========
  static const String featureName = 'feature_name';
  static const String actionType = 'action_type';
  static const String contentType = 'content_type';
  static const String contentId = 'content_id';
  static const String searchQuery = 'search_query';
  static const String filterApplied = 'filter_applied';

  // ========== BUSINESS PARAMETERS ==========
  static const String revenue = 'revenue';
  static const String conversionStep = 'conversion_step';
  static const String funnelStage = 'funnel_stage';
  static const String campaignId = 'campaign_id';
  static const String referralSource = 'referral_source';
  static const String acquisitionChannel = 'acquisition_channel';
}

/// User properties for analytics segmentation
class AnalyticsUserProperties {
  // Private constructor to prevent instantiation
  AnalyticsUserProperties._();

  // ========== USER DEMOGRAPHICS ==========
  static const String userType = 'user_type';
  static const String userTier = 'user_tier';
  static const String registrationDate = 'registration_date';
  static const String lastActiveDate = 'last_active_date';
  static const String totalBookings = 'total_bookings';
  static const String totalSpent = 'total_spent';
  static const String preferredServices = 'preferred_services';
  static const String location = 'location';
  static const String ageGroup = 'age_group';
  static const String gender = 'gender';

  // ========== PARTNER PROPERTIES ==========
  static const String partnerRating = 'partner_rating';
  static const String partnerExperience = 'partner_experience';
  static const String partnerServices = 'partner_services';
  static const String partnerAvailability = 'partner_availability';
  static const String partnerEarnings = 'partner_earnings';
  static const String partnerJobsCompleted = 'partner_jobs_completed';

  // ========== BEHAVIORAL PROPERTIES ==========
  static const String appUsageFrequency = 'app_usage_frequency';
  static const String averageSessionDuration = 'average_session_duration';
  static const String favoriteFeatures = 'favorite_features';
  static const String notificationPreferences = 'notification_preferences';
  static const String paymentPreferences = 'payment_preferences';
  static const String bookingPatterns = 'booking_patterns';

  // ========== ENGAGEMENT PROPERTIES ==========
  static const String engagementScore = 'engagement_score';
  static const String churnRisk = 'churn_risk';
  static const String lifetimeValue = 'lifetime_value';
  static const String referralCount = 'referral_count';
  static const String reviewsGiven = 'reviews_given';
  static const String helpRequestsCount = 'help_requests_count';
}

/// Screen names for consistent screen tracking
class AnalyticsScreens {
  // Private constructor to prevent instantiation
  AnalyticsScreens._();

  // ========== AUTH SCREENS ==========
  static const String loginScreen = 'login_screen';
  static const String signupScreen = 'signup_screen';
  static const String forgotPasswordScreen = 'forgot_password_screen';
  static const String emailVerificationScreen = 'email_verification_screen';

  // ========== CLIENT SCREENS ==========
  static const String homeScreen = 'home_screen';
  static const String servicesScreen = 'services_screen';
  static const String serviceDetailScreen = 'service_detail_screen';
  static const String bookingScreen = 'booking_screen';
  static const String bookingConfirmationScreen = 'booking_confirmation_screen';
  static const String bookingHistoryScreen = 'booking_history_screen';
  static const String profileScreen = 'profile_screen';
  static const String paymentScreen = 'payment_screen';
  static const String reviewScreen = 'review_screen';

  // ========== PARTNER SCREENS ==========
  static const String partnerDashboardScreen = 'partner_dashboard_screen';
  static const String partnerJobsScreen = 'partner_jobs_screen';
  static const String partnerEarningsScreen = 'partner_earnings_screen';
  static const String partnerProfileScreen = 'partner_profile_screen';
  static const String partnerAvailabilityScreen = 'partner_availability_screen';

  // ========== ADMIN SCREENS ==========
  static const String adminDashboardScreen = 'admin_dashboard_screen';
  static const String adminUsersScreen = 'admin_users_screen';
  static const String adminPartnersScreen = 'admin_partners_screen';
  static const String adminAnalyticsScreen = 'admin_analytics_screen';
  static const String adminReportsScreen = 'admin_reports_screen';
  static const String adminSystemMonitoringScreen = 'admin_system_monitoring_screen';

  // ========== COMMON SCREENS ==========
  static const String settingsScreen = 'settings_screen';
  static const String helpScreen = 'help_screen';
  static const String notificationsScreen = 'notifications_screen';
  static const String searchScreen = 'search_screen';
  static const String errorScreen = 'error_screen';
  static const String loadingScreen = 'loading_screen';
}

/// Conversion funnel stages for tracking user journey
class AnalyticsFunnelStages {
  // Private constructor to prevent instantiation
  AnalyticsFunnelStages._();

  // ========== CLIENT BOOKING FUNNEL ==========
  static const String serviceDiscovery = 'service_discovery';
  static const String serviceSelection = 'service_selection';
  static const String providerSelection = 'provider_selection';
  static const String bookingDetails = 'booking_details';
  static const String paymentInfo = 'payment_info';
  static const String bookingConfirmation = 'booking_confirmation';
  static const String serviceCompletion = 'service_completion';
  static const String reviewSubmission = 'review_submission';

  // ========== PARTNER ONBOARDING FUNNEL ==========
  static const String partnerSignup = 'partner_signup';
  static const String profileSetup = 'profile_setup';
  static const String documentVerification = 'document_verification';
  static const String skillsAssessment = 'skills_assessment';
  static const String backgroundCheck = 'background_check';
  static const String partnerApproval = 'partner_approval';
  static const String firstJobAcceptance = 'first_job_acceptance';

  // ========== USER ENGAGEMENT FUNNEL ==========
  static const String appInstall = 'app_install';
  static const String firstLaunch = 'first_launch';
  static const String accountCreation = 'account_creation';
  static const String profileCompletion = 'profile_completion';
  static const String firstBooking = 'first_booking';
  static const String repeatBooking = 'repeat_booking';
  static const String loyalUser = 'loyal_user';
}
