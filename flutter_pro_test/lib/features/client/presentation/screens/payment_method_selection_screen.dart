import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../booking/domain/entities/service.dart';
import '../../domain/entities/payment_request.dart';
import '../bloc/client_booking_bloc.dart';
import '../bloc/client_booking_event.dart';
import '../bloc/client_booking_state.dart';
import '../widgets/payment_method_card.dart';
import '../widgets/payment_summary_card.dart';

/// Screen for selecting payment method during booking flow
class PaymentMethodSelectionScreen extends StatefulWidget {
  final Service service;
  final double hours;
  final double totalPrice;
  final bool isUrgent;

  const PaymentMethodSelectionScreen({
    super.key,
    required this.service,
    required this.hours,
    required this.totalPrice,
    this.isUrgent = false,
  });

  @override
  State<PaymentMethodSelectionScreen> createState() =>
      _PaymentMethodSelectionScreenState();
}

class _PaymentMethodSelectionScreenState
    extends State<PaymentMethodSelectionScreen> {
  PaymentMethod? _selectedPaymentMethod;

  @override
  void initState() {
    super.initState();
    // Load available payment methods when screen initializes
    context.read<ClientBookingBloc>().add(const LoadPaymentMethodsEvent());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Phương thức thanh toán'),
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: BlocConsumer<ClientBookingBloc, ClientBookingState>(
        listener: (context, state) {
          if (state is ClientBookingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ClientBookingLoading) {
            return const Center(child: LoadingWidget());
          }

          if (state is ClientBookingError) {
            return Center(
              child: CustomErrorWidget(
                message: state.message,
                onRetry: () {
                  context.read<ClientBookingBloc>().add(
                    const LoadPaymentMethodsEvent(),
                  );
                },
              ),
            );
          }

          if (state is BookingFlowState) {
            return _buildPaymentMethodSelection(context, state);
          }

          return const Center(child: LoadingWidget());
        },
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildPaymentMethodSelection(
    BuildContext context,
    BookingFlowState state,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Payment summary
          PaymentSummaryCard(
            service: widget.service,
            hours: widget.hours,
            basePrice: widget.service.basePrice * widget.hours,
            totalPrice: widget.totalPrice,
            isUrgent: widget.isUrgent,
          ),

          SizedBox(height: 24.h),

          // Payment methods section
          Text(
            'Chọn phương thức thanh toán',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),

          SizedBox(height: 16.h),

          if (state.paymentMethods != null && state.paymentMethods!.isNotEmpty)
            ...state.paymentMethods!.map((paymentMethod) {
              final isSelected = _selectedPaymentMethod?.id == paymentMethod.id;
              return Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: PaymentMethodCard(
                  paymentMethod: paymentMethod,
                  isSelected: isSelected,
                  isEnabled: paymentMethod.isEnabled,
                  onTap: () {
                    setState(() {
                      _selectedPaymentMethod = paymentMethod;
                    });
                    context.read<ClientBookingBloc>().add(
                      SelectPaymentMethodEvent(paymentMethod),
                    );
                  },
                ),
              );
            }).toList()
          else
            _buildEmptyPaymentMethods(context),

          SizedBox(height: 100.h), // Space for bottom bar
        ],
      ),
    );
  }

  Widget _buildEmptyPaymentMethods(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Icon(
            Icons.payment_outlined,
            size: 48.sp,
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
          SizedBox(height: 16.h),
          Text(
            'Không có phương thức thanh toán',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Vui lòng thử lại sau',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Back button
            Expanded(
              flex: 1,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: const Text('Quay lại'),
              ),
            ),

            SizedBox(width: 16.w),

            // Continue button
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _selectedPaymentMethod != null
                    ? () => _proceedToPayment(context)
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: const Text('Tiếp tục'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _proceedToPayment(BuildContext context) {
    if (_selectedPaymentMethod == null) return;

    // Navigate to payment processing screen
    context.push(
      '/client/booking/payment-processing',
      extra: {
        'service': widget.service,
        'hours': widget.hours,
        'totalPrice': widget.totalPrice,
        'paymentMethod': _selectedPaymentMethod,
        'isUrgent': widget.isUrgent,
      },
    );
  }
}
