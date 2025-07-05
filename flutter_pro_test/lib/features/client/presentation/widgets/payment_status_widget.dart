import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/payment_result.dart';

/// Widget for displaying payment status with appropriate UI
class PaymentStatusWidget extends StatelessWidget {
  final PaymentResultStatus status;
  final String? message;
  final String? transactionId;
  final VoidCallback? onRetry;
  final VoidCallback? onContinue;

  const PaymentStatusWidget({
    super.key,
    required this.status,
    this.message,
    this.transactionId,
    this.onRetry,
    this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Status icon
        Container(
          width: 80.w,
          height: 80.w,
          decoration: BoxDecoration(
            color: _getStatusColor(status).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getStatusIcon(status),
            color: _getStatusColor(status),
            size: 40.sp,
          ),
        ),

        SizedBox(height: 24.h),

        // Status title
        Text(
          _getStatusTitle(status),
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: _getStatusColor(status),
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: 12.h),

        // Status message
        if (message != null)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Text(
              message!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ),

        // Transaction ID
        if (transactionId != null &&
            status == PaymentResultStatus.completed) ...[
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Column(
              children: [
                Text(
                  'Mã giao dịch',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  transactionId!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],

        SizedBox(height: 32.h),

        // Action buttons
        if (status == PaymentResultStatus.failed && onRetry != null) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onRetry,
              icon: Icon(Icons.refresh, size: 20.sp),
              label: Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),
        ],

        if (onContinue != null)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                backgroundColor: status == PaymentResultStatus.completed
                    ? theme.colorScheme.primary
                    : theme.colorScheme.secondary,
              ),
              child: Text(
                status == PaymentResultStatus.completed
                    ? 'Tiếp tục'
                    : 'Quay lại',
              ),
            ),
          ),
      ],
    );
  }

  IconData _getStatusIcon(PaymentResultStatus status) {
    switch (status) {
      case PaymentResultStatus.pending:
        return Icons.hourglass_empty;
      case PaymentResultStatus.processing:
        return Icons.sync;
      case PaymentResultStatus.completed:
        return Icons.check_circle;
      case PaymentResultStatus.failed:
        return Icons.error;
      case PaymentResultStatus.cancelled:
        return Icons.cancel;
      case PaymentResultStatus.refunded:
        return Icons.undo;
    }
  }

  Color _getStatusColor(PaymentResultStatus status) {
    switch (status) {
      case PaymentResultStatus.pending:
        return Colors.orange;
      case PaymentResultStatus.processing:
        return Colors.blue;
      case PaymentResultStatus.completed:
        return Colors.green;
      case PaymentResultStatus.failed:
        return Colors.red;
      case PaymentResultStatus.cancelled:
        return Colors.grey;
      case PaymentResultStatus.refunded:
        return Colors.purple;
    }
  }

  String _getStatusTitle(PaymentResultStatus status) {
    switch (status) {
      case PaymentResultStatus.pending:
        return 'Đang chờ thanh toán';
      case PaymentResultStatus.processing:
        return 'Đang xử lý thanh toán';
      case PaymentResultStatus.completed:
        return 'Thanh toán thành công';
      case PaymentResultStatus.failed:
        return 'Thanh toán thất bại';
      case PaymentResultStatus.cancelled:
        return 'Thanh toán đã hủy';
      case PaymentResultStatus.refunded:
        return 'Đã hoàn tiền';
    }
  }
}
