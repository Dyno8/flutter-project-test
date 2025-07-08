import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../animations/loading_animations.dart';

/// Loading animation types
enum LoadingType { circular, dots, wave, rotating }

/// Reusable loading widget with enhanced animations
class LoadingWidget extends StatelessWidget {
  final String? message;
  final double? size;
  final LoadingType type;

  const LoadingWidget({
    super.key,
    this.message,
    this.size,
    this.type = LoadingType.circular,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLoadingIndicator(context),
        if (message != null) ...[
          SizedBox(height: 16.h),
          Text(
            message!,
            style: TextStyle(
              fontSize: 14.sp,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildLoadingIndicator(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final indicatorSize = size ?? 40.0;

    switch (type) {
      case LoadingType.circular:
        return SizedBox(
          width: indicatorSize.w,
          height: indicatorSize.h,
          child: CircularProgressIndicator(
            strokeWidth: 3.w,
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          ),
        );
      case LoadingType.dots:
        return LoadingAnimations.pulsingDots(
          color: primaryColor,
          size: indicatorSize / 5,
        );
      case LoadingType.wave:
        return LoadingAnimations.waveLoading(
          color: primaryColor,
          size: indicatorSize,
        );
      case LoadingType.rotating:
        return LoadingAnimations.rotatingIndicator(
          color: primaryColor,
          size: indicatorSize,
        );
    }
  }
}
