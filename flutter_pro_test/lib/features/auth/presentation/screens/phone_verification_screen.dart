import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_button.dart';

/// Screen for phone number verification with OTP
class PhoneVerificationScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;

  const PhoneVerificationScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  State<PhoneVerificationScreen> createState() => _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );

  Timer? _timer;
  int _remainingSeconds = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _remainingSeconds = 60;
    _canResend = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      }
    });
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
            // Navigate to appropriate home screen
            context.go(AppRouter.clientHome);
          }
        },
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                SizedBox(height: 40.h),
                _buildOTPInput(),
                SizedBox(height: 32.h),
                _buildVerifyButton(),
                SizedBox(height: 24.h),
                _buildResendSection(),
                const Spacer(),
                _buildChangeNumberButton(),
              ],
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
          'Xác thực số điện thoại',
          style: TextStyle(
            fontSize: 32.sp,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        SizedBox(height: 8.h),
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 16.sp,
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
            ),
            children: [
              const TextSpan(text: 'Chúng tôi đã gửi mã xác thực đến số '),
              TextSpan(
                text: widget.phoneNumber,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOTPInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nhập mã xác thực',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) => _buildOTPField(index)),
        ),
      ],
    );
  }

  Widget _buildOTPField(int index) {
    return Container(
      width: 48.w,
      height: 56.h,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: _controllers[index].text.isNotEmpty
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outline.withOpacity(0.5),
          width: _controllers[index].text.isNotEmpty ? 2 : 1.5,
        ),
      ),
      child: TextFormField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: '',
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (value) {
          if (value.isNotEmpty) {
            if (index < 5) {
              _focusNodes[index + 1].requestFocus();
            } else {
              _focusNodes[index].unfocus();
              _verifyOTP();
            }
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
          setState(() {});
        },
      ),
    );
  }

  Widget _buildVerifyButton() {
    final isComplete = _controllers.every((controller) => controller.text.isNotEmpty);
    
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return AuthButton(
          text: 'Xác thực',
          isLoading: state is AuthInProgress,
          onPressed: isComplete ? _verifyOTP : null,
        );
      },
    );
  }

  Widget _buildResendSection() {
    return Center(
      child: Column(
        children: [
          Text(
            'Không nhận được mã?',
            style: TextStyle(
              fontSize: 16.sp,
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
            ),
          ),
          SizedBox(height: 8.h),
          if (_canResend)
            TextButton(
              onPressed: _resendOTP,
              child: Text(
                'Gửi lại mã',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            Text(
              'Gửi lại sau $_remainingSeconds giây',
              style: TextStyle(
                fontSize: 16.sp,
                color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChangeNumberButton() {
    return Center(
      child: TextButton(
        onPressed: () => context.pop(),
        child: Text(
          'Thay đổi số điện thoại',
          style: TextStyle(
            fontSize: 16.sp,
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _verifyOTP() {
    final otp = _controllers.map((controller) => controller.text).join();
    if (otp.length == 6) {
      final authBloc = context.read<AuthBloc>();
      authBloc.add(VerifyPhoneNumberRequested(
        verificationId: widget.verificationId,
        smsCode: otp,
      ));
    }
  }

  void _resendOTP() {
    final authBloc = context.read<AuthBloc>();
    authBloc.add(SignInWithPhoneRequested(
      phoneNumber: widget.phoneNumber,
    ));
    _startTimer();
    
    // Clear OTP fields
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }
}
