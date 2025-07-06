import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter_pro_test/core/di/injection_container.dart' as di;
import 'package:flutter_pro_test/shared/theme/app_theme.dart';
import 'package:flutter_pro_test/features/booking/presentation/bloc/realtime_booking_bloc.dart';
import 'package:flutter_pro_test/features/booking/presentation/screens/booking_tracking_screen.dart';
import 'package:flutter_pro_test/shared/models/booking_model.dart';
import 'package:flutter_pro_test/shared/theme/app_colors.dart';
import 'package:flutter_pro_test/shared/theme/app_text_styles.dart';
import 'package:flutter_pro_test/core/constants/app_constants.dart';
import 'package:flutter_pro_test/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize dependencies
  await di.init();

  runApp(const RealtimeBookingTestApp());
}

class RealtimeBookingTestApp extends StatelessWidget {
  const RealtimeBookingTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Real-time Booking Test',
          theme: AppTheme.lightTheme,
          home: const RealtimeBookingTestScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

class RealtimeBookingTestScreen extends StatefulWidget {
  const RealtimeBookingTestScreen({super.key});

  @override
  State<RealtimeBookingTestScreen> createState() =>
      _RealtimeBookingTestScreenState();
}

class _RealtimeBookingTestScreenState extends State<RealtimeBookingTestScreen> {
  final List<BookingModel> _testBookings = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _createTestBookings();
  }

  void _createTestBookings() {
    setState(() {
      _isLoading = true;
    });

    // Create sample bookings for testing
    _testBookings.addAll([
      BookingModel(
        id: 'test_booking_1',
        userId: 'test_user_1',
        partnerId: 'test_partner_1',
        serviceId: AppConstants.serviceElderCare,
        serviceName: 'Elder Care Service',
        scheduledDate: DateTime.now().add(const Duration(hours: 2)),
        timeSlot: '14:00 - 16:00',
        hours: 2.0,
        totalPrice: 200.0,
        status: AppConstants.statusPending,
        paymentStatus: AppConstants.paymentPaid,
        clientAddress: '123 Test Street, Ho Chi Minh City',
        clientLocation: const GeoPoint(10.8231, 106.6297),
        createdAt: DateTime.now(),
      ),
      BookingModel(
        id: 'test_booking_2',
        userId: 'test_user_2',
        partnerId: 'test_partner_2',
        serviceId: AppConstants.servicePetCare,
        serviceName: 'Pet Care Service',
        scheduledDate: DateTime.now().add(const Duration(hours: 1)),
        timeSlot: '13:00 - 15:00',
        hours: 2.0,
        totalPrice: 150.0,
        status: AppConstants.statusConfirmed,
        paymentStatus: AppConstants.paymentPaid,
        clientAddress: '456 Pet Avenue, Ho Chi Minh City',
        clientLocation: const GeoPoint(10.8331, 106.6397),
        createdAt: DateTime.now(),
      ),
      BookingModel(
        id: 'test_booking_3',
        userId: 'test_user_3',
        partnerId: 'test_partner_3',
        serviceId: AppConstants.serviceChildCare,
        serviceName: 'Child Care Service',
        scheduledDate: DateTime.now().add(const Duration(minutes: 30)),
        timeSlot: '12:30 - 14:30',
        hours: 2.0,
        totalPrice: 180.0,
        status: AppConstants.statusInProgress,
        paymentStatus: AppConstants.paymentPaid,
        clientAddress: '789 Family Road, Ho Chi Minh City',
        clientLocation: const GeoPoint(10.8131, 106.6197),
        createdAt: DateTime.now(),
      ),
    ]);

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Real-time Booking Test',
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.textOnPrimary,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.track_changes,
                              color: AppColors.primary,
                              size: 24.w,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Real-time Booking Tracking Test',
                              style: AppTextStyles.headlineSmall.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Test the real-time booking tracking functionality with sample bookings. '
                          'Each booking demonstrates different status states and real-time updates.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Test Bookings List
                  Text('Test Bookings', style: AppTextStyles.headlineSmall),
                  SizedBox(height: 16.h),

                  ...(_testBookings.map(
                    (booking) => _buildBookingCard(booking),
                  )),

                  SizedBox(height: 24.h),

                  // Test Instructions
                  _buildTestInstructions(),
                ],
              ),
            ),
    );
  }

  Widget _buildBookingCard(BookingModel booking) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: _getStatusColor(booking.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  _getStatusIcon(booking.status),
                  color: _getStatusColor(booking.status),
                  size: 20.w,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.serviceName,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'ID: ${booking.id}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: _getStatusColor(booking.status),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  booking.statusDisplayText,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textOnPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            'Address: ${booking.clientAddress}',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Time: ${booking.timeSlot}',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _openClientTracking(booking),
                  icon: const Icon(Icons.visibility),
                  label: const Text('Client View'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _openPartnerTracking(booking),
                  icon: const Icon(Icons.work),
                  label: const Text('Partner View'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTestInstructions() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.info.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.info, size: 20.w),
              SizedBox(width: 8.w),
              Text(
                'Test Instructions',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.info,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            '1. Tap "Client View" to see the booking from client perspective\n'
            '2. Tap "Partner View" to see the booking from partner perspective\n'
            '3. Partners can update booking status in real-time\n'
            '4. Clients receive live updates and notifications\n'
            '5. Test different booking statuses and real-time features',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _openClientTracking(BookingModel booking) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => di.sl<RealtimeBookingBloc>(),
          child: BookingTrackingScreen(
            bookingId: booking.id,
            booking: booking,
            isPartnerView: false,
          ),
        ),
      ),
    );
  }

  void _openPartnerTracking(BookingModel booking) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => di.sl<RealtimeBookingBloc>(),
          child: BookingTrackingScreen(
            bookingId: booking.id,
            booking: booking,
            isPartnerView: true,
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case AppConstants.statusPending:
        return Colors.orange;
      case AppConstants.statusConfirmed:
        return AppColors.primary;
      case AppConstants.statusInProgress:
        return Colors.blue;
      case AppConstants.statusCompleted:
        return AppColors.success;
      case AppConstants.statusCancelled:
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case AppConstants.statusPending:
        return Icons.pending;
      case AppConstants.statusConfirmed:
        return Icons.check_circle;
      case AppConstants.statusInProgress:
        return Icons.work;
      case AppConstants.statusCompleted:
        return Icons.done_all;
      case AppConstants.statusCancelled:
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }
}
