import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../booking/domain/entities/service.dart';
import '../bloc/client_booking_bloc.dart';
import '../bloc/client_booking_event.dart';
import '../bloc/client_booking_state.dart';
import '../widgets/date_picker_widget.dart';
import '../widgets/time_slot_selector.dart';
import '../widgets/hours_selector.dart';

/// Screen for selecting date, time, and duration
class DateTimeSelectionScreen extends StatefulWidget {
  final Service service;

  const DateTimeSelectionScreen({super.key, required this.service});

  @override
  State<DateTimeSelectionScreen> createState() =>
      _DateTimeSelectionScreenState();
}

class _DateTimeSelectionScreenState extends State<DateTimeSelectionScreen> {
  late ClientBookingBloc _bookingBloc;
  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  double? _selectedHours;

  @override
  void initState() {
    super.initState();
    _bookingBloc = di.sl<ClientBookingBloc>();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bookingBloc,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: const Text('Chọn thời gian'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          elevation: 0,
        ),
        body: BlocConsumer<ClientBookingBloc, ClientBookingState>(
          listener: (context, state) {
            if (state is ClientBookingError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is BookingFlowState &&
                state.currentStep == BookingStep.partnerSelection) {
              // Navigate to partner selection
              Navigator.pushNamed(context, '/client/booking/partners');
            }
          },
          builder: (context, state) {
            return _buildBody(context, state);
          },
        ),
        bottomNavigationBar: _buildBottomBar(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ClientBookingState state) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service Info Header
          _buildServiceHeader(context),

          SizedBox(height: 24.h),

          // Date Selection
          _buildSectionTitle(context, 'Chọn ngày'),
          SizedBox(height: 12.h),
          DatePickerWidget(
            selectedDate: _selectedDate,
            onDateSelected: (date) {
              setState(() {
                _selectedDate = date;
              });
              _updateBookingDateTime();
            },
          ),

          SizedBox(height: 24.h),

          // Time Slot Selection
          _buildSectionTitle(context, 'Chọn khung giờ'),
          SizedBox(height: 12.h),
          TimeSlotSelector(
            selectedTimeSlot: _selectedTimeSlot,
            onTimeSlotSelected: (timeSlot) {
              setState(() {
                _selectedTimeSlot = timeSlot;
              });
              _updateBookingDateTime();
            },
          ),

          SizedBox(height: 24.h),

          // Hours Selection
          _buildSectionTitle(context, 'Số giờ dịch vụ'),
          SizedBox(height: 12.h),
          HoursSelector(
            selectedHours: _selectedHours,
            serviceEstimatedDuration: widget.service.durationMinutes / 60,
            onHoursSelected: (hours) {
              setState(() {
                _selectedHours = hours;
              });
              _updateBookingDateTime();
            },
          ),

          SizedBox(height: 24.h),

          // Price Summary
          if (_selectedHours != null) _buildPriceSummary(context),

          SizedBox(height: 100.h), // Space for bottom bar
        ],
      ),
    );
  }

  Widget _buildServiceHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(
            Icons.medical_services,
            color: Theme.of(context).colorScheme.primary,
            size: 24.r,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.service.name,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                Text(
                  widget.service.category,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Theme.of(
                      context,
                    ).colorScheme.onPrimaryContainer.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${widget.service.basePrice.toStringAsFixed(0)}đ/giờ',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _buildPriceSummary(BuildContext context) {
    final totalPrice = widget.service.basePrice * _selectedHours!;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tóm tắt giá',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${widget.service.basePrice.toStringAsFixed(0)}đ × ${_selectedHours!.toStringAsFixed(1)}h',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                '${totalPrice.toStringAsFixed(0)}đ',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final canProceed =
        _selectedDate != null &&
        _selectedTimeSlot != null &&
        _selectedHours != null;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: canProceed ? _proceedToNextStep : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            padding: EdgeInsets.symmetric(vertical: 16.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          child: Text(
            'Tiếp tục',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  void _updateBookingDateTime() {
    if (_selectedDate != null &&
        _selectedTimeSlot != null &&
        _selectedHours != null) {
      _bookingBloc.add(
        SelectDateTimeEvent(
          date: _selectedDate!,
          timeSlot: _selectedTimeSlot!,
          hours: _selectedHours!,
        ),
      );
    }
  }

  void _proceedToNextStep() {
    _bookingBloc.add(const LoadAvailablePartnersEvent());
  }
}
