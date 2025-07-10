import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'base_chart_widget.dart';
import 'chart_theme.dart';

/// Reusable bar chart widget with customizable styling and data
class BarChartWidget extends BaseChartWidget {
  final List<BarChartDataPoint> data;
  final double? maxY;
  final double? minY;
  final bool showGrid;
  final bool showBorder;
  final bool showValues;
  final BarChartOrientation orientation;
  final ChartAnimation animation;
  final ChartInteraction interaction;
  final Function(String)? bottomTitleBuilder;
  final Function(double)? leftTitleBuilder;

  const BarChartWidget({
    super.key,
    required super.title,
    required this.data,
    super.subtitle,
    super.height,
    super.width,
    super.padding,
    super.margin,
    super.showLegend = false,
    super.headerActions,
    super.isLoading = false,
    super.errorMessage,
    super.onRetry,
    this.maxY,
    this.minY,
    this.showGrid = true,
    this.showBorder = true,
    this.showValues = true,
    this.orientation = BarChartOrientation.vertical,
    this.animation = const ChartAnimation(),
    this.interaction = const ChartInteraction(),
    this.bottomTitleBuilder,
    this.leftTitleBuilder,
  });

  @override
  List<LegendItem>? get legendItems {
    if (!showLegend) return null;

    return data
        .map(
          (point) => LegendItem(
            label: point.label,
            color:
                point.color ?? ChartTheme.getColorByIndex(data.indexOf(point)),
            value: point.value.toStringAsFixed(1),
          ),
        )
        .toList();
  }

  @override
  Widget buildChart(BuildContext context, Size chartSize) {
    if (data.isEmpty) {
      return _buildEmptyState();
    }

    return BarChart(
      _buildBarChartData(),
      duration: animation.enabled ? animation.duration : Duration.zero,
      curve: animation.curve,
    );
  }

  /// Build bar chart data
  BarChartData _buildBarChartData() {
    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: maxY ?? _calculateMaxY(),
      minY: minY ?? 0,
      gridData: showGrid
          ? ChartTheme.defaultGridData
          : const FlGridData(show: false),
      titlesData: _buildTitlesData(),
      borderData: showBorder
          ? ChartTheme.defaultBorderData
          : FlBorderData(show: false),
      barGroups: _buildBarGroups(),
      barTouchData: interaction.enableTouch
          ? ChartTheme.defaultBarTouchData
          : BarTouchData(enabled: false),
    );
  }

  /// Build titles data
  FlTitlesData _buildTitlesData() {
    return FlTitlesData(
      show: true,
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          getTitlesWidget: (value, meta) => _buildBottomTitle(value, meta),
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 50,
          interval: _calculateLeftInterval(),
          getTitlesWidget: (value, meta) => _buildLeftTitle(value, meta),
        ),
      ),
    );
  }

  /// Build bottom title widget
  Widget _buildBottomTitle(double value, TitleMeta meta) {
    final index = value.toInt();
    if (index < 0 || index >= data.length) {
      return const SizedBox.shrink();
    }

    String title = data[index].label;
    if (bottomTitleBuilder != null) {
      title = bottomTitleBuilder!(title);
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Text(
          title,
          style: TextStyle(
            color:
                ChartTheme.defaultTitlesData.bottomTitles.axisNameWidget != null
                ? (ChartTheme.defaultTitlesData.bottomTitles.axisNameWidget
                          as Text)
                      .style
                      ?.color
                : Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  /// Build left title widget
  Widget _buildLeftTitle(double value, TitleMeta meta) {
    if (leftTitleBuilder != null) {
      return SideTitleWidget(
        axisSide: meta.axisSide,
        child: Text(
          leftTitleBuilder!(value),
          style: TextStyle(
            color:
                ChartTheme.defaultTitlesData.leftTitles.axisNameWidget != null
                ? (ChartTheme.defaultTitlesData.leftTitles.axisNameWidget
                          as Text)
                      .style
                      ?.color
                : Colors.grey,
            fontSize: 12,
          ),
        ),
      );
    }
    return ChartTheme.defaultLeftTitleWidget(value, meta);
  }

  /// Build bar groups
  List<BarChartGroupData> _buildBarGroups() {
    return data.asMap().entries.map((entry) {
      final index = entry.key;
      final point = entry.value;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: point.value,
            color: point.color ?? ChartTheme.getColorByIndex(index),
            width: ChartTheme.defaultBarWidth,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
            rodStackItems: showValues
                ? [
                    BarChartRodStackItem(
                      0,
                      point.value,
                      point.color ?? ChartTheme.getColorByIndex(index),
                    ),
                  ]
                : [],
          ),
        ],
        showingTooltipIndicators: showValues ? [0] : [],
      );
    }).toList();
  }

  /// Calculate maximum Y value
  double _calculateMaxY() {
    if (data.isEmpty) return 10;
    final maxValue = data
        .map((point) => point.value)
        .reduce((a, b) => a > b ? a : b);
    return maxValue * 1.2; // Add 20% padding
  }

  /// Calculate left axis interval
  double? _calculateLeftInterval() {
    final maxValue = _calculateMaxY();
    if (maxValue <= 10) return 1;
    if (maxValue <= 50) return 5;
    if (maxValue <= 100) return 10;
    return maxValue / 5;
  }

  /// Build empty state
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No data available',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  /// Create sample data for testing
  static BarChartWidget sample({
    String title = 'Sample Bar Chart',
    String? subtitle,
  }) {
    final sampleData = [
      BarChartDataPoint(label: 'Jan', value: 1200),
      BarChartDataPoint(label: 'Feb', value: 1800),
      BarChartDataPoint(label: 'Mar', value: 1500),
      BarChartDataPoint(label: 'Apr', value: 2200),
      BarChartDataPoint(label: 'May', value: 1900),
      BarChartDataPoint(label: 'Jun', value: 2500),
    ];

    return BarChartWidget(
      title: title,
      subtitle: subtitle,
      data: sampleData,
      height: 300,
      showValues: true,
    );
  }
}

