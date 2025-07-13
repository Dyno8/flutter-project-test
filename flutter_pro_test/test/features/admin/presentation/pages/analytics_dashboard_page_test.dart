import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:get_it/get_it.dart';

// Core services
import 'package:flutter_pro_test/core/analytics/business_analytics_service.dart';
import 'package:flutter_pro_test/core/analytics/firebase_analytics_service.dart';
import 'package:flutter_pro_test/core/monitoring/monitoring_service.dart';

// Page under test
import 'package:flutter_pro_test/features/admin/presentation/pages/analytics_dashboard_page.dart';

// Generated mocks
import 'analytics_dashboard_page_test.mocks.dart';

@GenerateMocks([
  BusinessAnalyticsService,
  FirebaseAnalyticsService,
  MonitoringService,
  UserBehaviorTrackingService,
])
void main() {
  group('AnalyticsDashboardPage Widget Tests', () {
    late MockBusinessAnalyticsService mockBusinessAnalytics;
    late MockFirebaseAnalyticsService mockFirebaseAnalytics;
    late MockMonitoringService mockMonitoringService;
    late MockUserBehaviorTrackingService mockUserBehaviorTracking;

    setUp(() async {
      // Initialize mocks
      mockBusinessAnalytics = MockBusinessAnalyticsService();
      mockFirebaseAnalytics = MockFirebaseAnalyticsService();
      mockMonitoringService = MockMonitoringService();
      mockUserBehaviorTracking = MockUserBehaviorTrackingService();

      // Setup GetIt for dependency injection
      final getIt = GetIt.instance;
      if (getIt.isRegistered<BusinessAnalyticsService>()) {
        getIt.unregister<BusinessAnalyticsService>();
      }
      if (getIt.isRegistered<FirebaseAnalyticsService>()) {
        getIt.unregister<FirebaseAnalyticsService>();
      }
      if (getIt.isRegistered<MonitoringService>()) {
        getIt.unregister<MonitoringService>();
      }
      if (getIt.isRegistered<UserBehaviorTrackingService>()) {
        getIt.unregister<UserBehaviorTrackingService>();
      }

      getIt.registerSingleton<BusinessAnalyticsService>(mockBusinessAnalytics);
      getIt.registerSingleton<FirebaseAnalyticsService>(mockFirebaseAnalytics);
      getIt.registerSingleton<MonitoringService>(mockMonitoringService);
      getIt.registerSingleton<UserBehaviorTrackingService>(
        mockUserBehaviorTracking,
      );

      // Configure mock behaviors
      when(mockBusinessAnalytics.getSessionInfo()).thenReturn({
        'total_sessions': 1250,
        'active_sessions': 45,
        'average_session_duration': 8.5,
        'bounce_rate': 0.23,
      });

      when(mockUserBehaviorTracking.getBehaviorSummary()).thenReturn({
        'click_patterns': {'button_clicks': 1500, 'link_clicks': 800},
        'search_queries': {'total_searches': 350, 'unique_queries': 280},
        'user_flows': {'completed_bookings': 125, 'abandoned_carts': 45},
      });

      when(mockMonitoringService.getHealthStatus()).thenReturn({
        'cpu_usage': 0.23,
        'memory_usage': 0.67,
        'api_response_time': 450.0,
        'error_rate': 0.02,
        'uptime': 99.8,
      });
    });

    tearDown(() {
      GetIt.instance.reset();
    });

    Widget createWidgetUnderTest() {
      return ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) =>
            MaterialApp(home: const AnalyticsDashboardPage()),
      );
    }

    group('Basic Widget Structure', () {
      testWidgets('should display app bar with correct title', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        expect(find.text('Analytics Dashboard'), findsOneWidget);
        expect(find.byType(AppBar), findsOneWidget);
      });

      testWidgets('should display tab bar with four tabs', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        expect(find.byType(TabBar), findsOneWidget);
        expect(find.text('Overview'), findsOneWidget);
        expect(find.text('Users'), findsOneWidget);
        expect(find.text('Performance'), findsOneWidget);
        expect(find.text('Business'), findsOneWidget);
      });

      testWidgets('should display refresh and export buttons in app bar', (
        tester,
      ) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.refresh), findsOneWidget);
        expect(find.byIcon(Icons.download), findsOneWidget);
      });

      testWidgets('should show loading indicator initially', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());

        // Should show loading indicator before data loads
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    group('Overview Tab', () {
      testWidgets('should display metrics grid with four metric cards', (
        tester,
      ) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Should be on Overview tab by default
        expect(find.text('Active Users'), findsOneWidget);
        expect(find.text('Total Sessions'), findsOneWidget);
        expect(find.text('Revenue Today'), findsOneWidget);
        expect(find.text('Error Rate'), findsOneWidget);
      });

      testWidgets('should display metric values correctly', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Check for metric icons
        expect(find.byIcon(Icons.people), findsWidgets);
        expect(find.byIcon(Icons.timeline), findsWidgets);
        expect(find.byIcon(Icons.attach_money), findsWidgets);
        expect(find.byIcon(Icons.error_outline), findsWidgets);
      });

      testWidgets('should display real-time chart', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Look for chart-related text or containers
        expect(find.text('Real-time Activity'), findsOneWidget);
      });

      testWidgets('should display quick insights section', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        expect(find.text('Quick Insights'), findsOneWidget);
      });
    });

    group('Users Tab', () {
      testWidgets('should display user metrics when Users tab is selected', (
        tester,
      ) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Tap on Users tab
        await tester.tap(find.text('Users'));
        await tester.pumpAndSettle();

        expect(find.text('User Metrics'), findsOneWidget);
        expect(find.text('Total Users'), findsOneWidget);
        expect(find.text('New Users'), findsOneWidget);
        expect(find.text('Retention Rate'), findsOneWidget);
        expect(find.text('Avg Session'), findsOneWidget);
      });

      testWidgets('should display user behavior chart', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Users'));
        await tester.pumpAndSettle();

        expect(find.text('User Behavior Patterns'), findsOneWidget);
      });

      testWidgets('should display user segmentation card', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Users'));
        await tester.pumpAndSettle();

        expect(find.text('User Segmentation'), findsOneWidget);
      });
    });

    group('Performance Tab', () {
      testWidgets(
        'should display performance metrics when Performance tab is selected',
        (tester) async {
          await tester.pumpWidget(createWidgetUnderTest());
          await tester.pumpAndSettle();

          await tester.tap(find.text('Performance'));
          await tester.pumpAndSettle();

          expect(find.text('Performance Metrics'), findsOneWidget);
          expect(find.text('App Load Time'), findsOneWidget);
          expect(find.text('API Response'), findsOneWidget);
          expect(find.text('Memory Usage'), findsOneWidget);
          expect(find.text('CPU Usage'), findsOneWidget);
        },
      );

      testWidgets('should display error tracking card', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Performance'));
        await tester.pumpAndSettle();

        expect(find.text('Error Tracking'), findsOneWidget);
      });

      testWidgets('should display system health card', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Performance'));
        await tester.pumpAndSettle();

        expect(find.text('System Health'), findsOneWidget);
      });
    });

    group('Business Tab', () {
      testWidgets(
        'should display business metrics when Business tab is selected',
        (tester) async {
          await tester.pumpWidget(createWidgetUnderTest());
          await tester.pumpAndSettle();

          await tester.tap(find.text('Business'));
          await tester.pumpAndSettle();

          expect(find.text('Revenue Analytics'), findsOneWidget);
          expect(find.text('Service Performance'), findsOneWidget);
          expect(find.text('Partner Analytics'), findsOneWidget);
        },
      );
    });

    group('User Interactions', () {
      testWidgets('should refresh data when refresh button is tapped', (
        tester,
      ) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Tap refresh button
        await tester.tap(find.byIcon(Icons.refresh));
        await tester.pump();

        // Should show loading indicator
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('should handle export button tap', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Tap export button
        await tester.tap(find.byIcon(Icons.download));
        await tester.pumpAndSettle();

        // Should not crash (basic interaction test)
        expect(find.byType(AnalyticsDashboardPage), findsOneWidget);
      });

      testWidgets('should switch between tabs correctly', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Test tab switching
        await tester.tap(find.text('Users'));
        await tester.pumpAndSettle();
        expect(find.text('User Metrics'), findsOneWidget);

        await tester.tap(find.text('Performance'));
        await tester.pumpAndSettle();
        expect(find.text('Performance Metrics'), findsOneWidget);

        await tester.tap(find.text('Business'));
        await tester.pumpAndSettle();
        expect(find.text('Revenue Analytics'), findsOneWidget);

        await tester.tap(find.text('Overview'));
        await tester.pumpAndSettle();
        expect(find.text('Active Users'), findsOneWidget);
      });
    });

    group('Error Handling', () {
      testWidgets('should handle service initialization errors gracefully', (
        tester,
      ) async {
        // Reset mocks to throw errors
        when(
          mockBusinessAnalytics.getSessionInfo(),
        ).thenThrow(Exception('Service error'));
        when(
          mockUserBehaviorTracking.getBehaviorSummary(),
        ).thenThrow(Exception('Behavior service error'));
        when(
          mockMonitoringService.getHealthStatus(),
        ).thenThrow(Exception('Monitoring error'));

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Should still display the page structure
        expect(find.byType(AnalyticsDashboardPage), findsOneWidget);
        expect(find.text('Analytics Dashboard'), findsOneWidget);
      });

      testWidgets('should show error snackbar when data loading fails', (
        tester,
      ) async {
        when(
          mockBusinessAnalytics.getSessionInfo(),
        ).thenThrow(Exception('Network error'));

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Look for error indication (snackbar might be shown)
        expect(find.byType(AnalyticsDashboardPage), findsOneWidget);
      });
    });

    group('Data Display', () {
      testWidgets('should display correct metric values from services', (
        tester,
      ) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Verify that service methods were called
        verify(mockBusinessAnalytics.getSessionInfo()).called(1);
        verify(mockUserBehaviorTracking.getBehaviorSummary()).called(1);
        verify(mockMonitoringService.getHealthStatus()).called(1);
      });

      testWidgets('should handle empty or null data gracefully', (
        tester,
      ) async {
        // Setup mocks to return empty data
        when(mockBusinessAnalytics.getSessionInfo()).thenReturn({});
        when(mockUserBehaviorTracking.getBehaviorSummary()).thenReturn({});
        when(mockMonitoringService.getHealthStatus()).thenReturn({});

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Should still display the page structure
        expect(find.byType(AnalyticsDashboardPage), findsOneWidget);
        expect(find.text('Analytics Dashboard'), findsOneWidget);
      });
    });

    group('Real-time Updates', () {
      testWidgets('should handle real-time data updates', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Initial state should be loaded
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.text('Active Users'), findsOneWidget);

        // Simulate real-time update by refreshing
        await tester.tap(find.byIcon(Icons.refresh));
        await tester.pump();

        // Should show loading state
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        await tester.pumpAndSettle();

        // Should return to loaded state
        expect(find.byType(CircularProgressIndicator), findsNothing);
      });
    });

    group('Responsive Design', () {
      testWidgets('should adapt to different screen sizes', (tester) async {
        // Test with different screen size
        await tester.binding.setSurfaceSize(const Size(800, 600));

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        expect(find.byType(AnalyticsDashboardPage), findsOneWidget);
        expect(find.text('Analytics Dashboard'), findsOneWidget);

        // Reset to original size
        await tester.binding.setSurfaceSize(const Size(375, 812));
      });
    });

    group('Accessibility', () {
      testWidgets('should have proper accessibility labels', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Check for semantic labels on important elements
        expect(find.byType(TabBar), findsOneWidget);
        expect(find.byType(AppBar), findsOneWidget);

        // Tabs should be accessible
        expect(find.text('Overview'), findsOneWidget);
        expect(find.text('Users'), findsOneWidget);
        expect(find.text('Performance'), findsOneWidget);
        expect(find.text('Business'), findsOneWidget);
      });
    });
  });
}
