import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../booking/domain/entities/booking.dart';
import '../bloc/client_booking_bloc.dart';
import '../bloc/client_booking_event.dart';
import '../bloc/client_booking_state.dart';
import '../widgets/booking_history_card.dart';

/// Screen for displaying client's booking history
class BookingHistoryScreen extends StatefulWidget {
  final String userId;

  const BookingHistoryScreen({super.key, required this.userId});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen>
    with SingleTickerProviderStateMixin {
  late ClientBookingBloc _bookingBloc;
  late TabController _tabController;

  final List<BookingFilterTab> _filterTabs = [
    BookingFilterTab(label: 'Tất cả', status: null, icon: Icons.list_alt),
    BookingFilterTab(
      label: 'Đang chờ',
      status: BookingStatus.pending,
      icon: Icons.schedule,
    ),
    BookingFilterTab(
      label: 'Đang thực hiện',
      status: BookingStatus.inProgress,
      icon: Icons.play_circle,
    ),
    BookingFilterTab(
      label: 'Hoàn thành',
      status: BookingStatus.completed,
      icon: Icons.check_circle,
    ),
    BookingFilterTab(
      label: 'Đã hủy',
      status: BookingStatus.cancelled,
      icon: Icons.cancel,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _bookingBloc = di.sl<ClientBookingBloc>();
    _tabController = TabController(length: _filterTabs.length, vsync: this);
    _loadBookingHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bookingBloc,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: const Text('Lịch sử đặt dịch vụ'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          elevation: 0,
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            onTap: _onTabChanged,
            tabs: _filterTabs
                .map(
                  (tab) => Tab(
                    icon: Icon(tab.icon, size: 20.r),
                    text: tab.label,
                  ),
                )
                .toList(),
          ),
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
            }
          },
          builder: (context, state) {
            return _buildBody(context, state);
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ClientBookingState state) {
    if (state is ClientBookingLoading) {
      return const Center(child: LoadingWidget());
    }

    if (state is ClientBookingError) {
      return Center(
        child: CustomErrorWidget(
          message: state.message,
          onRetry: _loadBookingHistory,
        ),
      );
    }

    if (state is BookingHistoryLoadedState) {
      return _buildBookingHistory(context, state.bookings);
    }

    return const Center(child: Text('Chưa có dữ liệu'));
  }

  Widget _buildBookingHistory(BuildContext context, List<Booking> bookings) {
    final filteredBookings = _filterBookings(bookings);

    if (filteredBookings.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () async => _loadBookingHistory(),
      child: ListView.separated(
        padding: EdgeInsets.all(16.w),
        itemCount: filteredBookings.length,
        separatorBuilder: (context, index) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          final booking = filteredBookings[index];
          return BookingHistoryCard(
            booking: booking,
            onTap: () => _showBookingDetails(booking),
            onCancel: booking.status == BookingStatus.pending
                ? () => _showCancelDialog(booking)
                : null,
            onReview: booking.status == BookingStatus.completed
                ? () => _showReviewDialog(booking)
                : null,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final currentTab = _filterTabs[_tabController.index];

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(currentTab.icon, size: 64.r, color: Colors.grey),
          SizedBox(height: 16.h),
          Text(
            _getEmptyStateTitle(currentTab.status),
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            _getEmptyStateSubtitle(currentTab.status),
            style: TextStyle(fontSize: 14.sp, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          if (currentTab.status == null) ...[
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/client/booking');
              },
              child: const Text('Đặt dịch vụ ngay'),
            ),
          ],
        ],
      ),
    );
  }

  List<Booking> _filterBookings(List<Booking> bookings) {
    final currentTab = _filterTabs[_tabController.index];
    if (currentTab.status == null) {
      return bookings;
    }
    return bookings
        .where((booking) => booking.status == currentTab.status)
        .toList();
  }

  String _getEmptyStateTitle(BookingStatus? status) {
    switch (status) {
      case BookingStatus.pending:
        return 'Không có đặt dịch vụ đang chờ';
      case BookingStatus.inProgress:
        return 'Không có dịch vụ đang thực hiện';
      case BookingStatus.completed:
        return 'Chưa có dịch vụ hoàn thành';
      case BookingStatus.cancelled:
        return 'Không có dịch vụ đã hủy';
      default:
        return 'Chưa có lịch sử đặt dịch vụ';
    }
  }

  String _getEmptyStateSubtitle(BookingStatus? status) {
    switch (status) {
      case BookingStatus.pending:
        return 'Các đặt dịch vụ đang chờ xác nhận sẽ hiển thị ở đây';
      case BookingStatus.inProgress:
        return 'Các dịch vụ đang được thực hiện sẽ hiển thị ở đây';
      case BookingStatus.completed:
        return 'Các dịch vụ đã hoàn thành sẽ hiển thị ở đây';
      case BookingStatus.cancelled:
        return 'Các dịch vụ đã hủy sẽ hiển thị ở đây';
      default:
        return 'Hãy đặt dịch vụ đầu tiên của bạn\nđể bắt đầu trải nghiệm CareNow';
    }
  }

  void _onTabChanged(int index) {
    // Filter will be applied automatically when rebuilding
  }

  void _loadBookingHistory() {
    _bookingBloc.add(LoadClientBookingHistoryEvent(widget.userId));
  }

  void _showBookingDetails(Booking booking) {
    Navigator.pushNamed(context, '/client/booking/details', arguments: booking);
  }

  void _showCancelDialog(Booking booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hủy đặt dịch vụ'),
        content: const Text('Bạn có chắc chắn muốn hủy đặt dịch vụ này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Không'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _bookingBloc.add(CancelBookingEvent(bookingId: booking.id));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hủy dịch vụ'),
          ),
        ],
      ),
    );
  }

  void _showReviewDialog(Booking booking) {
    Navigator.pushNamed(context, '/client/review', arguments: booking);
  }
}

/// Data class for booking filter tabs
class BookingFilterTab {
  final String label;
  final BookingStatus? status;
  final IconData icon;

  const BookingFilterTab({
    required this.label,
    required this.status,
    required this.icon,
  });
}
