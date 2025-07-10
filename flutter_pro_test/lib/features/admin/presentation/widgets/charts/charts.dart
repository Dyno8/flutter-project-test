/// Chart library for CareNow Admin Dashboard
///
/// This library provides a comprehensive set of reusable chart components
/// with consistent theming and styling for data visualization.
///
/// Available chart types:
/// - Line Chart: For trend analysis and time series data
/// - Bar Chart: For categorical data comparison
/// - Pie Chart: For part-to-whole relationships
/// - Area Chart: For cumulative data visualization
/// - Donut Chart: For part-to-whole with center content
///
/// All charts support:
/// - Responsive design
/// - Custom theming
/// - Interactive features
/// - Loading and error states
/// - Export functionality
/// - Animation and transitions

library;

// Base components
export 'base_chart_widget.dart';
export 'chart_theme.dart';

// Chart widgets
export 'line_chart_widget.dart';
export 'bar_chart_widget.dart';
export 'pie_chart_widget.dart';
export 'area_chart_widget.dart';

// Chart utilities and helpers
import 'package:flutter/material.dart';
import 'chart_theme.dart';
import 'base_chart_widget.dart';
import 'line_chart_widget.dart';
import 'bar_chart_widget.dart';
import 'pie_chart_widget.dart';
import 'area_chart_widget.dart';

/// Chart factory for creating common chart configurations
class ChartFactory {
  /// Create a revenue trend line chart
  static Widget revenueTrendChart({
    required String title,
    required List<ChartDataPoint> data,
    String? subtitle,
    double? height,
  }) {
    return LineChartWidget(
      title: title,
      subtitle: subtitle,
      height: height ?? 300,
      dataSeries: [
        ChartDataSeries(
          name: 'Revenue',
          data: data,
          color: ChartTheme.primaryColors[0],
        ),
      ],
      showArea: true,
      showDots: true,
    );
  }

  /// Create a service distribution pie chart
  static Widget serviceDistributionChart({
    required String title,
    required List<PieChartDataPoint> data,
    String? subtitle,
    double? height,
  }) {
    return PieChartWidget(
      title: title,
      subtitle: subtitle,
      height: height ?? 300,
      data: data,
      showPercentages: true,
      showLegend: true,
    );
  }

  /// Create a monthly comparison bar chart
  static Widget monthlyComparisonChart({
    required String title,
    required List<BarChartDataPoint> data,
    String? subtitle,
    double? height,
  }) {
    return BarChartWidget(
      title: title,
      subtitle: subtitle,
      height: height ?? 300,
      data: data,
      showValues: true,
      showGrid: true,
    );
  }

  /// Create a performance donut chart
  static Widget performanceDonutChart({
    required String title,
    required List<PieChartDataPoint> data,
    String? subtitle,
    double? height,
    Widget? centerWidget,
  }) {
    return DonutChartWidget(
      title: title,
      subtitle: subtitle,
      height: height ?? 300,
      data: data,
      centerWidget: centerWidget,
      showPercentages: true,
      showLegend: true,
    );
  }

  /// Create a growth area chart
  static Widget growthAreaChart({
    required String title,
    required List<ChartDataSeries> dataSeries,
    String? subtitle,
    double? height,
  }) {
    return AreaChartWidget(
      title: title,
      subtitle: subtitle,
      height: height ?? 300,
      dataSeries: dataSeries,
      style: AreaChartStyle.gradient,
      showLine: true,
    );
  }

  /// Create a KPI dashboard grid
  static Widget kpiDashboard({
    required List<KPICard> kpis,
    int crossAxisCount = 2,
    double childAspectRatio = 1.5,
  }) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: kpis.length,
      itemBuilder: (context, index) => kpis[index],
    );
  }
}

