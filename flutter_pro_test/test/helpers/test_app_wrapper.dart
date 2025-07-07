import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_pro_test/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_pro_test/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:flutter_pro_test/features/booking/presentation/bloc/booking_bloc.dart';
import 'package:flutter_pro_test/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:flutter_pro_test/shared/theme/app_theme.dart';

import 'test_injection_container.dart';

/// Test wrapper for the app that doesn't require Firebase initialization
class TestAppWrapper extends StatelessWidget {
  final Widget child;
  final GoRouter? router;

  const TestAppWrapper({
    super.key,
    required this.child,
    this.router,
  });

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, _) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>(create: (context) => testSl<AuthBloc>()),
            BlocProvider<ProfileBloc>(create: (context) => testSl<ProfileBloc>()),
            BlocProvider<BookingBloc>(create: (context) => testSl<BookingBloc>()),
            BlocProvider<NotificationBloc>(create: (context) => testSl<NotificationBloc>()),
          ],
          child: MaterialApp(
            title: 'CareNow MVP Test',
            theme: AppTheme.lightTheme,
            home: child,
          ),
        );
      },
    );
  }
}

/// Simple splash screen for testing
class TestSplashScreen extends StatelessWidget {
  const TestSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'CareNow MVP\nComing Soon...',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