/// Bar chart orientation
enum BarChartOrientation {
  vertical,
  horizontal;

  String get displayName {
    switch (this) {
      case BarChartOrientation.vertical:
        return 'Vertical';
      case BarChartOrientation.horizontal:
        return 'Horizontal';
    }
  }
}

/// Grouped bar chart widget for multiple data series
class GroupedBarChartWidget extends BaseChartWidget {
  final List<GroupedBarChartData> data;
  final double? maxY;
  final double? minY;
  final bool showGrid;
  final bool showBorder;
  final bool showValues;
  final ChartAnimation animation;
  final ChartInteraction interaction;
  final Function(String)? bottomTitleBuilder;
  final Function(double)? leftTitleBuilder;

  const GroupedBarChartWidget({
    super.key,
    required super.title,
    required this.data,
    super.subtitle,
    super.height,
    super.width,
    super.padding,
    super.margin,
    super.showLegend = true,
    super.headerActions,
    super.isLoading = false,
    super.errorMessage,
    super.onRetry,
    this.maxY,
    this.minY,
    this.showGrid = true,
    this.showBorder = true,
    this.showValues = true,
    this.animation = const ChartAnimation(),
    this.interaction = const ChartInteraction(),
    this.bottomTitleBuilder,
    this.leftTitleBuilder,
  });

  @override
  List<LegendItem>? get legendItems {
    if (!showLegend || data.isEmpty) return null;

    final seriesNames = data.first.values.keys.toList();
    return seriesNames.asMap().entries.map((entry) {
      final index = entry.key;
      final seriesName = entry.value;
      return LegendItem(
        label: seriesName,
        color: ChartTheme.getColorByIndex(index),
      );
    }).toList();
  }

  @override
  Widget buildChart(BuildContext context, Size chartSize) {
    if (data.isEmpty) {
      return _buildEmptyState();
    }

    return BarChart(
      _buildGroupedBarChartData(),
      duration: animation.enabled ? animation.duration : Duration.zero,
      curve: animation.curve,
    );
  }

  /// Build grouped bar chart data
  BarChartData _buildGroupedBarChartData() {
    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: maxY ?? _calculateMaxY(),
      minY: minY ?? 0,
      gridData: showGrid
          ? ChartTheme.defaultGridData
          : const FlGridData(show: false),
      titlesData: _buildTitlesData(),
      borderData: showBorder
          ? ChartTheme.defaultBorderData
          : FlBorderData(show: false),
      barGroups: _buildGroupedBarGroups(),
      barTouchData: interaction.enableTouch
          ? ChartTheme.defaultBarTouchData
          : BarTouchData(enabled: false),
    );
  }

  /// Build titles data for grouped bars
  FlTitlesData _buildTitlesData() {
    return FlTitlesData(
      show: true,
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          getTitlesWidget: (value, meta) =>
              _buildGroupedBottomTitle(value, meta),
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 50,
          interval: _calculateLeftInterval(),
          getTitlesWidget: (value, meta) =>
              ChartTheme.defaultLeftTitleWidget(value, meta),
        ),
      ),
    );
  }

  /// Build bottom title for grouped bars
  Widget _buildGroupedBottomTitle(double value, TitleMeta meta) {
    final index = value.toInt();
    if (index < 0 || index >= data.length) {
      return const SizedBox.shrink();
    }

    String title = data[index].label;
    if (bottomTitleBuilder != null) {
      title = bottomTitleBuilder!(title);
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Text(
          title,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  /// Build grouped bar groups
  List<BarChartGroupData> _buildGroupedBarGroups() {
    return data.asMap().entries.map((entry) {
      final index = entry.key;
      final groupData = entry.value;

      final barRods = groupData.values.entries.toList().asMap().entries.map((
        seriesEntry,
      ) {
        final seriesIndex = seriesEntry.key;
        final seriesData = seriesEntry.value.value;
        final seriesColor =
            seriesData.color ?? ChartTheme.getColorByIndex(seriesIndex);

        return BarChartRodData(
          toY: seriesData.value,
          color: seriesColor,
          width: 12,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(2),
            topRight: Radius.circular(2),
          ),
        );
      }).toList();

      return BarChartGroupData(x: index, barRods: barRods, barsSpace: 4);
    }).toList();
  }

  /// Calculate maximum Y value for grouped bars
  double _calculateMaxY() {
    if (data.isEmpty) return 10;
    double maxValue = 0;
    for (final group in data) {
      for (final series in group.values.values) {
        if (series.value > maxValue) {
          maxValue = series.value;
        }
      }
    }
    return maxValue * 1.2; // Add 20% padding
  }

  /// Calculate left axis interval
  double? _calculateLeftInterval() {
    final maxValue = _calculateMaxY();
    if (maxValue <= 10) return 1;
    if (maxValue <= 50) return 5;
    if (maxValue <= 100) return 10;
    return maxValue / 5;
  }

  /// Build empty state
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No data available',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

/// Grouped bar chart data point
class GroupedBarChartData {
  final String label;
  final Map<String, GroupedBarValue> values;

  const GroupedBarChartData({required this.label, required this.values});
}

/// Grouped bar value
class GroupedBarValue {
  final double value;
  final Color? color;

  const GroupedBarValue({required this.value, this.color});
}
