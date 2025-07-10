import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_pro_test/features/admin/presentation/screens/simple_admin_dashboard_screen.dart';
import 'package:flutter_pro_test/shared/theme/app_colors.dart';

void main() {
  group('SimpleAdminDashboardScreen Widget Tests', () {
    testWidgets('should create SimpleAdminDashboardScreen without errors', (
      WidgetTester tester,
    ) async {
      // Build the widget with a larger screen size to avoid overflow
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(
            1200,
            800,
          ), // Larger design size to avoid overflow
          builder: (context, child) =>
              const MaterialApp(home: SimpleAdminDashboardScreen()),
        ),
      );

      // Verify the widget is created successfully
      expect(find.byType(SimpleAdminDashboardScreen), findsOneWidget);
    });

    testWidgets('should display admin dashboard title', (
      WidgetTester tester,
    ) async {
      // Build the widget with a larger screen size
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(1200, 800),
          builder: (context, child) =>
              const MaterialApp(home: SimpleAdminDashboardScreen()),
        ),
      );

      // Verify the title is displayed
      expect(find.text('CareNow Admin Dashboard'), findsOneWidget);
    });

    testWidgets('should display success message', (WidgetTester tester) async {
      // Build the widget with a larger screen size
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(1200, 800),
          builder: (context, child) =>
              const MaterialApp(home: SimpleAdminDashboardScreen()),
        ),
      );

      // Verify the success message is displayed
      expect(find.text('🎉 Admin Dashboard Working!'), findsOneWidget);
    });

    testWidgets('should have proper app bar', (WidgetTester tester) async {
      // Build the widget with a larger screen size
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(1200, 800),
          builder: (context, child) =>
              const MaterialApp(home: SimpleAdminDashboardScreen()),
        ),
      );

      // Verify the app bar is present
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should be scrollable', (WidgetTester tester) async {
      // Build the widget with a larger screen size
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(1200, 800),
          builder: (context, child) =>
              const MaterialApp(home: SimpleAdminDashboardScreen()),
        ),
      );

      // Verify the screen is scrollable
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });
}
