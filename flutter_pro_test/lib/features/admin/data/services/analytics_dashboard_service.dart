import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../../../../core/analytics/firebase_analytics_service.dart';
import '../../../../core/analytics/business_analytics_service.dart';
import '../../../../core/monitoring/monitoring_service.dart';
import '../../../../core/config/environment_config.dart';

/// Service for fetching and processing analytics data for the admin dashboard
class AnalyticsDashboardService {
  late final FirebaseAnalytics _analytics;
  late final FirebaseFirestore _firestore;
  late final FirebaseAnalyticsService _analyticsService;
  late final BusinessAnalyticsService _businessAnalytics;
  late final MonitoringService _monitoringService;

  // Stream controllers for real-time data
  final StreamController<Map<String, dynamic>> _userMetricsController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _performanceMetricsController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _businessMetricsController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _errorMetricsController =
      StreamController<Map<String, dynamic>>.broadcast();

  // Cached data
  Map<String, dynamic> _cachedUserMetrics = {};
  Map<String, dynamic> _cachedPerformanceMetrics = {};
  Map<String, dynamic> _cachedBusinessMetrics = {};
  Map<String, dynamic> _cachedErrorMetrics = {};

  // Refresh timers
  Timer? _userMetricsTimer;
  Timer? _performanceMetricsTimer;
  Timer? _businessMetricsTimer;
  Timer? _errorMetricsTimer;

  // Singleton instance
  static AnalyticsDashboardService? _instance;

  factory AnalyticsDashboardService({
    required FirebaseAnalytics analytics,
    required FirebaseFirestore firestore,
    required FirebaseAnalyticsService analyticsService,
    required BusinessAnalyticsService businessAnalytics,
    required MonitoringService monitoringService,
  }) {
    _instance ??= AnalyticsDashboardService._internal(
      analytics: analytics,
      firestore: firestore,
      analyticsService: analyticsService,
      businessAnalytics: businessAnalytics,
      monitoringService: monitoringService,
    );
    return _instance!;
  }

  AnalyticsDashboardService._internal({
    required FirebaseAnalytics analytics,
    required FirebaseFirestore firestore,
    required FirebaseAnalyticsService analyticsService,
    required BusinessAnalyticsService businessAnalytics,
    required MonitoringService monitoringService,
  }) {
    _analytics = analytics;
    _firestore = firestore;
    _analyticsService = analyticsService;
    _businessAnalytics = businessAnalytics;
    _monitoringService = monitoringService;
  }

  // Factory for default instance (production use)
  factory AnalyticsDashboardService.defaultInstance() {
    return AnalyticsDashboardService(
      analytics: FirebaseAnalytics.instance,
      firestore: FirebaseFirestore.instance,
      analyticsService: FirebaseAnalyticsService(),
      businessAnalytics: BusinessAnalyticsService(),
      monitoringService: MonitoringService(),
    );
  }

  // Reset instance for testing
  static void resetInstance() {
    _instance = null;
  }

