import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/router/app_router.dart';
import 'core/di/injection_container.dart' as di;
import 'shared/theme/app_theme.dart';
import 'shared/services/firebase_service.dart';
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

    print('🚀 Starting CareNow MVP...');

    // Initialize Firebase
    print('🔥 Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');

    // Initialize Firebase services
    print('🔧 Initializing Firebase services...');
    await FirebaseService().initialize();
    print('✅ Firebase services initialized');

    // Initialize dependency injection
    print('💉 Initializing dependency injection...');
    await di.init();
    print('✅ Dependency injection initialized');

    // Initialize and configure notification service
    print('🔔 Initializing notification service...');
    final notificationService = di.sl<NotificationService>();
    await notificationService.initialize();

    // Set up notification service with repository and action handler
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
          title: 'CareNow Admin',
          theme: AppTheme.lightTheme,
          routerConfig: AppRouter.router,
          debugShowCheckedModeBanner: false,
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
