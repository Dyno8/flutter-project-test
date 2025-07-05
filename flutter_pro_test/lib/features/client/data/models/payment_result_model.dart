import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/payment_result.dart';

/// Data model for PaymentResult with Firestore serialization
class PaymentResultModel extends PaymentResult {
  PaymentResultModel({
    required super.success,
    super.transactionId,
    super.amount,
    super.currency,
    super.status = PaymentResultStatus.pending,
    super.errorMessage,
    super.errorCode,
    super.metadata,
    super.timestamp,
  });

  /// Create PaymentResultModel from domain entity
  factory PaymentResultModel.fromEntity(PaymentResult entity) {
    return PaymentResultModel(
      success: entity.success,
      transactionId: entity.transactionId,
      amount: entity.amount,
      currency: entity.currency,
      status: entity.status,
      errorMessage: entity.errorMessage,
      errorCode: entity.errorCode,
      metadata: entity.metadata,
      timestamp: entity.timestamp,
    );
  }

  /// Create PaymentResultModel from Firestore document
  factory PaymentResultModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PaymentResultModel(
      success: data['success'] ?? false,
      transactionId: data['transactionId'],
      amount: data['amount']?.toDouble(),
      currency: data['currency'],
      status: PaymentResultStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => PaymentResultStatus.pending,
      ),
      errorMessage: data['errorMessage'],
      errorCode: data['errorCode'],
      metadata: data['metadata'] != null
          ? Map<String, dynamic>.from(data['metadata'])
          : null,
      timestamp: data['timestamp'] != null
          ? (data['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  /// Create PaymentResultModel from Map
  factory PaymentResultModel.fromMap(Map<String, dynamic> map) {
    return PaymentResultModel(
      success: map['success'] ?? false,
      transactionId: map['transactionId'],
      amount: map['amount']?.toDouble(),
      currency: map['currency'],
      status: PaymentResultStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => PaymentResultStatus.pending,
      ),
      errorMessage: map['errorMessage'],
      errorCode: map['errorCode'],
      metadata: map['metadata'] != null
          ? Map<String, dynamic>.from(map['metadata'])
          : null,
      timestamp: map['timestamp'] is Timestamp
          ? (map['timestamp'] as Timestamp).toDate()
          : (map['timestamp'] != null
                ? DateTime.parse(map['timestamp'])
                : DateTime.now()),
    );
  }

  /// Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'success': success,
      'transactionId': transactionId,
      'amount': amount,
      'currency': currency,
      'status': status.name,
      'errorMessage': errorMessage,
      'errorCode': errorCode,
      'metadata': metadata,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  /// Convert to domain entity
  PaymentResult toEntity() {
    return PaymentResult(
      success: success,
      transactionId: transactionId,
      amount: amount,
      currency: currency,
      status: status,
      errorMessage: errorMessage,
      errorCode: errorCode,
      metadata: metadata,
      timestamp: timestamp,
    );
  }

  /// Create successful payment result
  factory PaymentResultModel.success({
    required String transactionId,
    required double amount,
    String currency = 'VND',
    Map<String, dynamic>? metadata,
  }) {
    return PaymentResultModel(
      success: true,
      transactionId: transactionId,
      amount: amount,
      currency: currency,
      status: PaymentResultStatus.completed,
      metadata: metadata,
      timestamp: DateTime.now(),
    );
  }

  /// Create failed payment result
  factory PaymentResultModel.failure({
    required String errorMessage,
    String? errorCode,
    Map<String, dynamic>? metadata,
  }) {
    return PaymentResultModel(
      success: false,
      status: PaymentResultStatus.failed,
      errorMessage: errorMessage,
      errorCode: errorCode,
      metadata: metadata,
      timestamp: DateTime.now(),
    );
  }

  /// Create cancelled payment result
  factory PaymentResultModel.cancelled({
    String? errorMessage,
    Map<String, dynamic>? metadata,
  }) {
    return PaymentResultModel(
      success: false,
      status: PaymentResultStatus.cancelled,
      errorMessage: errorMessage ?? 'Payment was cancelled by user',
      metadata: metadata,
      timestamp: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'PaymentResultModel(success: $success, transactionId: $transactionId, '
        'amount: $amount, status: $status, errorMessage: $errorMessage)';
  }
}
