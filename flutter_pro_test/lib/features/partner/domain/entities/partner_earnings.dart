import 'package:equatable/equatable.dart';

/// Domain entity representing partner earnings
class PartnerEarnings extends Equatable {
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
  final double platformFeeRate; // Percentage taken by platform
  final DateTime lastUpdated;
  final List<DailyEarning> dailyBreakdown;

  const PartnerEarnings({
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
  });

  // Helper methods
  String get formattedTotalEarnings =>
      '${totalEarnings.toStringAsFixed(0)}k VND';
  String get formattedTodayEarnings =>
      '${todayEarnings.toStringAsFixed(0)}k VND';
  String get formattedWeekEarnings => '${weekEarnings.toStringAsFixed(0)}k VND';
  String get formattedMonthEarnings =>
      '${monthEarnings.toStringAsFixed(0)}k VND';
  String get formattedRating => averageRating.toStringAsFixed(1);

  double get averageEarningsPerJob {
    if (totalJobs == 0) return 0;
    return totalEarnings / totalJobs;
  }

  String get formattedAveragePerJob =>
      '${averageEarningsPerJob.toStringAsFixed(0)}k VND';

  // Calculate earnings growth
  double get weeklyGrowth {
    if (dailyBreakdown.length < 14) return 0;

    final thisWeek = dailyBreakdown
        .take(7)
        .fold(0.0, (sum, day) => sum + day.earnings);
    final lastWeek = dailyBreakdown
        .skip(7)
        .take(7)
        .fold(0.0, (sum, day) => sum + day.earnings);

    if (lastWeek == 0) return 0;
    return ((thisWeek - lastWeek) / lastWeek) * 100;
  }

  String get formattedWeeklyGrowth {
    final growth = weeklyGrowth;
    final sign = growth >= 0 ? '+' : '';
    return '$sign${growth.toStringAsFixed(1)}%';
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
  ];
}

/// Daily earnings breakdown
class DailyEarning extends Equatable {
  final DateTime date;
  final double earnings;
  final int jobsCompleted;
  final double hoursWorked;

  const DailyEarning({
    required this.date,
    required this.earnings,
    required this.jobsCompleted,
    required this.hoursWorked,
  });

  String get formattedEarnings => '${earnings.toStringAsFixed(0)}k VND';
  String get formattedDate => '${date.day}/${date.month}';
  String get formattedHours => '${hoursWorked.toStringAsFixed(1)}h';

  @override
  List<Object?> get props => [date, earnings, jobsCompleted, hoursWorked];
}

/// Partner availability status
class PartnerAvailability extends Equatable {
  final String partnerId;
  final bool isAvailable;
  final bool isOnline;
  final DateTime? lastSeen;
  final String? unavailabilityReason;
  final DateTime? unavailableUntil;
  final Map<String, List<String>> workingHours;
  final List<String> blockedDates; // ISO date strings
  final DateTime lastUpdated;

  const PartnerAvailability({
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

  // Helper methods
  bool get isCurrentlyAvailable {
    if (!isAvailable) return false;
    if (unavailableUntil != null &&
        DateTime.now().isBefore(unavailableUntil!)) {
      return false;
    }
    return true;
  }

  String get availabilityStatus {
    if (!isAvailable) return 'Không khả dụng';
    if (!isOnline) return 'Ngoại tuyến';
    if (unavailableUntil != null &&
        DateTime.now().isBefore(unavailableUntil!)) {
      return 'Tạm nghỉ';
    }
    return 'Sẵn sàng';
  }

  String get lastSeenText {
    if (isOnline) return 'Đang online';
    if (lastSeen == null) return 'Chưa xác định';

    final now = DateTime.now();
    final difference = now.difference(lastSeen!);

    if (difference.inMinutes < 1) return 'Vừa xong';
    if (difference.inHours < 1) return '${difference.inMinutes} phút trước';
    if (difference.inDays < 1) return '${difference.inHours} giờ trước';
    return '${difference.inDays} ngày trước';
  }

  // Check if available on specific day and time
  bool isAvailableAt(DateTime dateTime) {
    if (!isCurrentlyAvailable) return false;

    final dateString =
        '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    if (blockedDates.contains(dateString)) return false;

    final dayOfWeek = _getDayOfWeek(dateTime.weekday);
    final daySchedule = workingHours[dayOfWeek];
    if (daySchedule == null || daySchedule.isEmpty) return false;

    final timeString =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    return daySchedule.any((slot) => slot.contains(timeString.split(':')[0]));
  }

  String _getDayOfWeek(int weekday) {
    switch (weekday) {
      case 1:
        return 'monday';
      case 2:
        return 'tuesday';
      case 3:
        return 'wednesday';
      case 4:
        return 'thursday';
      case 5:
        return 'friday';
      case 6:
        return 'saturday';
      case 7:
        return 'sunday';
      default:
        return 'monday';
    }
  }

  /// Copy with method for creating modified instances
  PartnerAvailability copyWith({
    String? partnerId,
    bool? isAvailable,
    bool? isOnline,
    DateTime? lastSeen,
    String? unavailabilityReason,
    DateTime? unavailableUntil,
    Map<String, List<String>>? workingHours,
    List<String>? blockedDates,
    DateTime? lastUpdated,
  }) {
    return PartnerAvailability(
      partnerId: partnerId ?? this.partnerId,
      isAvailable: isAvailable ?? this.isAvailable,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      unavailabilityReason: unavailabilityReason ?? this.unavailabilityReason,
      unavailableUntil: unavailableUntil ?? this.unavailableUntil,
      workingHours: workingHours ?? this.workingHours,
      blockedDates: blockedDates ?? this.blockedDates,
      lastUpdated: lastUpdated ?? this.lastUpdated,
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
