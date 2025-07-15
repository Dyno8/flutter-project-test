import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../shared/theme/app_colors.dart';

/// Real-time status indicator widget with animated pulse effect
class RealTimeStatusIndicator extends StatefulWidget {
  final String status;
  final String label;
  final bool isRealTime;
  final VoidCallback? onTap;

  const RealTimeStatusIndicator({
    super.key,
    required this.status,
    required this.label,
    this.isRealTime = true,
    this.onTap,
  });

  @override
  State<RealTimeStatusIndicator> createState() => _RealTimeStatusIndicatorState();
}

class _RealTimeStatusIndicatorState extends State<RealTimeStatusIndicator>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    
    // Pulse animation for status indicator
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Rotation animation for loading states
    _rotationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_rotationController);

    // Start animations based on status
    _updateAnimations();
  }

  @override
  void didUpdateWidget(RealTimeStatusIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.status != widget.status || oldWidget.isRealTime != widget.isRealTime) {
      _updateAnimations();
    }
  }

  void _updateAnimations() {
    if (widget.isRealTime) {
      if (widget.status == 'healthy' || widget.status == 'operational') {
        _pulseController.repeat(reverse: true);
        _rotationController.stop();
      } else if (widget.status == 'loading' || widget.status == 'updating') {
        _rotationController.repeat();
        _pulseController.stop();
      } else if (widget.status == 'critical' || widget.status == 'error') {
        _pulseController.repeat(reverse: true);
        _rotationController.stop();
      } else {
        _pulseController.stop();
        _rotationController.stop();
      }
    } else {
      _pulseController.stop();
      _rotationController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: _getStatusColor().withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: _getStatusColor().withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusIcon(),
            SizedBox(width: 8.w),
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: _getStatusColor(),
              ),
            ),
            if (widget.isRealTime) ...[
              SizedBox(width: 8.w),
              _buildRealTimeIndicator(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    final icon = _getStatusIcon();
    final color = _getStatusColor();

    if (widget.status == 'loading' || widget.status == 'updating') {
      return AnimatedBuilder(
        animation: _rotationAnimation,
        builder: (context, child) {
          return Transform.rotate(
            angle: _rotationAnimation.value * 2 * 3.14159,
            child: Icon(
              icon,
              size: 16.sp,
              color: color,
            ),
          );
        },
      );
    } else if (widget.isRealTime && (widget.status == 'healthy' || widget.status == 'critical')) {
      return AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Icon(
              icon,
              size: 16.sp,
              color: color,
            ),
          );
        },
      );
    } else {
      return Icon(
        icon,
        size: 16.sp,
        color: color,
      );
    }
  }

  Widget _buildRealTimeIndicator() {
    return Container(
      width: 6.w,
      height: 6.h,
      decoration: BoxDecoration(
        color: AppColors.success,
        shape: BoxShape.circle,
      ),
    );
  }

  Color _getStatusColor() {
    switch (widget.status.toLowerCase()) {
      case 'healthy':
      case 'operational':
      case 'passed':
        return AppColors.success;
      case 'warning':
        return AppColors.warning;
      case 'critical':
      case 'error':
      case 'failed':
        return AppColors.error;
      case 'loading':
      case 'updating':
        return AppColors.info;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getStatusIcon() {
    switch (widget.status.toLowerCase()) {
      case 'healthy':
      case 'operational':
      case 'passed':
        return Icons.check_circle;
      case 'warning':
        return Icons.warning;
      case 'critical':
      case 'error':
      case 'failed':
        return Icons.error;
      case 'loading':
      case 'updating':
        return Icons.refresh;
      default:
        return Icons.help;
    }
  }
}

/// Live metrics counter with animated number changes
class LiveMetricsCounter extends StatefulWidget {
  final String label;
  final int currentValue;
  final int? previousValue;
  final String? unit;
  final Color? color;
  final IconData? icon;

  const LiveMetricsCounter({
    super.key,
    required this.label,
    required this.currentValue,
    this.previousValue,
    this.unit,
    this.color,
    this.icon,
  });

  @override
  State<LiveMetricsCounter> createState() => _LiveMetricsCounterState();
}

class _LiveMetricsCounterState extends State<LiveMetricsCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;
  int _displayValue = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _displayValue = widget.currentValue;
    _setupAnimation();
  }

  @override
  void didUpdateWidget(LiveMetricsCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentValue != widget.currentValue) {
      _setupAnimation();
      _controller.forward(from: 0);
    }
  }

  void _setupAnimation() {
    final startValue = widget.previousValue ?? _displayValue;
    _animation = IntTween(
      begin: startValue,
      end: widget.currentValue,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors.primary;
    
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  size: 20.sp,
                  color: color,
                ),
                SizedBox(width: 8.w),
              ],
              Expanded(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _animation.value.toString(),
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  if (widget.unit != null) ...[
                    SizedBox(width: 4.w),
                    Text(
                      widget.unit!,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
          if (widget.previousValue != null && widget.previousValue != widget.currentValue) ...[
            SizedBox(height: 4.h),
            _buildTrendIndicator(),
          ],
        ],
      ),
    );
  }

  Widget _buildTrendIndicator() {
    final difference = widget.currentValue - (widget.previousValue ?? 0);
    final isPositive = difference > 0;
    final trendColor = isPositive ? AppColors.success : AppColors.error;
    final trendIcon = isPositive ? Icons.trending_up : Icons.trending_down;

    return Row(
      children: [
        Icon(
          trendIcon,
          size: 12.sp,
          color: trendColor,
        ),
        SizedBox(width: 4.w),
        Text(
          '${isPositive ? '+' : ''}$difference',
          style: TextStyle(
            fontSize: 10.sp,
            color: trendColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
