import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../booking/domain/entities/service.dart';
import '../bloc/client_booking_bloc.dart';
import '../bloc/client_booking_event.dart';
import '../bloc/client_booking_state.dart';
import '../widgets/service_card.dart';
import '../widgets/service_search_bar.dart';

/// Screen for selecting a care service
class ServiceSelectionScreen extends StatefulWidget {
  const ServiceSelectionScreen({super.key});

  @override
  State<ServiceSelectionScreen> createState() => _ServiceSelectionScreenState();
}

class _ServiceSelectionScreenState extends State<ServiceSelectionScreen> {
  late ClientBookingBloc _bookingBloc;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bookingBloc = di.sl<ClientBookingBloc>();
    _bookingBloc.add(const LoadAvailableServicesEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bookingBloc,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: const Text('Chọn dịch vụ'),
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
                       state.currentStep == BookingStep.dateTimeSelection) {
              // Navigate to date/time selection
              Navigator.pushNamed(
                context,
                '/client/booking/datetime',
                arguments: state.selectedService,
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
          onRetry: () {
            _bookingBloc.add(const LoadAvailableServicesEvent());
          },
        ),
      );
    }

    if (state is ServicesLoadedState) {
      return _buildServicesContent(context, state);
    }

    return const Center(child: Text('Unknown state'));
  }

  Widget _buildServicesContent(BuildContext context, ServicesLoadedState state) {
    return Column(
      children: [
        // Search Bar
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24.r),
              bottomRight: Radius.circular(24.r),
            ),
          ),
          child: ServiceSearchBar(
            controller: _searchController,
            onChanged: (query) {
              _bookingBloc.add(SearchServicesEvent(query));
            },
            onClear: () {
              _searchController.clear();
              _bookingBloc.add(const SearchServicesEvent(''));
            },
          ),
        ),

        // Services List
        Expanded(
          child: _buildServicesList(context, state),
        ),
      ],
    );
  }

  Widget _buildServicesList(BuildContext context, ServicesLoadedState state) {
    if (state.filteredServices.isEmpty) {
      return _buildEmptyState(context, state.searchQuery);
    }

    return RefreshIndicator(
      onRefresh: () async {
        _bookingBloc.add(const LoadAvailableServicesEvent());
      },
      child: ListView.separated(
        padding: EdgeInsets.all(16.w),
        itemCount: state.filteredServices.length,
        separatorBuilder: (context, index) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          final service = state.filteredServices[index];
          return ServiceCard(
            service: service,
            onTap: () => _selectService(service),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String? searchQuery) {
    final isSearching = searchQuery != null && searchQuery.isNotEmpty;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearching ? Icons.search_off : Icons.medical_services_outlined,
            size: 64.r,
            color: Colors.grey,
          ),
          SizedBox(height: 16.h),
          Text(
            isSearching 
                ? 'Không tìm thấy dịch vụ'
                : 'Chưa có dịch vụ nào',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            isSearching
                ? 'Thử tìm kiếm với từ khóa khác'
                : 'Vui lòng thử lại sau',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey,
            ),
          ),
          if (isSearching) ...[
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () {
                _searchController.clear();
                _bookingBloc.add(const SearchServicesEvent(''));
              },
              child: const Text('Xóa bộ lọc'),
            ),
          ],
        ],
      ),
    );
  }

  void _selectService(Service service) {
    _bookingBloc.add(SelectServiceEvent(service));
  }
}

/// Service categories for filtering
class ServiceCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  const ServiceCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  static const List<ServiceCategory> categories = [
    ServiceCategory(
      id: 'elder_care',
      name: 'Chăm sóc người già',
      icon: Icons.elderly,
      color: Colors.blue,
    ),
    ServiceCategory(
      id: 'child_care',
      name: 'Chăm sóc trẻ em',
      icon: Icons.child_care,
      color: Colors.pink,
    ),
    ServiceCategory(
      id: 'pet_care',
      name: 'Chăm sóc thú cưng',
      icon: Icons.pets,
      color: Colors.orange,
    ),
    ServiceCategory(
      id: 'house_cleaning',
      name: 'Dọn dẹp nhà cửa',
      icon: Icons.cleaning_services,
      color: Colors.green,
    ),
    ServiceCategory(
      id: 'medical_care',
      name: 'Chăm sóc y tế',
      icon: Icons.medical_services,
      color: Colors.red,
    ),
  ];
}
