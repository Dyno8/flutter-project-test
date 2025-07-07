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
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Firebase services
  await FirebaseService().initialize();

  // Initialize dependency injection
  await di.init();

  // Initialize and configure notification service
  final notificationService = di.sl<NotificationService>();
  await notificationService.initialize();

  // Set up notification service with repository and action handler
  notificationService.setRepository(di.sl<NotificationRepository>());
  notificationService.setActionHandler(di.sl<NotificationActionHandler>());

  runApp(const CareNowApp());
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
