import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';

import 'package:flutter_pro_test/core/errors/failures.dart';
import 'package:flutter_pro_test/shared/models/user_profile_model.dart';
import 'package:flutter_pro_test/features/profile/domain/repositories/user_profile_repository.dart';
import 'package:flutter_pro_test/features/profile/domain/usecases/create_user_profile.dart';

import 'create_user_profile_test.mocks.dart';

@GenerateMocks([UserProfileRepository])
void main() {
  late CreateUserProfile usecase;
  late MockUserProfileRepository mockRepository;

  setUp(() {
    mockRepository = MockUserProfileRepository();
    usecase = CreateUserProfile(mockRepository);
  });

  final testProfile = UserProfileModel(
    uid: '123',
    email: 'test@example.com',
    displayName: 'Test User',
    phoneNumber: '0987654321', // Valid Vietnamese phone number
    role: UserRole.client,
    createdAt: DateTime.now(),
  );

  group('CreateUserProfile', () {
    test(
      'should return UserProfileModel when profile creation is successful',
      () async {
        // arrange
        when(
          mockRepository.createUserProfile(any),
        ).thenAnswer((_) async => Right(testProfile));

        // act
        final result = await usecase(
          CreateUserProfileParams(profile: testProfile),
        );

        // assert
        expect(result, Right(testProfile));
        verify(mockRepository.createUserProfile(testProfile));
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test('should return ValidationFailure when UID is empty', () async {
      // arrange
      final invalidProfile = testProfile.copyWith(uid: '');

      // act
      final result = await usecase(
        CreateUserProfileParams(profile: invalidProfile),
      );

      // assert
      expect(result, const Left(ValidationFailure('User ID cannot be empty')));
      verifyZeroInteractions(mockRepository);
    });

    test('should return ValidationFailure when email is empty', () async {
      // arrange
      final invalidProfile = testProfile.copyWith(email: '');

      // act
      final result = await usecase(
        CreateUserProfileParams(profile: invalidProfile),
      );

      // assert
      expect(result, const Left(ValidationFailure('Email cannot be empty')));
      verifyZeroInteractions(mockRepository);
    });

    test(
      'should return ValidationFailure when display name is empty',
      () async {
        // arrange
        final invalidProfile = testProfile.copyWith(displayName: '');

        // act
        final result = await usecase(
          CreateUserProfileParams(profile: invalidProfile),
        );

        // assert
        expect(
          result,
          const Left(ValidationFailure('Display name cannot be empty')),
        );
        verifyZeroInteractions(mockRepository);
      },
    );

    test(
      'should return ValidationFailure when email format is invalid',
      () async {
        // arrange
        final invalidProfile = testProfile.copyWith(email: 'invalid-email');

        // act
        final result = await usecase(
          CreateUserProfileParams(profile: invalidProfile),
        );

        // assert
        expect(result, const Left(ValidationFailure('Invalid email format')));
        verifyZeroInteractions(mockRepository);
      },
    );

    test(
      'should return ValidationFailure when display name is too short',
      () async {
        // arrange
        final invalidProfile = testProfile.copyWith(displayName: 'A');

        // act
        final result = await usecase(
          CreateUserProfileParams(profile: invalidProfile),
        );

        // assert
        expect(
          result,
          const Left(
            ValidationFailure('Display name must be at least 2 characters'),
          ),
        );
        verifyZeroInteractions(mockRepository);
      },
    );

    test(
      'should return ValidationFailure when phone number format is invalid',
      () async {
        // arrange
        final invalidProfile = testProfile.copyWith(phoneNumber: '123');

        // act
        final result = await usecase(
          CreateUserProfileParams(profile: invalidProfile),
        );

        // assert
        expect(
          result,
          const Left(
            ValidationFailure('Invalid Vietnamese phone number format'),
          ),
        );
        verifyZeroInteractions(mockRepository);
      },
    );

    test('should return DataFailure when repository fails', () async {
      // arrange
      when(
        mockRepository.createUserProfile(any),
      ).thenAnswer((_) async => const Left(DataFailure('Database error')));

      // act
      final result = await usecase(
        CreateUserProfileParams(profile: testProfile),
      );

      // assert
      expect(result, const Left(DataFailure('Database error')));
      verify(mockRepository.createUserProfile(testProfile));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should accept valid Vietnamese phone numbers', () async {
      // arrange
      final validPhoneNumbers = [
        '0987654321', // Valid: 0 + 9 + 8 digits
        '+84987654321', // Valid: +84 + 9 + 8 digits
        '84987654321', // Valid: 84 + 9 + 8 digits
        '0356789012', // Valid: 0 + 3 + 8 digits
        '0789123456', // Valid: 0 + 7 + 8 digits
      ];

      when(
        mockRepository.createUserProfile(any),
      ).thenAnswer((_) async => Right(testProfile));

      for (final phoneNumber in validPhoneNumbers) {
        // arrange
        final profileWithValidPhone = testProfile.copyWith(
          phoneNumber: phoneNumber,
        );

        // act
        final result = await usecase(
          CreateUserProfileParams(profile: profileWithValidPhone),
        );

        // assert
        expect(result, Right(testProfile));
      }
    });
  });
}
