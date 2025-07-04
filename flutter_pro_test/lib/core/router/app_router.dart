import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String clientHome = '/client';
  static const String partnerHome = '/partner';
  static const String serviceSelection = '/services';
  static const String booking = '/booking';
  static const String profile = '/profile';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    routes: [
      // Splash Screen
      GoRoute(
        path: splash,
        builder: (context, state) => const SplashScreen(),
      ),
      
      // Authentication Routes
      GoRoute(
        path: login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: register,
        builder: (context, state) => const RegisterScreen(),
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
            builder: (context, state) => const BookingScreen(),
          ),
          GoRoute(
            path: 'profile',
            builder: (context, state) => const ClientProfileScreen(),
          ),
        ],
      ),
      
      // Partner Routes
      GoRoute(
        path: partnerHome,
        builder: (context, state) => const PartnerHomeScreen(),
        routes: [
          GoRoute(
            path: 'profile',
            builder: (context, state) => const PartnerProfileScreen(),
          ),
        ],
      ),
    ],
  );
}

// Placeholder screens - will be implemented later
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite, size: 64, color: Colors.blue),
            SizedBox(height: 16),
            Text('CareNow', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Chăm sóc tận tâm, phục vụ tận nhà'),
          ],
        ),
      ),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng nhập')),
      body: const Center(child: Text('Login Screen - Coming Soon')),
    );
  }
}

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng ký')),
      body: const Center(child: Text('Register Screen - Coming Soon')),
    );
  }
}

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
    return Scaffold(
      appBar: AppBar(title: const Text('CareNow - Đối tác')),
      body: const Center(child: Text('Partner Home - Coming Soon')),
    );
  }
}

class ServiceSelectionScreen extends StatelessWidget {
  const ServiceSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chọn dịch vụ')),
      body: const Center(child: Text('Service Selection - Coming Soon')),
    );
  }
}

class BookingScreen extends StatelessWidget {
  const BookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đặt lịch')),
      body: const Center(child: Text('Booking Screen - Coming Soon')),
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
