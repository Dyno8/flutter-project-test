import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/payment_request.dart';

/// Data model for PaymentRequest with Firestore serialization
class PaymentRequestModel extends PaymentRequest {
  const PaymentRequestModel({
    required super.bookingId,
    required super.amount,
    required super.currency,
    required super.paymentMethod,
    super.description,
    super.metadata,
  });

  /// Create PaymentRequestModel from domain entity
  factory PaymentRequestModel.fromEntity(PaymentRequest entity) {
    return PaymentRequestModel(
      bookingId: entity.bookingId,
      amount: entity.amount,
      currency: entity.currency,
      paymentMethod: entity.paymentMethod,
      description: entity.description,
      metadata: entity.metadata,
    );
  }

  /// Create PaymentRequestModel from Firestore document
  factory PaymentRequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PaymentRequestModel(
      bookingId: data['bookingId'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      currency: data['currency'] ?? 'VND',
      paymentMethod: PaymentMethodModel.fromMap(data['paymentMethod'] ?? {}),
      description: data['description'],
      metadata: data['metadata'] != null 
          ? Map<String, dynamic>.from(data['metadata'])
          : null,
    );
  }

  /// Create PaymentRequestModel from Map
  factory PaymentRequestModel.fromMap(Map<String, dynamic> map) {
    return PaymentRequestModel(
      bookingId: map['bookingId'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      currency: map['currency'] ?? 'VND',
      paymentMethod: PaymentMethodModel.fromMap(map['paymentMethod'] ?? {}),
      description: map['description'],
      metadata: map['metadata'] != null 
          ? Map<String, dynamic>.from(map['metadata'])
          : null,
    );
  }

  /// Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
      'amount': amount,
      'currency': currency,
      'paymentMethod': PaymentMethodModel.fromEntity(paymentMethod).toMap(),
      'description': description,
      'metadata': metadata,
    };
  }

  /// Convert to domain entity
  PaymentRequest toEntity() {
    return PaymentRequest(
      bookingId: bookingId,
      amount: amount,
      currency: currency,
      paymentMethod: paymentMethod,
      description: description,
      metadata: metadata,
    );
  }

  @override
  String toString() {
    return 'PaymentRequestModel(bookingId: $bookingId, amount: $amount, '
        'currency: $currency, paymentMethod: $paymentMethod)';
  }
}

/// Data model for PaymentMethod with Firestore serialization
class PaymentMethodModel extends PaymentMethod {
  const PaymentMethodModel({
    required super.id,
    required super.type,
    required super.name,
    required super.displayName,
    super.iconUrl,
    super.isEnabled = true,
    super.configuration,
  });

  /// Create PaymentMethodModel from domain entity
  factory PaymentMethodModel.fromEntity(PaymentMethod entity) {
    return PaymentMethodModel(
      id: entity.id,
      type: entity.type,
      name: entity.name,
      displayName: entity.displayName,
      iconUrl: entity.iconUrl,
      isEnabled: entity.isEnabled,
      configuration: entity.configuration,
    );
  }

  /// Create PaymentMethodModel from Map
  factory PaymentMethodModel.fromMap(Map<String, dynamic> map) {
    return PaymentMethodModel(
      id: map['id'] ?? '',
      type: PaymentMethodType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => PaymentMethodType.mock,
      ),
      name: map['name'] ?? '',
      displayName: map['displayName'] ?? '',
      iconUrl: map['iconUrl'],
      isEnabled: map['isEnabled'] ?? true,
      configuration: map['configuration'] != null 
          ? Map<String, dynamic>.from(map['configuration'])
          : null,
    );
  }

  /// Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'name': name,
      'displayName': displayName,
      'iconUrl': iconUrl,
      'isEnabled': isEnabled,
      'configuration': configuration,
    };
  }

  /// Convert to domain entity
  PaymentMethod toEntity() {
    return PaymentMethod(
      id: id,
      type: type,
      name: name,
      displayName: displayName,
      iconUrl: iconUrl,
      isEnabled: isEnabled,
      configuration: configuration,
    );
  }

  @override
  String toString() {
    return 'PaymentMethodModel(id: $id, type: $type, name: $name, displayName: $displayName)';
  }
}
