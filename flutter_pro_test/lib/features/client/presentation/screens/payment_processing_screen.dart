import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../booking/domain/entities/service.dart';
import '../../domain/entities/payment_request.dart';
import '../../domain/entities/payment_result.dart';
import '../bloc/client_booking_bloc.dart';
import '../bloc/client_booking_event.dart';
import '../bloc/client_booking_state.dart';
import '../widgets/payment_status_widget.dart';
import '../widgets/payment_summary_card.dart';

/// Screen for processing payment and showing payment status
class PaymentProcessingScreen extends StatefulWidget {
  final Service service;
  final double hours;
  final double totalPrice;
  final PaymentMethod paymentMethod;
  final bool isUrgent;
  final String? bookingId;

  const PaymentProcessingScreen({
    super.key,
    required this.service,
    required this.hours,
    required this.totalPrice,
    required this.paymentMethod,
    this.isUrgent = false,
    this.bookingId,
  });

  @override
  State<PaymentProcessingScreen> createState() =>
      _PaymentProcessingScreenState();
}

class _PaymentProcessingScreenState extends State<PaymentProcessingScreen> {
  bool _hasProcessedPayment = false;

  @override
  void initState() {
    super.initState();
    // Start payment processing after a short delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processPayment();
    });
  }

  void _processPayment() {
    if (_hasProcessedPayment) return;
    _hasProcessedPayment = true;

    // If we don't have a booking ID, we need to create the booking first
    if (widget.bookingId == null) {
      // This would typically come from the previous booking flow
      // For now, we'll simulate creating a booking
      context.read<ClientBookingBloc>().add(
        const CreateBookingEvent('current-user-id'),
      );
    } else {
      // Process payment directly
      context.read<ClientBookingBloc>().add(
        ProcessPaymentEvent(widget.bookingId!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Xử lý thanh toán'),
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        automaticallyImplyLeading:
            false, // Prevent back navigation during processing
      ),
      body: BlocConsumer<ClientBookingBloc, ClientBookingState>(
        listener: (context, state) {
          if (state is BookingCreatedState && widget.bookingId == null) {
            // Booking created, now process payment
            context.read<ClientBookingBloc>().add(
              ProcessPaymentEvent(state.booking.id),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                // Payment summary (always visible)
                PaymentSummaryCard(
                  service: widget.service,
                  hours: widget.hours,
                  basePrice: widget.service.basePrice * widget.hours,
                  totalPrice: widget.totalPrice,
                  isUrgent: widget.isUrgent,
                ),

                SizedBox(height: 32.h),

                // Payment status based on current state
                Expanded(child: _buildPaymentStatus(context, state)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPaymentStatus(BuildContext context, ClientBookingState state) {
    if (state is ClientBookingLoading || state is BookingCreatedState) {
      return _buildProcessingStatus(context);
    }

    if (state is PaymentProcessingState) {
      return _buildProcessingStatus(context);
    }

    if (state is PaymentCompletedState) {
      return _buildCompletedStatus(context, state.paymentResult);
    }

    if (state is ClientBookingError) {
      return _buildErrorStatus(context, state.message);
    }

    // Default processing state
    return _buildProcessingStatus(context);
  }

  Widget _buildProcessingStatus(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Animated loading indicator
        SizedBox(
          width: 80.w,
          height: 80.w,
          child: CircularProgressIndicator(
            strokeWidth: 4.w,
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.primary,
            ),
          ),
        ),

        SizedBox(height: 32.h),

        Text(
          'Đang xử lý thanh toán',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: 12.h),

        Text(
          'Vui lòng đợi trong giây lát...',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: 24.h),

        // Payment method info
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getPaymentMethodIcon(widget.paymentMethod.type),
                color: theme.colorScheme.primary,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Thanh toán qua ${widget.paymentMethod.displayName}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompletedStatus(BuildContext context, PaymentResult result) {
    return PaymentStatusWidget(
      status: result.status,
      message: result.status == PaymentResultStatus.completed
          ? 'Thanh toán của bạn đã được xử lý thành công. Đặt lịch đã được xác nhận.'
          : result.errorMessage ?? 'Đã xảy ra lỗi trong quá trình thanh toán.',
      transactionId: result.transactionId,
      onContinue: () {
        if (result.status == PaymentResultStatus.completed) {
          // Navigate to booking confirmation or home
          context.go('/client');
        } else {
          // Go back to payment method selection
          context.pop();
        }
      },
      onRetry: result.status == PaymentResultStatus.failed
          ? () {
              setState(() {
                _hasProcessedPayment = false;
              });
              _processPayment();
            }
          : null,
    );
  }

  Widget _buildErrorStatus(BuildContext context, String errorMessage) {
    return PaymentStatusWidget(
      status: PaymentResultStatus.failed,
      message: errorMessage,
      onRetry: () {
        setState(() {
          _hasProcessedPayment = false;
        });
        _processPayment();
      },
      onContinue: () => context.pop(),
    );
  }

  IconData _getPaymentMethodIcon(PaymentMethodType type) {
    switch (type) {
      case PaymentMethodType.mock:
        return Icons.code;
      case PaymentMethodType.stripe:
        return Icons.credit_card;
      case PaymentMethodType.momo:
        return Icons.account_balance_wallet;
      case PaymentMethodType.vnpay:
        return Icons.payment;
      case PaymentMethodType.cash:
        return Icons.money;
    }
  }
}
