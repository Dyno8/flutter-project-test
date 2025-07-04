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

/// Register screen for new user registration
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _selectedRole = 'client';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
          } else if (state is AuthAuthenticated) {
            // Navigate to role selection or appropriate home screen
            if (_selectedRole == 'client') {
              context.go(AppRouter.clientHome);
            } else {
              context.go(AppRouter.partnerHome);
            }
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
                  _buildHeader(),
                  SizedBox(height: 32.h),
                  _buildRoleSelection(),
                  SizedBox(height: 24.h),
                  _buildRegistrationForm(),
                  SizedBox(height: 32.h),
                  _buildRegisterButton(),
                  SizedBox(height: 16.h),
                  _buildLoginPrompt(),
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
          'Tạo tài khoản mới',
          style: TextStyle(
            fontSize: 32.sp,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Đăng ký để bắt đầu sử dụng CareNow',
          style: TextStyle(
            fontSize: 16.sp,
            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bạn là:',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
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
                  onTap: () => setState(() => _selectedRole = 'client'),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    decoration: BoxDecoration(
                      color: _selectedRole == 'client'
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.person_outline,
                          color: _selectedRole == 'client'
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSurface,
                          size: 24.sp,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Khách hàng',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: _selectedRole == 'client'
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'Đặt dịch vụ',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: _selectedRole == 'client'
                                ? Theme.of(context).colorScheme.onPrimary.withOpacity(0.8)
                                : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedRole = 'partner'),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    decoration: BoxDecoration(
                      color: _selectedRole == 'partner'
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.work_outline,
                          color: _selectedRole == 'partner'
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSurface,
                          size: 24.sp,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Đối tác',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: _selectedRole == 'partner'
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'Cung cấp dịch vụ',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: _selectedRole == 'partner'
                                ? Theme.of(context).colorScheme.onPrimary.withOpacity(0.8)
                                : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRegistrationForm() {
    return Column(
      children: [
        AuthTextField(
          label: 'Họ và tên',
          hint: 'Nhập họ và tên của bạn',
          controller: _nameController,
          prefixIcon: Icon(
            Icons.person_outline,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Vui lòng nhập họ và tên';
            }
            if (value.trim().length < 2) {
              return 'Họ và tên phải có ít nhất 2 ký tự';
            }
            return null;
          },
        ),
        SizedBox(height: 20.h),
        AuthTextField(
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
        ),
        SizedBox(height: 20.h),
        AuthTextField(
          label: 'Mật khẩu',
          hint: 'Nhập mật khẩu (ít nhất 6 ký tự)',
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
        SizedBox(height: 20.h),
        AuthTextField(
          label: 'Xác nhận mật khẩu',
          hint: 'Nhập lại mật khẩu',
          controller: _confirmPasswordController,
          isPassword: true,
          prefixIcon: Icon(
            Icons.lock_outlined,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng xác nhận mật khẩu';
            }
            if (value != _passwordController.text) {
              return 'Mật khẩu không khớp';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return AuthButton(
          text: 'Đăng ký',
          isLoading: state is AuthInProgress,
          onPressed: _handleRegister,
        );
      },
    );
  }

  Widget _buildLoginPrompt() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Đã có tài khoản? ',
            style: TextStyle(
              fontSize: 16.sp,
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
            ),
          ),
          TextButton(
            onPressed: () {
              context.pop();
            },
            child: Text(
              'Đăng nhập ngay',
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

  void _handleRegister() {
    if (!_formKey.currentState!.validate()) return;

    final authBloc = context.read<AuthBloc>();
    authBloc.add(SignUpWithEmailRequested(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
      displayName: _nameController.text.trim(),
    ));
  }
}
