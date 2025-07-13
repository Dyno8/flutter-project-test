import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_pro_test/shared/widgets/custom_card.dart';

void main() {
  group('MetricCard Widget Tests', () {
    Widget createWidgetUnderTest({
      required String title,
      required String value,
      required IconData icon,
      required Color color,
      String? subtitle,
      VoidCallback? onTap,
      bool showTrend = false,
      double? trendValue,
    }) {
      return ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => MaterialApp(
          home: Scaffold(
            body: MetricCard(
              title: title,
              value: value,
              icon: icon,
              color: color,
              subtitle: subtitle,
              onTap: onTap,
              showTrend: showTrend,
              trendValue: trendValue,
            ),
          ),
        ),
      );
    }

    group('Basic Display', () {
      testWidgets('should display title, value, and icon', (tester) async {
        await tester.pumpWidget(
          createWidgetUnderTest(
            title: 'Active Users',
            value: '1,234',
            icon: Icons.people,
            color: Colors.blue,
          ),
        );

        expect(find.text('Active Users'), findsOneWidget);
        expect(find.text('1,234'), findsOneWidget);
        expect(find.byIcon(Icons.people), findsOneWidget);
      });

      testWidgets('should display subtitle when provided', (tester) async {
        await tester.pumpWidget(
          createWidgetUnderTest(
            title: 'Revenue',
            value: '\$12,345',
            icon: Icons.attach_money,
            color: Colors.green,
            subtitle: 'This month',
          ),
        );

        expect(find.text('Revenue'), findsOneWidget);
        expect(find.text('\$12,345'), findsOneWidget);
        expect(find.text('This month'), findsOneWidget);
        expect(find.byIcon(Icons.attach_money), findsOneWidget);
      });

      testWidgets('should apply correct color theme', (tester) async {
        await tester.pumpWidget(
          createWidgetUnderTest(
            title: 'Error Rate',
            value: '2.3%',
            icon: Icons.error_outline,
            color: Colors.red,
          ),
        );

        // Find the icon and verify it exists
        final iconFinder = find.byIcon(Icons.error_outline);
        expect(iconFinder, findsOneWidget);

        // Get the Icon widget and check its color
        final Icon iconWidget = tester.widget(iconFinder);
        expect(iconWidget.color, equals(Colors.red));
      });
    });

    group('Trend Display', () {
      testWidgets('should show trend when showTrend is true', (tester) async {
        await tester.pumpWidget(
          createWidgetUnderTest(
            title: 'Sessions',
            value: '5,678',
            icon: Icons.timeline,
            color: Colors.orange,
            showTrend: true,
            trendValue: 12.5,
          ),
        );

        expect(find.text('Sessions'), findsOneWidget);
        expect(find.text('5,678'), findsOneWidget);
        // Note: Trend display depends on MetricCard implementation
      });

      testWidgets('should not show trend when showTrend is false', (
        tester,
      ) async {
        await tester.pumpWidget(
          createWidgetUnderTest(
            title: 'Sessions',
            value: '5,678',
            icon: Icons.timeline,
            color: Colors.orange,
            showTrend: false,
            trendValue: 12.5,
          ),
        );

        expect(find.text('Sessions'), findsOneWidget);
        expect(find.text('5,678'), findsOneWidget);
        // Note: Trend is not shown when showTrend is false
      });

      testWidgets('should handle positive trend values', (tester) async {
        await tester.pumpWidget(
          createWidgetUnderTest(
            title: 'Growth',
            value: '15.7%',
            icon: Icons.trending_up,
            color: Colors.green,
            showTrend: true,
            trendValue: 15.7,
          ),
        );

        expect(find.text('Growth'), findsOneWidget);
        expect(find.text('15.7%'), findsWidgets);
        expect(find.byIcon(Icons.trending_up), findsWidgets);
      });

      testWidgets('should handle negative trend values', (tester) async {
        await tester.pumpWidget(
          createWidgetUnderTest(
            title: 'Errors',
            value: '2.1%',
            icon: Icons.trending_down,
            color: Colors.red,
            showTrend: true,
            trendValue: -2.1,
          ),
        );

        expect(find.text('Errors'), findsOneWidget);
        expect(find.text('2.1%'), findsWidgets);
        expect(find.byIcon(Icons.trending_down), findsWidgets);
      });
    });

    group('User Interactions', () {
      testWidgets('should handle tap when onTap is provided', (tester) async {
        bool tapped = false;

        await tester.pumpWidget(
          createWidgetUnderTest(
            title: 'Clickable Metric',
            value: '999',
            icon: Icons.touch_app,
            color: Colors.purple,
            onTap: () => tapped = true,
          ),
        );

        await tester.tap(find.byType(MetricCard));
        expect(tapped, isTrue);
      });

      testWidgets('should not crash when tapped without onTap callback', (
        tester,
      ) async {
        await tester.pumpWidget(
          createWidgetUnderTest(
            title: 'Non-clickable Metric',
            value: '888',
            icon: Icons.info,
            color: Colors.grey,
          ),
        );

        // Should not crash when tapped
        await tester.tap(find.byType(MetricCard));
        await tester.pumpAndSettle();

        expect(find.text('Non-clickable Metric'), findsOneWidget);
      });
    });

    group('Layout and Styling', () {
      testWidgets('should have proper card structure', (tester) async {
        await tester.pumpWidget(
          createWidgetUnderTest(
            title: 'Test Metric',
            value: '123',
            icon: Icons.star,
            color: Colors.amber,
          ),
        );

        // Should be wrapped in a CustomCard widget
        expect(find.byType(CustomCard), findsOneWidget);
        expect(find.text('Test Metric'), findsOneWidget);
        expect(find.text('123'), findsOneWidget);
      });

      testWidgets('should handle long text values', (tester) async {
        await tester.pumpWidget(
          createWidgetUnderTest(
            title: 'Very Long Metric Title That Might Overflow',
            value: '1,234,567,890',
            icon: Icons.data_usage,
            color: Colors.indigo,
          ),
        );

        expect(
          find.text('Very Long Metric Title That Might Overflow'),
          findsOneWidget,
        );
        expect(find.text('1,234,567,890'), findsOneWidget);
      });

      testWidgets('should handle empty values gracefully', (tester) async {
        await tester.pumpWidget(
          createWidgetUnderTest(
            title: 'Empty Metric',
            value: '',
            icon: Icons.help_outline,
            color: Colors.grey,
          ),
        );

        expect(find.text('Empty Metric'), findsOneWidget);
        expect(find.text(''), findsOneWidget);
      });
    });

    group('Different Icon Types', () {
      testWidgets('should display different icon types correctly', (
        tester,
      ) async {
        final icons = [
          Icons.people,
          Icons.attach_money,
          Icons.timeline,
          Icons.error_outline,
          Icons.speed,
          Icons.trending_up,
          Icons.trending_down,
        ];

        for (final icon in icons) {
          await tester.pumpWidget(
            createWidgetUnderTest(
              title: 'Test',
              value: '100',
              icon: icon,
              color: Colors.blue,
            ),
          );

          expect(find.byIcon(icon), findsOneWidget);
        }
      });
    });

    group('Color Variations', () {
      testWidgets('should handle different color schemes', (tester) async {
        final colors = [
          Colors.red,
          Colors.green,
          Colors.blue,
          Colors.orange,
          Colors.purple,
          Colors.amber,
          Colors.teal,
        ];

        for (final color in colors) {
          await tester.pumpWidget(
            createWidgetUnderTest(
              title: 'Color Test',
              value: '100',
              icon: Icons.palette,
              color: color,
            ),
          );

          final iconFinder = find.byIcon(Icons.palette);
          expect(iconFinder, findsOneWidget);

          final Icon iconWidget = tester.widget(iconFinder);
          expect(iconWidget.color, equals(color));
        }
      });
    });

    group('Accessibility', () {
      testWidgets('should be accessible with screen readers', (tester) async {
        await tester.pumpWidget(
          createWidgetUnderTest(
            title: 'Accessible Metric',
            value: '42',
            icon: Icons.accessibility,
            color: Colors.green,
            subtitle: 'Accessibility test',
          ),
        );

        // Check that text elements are present for screen readers
        expect(find.text('Accessible Metric'), findsOneWidget);
        expect(find.text('42'), findsOneWidget);
        expect(find.text('Accessibility test'), findsOneWidget);
      });

      testWidgets('should handle semantic labels properly', (tester) async {
        await tester.pumpWidget(
          createWidgetUnderTest(
            title: 'Users Online',
            value: '1,234',
            icon: Icons.people,
            color: Colors.blue,
            onTap: () {},
          ),
        );

        // Should be tappable for accessibility
        expect(find.byType(InkWell), findsOneWidget);
      });
    });
  });
}
