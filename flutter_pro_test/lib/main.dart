import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/monitoring/monitoring_service.dart';
import 'core/router/app_router.dart';
import 'core/di/injection_container.dart' as di;
import 'core/config/environment_config.dart';
import 'shared/theme/app_theme.dart';
import 'shared/services/firebase_service.dart';
import 'core/analytics/firebase_analytics_service.dart';
import 'core/analytics/business_analytics_service.dart';
import 'core/error_tracking/error_tracking_service.dart';
import 'core/performance/performance_analytics_service.dart';
import 'shared/services/notification_service.dart';
import 'shared/services/notification_action_handler.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'features/booking/presentation/bloc/booking_bloc.dart';
import 'features/notifications/presentation/bloc/notification_bloc.dart';
import 'features/notifications/domain/repositories/notification_repository.dart';

import 'core/utils/firebase_initializer.dart';

void main() async {
  // Wrap everything in a top-level error handler for mobile compatibility
  runZonedGuarded(
    () async {
      try {
        WidgetsFlutterBinding.ensureInitialized();

        // Initialize environment configuration
        if (EnvironmentConfig.isDebug) {
          print('🚀 Starting CareNow MVP...');
          EnvironmentConfig.printEnvironmentInfo();
        }

        // Validate environment configuration
        if (!EnvironmentConfig.validateConfiguration()) {
          throw Exception('Invalid environment configuration');
        }

        // Initialize Firebase safely
        if (EnvironmentConfig.isDebug) {
          print('🔥 Initializing Firebase...');
        }
        try {
          await FirebaseInitializer.initializeSafely();
          if (EnvironmentConfig.isDebug) {
            print('✅ Firebase initialized successfully');
          }
        } catch (e) {
          print('❌ Firebase initialization failed: $e');
          // Continue without Firebase for debugging
          runApp(const MobileFallbackApp());
          return;
        }

        // Initialize Firebase services
        print('🔧 Initializing Firebase services...');
        await FirebaseService().initialize();
        print('✅ Firebase services initialized');

        // Initialize dependency injection first with error handling
        print('💉 Initializing dependency injection...');
        try {
          await di.init();
          print('✅ Dependency injection initialized');
        } catch (e, stackTrace) {
          print('❌ Dependency injection failed: $e');
          print('Stack trace: $stackTrace');
          // Continue with minimal app initialization
          runApp(const MobileFallbackApp());
          return;
        }

        // Initialize Firebase Analytics service
        print('📊 Initializing Firebase Analytics...');
        final analyticsService = di.sl<FirebaseAnalyticsService>();
        await analyticsService.initialize();
        print('✅ Firebase Analytics initialized');

        // Initialize monitoring service with analytics integration
        print('🔍 Initializing monitoring service...');
        final monitoringService = di.sl<MonitoringService>();
        await monitoringService.initialize(analyticsService: analyticsService);
        print('✅ Monitoring service initialized');

        // Initialize business analytics service
        print('📊 Initializing business analytics...');
        final businessAnalytics = di.sl<BusinessAnalyticsService>();
        await businessAnalytics.initialize(
          analyticsService: analyticsService,
          monitoringService: monitoringService,
        );

        // Initialize user behavior tracking
        final behaviorTracking = di.sl<UserBehaviorTrackingService>();
        behaviorTracking.initialize(
          businessAnalytics: businessAnalytics,
          monitoringService: monitoringService,
        );
        print('✅ Business analytics initialized');

        // Initialize error tracking and incident management
        print('🚨 Initializing error tracking...');
        final errorTracking = di.sl<ErrorTrackingService>();
        final notificationService = di.sl<NotificationService>();
        await errorTracking.initialize(
          analyticsService: analyticsService,
          monitoringService: monitoringService,
          notificationService: notificationService,
        );

        final incidentManagement = di.sl<IncidentManagementService>();
        await incidentManagement.initialize(
          errorTrackingService: errorTracking,
          notificationService: notificationService,
          monitoringService: monitoringService,
        );
        print('✅ Error tracking initialized');

        // Initialize performance analytics
        print('📈 Initializing performance analytics...');
        final performanceAnalytics = di.sl<PerformanceAnalyticsService>();
        await performanceAnalytics.initialize(
          analyticsService: analyticsService,
          monitoringService: monitoringService,
          errorTrackingService: errorTracking,
        );
        print('✅ Performance analytics initialized');

        // Configure notification service with repository and action handler
        print('🔔 Configuring notification service...');
        notificationService.setRepository(di.sl<NotificationRepository>());
        notificationService.setActionHandler(
          di.sl<NotificationActionHandler>(),
        );
        print('✅ Notification service configured');

        print('🎉 All services initialized successfully. Starting app...');
        runApp(const CareNowApp());
      } catch (e, stackTrace) {
        print('❌ Error during app initialization: $e');
        print('Stack trace: $stackTrace');

        // Run mobile-friendly fallback app instead of red error screen
        runApp(const MobileFallbackApp());
      }
    },
    (error, stackTrace) {
      // Top-level error handler for mobile compatibility issues
      print('❌ Top-level error caught: $error');
      print('Stack trace: $stackTrace');

      // Always show mobile-friendly fallback for any unhandled errors
      runApp(const MobileFallbackApp());
    },
  );
}

class MinimalCareNowApp extends StatelessWidget {
  const MinimalCareNowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone X design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: EnvironmentConfig.appName,
          theme: AppTheme.lightTheme,
          routerConfig: AppRouter.router,
          debugShowCheckedModeBanner: EnvironmentConfig.isDebug,
        );
      },
    );
  }
}

class CareNowApp extends StatelessWidget {
  const CareNowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone X design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>(create: (context) => di.sl<AuthBloc>()),
            BlocProvider<ProfileBloc>(
              create: (context) => di.sl<ProfileBloc>(),
            ),
            BlocProvider<BookingBloc>(
              create: (context) => di.sl<BookingBloc>(),
            ),
            BlocProvider<NotificationBloc>(
              create: (context) => di.sl<NotificationBloc>(),
            ),
          ],
          child: _AppWithNotificationSetup(),
        );
      },
    );
  }
}

class _AppWithNotificationSetup extends StatefulWidget {
  @override
  State<_AppWithNotificationSetup> createState() =>
      _AppWithNotificationSetupState();
}

class _AppWithNotificationSetupState extends State<_AppWithNotificationSetup> {
  @override
  void initState() {
    super.initState();
    // Set up notification action handler with router context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final actionHandler = di.sl<NotificationActionHandler>();
      actionHandler.setNavigationContext(context, AppRouter.router);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'CareNow',
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Mobile-friendly fallback app for when dependency injection fails
class MobileFallbackApp extends StatelessWidget {
  const MobileFallbackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CareNow',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const MobileFallbackScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MobileFallbackScreen extends StatelessWidget {
  const MobileFallbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite, size: 64, color: Colors.blue[600]),
              const SizedBox(height: 24),
              Text(
                'CareNow',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Dịch vụ chăm sóc sức khỏe tại nhà',
                style: TextStyle(fontSize: 16, color: Colors.blue[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(Icons.smartphone, size: 48, color: Colors.blue[600]),
                    const SizedBox(height: 16),
                    const Text(
                      'Ứng dụng đang được tối ưu hóa cho thiết bị di động',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Vui lòng thử lại sau hoặc sử dụng trên máy tính để có trải nghiệm tốt nhất',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        // Reload functionality can be added here
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
