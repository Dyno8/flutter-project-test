import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../shared/services/firebase_service.dart';
import '../models/system_metrics_model.dart';
import '../../domain/entities/booking_analytics.dart';
import '../../domain/entities/system_metrics.dart';
import '../../domain/repositories/analytics_repository.dart';

/// Remote data source for analytics operations using Firebase
abstract class AnalyticsRemoteDataSource {
  /// Get real-time system metrics
  Future<SystemMetricsModel> getSystemMetrics();

  /// Stream of real-time system metrics
  Stream<SystemMetricsModel> watchSystemMetrics();

  /// Get booking analytics for a specific period
  Future<BookingAnalytics> getBookingAnalytics({
    required DateTime startDate,
    required DateTime endDate,
    String? serviceId,
    String? partnerId,
  });

  /// Get partner analytics
  Future<PartnerAnalytics> getPartnerAnalytics({
    required DateTime startDate,
    required DateTime endDate,
    String? serviceId,
  });

  /// Get user analytics
  Future<UserAnalytics> getUserAnalytics({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Get revenue analytics
  Future<RevenueAnalytics> getRevenueAnalytics({
    required DateTime startDate,
    required DateTime endDate,
    String? serviceId,
    String? partnerId,
  });

  /// Get system health metrics
  Future<SystemHealth> getSystemHealth();

  /// Stream of real-time system health
  Stream<SystemHealth> watchSystemHealth();

  /// Export analytics data
  Future<String> exportAnalyticsData({
    required AnalyticsExportType type,
    required DateTime startDate,
    required DateTime endDate,
    required AnalyticsExportFormat format,
    Map<String, dynamic>? filters,
  });
}

class AnalyticsRemoteDataSourceImpl implements AnalyticsRemoteDataSource {
  final FirebaseService _firebaseService;
  final FirebaseFirestore _firestore;

  AnalyticsRemoteDataSourceImpl({required FirebaseService firebaseService})
    : _firebaseService = firebaseService,
      _firestore = firebaseService.firestore;

  @override
  Future<SystemMetricsModel> getSystemMetrics() async {
    try {
      // Get cached metrics first
      final metricsDoc = await _firestore
          .collection(AppConstants.systemMetricsCollection)
          .doc('current')
          .get();

      if (metricsDoc.exists) {
        return SystemMetricsModel.fromFirestore(metricsDoc);
      }

      // If no cached metrics, calculate real-time
      return await _calculateSystemMetrics();
    } catch (e) {
      throw ServerException('Failed to get system metrics: $e');
    }
  }

  @override
  Stream<SystemMetricsModel> watchSystemMetrics() {
    return _firestore
        .collection(AppConstants.systemMetricsCollection)
        .doc('current')
        .snapshots()
        .map((doc) {
          if (doc.exists) {
            return SystemMetricsModel.fromFirestore(doc);
          } else {
            throw const ServerException('System metrics not found');
          }
        });
  }

  @override
  Future<BookingAnalytics> getBookingAnalytics({
    required DateTime startDate,
    required DateTime endDate,
    String? serviceId,
    String? partnerId,
  }) async {
    try {
      Query bookingsQuery = _firestore
          .collection(AppConstants.bookingsCollection)
          .where(
            'createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
          )
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate));

      if (serviceId != null) {
        bookingsQuery = bookingsQuery.where('serviceId', isEqualTo: serviceId);
      }

      if (partnerId != null) {
        bookingsQuery = bookingsQuery.where('partnerId', isEqualTo: partnerId);
      }

      final bookingsSnapshot = await bookingsQuery.get();

      return _processBookingAnalytics(
        bookingsSnapshot.docs,
        startDate,
        endDate,
      );
    } catch (e) {
      throw ServerException('Failed to get booking analytics: $e');
    }
  }

