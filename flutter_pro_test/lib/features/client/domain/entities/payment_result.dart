import 'package:equatable/equatable.dart';

/// Domain entity representing the result of a payment operation
class PaymentResult extends Equatable {
  final bool success;
  final String? transactionId;
  final double? amount;
  final String? currency;
  final PaymentResultStatus status;
  final String? errorMessage;
  final String? errorCode;
  final Map<String, dynamic>? metadata;
  final DateTime timestamp;

  PaymentResult({
    required this.success,
    this.transactionId,
    this.amount,
    this.currency,
    this.status = PaymentResultStatus.pending,
    this.errorMessage,
    this.errorCode,
    this.metadata,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Create a successful payment result
  factory PaymentResult.success({
    required String transactionId,
    required double amount,
    String currency = 'VND',
    Map<String, dynamic>? metadata,
  }) {
    return PaymentResult(
      success: true,
      transactionId: transactionId,
      amount: amount,
      currency: currency,
      status: PaymentResultStatus.completed,
      metadata: metadata,
      timestamp: DateTime.now(),
    );
  }

  /// Create a failed payment result
  factory PaymentResult.failure({
    required String errorMessage,
    String? errorCode,
    Map<String, dynamic>? metadata,
  }) {
    return PaymentResult(
      success: false,
      status: PaymentResultStatus.failed,
      errorMessage: errorMessage,
      errorCode: errorCode,
      metadata: metadata,
      timestamp: DateTime.now(),
    );
  }

  /// Create a cancelled payment result
  factory PaymentResult.cancelled({
    String? errorMessage,
    Map<String, dynamic>? metadata,
  }) {
    return PaymentResult(
      success: false,
      status: PaymentResultStatus.cancelled,
      errorMessage: errorMessage ?? 'Payment was cancelled by user',
      metadata: metadata,
      timestamp: DateTime.now(),
    );
  }

  /// Create a pending payment result
  factory PaymentResult.pending({
    String? transactionId,
    Map<String, dynamic>? metadata,
  }) {
    return PaymentResult(
      success: false,
      transactionId: transactionId,
      status: PaymentResultStatus.pending,
      metadata: metadata,
      timestamp: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    success,
    transactionId,
    amount,
    currency,
    status,
    errorMessage,
    errorCode,
    metadata,
    timestamp,
  ];

  PaymentResult copyWith({
    bool? success,
    String? transactionId,
    double? amount,
    String? currency,
    PaymentResultStatus? status,
    String? errorMessage,
    String? errorCode,
    Map<String, dynamic>? metadata,
    DateTime? timestamp,
  }) {
    return PaymentResult(
      success: success ?? this.success,
      transactionId: transactionId ?? this.transactionId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      errorCode: errorCode ?? this.errorCode,
      metadata: metadata ?? this.metadata,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() {
    return 'PaymentResult(success: $success, transactionId: $transactionId, '
        'amount: $amount, status: $status, errorMessage: $errorMessage)';
  }
}

/// Enum for payment result status
enum PaymentResultStatus {
  pending,
  processing,
  completed,
  failed,
  cancelled,
  refunded;

  String get displayName {
    switch (this) {
      case PaymentResultStatus.pending:
        return 'Đang chờ xử lý';
      case PaymentResultStatus.processing:
        return 'Đang xử lý';
      case PaymentResultStatus.completed:
        return 'Thành công';
      case PaymentResultStatus.failed:
        return 'Thất bại';
      case PaymentResultStatus.cancelled:
        return 'Đã hủy';
      case PaymentResultStatus.refunded:
        return 'Đã hoàn tiền';
    }
  }

  bool get isSuccess => this == PaymentResultStatus.completed;
  bool get isFailed => this == PaymentResultStatus.failed;
  bool get isCancelled => this == PaymentResultStatus.cancelled;
  bool get isPending => this == PaymentResultStatus.pending;
  bool get isProcessing => this == PaymentResultStatus.processing;
}
