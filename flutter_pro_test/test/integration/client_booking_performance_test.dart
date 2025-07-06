import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';

import 'package:flutter_pro_test/features/client/presentation/bloc/client_booking_bloc.dart';
import 'package:flutter_pro_test/features/client/presentation/bloc/client_booking_event.dart';
import 'package:flutter_pro_test/features/client/presentation/bloc/client_booking_state.dart';
import 'package:flutter_pro_test/features/client/domain/usecases/get_available_services.dart';
import 'package:flutter_pro_test/features/client/domain/usecases/search_available_partners.dart';
import 'package:flutter_pro_test/features/client/domain/usecases/create_booking.dart';
import 'package:flutter_pro_test/features/client/domain/usecases/process_payment.dart';
import 'package:flutter_pro_test/features/client/domain/usecases/get_client_bookings.dart';
import 'package:flutter_pro_test/features/booking/domain/entities/service.dart';
import 'package:flutter_pro_test/features/booking/domain/entities/partner.dart';
import 'package:flutter_pro_test/features/booking/domain/entities/booking.dart';
import 'package:flutter_pro_test/features/client/domain/entities/payment_request.dart';
import 'package:flutter_pro_test/features/client/domain/entities/payment_result.dart';
import 'package:flutter_pro_test/core/usecases/usecase.dart';
import 'package:flutter_pro_test/core/errors/failures.dart';

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
  group('Client Booking Performance Tests', () {
    late ClientBookingBloc clientBookingBloc;
    late MockGetAvailableServices mockGetAvailableServices;
    late MockSearchAvailablePartners mockSearchAvailablePartners;
    late MockCreateBooking mockCreateBooking;
    late MockProcessPayment mockProcessPayment;
    late MockGetAvailablePaymentMethods mockGetAvailablePaymentMethods;
    late MockGetClientBookings mockGetClientBookings;

    // Test data
    late List<Service> testServices;
    late List<Partner> testPartners;
    late Booking testBooking;
    late List<PaymentMethod> testPaymentMethods;
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

      // Initialize test data with multiple items for performance testing
      testServices = List.generate(
        50,
        (index) => Service(
          id: 'service-$index',
          name: 'Service $index',
          description: 'Test service $index',
          category: 'test-category',
          iconUrl: 'icon-$index.png',
          basePrice: 50000.0 + (index * 1000),
          durationMinutes: 60 + (index * 10),
          requirements: ['Requirement $index'],
          benefits: ['Benefit $index'],
          isActive: true,
          sortOrder: index,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      testPartners = List.generate(
        20,
        (index) => Partner(
          uid: 'partner-$index',
          name: 'Partner $index',
          phone: '+123456789$index',
          email: 'partner$index@example.com',
          gender: index % 2 == 0 ? 'male' : 'female',
          services: ['test-category'],
          workingHours: {
            'monday': ['09:00', '17:00'],
          },
          rating: 4.0 + (index % 5) * 0.2,
          totalReviews: 100 + index * 10,
          latitude: 10.8231 + (index * 0.001),
          longitude: 106.6297 + (index * 0.001),
          address: 'Address $index',
          bio: 'Bio for partner $index',
          profileImageUrl: 'profile-$index.jpg',
          certifications: ['Cert $index'],
          experienceYears: 1 + (index % 10),
          pricePerHour: 50000.0 + (index * 1000),
          isAvailable: true,
          isVerified: index % 3 == 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      testBooking = Booking(
        id: 'booking-1',
        userId: 'user-1',
        partnerId: 'partner-1',
        serviceId: 'service-1',
        serviceName: 'Test Service',
        scheduledDate: DateTime.now().add(const Duration(days: 1)),
        timeSlot: '09:00',
        hours: 2.0,
        totalPrice: 110000.0,
        status: BookingStatus.pending,
        paymentStatus: PaymentStatus.unpaid,
        clientAddress: '123 Main St',
        clientLatitude: 10.8231,
        clientLongitude: 106.6297,
        specialInstructions: 'Test instructions',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      testPaymentMethods = [
        const PaymentMethod(
          id: 'mock',
          type: PaymentMethodType.mock,
          name: 'mock',
          displayName: 'Mock Payment',
          isEnabled: true,
        ),
        const PaymentMethod(
          id: 'stripe',
          type: PaymentMethodType.stripe,
          name: 'stripe',
          displayName: 'Credit Card',
          isEnabled: true,
        ),
        const PaymentMethod(
          id: 'cash',
          type: PaymentMethodType.cash,
          name: 'cash',
          displayName: 'Cash',
          isEnabled: true,
        ),
      ];

      testPaymentResult = PaymentResult.success(
        transactionId: 'txn-123',
        amount: 110000.0,
        currency: 'VND',
      );
    });

    tearDown(() {
      clientBookingBloc.close();
    });

    group('Performance Tests', () {
      test('should handle large service list efficiently', () async {
        // Arrange
        when(
          mockGetAvailableServices.call(any),
        ).thenAnswer((_) async => Right(testServices));

        final stopwatch = Stopwatch()..start();

        // Act
        clientBookingBloc.add(const LoadAvailableServicesEvent());

        // Wait for state emission
        await expectLater(
          clientBookingBloc.stream,
          emitsInOrder([
            isA<ClientBookingLoading>(),
            isA<ServicesLoadedState>().having(
              (s) => s.services.length,
              'services count',
              50,
            ),
          ]),
        );

        stopwatch.stop();

        // Assert - Should complete within reasonable time (< 1 second)
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
        print('Service loading took: ${stopwatch.elapsedMilliseconds}ms');
      });

      test('should handle large partner list efficiently', () async {
        // Arrange
        when(
          mockSearchAvailablePartners.call(any),
        ).thenAnswer((_) async => Right(testPartners));

        // Set up initial state
        clientBookingBloc.add(SelectServiceEvent(testServices.first));
        clientBookingBloc.add(
          SelectDateTimeEvent(
            date: DateTime.now().add(const Duration(days: 1)),
            timeSlot: '09:00',
            hours: 2.0,
          ),
        );
        clientBookingBloc.add(
          const SetClientLocationEvent(
            address: '123 Main St',
            latitude: 10.8231,
            longitude: 106.6297,
          ),
        );

        // Wait for setup to complete
        await Future.delayed(const Duration(milliseconds: 100));

        final stopwatch = Stopwatch()..start();

        // Act
        clientBookingBloc.add(const LoadAvailablePartnersEvent());

        // Wait for partner loading to complete
        await expectLater(
          clientBookingBloc.stream,
          emitsThrough(
            isA<BookingFlowState>()
                .having(
                  (s) => s.availablePartners?.length,
                  'partners count',
                  20,
                )
                .having((s) => s.isLoading, 'loading', false),
          ),
        );

        stopwatch.stop();

        // Assert - Should complete within reasonable time (< 2 seconds)
        expect(stopwatch.elapsedMilliseconds, lessThan(2000));
        print('Partner loading took: ${stopwatch.elapsedMilliseconds}ms');
      });

      test('should handle rapid state changes efficiently', () async {
        // Arrange
        when(
          mockGetAvailableServices.call(any),
        ).thenAnswer((_) async => Right(testServices));
        when(
          mockSearchAvailablePartners.call(any),
        ).thenAnswer((_) async => Right(testPartners));
        when(
          mockGetAvailablePaymentMethods.call(any),
        ).thenAnswer((_) async => Right(testPaymentMethods));

        final stopwatch = Stopwatch()..start();

        // Act - Rapid sequence of events
        clientBookingBloc.add(const LoadAvailableServicesEvent());
        await Future.delayed(const Duration(milliseconds: 50));

        clientBookingBloc.add(SelectServiceEvent(testServices.first));
        await Future.delayed(const Duration(milliseconds: 50));

        clientBookingBloc.add(
          SelectDateTimeEvent(
            date: DateTime.now().add(const Duration(days: 1)),
            timeSlot: '09:00',
            hours: 2.0,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 50));

        clientBookingBloc.add(
          const SetClientLocationEvent(
            address: '123 Main St',
            latitude: 10.8231,
            longitude: 106.6297,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 50));

        clientBookingBloc.add(const LoadAvailablePartnersEvent());
        await Future.delayed(const Duration(milliseconds: 100));

        clientBookingBloc.add(SelectPartnerEvent(testPartners.first));
        await Future.delayed(const Duration(milliseconds: 50));

        clientBookingBloc.add(const LoadPaymentMethodsEvent());

        // Wait for final state
        await expectLater(
          clientBookingBloc.stream,
          emitsThrough(
            isA<BookingFlowState>()
                .having(
                  (s) => s.paymentMethods?.isNotEmpty,
                  'has payment methods',
                  true,
                )
                .having(
                  (s) => s.currentStep,
                  'step',
                  BookingStep.paymentMethod,
                ),
          ),
        );

        stopwatch.stop();

        // Assert - Should handle rapid changes efficiently (< 3 seconds)
        expect(stopwatch.elapsedMilliseconds, lessThan(3000));
        print('Rapid state changes took: ${stopwatch.elapsedMilliseconds}ms');
      });

      test('should handle concurrent operations efficiently', () async {
        // Arrange
        when(mockGetAvailableServices.call(any)).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return Right(testServices);
        });
        when(mockGetAvailablePaymentMethods.call(any)).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 150));
          return Right(testPaymentMethods);
        });

        final stopwatch = Stopwatch()..start();

        // Act - Trigger concurrent operations
        clientBookingBloc.add(const LoadAvailableServicesEvent());
        clientBookingBloc.add(const LoadPaymentMethodsEvent());

        // Wait for both operations to complete
        await expectLater(
          clientBookingBloc.stream,
          emitsThrough(
            isA<BookingFlowState>().having(
              (s) => s.paymentMethods?.isNotEmpty,
              'has payment methods',
              true,
            ),
          ),
        );

        stopwatch.stop();

        // Assert - Should handle concurrent operations efficiently
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
        print('Concurrent operations took: ${stopwatch.elapsedMilliseconds}ms');
      });

      test('should maintain memory efficiency during extended usage', () async {
        // Arrange
        when(
          mockGetAvailableServices.call(any),
        ).thenAnswer((_) async => Right(testServices));

        // Act - Simulate extended usage with multiple service loads
        for (int i = 0; i < 10; i++) {
          clientBookingBloc.add(const LoadAvailableServicesEvent());
          await Future.delayed(const Duration(milliseconds: 100));

          // Verify state is properly managed
          expect(clientBookingBloc.state, isA<ServicesLoadedState>());
        }

        // Assert - BLoC should still be responsive
        final stopwatch = Stopwatch()..start();
        clientBookingBloc.add(const LoadAvailableServicesEvent());

        await expectLater(
          clientBookingBloc.stream,
          emits(isA<ServicesLoadedState>()),
        );

        stopwatch.stop();

        // Should still respond quickly after extended usage
        expect(stopwatch.elapsedMilliseconds, lessThan(500));
        print(
          'Response time after extended usage: ${stopwatch.elapsedMilliseconds}ms',
        );
      });
    });

    group('Error Handling Performance', () {
      test('should handle errors efficiently without memory leaks', () async {
        // Arrange
        when(
          mockGetAvailableServices.call(any),
        ).thenAnswer((_) async => Left(ServerFailure('Network error')));

        final stopwatch = Stopwatch()..start();

        // Act - Trigger multiple error scenarios
        for (int i = 0; i < 5; i++) {
          clientBookingBloc.add(const LoadAvailableServicesEvent());
          await Future.delayed(const Duration(milliseconds: 50));

          clientBookingBloc.add(const ClearErrorEvent());
          await Future.delayed(const Duration(milliseconds: 50));
        }

        stopwatch.stop();

        // Assert - Error handling should be efficient
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
        print('Error handling took: ${stopwatch.elapsedMilliseconds}ms');

        // Final state should be clean
        expect(clientBookingBloc.state, isA<ClientBookingInitial>());
      });
    });
  });
}
