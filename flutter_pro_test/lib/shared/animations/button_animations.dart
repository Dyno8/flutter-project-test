import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Button animation types
enum ButtonAnimationType {
  scale,
  ripple,
  shake,
  bounce,
}

/// Animated button widget with various animation effects
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
    if (widget.animationType == ButtonAnimationType.scale) {
      _scaleController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.animationType == ButtonAnimationType.scale) {
      _scaleController.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.animationType == ButtonAnimationType.scale) {
      _scaleController.reverse();
    }
  }

  void _onTap() {
    if (widget.onPressed == null || widget.isLoading) return;

    switch (widget.animationType) {
      case ButtonAnimationType.ripple:
        _rippleController.forward().then((_) {
          _rippleController.reverse();
        });
        break;
      case ButtonAnimationType.shake:
        _shakeController.forward().then((_) {
          _shakeController.reverse();
        });
        break;
      case ButtonAnimationType.bounce:
        _scaleController.forward().then((_) {
          _scaleController.reverse();
        });
        break;
      case ButtonAnimationType.scale:
        // Scale animation is handled in tap down/up
        break;
    }

    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    return AnimatedBuilder(
      animation: Listenable.merge([
        _scaleAnimation,
        _rippleAnimation,
        _shakeAnimation,
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale: widget.animationType == ButtonAnimationType.scale
              ? _scaleAnimation.value
              : 1.0,
          child: Transform.translate(
            offset: widget.animationType == ButtonAnimationType.shake
                ? Offset(_shakeAnimation.value * 10 * (1 - _shakeAnimation.value), 0)
                : Offset.zero,
            child: GestureDetector(
              onTapDown: isEnabled ? _onTapDown : null,
              onTapUp: isEnabled ? _onTapUp : null,
              onTapCancel: isEnabled ? _onTapCancel : null,
              onTap: isEnabled ? _onTap : null,
              child: Container(
                width: widget.width ?? double.infinity,
                height: widget.height ?? 48.h,
                decoration: BoxDecoration(
                  color: widget.isOutlined
                      ? Colors.transparent
                      : (widget.backgroundColor ?? theme.colorScheme.primary),
                  border: widget.isOutlined
                      ? Border.all(
                          color: widget.backgroundColor ?? theme.colorScheme.primary,
                          width: 1.5,
                        )
                      : null,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Stack(
                  children: [
                    // Ripple effect
                    if (widget.animationType == ButtonAnimationType.ripple)
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: AnimatedBuilder(
                            animation: _rippleAnimation,
                            builder: (context, child) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(
                                    alpha: 0.3 * _rippleAnimation.value,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    
                    // Button content
                    Center(
                      child: widget.isLoading
                          ? SizedBox(
                              width: 20.w,
                              height: 20.h,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  widget.isOutlined
                                      ? (widget.textColor ?? theme.colorScheme.primary)
                                      : (widget.textColor ?? theme.colorScheme.onPrimary),
                                ),
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (widget.icon != null) ...[
                                  widget.icon!,
                                  SizedBox(width: 8.w),
                                ],
                                Text(
                                  widget.text,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: widget.isOutlined
                                        ? (widget.textColor ?? theme.colorScheme.primary)
                                        : (widget.textColor ?? theme.colorScheme.onPrimary),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
