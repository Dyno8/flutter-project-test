import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_state.dart';
import '../bloc/booking_bloc.dart';
import '../bloc/booking_event.dart';
import '../bloc/booking_state.dart';
import '../widgets/booking_summary_card.dart';
import '../widgets/address_input_widget.dart';

class BookingConfirmationScreen extends StatefulWidget {
  const BookingConfirmationScreen({super.key});

  @override
  State<BookingConfirmationScreen> createState() => _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();
  bool _hasSetAddress = false;

  @override
  void dispose() {
    _addressController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác nhận đặt lịch'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: BlocConsumer<BookingBloc, BookingState>(
        listener: (context, state) {
          if (state is BookingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is BookingCreated) {
            // Show success dialog and navigate to booking details
            _showBookingSuccessDialog(context);
          }
        },
        builder: (context, state) {
          if (state is! PartnerSelected && state is! BookingReadyForConfirmation) {
            return const Center(
              child: Text('Vui lòng hoàn tất các bước trước'),
            );
          }

          final selectedService = state is PartnerSelected 
              ? state.selectedService 
              : (state as BookingReadyForConfirmation).selectedService;

          final selectedDate = state is PartnerSelected 
              ? state.selectedDate 
              : (state as BookingReadyForConfirmation).selectedDate;

          final selectedTimeSlot = state is PartnerSelected 
              ? state.selectedTimeSlot 
              : (state as BookingReadyForConfirmation).selectedTimeSlot;

          final selectedHours = state is PartnerSelected 
              ? state.selectedHours 
              : (state as BookingReadyForConfirmation).selectedHours;

          final selectedPartner = state is PartnerSelected 
              ? state.selectedPartner 
              : (state as BookingReadyForConfirmation).selectedPartner;

          final totalPrice = selectedService.calculatePrice(selectedHours);

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Booking Summary
                BookingSummaryCard(
                  service: selectedService,
                  partner: selectedPartner,
                  date: selectedDate,
                  timeSlot: selectedTimeSlot,
                  hours: selectedHours,
                  totalPrice: totalPrice,
                ),
                SizedBox(height: 24.h),

                // Address Input
                Text(
                  'Địa chỉ dịch vụ',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12.h),
                AddressInputWidget(
                  controller: _addressController,
                  onAddressSelected: (address, latitude, longitude) {
                    setState(() {
                      _hasSetAddress = true;
                    });
                    context.read<BookingBloc>().add(
                      SetClientAddressEvent(
                        address: address,
                        latitude: latitude,
                        longitude: longitude,
                      ),
                    );
                  },
                ),
                SizedBox(height: 24.h),

                // Special Instructions
                Text(
                  'Ghi chú đặc biệt',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12.h),
                TextField(
                  controller: _instructionsController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Nhập ghi chú cho người chăm sóc (không bắt buộc)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    contentPadding: EdgeInsets.all(16.w),
                  ),
                  onChanged: (value) {
                    context.read<BookingBloc>().add(
                      SetSpecialInstructionsEvent(value),
                    );
                  },
                ),
                SizedBox(height: 32.h),

                // Confirm Button
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: _hasSetAddress && state is! BookingCreating
                        ? () => _confirmBooking(context)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: state is BookingCreating
                        ? SizedBox(
                            width: 20.w,
                            height: 20.h,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Xác nhận đặt lịch',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 16.h),

                // Terms and Conditions
                Text(
                  'Bằng cách đặt lịch, bạn đồng ý với điều khoản sử dụng và chính sách bảo mật của chúng tôi.',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _confirmBooking(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<BookingBloc>().add(
        CreateBookingEvent(authState.user.uid),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập để đặt lịch'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showBookingSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              size: 64.r,
              color: Colors.green,
            ),
            SizedBox(height: 16.h),
            Text(
              'Đặt lịch thành công!',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Chúng tôi sẽ liên hệ với bạn sớm nhất để xác nhận lịch hẹn.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.pop(); // Close dialog
              context.go('/client'); // Navigate to home
            },
            child: const Text('Về trang chủ'),
          ),
          ElevatedButton(
            onPressed: () {
              context.pop(); // Close dialog
              context.go('/client/bookings'); // Navigate to bookings
            },
            child: const Text('Xem lịch đặt'),
          ),
        ],
      ),
    );
  }
}
