import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'base_chart_widget.dart';
import 'chart_theme.dart';

/// Reusable pie chart widget with customizable styling and data
class PieChartWidget extends BaseChartWidget {
  final List<PieChartDataPoint> data;
  final double radius;
  final double centerSpaceRadius;
  final bool showPercentages;
  final bool showValues;
  final bool showLabels;
  final PieChartStyle style;
  final ChartAnimation animation;
  final ChartInteraction interaction;

  const PieChartWidget({
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
    this.radius = 80,
    this.centerSpaceRadius = 0,
    this.showPercentages = true,
    this.showValues = false,
    this.showLabels = true,
    this.style = PieChartStyle.normal,
    this.animation = const ChartAnimation(),
    this.interaction = const ChartInteraction(),
  });

  @override
  List<LegendItem>? get legendItems {
    if (!showLegend) return null;
    
    final total = _calculateTotal();
    return data.map((point) => LegendItem(
      label: point.label,
      color: point.color,
      value: showPercentages 
          ? '${point.getPercentage(total).toStringAsFixed(1)}%'
          : point.value.toStringAsFixed(1),
    )).toList();
  }

  @override
  Widget buildChart(BuildContext context, Size chartSize) {
    if (data.isEmpty) {
      return _buildEmptyState();
    }

    return PieChart(
      _buildPieChartData(),
      duration: animation.enabled ? animation.duration : Duration.zero,
      curve: animation.curve,
    );
  }

  /// Build pie chart data
  PieChartData _buildPieChartData() {
    return PieChartData(
      sections: _buildPieSections(),
      centerSpaceRadius: centerSpaceRadius,
      sectionsSpace: style == PieChartStyle.separated ? 4 : 0,
      pieTouchData: interaction.enableTouch ? ChartTheme.defaultPieTouchData : PieTouchData(enabled: false),
      startDegreeOffset: 0,
    );
  }

  /// Build pie chart sections
  List<PieChartSectionData> _buildPieSections() {
    final total = _calculateTotal();
    
    return data.map((point) {
      final percentage = point.getPercentage(total);
      String title = '';
      
      if (showLabels) {
        if (showPercentages && showValues) {
          title = '${point.label}\n${percentage.toStringAsFixed(1)}%\n${point.value.toStringAsFixed(1)}';
        } else if (showPercentages) {
          title = '${point.label}\n${percentage.toStringAsFixed(1)}%';
        } else if (showValues) {
          title = '${point.label}\n${point.value.toStringAsFixed(1)}';
        } else {
          title = point.label;
        }
      } else if (showPercentages) {
        title = '${percentage.toStringAsFixed(1)}%';
      } else if (showValues) {
        title = point.value.toStringAsFixed(1);
      }

      return PieChartSectionData(
        color: point.color,
        value: point.value,
        title: title,
        radius: radius,
        titleStyle: _getTitleStyle(percentage),
        titlePositionPercentageOffset: 0.6,
        borderSide: style == PieChartStyle.outlined 
            ? BorderSide(color: Colors.white, width: 2)
            : BorderSide.none,
      );
    }).toList();
  }

  /// Get title style based on section size
  TextStyle _getTitleStyle(double percentage) {
    // Hide text for very small sections
    if (percentage < 5) {
      return const TextStyle(fontSize: 0, color: Colors.transparent);
    }
    
    return TextStyle(
      fontSize: percentage < 10 ? 10 : 12,
      fontWeight: FontWeight.bold,
      color: Colors.white,
      shadows: [
        Shadow(
          color: Colors.black.withOpacity(0.5),
          offset: const Offset(1, 1),
          blurRadius: 2,
        ),
      ],
    );
  }

  /// Calculate total value
  double _calculateTotal() {
    return data.fold(0, (sum, point) => sum + point.value);
  }

  /// Build empty state
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pie_chart,
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
  static PieChartWidget sample({
    String title = 'Sample Pie Chart',
    String? subtitle,
  }) {
    final sampleData = [
      PieChartDataPoint(
        label: 'Home Cleaning',
        value: 45,
        color: ChartTheme.primaryColors[0],
      ),
      PieChartDataPoint(
        label: 'Plumbing',
        value: 25,
        color: ChartTheme.primaryColors[1],
      ),
      PieChartDataPoint(
        label: 'Electrical',
        value: 20,
        color: ChartTheme.primaryColors[2],
      ),
      PieChartDataPoint(
        label: 'Gardening',
        value: 10,
        color: ChartTheme.primaryColors[3],
      ),
    ];

    return PieChartWidget(
      title: title,
      subtitle: subtitle,
      data: sampleData,
      height: 300,
      showPercentages: true,
    );
  }
}

/// Pie chart styles
enum PieChartStyle {
  normal,
  separated,
  outlined;

  String get displayName {
    switch (this) {
      case PieChartStyle.normal:
        return 'Normal';
      case PieChartStyle.separated:
        return 'Separated';
      case PieChartStyle.outlined:
        return 'Outlined';
    }
  }
}

/// Donut chart widget (pie chart with center space)
class DonutChartWidget extends PieChartWidget {
  final Widget? centerWidget;

  const DonutChartWidget({
    super.key,
    required super.title,
    required super.data,
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
    super.radius = 80,
    double centerSpaceRadius = 40,
    super.showPercentages = true,
    super.showValues = false,
    super.showLabels = false, // Usually false for donut charts
    super.style = PieChartStyle.normal,
    super.animation = const ChartAnimation(),
    super.interaction = const ChartInteraction(),
    this.centerWidget,
  }) : super(centerSpaceRadius: centerSpaceRadius);

  @override
  Widget buildChart(BuildContext context, Size chartSize) {
    if (data.isEmpty) {
      return _buildEmptyState();
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        PieChart(
          _buildPieChartData(),
          duration: animation.enabled ? animation.duration : Duration.zero,
          curve: animation.curve,
        ),
        if (centerWidget != null) centerWidget!,
        if (centerWidget == null) _buildDefaultCenterWidget(),
      ],
    );
  }

  /// Build default center widget showing total
  Widget _buildDefaultCenterWidget() {
    final total = _calculateTotal();
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Total',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          total.toStringAsFixed(0),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Build empty state
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.donut_small,
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
  static DonutChartWidget sample({
    String title = 'Sample Donut Chart',
    String? subtitle,
  }) {
    final sampleData = [
      PieChartDataPoint(
        label: 'Completed',
        value: 75,
        color: ChartTheme.primaryColors[2], // Success color
      ),
      PieChartDataPoint(
        label: 'In Progress',
        value: 15,
        color: ChartTheme.primaryColors[3], // Warning color
      ),
      PieChartDataPoint(
        label: 'Cancelled',
        value: 10,
        color: ChartTheme.primaryColors[5], // Error color
      ),
    ];

    return DonutChartWidget(
      title: title,
      subtitle: subtitle,
      data: sampleData,
      height: 300,
      showPercentages: true,
    );
  }
}
