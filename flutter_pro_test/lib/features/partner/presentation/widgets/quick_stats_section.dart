import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Quick stats section widget for partner dashboard
class QuickStatsSection extends StatelessWidget {
  final int pendingJobsCount;
  final int acceptedJobsCount;
  final double todayEarnings;
  final double averageRating;

  const QuickStatsSection({
    super.key,
    required this.pendingJobsCount,
    required this.acceptedJobsCount,
    required this.todayEarnings,
    required this.averageRating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Stats',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: Icons.pending_actions,
                  title: 'Pending',
                  value: pendingJobsCount.toString(),
                  subtitle: 'jobs',
                  color: Colors.orange,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: Icons.work,
                  title: 'Active',
                  value: acceptedJobsCount.toString(),
                  subtitle: 'jobs',
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: Icons.monetization_on,
                  title: 'Today',
                  value: '${todayEarnings.toStringAsFixed(0)}k',
                  subtitle: 'VND',
                  color: Colors.green,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: Icons.star,
                  title: 'Rating',
                  value: averageRating.toStringAsFixed(1),
                  subtitle: 'stars',
                  color: Colors.amber,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.05),
            blurRadius: 4.r,
            offset: Offset(0, 2.h),
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
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  icon,
                  size: 20.w,
                  color: color,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10.sp,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}
