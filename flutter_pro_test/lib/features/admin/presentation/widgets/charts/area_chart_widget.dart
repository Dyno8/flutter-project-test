import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'base_chart_widget.dart';
import 'chart_theme.dart';

/// Reusable area chart widget with customizable styling and data
class AreaChartWidget extends BaseChartWidget {
  final List<ChartDataSeries> dataSeries;
  final double? minY;
  final double? maxY;
  final double? minX;
  final double? maxX;
  final bool showDots;
  final bool showGrid;
  final bool showBorder;
  final bool showLine;
  final AreaChartStyle style;
  final ChartAnimation animation;
  final ChartInteraction interaction;
  final Function(String)? bottomTitleBuilder;
  final Function(double)? leftTitleBuilder;

  const AreaChartWidget({
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
    this.showDots = false,
    this.showGrid = true,
    this.showBorder = true,
    this.showLine = true,
    this.style = AreaChartStyle.gradient,
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
      _buildAreaChartData(),
      duration: animation.enabled ? animation.duration : Duration.zero,
      curve: animation.curve,
    );
  }

  /// Build area chart data (using LineChart with area fill)
  LineChartData _buildAreaChartData() {
    return LineChartData(
      gridData: showGrid ? ChartTheme.defaultGridData : const FlGridData(show: false),
      titlesData: _buildTitlesData(),
      borderData: showBorder ? ChartTheme.defaultBorderData : FlBorderData(show: false),
      minX: minX ?? _calculateMinX(),
      maxX: maxX ?? _calculateMaxX(),
      minY: minY ?? _calculateMinY(),
      maxY: maxY ?? _calculateMaxY(),
      lineBarsData: _buildAreaBarsData(),
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
          style: const TextStyle(
            color: Colors.grey,
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
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      );
    }
    return ChartTheme.defaultLeftTitleWidget(value, meta);
  }

  /// Build area bars data
  List<LineChartBarData> _buildAreaBarsData() {
    return dataSeries
        .where((series) => series.isVisible)
        .map((series) => _buildAreaChartBarData(series))
        .toList();
  }

  /// Build individual area chart bar data
  LineChartBarData _buildAreaChartBarData(ChartDataSeries series) {
    return LineChartBarData(
      spots: series.data
          .map((point) => FlSpot(point.x, point.y))
          .toList(),
      color: showLine ? series.color : Colors.transparent,
      barWidth: showLine ? ChartTheme.defaultStrokeWidth : 0,
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
      belowBarData: _buildAreaData(series),
    );
  }

  /// Build area data based on style
  BarAreaData _buildAreaData(ChartDataSeries series) {
    switch (style) {
      case AreaChartStyle.solid:
        return BarAreaData(
          show: true,
          color: series.color.withOpacity(0.3),
        );
      case AreaChartStyle.gradient:
        return BarAreaData(
          show: true,
          gradient: LinearGradient(
            colors: ChartTheme.getGradientColors(series.color),
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        );
      case AreaChartStyle.pattern:
        // For pattern, we use a semi-transparent solid color
        // In a real implementation, you might use a custom painter for patterns
        return BarAreaData(
          show: true,
          color: series.color.withOpacity(0.2),
        );
    }
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
    return 0; // Area charts typically start from 0
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
            Icons.area_chart,
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
  static AreaChartWidget sample({
    String title = 'Sample Area Chart',
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
            y: 600 + (index * 120) + (index % 4 * 80),
          );
        }),
      ),
    ];

    return AreaChartWidget(
      title: title,
      subtitle: subtitle,
      dataSeries: sampleData,
      height: 300,
      style: AreaChartStyle.gradient,
    );
  }
}

/// Area chart styles
enum AreaChartStyle {
  solid,
  gradient,
  pattern;

  String get displayName {
    switch (this) {
      case AreaChartStyle.solid:
        return 'Solid';
      case AreaChartStyle.gradient:
        return 'Gradient';
      case AreaChartStyle.pattern:
        return 'Pattern';
    }
  }
}

