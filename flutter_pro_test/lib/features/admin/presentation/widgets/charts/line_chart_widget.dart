import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'base_chart_widget.dart';
import 'chart_theme.dart';

/// Reusable line chart widget with customizable styling and data
class LineChartWidget extends BaseChartWidget {
  final List<ChartDataSeries> dataSeries;
  final double? minY;
  final double? maxY;
  final double? minX;
  final double? maxX;
  final bool showDots;
  final bool showArea;
  final bool showGrid;
  final bool showBorder;
  final ChartAnimation animation;
  final ChartInteraction interaction;
  final Function(String)? bottomTitleBuilder;
  final Function(double)? leftTitleBuilder;

  const LineChartWidget({
    super.key,
    required super.title,
    required this.dataSeries,
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
    this.minY,
    this.maxY,
    this.minX,
    this.maxX,
    this.showDots = true,
    this.showArea = false,
    this.showGrid = true,
    this.showBorder = true,
    this.animation = const ChartAnimation(),
    this.interaction = const ChartInteraction(),
    this.bottomTitleBuilder,
    this.leftTitleBuilder,
  });

  @override
  List<LegendItem> get legendItems {
    return dataSeries
        .where((series) => series.isVisible)
        .map((series) => LegendItem(
              label: series.name,
              color: series.color,
              value: series.data.isNotEmpty 
                  ? series.data.last.y.toStringAsFixed(1)
                  : null,
            ))
        .toList();
  }

  @override
  Widget buildChart(BuildContext context, Size chartSize) {
    if (dataSeries.isEmpty || dataSeries.every((series) => series.data.isEmpty)) {
      return _buildEmptyState();
    }

    return LineChart(
      _buildLineChartData(),
      duration: animation.enabled ? animation.duration : Duration.zero,
      curve: animation.curve,
    );
  }

  /// Build line chart data
  LineChartData _buildLineChartData() {
    return LineChartData(
      gridData: showGrid ? ChartTheme.defaultGridData : const FlGridData(show: false),
      titlesData: _buildTitlesData(),
      borderData: showBorder ? ChartTheme.defaultBorderData : FlBorderData(show: false),
      minX: minX ?? _calculateMinX(),
      maxX: maxX ?? _calculateMaxX(),
      minY: minY ?? _calculateMinY(),
      maxY: maxY ?? _calculateMaxY(),
      lineBarsData: _buildLineBarsData(),
      lineTouchData: interaction.enableTouch ? ChartTheme.defaultLineTouchData : LineTouchData(enabled: false),
    );
  }

