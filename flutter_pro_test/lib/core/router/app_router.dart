import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/phone_verification_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';

import '../../features/booking/presentation/screens/service_selection_screen.dart';
import '../../features/booking/presentation/screens/datetime_selection_screen.dart';
import '../../features/booking/presentation/screens/partner_selection_screen.dart';
import '../../features/booking/presentation/screens/booking_confirmation_screen.dart';
import '../../features/partner/presentation/screens/partner_dashboard_screen.dart';
import '../../features/client/presentation/screens/payment_method_selection_screen.dart';
import '../../features/client/presentation/screens/payment_processing_screen.dart';
import '../../features/booking/presentation/screens/booking_tracking_screen.dart';
import '../../features/admin/presentation/screens/simple_admin_dashboard_screen.dart';
import '../../features/admin/presentation/pages/analytics_dashboard_page.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String verifyPhone = '/verify-phone';
  static const String forgotPassword = '/forgot-password';
  static const String clientHome = '/client';
  static const String partnerHome = '/partner';
  static const String serviceSelection = '/services';
  static const String booking = '/booking';
  static const String bookingTracking = '/booking/tracking';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';

  // Partner routes
  static const String partnerDashboard = '/partner/dashboard';
  static const String partnerJobDetails = '/partner/job-details';
  static const String partnerJobHistory = '/partner/job-history';
  static const String partnerEarnings = '/partner/earnings';
  static const String partnerSettings = '/partner/settings';

  // Admin routes
  static const String adminDashboard = '/admin/dashboard';
  static const String adminAnalytics = '/admin/analytics';

  static final GoRouter router = GoRouter(
    initialLocation:
        splash, // Start with splash screen for proper authentication flow
    routes: [
      // Splash Screen
      GoRoute(path: splash, builder: (context, state) => const SplashScreen()),

      // Authentication Routes
      GoRoute(path: login, builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: verifyPhone,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return PhoneVerificationScreen(
            verificationId: extra?['verificationId'] ?? '',
            phoneNumber: extra?['phoneNumber'] ?? '',
          );
        },
      ),
      GoRoute(
        path: forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Client Routes
      GoRoute(
        path: clientHome,
        builder: (context, state) => const ClientHomeScreen(),
        routes: [
          GoRoute(
            path: 'services',
            builder: (context, state) => const ServiceSelectionScreen(),
          ),
          GoRoute(
            path: 'booking',
            builder: (context, state) => const ServiceSelectionScreen(),
            routes: [
              GoRoute(
                path: 'datetime',
                builder: (context, state) => const DateTimeSelectionScreen(),
              ),
              GoRoute(
                path: 'partners',
                builder: (context, state) => const PartnerSelectionScreen(),
              ),
              GoRoute(
                path: 'confirmation',
                builder: (context, state) => const BookingConfirmationScreen(),
              ),
              GoRoute(
                path: 'payment-method',
                builder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>?;
                  return PaymentMethodSelectionScreen(
                    service: extra?['service'],
                    hours: extra?['hours'] ?? 0.0,
                    totalPrice: extra?['totalPrice'] ?? 0.0,
                    isUrgent: extra?['isUrgent'] ?? false,
                  );
                },
              ),
              GoRoute(
                path: 'payment-processing',
                builder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>?;
                  return PaymentProcessingScreen(
                    service: extra?['service'],
                    hours: extra?['hours'] ?? 0.0,
                    totalPrice: extra?['totalPrice'] ?? 0.0,
                    paymentMethod: extra?['paymentMethod'],
                    isUrgent: extra?['isUrgent'] ?? false,
                    bookingId: extra?['bookingId'],
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: 'booking-tracking/:bookingId',
            builder: (context, state) {
              final bookingId = state.pathParameters['bookingId']!;
              final extra = state.extra as Map<String, dynamic>?;
              return BookingTrackingScreen(
                bookingId: bookingId,
                booking: extra?['booking'],
                isPartnerView: extra?['isPartnerView'] ?? false,
              );
            },
          ),
          GoRoute(
            path: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // Partner Routes
      GoRoute(
        path: partnerHome,
        builder: (context, state) => const PartnerHomeScreen(),
        routes: [
          GoRoute(
            path: 'dashboard',
            builder: (context, state) {
              final partnerId =
                  state.pathParameters['partnerId'] ??
                  state.uri.queryParameters['partnerId'] ??
                  '';
              return PartnerDashboardScreen(partnerId: partnerId);
            },
          ),
          GoRoute(
            path: 'job-details/:jobId',
            builder: (context, state) {
              final jobId = state.pathParameters['jobId']!;
              return JobDetailsScreen(jobId: jobId);
            },
          ),
          GoRoute(
            path: 'job-history',
            builder: (context, state) {
              final partnerId = state.uri.queryParameters['partnerId'] ?? '';
              return JobHistoryScreen(partnerId: partnerId);
            },
          ),
          GoRoute(
            path: 'earnings',
            builder: (context, state) {
              final partnerId = state.uri.queryParameters['partnerId'] ?? '';
              return EarningsScreen(partnerId: partnerId);
            },
          ),
          GoRoute(
            path: 'settings',
            builder: (context, state) => const PartnerSettingsScreen(),
          ),
          GoRoute(
            path: 'job-tracking/:bookingId',
            builder: (context, state) {
              final bookingId = state.pathParameters['bookingId']!;
              final extra = state.extra as Map<String, dynamic>?;
              return BookingTrackingScreen(
                bookingId: bookingId,
                booking: extra?['booking'],
                isPartnerView: true,
              );
            },
          ),
          GoRoute(
            path: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // Admin Routes (Protected)
      GoRoute(
        path: adminDashboard,
        builder: (context, state) =>
            const AdminAuthGuard(child: SimpleAdminDashboardScreen()),
      ),
      GoRoute(
        path: adminAnalytics,
        builder: (context, state) =>
            const AdminAuthGuard(child: AnalyticsDashboardPage()),
      ),
    ],
  );
}

// Admin Authentication Guard
class AdminAuthGuard extends StatelessWidget {
  final Widget child;

  const AdminAuthGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // For now, show a simple admin login screen
    // In a real implementation, this would check admin authentication status
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.admin_panel_settings,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Admin Access Required',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Please contact system administrator for access',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go(AppRouter.login),
              child: const Text('Back to Login'),
            ),
          ],
        ),
      ),
    );
  }
}

// Splash screen with authentication state handling
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  void _checkAuthStatus() async {
    // Add a small delay for splash screen effect
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      // Check authentication status and navigate accordingly
      // This will be handled by the AuthBloc in the main app
      context.read<AuthBloc>().add(const AuthStatusRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // Navigate to appropriate home screen based on user role
          // For now, default to client home
          context.go(AppRouter.clientHome);
        } else if (state is AuthUnauthenticated) {
          context.go(AppRouter.login);
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.favorite,
                size: 64,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              const SizedBox(height: 16),
              Text(
                'CareNow',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Chăm sóc tận tâm, phục vụ tận nhà',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(
                    context,
                  ).colorScheme.onPrimary.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 32),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Placeholder screens are now replaced by actual authentication screens
// LoginScreen, RegisterScreen, PhoneVerificationScreen, and ForgotPasswordScreen
// are imported from their respective files

class ClientHomeScreen extends StatelessWidget {
  const ClientHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CareNow - Khách hàng')),
      body: const Center(child: Text('Client Home - Coming Soon')),
    );
  }
}

