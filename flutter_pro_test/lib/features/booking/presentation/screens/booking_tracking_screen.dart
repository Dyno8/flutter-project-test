import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../bloc/realtime_booking_bloc.dart';
import '../widgets/realtime_booking_tracker.dart';
import '../../../../shared/models/booking_model.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../core/di/injection_container.dart' as di;

/// Screen for real-time booking tracking
class BookingTrackingScreen extends StatelessWidget {
  final String bookingId;
  final BookingModel? booking;
  final bool isPartnerView;

  const BookingTrackingScreen({
    super.key,
    required this.bookingId,
    this.booking,
    this.isPartnerView = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<RealtimeBookingBloc>(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            isPartnerView ? 'Job Tracking' : 'Booking Tracking',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.textOnPrimary,
            ),
          ),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                // Refresh tracking
                context.read<RealtimeBookingBloc>().add(
                  StartRealtimeTrackingEvent(bookingId),
                );
              },
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Booking Info Card (if available)
                if (booking != null) ...[
                  _buildBookingInfoCard(booking!),
                  SizedBox(height: 16.h),
                ],

                // Real-time Tracker
                RealtimeBookingTracker(
                  bookingId: bookingId,
                  isPartnerView: isPartnerView,
                ),

                SizedBox(height: 16.h),

                // Additional Actions
                _buildAdditionalActions(context),

                SizedBox(height: 16.h),

                // Help Section
                _buildHelpSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookingInfoCard(BookingModel booking) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.medical_services,
                  color: AppColors.primary,
                  size: 24.w,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.serviceName,
                      style: AppTextStyles.headlineSmall,
                    ),
                    Text(
                      'Booking #${booking.id.substring(0, 8)}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Divider(color: AppColors.divider),
          SizedBox(height: 12.h),
          _buildInfoRow(
            Icons.schedule,
            'Scheduled Time',
            '${booking.scheduledDate.day}/${booking.scheduledDate.month}/${booking.scheduledDate.year} - ${booking.timeSlot}',
          ),
          SizedBox(height: 8.h),
          _buildInfoRow(
            Icons.location_on,
            'Address',
            booking.clientAddress,
          ),
          SizedBox(height: 8.h),
          _buildInfoRow(
            Icons.access_time,
            'Duration',
            '${booking.hours} hours',
          ),
          SizedBox(height: 8.h),
          _buildInfoRow(
            Icons.payment,
            'Total Price',
            '${booking.totalPrice.toStringAsFixed(0)}k VND',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16.w,
          color: AppColors.textSecondary,
        ),
        SizedBox(width: 8.w),
        Text(
          '$label: ',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodySmall,
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalActions(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: AppTextStyles.headlineSmall,
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Call partner/client
                    _showCallDialog(context);
                  },
                  icon: const Icon(Icons.phone),
                  label: Text(isPartnerView ? 'Call Client' : 'Call Partner'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Send message
                    _showMessageDialog(context);
                  },
                  icon: const Icon(Icons.message),
                  label: const Text('Message'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                ),
              ),
            ],
          ),
          if (!isPartnerView) ...[
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  // Cancel booking
                  _showCancelDialog(context);
                },
                icon: const Icon(Icons.cancel),
                label: const Text('Cancel Booking'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: BorderSide(color: AppColors.error),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHelpSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.help_outline,
                color: AppColors.primary,
                size: 20.w,
              ),
              SizedBox(width: 8.w),
              Text(
                'Need Help?',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            isPartnerView
                ? 'Track your job progress in real-time. Update status as you complete each step of the service.'
                : 'Track your booking in real-time. You\'ll receive updates when your partner is on the way and when the service starts.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8.h),
          TextButton(
            onPressed: () {
              // Navigate to help/support
            },
            child: Text(
              'Contact Support',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCallDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isPartnerView ? 'Call Client' : 'Call Partner'),
        content: Text(
          isPartnerView
              ? 'Would you like to call the client?'
              : 'Would you like to call your assigned partner?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Implement call functionality
            },
            child: const Text('Call'),
          ),
        ],
      ),
    );
  }

  void _showMessageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Message'),
        content: const TextField(
          decoration: InputDecoration(
            hintText: 'Type your message...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Implement message functionality
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text(
          'Are you sure you want to cancel this booking? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Keep Booking'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Implement cancel functionality
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Cancel Booking'),
          ),
        ],
      ),
    );
  }
}
