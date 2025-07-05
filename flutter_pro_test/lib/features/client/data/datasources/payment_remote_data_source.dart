import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import '../../../../core/errors/exceptions.dart';
import '../../../../shared/services/firebase_service.dart';
import '../../domain/entities/payment_request.dart';
import '../../domain/entities/payment_result.dart';
import '../models/payment_request_model.dart';
import '../models/payment_result_model.dart';

/// Remote data source for payment operations using Firebase
abstract class PaymentRemoteDataSource {
  Future<List<PaymentMethodModel>> getAvailablePaymentMethods();
  Future<PaymentResultModel> processPayment(PaymentRequestModel request);
  Future<PaymentResultModel> verifyPayment(String transactionId);
  Future<PaymentResultModel> refundPayment({
    required String transactionId,
    required double amount,
    String? reason,
  });
  Future<List<PaymentResultModel>> getPaymentHistory({
    required String userId,
    int limit = 20,
    String? startAfter,
  });
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final FirebaseService _firebaseService;

  PaymentRemoteDataSourceImpl(this._firebaseService);

  static const String _paymentMethodsCollection = 'payment_methods';
  static const String _paymentResultsCollection = 'payment_results';
  static const String _paymentHistoryCollection = 'payment_history';

  @override
  Future<List<PaymentMethodModel>> getAvailablePaymentMethods() async {
    try {
      final query = _firebaseService.firestore
          .collection(_paymentMethodsCollection)
          .where('isEnabled', isEqualTo: true)
          .orderBy('type');

      final snapshot = await query.get();
      return snapshot.docs
          .map(
            (doc) => PaymentMethodModel.fromMap({'id': doc.id, ...doc.data()}),
          )
          .toList();
    } catch (e) {
      throw ServerException('Failed to get payment methods: $e');
    }
  }

  @override
  Future<PaymentResultModel> processPayment(PaymentRequestModel request) async {
    try {
      // Create payment record
      final paymentData = {
        ...request.toMap(),
        'status': 'processing',
        'createdAt': FieldValue.serverTimestamp(),
      };

      final docRef = await _firebaseService.firestore
          .collection(_paymentResultsCollection)
          .add(paymentData);

      // Process payment based on method type
      PaymentResultModel result;
      switch (request.paymentMethod.type) {
        case PaymentMethodType.mock:
          result = await _processMockPayment(request, docRef.id);
          break;
        case PaymentMethodType.stripe:
          result = await _processStripePayment(request, docRef.id);
          break;
        case PaymentMethodType.momo:
          result = await _processMomoPayment(request, docRef.id);
          break;
        case PaymentMethodType.vnpay:
          result = await _processVNPayPayment(request, docRef.id);
          break;
        case PaymentMethodType.cash:
          result = PaymentResultModel.success(
            transactionId: docRef.id,
            amount: request.amount,
            currency: request.currency,
            metadata: {'paymentMethod': 'cash'},
          );
          break;
      }

      // Update payment record with result
      await docRef.update(result.toMap());

      // Add to payment history
      await _addToPaymentHistory(request, result);

      return result;
    } catch (e) {
      throw ServerException('Failed to process payment: $e');
    }
  }

  /// Process mock payment (for testing)
  Future<PaymentResultModel> _processMockPayment(
    PaymentRequestModel request,
    String transactionId,
  ) async {
    // Simulate processing delay
    await Future.delayed(const Duration(seconds: 2));

    // Mock success (you can add failure scenarios for testing)
    return PaymentResultModel.success(
      transactionId: transactionId,
      amount: request.amount,
      currency: request.currency,
      metadata: {'paymentMethod': 'mock', 'bookingId': request.bookingId},
    );
  }

  /// Process Stripe payment
  Future<PaymentResultModel> _processStripePayment(
    PaymentRequestModel request,
    String transactionId,
  ) async {
    try {
      // Convert VND to smallest currency unit (for Stripe, VND doesn't have subunits)
      final amountInCents = (request.amount).round();

      // Create payment intent
      final paymentIntent = await _createStripePaymentIntent(
        amount: amountInCents,
        currency: request.currency.toLowerCase(),
        metadata: {
          'booking_id': request.bookingId,
          'transaction_id': transactionId,
        },
      );

      if (paymentIntent == null) {
        return PaymentResultModel.failure(
          errorMessage: 'Failed to create payment intent',
          errorCode: 'STRIPE_PAYMENT_INTENT_ERROR',
        );
      }

      // For now, simulate successful payment
      // In a real app, you would present the payment sheet to the user
      // and handle the payment confirmation
      await Future.delayed(const Duration(seconds: 3));

      return PaymentResultModel.success(
        transactionId: paymentIntent['id'] ?? transactionId,
        amount: request.amount,
        currency: request.currency,
        metadata: {
          'paymentMethod': 'stripe',
          'bookingId': request.bookingId,
          'stripePaymentIntentId': paymentIntent['id'],
        },
      );
    } on stripe.StripeException catch (e) {
      return PaymentResultModel.failure(
        errorMessage: 'Stripe payment failed: ${e.error.localizedMessage}',
        errorCode: e.error.code.name,
      );
    } catch (e) {
      return PaymentResultModel.failure(
        errorMessage: 'Stripe payment failed: $e',
        errorCode: 'STRIPE_ERROR',
      );
    }
  }

