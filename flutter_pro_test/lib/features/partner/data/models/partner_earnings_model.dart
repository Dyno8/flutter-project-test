import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/partner_earnings.dart';

/// Data model for PartnerEarnings entity
class PartnerEarningsModel extends Equatable {
  final String id;
  final String partnerId;
  final double totalEarnings;
  final double todayEarnings;
  final double weekEarnings;
  final double monthEarnings;
  final int totalJobs;
  final int todayJobs;
  final int weekJobs;
  final int monthJobs;
  final double averageRating;
  final int totalReviews;
  final double platformFeeRate;
  final DateTime lastUpdated;
  final List<Map<String, dynamic>> dailyBreakdown;
  final double averageEarningsPerJob;
  final double weeklyGrowth;

  const PartnerEarningsModel({
    required this.id,
    required this.partnerId,
    required this.totalEarnings,
    required this.todayEarnings,
    required this.weekEarnings,
    required this.monthEarnings,
    required this.totalJobs,
    required this.todayJobs,
    required this.weekJobs,
    required this.monthJobs,
    required this.averageRating,
    required this.totalReviews,
    required this.platformFeeRate,
    required this.lastUpdated,
    this.dailyBreakdown = const [],
    required this.averageEarningsPerJob,
    required this.weeklyGrowth,
  });

  /// Factory constructor from Firestore document
  factory PartnerEarningsModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PartnerEarningsModel(
      id: doc.id,
      partnerId: data['partnerId'] ?? '',
      totalEarnings: (data['totalEarnings'] ?? 0.0).toDouble(),
      todayEarnings: (data['todayEarnings'] ?? 0.0).toDouble(),
      weekEarnings: (data['weekEarnings'] ?? 0.0).toDouble(),
      monthEarnings: (data['monthEarnings'] ?? 0.0).toDouble(),
      totalJobs: data['totalJobs'] ?? 0,
      todayJobs: data['todayJobs'] ?? 0,
      weekJobs: data['weekJobs'] ?? 0,
      monthJobs: data['monthJobs'] ?? 0,
      averageRating: (data['averageRating'] ?? 0.0).toDouble(),
      totalReviews: data['totalReviews'] ?? 0,
      platformFeeRate: (data['platformFeeRate'] ?? 0.15).toDouble(),
      lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
      dailyBreakdown: List<Map<String, dynamic>>.from(
        data['dailyBreakdown'] ?? [],
      ),
      averageEarningsPerJob: (data['averageEarningsPerJob'] ?? 0.0).toDouble(),
      weeklyGrowth: (data['weeklyGrowth'] ?? 0.0).toDouble(),
    );
  }

  /// Factory constructor from Map
  factory PartnerEarningsModel.fromMap(Map<String, dynamic> map) {
    return PartnerEarningsModel(
      id: map['id'] ?? '',
      partnerId: map['partnerId'] ?? '',
      totalEarnings: (map['totalEarnings'] ?? 0.0).toDouble(),
      todayEarnings: (map['todayEarnings'] ?? 0.0).toDouble(),
      weekEarnings: (map['weekEarnings'] ?? 0.0).toDouble(),
      monthEarnings: (map['monthEarnings'] ?? 0.0).toDouble(),
      totalJobs: map['totalJobs'] ?? 0,
      todayJobs: map['todayJobs'] ?? 0,
      weekJobs: map['weekJobs'] ?? 0,
      monthJobs: map['monthJobs'] ?? 0,
      averageRating: (map['averageRating'] ?? 0.0).toDouble(),
      totalReviews: map['totalReviews'] ?? 0,
      platformFeeRate: (map['platformFeeRate'] ?? 0.15).toDouble(),
      lastUpdated: map['lastUpdated'] is Timestamp
          ? (map['lastUpdated'] as Timestamp).toDate()
          : DateTime.parse(map['lastUpdated']),
      dailyBreakdown: List<Map<String, dynamic>>.from(
        map['dailyBreakdown'] ?? [],
      ),
      averageEarningsPerJob: (map['averageEarningsPerJob'] ?? 0.0).toDouble(),
      weeklyGrowth: (map['weeklyGrowth'] ?? 0.0).toDouble(),
    );
  }

  /// Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'partnerId': partnerId,
      'totalEarnings': totalEarnings,
      'todayEarnings': todayEarnings,
      'weekEarnings': weekEarnings,
      'monthEarnings': monthEarnings,
      'totalJobs': totalJobs,
      'todayJobs': todayJobs,
      'weekJobs': weekJobs,
      'monthJobs': monthJobs,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'platformFeeRate': platformFeeRate,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'dailyBreakdown': dailyBreakdown,
    };
  }

  /// Convert to domain entity
  PartnerEarnings toEntity() {
    final dailyEarnings = dailyBreakdown.map((item) {
      return DailyEarning(
        date: item['date'] is Timestamp
            ? (item['date'] as Timestamp).toDate()
            : DateTime.parse(item['date']),
        earnings: (item['earnings'] ?? 0.0).toDouble(),
        jobsCompleted: item['jobsCompleted'] ?? 0,
        hoursWorked: (item['hoursWorked'] ?? 0.0).toDouble(),
      );
    }).toList();

    return PartnerEarnings(
      id: id,
      partnerId: partnerId,
      totalEarnings: totalEarnings,
      todayEarnings: todayEarnings,
      weekEarnings: weekEarnings,
      monthEarnings: monthEarnings,
      totalJobs: totalJobs,
      todayJobs: todayJobs,
      weekJobs: weekJobs,
      monthJobs: monthJobs,
      averageRating: averageRating,
      totalReviews: totalReviews,
      platformFeeRate: platformFeeRate,
      lastUpdated: lastUpdated,
      dailyBreakdown: dailyEarnings,
    );
  }

  /// Create from domain entity
  factory PartnerEarningsModel.fromEntity(PartnerEarnings earnings) {
    final dailyBreakdown = earnings.dailyBreakdown.map((daily) {
      return {
        'date': Timestamp.fromDate(daily.date),
        'earnings': daily.earnings,
        'jobsCompleted': daily.jobsCompleted,
        'hoursWorked': daily.hoursWorked,
      };
    }).toList();

    return PartnerEarningsModel(
      id: earnings.id,
      partnerId: earnings.partnerId,
      totalEarnings: earnings.totalEarnings,
      todayEarnings: earnings.todayEarnings,
      weekEarnings: earnings.weekEarnings,
      monthEarnings: earnings.monthEarnings,
      totalJobs: earnings.totalJobs,
      todayJobs: earnings.todayJobs,
      weekJobs: earnings.weekJobs,
      monthJobs: earnings.monthJobs,
      averageRating: earnings.averageRating,
      totalReviews: earnings.totalReviews,
      platformFeeRate: earnings.platformFeeRate,
      lastUpdated: earnings.lastUpdated,
      dailyBreakdown: dailyBreakdown,
      averageEarningsPerJob: earnings.totalJobs > 0
          ? earnings.totalEarnings / earnings.totalJobs
          : 0.0,
      weeklyGrowth: 0.0, // Calculate based on previous week data if available
    );
  }

  @override
  List<Object?> get props => [
    id,
    partnerId,
    totalEarnings,
    todayEarnings,
    weekEarnings,
    monthEarnings,
    totalJobs,
    todayJobs,
    weekJobs,
    monthJobs,
    averageRating,
    totalReviews,
    platformFeeRate,
    lastUpdated,
    dailyBreakdown,
    averageEarningsPerJob,
    weeklyGrowth,
  ];
}

