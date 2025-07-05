import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Reusable loading widget
class LoadingWidget extends StatelessWidget {
  final String? message;
  final double? size;

  const LoadingWidget({
    super.key,
    this.message,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: size ?? 40.w,
          height: size ?? 40.h,
          child: CircularProgressIndicator(
            strokeWidth: 3.w,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        if (message != null) ...[
          SizedBox(height: 16.h),
          Text(
            message!,
            style: TextStyle(
              fontSize: 14.sp,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