  /// Build titles data with custom builders
  FlTitlesData _buildTitlesData() {
    return FlTitlesData(
      show: true,
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          interval: _calculateBottomInterval(),
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
    if (bottomTitleBuilder != null) {
      return SideTitleWidget(
        axisSide: meta.axisSide,
        child: Text(
          bottomTitleBuilder!(value.toString()),
          style: TextStyle(
            color: ChartTheme.defaultTitlesData.bottomTitles.axisNameWidget != null
                ? (ChartTheme.defaultTitlesData.bottomTitles.axisNameWidget as Text).style?.color
                : Colors.grey,
            fontSize: 12,
          ),
        ),
      );
    }
    return ChartTheme.defaultBottomTitleWidget(value, meta);
  }

  /// Build left title widget
  Widget _buildLeftTitle(double value, TitleMeta meta) {
    if (leftTitleBuilder != null) {
      return SideTitleWidget(
        axisSide: meta.axisSide,
        child: Text(
          leftTitleBuilder!(value),
          style: TextStyle(
            color: ChartTheme.defaultTitlesData.leftTitles.axisNameWidget != null
                ? (ChartTheme.defaultTitlesData.leftTitles.axisNameWidget as Text).style?.color
                : Colors.grey,
            fontSize: 12,
          ),
        ),
      );
    }
    return ChartTheme.defaultLeftTitleWidget(value, meta);
  }

  /// Build line bars data
  List<LineChartBarData> _buildLineBarsData() {
    return dataSeries
        .where((series) => series.isVisible)
        .map((series) => _buildLineChartBarData(series))
        .toList();
  }

  /// Build individual line chart bar data
  LineChartBarData _buildLineChartBarData(ChartDataSeries series) {
    return LineChartBarData(
      spots: series.data
          .map((point) => FlSpot(point.x, point.y))
          .toList(),
      color: series.color,
      barWidth: ChartTheme.defaultStrokeWidth,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: showDots,
        getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
          radius: ChartTheme.defaultDotSize,
          color: series.color,
          strokeWidth: 2,
          strokeColor: Colors.white,
        ),
      ),
      belowBarData: showArea ? BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors: ChartTheme.getGradientColors(series.color),
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ) : BarAreaData(show: false),
    );
  }

  /// Calculate minimum X value
  double _calculateMinX() {
    if (dataSeries.isEmpty) return 0;
    return dataSeries
        .where((series) => series.isVisible && series.data.isNotEmpty)
        .map((series) => series.data.map((point) => point.x).reduce((a, b) => a < b ? a : b))
        .reduce((a, b) => a < b ? a : b);
  }

  /// Calculate maximum X value
  double _calculateMaxX() {
    if (dataSeries.isEmpty) return 10;
    return dataSeries
        .where((series) => series.isVisible && series.data.isNotEmpty)
        .map((series) => series.data.map((point) => point.x).reduce((a, b) => a > b ? a : b))
        .reduce((a, b) => a > b ? a : b);
  }

  /// Calculate minimum Y value
  double _calculateMinY() {
    if (dataSeries.isEmpty) return 0;
    final minValue = dataSeries
        .where((series) => series.isVisible && series.data.isNotEmpty)
        .map((series) => series.data.map((point) => point.y).reduce((a, b) => a < b ? a : b))
        .reduce((a, b) => a < b ? a : b);
    return minValue * 0.9; // Add 10% padding
  }

  /// Calculate maximum Y value
  double _calculateMaxY() {
    if (dataSeries.isEmpty) return 10;
    final maxValue = dataSeries
        .where((series) => series.isVisible && series.data.isNotEmpty)
        .map((series) => series.data.map((point) => point.y).reduce((a, b) => a > b ? a : b))
        .reduce((a, b) => a > b ? a : b);
    return maxValue * 1.1; // Add 10% padding
  }

  /// Calculate bottom axis interval
  double? _calculateBottomInterval() {
    final range = _calculateMaxX() - _calculateMinX();
    if (range <= 10) return 1;
    if (range <= 50) return 5;
    if (range <= 100) return 10;
    return range / 10;
  }

  /// Calculate left axis interval
  double? _calculateLeftInterval() {
    final range = _calculateMaxY() - _calculateMinY();
    if (range <= 10) return 1;
    if (range <= 50) return 5;
    if (range <= 100) return 10;
    return range / 5;
  }

  /// Build empty state
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.show_chart,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No data available',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// Create sample data for testing
  static LineChartWidget sample({
    String title = 'Sample Line Chart',
    String? subtitle,
  }) {
    final sampleData = [
      ChartDataSeries(
        name: 'Revenue',
        color: ChartTheme.primaryColors[0],
        data: List.generate(12, (index) {
          return ChartDataPoint(
            x: index.toDouble(),
            y: 1000 + (index * 200) + (index % 3 * 100),
          );
        }),
      ),
      ChartDataSeries(
        name: 'Profit',
        color: ChartTheme.primaryColors[1],
        data: List.generate(12, (index) {
          return ChartDataPoint(
            x: index.toDouble(),
            y: 800 + (index * 150) + (index % 4 * 80),
          );
        }),
      ),
    ];

    return LineChartWidget(
      title: title,
      subtitle: subtitle,
      dataSeries: sampleData,
      height: 300,
      showArea: true,
    );
  }
}
