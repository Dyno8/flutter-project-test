import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Enhanced button widgets with smooth animations and micro-interactions
class AnimatedButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final Widget? icon;
  final ButtonAnimationType animationType;
  final Duration animationDuration;

  const AnimatedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.icon,
    this.animationType = ButtonAnimationType.scale,
    this.animationDuration = const Duration(milliseconds: 150),
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rippleController;
  late AnimationController _shakeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rippleAnimation;
  late Animation<double> _shakeAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );

    _shakeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rippleController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);

    switch (widget.animationType) {
      case ButtonAnimationType.scale:
        _scaleController.forward();
        break;
      case ButtonAnimationType.ripple:
        _rippleController.forward();
        break;
      case ButtonAnimationType.bounce:
        _scaleController.forward();
        break;
      case ButtonAnimationType.shake:
        // Shake animation is triggered on tap, not tap down
        break;
    }

    // Haptic feedback
    HapticFeedback.lightImpact();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);

    switch (widget.animationType) {
      case ButtonAnimationType.scale:
        _scaleController.reverse();
        break;
      case ButtonAnimationType.ripple:
        _rippleController.reverse();
        break;
      case ButtonAnimationType.bounce:
        _scaleController.reverse().then((_) {
          _scaleController.forward().then((_) {
            _scaleController.reverse();
          });
        });
        break;
      case ButtonAnimationType.shake:
        _shakeController.forward().then((_) {
          _shakeController.reset();
        });
        break;
    }
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _scaleController.reverse();
    _rippleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: Listenable.merge([
        _scaleAnimation,
        _rippleAnimation,
        _shakeAnimation,
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale:
              widget.animationType == ButtonAnimationType.scale ||
                  widget.animationType == ButtonAnimationType.bounce
              ? _scaleAnimation.value
              : 1.0,
          child: Transform.translate(
            offset: widget.animationType == ButtonAnimationType.shake
                ? Offset(
                    _shakeAnimation.value * 10 * (1 - _shakeAnimation.value),
                    0,
                  )
                : Offset.zero,
            child: SizedBox(
              width: widget.width ?? double.infinity,
              height: widget.height ?? 56.h,
              child: Stack(
                children: [
                  // Main button
                  widget.isOutlined
                      ? _buildOutlinedButton(theme)
                      : _buildElevatedButton(theme),

                  // Ripple effect overlay
                  if (widget.animationType == ButtonAnimationType.ripple)
                    _buildRippleOverlay(theme),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildElevatedButton(ThemeData theme) {
    return GestureDetector(
      onTapDown: widget.onPressed != null ? _onTapDown : null,
      onTapUp: widget.onPressed != null ? _onTapUp : null,
      onTapCancel: widget.onPressed != null ? _onTapCancel : null,
      child: ElevatedButton(
        onPressed: widget.isLoading ? null : widget.onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.backgroundColor ?? theme.colorScheme.primary,
          foregroundColor: widget.textColor ?? theme.colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: _isPressed ? 1 : 2,
          shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.2),
        ),
        child: _buildButtonContent(theme),
      ),
    );
  }

  Widget _buildOutlinedButton(ThemeData theme) {
    return GestureDetector(
      onTapDown: widget.onPressed != null ? _onTapDown : null,
      onTapUp: widget.onPressed != null ? _onTapUp : null,
      onTapCancel: widget.onPressed != null ? _onTapCancel : null,
      child: OutlinedButton(
        onPressed: widget.isLoading ? null : widget.onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: widget.backgroundColor ?? theme.colorScheme.primary,
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          backgroundColor: _isPressed
              ? (widget.backgroundColor ?? theme.colorScheme.primary)
                    .withValues(alpha: 0.1)
              : Colors.transparent,
        ),
        child: _buildButtonContent(theme),
      ),
    );
  }

  Widget _buildButtonContent(ThemeData theme) {
    if (widget.isLoading) {
      return SizedBox(
        width: 24.w,
        height: 24.h,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            widget.isOutlined
                ? (widget.backgroundColor ?? theme.colorScheme.primary)
                : (widget.textColor ?? theme.colorScheme.onPrimary),
          ),
        ),
      );
    }

    if (widget.icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          widget.icon!,
          SizedBox(width: 8.w),
          Text(
            widget.text,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: widget.isOutlined
                  ? (widget.backgroundColor ?? theme.colorScheme.primary)
                  : (widget.textColor ?? theme.colorScheme.onPrimary),
            ),
          ),
        ],
      );
    }

    return Text(
      widget.text,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: widget.isOutlined
            ? (widget.backgroundColor ?? theme.colorScheme.primary)
            : (widget.textColor ?? theme.colorScheme.onPrimary),
      ),
    );
  }

  Widget _buildRippleOverlay(ThemeData theme) {
    return Positioned.fill(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: AnimatedBuilder(
          animation: _rippleAnimation,
          builder: (context, child) {
            return CustomPaint(
              painter: RipplePainter(
                animation: _rippleAnimation,
                color: (widget.backgroundColor ?? theme.colorScheme.primary)
                    .withValues(alpha: 0.3),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Button animation types
enum ButtonAnimationType { scale, ripple, bounce, shake }

/// Custom painter for ripple effect
class RipplePainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;

  RipplePainter({required this.animation, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (animation.value > 0) {
      final center = Offset(size.width / 2, size.height / 2);
      final radius = size.width * animation.value;

      final paint = Paint()
        ..color = color.withValues(alpha: color.a * (1 - animation.value))
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(RipplePainter oldDelegate) {
    return animation.value != oldDelegate.animation.value;
  }
}

/// Floating Action Button with enhanced animations
class AnimatedFAB extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color? backgroundColor;
  final double? elevation;
  final FABAnimationType animationType;

  const AnimatedFAB({
    super.key,
    this.onPressed,
    required this.child,
    this.backgroundColor,
    this.elevation,
    this.animationType = FABAnimationType.scale,
  });

  @override
  State<AnimatedFAB> createState() => _AnimatedFABState();
}

class _AnimatedFABState extends State<AnimatedFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
    HapticFeedback.lightImpact();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.animationType == FABAnimationType.scale
              ? _scaleAnimation.value
              : 1.0,
          child: Transform.rotate(
            angle: widget.animationType == FABAnimationType.rotate
                ? _rotationAnimation.value
                : 0.0,
            child: FloatingActionButton(
              onPressed: widget.onPressed,
              backgroundColor: widget.backgroundColor,
              elevation: widget.elevation,
              child: GestureDetector(
                onTapDown: _onTapDown,
                onTapUp: _onTapUp,
                onTapCancel: _onTapCancel,
                child: widget.child,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// FAB animation types
enum FABAnimationType { scale, rotate }
