import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../features/auth/data/datasources/firebase_auth_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/sign_in_with_email.dart';
import '../../features/auth/domain/usecases/sign_up_with_email.dart';
import '../../features/auth/domain/usecases/sign_in_with_phone.dart';
import '../../features/auth/domain/usecases/verify_phone_number.dart';
import '../../features/auth/domain/usecases/sign_out.dart';
import '../../features/auth/domain/usecases/get_current_user.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/profile/data/datasources/user_profile_datasource.dart';
import '../../features/profile/data/repositories/user_profile_repository_impl.dart';
import '../../features/profile/domain/repositories/user_profile_repository.dart';
import '../../features/profile/domain/usecases/get_user_profile.dart';
import '../../features/profile/domain/usecases/create_user_profile.dart';
import '../../features/profile/domain/usecases/update_user_profile.dart';
import '../../features/profile/domain/usecases/update_profile_avatar.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/booking/data/datasources/booking_remote_datasource.dart';
import '../../features/booking/data/datasources/service_remote_datasource.dart';
import '../../features/booking/data/datasources/partner_remote_datasource.dart';
import '../../features/booking/data/repositories/booking_repository_impl.dart';
import '../../features/booking/data/repositories/service_repository_impl.dart';
import '../../features/booking/data/repositories/partner_repository_impl.dart';
import '../../features/booking/domain/repositories/booking_repository.dart';
import '../../features/booking/domain/repositories/service_repository.dart';
import '../../features/booking/domain/repositories/partner_repository.dart';
import '../../features/booking/domain/usecases/create_booking.dart';
import '../../features/booking/domain/usecases/get_user_bookings.dart';
import '../../features/booking/domain/usecases/get_available_services.dart';
import '../../features/booking/domain/usecases/get_available_partners.dart';
import '../../features/booking/domain/usecases/cancel_booking.dart';
import '../../features/booking/presentation/bloc/booking_bloc.dart';
import '../../features/partner/data/datasources/partner_job_remote_data_source.dart';
import '../../features/partner/data/repositories/partner_job_repository_impl.dart';
import '../../features/partner/domain/repositories/partner_job_repository.dart';
import '../../features/partner/domain/usecases/get_pending_jobs.dart';
import '../../features/partner/domain/usecases/accept_job.dart';
import '../../features/partner/domain/usecases/reject_job.dart';
import '../../features/partner/domain/usecases/manage_job_status.dart';
import '../../features/partner/domain/usecases/get_partner_earnings.dart';
import '../../features/partner/domain/usecases/manage_availability.dart';
import '../../features/partner/presentation/bloc/partner_dashboard_bloc.dart';
import '../../features/client/data/datasources/client_service_remote_data_source.dart';
import '../../features/client/data/datasources/payment_remote_data_source.dart';
import '../../features/client/data/repositories/client_service_repository_impl.dart';
import '../../features/client/data/repositories/payment_repository_impl.dart';
import '../../features/client/domain/repositories/client_service_repository.dart';
import '../../features/client/domain/repositories/payment_repository.dart';
import '../../features/client/domain/usecases/get_available_services.dart'
    as client_services;
import '../../features/client/domain/usecases/search_available_partners.dart';
import '../../features/client/domain/usecases/create_booking.dart'
    as client_booking;
import '../../features/client/domain/usecases/process_payment.dart';
import '../../features/client/domain/usecases/get_client_bookings.dart';
import '../../features/client/presentation/bloc/client_booking_bloc.dart';
import '../../shared/services/firebase_service.dart';

final sl = GetIt.instance;

