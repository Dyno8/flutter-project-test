import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';

/// Login screen for user authentication
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isEmailLogin = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          } else if (state is AuthAuthenticated) {
            // Navigate to appropriate home screen based on user role
            // This will be handled by the navigation flow
            context.go(AppRouter.clientHome);
          } else if (state is AuthPhoneCodeSent) {
            // Navigate to OTP verification screen
            context.push('/verify-phone', extra: {
              'verificationId': state.verificationId,
              'phoneNumber': state.phoneNumber,
            });
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 40.h),
                  _buildHeader(),
                  SizedBox(height: 40.h),
                  _buildLoginMethodToggle(),
                  SizedBox(height: 32.h),
                  _buildLoginForm(),
                  SizedBox(height: 24.h),
                  _buildLoginButton(),
                  SizedBox(height: 16.h),
                  _buildForgotPasswordButton(),
                  SizedBox(height: 32.h),
                  _buildDivider(),
                  SizedBox(height: 32.h),
                  _buildSignUpPrompt(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chào mừng trở lại!',
          style: TextStyle(
            fontSize: 32.sp,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Đăng nhập để tiếp tục sử dụng CareNow',
          style: TextStyle(
            fontSize: 16.sp,
            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginMethodToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isEmailLogin = true),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                decoration: BoxDecoration(
                  color: _isEmailLogin
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  'Email',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: _isEmailLogin
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isEmailLogin = false),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                decoration: BoxDecoration(
                  color: !_isEmailLogin
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  'Số điện thoại',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: !_isEmailLogin
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        AuthTextField(
          label: _isEmailLogin ? 'Email' : 'Số điện thoại',
          hint: _isEmailLogin ? 'Nhập email của bạn' : 'Nhập số điện thoại',
          controller: _emailController,
          keyboardType: _isEmailLogin
              ? TextInputType.emailAddress
              : TextInputType.phone,
          prefixIcon: Icon(
            _isEmailLogin ? Icons.email_outlined : Icons.phone_outlined,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return _isEmailLogin
                  ? 'Vui lòng nhập email'
                  : 'Vui lòng nhập số điện thoại';
            }
            if (_isEmailLogin) {
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(value)) {
                return 'Email không hợp lệ';
              }
            } else {
              if (!RegExp(r'^(\+84|84|0)(3|5|7|8|9)([0-9]{8})$')
                  .hasMatch(value)) {
                return 'Số điện thoại không hợp lệ';
              }
            }
            return null;
          },
        ),
        if (_isEmailLogin) ...[
          SizedBox(height: 20.h),
          AuthTextField(
            label: 'Mật khẩu',
            hint: 'Nhập mật khẩu của bạn',
            controller: _passwordController,
            isPassword: true,
            prefixIcon: Icon(
              Icons.lock_outlined,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập mật khẩu';
              }
              if (value.length < 6) {
                return 'Mật khẩu phải có ít nhất 6 ký tự';
              }
              return null;
            },
          ),
        ],
      ],
    );
  }

  Widget _buildLoginButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return AuthButton(
          text: _isEmailLogin ? 'Đăng nhập' : 'Gửi mã xác thực',
          isLoading: state is AuthInProgress,
          onPressed: _handleLogin,
        );
      },
    );
  }

  Widget _buildForgotPasswordButton() {
    if (!_isEmailLogin) return const SizedBox.shrink();
    
    return Center(
      child: TextButton(
        onPressed: () {
          // Navigate to forgot password screen
          context.push('/forgot-password');
        },
        child: Text(
          'Quên mật khẩu?',
          style: TextStyle(
            fontSize: 16.sp,
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            'hoặc',
            style: TextStyle(
              fontSize: 14.sp,
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpPrompt() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Chưa có tài khoản? ',
            style: TextStyle(
              fontSize: 16.sp,
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
            ),
          ),
          TextButton(
            onPressed: () {
              context.push(AppRouter.register);
            },
            child: Text(
              'Đăng ký ngay',
              style: TextStyle(
                fontSize: 16.sp,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleLogin() {
    if (!_formKey.currentState!.validate()) return;

    final authBloc = context.read<AuthBloc>();

    if (_isEmailLogin) {
      authBloc.add(SignInWithEmailRequested(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ));
    } else {
      authBloc.add(SignInWithPhoneRequested(
        phoneNumber: _emailController.text.trim(),
      ));
    }
  }
}
