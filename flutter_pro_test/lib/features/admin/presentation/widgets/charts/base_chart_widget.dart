import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../shared/theme/app_colors.dart';
import 'chart_theme.dart';

/// Base chart widget that provides common functionality for all chart types
abstract class BaseChartWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final double? height;
  final double? width;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final bool showLegend;
  final List<LegendItem>? legendItems;
  final Widget? headerActions;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;

  const BaseChartWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.height,
    this.width,
    this.padding,
    this.margin,
    this.showLegend = false,
    this.legendItems,
    this.headerActions,
    this.isLoading = false,
    this.errorMessage,
    this.onRetry,
  });

  /// Build the actual chart widget - to be implemented by subclasses
  Widget buildChart(BuildContext context, Size chartSize);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      margin: margin ?? EdgeInsets.all(ChartTheme.defaultMargin),
      decoration: ChartTheme.chartContainerDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          Expanded(
            child: _buildContent(context),
          ),
          if (showLegend && legendItems != null && legendItems!.isNotEmpty)
            _buildLegend(),
        ],
      ),
    );
  }

  /// Build chart header with title and actions
  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(ChartTheme.defaultPadding),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: ChartTheme.chartTitleStyle,
                ),
                if (subtitle != null) ...[
                  SizedBox(height: 4.h),
                  Text(
                    subtitle!,
                    style: ChartTheme.chartSubtitleStyle,
                  ),
                ],
              ],
            ),
          ),
          if (headerActions != null) headerActions!,
        ],
      ),
    );
  }

  /// Build chart content with loading and error states
  Widget _buildContent(BuildContext context) {
    if (isLoading) {
      return _buildLoadingState();
    }

    if (errorMessage != null) {
      return _buildErrorState();
    }

    return Padding(
      padding: padding ?? ChartTheme.getResponsivePadding(
        Size(width ?? double.infinity, height ?? 300),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return buildChart(context, constraints.biggest);
        },
      ),
    );
  }

  /// Build loading state
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          SizedBox(height: 16.h),
          Text(
            'Loading chart data...',
            style: ChartTheme.chartSubtitleStyle,
          ),
        ],
      ),
    );
  }

  /// Build error state
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48.r,
            color: AppColors.error,
          ),
          SizedBox(height: 16.h),
          Text(
            'Failed to load chart',
            style: ChartTheme.chartTitleStyle.copyWith(
              color: AppColors.error,
            ),
          ),
          if (errorMessage != null) ...[
            SizedBox(height: 8.h),
            Text(
              errorMessage!,
              style: ChartTheme.chartSubtitleStyle,
              textAlign: TextAlign.center,
            ),
          ],
          if (onRetry != null) ...[
            SizedBox(height: 16.h),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build legend
  Widget _buildLegend() {
    return Container(
      padding: EdgeInsets.all(ChartTheme.defaultPadding),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.border.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Wrap(
        spacing: 16.w,
        runSpacing: 8.h,
        children: legendItems!.map((item) => _buildLegendItem(item)).toList(),
      ),
    );
  }

  /// Build individual legend item
  Widget _buildLegendItem(LegendItem item) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: ChartTheme.legendIndicatorSize,
          height: ChartTheme.legendIndicatorSize,
          decoration: BoxDecoration(
            color: item.color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          item.label,
          style: ChartTheme.legendTextStyle,
        ),
        if (item.value != null) ...[
          SizedBox(width: 4.w),
          Text(
            '(${item.value})',
            style: ChartTheme.legendTextStyle.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

/// Legend item data class
class LegendItem {
  final String label;
  final Color color;
  final String? value;

  const LegendItem({
    required this.label,
    required this.color,
    this.value,
  });
}

/// Chart data point for line and area charts
class ChartDataPoint {
  final double x;
  final double y;
  final String? label;
  final Map<String, dynamic>? metadata;

  const ChartDataPoint({
    required this.x,
    required this.y,
    this.label,
    this.metadata,
  });
}

/// Chart data series for multi-series charts
class ChartDataSeries {
  final String name;
  final List<ChartDataPoint> data;
  final Color color;
  final bool isVisible;

  const ChartDataSeries({
    required this.name,
    required this.data,
    required this.color,
    this.isVisible = true,
  });
}

/// Bar chart data point
class BarChartDataPoint {
  final String label;
  final double value;
  final Color? color;
  final Map<String, dynamic>? metadata;

  const BarChartDataPoint({
    required this.label,
    required this.value,
    this.color,
    this.metadata,
  });
}

/// Pie chart data point
class PieChartDataPoint {
  final String label;
  final double value;
  final Color color;
  final Map<String, dynamic>? metadata;

  const PieChartDataPoint({
    required this.label,
    required this.value,
    required this.color,
    this.metadata,
  });

  /// Calculate percentage of total
  double getPercentage(double total) {
    if (total == 0) return 0;
    return (value / total) * 100;
  }
}

/// Chart animation configuration
class ChartAnimation {
  final Duration duration;
  final Curve curve;
  final bool enabled;

  const ChartAnimation({
    this.duration = ChartTheme.animationDuration,
    this.curve = ChartTheme.animationCurve,
    this.enabled = true,
  });

  static const ChartAnimation none = ChartAnimation(
    duration: Duration.zero,
    enabled: false,
  );
}

/// Chart interaction configuration
class ChartInteraction {
  final bool enableTouch;
  final bool enableZoom;
  final bool enablePan;
  final Function(dynamic)? onTap;
  final Function(dynamic)? onLongPress;

  const ChartInteraction({
    this.enableTouch = true,
    this.enableZoom = false,
    this.enablePan = false,
    this.onTap,
    this.onLongPress,
  });
}

/// Chart export configuration
class ChartExport {
  final bool enabled;
  final List<ChartExportFormat> formats;
  final Function(ChartExportFormat)? onExport;

  const ChartExport({
    this.enabled = false,
    this.formats = const [ChartExportFormat.png],
    this.onExport,
  });
}

/// Chart export formats
enum ChartExportFormat {
  png,
  jpg,
  pdf,
  svg;

  String get displayName {
    switch (this) {
      case ChartExportFormat.png:
        return 'PNG Image';
      case ChartExportFormat.jpg:
        return 'JPEG Image';
      case ChartExportFormat.pdf:
        return 'PDF Document';
      case ChartExportFormat.svg:
        return 'SVG Vector';
    }
  }

  String get fileExtension {
    switch (this) {
      case ChartExportFormat.png:
        return '.png';
      case ChartExportFormat.jpg:
        return '.jpg';
      case ChartExportFormat.pdf:
        return '.pdf';
      case ChartExportFormat.svg:
        return '.svg';
    }
  }
}
