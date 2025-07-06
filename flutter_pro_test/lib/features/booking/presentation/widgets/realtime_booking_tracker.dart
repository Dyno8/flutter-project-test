import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../bloc/realtime_booking_bloc.dart';
import '../../../../shared/services/realtime_booking_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';

/// Widget for real-time booking tracking
class RealtimeBookingTracker extends StatefulWidget {
  final String bookingId;
  final bool isPartnerView;

  const RealtimeBookingTracker({
    super.key,
    required this.bookingId,
    this.isPartnerView = false,
  });

  @override
  State<RealtimeBookingTracker> createState() => _RealtimeBookingTrackerState();
}

class _RealtimeBookingTrackerState extends State<RealtimeBookingTracker> {
  late RealtimeBookingBloc _realtimeBloc;

  @override
  void initState() {
    super.initState();
    _realtimeBloc = context.read<RealtimeBookingBloc>();
    _realtimeBloc.add(StartRealtimeTrackingEvent(widget.bookingId));
  }

  @override
  void dispose() {
    _realtimeBloc.add(StopRealtimeTrackingEvent(widget.bookingId));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RealtimeBookingBloc, RealtimeBookingState>(
      builder: (context, state) {
        if (state is RealtimeBookingLoading) {
          return _buildLoadingWidget();
        } else if (state is RealtimeBookingUpdated) {
          return _buildTrackingWidget(state.data);
        } else if (state is RealtimeBookingError) {
          return _buildErrorWidget(state.message);
        } else {
          return _buildInitialWidget();
        }
      },
    );
  }

  Widget _buildLoadingWidget() {
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
        children: [
          const CircularProgressIndicator(),
          SizedBox(height: 12.h),
          Text(
            'Initializing real-time tracking...',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingWidget(BookingRealtimeData data) {
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
          // Status Header
          _buildStatusHeader(data.status),
          SizedBox(height: 16.h),

          // Location Info (if available)
          if (data.partnerLocation != null) ...[
            _buildLocationInfo(data.partnerLocation!),
            SizedBox(height: 16.h),
          ],

          // Estimated Arrival (if available)
          if (data.estimatedArrival != null) ...[
            _buildEstimatedArrival(data.estimatedArrival!),
            SizedBox(height: 16.h),
          ],

          // Recent Messages
          if (data.messages.isNotEmpty) ...[
            _buildRecentMessages(data.messages),
            SizedBox(height: 16.h),
          ],

          // Last Updated
          _buildLastUpdated(data.lastUpdated),

          // Partner Actions (if partner view)
          if (widget.isPartnerView) ...[
            SizedBox(height: 16.h),
            _buildPartnerActions(data),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusHeader(String status) {
    final statusInfo = _getStatusInfo(status);
    
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: statusInfo.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            statusInfo.icon,
            color: statusInfo.color,
            size: 24.w,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                statusInfo.title,
                style: AppTextStyles.headlineSmall.copyWith(
                  color: statusInfo.color,
                ),
              ),
              Text(
                statusInfo.description,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationInfo(LocationData location) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on,
            color: AppColors.primary,
            size: 20.w,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Partner Location',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Lat: ${location.latitude.toStringAsFixed(6)}, '
                  'Lng: ${location.longitude.toStringAsFixed(6)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  'Accuracy: ${location.accuracy.toStringAsFixed(1)}m',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstimatedArrival(DateTime estimatedArrival) {
    final timeFormat = DateFormat('HH:mm');
    final now = DateTime.now();
    final difference = estimatedArrival.difference(now);
    
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: AppColors.secondary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.access_time,
            color: AppColors.secondary,
            size: 20.w,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estimated Arrival',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  timeFormat.format(estimatedArrival),
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
                if (difference.inMinutes > 0)
                  Text(
                    'In ${difference.inMinutes} minutes',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentMessages(List<RealtimeMessage> messages) {
    final recentMessages = messages.take(3).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Updates',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        ...recentMessages.map((message) => _buildMessageItem(message)),
      ],
    );
  }

  Widget _buildMessageItem(RealtimeMessage message) {
    final timeFormat = DateFormat('HH:mm');
    
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            timeFormat.format(message.timestamp),
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              message.message,
              style: AppTextStyles.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastUpdated(DateTime lastUpdated) {
    final timeFormat = DateFormat('HH:mm:ss');
    
    return Row(
      children: [
        Icon(
          Icons.update,
          color: AppColors.textSecondary,
          size: 16.w,
        ),
        SizedBox(width: 4.w),
        Text(
          'Last updated: ${timeFormat.format(lastUpdated)}',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildPartnerActions(BookingRealtimeData data) {
    return Column(
      children: [
        if (data.status == AppConstants.statusConfirmed) ...[
          ElevatedButton.icon(
            onPressed: () => _updateStatus(AppConstants.statusInProgress, 'Service started'),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start Service'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: Size(double.infinity, 44.h),
            ),
          ),
        ],
        if (data.status == AppConstants.statusInProgress) ...[
          ElevatedButton.icon(
            onPressed: () => _updateStatus(AppConstants.statusCompleted, 'Service completed'),
            icon: const Icon(Icons.check_circle),
            label: const Text('Complete Service'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              minimumSize: Size(double.infinity, 44.h),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildErrorWidget(String message) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.error.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 32.w,
          ),
          SizedBox(height: 8.h),
          Text(
            'Tracking Error',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.error,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            message,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInitialWidget() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        'Real-time tracking not active',
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  void _updateStatus(String status, String message) {
    _realtimeBloc.add(UpdateBookingStatusEvent(
      bookingId: widget.bookingId,
      status: status,
      message: message,
    ));
  }

  StatusInfo _getStatusInfo(String status) {
    switch (status) {
      case AppConstants.statusPending:
        return StatusInfo(
          title: 'Booking Pending',
          description: 'Waiting for partner confirmation',
          icon: Icons.pending,
          color: Colors.orange,
        );
      case AppConstants.statusConfirmed:
        return StatusInfo(
          title: 'Booking Confirmed',
          description: 'Partner is on the way',
          icon: Icons.check_circle,
          color: AppColors.primary,
        );
      case AppConstants.statusInProgress:
        return StatusInfo(
          title: 'Service In Progress',
          description: 'Partner is providing the service',
          icon: Icons.work,
          color: Colors.blue,
        );
      case AppConstants.statusCompleted:
        return StatusInfo(
          title: 'Service Completed',
          description: 'Service has been completed successfully',
          icon: Icons.done_all,
          color: AppColors.success,
        );
      default:
        return StatusInfo(
          title: 'Unknown Status',
          description: 'Status information not available',
          icon: Icons.help,
          color: AppColors.textSecondary,
        );
    }
  }
}

class StatusInfo {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  StatusInfo({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
