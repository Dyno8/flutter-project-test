import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../shared/services/firebase_service.dart';
import '../models/system_metrics_model.dart';
import '../../domain/entities/booking_analytics.dart';
import '../../domain/entities/system_metrics.dart';
import '../../domain/entities/partner_analytics.dart';
import '../../domain/entities/user_analytics.dart';
import '../../domain/entities/revenue_analytics.dart';
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
  final FirebaseFirestore _firestore;

  AnalyticsRemoteDataSourceImpl({required FirebaseService firebaseService})
    : _firestore = firebaseService.firestore;

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
      // Simplified implementation - return mock data for now
      return PartnerAnalytics(
        totalPartners: 100,
        activePartners: 85,
        newPartners: 5,
        inactivePartners: 10,
        suspendedPartners: 5,
        averageRating: 4.5,
        averageCompletionRate: 92.5,
        averageResponseTime: 2.5,
        partnersByRegion: const {
          'Ho Chi Minh City': 50,
          'Hanoi': 30,
          'Da Nang': 20,
        },
        partnersByService: const {
          'Home Cleaning': 40,
          'Plumbing': 25,
          'Electrical': 20,
          'Gardening': 15,
        },
        partnersByRating: const {'5': 30, '4': 25, '3': 20, '2': 15, '1': 10},
        partnerGrowthTrend: [],
        topPerformers: [],
        underPerformers: [],
        periodStart: startDate,
        periodEnd: endDate,
        insights: const PartnerInsights(
          performanceTrends: ['Partner growth increased by 12%'],
          recommendations: ['Focus on partner retention'],
          alerts: [],
          capacityAnalysis: PartnerCapacityAnalysis(
            currentUtilization: 75.0,
            optimalUtilization: 80.0,
            availableCapacity: 250,
            utilizationByService: {'Home Cleaning': 80.0, 'Plumbing': 70.0},
            utilizationByRegion: {'Ho Chi Minh City': 85.0, 'Hanoi': 65.0},
          ),
          trainingNeeds: PartnerTrainingNeeds(
            skillGaps: ['Customer Service', 'Technical Skills'],
            trainingRecommendations: [
              'Communication Training',
              'Safety Protocols',
            ],
            partnersNeedingTraining: {'Customer Service': 15, 'Technical': 10},
            availablePrograms: [],
          ),
        ),
        qualityMetrics: const PartnerQualityMetrics(
          averageCustomerSatisfaction: 4.5,
          averageJobQuality: 4.3,
          averagePunctuality: 4.6,
          averageProfessionalism: 4.4,
          qualityByService: {'Home Cleaning': 4.5, 'Plumbing': 4.2},
          qualityTrends: [],
        ),
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
      // Simplified implementation - return mock data for now
      return UserAnalytics(
        totalUsers: 1000,
        activeUsers: 750,
        newUsers: 50,
        returningUsers: 700,
        inactiveUsers: 250,
        userRetentionRate: 85.0,
        userChurnRate: 15.0,
        averageSessionDuration: 15.5,
        usersByRegion: const {
          'Ho Chi Minh City': 600,
          'Hanoi': 300,
          'Da Nang': 100,
        },
        usersByAgeGroup: const {'18-25': 300, '26-35': 450, '36-50': 250},
        usersByGender: const {'Male': 450, 'Female': 550},
        userGrowthTrend: [],
        cohortAnalysis: [],
        periodStart: startDate,
        periodEnd: endDate,
        behaviorInsights: const UserBehaviorInsights(
          behaviorTrends: ['User engagement increased by 15%'],
          recommendations: ['Focus on user retention'],
          alerts: [],
          segmentation: UserSegmentation(
            segmentsByValue: {
              'High Value': 300,
              'Medium Value': 500,
              'Low Value': 200,
            },
            segmentsByActivity: {'Active': 600, 'Inactive': 400},
            segmentsByLifecycle: {'New': 250, 'Returning': 600, 'Churned': 150},
            customSegments: [],
          ),
          journeyAnalysis: UserJourneyAnalysis(
            conversionFunnel: {
              'Impression': 100.0,
              'Click': 15.0,
              'Signup': 3.0,
              'Purchase': 1.0,
            },
            dropOffPoints: {
              'Landing Page': 85.0,
              'Signup Form': 12.0,
              'Checkout': 2.0,
            },
            commonPaths: [
              'Home -> Search -> Booking',
              'Home -> Profile -> Booking',
            ],
            averageTimeToConversion: 5.5,
          ),
        ),
        engagement: const UserEngagementMetrics(
          averageSessionsPerUser: 3.5,
          averagePageViewsPerSession: 8.2,
          bounceRate: 25.0,
          featureUsage: {'Search': 85.0, 'Booking': 70.0, 'Profile': 45.0},
          timeSpentByFeature: {
            'Search': 120.0,
            'Booking': 300.0,
            'Profile': 60.0,
          },
        ),
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
          (total, doc) => total + (doc['totalPrice'] ?? 0).toDouble(),
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

  RevenueAnalytics _processRevenueAnalytics(
    List<QueryDocumentSnapshot> docs,
    DateTime startDate,
    DateTime endDate,
  ) {
    final totalRevenue = docs.fold<double>(
      0.0,
      (total, doc) => total + (doc['totalPrice'] ?? 0).toDouble(),
    );

    return RevenueAnalytics(
      totalRevenue: totalRevenue,
      monthlyRevenue: totalRevenue,
      weeklyRevenue: totalRevenue / 4, // Approximate weekly revenue
      dailyRevenue: totalRevenue / endDate.difference(startDate).inDays,
      averageOrderValue: docs.isNotEmpty ? totalRevenue / docs.length : 0.0,
      totalCommissions: totalRevenue * 0.1, // 10% commission
      netRevenue: totalRevenue * 0.9, // Revenue after commissions
      revenueByService: const {
        'Home Cleaning': 45000.0,
        'Plumbing': 35000.0,
        'Electrical': 25000.0,
      },
      revenueByPartner: const {
        'Partner1': 30000.0,
        'Partner2': 25000.0,
        'Partner3': 20000.0,
      },
      revenueByRegion: const {
        'Ho Chi Minh City': 60000.0,
        'Hanoi': 40000.0,
        'Da Nang': 25000.0,
      },
      revenueTrend: [],
      monthlyTrend: [],
      periodStart: startDate,
      periodEnd: endDate,
      insights: RevenueInsights(
        trends: ['Revenue growth increased by 15%'],
        recommendations: ['Focus on high-value services'],
        alerts: [],
        seasonalAnalysis: SeasonalAnalysis(
          monthlyPatterns: {
            'January': 0.8,
            'February': 0.7,
            'March': 0.9,
            'April': 1.0,
            'May': 1.1,
            'June': 1.3,
            'July': 1.4,
            'August': 1.2,
            'September': 1.0,
            'October': 1.1,
            'November': 1.2,
            'December': 1.5,
          },
          weeklyPatterns: {
            'Monday': 1.0,
            'Tuesday': 1.1,
            'Wednesday': 1.2,
            'Thursday': 1.1,
            'Friday': 1.3,
            'Saturday': 1.4,
            'Sunday': 0.8,
          },
          dailyPatterns: {'0-6': 0.3, '6-12': 1.2, '12-18': 1.5, '18-24': 0.8},
          peakSeasons: ['Summer', 'Winter Holiday'],
          lowSeasons: ['Early Spring', 'Late Fall'],
        ),
        forecast: ForecastData(
          nextMonthForecast: 130000.0,
          nextQuarterForecast: 400000.0,
          confidenceLevel: 85.0,
          monthlyForecasts: [
            MonthlyForecast(
              month: DateTime.now().add(Duration(days: 30)),
              forecastRevenue: 130000.0,
              confidenceLevel: 85.0,
            ),
            MonthlyForecast(
              month: DateTime.now().add(Duration(days: 60)),
              forecastRevenue: 135000.0,
              confidenceLevel: 82.0,
            ),
            MonthlyForecast(
              month: DateTime.now().add(Duration(days: 90)),
              forecastRevenue: 140000.0,
              confidenceLevel: 78.0,
            ),
          ],
        ),
      ),
      paymentMethods: const PaymentMethodAnalytics(
        revenueByPaymentMethod: {
          'Credit Card': 75000.0,
          'Cash': 37500.0,
          'Bank Transfer': 12500.0,
        },
        transactionsByPaymentMethod: {
          'Credit Card': 500,
          'Cash': 375,
          'Bank Transfer': 62,
        },
        averageValueByPaymentMethod: {
          'Credit Card': 150.0,
          'Cash': 100.0,
          'Bank Transfer': 200.0,
        },
        successRateByPaymentMethod: {
          'Credit Card': 98.0,
          'Cash': 100.0,
          'Bank Transfer': 95.0,
        },
      ),
    );
  }
}
