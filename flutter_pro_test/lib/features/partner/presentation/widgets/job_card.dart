import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/job.dart';

/// Job card widget for displaying job information
class JobCard extends StatelessWidget {
  final Job job;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onStart;
  final VoidCallback? onComplete;
  final VoidCallback? onCancel;
  final bool showActions;
  final bool isCompact;

  const JobCard({
    super.key,
    required this.job,
    this.onAccept,
    this.onReject,
    this.onStart,
    this.onComplete,
    this.onCancel,
    this.showActions = false,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () {
          // Navigate to job details screen
          Navigator.pushNamed(
            context,
            '/partner/job-details',
            arguments: job.id,
          );
        },
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status and priority
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatusChip(context),
                  if (job.isUrgent || job.priority == JobPriority.urgent)
                    _buildPriorityChip(context),
                ],
              ),

              SizedBox(height: 12.h),

              // Service and client info
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.serviceName,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          job.clientName,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        job.formattedEarnings,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      Text(
                        '${job.hours}h',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 12.h),

              // Date, time, and location
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16.w,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    job.formattedDateTime,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Icon(
                    Icons.location_on,
                    size: 16.w,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Text(
                      job.clientAddress,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              if (job.distanceFromPartner != null) ...[
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(
                      Icons.directions_car,
                      size: 16.w,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      job.formattedDistance,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ],

              // Special instructions
              if (job.specialInstructions != null && job.specialInstructions!.isNotEmpty) ...[
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16.w,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          job.specialInstructions!,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Time indicators
              if (job.isStartingSoon || job.isOverdue) ...[
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: job.isOverdue
                        ? Colors.red.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        job.isOverdue ? Icons.warning : Icons.access_time,
                        size: 12.w,
                        color: job.isOverdue ? Colors.red : Colors.orange,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        job.isOverdue ? 'Overdue' : 'Starting soon',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: job.isOverdue ? Colors.red : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Action buttons
              if (showActions) ...[
                SizedBox(height: 16.h),
                _buildActionButtons(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (job.status) {
      case JobStatus.pending:
        backgroundColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange;
        icon = Icons.pending;
        break;
      case JobStatus.accepted:
        backgroundColor = Colors.blue.withOpacity(0.1);
        textColor = Colors.blue;
        icon = Icons.check_circle;
        break;
      case JobStatus.inProgress:
        backgroundColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green;
        icon = Icons.play_circle;
        break;
      case JobStatus.completed:
        backgroundColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green;
        icon = Icons.check_circle;
        break;
      case JobStatus.rejected:
        backgroundColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red;
        icon = Icons.cancel;
        break;
      case JobStatus.cancelled:
        backgroundColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey;
        icon = Icons.cancel;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.w, color: textColor),
          SizedBox(width: 4.w),
          Text(
            job.status.displayName,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityChip(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.priority_high, size: 12.w, color: Colors.red),
          SizedBox(width: 4.w),
          Text(
            'URGENT',
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    if (job.isPending) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onReject,
              icon: const Icon(Icons.close, size: 16),
              label: const Text('Reject'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
                side: BorderSide(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onAccept,
              icon: const Icon(Icons.check, size: 16),
              label: const Text('Accept'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      );
    }

    if (job.isAccepted && job.canBeStarted) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onStart,
          icon: const Icon(Icons.play_arrow, size: 16),
          label: const Text('Start Job'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }

    if (job.isInProgress && job.canBeCompleted) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onComplete,
          icon: const Icon(Icons.check_circle, size: 16),
          label: const Text('Complete Job'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
