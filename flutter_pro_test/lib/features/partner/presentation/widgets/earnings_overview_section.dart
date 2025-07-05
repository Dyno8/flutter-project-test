import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/partner_earnings.dart';

/// Earnings overview section widget
class EarningsOverviewSection extends StatelessWidget {
  final PartnerEarnings earnings;
  final VoidCallback onViewDetails;

  const EarningsOverviewSection({
    super.key,
    required this.earnings,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Earnings Overview',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              TextButton(
                onPressed: onViewDetails,
                child: Text(
                  'View Details',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withOpacity(0.8),
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
              children: [
                // Total earnings
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Earnings',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
                          ),
                        ),
                        Text(
                          earnings.formattedTotalEarnings,
                          style: TextStyle(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.account_balance_wallet,
                        size: 32.w,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20.h),

                // Earnings breakdown
                Row(
                  children: [
                    Expanded(
                      child: _buildEarningsCard(
                        context,
                        title: 'Today',
                        amount: earnings.formattedTodayEarnings,
                        jobs: '${earnings.todayJobs} jobs',
                        icon: Icons.today,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _buildEarningsCard(
                        context,
                        title: 'This Week',
                        amount: earnings.formattedWeekEarnings,
                        jobs: '${earnings.weekJobs} jobs',
                        icon: Icons.date_range,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12.h),

                Row(
                  children: [
                    Expanded(
                      child: _buildEarningsCard(
                        context,
                        title: 'This Month',
                        amount: earnings.formattedMonthEarnings,
                        jobs: '${earnings.monthJobs} jobs',
                        icon: Icons.calendar_month,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _buildEarningsCard(
                        context,
                        title: 'Avg/Job',
                        amount: earnings.formattedAveragePerJob,
                        jobs: '${earnings.totalJobs} total',
                        icon: Icons.trending_up,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20.h),

                // Performance indicators
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 16.w,
                                  color: Colors.amber,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  earnings.formattedRating,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onPrimary,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'Rating',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1.w,
                        height: 40.h,
                        color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.3),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              '${earnings.totalReviews}',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                            Text(
                              'Reviews',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1.w,
                        height: 40.h,
                        color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.3),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  earnings.weeklyGrowth >= 0 ? Icons.trending_up : Icons.trending_down,
                                  size: 16.w,
                                  color: earnings.weeklyGrowth >= 0 ? Colors.green : Colors.red,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  earnings.formattedWeeklyGrowth,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: earnings.weeklyGrowth >= 0 ? Colors.green : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'Growth',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsCard(
    BuildContext context, {
    required String title,
    required String amount,
    required String jobs,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16.w,
                color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
              ),
              SizedBox(width: 4.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            amount,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          Text(
            jobs,
            style: TextStyle(
              fontSize: 10.sp,
              color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
