import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/system_metrics.dart';

/// Data model for SystemMetrics with Firestore serialization
class SystemMetricsModel extends SystemMetrics {
  const SystemMetricsModel({
    required super.totalUsers,
    required super.totalPartners,
    required super.totalBookings,
    required super.activeBookings,
    required super.completedBookings,
    required super.cancelledBookings,
    required super.totalRevenue,
    required super.monthlyRevenue,
    required super.dailyRevenue,
    required super.averageRating,
    required super.totalReviews,
    required super.timestamp,
    required super.performance,
  });

  /// Create SystemMetricsModel from domain entity
  factory SystemMetricsModel.fromEntity(SystemMetrics metrics) {
    return SystemMetricsModel(
      totalUsers: metrics.totalUsers,
      totalPartners: metrics.totalPartners,
      totalBookings: metrics.totalBookings,
      activeBookings: metrics.activeBookings,
      completedBookings: metrics.completedBookings,
      cancelledBookings: metrics.cancelledBookings,
      totalRevenue: metrics.totalRevenue,
      monthlyRevenue: metrics.monthlyRevenue,
      dailyRevenue: metrics.dailyRevenue,
      averageRating: metrics.averageRating,
      totalReviews: metrics.totalReviews,
      timestamp: metrics.timestamp,
      performance: metrics.performance,
    );
  }

  /// Create SystemMetricsModel from Firestore document
  factory SystemMetricsModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return SystemMetricsModel(
      totalUsers: data['totalUsers'] ?? 0,
      totalPartners: data['totalPartners'] ?? 0,
      totalBookings: data['totalBookings'] ?? 0,
      activeBookings: data['activeBookings'] ?? 0,
      completedBookings: data['completedBookings'] ?? 0,
      cancelledBookings: data['cancelledBookings'] ?? 0,
      totalRevenue: (data['totalRevenue'] ?? 0).toDouble(),
      monthlyRevenue: (data['monthlyRevenue'] ?? 0).toDouble(),
      dailyRevenue: (data['dailyRevenue'] ?? 0).toDouble(),
      averageRating: (data['averageRating'] ?? 0).toDouble(),
      totalReviews: data['totalReviews'] ?? 0,
      timestamp: data['timestamp'] != null
          ? (data['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
      performance: SystemPerformanceModel.fromMap(data['performance'] ?? {}),
    );
  }

  /// Create SystemMetricsModel from JSON map
  factory SystemMetricsModel.fromJson(Map<String, dynamic> json) {
    return SystemMetricsModel(
      totalUsers: json['totalUsers'] ?? 0,
      totalPartners: json['totalPartners'] ?? 0,
      totalBookings: json['totalBookings'] ?? 0,
      activeBookings: json['activeBookings'] ?? 0,
      completedBookings: json['completedBookings'] ?? 0,
      cancelledBookings: json['cancelledBookings'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      monthlyRevenue: (json['monthlyRevenue'] ?? 0).toDouble(),
      dailyRevenue: (json['dailyRevenue'] ?? 0).toDouble(),
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      totalReviews: json['totalReviews'] ?? 0,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      performance: SystemPerformanceModel.fromMap(json['performance'] ?? {}),
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'totalUsers': totalUsers,
      'totalPartners': totalPartners,
      'totalBookings': totalBookings,
      'activeBookings': activeBookings,
      'completedBookings': completedBookings,
      'cancelledBookings': cancelledBookings,
      'totalRevenue': totalRevenue,
      'monthlyRevenue': monthlyRevenue,
      'dailyRevenue': dailyRevenue,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'timestamp': Timestamp.fromDate(timestamp),
      'performance': SystemPerformanceModel.fromEntity(performance).toMap(),
    };
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'totalUsers': totalUsers,
      'totalPartners': totalPartners,
      'totalBookings': totalBookings,
      'activeBookings': activeBookings,
      'completedBookings': completedBookings,
      'cancelledBookings': cancelledBookings,
      'totalRevenue': totalRevenue,
      'monthlyRevenue': monthlyRevenue,
      'dailyRevenue': dailyRevenue,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'timestamp': timestamp.toIso8601String(),
      'performance': SystemPerformanceModel.fromEntity(performance).toMap(),
    };
  }

  /// Convert to domain entity
  SystemMetrics toEntity() {
    return SystemMetrics(
      totalUsers: totalUsers,
      totalPartners: totalPartners,
      totalBookings: totalBookings,
      activeBookings: activeBookings,
      completedBookings: completedBookings,
      cancelledBookings: cancelledBookings,
      totalRevenue: totalRevenue,
      monthlyRevenue: monthlyRevenue,
      dailyRevenue: dailyRevenue,
      averageRating: averageRating,
      totalReviews: totalReviews,
      timestamp: timestamp,
      performance: performance,
    );
  }
}

/// Data model for SystemPerformance
class SystemPerformanceModel extends SystemPerformance {
  const SystemPerformanceModel({
    required super.apiResponseTime,
    required super.errorRate,
    required super.activeConnections,
    required super.memoryUsage,
    required super.cpuUsage,
    required super.diskUsage,
    required super.requestsPerMinute,
    required super.lastUpdated,
  });

  /// Create SystemPerformanceModel from domain entity
  factory SystemPerformanceModel.fromEntity(SystemPerformance performance) {
    return SystemPerformanceModel(
      apiResponseTime: performance.apiResponseTime,
      errorRate: performance.errorRate,
      activeConnections: performance.activeConnections,
      memoryUsage: performance.memoryUsage,
      cpuUsage: performance.cpuUsage,
      diskUsage: performance.diskUsage,
      requestsPerMinute: performance.requestsPerMinute,
      lastUpdated: performance.lastUpdated,
    );
  }

  /// Create SystemPerformanceModel from map
  factory SystemPerformanceModel.fromMap(Map<String, dynamic> map) {
    return SystemPerformanceModel(
      apiResponseTime: (map['apiResponseTime'] ?? 0).toDouble(),
      errorRate: (map['errorRate'] ?? 0).toDouble(),
      activeConnections: map['activeConnections'] ?? 0,
      memoryUsage: (map['memoryUsage'] ?? 0).toDouble(),
      cpuUsage: (map['cpuUsage'] ?? 0).toDouble(),
      diskUsage: (map['diskUsage'] ?? 0).toDouble(),
      requestsPerMinute: map['requestsPerMinute'] ?? 0,
      lastUpdated: map['lastUpdated'] != null
          ? (map['lastUpdated'] is Timestamp
              ? (map['lastUpdated'] as Timestamp).toDate()
              : DateTime.parse(map['lastUpdated']))
          : DateTime.now(),
    );
  }

  /// Convert to map
  Map<String, dynamic> toMap() {
    return {
      'apiResponseTime': apiResponseTime,
      'errorRate': errorRate,
      'activeConnections': activeConnections,
      'memoryUsage': memoryUsage,
      'cpuUsage': cpuUsage,
      'diskUsage': diskUsage,
      'requestsPerMinute': requestsPerMinute,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  /// Convert to domain entity
  SystemPerformance toEntity() {
    return SystemPerformance(
      apiResponseTime: apiResponseTime,
      errorRate: errorRate,
      activeConnections: activeConnections,
      memoryUsage: memoryUsage,
      cpuUsage: cpuUsage,
      diskUsage: diskUsage,
      requestsPerMinute: requestsPerMinute,
      lastUpdated: lastUpdated,
    );
  }
}
