import 'dart:math' as math;
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

  /// Pulsing dots loading animation
  static Widget pulsingDots({
    Color? color,
    double size = 8.0,
    int dotCount = 3,
    Duration duration = const Duration(milliseconds: 1200),
  }) {
    return _PulsingDotsWidget(
      color: color ?? Colors.blue,
      size: size,
      dotCount: dotCount,
      duration: duration,
    );
  }

  /// Wave loading animation
  static Widget waveLoading({
    Color? color,
    double size = 40.0,
    Duration duration = const Duration(milliseconds: 1000),
  }) {
    return _WaveLoadingWidget(
      color: color ?? Colors.blue,
      size: size,
      duration: duration,
    );
  }

  /// Rotating indicator
  static Widget rotatingIndicator({
    Color? color,
    double size = 40.0,
    Duration duration = const Duration(milliseconds: 1000),
  }) {
    return _RotatingIndicatorWidget(
      color: color ?? Colors.blue,
      size: size,
      duration: duration,
    );
  }
}

/// Shimmer widget implementation
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
    _controller = AnimationController(duration: widget.period, vsync: this)
      ..repeat();
    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
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

/// Pulsing dots widget implementation
class _PulsingDotsWidget extends StatefulWidget {
  final Color color;
  final double size;
  final int dotCount;
  final Duration duration;

  const _PulsingDotsWidget({
    required this.color,
    required this.size,
    required this.dotCount,
    required this.duration,
  });

  @override
  State<_PulsingDotsWidget> createState() => _PulsingDotsWidgetState();
}

class _PulsingDotsWidgetState extends State<_PulsingDotsWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.dotCount, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final delay = index * 0.2;
            final animationValue = (_controller.value + delay) % 1.0;
            final scale =
                0.5 +
                0.5 * (1 - (animationValue - 0.5).abs() * 2).clamp(0.0, 1.0);

            return Container(
              margin: EdgeInsets.symmetric(horizontal: 2.w),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: widget.size.w,
                  height: widget.size.h,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

/// Wave loading widget implementation
class _WaveLoadingWidget extends StatefulWidget {
  final Color color;
  final double size;
  final Duration duration;

  const _WaveLoadingWidget({
    required this.color,
    required this.size,
    required this.duration,
  });

  @override
  State<_WaveLoadingWidget> createState() => _WaveLoadingWidgetState();
}

class _WaveLoadingWidgetState extends State<_WaveLoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size.w,
      height: widget.size.h,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _WavePainter(
              color: widget.color,
              animationValue: _controller.value,
            ),
          );
        },
      ),
    );
  }
}

/// Wave painter for wave loading animation
class _WavePainter extends CustomPainter {
  final Color color;
  final double animationValue;

  _WavePainter({required this.color, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final waveHeight = size.height * 0.2;
    final waveLength = size.width;
    final phase = animationValue * 2 * math.pi;

    path.moveTo(0, size.height);

    for (double x = 0; x <= size.width; x += 1) {
      final y =
          size.height -
          waveHeight *
              (1 +
                  0.5 *
                      math.sin(x / waveLength) *
                      math.sin(phase + x / waveLength * 2 * math.pi));
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Rotating indicator widget implementation
class _RotatingIndicatorWidget extends StatefulWidget {
  final Color color;
  final double size;
  final Duration duration;

  const _RotatingIndicatorWidget({
    required this.color,
    required this.size,
    required this.duration,
  });

  @override
  State<_RotatingIndicatorWidget> createState() =>
      _RotatingIndicatorWidgetState();
}

class _RotatingIndicatorWidgetState extends State<_RotatingIndicatorWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size.w,
      height: widget.size.h,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: _controller.value * 2 * math.pi,
            child: CustomPaint(painter: _RotatingPainter(color: widget.color)),
          );
        },
      ),
    );
  }
}

/// Rotating painter for rotating indicator
class _RotatingPainter extends CustomPainter {
  final Color color;

  _RotatingPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0,
      math.pi * 1.5,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
