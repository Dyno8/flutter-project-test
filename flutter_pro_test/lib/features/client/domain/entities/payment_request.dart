import 'package:equatable/equatable.dart';

/// Domain entity representing a payment request
class PaymentRequest extends Equatable {
  final String bookingId;
  final double amount;
  final String currency;
  final PaymentMethod paymentMethod;
  final String? description;
  final Map<String, dynamic>? metadata;

  const PaymentRequest({
    required this.bookingId,
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    this.description,
    this.metadata,
  });

  @override
  List<Object?> get props => [
        bookingId,
        amount,
        currency,
        paymentMethod,
        description,
        metadata,
      ];

  PaymentRequest copyWith({
    String? bookingId,
    double? amount,
    String? currency,
    PaymentMethod? paymentMethod,
    String? description,
    Map<String, dynamic>? metadata,
  }) {
    return PaymentRequest(
      bookingId: bookingId ?? this.bookingId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      description: description ?? this.description,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'PaymentRequest(bookingId: $bookingId, amount: $amount, '
        'currency: $currency, paymentMethod: $paymentMethod)';
  }
}

/// Domain entity representing a payment method
class PaymentMethod extends Equatable {
  final String id;
  final PaymentMethodType type;
  final String name;
  final String displayName;
  final String? iconUrl;
  final bool isEnabled;
  final Map<String, dynamic>? configuration;

  const PaymentMethod({
    required this.id,
    required this.type,
    required this.name,
    required this.displayName,
    this.iconUrl,
    this.isEnabled = true,
    this.configuration,
  });

  @override
  List<Object?> get props => [
        id,
        type,
        name,
        displayName,
        iconUrl,
        isEnabled,
        configuration,
      ];

  PaymentMethod copyWith({
    String? id,
    PaymentMethodType? type,
    String? name,
    String? displayName,
    String? iconUrl,
    bool? isEnabled,
    Map<String, dynamic>? configuration,
  }) {
    return PaymentMethod(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      iconUrl: iconUrl ?? this.iconUrl,
      isEnabled: isEnabled ?? this.isEnabled,
      configuration: configuration ?? this.configuration,
    );
  }

  @override
  String toString() {
    return 'PaymentMethod(id: $id, type: $type, name: $name, displayName: $displayName)';
  }
}

/// Enum for payment method types
enum PaymentMethodType {
  mock,
  stripe,
  momo,
  vnpay,
  cash;

  String get displayName {
    switch (this) {
      case PaymentMethodType.mock:
        return 'Mock Payment';
      case PaymentMethodType.stripe:
        return 'Thẻ tín dụng/ghi nợ';
      case PaymentMethodType.momo:
        return 'Ví MoMo';
      case PaymentMethodType.vnpay:
        return 'VNPay';
      case PaymentMethodType.cash:
        return 'Tiền mặt';
    }
  }

  bool get isOnline {
    switch (this) {
      case PaymentMethodType.mock:
      case PaymentMethodType.stripe:
      case PaymentMethodType.momo:
      case PaymentMethodType.vnpay:
        return true;
      case PaymentMethodType.cash:
        return false;
    }
  }
}
