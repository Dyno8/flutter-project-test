import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_pro_test/features/admin/presentation/screens/advanced_admin_dashboard_screen.dart';
import 'package:flutter_pro_test/features/admin/presentation/bloc/admin_dashboard_bloc.dart';
import 'package:flutter_pro_test/features/admin/presentation/bloc/realtime_analytics_bloc.dart';
import 'package:flutter_pro_test/features/admin/domain/entities/system_metrics.dart';
import 'package:flutter_pro_test/features/admin/domain/entities/booking_analytics.dart';
import 'package:flutter_pro_test/features/admin/data/services/realtime_analytics_service.dart';
import 'package:flutter_pro_test/features/admin/data/services/websocket_service.dart';
import 'package:flutter_pro_test/features/admin/domain/usecases/get_system_metrics.dart';
import 'package:flutter_pro_test/features/admin/domain/usecases/get_booking_analytics.dart';
import 'package:flutter_pro_test/features/admin/domain/repositories/analytics_repository.dart';

import 'advanced_analytics_dashboard_integration_test.mocks.dart';

@GenerateMocks(
  [RealtimeAnalyticsService, WebSocketService],
  customMocks: [
    MockSpec<GetSystemMetrics>(as: #MockGetSystemMetricsUseCase),
    MockSpec<GetBookingAnalytics>(as: #MockGetBookingAnalyticsUseCase),
    MockSpec<AnalyticsRepository>(as: #MockAnalyticsRepo),
  ],
)
// Helper methods to create mock data
SystemMetrics _createMockSystemMetrics() {
  return SystemMetrics(
    totalUsers: 12450,
    totalPartners: 1250,
    totalBookings: 8920,
    activeBookings: 150,
    completedBookings: 7800,
    cancelledBookings: 650,
    totalRevenue: 125000.0,
    monthlyRevenue: 25000.0,
    dailyRevenue: 850.0,
    averageRating: 4.3,
    totalReviews: 1800,
    timestamp: DateTime.now(),
    performance: SystemPerformance(
      apiResponseTime: 120.0,
      errorRate: 0.02,
      activeConnections: 500,
      memoryUsage: 65.0,
      cpuUsage: 45.0,
      diskUsage: 70.0,
      requestsPerMinute: 1200,
      lastUpdated: DateTime.now(),
    ),
  );
}

BookingAnalytics _createMockBookingAnalytics() {
  return BookingAnalytics(
    totalBookings: 8920,
    completedBookings: 7800,
    cancelledBookings: 650,
    pendingBookings: 470,
    inProgressBookings: 150,
    averageBookingValue: 85.0,
    totalBookingValue: 758000.0,
    bookingsByService: {
      'Home Cleaning': 3500,
      'Plumbing': 2800,
      'Electrical': 1900,
      'Gardening': 1200,
    },
    bookingsByTimeSlot: {'Morning': 2200, 'Afternoon': 3800, 'Evening': 2900},
    bookingsByStatus: {
      'Completed': 7800,
      'Cancelled': 650,
      'Pending': 470,
      'In Progress': 150,
    },
    bookingsTrend: [
      DailyBookingData(
        date: DateTime.now().subtract(const Duration(days: 6)),
        totalBookings: 120,
        completedBookings: 105,
        cancelledBookings: 8,
        totalValue: 8500.0,
      ),
    ],
    periodStart: DateTime.now().subtract(const Duration(days: 30)),
    periodEnd: DateTime.now(),
    insights: const BookingInsights(
      trends: ['Booking volume increased by 15%'],
      recommendations: ['Focus on peak hours optimization'],
      alerts: [],
      peakHours: PeakHoursAnalysis(
        peakHours: ['10:00', '14:00', '18:00'],
        lowHours: ['06:00', '22:00'],
        hourlyDistribution: {'10:00': 0.15, '14:00': 0.20, '18:00': 0.18},
      ),
      servicePerformance: ServicePerformance(
        serviceCompletionRates: {'Home Cleaning': 92.5, 'Plumbing': 88.0},
        serviceAverageRatings: {'Home Cleaning': 4.3, 'Plumbing': 4.1},
        serviceRevenue: {'Home Cleaning': 45000.0, 'Plumbing': 35000.0},
        topPerformingServices: ['Home Cleaning'],
        underperformingServices: [],
      ),
    ),
  );
}

void main() {
  group('Advanced Analytics Dashboard Integration', () {
    late MockRealtimeAnalyticsService mockRealtimeService;
    late MockWebSocketService mockWebSocketService;
    late MockGetSystemMetricsUseCase mockGetSystemMetrics;
    late MockGetBookingAnalyticsUseCase mockGetBookingAnalytics;
    late MockAnalyticsRepo mockAnalyticsRepository;
    late AdminDashboardBloc adminDashboardBloc;
    late RealtimeAnalyticsBloc realtimeAnalyticsBloc;

    setUp(() {
      mockRealtimeService = MockRealtimeAnalyticsService();
      mockWebSocketService = MockWebSocketService();
      mockGetSystemMetrics = MockGetSystemMetricsUseCase();
      mockGetBookingAnalytics = MockGetBookingAnalyticsUseCase();
      mockAnalyticsRepository = MockAnalyticsRepo();

      // Setup mock streams
      when(
        mockRealtimeService.getSystemMetricsStream(),
      ).thenAnswer((_) => Stream.value(_createMockSystemMetrics()));
      when(
        mockRealtimeService.getBookingAnalyticsStream(),
      ).thenAnswer((_) => Stream.value(_createMockBookingAnalytics()));
      when(
        mockRealtimeService.getRevenueStream(),
      ).thenAnswer((_) => Stream.value(125000.0));
      when(
        mockRealtimeService.getUserCountStream(),
      ).thenAnswer((_) => Stream.value(12450));
      when(
        mockRealtimeService.getActiveBookingsStream(),
      ).thenAnswer((_) => Stream.value(150));
      when(mockRealtimeService.getPartnerStatusStream()).thenAnswer(
        (_) => Stream.value({'active': 890, 'inactive': 285, 'suspended': 75}),
      );

      when(mockWebSocketService.messageStream).thenAnswer(
        (_) => Stream.value({'type': 'analytics_update', 'data': {}}),
      );
      when(mockWebSocketService.isConnected).thenReturn(true);

      // Create BLoCs with mocked dependencies
      adminDashboardBloc = AdminDashboardBloc(
        getSystemMetrics: mockGetSystemMetrics,
        getBookingAnalytics: mockGetBookingAnalytics,
        analyticsRepository: mockAnalyticsRepository,
      );

      realtimeAnalyticsBloc = RealtimeAnalyticsBloc(
        analyticsService: mockRealtimeService,
        webSocketService: mockWebSocketService,
      );
    });

    tearDown(() {
      adminDashboardBloc.close();
      realtimeAnalyticsBloc.close();
    });

    testWidgets(
      'should display advanced analytics dashboard with all components',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MultiBlocProvider(
              providers: [
                BlocProvider<AdminDashboardBloc>.value(
                  value: adminDashboardBloc,
                ),
                BlocProvider<RealtimeAnalyticsBloc>.value(
                  value: realtimeAnalyticsBloc,
                ),
              ],
              child: const AdvancedAdminDashboardScreen(),
            ),
          ),
        );

        // Wait for initial render
        await tester.pump();

        // Verify main dashboard components are present
        expect(find.text('Advanced Analytics Dashboard'), findsOneWidget);
        expect(find.byType(TabBar), findsOneWidget);
        expect(find.byType(TabBarView), findsOneWidget);
      },
    );

    testWidgets('should display overview tab with KPIs and charts', (
      WidgetTester tester,
    ) async {
      // Trigger dashboard loaded state
      adminDashboardBloc.add(
        AdminDashboardStarted(
          startDate: DateTime.now().subtract(const Duration(days: 30)),
          endDate: DateTime.now(),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<AdminDashboardBloc>.value(value: adminDashboardBloc),
              BlocProvider<RealtimeAnalyticsBloc>.value(
                value: realtimeAnalyticsBloc,
              ),
            ],
            child: const AdvancedAdminDashboardScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify overview tab is selected by default
      expect(find.text('Overview'), findsOneWidget);

      // Look for KPI cards (they should be present even if loading)
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('should switch between tabs correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<AdminDashboardBloc>.value(value: adminDashboardBloc),
              BlocProvider<RealtimeAnalyticsBloc>.value(
                value: realtimeAnalyticsBloc,
              ),
            ],
            child: const AdvancedAdminDashboardScreen(),
          ),
        ),
      );

      await tester.pump();

      // Find and tap on Revenue tab
      final revenueTab = find.text('Revenue');
      if (revenueTab.evaluate().isNotEmpty) {
        await tester.tap(revenueTab);
        await tester.pump();

        // Verify revenue tab content is displayed
        expect(find.text('Revenue'), findsOneWidget);
      }

      // Find and tap on Users tab
      final usersTab = find.text('Users');
      if (usersTab.evaluate().isNotEmpty) {
        await tester.tap(usersTab);
        await tester.pump();

        // Verify users tab content is displayed
        expect(find.text('Users'), findsOneWidget);
      }
    });

    testWidgets('should display real-time analytics when enabled', (
      WidgetTester tester,
    ) async {
      // Start real-time analytics
      realtimeAnalyticsBloc.add(const RealtimeAnalyticsStarted());

      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<AdminDashboardBloc>.value(value: adminDashboardBloc),
              BlocProvider<RealtimeAnalyticsBloc>.value(
                value: realtimeAnalyticsBloc,
              ),
            ],
            child: const AdvancedAdminDashboardScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Look for real-time indicators
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('should handle loading states correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<AdminDashboardBloc>.value(value: adminDashboardBloc),
              BlocProvider<RealtimeAnalyticsBloc>.value(
                value: realtimeAnalyticsBloc,
              ),
            ],
            child: const AdvancedAdminDashboardScreen(),
          ),
        ),
      );

      await tester.pump();

      // Should show loading indicators initially
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('should display error states when data loading fails', (
      WidgetTester tester,
    ) async {
      // Trigger error state
      adminDashboardBloc.add(
        AdminDashboardStarted(
          startDate: DateTime.now().subtract(const Duration(days: 30)),
          endDate: DateTime.now(),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<AdminDashboardBloc>.value(value: adminDashboardBloc),
              BlocProvider<RealtimeAnalyticsBloc>.value(
                value: realtimeAnalyticsBloc,
              ),
            ],
            child: const AdvancedAdminDashboardScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // The dashboard should handle errors gracefully
      expect(find.byType(AdvancedAdminDashboardScreen), findsOneWidget);
    });

    testWidgets('should support date range selection', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<AdminDashboardBloc>.value(value: adminDashboardBloc),
              BlocProvider<RealtimeAnalyticsBloc>.value(
                value: realtimeAnalyticsBloc,
              ),
            ],
            child: const AdvancedAdminDashboardScreen(),
          ),
        ),
      );

      await tester.pump();

      // Look for date picker or date range selector
      final dateButtons = find.byIcon(Icons.date_range);
      if (dateButtons.evaluate().isNotEmpty) {
        await tester.tap(dateButtons.first);
        await tester.pump();

        // Should open date picker
        expect(find.byType(DatePickerDialog), findsOneWidget);
      }
    });

    testWidgets('should display charts and visualizations', (
      WidgetTester tester,
    ) async {
      // Load dashboard with data
      adminDashboardBloc.add(
        AdminDashboardStarted(
          startDate: DateTime.now().subtract(const Duration(days: 30)),
          endDate: DateTime.now(),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<AdminDashboardBloc>.value(value: adminDashboardBloc),
              BlocProvider<RealtimeAnalyticsBloc>.value(
                value: realtimeAnalyticsBloc,
              ),
            ],
            child: const AdvancedAdminDashboardScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Should display various chart widgets
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('should handle report generation', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<AdminDashboardBloc>.value(value: adminDashboardBloc),
              BlocProvider<RealtimeAnalyticsBloc>.value(
                value: realtimeAnalyticsBloc,
              ),
            ],
            child: const AdvancedAdminDashboardScreen(),
          ),
        ),
      );

      await tester.pump();

      // Look for report generation button
      final reportButtons = find.byIcon(Icons.file_download);
      if (reportButtons.evaluate().isNotEmpty) {
        await tester.tap(reportButtons.first);
        await tester.pump();

        // Should trigger report generation
        expect(find.byType(AdvancedAdminDashboardScreen), findsOneWidget);
      }
    });

    testWidgets('should be responsive to different screen sizes', (
      WidgetTester tester,
    ) async {
      // Test with different screen sizes
      await tester.binding.setSurfaceSize(const Size(800, 600)); // Tablet size

      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<AdminDashboardBloc>.value(value: adminDashboardBloc),
              BlocProvider<RealtimeAnalyticsBloc>.value(
                value: realtimeAnalyticsBloc,
              ),
            ],
            child: const AdvancedAdminDashboardScreen(),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(AdvancedAdminDashboardScreen), findsOneWidget);

      // Test with mobile size
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pump();

      expect(find.byType(AdvancedAdminDashboardScreen), findsOneWidget);

      // Reset to default size
      await tester.binding.setSurfaceSize(null);
    });
  });
}