/// Stacked area chart widget for cumulative data visualization
class StackedAreaChartWidget extends BaseChartWidget {
  final List<ChartDataSeries> dataSeries;
  final double? minY;
  final double? maxY;
  final double? minX;
  final double? maxX;
  final bool showGrid;
  final bool showBorder;
  final ChartAnimation animation;
  final ChartInteraction interaction;
  final Function(String)? bottomTitleBuilder;
  final Function(double)? leftTitleBuilder;

  const StackedAreaChartWidget({
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
            ))
        .toList();
  }

  @override
  Widget buildChart(BuildContext context, Size chartSize) {
    if (dataSeries.isEmpty || dataSeries.every((series) => series.data.isEmpty)) {
      return _buildEmptyState();
    }

    return LineChart(
      _buildStackedAreaChartData(),
      duration: animation.enabled ? animation.duration : Duration.zero,
      curve: animation.curve,
    );
  }

  /// Build stacked area chart data
  LineChartData _buildStackedAreaChartData() {
    return LineChartData(
      gridData: showGrid ? ChartTheme.defaultGridData : const FlGridData(show: false),
      titlesData: _buildTitlesData(),
      borderData: showBorder ? ChartTheme.defaultBorderData : FlBorderData(show: false),
      minX: minX ?? _calculateMinX(),
      maxX: maxX ?? _calculateMaxX(),
      minY: minY ?? 0,
      maxY: maxY ?? _calculateStackedMaxY(),
      lineBarsData: _buildStackedAreaBarsData(),
      lineTouchData: interaction.enableTouch ? ChartTheme.defaultLineTouchData : LineTouchData(enabled: false),
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
          reservedSize: 30,
          getTitlesWidget: (value, meta) => bottomTitleBuilder != null
              ? SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(bottomTitleBuilder!(value.toString())),
                )
              : ChartTheme.defaultBottomTitleWidget(value, meta),
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 50,
          getTitlesWidget: (value, meta) => leftTitleBuilder != null
              ? SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(leftTitleBuilder!(value)),
                )
              : ChartTheme.defaultLeftTitleWidget(value, meta),
        ),
      ),
    );
  }

  /// Build stacked area bars data
  List<LineChartBarData> _buildStackedAreaBarsData() {
    final stackedData = _calculateStackedData();
    
    return stackedData.asMap().entries.map((entry) {
      final index = entry.key;
      final series = entry.value;
      
      return LineChartBarData(
        spots: series.data.map((point) => FlSpot(point.x, point.y)).toList(),
        color: Colors.transparent, // No line for stacked areas
        barWidth: 0,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          color: dataSeries[index].color.withOpacity(0.8),
        ),
      );
    }).toList();
  }

  /// Calculate stacked data (cumulative values)
  List<ChartDataSeries> _calculateStackedData() {
    if (dataSeries.isEmpty) return [];
    
    final stackedSeries = <ChartDataSeries>[];
    final visibleSeries = dataSeries.where((series) => series.isVisible).toList();
    
    for (int i = 0; i < visibleSeries.length; i++) {
      final currentSeries = visibleSeries[i];
      final stackedData = <ChartDataPoint>[];
      
      for (int j = 0; j < currentSeries.data.length; j++) {
        final currentPoint = currentSeries.data[j];
        double stackedValue = currentPoint.y;
        
        // Add values from previous series
        for (int k = 0; k < i; k++) {
          if (j < visibleSeries[k].data.length) {
            stackedValue += visibleSeries[k].data[j].y;
          }
        }
        
        stackedData.add(ChartDataPoint(
          x: currentPoint.x,
          y: stackedValue,
          label: currentPoint.label,
          metadata: currentPoint.metadata,
        ));
      }
      
      stackedSeries.add(ChartDataSeries(
        name: currentSeries.name,
        data: stackedData,
        color: currentSeries.color,
        isVisible: currentSeries.isVisible,
      ));
    }
    
    return stackedSeries;
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

  /// Calculate maximum Y value for stacked data
  double _calculateStackedMaxY() {
    final stackedData = _calculateStackedData();
    if (stackedData.isEmpty) return 10;
    
    final maxValue = stackedData.last.data
        .map((point) => point.y)
        .reduce((a, b) => a > b ? a : b);
    return maxValue * 1.1; // Add 10% padding
  }

  /// Build empty state
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.stacked_line_chart,
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
}
