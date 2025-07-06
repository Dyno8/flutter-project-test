import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:bloc_test/bloc_test.dart';

import 'package:flutter_pro_test/features/client/presentation/bloc/client_booking_bloc.dart';
import 'package:flutter_pro_test/features/client/presentation/bloc/client_booking_event.dart';
import 'package:flutter_pro_test/features/client/presentation/bloc/client_booking_state.dart';
import 'package:flutter_pro_test/features/client/domain/usecases/get_available_services.dart';
import 'package:flutter_pro_test/features/client/domain/usecases/search_available_partners.dart';
import 'package:flutter_pro_test/features/client/domain/usecases/create_booking.dart';
import 'package:flutter_pro_test/features/client/domain/usecases/process_payment.dart';
import 'package:flutter_pro_test/features/client/domain/usecases/get_client_bookings.dart';
import 'package:flutter_pro_test/features/client/domain/entities/payment_request.dart';
import 'package:flutter_pro_test/features/client/domain/entities/payment_result.dart';
import 'package:flutter_pro_test/features/booking/domain/entities/service.dart';
import 'package:flutter_pro_test/features/booking/domain/entities/partner.dart';
import 'package:flutter_pro_test/features/booking/domain/entities/booking.dart';
import 'package:flutter_pro_test/core/errors/failures.dart';
import 'package:flutter_pro_test/core/usecases/usecase.dart';

import 'complete_client_booking_flow_test.mocks.dart';

