import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/partner.dart';
import '../bloc/booking_bloc.dart';
import '../bloc/booking_event.dart';
import '../bloc/booking_state.dart';
import '../widgets/partner_card.dart';

class PartnerSelectionScreen extends StatefulWidget {
  const PartnerSelectionScreen({super.key});

  @override
  State<PartnerSelectionScreen> createState() => _PartnerSelectionScreenState();
}

class _PartnerSelectionScreenState extends State<PartnerSelectionScreen> {
  @override
  void initState() {
    super.initState();
    // Load available partners when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<BookingBloc>().state;
      if (state is DateTimeSelected && 
          state.selectedTimeSlot != null && 
          state.selectedHours != null) {
        context.read<BookingBloc>().add(
          LoadAvailablePartnersEvent(
            serviceId: state.selectedService.id,
            date: state.selectedDate,
            timeSlot: state.selectedTimeSlot!,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn người chăm sóc'),
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
          } else if (state is PartnerSelected) {
            // Navigate to booking confirmation
            context.push('/client/booking/confirmation');
          }
        },
        builder: (context, state) {
          if (state is PartnersLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is BookingError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64.r,
                    color: Colors.red,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Có lỗi xảy ra',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Quay lại'),
                  ),
                ],
              ),
            );
          }

          if (state is PartnersLoaded || state is PartnerSelected) {
            final partners = state is PartnersLoaded 
                ? state.availablePartners 
                : (state as PartnerSelected).availablePartners;

            final selectedService = state is PartnersLoaded 
                ? state.selectedService 
                : (state as PartnerSelected).selectedService;

            final selectedDate = state is PartnersLoaded 
                ? state.selectedDate 
                : (state as PartnerSelected).selectedDate;

            final selectedTimeSlot = state is PartnersLoaded 
                ? state.selectedTimeSlot 
                : (state as PartnerSelected).selectedTimeSlot;

            if (partners.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_search,
                      size: 64.r,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Không có người chăm sóc',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Không có người chăm sóc nào khả dụng\ncho thời gian này',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () => context.pop(),
                      child: const Text('Chọn thời gian khác'),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Booking Summary
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Thông tin đặt lịch',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          selectedService.name,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '${selectedDate.day}/${selectedDate.month}/${selectedDate.year} - $selectedTimeSlot',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),

                  Text(
                    'Chọn người chăm sóc (${partners.length})',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Được sắp xếp theo khoảng cách và đánh giá',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Partners List
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: partners.length,
                    separatorBuilder: (context, index) => SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      final partner = partners[index];
                      return PartnerCard(
                        partner: partner,
                        onTap: () => _selectPartner(partner),
                      );
                    },
                  ),
                ],
              ),
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  void _selectPartner(Partner partner) {
    context.read<BookingBloc>().add(
      SelectPartnerEvent(
        partnerId: partner.uid,
        partnerName: partner.name,
        partnerPrice: partner.pricePerHour,
      ),
    );
  }
}