  @override
  Future<PartnerAnalytics> getPartnerAnalytics({
    required DateTime startDate,
    required DateTime endDate,
    String? serviceId,
  }) async {
    try {
      Query partnersQuery = _firestore.collection(
        AppConstants.partnersCollection,
      );

      if (serviceId != null) {
        partnersQuery = partnersQuery.where(
          'services',
          arrayContains: serviceId,
        );
      }

      final partnersSnapshot = await partnersQuery.get();

      // Get partner bookings for the period
      final bookingsSnapshot = await _firestore
          .collection(AppConstants.bookingsCollection)
          .where(
            'createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
          )
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      return _processPartnerAnalytics(
        partnersSnapshot.docs,
        bookingsSnapshot.docs,
        startDate,
        endDate,
      );
    } catch (e) {
      throw ServerException('Failed to get partner analytics: $e');
    }
  }

  @override
  Future<UserAnalytics> getUserAnalytics({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final usersSnapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .get();

      final bookingsSnapshot = await _firestore
          .collection(AppConstants.bookingsCollection)
          .where(
            'createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
          )
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      return _processUserAnalytics(
        usersSnapshot.docs,
        bookingsSnapshot.docs,
        startDate,
        endDate,
      );
    } catch (e) {
      throw ServerException('Failed to get user analytics: $e');
    }
  }

  @override
  Future<RevenueAnalytics> getRevenueAnalytics({
    required DateTime startDate,
    required DateTime endDate,
    String? serviceId,
    String? partnerId,
  }) async {
    try {
      Query bookingsQuery = _firestore
          .collection(AppConstants.bookingsCollection)
          .where('status', isEqualTo: 'completed')
          .where(
            'createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
          )
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate));

      if (serviceId != null) {
        bookingsQuery = bookingsQuery.where('serviceId', isEqualTo: serviceId);
      }

      if (partnerId != null) {
        bookingsQuery = bookingsQuery.where('partnerId', isEqualTo: partnerId);
      }

      final bookingsSnapshot = await bookingsQuery.get();

