import 'package:equatable/equatable.dart';

/// Domain entity representing a job for partners (based on booking)
class Job extends Equatable {
  final String id; // Same as booking ID
  final String bookingId;
  final String partnerId;
  final String userId;
  final String clientName;
  final String clientPhone;
  final String serviceId;
  final String serviceName;
  final DateTime scheduledDate;
  final String timeSlot;
  final double hours;
  final double totalPrice;
  final double partnerEarnings; // Partner's share after platform fee
  final JobStatus status;
  final JobPriority priority;
  final String clientAddress;
  final double clientLatitude;
  final double clientLongitude;
  final String? specialInstructions;
  final String? rejectionReason;
  final DateTime? acceptedAt;
  final DateTime? rejectedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isUrgent;
  final double? distanceFromPartner;

  const Job({
    required this.id,
    required this.bookingId,
    required this.partnerId,
    required this.userId,
    required this.clientName,
    required this.clientPhone,
    required this.serviceId,
    required this.serviceName,
    required this.scheduledDate,
    required this.timeSlot,
    required this.hours,
    required this.totalPrice,
    required this.partnerEarnings,
    required this.status,
    required this.priority,
    required this.clientAddress,
    required this.clientLatitude,
    required this.clientLongitude,
    this.specialInstructions,
    this.rejectionReason,
    this.acceptedAt,
    this.rejectedAt,
    this.startedAt,
    this.completedAt,
    this.cancelledAt,
    required this.createdAt,
    this.updatedAt,
    this.isUrgent = false,
    this.distanceFromPartner,
  });

  // Helper methods
  bool get isPending => status == JobStatus.pending;
  bool get isAccepted => status == JobStatus.accepted;
  bool get isRejected => status == JobStatus.rejected;
  bool get isInProgress => status == JobStatus.inProgress;
  bool get isCompleted => status == JobStatus.completed;
  bool get isCancelled => status == JobStatus.cancelled;

  bool get canBeAccepted => status == JobStatus.pending;
  bool get canBeRejected => status == JobStatus.pending;
  bool get canBeStarted => status == JobStatus.accepted;
  bool get canBeCompleted => status == JobStatus.inProgress;

  String get formattedPrice => '${totalPrice.toStringAsFixed(0)}k VND';
  String get formattedEarnings => '${partnerEarnings.toStringAsFixed(0)}k VND';
  String get formattedDate =>
      '${scheduledDate.day}/${scheduledDate.month}/${scheduledDate.year}';
  String get formattedDateTime => '$formattedDate - $timeSlot';

  // Calculate time until job starts
  Duration get timeUntilStart {
    final now = DateTime.now();
    final jobDateTime = DateTime(
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      int.parse(timeSlot.split(':')[0]),
      int.parse(timeSlot.split(':')[1]),
    );
    return jobDateTime.difference(now);
  }

  // Check if job is starting soon (within 1 hour)
  bool get isStartingSoon {
    final timeUntil = timeUntilStart;
    return timeUntil.inHours <= 1 && timeUntil.inMinutes > 0;
  }

  // Check if job is overdue
  bool get isOverdue {
    return timeUntilStart.isNegative && !isCompleted && !isCancelled;
  }

  // Get formatted distance
  String get formattedDistance {
    if (distanceFromPartner == null) return 'N/A';
    if (distanceFromPartner! < 1) {
      return '${(distanceFromPartner! * 1000).toInt()}m';
    }
    return '${distanceFromPartner!.toStringAsFixed(1)}km';
  }

  /// Copy with method for creating modified instances
  Job copyWith({
    String? id,
    String? bookingId,
    String? partnerId,
    String? userId,
    String? clientName,
    String? clientPhone,
    String? serviceId,
    String? serviceName,
    DateTime? scheduledDate,
    String? timeSlot,
    double? hours,
    double? totalPrice,
    double? partnerEarnings,
    JobStatus? status,
    JobPriority? priority,
    String? clientAddress,
    double? clientLatitude,
    double? clientLongitude,
    String? specialInstructions,
    String? rejectionReason,
    DateTime? acceptedAt,
    DateTime? rejectedAt,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? cancelledAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isUrgent,
    double? distanceFromPartner,
  }) {
    return Job(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      partnerId: partnerId ?? this.partnerId,
      userId: userId ?? this.userId,
      clientName: clientName ?? this.clientName,
      clientPhone: clientPhone ?? this.clientPhone,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      timeSlot: timeSlot ?? this.timeSlot,
      hours: hours ?? this.hours,
      totalPrice: totalPrice ?? this.totalPrice,
      partnerEarnings: partnerEarnings ?? this.partnerEarnings,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      clientAddress: clientAddress ?? this.clientAddress,
      clientLatitude: clientLatitude ?? this.clientLatitude,
      clientLongitude: clientLongitude ?? this.clientLongitude,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      rejectedAt: rejectedAt ?? this.rejectedAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isUrgent: isUrgent ?? this.isUrgent,
      distanceFromPartner: distanceFromPartner ?? this.distanceFromPartner,
    );
  }

  @override
  List<Object?> get props => [
    id,
    bookingId,
    partnerId,
    userId,
    clientName,
    clientPhone,
    serviceId,
    serviceName,
    scheduledDate,
    timeSlot,
    hours,
    totalPrice,
    partnerEarnings,
    status,
    priority,
    clientAddress,
    clientLatitude,
    clientLongitude,
    specialInstructions,
    rejectionReason,
    acceptedAt,
    rejectedAt,
    startedAt,
    completedAt,
    cancelledAt,
    createdAt,
    updatedAt,
    isUrgent,
    distanceFromPartner,
  ];
}

/// Enum for job status from partner perspective
enum JobStatus {
  pending,
  accepted,
  rejected,
  inProgress,
  completed,
  cancelled;

  String get displayName {
    switch (this) {
      case JobStatus.pending:
        return 'Chờ xác nhận';
      case JobStatus.accepted:
        return 'Đã nhận';
      case JobStatus.rejected:
        return 'Đã từ chối';
      case JobStatus.inProgress:
        return 'Đang thực hiện';
      case JobStatus.completed:
        return 'Hoàn thành';
      case JobStatus.cancelled:
        return 'Đã hủy';
    }
  }

  String get actionText {
    switch (this) {
      case JobStatus.pending:
        return 'Chờ phản hồi';
      case JobStatus.accepted:
        return 'Bắt đầu';
      case JobStatus.rejected:
        return 'Đã từ chối';
      case JobStatus.inProgress:
        return 'Hoàn thành';
      case JobStatus.completed:
        return 'Đã xong';
      case JobStatus.cancelled:
        return 'Đã hủy';
    }
  }

  static JobStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
      case 'confirmed':
        return JobStatus.accepted;
      case 'rejected':
        return JobStatus.rejected;
      case 'inprogress':
      case 'in_progress':
        return JobStatus.inProgress;
      case 'completed':
        return JobStatus.completed;
      case 'cancelled':
        return JobStatus.cancelled;
      default:
        return JobStatus.pending;
    }
  }
}

/// Enum for job priority
enum JobPriority {
  low,
  normal,
  high,
  urgent;

  String get displayName {
    switch (this) {
      case JobPriority.low:
        return 'Thấp';
      case JobPriority.normal:
        return 'Bình thường';
      case JobPriority.high:
        return 'Cao';
      case JobPriority.urgent:
        return 'Khẩn cấp';
    }
  }

  static JobPriority fromString(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return JobPriority.high;
      case 'urgent':
        return JobPriority.urgent;
      case 'low':
        return JobPriority.low;
      default:
        return JobPriority.normal;
    }
  }
}
