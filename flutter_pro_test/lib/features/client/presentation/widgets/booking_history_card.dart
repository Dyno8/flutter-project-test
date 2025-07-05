import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../booking/domain/entities/booking.dart';

/// Card widget for displaying booking history item
class BookingHistoryCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback onTap;
  final VoidCallback? onCancel;
  final VoidCallback? onReview;

  const BookingHistoryCard({
    super.key,
    required this.booking,
    required this.onTap,
    this.onCancel,
    this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with service name and status
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.serviceName,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Mã đặt: ${booking.id.substring(0, 8).toUpperCase()}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(context),
                ],
              ),
              
              SizedBox(height: 12.h),
              
              // Booking details
              _buildBookingDetails(context),
              
              SizedBox(height: 12.h),
              
              // Price and actions
              _buildBottomSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    final statusInfo = _getStatusInfo(booking.status);
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: statusInfo.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusInfo.icon,
            size: 12.r,
            color: statusInfo.color,
          ),
          SizedBox(width: 4.w),
          Text(
            statusInfo.label,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: statusInfo.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingDetails(BuildContext context) {
    return Column(
      children: [
        // Date and time
        _buildDetailRow(
          context,
          Icons.schedule,
          'Thời gian',
          '${_formatDate(booking.scheduledDate)} - ${booking.timeSlot}',
        ),
        
        SizedBox(height: 8.h),
        
        // Duration
        _buildDetailRow(
          context,
          Icons.access_time,
          'Thời lượng',
          '${booking.hours.toStringAsFixed(1)} giờ',
        ),
        
        SizedBox(height: 8.h),
        
        // Address
        _buildDetailRow(
          context,
          Icons.location_on,
          'Địa chỉ',
          booking.clientAddress,
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    int maxLines = 1,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16.r,
          color: Theme.of(context).colorScheme.primary,
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSection(BuildContext context) {
    return Row(
      children: [
        // Price
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tổng tiền',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              Text(
                '${booking.totalPrice.toStringAsFixed(0)}đ',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        
        // Action buttons
        Row(
          children: [
            if (onCancel != null) ...[
              OutlinedButton(
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  minimumSize: Size.zero,
                ),
                child: Text(
                  'Hủy',
                  style: TextStyle(fontSize: 12.sp),
                ),
              ),
              SizedBox(width: 8.w),
            ],
            if (onReview != null) ...[
              ElevatedButton(
                onPressed: onReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  minimumSize: Size.zero,
                ),
                child: Text(
                  'Đánh giá',
                  style: TextStyle(fontSize: 12.sp),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  BookingStatusInfo _getStatusInfo(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return BookingStatusInfo(
          label: 'Đang chờ',
          color: Colors.orange,
          icon: Icons.schedule,
        );
      case BookingStatus.confirmed:
        return BookingStatusInfo(
          label: 'Đã xác nhận',
          color: Colors.blue,
          icon: Icons.check_circle_outline,
        );
      case BookingStatus.inProgress:
        return BookingStatusInfo(
          label: 'Đang thực hiện',
          color: Colors.green,
          icon: Icons.play_circle,
        );
      case BookingStatus.completed:
        return BookingStatusInfo(
          label: 'Hoàn thành',
          color: Colors.green,
          icon: Icons.check_circle,
        );
      case BookingStatus.cancelled:
        return BookingStatusInfo(
          label: 'Đã hủy',
          color: Colors.red,
          icon: Icons.cancel,
        );
      case BookingStatus.rejected:
        return BookingStatusInfo(
          label: 'Bị từ chối',
          color: Colors.red,
          icon: Icons.block,
        );
    }
  }

  String _formatDate(DateTime date) {
    final weekdays = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
    final weekday = weekdays[date.weekday % 7];
    return '$weekday ${date.day}/${date.month}/${date.year}';
  }
}

/// Data class for booking status information
class BookingStatusInfo {
  final String label;
  final Color color;
  final IconData icon;

  const BookingStatusInfo({
    required this.label,
    required this.color,
    required this.icon,
  });
}
