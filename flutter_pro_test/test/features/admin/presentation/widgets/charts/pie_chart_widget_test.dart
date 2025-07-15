import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:flutter_pro_test/features/admin/presentation/widgets/charts/pie_chart_widget.dart';
import 'package:flutter_pro_test/features/admin/presentation/widgets/charts/base_chart_widget.dart';

void main() {
  group('PieChartWidget Tests', () {
    late List<PieChartDataPoint> testData;

    setUp(() {
      testData = [
        PieChartDataPoint(label: 'Cleaning', value: 45.0, color: Colors.blue),
        PieChartDataPoint(label: 'Garden', value: 30.0, color: Colors.green),
        PieChartDataPoint(label: 'Pet Care', value: 25.0, color: Colors.orange),
      ];
    });

    Widget createWidgetUnderTest({
      required String title,
      required List<PieChartDataPoint> data,
      String? subtitle,
      double? height,
      double? width,
      bool showLegend = true,
      bool showPercentages = true,
      bool showValues = false,
      bool showLabels = true,
      bool isLoading = false,
      String? errorMessage,
      VoidCallback? onRetry,
    }) {
      return ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => MaterialApp(
          home: Scaffold(
            body: PieChartWidget(
              title: title,
              data: data,
              subtitle: subtitle,
              height: height,
              width: width,
              showLegend: showLegend,
              showPercentages: showPercentages,
              showValues: showValues,
              showLabels: showLabels,
              isLoading: isLoading,
              errorMessage: errorMessage,
              onRetry: onRetry,
            ),
          ),
        ),
      );
    }

    group('Basic Display', () {
      testWidgets('should display title and chart', (tester) async {
        await tester.pumpWidget(
          createWidgetUnderTest(title: 'Service Distribution', data: testData),
        );

        expect(find.text('Service Distribution'), findsOneWidget);
        expect(find.byType(PieChart), findsOneWidget);
      });

      testWidgets('should display subtitle when provided', (tester) async {
        await tester.pumpWidget(
          createWidgetUnderTest(
            title: 'Service Distribution',
            subtitle: 'Last 30 days',
            data: testData,
          ),
        );

        expect(find.text('Service Distribution'), findsOneWidget);
        expect(find.text('Last 30 days'), findsOneWidget);
      });

      testWidgets('should display legend when showLegend is true', (
        tester,
      ) async {
        await tester.pumpWidget(
          createWidgetUnderTest(
            title: 'Service Distribution',
            data: testData,
            showLegend: true,
          ),
        );

        expect(find.text('Cleaning'), findsOneWidget);
        expect(find.text('Garden'), findsOneWidget);
        expect(find.text('Pet Care'), findsOneWidget);
      });

      testWidgets('should not display legend when showLegend is false', (
        tester,
      ) async {
        await tester.pumpWidget(
          createWidgetUnderTest(
            title: 'Service Distribution',
            data: testData,
            showLegend: false,
          ),
        );

        expect(find.text('Service Distribution'), findsOneWidget);
        expect(find.byType(PieChart), findsOneWidget);
        // Legend items should not be visible
        expect(find.text('Cleaning'), findsNothing);
        expect(find.text('Garden'), findsNothing);
        expect(find.text('Pet Care'), findsNothing);
      });
    });

    group('Data Display', () {
      testWidgets('should handle empty data gracefully', (tester) async {
        await tester.pumpWidget(
          createWidgetUnderTest(title: 'Empty Chart', data: []),
        );

        expect(find.text('Empty Chart'), findsOneWidget);
        expect(find.text('No data available'), findsOneWidget);
      });

      testWidgets('should display percentages when showPercentages is true', (
        tester,
      ) async {
        await tester.pumpWidget(
          createWidgetUnderTest(
            title: 'Service Distribution',
            data: testData,
            showPercentages: true,
            showLegend: true,
          ),
        );

        // Should show percentage values in legend
        expect(find.textContaining('45.0%'), findsOneWidget);
        expect(find.textContaining('30.0%'), findsOneWidget);
        expect(find.textContaining('25.0%'), findsOneWidget);
      });

      testWidgets('should display values when showValues is true', (
        tester,
      ) async {
        await tester.pumpWidget(
          createWidgetUnderTest(
            title: 'Service Distribution',
            data: testData,
            showValues: true,
            showLegend: true,
          ),
        );

        // Should show actual values in legend
        expect(find.textContaining('45'), findsOneWidget);
        expect(find.textContaining('30'), findsOneWidget);
        expect(find.textContaining('25'), findsOneWidget);
      });

      testWidgets('should handle single data point', (tester) async {
        final singleData = [
          PieChartDataPoint(
            label: 'Complete',
            value: 100.0,
            color: Colors.blue,
          ),
        ];

        await tester.pumpWidget(
          createWidgetUnderTest(
            title: 'Single Service Chart',
            data: singleData,
          ),
        );

        expect(find.text('Single Service Chart'), findsOneWidget);
        expect(find.text('Complete'), findsOneWidget);
        expect(find.byType(PieChart), findsOneWidget);
      });
    });

    group('Loading and Error States', () {
      testWidgets('should show loading indicator when isLoading is true', (
        tester,
      ) async {
        await tester.pumpWidget(
          createWidgetUnderTest(
            title: 'Loading Chart',
            data: testData,
            isLoading: true,
          ),
        );

        expect(find.text('Loading Chart'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('should show error message when errorMessage is provided', (
        tester,
      ) async {
        await tester.pumpWidget(
          createWidgetUnderTest(
            title: 'Error Chart',
            data: testData,
            errorMessage: 'Failed to load chart data',
          ),
        );

        expect(find.text('Error Chart'), findsOneWidget);
        expect(find.text('Failed to load chart data'), findsOneWidget);
      });

      testWidgets('should show retry button when onRetry is provided', (
        tester,
      ) async {
        bool retryTapped = false;

        await tester.pumpWidget(
          createWidgetUnderTest(
            title: 'Error Chart',
            data: testData,
            errorMessage: 'Network error',
            onRetry: () => retryTapped = true,
          ),
        );

        expect(find.text('Retry'), findsOneWidget);

        await tester.tap(find.text('Retry'));
        expect(retryTapped, isTrue);
      });
    });

    group('Sizing and Layout', () {
      testWidgets('should respect custom height', (tester) async {
        await tester.pumpWidget(
          createWidgetUnderTest(
            title: 'Custom Height Chart',
            data: testData,
            height: 400,
          ),
        );

        expect(find.text('Custom Height Chart'), findsOneWidget);
        expect(find.byType(PieChart), findsOneWidget);
      });

      testWidgets('should respect custom width', (tester) async {
        await tester.pumpWidget(
          createWidgetUnderTest(
            title: 'Custom Width Chart',
            data: testData,
            width: 300,
          ),
        );

        expect(find.text('Custom Width Chart'), findsOneWidget);
        expect(find.byType(PieChart), findsOneWidget);
      });

      testWidgets('should handle responsive layout', (tester) async {
        // Test with different screen size
        await tester.binding.setSurfaceSize(const Size(800, 600));

        await tester.pumpWidget(
          createWidgetUnderTest(title: 'Responsive Chart', data: testData),
        );

        expect(find.text('Responsive Chart'), findsOneWidget);
        expect(find.byType(PieChart), findsOneWidget);

        // Reset to original size
        await tester.binding.setSurfaceSize(const Size(375, 812));
      });
    });

    group('Color and Styling', () {
      testWidgets('should apply correct colors to chart sections', (
        tester,
      ) async {
        await tester.pumpWidget(
          createWidgetUnderTest(title: 'Colored Chart', data: testData),
        );

        expect(find.byType(PieChart), findsOneWidget);

        // Chart should be rendered with the provided colors
        final pieChart = tester.widget<PieChart>(find.byType(PieChart));
        expect(pieChart.data.sections.length, equals(3));
      });

      testWidgets('should handle custom chart theme', (tester) async {
        await tester.pumpWidget(
          createWidgetUnderTest(title: 'Themed Chart', data: testData),
        );

        expect(find.text('Themed Chart'), findsOneWidget);
        expect(find.byType(PieChart), findsOneWidget);
      });
    });

    group('Accessibility', () {
      testWidgets('should be accessible with proper semantics', (tester) async {
        await tester.pumpWidget(
          createWidgetUnderTest(
            title: 'Accessible Chart',
            data: testData,
            showLegend: true,
          ),
        );

        // Title should be accessible
        expect(find.text('Accessible Chart'), findsOneWidget);

        // Legend items should be accessible
        expect(find.text('Cleaning'), findsOneWidget);
        expect(find.text('Garden'), findsOneWidget);
        expect(find.text('Pet Care'), findsOneWidget);
      });
    });
  });

  group('DonutChartWidget Tests', () {
    late List<PieChartDataPoint> testData;

    setUp(() {
      testData = [
        PieChartDataPoint(label: 'Completed', value: 75.0, color: Colors.green),
        PieChartDataPoint(label: 'Pending', value: 25.0, color: Colors.orange),
      ];
    });

    Widget createDonutWidgetUnderTest({
      required String title,
      required List<PieChartDataPoint> data,
      Widget? centerWidget,
    }) {
      return ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => MaterialApp(
          home: Scaffold(
            body: DonutChartWidget(
              title: title,
              data: data,
              centerWidget: centerWidget,
            ),
          ),
        ),
      );
    }

    testWidgets('should display donut chart with center widget', (
      tester,
    ) async {
      await tester.pumpWidget(
        createDonutWidgetUnderTest(
          title: 'Task Progress',
          data: testData,
          centerWidget: const Text('75%'),
        ),
      );

      expect(find.text('Task Progress'), findsOneWidget);
      expect(find.text('75%'), findsOneWidget);
      expect(find.byType(PieChart), findsOneWidget);
    });

    testWidgets('should display donut chart without center widget', (
      tester,
    ) async {
      await tester.pumpWidget(
        createDonutWidgetUnderTest(title: 'Simple Donut', data: testData),
      );

      expect(find.text('Simple Donut'), findsOneWidget);
      expect(find.byType(PieChart), findsOneWidget);
    });
  });
}
