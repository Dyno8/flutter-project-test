import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../shared/theme/app_colors.dart';

/// Dashboard card widget for displaying metrics
class DashboardCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? trend;
  final bool? isPositiveTrend;
  final VoidCallback? onTap;
  final Widget? customContent;

  const DashboardCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.trend,
    this.isPositiveTrend,
    this.onTap,
    this.customContent,
  });

  @override
  State<DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<DashboardCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: FadeTransition(opacity: _fadeAnimation, child: _buildCard()),
        );
      },
    );
  }

  Widget _buildCard() {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: AppColors.border.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            // Background gradient
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      widget.color.withValues(alpha: 0.05),
                      widget.color.withValues(alpha: 0.02),
                    ],
                  ),
                ),
              ),
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(16.w),
              child: widget.customContent ?? _buildDefaultContent(),
            ),

            // Decorative element
            Positioned(
              top: -10.h,
              right: -10.w,
              child: Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(widget.icon, color: widget.color, size: 20.sp),
            ),
            const Spacer(),
            if (widget.trend != null) _buildTrendIndicator(),
          ],
        ),
        SizedBox(height: 12.h),
        Text(
          widget.title,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 4.h),
        Text(
          widget.value,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildTrendIndicator() {
    if (widget.trend == null) return const SizedBox.shrink();

    final isPositive = widget.isPositiveTrend ?? true;
    final trendColor = isPositive ? AppColors.success : AppColors.error;
    final trendIcon = isPositive ? Icons.trending_up : Icons.trending_down;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: trendColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(trendIcon, color: trendColor, size: 12.sp),
          SizedBox(width: 2.w),
          Text(
            widget.trend!,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: trendColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Specialized dashboard card for charts
class ChartDashboardCard extends StatelessWidget {
  final String title;
  final Widget chart;
  final String? subtitle;
  final List<Widget>? actions;

  const ChartDashboardCard({
    super.key,
    required this.title,
    required this.chart,
    this.subtitle,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (subtitle != null) ...[
                        SizedBox(height: 4.h),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (actions != null) ...actions!,
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
              child: chart,
            ),
          ),
        ],
      ),
    );
  }
}

/// Loading dashboard card
class LoadingDashboardCard extends StatefulWidget {
  const LoadingDashboardCard({super.key});

  @override
  State<LoadingDashboardCard> createState() => _LoadingDashboardCardState();
}

class _LoadingDashboardCardState extends State<LoadingDashboardCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Container(
                      width: 40.w,
                      height: 40.h,
                      decoration: BoxDecoration(
                        color: AppColors.border.withValues(
                          alpha: _animation.value * 0.3,
                        ),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    );
                  },
                ),
                const Spacer(),
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Container(
                      width: 30.w,
                      height: 16.h,
                      decoration: BoxDecoration(
                        color: AppColors.border.withValues(
                          alpha: _animation.value * 0.3,
                        ),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 12.h),
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Container(
                  width: 80.w,
                  height: 12.h,
                  decoration: BoxDecoration(
                    color: AppColors.border.withValues(
                      alpha: _animation.value * 0.3,
                    ),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                );
              },
            ),
            SizedBox(height: 8.h),
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Container(
                  width: 120.w,
                  height: 20.h,
                  decoration: BoxDecoration(
                    color: AppColors.border.withValues(
                      alpha: _animation.value * 0.3,
                    ),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