/// Data model for PartnerAvailability entity
class PartnerAvailabilityModel extends Equatable {
  final String partnerId;
  final bool isAvailable;
  final bool isOnline;
  final DateTime? lastSeen;
  final String? unavailabilityReason;
  final DateTime? unavailableUntil;
  final Map<String, List<String>> workingHours;
  final List<String> blockedDates;
  final DateTime lastUpdated;

  const PartnerAvailabilityModel({
    required this.partnerId,
    required this.isAvailable,
    required this.isOnline,
    this.lastSeen,
    this.unavailabilityReason,
    this.unavailableUntil,
    required this.workingHours,
    this.blockedDates = const [],
    required this.lastUpdated,
  });

  /// Factory constructor from Firestore document
  factory PartnerAvailabilityModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PartnerAvailabilityModel(
      partnerId: doc.id,
      isAvailable: data['isAvailable'] ?? true,
      isOnline: data['isOnline'] ?? false,
      lastSeen: data['lastSeen'] != null
          ? (data['lastSeen'] as Timestamp).toDate()
          : null,
      unavailabilityReason: data['unavailabilityReason'],
      unavailableUntil: data['unavailableUntil'] != null
          ? (data['unavailableUntil'] as Timestamp).toDate()
          : null,
      workingHours: Map<String, List<String>>.from(data['workingHours'] ?? {}),
      blockedDates: List<String>.from(data['blockedDates'] ?? []),
      lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
    );
  }

  /// Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'partnerId': partnerId,
      'isAvailable': isAvailable,
      'isOnline': isOnline,
      'lastSeen': lastSeen != null ? Timestamp.fromDate(lastSeen!) : null,
      'unavailabilityReason': unavailabilityReason,
      'unavailableUntil': unavailableUntil != null
          ? Timestamp.fromDate(unavailableUntil!)
          : null,
      'workingHours': workingHours,
      'blockedDates': blockedDates,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  /// Convert to domain entity
  PartnerAvailability toEntity() {
    return PartnerAvailability(
      partnerId: partnerId,
      isAvailable: isAvailable,
      isOnline: isOnline,
      lastSeen: lastSeen,
      unavailabilityReason: unavailabilityReason,
      unavailableUntil: unavailableUntil,
      workingHours: workingHours,
      blockedDates: blockedDates,
      lastUpdated: lastUpdated,
    );
  }

  /// Create from domain entity
  factory PartnerAvailabilityModel.fromEntity(
    PartnerAvailability availability,
  ) {
    return PartnerAvailabilityModel(
      partnerId: availability.partnerId,
      isAvailable: availability.isAvailable,
      isOnline: availability.isOnline,
      lastSeen: availability.lastSeen,
      unavailabilityReason: availability.unavailabilityReason,
      unavailableUntil: availability.unavailableUntil,
      workingHours: availability.workingHours,
      blockedDates: availability.blockedDates,
      lastUpdated: availability.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [
    partnerId,
    isAvailable,
    isOnline,
    lastSeen,
    unavailabilityReason,
    unavailableUntil,
    workingHours,
    blockedDates,
    lastUpdated,
  ];
}
