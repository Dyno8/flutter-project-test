import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pro_test/features/client/domain/entities/payment_request.dart';
import 'package:flutter_pro_test/features/client/domain/entities/payment_result.dart';
import 'package:flutter_pro_test/features/booking/domain/entities/service.dart';

void main() {
  group('Payment Flow Integration Tests', () {
    test('Payment request should be created with correct data', () {
      // Arrange
      const paymentMethod = PaymentMethod(
        id: 'mock',
        type: PaymentMethodType.mock,
        name: 'mock',
        displayName: 'Mock Payment',
        isEnabled: true,
      );

      // Act
      const paymentRequest = PaymentRequest(
        bookingId: 'test-booking-123',
        amount: 150000.0,
        currency: 'VND',
        paymentMethod: paymentMethod,
      );

      // Assert
      expect(paymentRequest.bookingId, 'test-booking-123');
      expect(paymentRequest.amount, 150000.0);
      expect(paymentRequest.currency, 'VND');
      expect(paymentRequest.paymentMethod.type, PaymentMethodType.mock);
    });

    test('Payment result should handle success state correctly', () {
      // Act
      final paymentResult = PaymentResult.success(
        transactionId: 'txn_123456',
        amount: 150000.0,
        currency: 'VND',
        metadata: {'test': 'data'},
      );

      // Assert
      expect(paymentResult.status, PaymentResultStatus.completed);
      expect(paymentResult.transactionId, 'txn_123456');
      expect(paymentResult.amount, 150000.0);
      expect(paymentResult.currency, 'VND');
      expect(paymentResult.metadata?['test'], 'data');
      expect(paymentResult.errorMessage, isNull);
    });

    test('Payment result should handle failure state correctly', () {
      // Act
      final paymentResult = PaymentResult.failure(
        errorMessage: 'Payment failed',
        errorCode: 'PAYMENT_ERROR',
      );

      // Assert
      expect(paymentResult.status, PaymentResultStatus.failed);
      expect(paymentResult.errorMessage, 'Payment failed');
      expect(paymentResult.errorCode, 'PAYMENT_ERROR');
      expect(paymentResult.transactionId, isNull);
    });

    test('Service should calculate price correctly', () {
      // Arrange
      final service = Service(
        id: 'test-service',
        name: 'Test Service',
        description: 'Test Description',
        category: 'test',
        iconUrl: 'test-icon.png',
        basePrice: 50000.0,
        durationMinutes: 60,
        requirements: [],
        benefits: ['Chất lượng cao', 'Đáng tin cậy'],
        isActive: true,
        sortOrder: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      final totalPrice = service.calculatePrice(3.0);

      // Assert
      expect(totalPrice, 150000.0);
      expect(service.formattedPrice, '50000k VND/giờ');
      expect(service.formattedDuration, '60 phút');
    });

    test('Payment method types should have correct properties', () {
      // Test Mock Payment
      expect(PaymentMethodType.mock.displayName, 'Mock Payment');
      expect(PaymentMethodType.mock.isOnline, true);

      // Test Stripe Payment
      expect(PaymentMethodType.stripe.displayName, 'Thẻ tín dụng/ghi nợ');
      expect(PaymentMethodType.stripe.isOnline, true);

      // Test Cash Payment
      expect(PaymentMethodType.cash.displayName, 'Tiền mặt');
      expect(PaymentMethodType.cash.isOnline, false);

      // Test MoMo Payment
      expect(PaymentMethodType.momo.displayName, 'Ví MoMo');
      expect(PaymentMethodType.momo.isOnline, true);

      // Test VNPay Payment
      expect(PaymentMethodType.vnpay.displayName, 'VNPay');
      expect(PaymentMethodType.vnpay.isOnline, true);
    });

    test('Payment result status should have correct properties', () {
      // Test status display names
      expect(PaymentResultStatus.pending.displayName, 'Đang chờ xử lý');
      expect(PaymentResultStatus.processing.displayName, 'Đang xử lý');
      expect(PaymentResultStatus.completed.displayName, 'Thành công');
      expect(PaymentResultStatus.failed.displayName, 'Thất bại');
      expect(PaymentResultStatus.cancelled.displayName, 'Đã hủy');
      expect(PaymentResultStatus.refunded.displayName, 'Đã hoàn tiền');

      // Test status type checks
      expect(PaymentResultStatus.completed.isSuccess, true);
      expect(PaymentResultStatus.failed.isFailed, true);
      expect(PaymentResultStatus.cancelled.isCancelled, true);
      expect(PaymentResultStatus.pending.isPending, true);
      expect(PaymentResultStatus.processing.isProcessing, true);
    });
  });
}
