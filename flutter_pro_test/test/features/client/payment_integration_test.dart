import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pro_test/features/client/domain/entities/payment_request.dart';
import 'package:flutter_pro_test/features/client/domain/entities/payment_result.dart';

void main() {
  group('Payment Integration Tests', () {
    group('Payment Method Types', () {
      test('should have correct display names', () {
        expect(PaymentMethodType.mock.displayName, 'Mock Payment');
        expect(PaymentMethodType.stripe.displayName, 'Thẻ tín dụng/ghi nợ');
        expect(PaymentMethodType.momo.displayName, 'Ví MoMo');
        expect(PaymentMethodType.vnpay.displayName, 'VNPay');
        expect(PaymentMethodType.cash.displayName, 'Tiền mặt');
      });

      test('should correctly identify online payment methods', () {
        expect(PaymentMethodType.mock.isOnline, true);
        expect(PaymentMethodType.stripe.isOnline, true);
        expect(PaymentMethodType.momo.isOnline, true);
        expect(PaymentMethodType.vnpay.isOnline, true);
        expect(PaymentMethodType.cash.isOnline, false);
      });
    });

    group('Payment Result Status', () {
      test('should have correct display names', () {
        expect(PaymentResultStatus.pending.displayName, 'Đang chờ xử lý');
        expect(PaymentResultStatus.processing.displayName, 'Đang xử lý');
        expect(PaymentResultStatus.completed.displayName, 'Thành công');
        expect(PaymentResultStatus.failed.displayName, 'Thất bại');
        expect(PaymentResultStatus.cancelled.displayName, 'Đã hủy');
        expect(PaymentResultStatus.refunded.displayName, 'Đã hoàn tiền');
      });

      test('should correctly identify status types', () {
        expect(PaymentResultStatus.completed.isSuccess, true);
        expect(PaymentResultStatus.failed.isFailed, true);
        expect(PaymentResultStatus.cancelled.isCancelled, true);
        expect(PaymentResultStatus.pending.isPending, true);
        expect(PaymentResultStatus.processing.isProcessing, true);
      });
    });
  });
}
