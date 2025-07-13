import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';

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
import 'firebase_options.dart';

void main() async {
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

    // Initialize Firebase
    if (EnvironmentConfig.isDebug) {
      print('🔥 Initializing Firebase...');
    }
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (EnvironmentConfig.isDebug) {
      print('✅ Firebase initialized successfully');
    }

    // Initialize Firebase services
    print('🔧 Initializing Firebase services...');
    await FirebaseService().initialize();
    print('✅ Firebase services initialized');

    // Initialize dependency injection first
    print('💉 Initializing dependency injection...');
    await di.init();
    print('✅ Dependency injection initialized');

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
    notificationService.setActionHandler(di.sl<NotificationActionHandler>());
    print('✅ Notification service configured');

    print('🎉 All services initialized successfully. Starting app...');
    runApp(const MinimalCareNowApp());
  } catch (e, stackTrace) {
    print('❌ Error during app initialization: $e');
    print('Stack trace: $stackTrace');

    // Run a minimal error app
    runApp(
      MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.red,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.white),
                const SizedBox(height: 16),
                const Text(
                  'Initialization Error',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Error: $e',
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
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