class PartnerHomeScreen extends StatelessWidget {
  const PartnerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // For now, redirect to dashboard with a placeholder partner ID
    // In a real app, you would get the partner ID from authentication
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.go('/partner/dashboard?partnerId=demo-partner-id');
    });

    return Scaffold(
      appBar: AppBar(title: const Text('CareNow - Đối tác')),
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}

class ClientProfileScreen extends StatelessWidget {
  const ClientProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hồ sơ')),
      body: const Center(child: Text('Client Profile - Coming Soon')),
    );
  }
}

class PartnerProfileScreen extends StatelessWidget {
  const PartnerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hồ sơ đối tác')),
      body: const Center(child: Text('Partner Profile - Coming Soon')),
    );
  }
}

// Partner Dashboard Screens (Placeholders for missing screens)

class JobDetailsScreen extends StatelessWidget {
  final String jobId;

  const JobDetailsScreen({super.key, required this.jobId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Job Details')),
      body: Center(child: Text('Job Details for: $jobId')),
    );
  }
}

class JobHistoryScreen extends StatelessWidget {
  final String partnerId;

  const JobHistoryScreen({super.key, required this.partnerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Job History')),
      body: Center(child: Text('Job History for partner: $partnerId')),
    );
  }
}

class EarningsScreen extends StatelessWidget {
  final String partnerId;

  const EarningsScreen({super.key, required this.partnerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Earnings')),
      body: Center(child: Text('Earnings for partner: $partnerId')),
    );
  }
}

class PartnerSettingsScreen extends StatelessWidget {
  const PartnerSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(child: Text('Partner Settings - Coming Soon')),
    );
  }
}
