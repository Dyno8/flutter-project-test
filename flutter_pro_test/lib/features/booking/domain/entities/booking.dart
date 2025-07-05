import 'package:equatable/equatable.dart';

/// Domain entity for booking
class Booking extends Equatable {
  final String id;
  final String userId;
  final String partnerId;
  final String serviceId;
  final String serviceName;
  final DateTime scheduledDate;
  final String timeSlot;
  final double hours;
  final double totalPrice;
  final BookingStatus status;
  final PaymentStatus paymentStatus;
  final String? paymentMethod;
  final String? paymentTransactionId;
  final String clientAddress;
  final double clientLatitude;
  final double clientLongitude;
  final String? specialInstructions;
  final String? cancellationReason;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Booking({
    required this.id,
    required this.userId,
    required this.partnerId,
    required this.serviceId,
    required this.serviceName,
    required this.scheduledDate,
    required this.timeSlot,
    required this.hours,
    required this.totalPrice,
    required this.status,
    required this.paymentStatus,
    this.paymentMethod,
    this.paymentTransactionId,
    required this.clientAddress,
    required this.clientLatitude,
    required this.clientLongitude,
    this.specialInstructions,
    this.cancellationReason,
    this.completedAt,
    this.cancelledAt,
    required this.createdAt,
    this.updatedAt,
  });

  // Helper methods
  bool get isPending => status == BookingStatus.pending;
  bool get isConfirmed => status == BookingStatus.confirmed;
  bool get isInProgress => status == BookingStatus.inProgress;
  bool get isCompleted => status == BookingStatus.completed;
  bool get isCancelled => status == BookingStatus.cancelled;
  bool get isRejected => status == BookingStatus.rejected;

  bool get isPaid => paymentStatus == PaymentStatus.paid;
  bool get isUnpaid => paymentStatus == PaymentStatus.unpaid;

  String get formattedPrice => '${totalPrice.toStringAsFixed(0)}k VND';
  String get formattedDate =>
      '${scheduledDate.day}/${scheduledDate.month}/${scheduledDate.year}';
  String get formattedDateTime => '$formattedDate - $timeSlot';

  // Check if booking can be cancelled
  bool get canBeCancelled {
    if (isCancelled || isCompleted) return false;
    final now = DateTime.now();
    final bookingDateTime = DateTime(
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      int.parse(timeSlot.split(':')[0]),
      int.parse(timeSlot.split(':')[1]),
    );
    // Can cancel if booking is more than 2 hours away
    return bookingDateTime.difference(now).inHours > 2;
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    partnerId,
    serviceId,
    serviceName,
    scheduledDate,
    timeSlot,
    hours,
    totalPrice,
    status,
    paymentStatus,
    paymentMethod,
    paymentTransactionId,
    clientAddress,
    clientLatitude,
    clientLongitude,
    specialInstructions,
    cancellationReason,
    completedAt,
    cancelledAt,
    createdAt,
    updatedAt,
  ];
}

/// Enum for booking status
enum BookingStatus {
  pending,
  confirmed,
  inProgress,
  completed,
  cancelled,
  rejected;

  String get displayName {
    switch (this) {
      case BookingStatus.pending:
        return 'Chờ xác nhận';
      case BookingStatus.confirmed:
        return 'Đã xác nhận';
      case BookingStatus.inProgress:
        return 'Đang thực hiện';
      case BookingStatus.completed:
        return 'Hoàn thành';
      case BookingStatus.cancelled:
        return 'Đã hủy';
      case BookingStatus.rejected:
        return 'Bị từ chối';
    }
  }

  static BookingStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return BookingStatus.pending;
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'in-progress':
      case 'inprogress':
        return BookingStatus.inProgress;
      case 'completed':
        return BookingStatus.completed;
      case 'cancelled':
        return BookingStatus.cancelled;
      case 'rejected':
        return BookingStatus.rejected;
      default:
        return BookingStatus.pending;
    }
  }
}

/// Enum for payment status
enum PaymentStatus {
  unpaid,
  paid,
  refunded,
  failed;

  String get displayName {
    switch (this) {
      case PaymentStatus.unpaid:
        return 'Chưa thanh toán';
      case PaymentStatus.paid:
        return 'Đã thanh toán';
      case PaymentStatus.refunded:
        return 'Đã hoàn tiền';
      case PaymentStatus.failed:
        return 'Thanh toán thất bại';
    }
  }

  static PaymentStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return PaymentStatus.paid;
      case 'refunded':
        return PaymentStatus.refunded;
      case 'failed':
        return PaymentStatus.failed;
      default:
        return PaymentStatus.unpaid;
    }
  }
}
