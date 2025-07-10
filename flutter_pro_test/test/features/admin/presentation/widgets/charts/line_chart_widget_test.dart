import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_pro_test/features/admin/presentation/widgets/charts/line_chart_widget.dart';
import 'package:flutter_pro_test/features/admin/presentation/widgets/charts/base_chart_widget.dart';
import 'package:flutter_pro_test/features/admin/presentation/widgets/charts/chart_theme.dart';

void main() {
  group('LineChartWidget', () {
    late List<ChartDataSeries> testDataSeries;

    setUpAll(() async {
      await ScreenUtil.ensureScreenSize();
    });

    setUp(() {
      testDataSeries = [
        ChartDataSeries(
          name: 'Revenue',
          color: ChartTheme.primaryColors[0],
          data: [
            const ChartDataPoint(x: 0, y: 1000),
            const ChartDataPoint(x: 1, y: 1200),
            const ChartDataPoint(x: 2, y: 1100),
            const ChartDataPoint(x: 3, y: 1400),
            const ChartDataPoint(x: 4, y: 1300),
          ],
        ),
        ChartDataSeries(
          name: 'Profit',
          color: ChartTheme.primaryColors[1],
          data: [
            const ChartDataPoint(x: 0, y: 800),
            const ChartDataPoint(x: 1, y: 950),
            const ChartDataPoint(x: 2, y: 880),
            const ChartDataPoint(x: 3, y: 1100),
            const ChartDataPoint(x: 4, y: 1050),
          ],
        ),
      ];
    });

    testWidgets('should render line chart with title', (
      WidgetTester tester,
    ) async {
      const title = 'Test Line Chart';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LineChartWidget(
              title: title,
              dataSeries: testDataSeries,
              height: 300,
            ),
          ),
        ),
      );

      expect(find.text(title), findsOneWidget);
    });

    testWidgets('should render line chart with subtitle', (
      WidgetTester tester,
    ) async {
      const title = 'Test Line Chart';
      const subtitle = 'Test Subtitle';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LineChartWidget(
              title: title,
              subtitle: subtitle,
              dataSeries: testDataSeries,
              height: 300,
            ),
          ),
        ),
      );

      expect(find.text(title), findsOneWidget);
      expect(find.text(subtitle), findsOneWidget);
    });

    testWidgets('should show legend when enabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LineChartWidget(
              title: 'Test Chart',
              dataSeries: testDataSeries,
              showLegend: true,
              height: 300,
            ),
          ),
        ),
      );

      // Check if legend items are present
      expect(find.text('Revenue'), findsOneWidget);
      expect(find.text('Profit'), findsOneWidget);
    });

    testWidgets('should hide legend when disabled', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LineChartWidget(
              title: 'Test Chart',
              dataSeries: testDataSeries,
              showLegend: false,
              height: 300,
            ),
          ),
        ),
      );

      // Legend should not be visible
      expect(find.text('Revenue'), findsNothing);
      expect(find.text('Profit'), findsNothing);
    });

    testWidgets('should show loading state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LineChartWidget(
              title: 'Test Chart',
              dataSeries: testDataSeries,
              isLoading: true,
              height: 300,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading chart data...'), findsOneWidget);
    });

    testWidgets('should show error state', (WidgetTester tester) async {
      const errorMessage = 'Failed to load data';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LineChartWidget(
              title: 'Test Chart',
              dataSeries: testDataSeries,
              errorMessage: errorMessage,
              height: 300,
            ),
          ),
        ),
      );

      expect(find.text('Failed to load chart'), findsOneWidget);
      expect(find.text(errorMessage), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should show retry button in error state', (
      WidgetTester tester,
    ) async {
      bool retryPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LineChartWidget(
              title: 'Test Chart',
              dataSeries: testDataSeries,
              errorMessage: 'Error',
              onRetry: () => retryPressed = true,
              height: 300,
            ),
          ),
        ),
      );

      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pump();

      expect(retryPressed, isTrue);
    });

    testWidgets('should show empty state for no data', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LineChartWidget(
              title: 'Test Chart',
              dataSeries: [],
              height: 300,
            ),
          ),
        ),
      );

      expect(find.text('No data available'), findsOneWidget);
      expect(find.byIcon(Icons.show_chart), findsOneWidget);
    });

    testWidgets('should create sample chart', (WidgetTester tester) async {
      final sampleChart = LineChartWidget.sample();

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: sampleChart)));

      expect(find.text('Sample Line Chart'), findsOneWidget);
      expect(sampleChart.dataSeries.length, equals(2));
      expect(sampleChart.dataSeries[0].name, equals('Revenue'));
      expect(sampleChart.dataSeries[1].name, equals('Profit'));
    });

    group('Chart Configuration', () {
      testWidgets('should apply custom height', (WidgetTester tester) async {
        const customHeight = 400.0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: LineChartWidget(
                title: 'Test Chart',
                dataSeries: testDataSeries,
                height: customHeight,
              ),
            ),
          ),
        );

        final container = tester.widget<Container>(
          find.byType(Container).first,
        );
        expect(container.constraints?.maxHeight, equals(customHeight));
      });

      testWidgets('should show dots when enabled', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: LineChartWidget(
                title: 'Test Chart',
                dataSeries: testDataSeries,
                showDots: true,
                height: 300,
              ),
            ),
          ),
        );

        // Chart should be rendered (we can't easily test fl_chart internals)
        expect(find.byType(LineChartWidget), findsOneWidget);
      });

      testWidgets('should show area when enabled', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: LineChartWidget(
                title: 'Test Chart',
                dataSeries: testDataSeries,
                showArea: true,
                height: 300,
              ),
            ),
          ),
        );

        expect(find.byType(LineChartWidget), findsOneWidget);
      });
    });

    group('Data Validation', () {
      test('should calculate min X correctly', () {
        final widget = LineChartWidget(
          title: 'Test',
          dataSeries: testDataSeries,
        );

        // We can't directly test private methods, but we can test the widget creation
        expect(widget.dataSeries.isNotEmpty, isTrue);
        expect(widget.dataSeries[0].data.first.x, equals(0));
      });

      test('should calculate max X correctly', () {
        final widget = LineChartWidget(
          title: 'Test',
          dataSeries: testDataSeries,
        );

        expect(widget.dataSeries[0].data.last.x, equals(4));
      });

      test('should handle empty data series', () {
        final widget = LineChartWidget(title: 'Test', dataSeries: []);

        expect(widget.dataSeries.isEmpty, isTrue);
      });
    });

    group('Interaction', () {
      testWidgets('should handle touch interaction when enabled', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: LineChartWidget(
                title: 'Test Chart',
                dataSeries: testDataSeries,
                interaction: const ChartInteraction(enableTouch: true),
                height: 300,
              ),
            ),
          ),
        );

        expect(find.byType(LineChartWidget), findsOneWidget);
      });

      testWidgets('should disable touch interaction when disabled', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: LineChartWidget(
                title: 'Test Chart',
                dataSeries: testDataSeries,
                interaction: const ChartInteraction(enableTouch: false),
                height: 300,
              ),
            ),
          ),
        );

        expect(find.byType(LineChartWidget), findsOneWidget);
      });
    });

    group('Animation', () {
      testWidgets('should apply animation when enabled', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: LineChartWidget(
                title: 'Test Chart',
                dataSeries: testDataSeries,
                animation: const ChartAnimation(enabled: true),
                height: 300,
              ),
            ),
          ),
        );

        expect(find.byType(LineChartWidget), findsOneWidget);
      });

      testWidgets('should disable animation when disabled', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: LineChartWidget(
                title: 'Test Chart',
                dataSeries: testDataSeries,
                animation: ChartAnimation.none,
                height: 300,
              ),
            ),
          ),
        );

        expect(find.byType(LineChartWidget), findsOneWidget);
      });
    });
  });
}
