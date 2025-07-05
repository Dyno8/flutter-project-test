import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/payment_request.dart';
import '../../domain/entities/payment_result.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/payment_remote_data_source.dart';
import '../models/payment_request_model.dart';

/// Implementation of PaymentRepository
class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource remoteDataSource;

  PaymentRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, List<PaymentMethod>>> getAvailablePaymentMethods() async {
    try {
      final paymentMethods = await remoteDataSource.getAvailablePaymentMethods();
      return Right(paymentMethods.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get payment methods: $e'));
    }
  }

  @override
  Future<Either<Failure, PaymentResult>> processPayment(PaymentRequest request) async {
    try {
      final requestModel = PaymentRequestModel.fromEntity(request);
      final result = await remoteDataSource.processPayment(requestModel);
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to process payment: $e'));
    }
  }

  @override
  Future<Either<Failure, PaymentResult>> verifyPayment(String transactionId) async {
    try {
      final result = await remoteDataSource.verifyPayment(transactionId);
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to verify payment: $e'));
    }
  }

  @override
  Future<Either<Failure, PaymentResult>> refundPayment({
    required String transactionId,
    required double amount,
    String? reason,
  }) async {
    try {
      final result = await remoteDataSource.refundPayment(
        transactionId: transactionId,
        amount: amount,
        reason: reason,
      );
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to refund payment: $e'));
    }
  }

  @override
  Future<Either<Failure, List<PaymentResult>>> getPaymentHistory({
    required String userId,
    int limit = 20,
    String? startAfter,
  }) async {
    try {
      final results = await remoteDataSource.getPaymentHistory(
        userId: userId,
        limit: limit,
        startAfter: startAfter,
      );
      return Right(results.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get payment history: $e'));
    }
  }
}
