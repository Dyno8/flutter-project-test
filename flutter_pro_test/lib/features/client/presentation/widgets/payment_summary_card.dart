import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../booking/domain/entities/service.dart';

/// Widget for displaying payment summary information
class PaymentSummaryCard extends StatelessWidget {
  final Service service;
  final double hours;
  final double basePrice;
  final bool isUrgent;
  final double totalPrice;
  final String? promoCode;
  final double? discount;

  const PaymentSummaryCard({
    super.key,
    required this.service,
    required this.hours,
    required this.basePrice,
    required this.totalPrice,
    this.isUrgent = false,
    this.promoCode,
    this.discount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.receipt_long,
                  color: theme.colorScheme.primary,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Chi tiết thanh toán',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            // Service details
            _buildSummaryRow(
              context,
              'Dịch vụ',
              service.name,
              isTitle: true,
            ),
            
            SizedBox(height: 8.h),
            
            _buildSummaryRow(
              context,
              'Thời gian',
              '${hours.toStringAsFixed(1)} giờ',
            ),
            
            _buildSummaryRow(
              context,
              'Giá cơ bản',
              currencyFormat.format(basePrice),
            ),
            
            // Urgent fee if applicable
            if (isUrgent) ...[
              _buildSummaryRow(
                context,
                'Phí khẩn cấp (20%)',
                currencyFormat.format(basePrice * 0.2),
                valueColor: theme.colorScheme.error,
              ),
            ],
            
            // Discount if applicable
            if (discount != null && discount! > 0) ...[
              _buildSummaryRow(
                context,
                'Giảm giá${promoCode != null ? ' ($promoCode)' : ''}',
                '-${currencyFormat.format(discount!)}',
                valueColor: theme.colorScheme.primary,
              ),
            ],
            
            SizedBox(height: 12.h),
            
            // Divider
            Divider(
              color: theme.colorScheme.outline.withOpacity(0.3),
            ),
            
            SizedBox(height: 12.h),
            
            // Total
            _buildSummaryRow(
              context,
              'Tổng cộng',
              currencyFormat.format(totalPrice),
              isTotal: true,
            ),
            
            SizedBox(height: 16.h),
            
            // Payment note
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.primary,
                    size: 16.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Bạn sẽ được thanh toán sau khi dịch vụ hoàn thành',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    String value, {
    bool isTitle = false,
    bool isTotal = false,
    Color? valueColor,
  }) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  )
                : isTitle
                    ? theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      )
                    : theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
          ),
          Text(
            value,
            style: isTotal
                ? theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  )
                : theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: valueColor ?? theme.colorScheme.onSurface,
                  ),
          ),
        ],
      ),
    );
  }
}