  /// Process MoMo payment
  Future<PaymentResultModel> _processMomoPayment(
    PaymentRequestModel request,
    String transactionId,
  ) async {
    try {
      // TODO: Implement actual MoMo integration
      return PaymentResultModel.failure(
        errorMessage: 'MoMo payment not yet implemented',
        errorCode: 'NOT_IMPLEMENTED',
      );
    } catch (e) {
      return PaymentResultModel.failure(
        errorMessage: 'MoMo payment failed: $e',
        errorCode: 'MOMO_ERROR',
      );
    }
  }

  /// Process VNPay payment
  Future<PaymentResultModel> _processVNPayPayment(
    PaymentRequestModel request,
    String transactionId,
  ) async {
    try {
      // TODO: Implement actual VNPay integration
      return PaymentResultModel.failure(
        errorMessage: 'VNPay payment not yet implemented',
        errorCode: 'NOT_IMPLEMENTED',
      );
    } catch (e) {
      return PaymentResultModel.failure(
        errorMessage: 'VNPay payment failed: $e',
        errorCode: 'VNPAY_ERROR',
      );
    }
  }

  /// Add payment to user's payment history
  Future<void> _addToPaymentHistory(
    PaymentRequestModel request,
    PaymentResultModel result,
  ) async {
    try {
      final historyData = {
        'userId': request.bookingId, // Extract userId from booking
        'bookingId': request.bookingId,
        'amount': request.amount,
        'currency': request.currency,
        'paymentMethod': PaymentMethodModel.fromEntity(
          request.paymentMethod,
        ).toMap(),
        'result': result.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firebaseService.firestore
          .collection(_paymentHistoryCollection)
          .add(historyData);
    } catch (e) {
      // Log error but don't fail the payment
      print('Failed to add to payment history: $e');
    }
  }

  @override
  Future<PaymentResultModel> verifyPayment(String transactionId) async {
    try {
      final doc = await _firebaseService.firestore
          .collection(_paymentResultsCollection)
          .doc(transactionId)
          .get();

      if (!doc.exists) {
        throw ServerException('Payment not found');
      }

      return PaymentResultModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException('Failed to verify payment: $e');
    }
  }

  @override
  Future<PaymentResultModel> refundPayment({
    required String transactionId,
    required double amount,
    String? reason,
  }) async {
    try {
      // TODO: Implement actual refund logic based on payment method
      final refundData = {
        'originalTransactionId': transactionId,
        'refundAmount': amount,
        'reason': reason,
        'status': 'refunded',
        'createdAt': FieldValue.serverTimestamp(),
      };

      final docRef = await _firebaseService.firestore
          .collection(_paymentResultsCollection)
          .add(refundData);

      return PaymentResultModel(
        success: true,
        transactionId: docRef.id,
        amount: amount,
        status: PaymentResultStatus.refunded,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      throw ServerException('Failed to process refund: $e');
    }
  }

  @override
  Future<List<PaymentResultModel>> getPaymentHistory({
    required String userId,
    int limit = 20,
    String? startAfter,
  }) async {
    try {
      Query query = _firebaseService.firestore
          .collection(_paymentHistoryCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (startAfter != null) {
        final startDoc = await _firebaseService.firestore
            .collection(_paymentHistoryCollection)
            .doc(startAfter)
            .get();
        query = query.startAfterDocument(startDoc);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map(
            (doc) => PaymentResultModel.fromMap({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }),
          )
          .toList();
    } catch (e) {
      throw ServerException('Failed to get payment history: $e');
    }
  }

  /// Create Stripe payment intent
  /// In a real implementation, this would call your backend API
  /// which would create the payment intent using Stripe's server-side SDK
  Future<Map<String, dynamic>?> _createStripePaymentIntent({
    required int amount,
    required String currency,
    Map<String, String>? metadata,
  }) async {
    try {
      // TODO: Replace with actual backend API call
      // This is a mock implementation for demonstration
      // In production, you should NEVER create payment intents on the client side

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Mock payment intent response
      return {
        'id': 'pi_mock_${DateTime.now().millisecondsSinceEpoch}',
        'amount': amount,
        'currency': currency,
        'status': 'requires_payment_method',
        'client_secret':
            'pi_mock_secret_${DateTime.now().millisecondsSinceEpoch}',
        'metadata': metadata ?? {},
      };
    } catch (e) {
      print('Failed to create payment intent: $e');
      return null;
    }
  }
}
