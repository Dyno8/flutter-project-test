import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../domain/entities/booking_analytics.dart';
import 'dashboard_card.dart';

/// Widget for displaying metrics charts
class MetricsChart extends StatelessWidget {
  final String title;
  final List<DailyBookingData> data;
  final String? subtitle;

  const MetricsChart({
    super.key,
    required this.title,
    required this.data,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ChartDashboardCard(
      title: title,
      subtitle: subtitle,
      chart: _buildChart(),
      actions: [
        IconButton(
          icon: Icon(
            Icons.more_vert,
            color: AppColors.textSecondary,
            size: 20.sp,
          ),
          onPressed: () {
            // Show chart options
          },
        ),
      ],
    );
  }

  Widget _buildChart() {
    if (data.isEmpty) {
      return _buildEmptyChart();
    }

    return Container(
      height: 200.h,
      child: CustomPaint(painter: LineChartPainter(data), child: Container()),
    );
  }

  Widget _buildEmptyChart() {
    return Container(
      height: 200.h,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.show_chart,
              size: 48.sp,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            SizedBox(height: 16.h),
            Text(
              'No data available',
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for line chart
class LineChartPainter extends CustomPainter {
  final List<DailyBookingData> data;

  LineChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    final maxValue = data
        .map((d) => d.totalBookings)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();

    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final y = size.height - (data[i].totalBookings / maxValue) * size.height;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Draw data points
    final pointPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final y = size.height - (data[i].totalBookings / maxValue) * size.height;
      canvas.drawCircle(Offset(x, y), 4.0, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
