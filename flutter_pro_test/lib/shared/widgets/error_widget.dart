import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Reusable error widget
class CustomErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData? icon;

  const CustomErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon ?? Icons.error_outline,
            size: 64.w,
            color: Theme.of(context).colorScheme.error,
          ),
          SizedBox(height: 16.h),
          Text(
            'Oops! Something went wrong',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            message,
            style: TextStyle(
              fontSize: 14.sp,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