/// Initialize all dependencies
Future<void> init() async {
  //! Features - Authentication
  // Bloc
  sl.registerFactory(
    () => AuthBloc(
      authRepository: sl(),
      signInWithEmail: sl(),
      signUpWithEmail: sl(),
      signInWithPhone: sl(),
      verifyPhoneNumber: sl(),
      signOut: sl(),
      getCurrentUser: sl(),
    ),
  );

  //! Features - Profile
  // Bloc
  sl.registerFactory(
    () => ProfileBloc(
      getUserProfile: sl(),
      createUserProfile: sl(),
      updateUserProfile: sl(),
      updateProfileAvatar: sl(),
      repository: sl(),
    ),
  );

  //! Features - Booking
  // Bloc
  sl.registerFactory(
    () => BookingBloc(
      createBooking: sl(),
      getUserBookings: sl(),
      getAvailableServices: sl(),
      getAvailablePartners: sl(),
      cancelBooking: sl(),
    ),
  );

  //! Features - Partner Dashboard
  // Bloc
  sl.registerFactory(
    () => PartnerDashboardBloc(
      getPendingJobs: sl(),
      acceptJob: sl(),
      rejectJob: sl(),
      startJob: sl(),
      completeJob: sl(),
      cancelJob: sl(),
      getPartnerEarnings: sl(),
      getPartnerAvailability: sl(),
      updateAvailabilityStatus: sl(),
      updateOnlineStatus: sl(),
      updateWorkingHours: sl(),
      repository: sl(),
    ),
  );

  //! Features - Client Booking
  // Bloc
  sl.registerFactory(
    () => ClientBookingBloc(
      getAvailableServices: sl(),
      searchAvailablePartners: sl(),
      createBooking: sl(),
      processPayment: sl(),
      getAvailablePaymentMethods: sl(),
      getClientBookings: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => SignInWithEmail(sl()));
  sl.registerLazySingleton(() => SignUpWithEmail(sl()));
  sl.registerLazySingleton(() => SignInWithPhone(sl()));
  sl.registerLazySingleton(() => VerifyPhoneNumber(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));

  // Profile use cases
  sl.registerLazySingleton(() => GetUserProfile(sl()));
  sl.registerLazySingleton(() => CreateUserProfile(sl()));
  sl.registerLazySingleton(() => UpdateUserProfile(sl()));
  sl.registerLazySingleton(() => UpdateProfileAvatar(sl()));

  // Booking use cases
  sl.registerLazySingleton(() => CreateBooking(sl()));
  sl.registerLazySingleton(() => GetUserBookings(sl()));
  sl.registerLazySingleton(() => GetAvailableServices(sl()));
  sl.registerLazySingleton(() => GetAvailablePartners(sl()));
  sl.registerLazySingleton(() => CancelBooking(sl()));

  // Partner dashboard use cases
  sl.registerLazySingleton(() => GetPendingJobs(sl()));
  sl.registerLazySingleton(() => AcceptJob(sl()));
  sl.registerLazySingleton(() => RejectJob(sl()));
  sl.registerLazySingleton(() => StartJob(sl()));
  sl.registerLazySingleton(() => CompleteJob(sl()));
  sl.registerLazySingleton(() => CancelJob(sl()));
  sl.registerLazySingleton(() => GetPartnerEarnings(sl()));
  sl.registerLazySingleton(() => GetPartnerAvailability(sl()));
  sl.registerLazySingleton(() => UpdateAvailabilityStatus(sl()));
  sl.registerLazySingleton(() => UpdateOnlineStatus(sl()));
  sl.registerLazySingleton(() => UpdateWorkingHours(sl()));

  // Client booking use cases
  sl.registerLazySingleton(() => client_services.GetAvailableServices(sl()));
  sl.registerLazySingleton(() => SearchAvailablePartners(sl()));
  sl.registerLazySingleton(() => client_booking.CreateBooking(sl()));
  sl.registerLazySingleton(() => ProcessPayment(sl()));
  sl.registerLazySingleton(() => GetAvailablePaymentMethods(sl()));
  sl.registerLazySingleton(() => GetClientBookings(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(dataSource: sl()),
  );

  // Profile repository
  sl.registerLazySingleton<UserProfileRepository>(
    () => UserProfileRepositoryImpl(dataSource: sl()),
  );

  // Booking repositories
  sl.registerLazySingleton<BookingRepository>(
    () => BookingRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<ServiceRepository>(
    () => ServiceRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<PartnerRepository>(
    () => PartnerRepositoryImpl(remoteDataSource: sl()),
  );

  // Partner dashboard repository
  sl.registerLazySingleton<PartnerJobRepository>(
    () => PartnerJobRepositoryImpl(remoteDataSource: sl()),
  );

  // Client repositories
  sl.registerLazySingleton<ClientServiceRepository>(
    () => ClientServiceRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<PaymentRepository>(
    () => PaymentRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<FirebaseAuthDataSource>(
    () => FirebaseAuthDataSourceImpl(firebaseAuth: sl()),
  );

  // Profile data source
  sl.registerLazySingleton<UserProfileDataSource>(
    () => FirebaseUserProfileDataSource(),
  );

  // Booking data sources
  sl.registerLazySingleton<BookingRemoteDataSource>(
    () => BookingRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<ServiceRemoteDataSource>(
    () => ServiceRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<PartnerRemoteDataSource>(
    () => PartnerRemoteDataSourceImpl(sl()),
  );

  // Partner dashboard data source
  sl.registerLazySingleton<PartnerJobRemoteDataSource>(
    () => PartnerJobRemoteDataSourceImpl(firebaseService: sl()),
  );

  // Client data sources
  sl.registerLazySingleton<ClientServiceRemoteDataSource>(
    () => ClientServiceRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<PaymentRemoteDataSource>(
    () => PaymentRemoteDataSourceImpl(sl()),
  );

  //! External
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseService());
}
