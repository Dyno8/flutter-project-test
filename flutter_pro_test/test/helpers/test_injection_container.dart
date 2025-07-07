import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

// Import all the services and repositories that need to be mocked for tests
import 'package:flutter_pro_test/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_pro_test/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_pro_test/features/auth/domain/usecases/sign_in_with_email.dart';
import 'package:flutter_pro_test/features/auth/domain/usecases/sign_up_with_email.dart';
import 'package:flutter_pro_test/features/auth/domain/usecases/sign_in_with_phone.dart';
import 'package:flutter_pro_test/features/auth/domain/usecases/verify_phone_number.dart';
import 'package:flutter_pro_test/features/auth/domain/usecases/sign_out.dart';
import 'package:flutter_pro_test/features/auth/domain/usecases/get_current_user.dart';
import 'package:flutter_pro_test/features/profile/domain/repositories/user_profile_repository.dart';
import 'package:flutter_pro_test/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:flutter_pro_test/features/profile/domain/usecases/get_user_profile.dart';
import 'package:flutter_pro_test/features/profile/domain/usecases/create_user_profile.dart';
import 'package:flutter_pro_test/features/profile/domain/usecases/update_user_profile.dart';
import 'package:flutter_pro_test/features/profile/domain/usecases/update_profile_avatar.dart';
import 'package:flutter_pro_test/features/booking/domain/repositories/booking_repository.dart';
import 'package:flutter_pro_test/features/booking/presentation/bloc/booking_bloc.dart';
import 'package:flutter_pro_test/features/booking/domain/usecases/create_booking.dart';
import 'package:flutter_pro_test/features/booking/domain/usecases/get_user_bookings.dart';
import 'package:flutter_pro_test/features/booking/domain/usecases/get_available_services.dart';
import 'package:flutter_pro_test/features/booking/domain/usecases/get_available_partners.dart';
import 'package:flutter_pro_test/features/booking/domain/usecases/cancel_booking.dart';
import 'package:flutter_pro_test/features/notifications/domain/repositories/notification_repository.dart';
import 'package:flutter_pro_test/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:flutter_pro_test/features/notifications/domain/usecases/get_user_notifications.dart';
import 'package:flutter_pro_test/features/notifications/domain/usecases/get_unread_notifications.dart';
import 'package:flutter_pro_test/features/notifications/domain/usecases/mark_notification_as_read.dart';
import 'package:flutter_pro_test/features/notifications/domain/usecases/create_notification.dart';
import 'package:flutter_pro_test/features/notifications/domain/usecases/send_push_notification.dart';
import 'package:flutter_pro_test/features/notifications/domain/usecases/get_notification_preferences.dart';
import 'package:flutter_pro_test/features/notifications/domain/usecases/update_notification_preferences.dart';
import 'package:flutter_pro_test/shared/services/notification_service.dart';
import 'package:flutter_pro_test/shared/services/notification_action_handler.dart';
import 'package:flutter_pro_test/shared/services/notification_integration_service.dart';

// Mock classes
class MockAuthRepository extends Mock implements AuthRepository {}

class MockUserProfileRepository extends Mock implements UserProfileRepository {}

class MockBookingRepository extends Mock implements BookingRepository {}

class MockNotificationRepository extends Mock
    implements NotificationRepository {}

class MockNotificationService extends Mock implements NotificationService {}

class MockNotificationActionHandler extends Mock
    implements NotificationActionHandler {}

