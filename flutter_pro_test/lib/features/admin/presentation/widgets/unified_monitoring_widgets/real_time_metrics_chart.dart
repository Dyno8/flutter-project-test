import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../shared/theme/app_colors.dart';
import '../../../../../shared/widgets/custom_card.dart';

/// Real-time metrics chart widget with live data updates
class RealTimeMetricsChart extends StatefulWidget {
  final String title;
  final List<MetricDataPoint> dataPoints;
  final String? unit;
  final double? maxValue;
  final Color? lineColor;
  final bool showGrid;
  final Duration animationDuration;

  const RealTimeMetricsChart({
    super.key,
    required this.title,
    required this.dataPoints,
    this.unit,
    this.maxValue,
    this.lineColor,
    this.showGrid = true,
    this.animationDuration = const Duration(milliseconds: 500),
  });

  @override
  State<RealTimeMetricsChart> createState() => _RealTimeMetricsChartState();
}

class _RealTimeMetricsChartState extends State<RealTimeMetricsChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  List<MetricDataPoint> _previousDataPoints = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _previousDataPoints = List.from(widget.dataPoints);
    _animationController.forward();
  }

  @override
  void didUpdateWidget(RealTimeMetricsChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dataPoints != widget.dataPoints) {
      _previousDataPoints = List.from(oldWidget.dataPoints);
      _animationController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: 16.h),
          SizedBox(
            height: 200.h,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return CustomPaint(
                  size: Size.infinite,
                  painter: MetricsChartPainter(
                    dataPoints: widget.dataPoints,
                    previousDataPoints: _previousDataPoints,
                    animationValue: _animation.value,
                    maxValue: widget.maxValue,
                    lineColor: widget.lineColor ?? AppColors.primary,
                    showGrid: widget.showGrid,
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 16.h),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final latestValue = widget.dataPoints.isNotEmpty 
        ? widget.dataPoints.last.value 
        : 0.0;
    final previousValue = _previousDataPoints.isNotEmpty 
        ? _previousDataPoints.last.value 
        : latestValue;
    final change = latestValue - previousValue;
    final changePercent = previousValue != 0 
        ? (change / previousValue * 100) 
        : 0.0;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 4.h),
              Row(
                children: [
                  Text(
                    latestValue.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: widget.lineColor ?? AppColors.primary,
                    ),
                  ),
                  if (widget.unit != null) ...[
                    SizedBox(width: 4.w),
                    Text(
                      widget.unit!,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        if (change != 0) _buildChangeIndicator(change, changePercent),
      ],
    );
  }

  Widget _buildChangeIndicator(double change, double changePercent) {
    final isPositive = change > 0;
    final color = isPositive ? AppColors.success : AppColors.error;
    final icon = isPositive ? Icons.trending_up : Icons.trending_down;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14.sp,
            color: color,
          ),
          SizedBox(width: 4.w),
          Text(
            '${changePercent.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    if (widget.dataPoints.isEmpty) return const SizedBox.shrink();

    final minValue = widget.dataPoints.map((p) => p.value).reduce((a, b) => a < b ? a : b);
    final maxValue = widget.dataPoints.map((p) => p.value).reduce((a, b) => a > b ? a : b);
    final avgValue = widget.dataPoints.map((p) => p.value).reduce((a, b) => a + b) / widget.dataPoints.length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildLegendItem('Min', minValue, AppColors.error),
        _buildLegendItem('Avg', avgValue, AppColors.warning),
        _buildLegendItem('Max', maxValue, AppColors.success),
      ],
    );
  }

  Widget _buildLegendItem(String label, double value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          value.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// Data point for metrics chart
class MetricDataPoint {
  final DateTime timestamp;
  final double value;
  final String? label;

  const MetricDataPoint({
    required this.timestamp,
    required this.value,
    this.label,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MetricDataPoint &&
          runtimeType == other.runtimeType &&
          timestamp == other.timestamp &&
          value == other.value;

  @override
  int get hashCode => timestamp.hashCode ^ value.hashCode;
}

/// Custom painter for the metrics chart
class MetricsChartPainter extends CustomPainter {
  final List<MetricDataPoint> dataPoints;
  final List<MetricDataPoint> previousDataPoints;
  final double animationValue;
  final double? maxValue;
  final Color lineColor;
  final bool showGrid;

  MetricsChartPainter({
    required this.dataPoints,
    required this.previousDataPoints,
    required this.animationValue,
    this.maxValue,
    required this.lineColor,
    required this.showGrid,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = lineColor.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // Calculate bounds
    final minValue = dataPoints.map((p) => p.value).reduce((a, b) => a < b ? a : b);
    final maxVal = maxValue ?? dataPoints.map((p) => p.value).reduce((a, b) => a > b ? a : b);
    final valueRange = maxVal - minValue;

    // Draw grid
    if (showGrid) {
      _drawGrid(canvas, size, gridPaint);
    }

    // Create path for line and fill
    final path = Path();
    final fillPath = Path();
    
    for (int i = 0; i < dataPoints.length; i++) {
      final x = (i / (dataPoints.length - 1)) * size.width;
      final normalizedValue = valueRange > 0 ? (dataPoints[i].value - minValue) / valueRange : 0.5;
      final y = size.height - (normalizedValue * size.height);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    // Complete fill path
    if (dataPoints.isNotEmpty) {
      fillPath.lineTo(size.width, size.height);
      fillPath.close();
    }

    // Apply animation
    final animatedPath = _createAnimatedPath(path, animationValue);
    final animatedFillPath = _createAnimatedPath(fillPath, animationValue);

    // Draw fill and line
    canvas.drawPath(animatedFillPath, fillPaint);
    canvas.drawPath(animatedPath, paint);

    // Draw data points
    _drawDataPoints(canvas, size, paint, minValue, valueRange);
  }

  void _drawGrid(Canvas canvas, Size size, Paint paint) {
    // Horizontal lines
    for (int i = 0; i <= 4; i++) {
      final y = (i / 4) * size.height;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Vertical lines
    for (int i = 0; i <= 4; i++) {
      final x = (i / 4) * size.width;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  void _drawDataPoints(Canvas canvas, Size size, Paint paint, double minValue, double valueRange) {
    final pointPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    for (int i = 0; i < dataPoints.length; i++) {
      final x = (i / (dataPoints.length - 1)) * size.width;
      final normalizedValue = valueRange > 0 ? (dataPoints[i].value - minValue) / valueRange : 0.5;
      final y = size.height - (normalizedValue * size.height);

      canvas.drawCircle(Offset(x, y), 3.0, pointPaint);
    }
  }

  Path _createAnimatedPath(Path originalPath, double animationValue) {
    final pathMetrics = originalPath.computeMetrics();
    final animatedPath = Path();

    for (final pathMetric in pathMetrics) {
      final extractPath = pathMetric.extractPath(
        0.0,
        pathMetric.length * animationValue,
      );
      animatedPath.addPath(extractPath, Offset.zero);
    }

    return animatedPath;
  }

  @override
  bool shouldRepaint(MetricsChartPainter oldDelegate) {
    return oldDelegate.dataPoints != dataPoints ||
           oldDelegate.animationValue != animationValue ||
           oldDelegate.lineColor != lineColor;
  }
}
