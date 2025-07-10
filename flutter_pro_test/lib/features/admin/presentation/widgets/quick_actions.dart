import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../shared/theme/app_colors.dart';

/// Quick actions widget for common admin tasks
class QuickActions extends StatelessWidget {
  final VoidCallback? onExportReports;
  final VoidCallback? onManageUsers;
  final VoidCallback? onManagePartners;
  final VoidCallback? onSystemSettings;
  final VoidCallback? onViewAnalytics;
  final VoidCallback? onManageBookings;

  const QuickActions({
    super.key,
    this.onExportReports,
    this.onManageUsers,
    this.onManagePartners,
    this.onSystemSettings,
    this.onViewAnalytics,
    this.onManageBookings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          
          // Actions Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: _getCrossAxisCount(context),
            childAspectRatio: 2.5,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            children: _buildActionCards(),
          ),
        ],
      ),
    );
  }

  /// Get cross axis count based on screen size
  int _getCrossAxisCount(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 1200) return 3;
    if (screenWidth > 800) return 2;
    return 1;
  }

  /// Build action cards
  List<Widget> _buildActionCards() {
    return [
      _buildActionCard(
        title: 'Export Reports',
        subtitle: 'Generate and download reports',
        icon: Icons.file_download_outlined,
        color: AppColors.primary,
        onTap: onExportReports,
      ),
      _buildActionCard(
        title: 'Manage Users',
        subtitle: 'View and manage user accounts',
        icon: Icons.people_outline,
        color: AppColors.secondary,
        onTap: onManageUsers,
      ),
      _buildActionCard(
        title: 'Manage Partners',
        subtitle: 'Partner verification and management',
        icon: Icons.business_center_outlined,
        color: AppColors.success,
        onTap: onManagePartners,
      ),
      _buildActionCard(
        title: 'System Settings',
        subtitle: 'Configure system parameters',
        icon: Icons.settings_outlined,
        color: AppColors.warning,
        onTap: onSystemSettings,
      ),
      _buildActionCard(
        title: 'View Analytics',
        subtitle: 'Detailed analytics and insights',
        icon: Icons.analytics_outlined,
        color: AppColors.info,
        onTap: onViewAnalytics,
      ),
      _buildActionCard(
        title: 'Manage Bookings',
        subtitle: 'Monitor and manage bookings',
        icon: Icons.event_note_outlined,
        color: AppColors.error,
        onTap: onManageBookings,
      ),
    ];
  }

  /// Build individual action card
  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: AppColors.border.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24.r,
              ),
            ),
            
            SizedBox(width: 16.w),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            // Arrow
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textSecondary,
              size: 16.r,
            ),
          ],
        ),
      ),
    );
  }
}
