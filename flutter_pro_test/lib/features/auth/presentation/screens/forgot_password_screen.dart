import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';

/// Screen for password reset functionality
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onBackground,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          } else if (state is AuthPasswordResetSent) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Email khôi phục mật khẩu đã được gửi đến ${state.email}'),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            );
            context.pop();
          }
        },
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  SizedBox(height: 40.h),
                  _buildEmailForm(),
                  SizedBox(height: 32.h),
                  _buildResetButton(),
                  const Spacer(),
                  _buildBackToLoginButton(),
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
          'Quên mật khẩu?',
          style: TextStyle(
            fontSize: 32.sp,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Nhập email của bạn để nhận liên kết khôi phục mật khẩu',
          style: TextStyle(
            fontSize: 16.sp,
            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailForm() {
    return AuthTextField(
      label: 'Email',
      hint: 'Nhập email của bạn',
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      prefixIcon: Icon(
        Icons.email_outlined,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng nhập email';
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Email không hợp lệ';
        }
        return null;
      },
    );
  }

  Widget _buildResetButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return AuthButton(
          text: 'Gửi email khôi phục',
          isLoading: state is AuthInProgress,
          onPressed: _handlePasswordReset,
        );
      },
    );
  }

  Widget _buildBackToLoginButton() {
    return Center(
      child: TextButton(
        onPressed: () => context.pop(),
        child: Text(
          'Quay lại đăng nhập',
          style: TextStyle(
            fontSize: 16.sp,
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _handlePasswordReset() {
    if (!_formKey.currentState!.validate()) return;

    final authBloc = context.read<AuthBloc>();
    authBloc.add(SendPasswordResetRequested(
      email: _emailController.text.trim(),
    ));
  }
}