  /// Initialize the analytics dashboard service
  Future<void> initialize() async {
    try {
      // Ensure Firebase Analytics is initialized
      if (!_analyticsService.isInitialized) {
        await _analyticsService.initialize();
      }

      // Start data refresh timers
      _startRefreshTimers();

      // Initial data load
      await Future.wait([
        _fetchUserMetrics(),
        _fetchPerformanceMetrics(),
        _fetchBusinessMetrics(),
        _fetchErrorMetrics(),
      ]);

      // Track dashboard initialization
      await _analyticsService.logEvent(
        'admin_analytics_dashboard_initialized',
        parameters: {
          'timestamp': DateTime.now().toIso8601String(),
          'environment': EnvironmentConfig.environment,
        },
      );

      _monitoringService.logInfo('Analytics Dashboard Service initialized');
    } catch (e, stackTrace) {
      _monitoringService.logError(
        'Failed to initialize Analytics Dashboard Service',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Start data refresh timers
  void _startRefreshTimers() {
    // Refresh user metrics every 60 seconds
    _userMetricsTimer = Timer.periodic(
      const Duration(seconds: 60),
      (_) => _fetchUserMetrics(),
    );

    // Refresh performance metrics every 30 seconds
    _performanceMetricsTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _fetchPerformanceMetrics(),
    );

    // Refresh business metrics every 2 minutes
    _businessMetricsTimer = Timer.periodic(
      const Duration(minutes: 2),
      (_) => _fetchBusinessMetrics(),
    );

    // Refresh error metrics every 45 seconds
    _errorMetricsTimer = Timer.periodic(
      const Duration(seconds: 45),
      (_) => _fetchErrorMetrics(),
    );
  }

  /// Fetch user metrics from Firebase Analytics and Firestore
  Future<Map<String, dynamic>> _fetchUserMetrics() async {
    try {
      // In a real implementation, this would fetch from Firebase Analytics API
      // For now, we'll use mock data with some randomization
      final now = DateTime.now();
      final activeUsers = 1000 + (now.minute % 10) * 50;
      final newUsers = 100 + (now.minute % 5) * 20;
      final retentionRate = 75.0 + (now.second % 10) / 2;

      // Fetch user data from Firestore
      final userSnapshot = await _firestore
          .collection('analytics')
          .doc('users')
          .get();

      final userData = userSnapshot.data() ?? {};

      // Combine data
      final metrics = {
        'active_users': activeUsers,
        'new_users': newUsers,
        'retention_rate': retentionRate,
        'total_users': userData['total_users'] ?? 12500,
        'avg_session_duration': userData['avg_session_duration'] ?? 8.5,
        'user_segments':
            userData['user_segments'] ??
            {'new': 0.3, 'regular': 0.5, 'power': 0.2},
        'timestamp': now.toIso8601String(),
      };

      _cachedUserMetrics = metrics;
      _userMetricsController.add(metrics);
      return metrics;
    } catch (e, stackTrace) {
      _monitoringService.logError(
        'Failed to fetch user metrics',
        error: e,
        stackTrace: stackTrace,
      );
      return _cachedUserMetrics;
    }
  }

  /// Fetch performance metrics
  Future<Map<String, dynamic>> _fetchPerformanceMetrics() async {
    try {
      // In a real implementation, this would fetch from Firebase Performance Monitoring
      // For now, we'll use mock data with some randomization
      final now = DateTime.now();
      final appLoadTime = 2.0 + (now.second % 10) / 20;
      final apiResponseTime = 400 + (now.second % 10) * 10;
      final memoryUsage = 60 + (now.second % 10);
      final cpuUsage = 20 + (now.second % 10);

      // Get health status from monitoring service
      final healthStatus = _monitoringService.getHealthStatus();

      // Combine data
      final metrics = {
        'app_load_time': appLoadTime,
        'api_response_time': apiResponseTime,
        'memory_usage': memoryUsage / 100,
        'cpu_usage': cpuUsage / 100,
        'health_status': healthStatus['status'] ?? 'unknown',
        'performance_score': healthStatus['score'] ?? 85,
        'timestamp': now.toIso8601String(),
      };

      _cachedPerformanceMetrics = metrics;
      _performanceMetricsController.add(metrics);
      return metrics;
    } catch (e, stackTrace) {
      _monitoringService.logError(
        'Failed to fetch performance metrics',
        error: e,
        stackTrace: stackTrace,
      );
      return _cachedPerformanceMetrics;
    }
  }

  /// Fetch business metrics
  Future<Map<String, dynamic>> _fetchBusinessMetrics() async {
    try {
      // In a real implementation, this would fetch from Firestore and other business data sources
      // For now, we'll use mock data with some randomization
      final now = DateTime.now();
      final revenueToday = 10000 + (now.hour * 100) + (now.minute * 5);
      final bookingsToday = 80 + (now.hour % 10);
      final conversionRate = 4.0 + (now.minute % 10) / 10;

      // Fetch business data from Firestore
      final businessSnapshot = await _firestore
          .collection('analytics')
          .doc('business')
          .get();

      final businessData = businessSnapshot.data() ?? {};

      // Combine data
      final metrics = {
        'revenue_today': revenueToday,
        'revenue_week': businessData['revenue_week'] ?? 87320,
        'revenue_month': businessData['revenue_month'] ?? 345670,
        'revenue_year': businessData['revenue_year'] ?? 2456890,
        'bookings_today': bookingsToday,
        'bookings_total': businessData['bookings_total'] ?? 1247,
        'bookings_completed': businessData['bookings_completed'] ?? 1156,
        'bookings_cancelled': businessData['bookings_cancelled'] ?? 67,
        'bookings_pending': businessData['bookings_pending'] ?? 24,
        'conversion_rate': conversionRate,
        'conversion_funnel':
            businessData['conversion_funnel'] ??
            {
              'app_opens': 10000,
              'service_browse': 7500,
              'booking_started': 3200,
              'payment': 2800,
              'completed': 2650,
            },
        'timestamp': now.toIso8601String(),
      };

      _cachedBusinessMetrics = metrics;
      _businessMetricsController.add(metrics);
      return metrics;
    } catch (e, stackTrace) {
      _monitoringService.logError(
        'Failed to fetch business metrics',
        error: e,
        stackTrace: stackTrace,
      );
      return _cachedBusinessMetrics;
    }
  }

  /// Fetch error metrics
  Future<Map<String, dynamic>> _fetchErrorMetrics() async {
    try {
      // In a real implementation, this would fetch from Firebase Crashlytics
      // For now, we'll use mock data with some randomization
      final now = DateTime.now();
      final appCrashes = (now.minute % 5);
      final networkErrors = 10 + (now.minute % 5);
      final validationErrors = 40 + (now.second % 10);
      final authErrors = (now.minute % 3);

      // Get error data from monitoring service
      final errorCounts = _monitoringService.getErrorStats();

      // Combine data
      final metrics = {
        'app_crashes': appCrashes,
        'network_errors': networkErrors,
        'validation_errors': validationErrors,
        'auth_errors': authErrors,
        'error_rate':
            (appCrashes + networkErrors + validationErrors + authErrors) /
            10000,
        'error_counts': errorCounts,
        'timestamp': now.toIso8601String(),
      };

      _cachedErrorMetrics = metrics;
      _errorMetricsController.add(metrics);
      return metrics;
    } catch (e, stackTrace) {
      _monitoringService.logError(
        'Failed to fetch error metrics',
        error: e,
        stackTrace: stackTrace,
      );
      return _cachedErrorMetrics;
    }
  }

  /// Get user metrics stream
  Stream<Map<String, dynamic>> get userMetricsStream =>
      _userMetricsController.stream;

  /// Get performance metrics stream
  Stream<Map<String, dynamic>> get performanceMetricsStream =>
      _performanceMetricsController.stream;

  /// Get business metrics stream
  Stream<Map<String, dynamic>> get businessMetricsStream =>
      _businessMetricsController.stream;

  /// Get error metrics stream
  Stream<Map<String, dynamic>> get errorMetricsStream =>
      _errorMetricsController.stream;

  /// Get latest user metrics
  Map<String, dynamic> get latestUserMetrics => _cachedUserMetrics;

  /// Get latest performance metrics
  Map<String, dynamic> get latestPerformanceMetrics =>
      _cachedPerformanceMetrics;

  /// Get latest business metrics
  Map<String, dynamic> get latestBusinessMetrics => _cachedBusinessMetrics;

  /// Get latest error metrics
  Map<String, dynamic> get latestErrorMetrics => _cachedErrorMetrics;

  /// Force refresh all metrics
  Future<void> refreshAllMetrics() async {
    await Future.wait([
      _fetchUserMetrics(),
      _fetchPerformanceMetrics(),
      _fetchBusinessMetrics(),
      _fetchErrorMetrics(),
    ]);
  }

  /// Dispose resources
  void dispose() {
    _userMetricsTimer?.cancel();
    _performanceMetricsTimer?.cancel();
    _businessMetricsTimer?.cancel();
    _errorMetricsTimer?.cancel();
    _userMetricsController.close();
    _performanceMetricsController.close();
    _businessMetricsController.close();
    _errorMetricsController.close();
  }
}
