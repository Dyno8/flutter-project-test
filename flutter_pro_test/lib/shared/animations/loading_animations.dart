import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Enhanced loading widgets with smooth animations
class LoadingAnimations {
  /// Shimmer effect for skeleton loading
  static Widget shimmer({
    required Widget child,
    Color? baseColor,
    Color? highlightColor,
    Duration period = const Duration(milliseconds: 1500),
  }) {
    return _ShimmerWidget(
      baseColor: baseColor ?? Colors.grey[300]!,
      highlightColor: highlightColor ?? Colors.grey[100]!,
      period: period,
      child: child,
    );
  }

  /// Skeleton loader for cards
  static Widget skeletonCard({
    double? width,
    double? height,
    double borderRadius = 12.0,
  }) {
    return shimmer(
      child: Container(
        width: width ?? double.infinity,
        height: height ?? 120.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius.r),
        ),
      ),
    );
  }

  /// Skeleton loader for list items
  static Widget skeletonListItem({
    bool showAvatar = true,
    int lineCount = 2,
  }) {
    return shimmer(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showAvatar) ...[
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.r),
                ),
              ),
              SizedBox(width: 12.w),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 16.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  for (int i = 0; i < lineCount - 1; i++) ...[
                    Container(
                      width: (i == lineCount - 2) ? 0.7.sw : double.infinity,
                      height: 14.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(7.r),
                      ),
                    ),
                    if (i < lineCount - 2) SizedBox(height: 6.h),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Pulsing dot animation
  static Widget pulsingDots({
    int dotCount = 3,
    Color? color,
    double size = 8.0,
    Duration duration = const Duration(milliseconds: 1200),
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(dotCount, (index) {
        return _PulsingDot(
          delay: Duration(milliseconds: index * 200),
          color: color ?? Colors.blue,
          size: size,
          duration: duration,
        );
      }),
    );
  }

  /// Rotating loading indicator
  static Widget rotatingIndicator({
    Color? color,
    double size = 24.0,
    Duration duration = const Duration(milliseconds: 1000),
  }) {
    return _RotatingWidget(
      duration: duration,
      child: Icon(
        Icons.refresh,
        color: color ?? Colors.blue,
        size: size,
      ),
    );
  }

  /// Wave loading animation
  static Widget waveLoading({
    Color? color,
    double size = 40.0,
    int waveCount = 4,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(waveCount, (index) {
          return _WaveBar(
            delay: Duration(milliseconds: index * 100),
            color: color ?? Colors.blue,
          );
        }),
      ),
    );
  }
}

/// Internal shimmer widget implementation
class _ShimmerWidget extends StatefulWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;
  final Duration period;

  const _ShimmerWidget({
    required this.child,
    required this.baseColor,
    required this.highlightColor,
    required this.period,
  });

  @override
  State<_ShimmerWidget> createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<_ShimmerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.period,
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ].map((stop) => stop.clamp(0.0, 1.0)).toList(),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Pulsing dot widget
class _PulsingDot extends StatefulWidget {
  final Duration delay;
  final Color color;
  final double size;
  final Duration duration;

  const _PulsingDot({
    required this.delay,
    required this.color,
    required this.size,
    required this.duration,
  });

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 2.w),
          width: widget.size.w,
          height: widget.size.w,
          decoration: BoxDecoration(
            color: widget.color.withOpacity(_animation.value),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}

/// Rotating widget
class _RotatingWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const _RotatingWidget({
    required this.child,
    required this.duration,
  });

  @override
  State<_RotatingWidget> createState() => _RotatingWidgetState();
}

class _RotatingWidgetState extends State<_RotatingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * 3.14159,
          child: widget.child,
        );
      },
    );
  }
}

/// Wave bar widget
class _WaveBar extends StatefulWidget {
  final Duration delay;
  final Color color;

  const _WaveBar({
    required this.delay,
    required this.color,
  });

  @override
  State<_WaveBar> createState() => _WaveBarState();
}

class _WaveBarState extends State<_WaveBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 4.w,
          height: 20.h * _animation.value,
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(2.r),
          ),
        );
      },
    );
  }
}