class MockNotificationIntegrationService extends Mock
    implements NotificationIntegrationService {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockFirebaseStorage extends Mock implements FirebaseStorage {}

// Mock use cases - Auth
class MockSignInWithEmail extends Mock implements SignInWithEmail {}

class MockSignUpWithEmail extends Mock implements SignUpWithEmail {}

class MockSignInWithPhone extends Mock implements SignInWithPhone {}

class MockVerifyPhoneNumber extends Mock implements VerifyPhoneNumber {}

class MockSignOut extends Mock implements SignOut {}

class MockGetCurrentUser extends Mock implements GetCurrentUser {}

// Mock use cases - Profile
class MockGetUserProfile extends Mock implements GetUserProfile {}

class MockCreateUserProfile extends Mock implements CreateUserProfile {}

class MockUpdateUserProfile extends Mock implements UpdateUserProfile {}

class MockUpdateProfileAvatar extends Mock implements UpdateProfileAvatar {}

// Mock use cases - Booking
class MockCreateBooking extends Mock implements CreateBooking {}

class MockGetUserBookings extends Mock implements GetUserBookings {}

class MockGetAvailableServices extends Mock implements GetAvailableServices {}

class MockGetAvailablePartners extends Mock implements GetAvailablePartners {}

class MockCancelBooking extends Mock implements CancelBooking {}

// Mock use cases - Notifications
class MockGetUserNotifications extends Mock implements GetUserNotifications {}

class MockGetUnreadNotifications extends Mock
    implements GetUnreadNotifications {}

class MockMarkNotificationAsRead extends Mock
    implements MarkNotificationAsRead {}

class MockCreateNotification extends Mock implements CreateNotification {}

class MockSendPushNotification extends Mock implements SendPushNotification {}

class MockGetNotificationPreferences extends Mock
    implements GetNotificationPreferences {}

class MockUpdateNotificationPreferences extends Mock
    implements UpdateNotificationPreferences {}

final GetIt testSl = GetIt.instance;

/// Initialize test dependencies with mocks
Future<void> initTestDependencies() async {
  // Clear any existing registrations
  if (testSl.isRegistered<AuthRepository>()) {
    await testSl.reset();
  }

  // Register mock repositories
  testSl.registerLazySingleton<AuthRepository>(() => MockAuthRepository());
  testSl.registerLazySingleton<UserProfileRepository>(
    () => MockUserProfileRepository(),
  );
  testSl.registerLazySingleton<BookingRepository>(
    () => MockBookingRepository(),
  );
  testSl.registerLazySingleton<NotificationRepository>(
    () => MockNotificationRepository(),
  );

  // Register mock services
  testSl.registerLazySingleton<NotificationService>(
    () => MockNotificationService(),
  );
  testSl.registerLazySingleton<NotificationActionHandler>(
    () => MockNotificationActionHandler(),
  );
  testSl.registerLazySingleton<NotificationIntegrationService>(
    () => MockNotificationIntegrationService(),
  );

  // Register mock Firebase services
  testSl.registerLazySingleton<FirebaseAuth>(() => MockFirebaseAuth());
  testSl.registerLazySingleton<FirebaseFirestore>(
    () => MockFirebaseFirestore(),
  );
  testSl.registerLazySingleton<FirebaseStorage>(() => MockFirebaseStorage());

  // Register mock use cases - Auth
  testSl.registerLazySingleton<SignInWithEmail>(() => MockSignInWithEmail());
  testSl.registerLazySingleton<SignUpWithEmail>(() => MockSignUpWithEmail());
  testSl.registerLazySingleton<SignInWithPhone>(() => MockSignInWithPhone());
  testSl.registerLazySingleton<VerifyPhoneNumber>(
    () => MockVerifyPhoneNumber(),
  );
  testSl.registerLazySingleton<SignOut>(() => MockSignOut());
  testSl.registerLazySingleton<GetCurrentUser>(() => MockGetCurrentUser());

  // Register mock use cases - Profile
  testSl.registerLazySingleton<GetUserProfile>(() => MockGetUserProfile());
  testSl.registerLazySingleton<CreateUserProfile>(
    () => MockCreateUserProfile(),
  );
  testSl.registerLazySingleton<UpdateUserProfile>(
    () => MockUpdateUserProfile(),
  );
  testSl.registerLazySingleton<UpdateProfileAvatar>(
    () => MockUpdateProfileAvatar(),
  );

  // Register mock use cases - Booking
  testSl.registerLazySingleton<CreateBooking>(() => MockCreateBooking());
  testSl.registerLazySingleton<GetUserBookings>(() => MockGetUserBookings());
  testSl.registerLazySingleton<GetAvailableServices>(
    () => MockGetAvailableServices(),
  );
  testSl.registerLazySingleton<GetAvailablePartners>(
    () => MockGetAvailablePartners(),
  );
  testSl.registerLazySingleton<CancelBooking>(() => MockCancelBooking());

  // Register mock use cases - Notifications
  testSl.registerLazySingleton<GetUserNotifications>(
    () => MockGetUserNotifications(),
  );
  testSl.registerLazySingleton<GetUnreadNotifications>(
    () => MockGetUnreadNotifications(),
  );
  testSl.registerLazySingleton<MarkNotificationAsRead>(
    () => MockMarkNotificationAsRead(),
  );
  testSl.registerLazySingleton<CreateNotification>(
    () => MockCreateNotification(),
  );
  testSl.registerLazySingleton<SendPushNotification>(
    () => MockSendPushNotification(),
  );
  testSl.registerLazySingleton<GetNotificationPreferences>(
    () => MockGetNotificationPreferences(),
  );
  testSl.registerLazySingleton<UpdateNotificationPreferences>(
    () => MockUpdateNotificationPreferences(),
  );

  // Register BLoCs with mock dependencies
  testSl.registerFactory<AuthBloc>(
    () => AuthBloc(
      authRepository: testSl<AuthRepository>(),
      signInWithEmail: testSl<SignInWithEmail>(),
      signUpWithEmail: testSl<SignUpWithEmail>(),
      signInWithPhone: testSl<SignInWithPhone>(),
      verifyPhoneNumber: testSl<VerifyPhoneNumber>(),
      signOut: testSl<SignOut>(),
      getCurrentUser: testSl<GetCurrentUser>(),
    ),
  );

  testSl.registerFactory<ProfileBloc>(
    () => ProfileBloc(
      getUserProfile: testSl<GetUserProfile>(),
      createUserProfile: testSl<CreateUserProfile>(),
      updateUserProfile: testSl<UpdateUserProfile>(),
      updateProfileAvatar: testSl<UpdateProfileAvatar>(),
      repository: testSl<UserProfileRepository>(),
    ),
  );

  testSl.registerFactory<BookingBloc>(
    () => BookingBloc(
      createBooking: testSl<CreateBooking>(),
      getUserBookings: testSl<GetUserBookings>(),
      getAvailableServices: testSl<GetAvailableServices>(),
      getAvailablePartners: testSl<GetAvailablePartners>(),
      cancelBooking: testSl<CancelBooking>(),
    ),
  );

  testSl.registerFactory<NotificationBloc>(
    () => NotificationBloc(
      getUserNotifications: testSl<GetUserNotifications>(),
      getUnreadNotifications: testSl<GetUnreadNotifications>(),
      markNotificationAsRead: testSl<MarkNotificationAsRead>(),
      createNotification: testSl<CreateNotification>(),
      sendPushNotification: testSl<SendPushNotification>(),
      getNotificationPreferences: testSl<GetNotificationPreferences>(),
      updateNotificationPreferences: testSl<UpdateNotificationPreferences>(),
      repository: testSl<NotificationRepository>(),
    ),
  );
}

/// Clean up test dependencies
Future<void> cleanupTestDependencies() async {
  await testSl.reset();
}
