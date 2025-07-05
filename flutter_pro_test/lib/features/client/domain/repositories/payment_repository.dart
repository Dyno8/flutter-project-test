import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/payment_request.dart';
import '../entities/payment_result.dart';

/// Domain repository interface for payment operations
abstract class PaymentRepository {
  /// Get available payment methods
  Future<Either<Failure, List<PaymentMethod>>> getAvailablePaymentMethods();

  /// Process a payment
  Future<Either<Failure, PaymentResult>> processPayment(PaymentRequest request);

  /// Verify payment status
  Future<Either<Failure, PaymentResult>> verifyPayment(String transactionId);

  /// Refund a payment
  Future<Either<Failure, PaymentResult>> refundPayment({
    required String transactionId,
    required double amount,
    String? reason,
  });

  /// Get payment history for a user
  Future<Either<Failure, List<PaymentResult>>> getPaymentHistory({
    required String userId,
    int limit = 20,
    String? startAfter,
  });
}
