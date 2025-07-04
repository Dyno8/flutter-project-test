import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/booking.dart';
import '../bloc/booking_bloc.dart';
import '../bloc/booking_event.dart';
import '../bloc/booking_state.dart';
import '../widgets/booking_list_item.dart';

class BookingListScreen extends StatefulWidget {
  const BookingListScreen({super.key});

  @override
  State<BookingListScreen> createState() => _BookingListScreenState();
}

class _BookingListScreenState extends State<BookingListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadUserBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadUserBookings() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<BookingBloc>().add(
        LoadUserBookingsEvent(userId: authState.user.uid),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch đặt của tôi'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.onPrimary,
          unselectedLabelColor: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
          indicatorColor: Theme.of(context).colorScheme.onPrimary,
          tabs: const [
            Tab(text: 'Tất cả'),
            Tab(text: 'Chờ xác nhận'),
            Tab(text: 'Đang thực hiện'),
            Tab(text: 'Hoàn thành'),
          ],
          onTap: (index) => _onTabChanged(index),
        ),
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
          }
        },
        builder: (context, state) {
          if (state is BookingLoading) {
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
                    onPressed: _loadUserBookings,
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          if (state is UserBookingsLoaded) {
            final bookings = _filterBookingsByTab(state.bookings);

            if (bookings.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 64.r,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Chưa có lịch đặt nào',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Hãy đặt lịch dịch vụ đầu tiên của bạn',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to service selection
                        Navigator.of(context).pushNamed('/client/booking');
                      },
                      child: const Text('Đặt lịch ngay'),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async => _loadUserBookings(),
              child: ListView.separated(
                padding: EdgeInsets.all(16.w),
                itemCount: bookings.length,
                separatorBuilder: (context, index) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  final booking = bookings[index];
                  return BookingListItem(
                    booking: booking,
                    onTap: () => _showBookingDetails(booking),
                    onCancel: booking.canBeCancelled
                        ? () => _showCancelDialog(booking)
                        : null,
                  );
                },
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

  void _onTabChanged(int index) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      BookingStatus? status;
      switch (index) {
        case 1:
          status = BookingStatus.pending;
          break;
        case 2:
          status = BookingStatus.inProgress;
          break;
        case 3:
          status = BookingStatus.completed;
          break;
        default:
          status = null; // All bookings
      }

      context.read<BookingBloc>().add(
        LoadUserBookingsEvent(
          userId: authState.user.uid,
          status: status,
        ),
      );
    }
  }

  List<Booking> _filterBookingsByTab(List<Booking> bookings) {
    final currentTab = _tabController.index;
    switch (currentTab) {
      case 1:
        return bookings.where((b) => b.isPending).toList();
      case 2:
        return bookings.where((b) => b.isInProgress).toList();
      case 3:
        return bookings.where((b) => b.isCompleted).toList();
      default:
        return bookings;
    }
  }

  void _showBookingDetails(Booking booking) {
    // TODO: Navigate to booking details screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Chi tiết booking ${booking.id}'),
      ),
    );
  }

  void _showCancelDialog(Booking booking) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hủy lịch đặt'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Bạn có chắc chắn muốn hủy lịch đặt này?'),
            SizedBox(height: 16.h),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Lý do hủy',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Không'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isNotEmpty) {
                context.read<BookingBloc>().add(
                  CancelBookingEvent(
                    bookingId: booking.id,
                    cancellationReason: reasonController.text.trim(),
                  ),
                );
                Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hủy lịch'),
          ),
        ],
      ),
    );
  }
}
