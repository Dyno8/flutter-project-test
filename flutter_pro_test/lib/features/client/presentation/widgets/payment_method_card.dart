import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/payment_request.dart';

/// Widget for displaying a payment method option
class PaymentMethodCard extends StatelessWidget {
  final PaymentMethod paymentMethod;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isEnabled;

  const PaymentMethodCard({
    super.key,
    required this.paymentMethod,
    required this.isSelected,
    required this.onTap,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(
          color: isSelected 
              ? theme.colorScheme.primary 
              : theme.colorScheme.outline.withOpacity(0.2),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              // Payment method icon
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: _getPaymentMethodColor(paymentMethod.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  _getPaymentMethodIcon(paymentMethod.type),
                  color: _getPaymentMethodColor(paymentMethod.type),
                  size: 24.sp,
                ),
              ),
              
              SizedBox(width: 16.w),
              
              // Payment method details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      paymentMethod.displayName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isEnabled 
                            ? theme.colorScheme.onSurface 
                            : theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      _getPaymentMethodDescription(paymentMethod.type),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isEnabled 
                            ? theme.colorScheme.onSurface.withOpacity(0.7)
                            : theme.colorScheme.onSurface.withOpacity(0.4),
                      ),
                    ),
                    if (!paymentMethod.isEnabled)
                      Padding(
                        padding: EdgeInsets.only(top: 4.h),
                        child: Text(
                          'Tạm thời không khả dụng',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              // Selection indicator
              if (isSelected)
                Container(
                  width: 24.w,
                  height: 24.w,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: theme.colorScheme.onPrimary,
                    size: 16.sp,
                  ),
                )
              else
                Container(
                  width: 24.w,
                  height: 24.w,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.5),
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
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

  Color _getPaymentMethodColor(PaymentMethodType type) {
    switch (type) {
      case PaymentMethodType.mock:
        return Colors.purple;
      case PaymentMethodType.stripe:
        return Colors.blue;
      case PaymentMethodType.momo:
        return Colors.pink;
      case PaymentMethodType.vnpay:
        return Colors.red;
      case PaymentMethodType.cash:
        return Colors.green;
    }
  }

  String _getPaymentMethodDescription(PaymentMethodType type) {
    switch (type) {
      case PaymentMethodType.mock:
        return 'Thanh toán giả lập cho thử nghiệm';
      case PaymentMethodType.stripe:
        return 'Thanh toán bằng thẻ tín dụng/ghi nợ';
      case PaymentMethodType.momo:
        return 'Thanh toán qua ví điện tử MoMo';
      case PaymentMethodType.vnpay:
        return 'Thanh toán qua VNPay';
      case PaymentMethodType.cash:
        return 'Thanh toán tiền mặt khi hoàn thành';
    }
  }
}
