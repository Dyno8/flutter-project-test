import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../shared/animations/button_animations.dart';

/// Custom button widget for authentication screens with animations
class AuthButton extends StatelessWidget {
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

  const AuthButton({
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
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      isOutlined: isOutlined,
      backgroundColor: backgroundColor,
      textColor: textColor,
      width: width,
      height: height,
      icon: icon,
      animationType: animationType,
    );
  }
}