/// KPI Card widget for displaying key performance indicators
class KPICard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData? icon;
  final Color? color;
  final String? trend;
  final bool isPositiveTrend;
  final VoidCallback? onTap;

  const KPICard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    this.color,
    this.trend,
    this.isPositiveTrend = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: ChartTheme.chartContainerDecoration,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    color: color ?? ChartTheme.primaryColors[0],
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: ChartTheme.chartSubtitleStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: ChartTheme.chartTitleStyle.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color ?? ChartTheme.primaryColors[0],
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: ChartTheme.chartSubtitleStyle.copyWith(fontSize: 11),
              ),
            ],
            if (trend != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    isPositiveTrend ? Icons.trending_up : Icons.trending_down,
                    color: isPositiveTrend ? Colors.green : Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    trend!,
                    style: TextStyle(
                      color: isPositiveTrend ? Colors.green : Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Chart utilities for data processing and formatting
class ChartUtils {
  /// Format number for display
  static String formatNumber(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    } else if (value == value.toInt()) {
      return value.toInt().toString();
    } else {
      return value.toStringAsFixed(1);
    }
  }

  /// Format currency for display
  static String formatCurrency(double value, {String symbol = '\$'}) {
    return '$symbol${formatNumber(value)}';
  }

  /// Format percentage for display
  static String formatPercentage(double value) {
    return '${value.toStringAsFixed(1)}%';
  }

  /// Generate color palette for multiple data series
  static List<Color> generateColorPalette(int count) {
    if (count <= ChartTheme.extendedColors.length) {
      return ChartTheme.extendedColors.take(count).toList();
    }

    // Generate additional colors if needed
    final colors = <Color>[...ChartTheme.extendedColors];
    for (int i = ChartTheme.extendedColors.length; i < count; i++) {
      colors.add(
        HSVColor.fromAHSV(1.0, (i * 360 / count) % 360, 0.7, 0.8).toColor(),
      );
    }

    return colors;
  }

  /// Convert data to chart data points
  static List<ChartDataPoint> convertToChartData(
    Map<String, double> data, {
    bool sortByKey = true,
  }) {
    final entries = data.entries.toList();
    if (sortByKey) {
      entries.sort((a, b) => a.key.compareTo(b.key));
    }

    return entries.asMap().entries.map((entry) {
      return ChartDataPoint(
        x: entry.key.toDouble(),
        y: entry.value.value,
        label: entry.value.key,
      );
    }).toList();
  }

  /// Convert data to pie chart data points
  static List<PieChartDataPoint> convertToPieChartData(
    Map<String, double> data, {
    List<Color>? colors,
  }) {
    final colorPalette = colors ?? generateColorPalette(data.length);

    return data.entries.toList().asMap().entries.map((entry) {
      return PieChartDataPoint(
        label: entry.value.key,
        value: entry.value.value,
        color: colorPalette[entry.key % colorPalette.length],
      );
    }).toList();
  }

  /// Convert data to bar chart data points
  static List<BarChartDataPoint> convertToBarChartData(
    Map<String, double> data, {
    List<Color>? colors,
  }) {
    final colorPalette = colors ?? generateColorPalette(data.length);

    return data.entries.toList().asMap().entries.map((entry) {
      return BarChartDataPoint(
        label: entry.value.key,
        value: entry.value.value,
        color: colorPalette[entry.key % colorPalette.length],
      );
    }).toList();
  }

  /// Calculate trend percentage
  static double calculateTrend(double current, double previous) {
    if (previous == 0) return current > 0 ? 100 : 0;
    return ((current - previous) / previous) * 100;
  }

  /// Get trend display string
  static String getTrendDisplay(double trendPercentage) {
    final abs = trendPercentage.abs();
    final sign = trendPercentage >= 0 ? '+' : '-';
    return '$sign${abs.toStringAsFixed(1)}%';
  }
}

/// Chart export utilities
class ChartExportUtils {
  /// Export chart as image (placeholder implementation)
  static Future<void> exportAsImage(
    Widget chart, {
    String? fileName,
    ChartExportFormat format = ChartExportFormat.png,
  }) async {
    // Implementation would depend on the specific requirements
    // This is a placeholder for the export functionality
    throw UnimplementedError('Chart export functionality not implemented yet');
  }

  /// Export chart data as CSV
  static String exportAsCSV(List<ChartDataPoint> data) {
    final buffer = StringBuffer();
    buffer.writeln('X,Y,Label');

    for (final point in data) {
      buffer.writeln('${point.x},${point.y},${point.label ?? ''}');
    }

    return buffer.toString();
  }

  /// Export pie chart data as CSV
  static String exportPieChartAsCSV(List<PieChartDataPoint> data) {
    final buffer = StringBuffer();
    buffer.writeln('Label,Value,Percentage');

    final total = data.fold(0.0, (sum, point) => sum + point.value);

    for (final point in data) {
      final percentage = point.getPercentage(total);
      buffer.writeln(
        '${point.label},${point.value},${percentage.toStringAsFixed(2)}',
      );
    }

    return buffer.toString();
  }
}
