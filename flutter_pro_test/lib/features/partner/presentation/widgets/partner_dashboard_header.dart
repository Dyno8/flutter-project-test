import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/partner_earnings.dart';

/// Header widget for partner dashboard
class PartnerDashboardHeader extends StatelessWidget {
  final PartnerAvailability availability;
  final PartnerEarnings earnings;
  final Function(bool isAvailable, String? reason) onAvailabilityToggle;

  const PartnerDashboardHeader({
    super.key,
    required this.availability,
    required this.earnings,
    required this.onAvailabilityToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.primaryContainer.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome message and status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back!',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Ready to help clients today?',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusIndicator(context),
            ],
          ),

          SizedBox(height: 20.h),

          // Availability status and toggle
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  availability.isCurrentlyAvailable
                      ? Icons.check_circle
                      : Icons.pause_circle,
                  color: availability.isCurrentlyAvailable
                      ? Colors.green
                      : Colors.orange,
                  size: 24.w,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        availability.availabilityStatus,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      if (!availability.isCurrentlyAvailable && 
                          availability.unavailabilityReason != null)
                        Text(
                          availability.unavailabilityReason!,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      Text(
                        availability.lastSeenText,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: availability.isAvailable,
                  onChanged: (value) {
                    if (value) {
                      onAvailabilityToggle(true, null);
                    } else {
                      _showUnavailabilityDialog(context);
                    }
                  },
                  activeColor: Colors.green,
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // Today's earnings highlight
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.monetization_on,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24.w,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Today\'s Earnings',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                        ),
                      ),
                      Text(
                        earnings.formattedTodayEarnings,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${earnings.todayJobs} jobs',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    if (earnings.weeklyGrowth != 0)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: earnings.weeklyGrowth > 0
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          earnings.formattedWeeklyGrowth,
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: earnings.weeklyGrowth > 0 ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: availability.isOnline
            ? Colors.green.withOpacity(0.2)
            : Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: availability.isOnline ? Colors.green : Colors.grey,
          width: 1.w,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8.w,
            height: 8.h,
            decoration: BoxDecoration(
              color: availability.isOnline ? Colors.green : Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 6.w),
          Text(
            availability.isOnline ? 'Online' : 'Offline',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: availability.isOnline ? Colors.green : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  void _showUnavailabilityDialog(BuildContext context) {
    final reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Unavailable'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for being unavailable:'),
            SizedBox(height: 16.h),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'e.g., Taking a break, Personal time',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onAvailabilityToggle(false, reasonController.text.trim());
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
