import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../auth/presentation/widgets/auth_text_field.dart';
import '../../../../shared/animations/button_animations.dart';

import '../bloc/admin_auth_bloc.dart';
import '../widgets/admin_app_bar.dart';

/// Admin login screen
class AdminLoginScreen extends StatefulWidget {
  static const String routeName = '/admin-login';

  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    // Start animations
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AdminAppBar(title: 'Admin Login', showBackButton: false),
      body: BlocListener<AdminAuthBloc, AdminAuthState>(
        listener: (context, state) {
          if (state is AdminAuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state is AdminAuthenticated) {
            Navigator.of(context).pushReplacementNamed('/admin-dashboard');
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 60.h),
                    _buildHeader(),
                    SizedBox(height: 60.h),
                    _buildLoginForm(),
                    SizedBox(height: 40.h),
                    _buildLoginButton(),
                    SizedBox(height: 24.h),
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80.w,
          height: 80.h,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(
            Icons.admin_panel_settings,
            color: Colors.white,
            size: 40.sp,
          ),
        ),
        SizedBox(height: 24.h),
        Text(
          'CareNow Admin',
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Sign in to access the admin dashboard',
          style: TextStyle(fontSize: 16.sp, color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          AuthTextField(
            controller: _emailController,
            label: 'Email Address',
            hint: 'Enter your admin email',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icon(Icons.email_outlined),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          SizedBox(height: 20.h),
          AuthTextField(
            controller: _passwordController,
            label: 'Password',
            hint: 'Enter your password',
            isPassword: true,
            prefixIcon: Icon(Icons.lock_outlined),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (value.length < 8) {
                return 'Password must be at least 8 characters';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return BlocBuilder<AdminAuthBloc, AdminAuthState>(
      builder: (context, state) {
        final isLoading = state is AdminAuthLoading;

        return AnimatedButton(
          text: 'Sign In',
          onPressed: isLoading ? null : _handleLogin,
          isLoading: isLoading,
          animationType: ButtonAnimationType.scale,
          backgroundColor: AppColors.primary,
          textColor: Colors.white,
          height: 56.h,
          icon: isLoading
              ? null
              : Icon(Icons.login, color: Colors.white, size: 20.sp),
        );
      },
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Divider(color: AppColors.border, thickness: 1),
        SizedBox(height: 16.h),
        Text(
          'Secure Admin Access',
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.security, size: 16.sp, color: AppColors.success),
            SizedBox(width: 8.w),
            Text(
              'Protected by Firebase Authentication',
              style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary),
            ),
          ],
        ),
      ],
    );
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AdminAuthBloc>().add(
        AdminLoginRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }
}