@GenerateMocks([
  GetAvailableServices,
  SearchAvailablePartners,
  CreateBooking,
  ProcessPayment,
  GetAvailablePaymentMethods,
  GetClientBookings,
])
void main() {
  group('Complete Client Booking Flow Integration Tests', () {
    late ClientBookingBloc clientBookingBloc;
    late MockGetAvailableServices mockGetAvailableServices;
    late MockSearchAvailablePartners mockSearchAvailablePartners;
    late MockCreateBooking mockCreateBooking;
    late MockProcessPayment mockProcessPayment;
    late MockGetAvailablePaymentMethods mockGetAvailablePaymentMethods;
    late MockGetClientBookings mockGetClientBookings;

    // Test data
    late Service testService;
    late Partner testPartner;
    late Booking testBooking;
    late PaymentMethod testPaymentMethod;
    late PaymentResult testPaymentResult;

    setUp(() {
      mockGetAvailableServices = MockGetAvailableServices();
      mockSearchAvailablePartners = MockSearchAvailablePartners();
      mockCreateBooking = MockCreateBooking();
      mockProcessPayment = MockProcessPayment();
      mockGetAvailablePaymentMethods = MockGetAvailablePaymentMethods();
      mockGetClientBookings = MockGetClientBookings();

      clientBookingBloc = ClientBookingBloc(
        getAvailableServices: mockGetAvailableServices,
        searchAvailablePartners: mockSearchAvailablePartners,
        createBooking: mockCreateBooking,
        processPayment: mockProcessPayment,
        getAvailablePaymentMethods: mockGetAvailablePaymentMethods,
        getClientBookings: mockGetClientBookings,
      );

      // Initialize test data
      testService = Service(
        id: 'service-1',
        name: 'Elder Care',
        description: 'Professional elder care service',
        category: 'elder-care',
        iconUrl: 'elder-care.png',
        basePrice: 50000.0,
        durationMinutes: 120,
        requirements: ['Experience with elderly'],
        benefits: ['Professional care', 'Reliable service'],
        isActive: true,
        sortOrder: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      testPartner = Partner(
        uid: 'partner-1',
        name: 'John Doe',
        phone: '+1234567890',
        email: 'john@example.com',
        gender: 'male',
        services: ['elder-care'],
        workingHours: {
          'monday': ['09:00', '17:00'],
        },
        rating: 4.8,
        totalReviews: 120,
        latitude: 10.8231,
        longitude: 106.6297,
        address: 'Ho Chi Minh City',
        bio: 'Experienced caregiver',
        profileImageUrl: 'profile.jpg',
        certifications: ['First Aid'],
        experienceYears: 5,
        pricePerHour: 55000.0,
        isAvailable: true,
        isVerified: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      testBooking = Booking(
        id: 'booking-1',
        userId: 'user-1',
        partnerId: 'partner-1',
        serviceId: 'service-1',
        serviceName: 'Elder Care',
        scheduledDate: DateTime.now().add(const Duration(days: 1)),
        timeSlot: '09:00',
        hours: 2.0,
        totalPrice: 110000.0,
        status: BookingStatus.pending,
        paymentStatus: PaymentStatus.unpaid,
        clientAddress: '123 Main St',
        clientLatitude: 10.8231,
        clientLongitude: 106.6297,
        specialInstructions: 'Handle with care',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      testPaymentMethod = const PaymentMethod(
        id: 'mock',
        type: PaymentMethodType.mock,
        name: 'mock',
        displayName: 'Mock Payment',
        isEnabled: true,
      );

      testPaymentResult = PaymentResult.success(
        transactionId: 'txn-123',
        amount: 110000.0,
        currency: 'VND',
      );
    });

    tearDown(() {
      clientBookingBloc.close();
    });

    group('Happy Path - Complete Booking Flow', () {
      blocTest<ClientBookingBloc, ClientBookingState>(
        'should complete entire booking flow successfully',
        build: () {
          // Mock all successful responses
          when(
            mockGetAvailableServices.call(any),
          ).thenAnswer((_) async => Right([testService]));
          when(
            mockSearchAvailablePartners.call(any),
          ).thenAnswer((_) async => Right([testPartner]));
          when(
            mockCreateBooking.call(any),
          ).thenAnswer((_) async => Right(testBooking));
          when(
            mockGetAvailablePaymentMethods.call(any),
          ).thenAnswer((_) async => Right([testPaymentMethod]));
          when(
            mockProcessPayment.call(any),
          ).thenAnswer((_) async => Right(testPaymentResult));

          return clientBookingBloc;
        },
        act: (bloc) async {
          // Step 1: Load services
          bloc.add(const LoadAvailableServicesEvent());
          await Future.delayed(const Duration(milliseconds: 100));

          // Step 2: Select service
          bloc.add(SelectServiceEvent(testService));
          await Future.delayed(const Duration(milliseconds: 100));

          // Step 3: Select date and time
          bloc.add(
            SelectDateTimeEvent(
              date: DateTime.now().add(const Duration(days: 1)),
              timeSlot: '09:00',
              hours: 2.0,
            ),
          );
          await Future.delayed(const Duration(milliseconds: 100));

          // Step 4: Set location
          bloc.add(
            const SetClientLocationEvent(
              address: '123 Main St',
              latitude: 10.8231,
              longitude: 106.6297,
            ),
          );
          await Future.delayed(const Duration(milliseconds: 100));

          // Step 5: Load partners
          bloc.add(const LoadAvailablePartnersEvent());
          await Future.delayed(const Duration(milliseconds: 100));

          // Step 6: Select partner
          bloc.add(SelectPartnerEvent(testPartner));
          await Future.delayed(const Duration(milliseconds: 100));

          // Step 7: Load payment methods
          bloc.add(const LoadPaymentMethodsEvent());
          await Future.delayed(const Duration(milliseconds: 100));

          // Step 8: Select payment method
          bloc.add(SelectPaymentMethodEvent(testPaymentMethod));
          await Future.delayed(const Duration(milliseconds: 100));

          // Step 9: Create booking
          bloc.add(const CreateBookingEvent('user-1'));
          await Future.delayed(const Duration(milliseconds: 100));

          // Step 10: Process payment
          bloc.add(ProcessPaymentEvent(testBooking.id));
        },
        expect: () => [
          // Service loading states
          isA<ClientBookingLoading>(),
          isA<ServicesLoadedState>(),

          // Service selection and flow progression
          isA<BookingFlowState>()
              .having(
                (s) => s.currentStep,
                'step',
                BookingStep.dateTimeSelection,
              )
              .having((s) => s.selectedService, 'service', testService),

          // Date/time selection
          isA<BookingFlowState>()
              .having((s) => s.selectedDate, 'date', isNotNull)
              .having((s) => s.selectedTimeSlot, 'timeSlot', '09:00')
              .having((s) => s.selectedHours, 'hours', 2.0),

          // Location setting
          isA<BookingFlowState>().having(
            (s) => s.clientAddress,
            'address',
            '123 Main St',
          ),

          // Partner loading and selection
          isA<BookingFlowState>().having((s) => s.isLoading, 'loading', true),
          isA<BookingFlowState>()
              .having((s) => s.availablePartners, 'partners', [testPartner])
              .having(
                (s) => s.currentStep,
                'step',
                BookingStep.partnerSelection,
              ),

          isA<BookingFlowState>().having(
            (s) => s.selectedPartner,
            'partner',
            testPartner,
          ),

          // Payment method loading and selection
          isA<BookingFlowState>().having((s) => s.isLoading, 'loading', true),
          isA<BookingFlowState>()
              .having((s) => s.paymentMethods, 'methods', [testPaymentMethod])
              .having((s) => s.currentStep, 'step', BookingStep.paymentMethod),

          isA<BookingFlowState>().having(
            (s) => s.selectedPaymentMethod,
            'method',
            testPaymentMethod,
          ),

          // Booking creation
          isA<BookingCreatedState>().having(
            (s) => s.booking,
            'booking',
            testBooking,
          ),

          // Payment processing
          isA<PaymentProcessingState>(),
          isA<PaymentCompletedState>()
              .having((s) => s.paymentResult, 'result', testPaymentResult)
              .having((s) => s.booking, 'booking', testBooking),
        ],
        verify: (_) {
          verify(mockGetAvailableServices.call(any)).called(1);
          verify(mockSearchAvailablePartners.call(any)).called(1);
          verify(mockCreateBooking.call(any)).called(1);
          verify(mockGetAvailablePaymentMethods.call(any)).called(1);
          verify(mockProcessPayment.call(any)).called(1);
        },
      );
    });

    group('Error Scenarios', () {
      blocTest<ClientBookingBloc, ClientBookingState>(
        'should handle service loading failure',
        build: () {
          when(
            mockGetAvailableServices.call(any),
          ).thenAnswer((_) async => Left(ServerFailure('Network error')));
          return clientBookingBloc;
        },
        act: (bloc) => bloc.add(const LoadAvailableServicesEvent()),
        expect: () => [
          isA<ClientBookingLoading>(),
          isA<ClientBookingError>().having(
            (s) => s.message,
            'message',
            'Network error',
          ),
        ],
      );

      blocTest<ClientBookingBloc, ClientBookingState>(
        'should handle partner search failure',
        build: () {
          when(
            mockGetAvailableServices.call(any),
          ).thenAnswer((_) async => Right([testService]));
          when(mockSearchAvailablePartners.call(any)).thenAnswer(
            (_) async => Left(ServerFailure('No partners available')),
          );
          return clientBookingBloc;
        },
        act: (bloc) async {
          bloc.add(const LoadAvailableServicesEvent());
          await Future.delayed(const Duration(milliseconds: 100));
          bloc.add(SelectServiceEvent(testService));
          await Future.delayed(const Duration(milliseconds: 100));
          bloc.add(
            SelectDateTimeEvent(
              date: DateTime.now().add(const Duration(days: 1)),
              timeSlot: '09:00',
              hours: 2.0,
            ),
          );
          await Future.delayed(const Duration(milliseconds: 100));
          bloc.add(
            const SetClientLocationEvent(
              address: '123 Main St',
              latitude: 10.8231,
              longitude: 106.6297,
            ),
          );
          await Future.delayed(const Duration(milliseconds: 100));
          bloc.add(const LoadAvailablePartnersEvent());
        },
        expect: () => [
          isA<ClientBookingLoading>(),
          isA<ServicesLoadedState>(),
          isA<BookingFlowState>(),
          isA<BookingFlowState>(),
          isA<BookingFlowState>(),
          isA<BookingFlowState>().having((s) => s.isLoading, 'loading', true),
          isA<BookingFlowState>()
              .having((s) => s.isLoading, 'loading', false)
              .having((s) => s.error, 'error', 'No partners available'),
        ],
      );

      blocTest<ClientBookingBloc, ClientBookingState>(
        'should handle payment processing failure',
        build: () {
          when(
            mockGetAvailableServices.call(any),
          ).thenAnswer((_) async => Right([testService]));
          when(
            mockCreateBooking.call(any),
          ).thenAnswer((_) async => Right(testBooking));
          when(
            mockProcessPayment.call(any),
          ).thenAnswer((_) async => Left(ServerFailure('Payment failed')));
          return clientBookingBloc;
        },
        act: (bloc) async {
          bloc.add(const CreateBookingEvent('user-1'));
          await Future.delayed(const Duration(milliseconds: 100));
          bloc.add(ProcessPaymentEvent(testBooking.id));
        },
        expect: () => [
          isA<BookingCreatedState>(),
          isA<PaymentProcessingState>(),
          isA<ClientBookingError>().having(
            (s) => s.message,
            'message',
            'Payment failed',
          ),
        ],
      );
    });

    group('State Management', () {
      blocTest<ClientBookingBloc, ClientBookingState>(
        'should maintain booking flow state correctly',
        build: () => clientBookingBloc,
        act: (bloc) async {
          bloc.add(SelectServiceEvent(testService));
          await Future.delayed(const Duration(milliseconds: 50));
          bloc.add(
            SelectDateTimeEvent(
              date: DateTime.now().add(const Duration(days: 1)),
              timeSlot: '09:00',
              hours: 2.0,
            ),
          );
          await Future.delayed(const Duration(milliseconds: 50));
          bloc.add(SelectPartnerEvent(testPartner));
        },
        expect: () => [
          isA<BookingFlowState>()
              .having((s) => s.selectedService, 'service', testService)
              .having(
                (s) => s.currentStep,
                'step',
                BookingStep.dateTimeSelection,
              ),
          isA<BookingFlowState>()
              .having((s) => s.selectedService, 'service', testService)
              .having((s) => s.selectedDate, 'date', isNotNull)
              .having((s) => s.selectedTimeSlot, 'timeSlot', '09:00')
              .having((s) => s.selectedHours, 'hours', 2.0),
          isA<BookingFlowState>()
              .having((s) => s.selectedService, 'service', testService)
              .having((s) => s.selectedPartner, 'partner', testPartner)
              .having((s) => s.selectedDate, 'date', isNotNull)
              .having((s) => s.selectedTimeSlot, 'timeSlot', '09:00'),
        ],
      );

      blocTest<ClientBookingBloc, ClientBookingState>(
        'should reset booking flow when requested',
        build: () => clientBookingBloc,
        act: (bloc) async {
          bloc.add(SelectServiceEvent(testService));
          await Future.delayed(const Duration(milliseconds: 50));
          bloc.add(const ResetBookingFlowEvent());
        },
        expect: () => [isA<BookingFlowState>(), isA<ClientBookingInitial>()],
      );

      blocTest<ClientBookingBloc, ClientBookingState>(
        'should clear errors when requested',
        build: () {
          when(
            mockGetAvailableServices.call(any),
          ).thenAnswer((_) async => Left(ServerFailure('Test error')));
          return clientBookingBloc;
        },
        act: (bloc) async {
          bloc.add(const LoadAvailableServicesEvent());
          await Future.delayed(const Duration(milliseconds: 100));
          bloc.add(const ClearErrorEvent());
        },
        expect: () => [
          isA<ClientBookingLoading>(),
          isA<ClientBookingError>(),
          isA<ClientBookingInitial>(),
        ],
      );
    });
  });
}
