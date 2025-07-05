import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/payment_request.dart';
import '../entities/payment_result.dart';
import '../repositories/payment_repository.dart';

/// Use case for processing a payment
class ProcessPayment implements UseCase<PaymentResult, PaymentRequest> {
  final PaymentRepository repository;

  ProcessPayment(this.repository);

  @override
  Future<Either<Failure, PaymentResult>> call(PaymentRequest params) async {
    // Validate payment request
    if (params.amount <= 0) {
      return Left(ValidationFailure('Payment amount must be greater than 0'));
    }

    if (params.bookingId.isEmpty) {
      return Left(ValidationFailure('Booking ID is required'));
    }

    return await repository.processPayment(params);
  }
}

/// Use case for getting available payment methods
class GetAvailablePaymentMethods implements UseCase<List<PaymentMethod>, NoParams> {
  final PaymentRepository repository;

  GetAvailablePaymentMethods(this.repository);

  @override
  Future<Either<Failure, List<PaymentMethod>>> call(NoParams params) async {
    return await repository.getAvailablePaymentMethods();
  }
}

/// Custom failure for validation errors
class ValidationFailure extends Failure {
  ValidationFailure(String message) : super(message);
}
