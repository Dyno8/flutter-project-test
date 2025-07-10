import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../../shared/theme/app_colors.dart';

/// Chart theme configuration for consistent styling across all charts
class ChartTheme {
  static const double defaultBorderRadius = 8.0;
  static const double defaultPadding = 16.0;
  static const double defaultMargin = 8.0;
  static const double defaultStrokeWidth = 2.0;
  static const double defaultDotSize = 4.0;
  static const double defaultBarWidth = 20.0;

  /// Primary color palette for charts
  static const List<Color> primaryColors = [
    AppColors.primary,
    AppColors.secondary,
    AppColors.success,
    AppColors.warning,
    AppColors.info,
    AppColors.error,
  ];

  /// Extended color palette for charts with more data series
  static const List<Color> extendedColors = [
    AppColors.primary,
    AppColors.secondary,
    AppColors.success,
    AppColors.warning,
    AppColors.info,
    AppColors.error,
    Color(0xFF9C27B0), // Purple
    Color(0xFF607D8B), // Blue Grey
    Color(0xFF795548), // Brown
    Color(0xFF009688), // Teal
    Color(0xFFCDDC39), // Lime
    Color(0xFFFF5722), // Deep Orange
  ];

  /// Gradient colors for area charts
  static List<Color> getGradientColors(Color baseColor) {
    return [
      baseColor.withOpacity(0.8),
      baseColor.withOpacity(0.3),
      baseColor.withOpacity(0.1),
    ];
  }

  /// Get color by index with cycling
  static Color getColorByIndex(int index) {
    return extendedColors[index % extendedColors.length];
  }

  /// Default grid data for charts
  static FlGridData get defaultGridData => FlGridData(
    show: true,
    drawVerticalLine: true,
    drawHorizontalLine: true,
    horizontalInterval: null,
    verticalInterval: null,
    getDrawingHorizontalLine: (value) => FlLine(
      color: AppColors.border.withOpacity(0.3),
      strokeWidth: 1,
      dashArray: [5, 5],
    ),
    getDrawingVerticalLine: (value) => FlLine(
      color: AppColors.border.withOpacity(0.3),
      strokeWidth: 1,
      dashArray: [5, 5],
    ),
  );

  /// Default border data for charts
  static FlBorderData get defaultBorderData => FlBorderData(
    show: true,
    border: Border.all(color: AppColors.border.withOpacity(0.5), width: 1),
  );

  /// Default titles data for line/bar charts
  static FlTitlesData get defaultTitlesData => FlTitlesData(
    show: true,
    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 30,
        interval: 1,
        getTitlesWidget: (value, meta) => defaultBottomTitleWidget(value, meta),
      ),
    ),
    leftTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 50,
        interval: null,
        getTitlesWidget: (value, meta) => defaultLeftTitleWidget(value, meta),
      ),
    ),
  );

  /// Default bottom title widget
  static Widget defaultBottomTitleWidget(double value, TitleMeta meta) {
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        value.toInt().toString(),
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  /// Default left title widget
  static Widget defaultLeftTitleWidget(double value, TitleMeta meta) {
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        _formatValue(value),
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  /// Format value for display
  static String _formatValue(double value) {
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

  /// Default tooltip style
  static LineTooltipItem? defaultLineTooltipItem(
    LineBarSpot touchedSpot,
    LineChartBarData barData,
  ) {
    return LineTooltipItem(
      '${_formatValue(touchedSpot.y)}',
      TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
    );
  }

  /// Default bar tooltip style
  static BarTooltipItem? defaultBarTooltipItem(
    BarChartGroupData group,
    int groupIndex,
    BarChartRodData rod,
    int rodIndex,
  ) {
    return BarTooltipItem(
      '${_formatValue(rod.toY)}',
      TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
    );
  }

  /// Default pie chart section style
  static PieChartSectionData defaultPieSection({
    required double value,
    required String title,
    required Color color,
    double radius = 60,
    bool showTitle = true,
    double titlePositionPercentageOffset = 0.5,
  }) {
    return PieChartSectionData(
      color: color,
      value: value,
      title: showTitle ? title : '',
      radius: radius,
      titleStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      titlePositionPercentageOffset: titlePositionPercentageOffset,
    );
  }

  /// Chart container decoration
  static BoxDecoration get chartContainerDecoration => BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(defaultBorderRadius),
    border: Border.all(color: AppColors.border.withOpacity(0.3), width: 1),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ],
  );

  /// Chart title style
  static TextStyle get chartTitleStyle => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  /// Chart subtitle style
  static TextStyle get chartSubtitleStyle => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// Legend item style
  static TextStyle get legendTextStyle => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  /// Legend indicator size
  static const double legendIndicatorSize = 12.0;

  /// Animation duration for charts
  static const Duration animationDuration = Duration(milliseconds: 800);

  /// Animation curve for charts
  static const Curve animationCurve = Curves.easeInOutCubic;

  /// Touch response configuration
  static LineTouchData get defaultLineTouchData => LineTouchData(
    enabled: true,
    touchTooltipData: LineTouchTooltipData(
      tooltipPadding: const EdgeInsets.all(8),
      tooltipMargin: 8,
      getTooltipItems: (touchedSpots) {
        return touchedSpots.map((spot) {
          return defaultLineTooltipItem(spot, spot.bar);
        }).toList();
      },
    ),
    touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
      // Handle touch events if needed
    },
    handleBuiltInTouches: true,
  );

  /// Bar touch response configuration
  static BarTouchData get defaultBarTouchData => BarTouchData(
    enabled: true,
    touchTooltipData: BarTouchTooltipData(
      tooltipPadding: const EdgeInsets.all(8),
      tooltipMargin: 8,
      getTooltipItem: defaultBarTooltipItem,
    ),
    touchCallback: (FlTouchEvent event, BarTouchResponse? touchResponse) {
      // Handle touch events if needed
    },
    handleBuiltInTouches: true,
  );

  /// Pie touch response configuration
  static PieTouchData get defaultPieTouchData => PieTouchData(
    enabled: true,
    touchCallback: (FlTouchEvent event, PieTouchResponse? touchResponse) {
      // Handle touch events if needed
    },
  );

  /// Get responsive font size based on chart size
  static double getResponsiveFontSize(Size chartSize) {
    final minDimension = chartSize.width < chartSize.height
        ? chartSize.width
        : chartSize.height;

    if (minDimension < 200) {
      return 10;
    } else if (minDimension < 300) {
      return 12;
    } else if (minDimension < 400) {
      return 14;
    } else {
      return 16;
    }
  }

  /// Get responsive padding based on chart size
  static EdgeInsets getResponsivePadding(Size chartSize) {
    final minDimension = chartSize.width < chartSize.height
        ? chartSize.width
        : chartSize.height;

    if (minDimension < 200) {
      return const EdgeInsets.all(8);
    } else if (minDimension < 300) {
      return const EdgeInsets.all(12);
    } else {
      return const EdgeInsets.all(16);
    }
  }
}