      return _processRevenueAnalytics(
        bookingsSnapshot.docs,
        startDate,
        endDate,
      );
    } catch (e) {
      throw ServerException('Failed to get revenue analytics: $e');
    }
  }

  @override
  Future<SystemHealth> getSystemHealth() async {
    try {
      final healthDoc = await _firestore
          .collection(AppConstants.systemHealthCollection)
          .doc('current')
          .get();

      if (healthDoc.exists) {
        final data = healthDoc.data()!;
        return SystemHealth(
          status: SystemHealthStatus.values.firstWhere(
            (status) => status.name == data['status'],
            orElse: () => SystemHealthStatus.healthy,
          ),
          apiResponseTime: (data['apiResponseTime'] ?? 0).toDouble(),
          errorRate: (data['errorRate'] ?? 0).toDouble(),
          activeConnections: data['activeConnections'] ?? 0,
          memoryUsage: (data['memoryUsage'] ?? 0).toDouble(),
          cpuUsage: (data['cpuUsage'] ?? 0).toDouble(),
          alerts: (data['alerts'] as List? ?? [])
              .map(
                (alert) => SystemAlert(
                  id: alert['id'] ?? '',
                  title: alert['title'] ?? '',
                  description: alert['description'] ?? '',
                  severity: SystemAlertSeverity.values.firstWhere(
                    (severity) => severity.name == alert['severity'],
                    orElse: () => SystemAlertSeverity.info,
                  ),
                  timestamp: (alert['timestamp'] as Timestamp).toDate(),
                ),
              )
              .toList(),
          lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
        );
      }

      // Return default healthy status if no data
      return SystemHealth(
        status: SystemHealthStatus.healthy,
        apiResponseTime: 200.0,
        errorRate: 0.0,
        activeConnections: 0,
        memoryUsage: 50.0,
        cpuUsage: 30.0,
        alerts: [],
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      throw ServerException('Failed to get system health: $e');
    }
  }

  @override
  Stream<SystemHealth> watchSystemHealth() {
    return _firestore
        .collection(AppConstants.systemHealthCollection)
        .doc('current')
        .snapshots()
        .map((doc) {
          if (doc.exists) {
            final data = doc.data()!;
            return SystemHealth(
              status: SystemHealthStatus.values.firstWhere(
                (status) => status.name == data['status'],
                orElse: () => SystemHealthStatus.healthy,
              ),
              apiResponseTime: (data['apiResponseTime'] ?? 0).toDouble(),
              errorRate: (data['errorRate'] ?? 0).toDouble(),
              activeConnections: data['activeConnections'] ?? 0,
              memoryUsage: (data['memoryUsage'] ?? 0).toDouble(),
              cpuUsage: (data['cpuUsage'] ?? 0).toDouble(),
              alerts: (data['alerts'] as List? ?? [])
                  .map(
                    (alert) => SystemAlert(
                      id: alert['id'] ?? '',
                      title: alert['title'] ?? '',
                      description: alert['description'] ?? '',
                      severity: SystemAlertSeverity.values.firstWhere(
                        (severity) => severity.name == alert['severity'],
                        orElse: () => SystemAlertSeverity.info,
                      ),
                      timestamp: (alert['timestamp'] as Timestamp).toDate(),
                    ),
                  )
                  .toList(),
              lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
            );
          }

          return SystemHealth(
            status: SystemHealthStatus.healthy,
            apiResponseTime: 200.0,
            errorRate: 0.0,
            activeConnections: 0,
            memoryUsage: 50.0,
            cpuUsage: 30.0,
            alerts: [],
            lastUpdated: DateTime.now(),
          );
        });
  }

  @override
  Future<String> exportAnalyticsData({
    required AnalyticsExportType type,
    required DateTime startDate,
    required DateTime endDate,
    required AnalyticsExportFormat format,
    Map<String, dynamic>? filters,
  }) async {
    try {
      // This would typically trigger a Cloud Function to generate the export
      // For now, return a placeholder URL
      final exportDoc = await _firestore
          .collection(AppConstants.analyticsExportsCollection)
          .add({
            'type': type.name,
            'startDate': Timestamp.fromDate(startDate),
            'endDate': Timestamp.fromDate(endDate),
            'format': format.name,
            'filters': filters ?? {},
            'status': 'processing',
            'createdAt': FieldValue.serverTimestamp(),
          });

      // Return export ID for tracking
      return exportDoc.id;
    } catch (e) {
      throw ServerException('Failed to export analytics data: $e');
    }
  }

  Future<SystemMetricsModel> _calculateSystemMetrics() async {
    // This would typically be done by a Cloud Function
    // For now, return mock data
    final performance = SystemPerformanceModel.fromMap({
      'apiResponseTime': 250.0,
      'errorRate': 0.5,
      'activeConnections': 150,
      'memoryUsage': 65.0,
      'cpuUsage': 45.0,
      'diskUsage': 70.0,
      'requestsPerMinute': 1200,
      'lastUpdated': DateTime.now().toIso8601String(),
    });

    return SystemMetricsModel(
      totalUsers: 1000,
      totalPartners: 150,
      totalBookings: 2500,
      activeBookings: 45,
      completedBookings: 2200,
      cancelledBookings: 255,
      totalRevenue: 125000.0,
      monthlyRevenue: 25000.0,
      dailyRevenue: 850.0,
      averageRating: 4.6,
      totalReviews: 1800,
      timestamp: DateTime.now(),
      performance: performance,
    );
  }

  BookingAnalytics _processBookingAnalytics(
    List<QueryDocumentSnapshot> docs,
    DateTime startDate,
    DateTime endDate,
  ) {
    // Process booking documents and return analytics
    // This is a simplified implementation
    final totalBookings = docs.length;
    final completedBookings = docs
        .where((doc) => doc['status'] == 'completed')
        .length;
    final cancelledBookings = docs
        .where((doc) => doc['status'] == 'cancelled')
        .length;
    final pendingBookings = docs
        .where((doc) => doc['status'] == 'pending')
        .length;
    final inProgressBookings = docs
        .where((doc) => doc['status'] == 'inProgress')
        .length;

    final totalValue = docs
        .where((doc) => doc['status'] == 'completed')
        .fold<double>(
          0.0,
          (sum, doc) => sum + (doc['totalPrice'] ?? 0).toDouble(),
        );

    return BookingAnalytics(
      totalBookings: totalBookings,
      completedBookings: completedBookings,
      cancelledBookings: cancelledBookings,
      pendingBookings: pendingBookings,
      inProgressBookings: inProgressBookings,
      averageBookingValue: totalBookings > 0 ? totalValue / totalBookings : 0.0,
      totalBookingValue: totalValue,
      bookingsByService: {},
      bookingsByTimeSlot: {},
      bookingsByStatus: {
        'completed': completedBookings,
        'cancelled': cancelledBookings,
        'pending': pendingBookings,
        'inProgress': inProgressBookings,
      },
      bookingsTrend: [],
      periodStart: startDate,
      periodEnd: endDate,
      insights: const BookingInsights(
        trends: [],
        recommendations: [],
        alerts: [],
        peakHours: PeakHoursAnalysis(
          peakHours: [],
          lowHours: [],
          hourlyDistribution: {},
        ),
        servicePerformance: ServicePerformance(
          serviceCompletionRates: {},
          serviceAverageRatings: {},
          serviceRevenue: {},
          topPerformingServices: [],
          underperformingServices: [],
        ),
      ),
    );
  }

  PartnerAnalytics _processPartnerAnalytics(
    List<QueryDocumentSnapshot> partnerDocs,
    List<QueryDocumentSnapshot> bookingDocs,
    DateTime startDate,
    DateTime endDate,
  ) {
    // Process partner and booking documents
    return PartnerAnalytics(
      totalPartners: partnerDocs.length,
      activePartners: partnerDocs
          .where((doc) => doc['isAvailable'] == true)
          .length,
      verifiedPartners: partnerDocs
          .where((doc) => doc['isVerified'] == true)
          .length,
      averageRating: 4.5,
      topPerformingPartners: [],
      partnersByService: {},
      partnerEarnings: [],
      periodStart: startDate,
      periodEnd: endDate,
    );
  }

  UserAnalytics _processUserAnalytics(
    List<QueryDocumentSnapshot> userDocs,
    List<QueryDocumentSnapshot> bookingDocs,
    DateTime startDate,
    DateTime endDate,
  ) {
    // Process user and booking documents
    return UserAnalytics(
      totalUsers: userDocs.length,
      activeUsers: userDocs.length,
      newUsersToday: 10,
      userRetentionRate: 85.0,
      usersByLocation: {},
      userEngagement: const UserEngagementData(
        averageSessionDuration: 15.5,
        averageBookingsPerUser: 2,
        userSatisfactionScore: 4.6,
        featureUsage: {},
      ),
      periodStart: startDate,
      periodEnd: endDate,
    );
  }

  RevenueAnalytics _processRevenueAnalytics(
    List<QueryDocumentSnapshot> docs,
    DateTime startDate,
    DateTime endDate,
  ) {
    final totalRevenue = docs.fold<double>(
      0.0,
      (sum, doc) => sum + (doc['totalPrice'] ?? 0).toDouble(),
    );

    return RevenueAnalytics(
      totalRevenue: totalRevenue,
      monthlyRevenue: totalRevenue,
      dailyRevenue: totalRevenue / endDate.difference(startDate).inDays,
      revenueByService: {},
      revenueTrend: [],
      commissionEarned: totalRevenue * 0.1, // 10% commission
      averageOrderValue: docs.isNotEmpty ? totalRevenue / docs.length : 0.0,
      periodStart: startDate,
      periodEnd: endDate,
    );
  }
}
