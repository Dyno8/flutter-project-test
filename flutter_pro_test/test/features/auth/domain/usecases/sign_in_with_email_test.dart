import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';

import 'package:flutter_pro_test/core/errors/failures.dart';
import 'package:flutter_pro_test/features/auth/domain/entities/auth_user.dart';
import 'package:flutter_pro_test/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_pro_test/features/auth/domain/usecases/sign_in_with_email.dart';

import 'sign_in_with_email_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late SignInWithEmail usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = SignInWithEmail(mockAuthRepository);
  });

  const testEmail = 'test@example.com';
  const testPassword = 'password123';
  const testUser = AuthUser(
    uid: '123',
    email: testEmail,
    displayName: 'Test User',
    isEmailVerified: true,
  );

  group('SignInWithEmail', () {
    test('should return AuthUser when sign in is successful', () async {
      // arrange
      when(mockAuthRepository.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => const Right(testUser));

      // act
      final result = await usecase(const SignInWithEmailParams(
        email: testEmail,
        password: testPassword,
      ));

      // assert
      expect(result, const Right(testUser));
      verify(mockAuthRepository.signInWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      ));
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return ValidationFailure when email is invalid', () async {
      // act
      final result = await usecase(const SignInWithEmailParams(
        email: 'invalid-email',
        password: testPassword,
      ));

      // assert
      expect(result, const Left(ValidationFailure('Invalid email format')));
      verifyZeroInteractions(mockAuthRepository);
    });

    test('should return ValidationFailure when password is too short', () async {
      // act
      final result = await usecase(const SignInWithEmailParams(
        email: testEmail,
        password: '123',
      ));

      // assert
      expect(result, const Left(ValidationFailure('Password must be at least 6 characters')));
      verifyZeroInteractions(mockAuthRepository);
    });

    test('should return AuthFailure when sign in fails', () async {
      // arrange
      when(mockAuthRepository.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => const Left(AuthFailure('Sign in failed')));

      // act
      final result = await usecase(const SignInWithEmailParams(
        email: testEmail,
        password: testPassword,
      ));

      // assert
      expect(result, const Left(AuthFailure('Sign in failed')));
      verify(mockAuthRepository.signInWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      ));
      verifyNoMoreInteractions(mockAuthRepository);
    });
  });
}
