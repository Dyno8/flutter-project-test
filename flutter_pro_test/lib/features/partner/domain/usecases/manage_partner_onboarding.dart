import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../shared/models/partner_model.dart';
import '../entities/partner_onboarding.dart';
import '../repositories/partner_repository.dart';

/// Use case for managing partner onboarding process
class ManagePartnerOnboarding implements UseCase<PartnerOnboarding, ManagePartnerOnboardingParams> {
  final PartnerRepository repository;

  const ManagePartnerOnboarding(this.repository);

  @override
  Future<Either<Failure, PartnerOnboarding>> call(ManagePartnerOnboardingParams params) async {
    switch (params.action) {
      case OnboardingAction.start:
        return _startOnboarding(params);
      case OnboardingAction.updateStep:
        return _updateStep(params);
      case OnboardingAction.completeStep:
        return _completeStep(params);
      case OnboardingAction.moveToStep:
        return _moveToStep(params);
      case OnboardingAction.complete:
        return _completeOnboarding(params);
    }
  }

  Future<Either<Failure, PartnerOnboarding>> _startOnboarding(ManagePartnerOnboardingParams params) async {
    if (params.uid.trim().isEmpty) {
      return const Left(ValidationFailure('User ID cannot be empty'));
    }

    final onboarding = PartnerOnboarding.create(params.uid);
    return Right(onboarding);
  }

  Future<Either<Failure, PartnerOnboarding>> _updateStep(ManagePartnerOnboardingParams params) async {
    if (params.onboarding == null) {
      return const Left(ValidationFailure('Onboarding data is required'));
    }

    if (params.partialProfile == null) {
      return const Left(ValidationFailure('Profile data is required for update'));
    }

    final updatedOnboarding = params.onboarding!.updatePartialProfile(params.partialProfile!);
    return Right(updatedOnboarding);
  }

  Future<Either<Failure, PartnerOnboarding>> _completeStep(ManagePartnerOnboardingParams params) async {
    if (params.onboarding == null) {
      return const Left(ValidationFailure('Onboarding data is required'));
    }

    if (params.step == null) {
      return const Left(ValidationFailure('Step is required for completion'));
    }

    // Validate if step can be completed
    if (!params.onboarding!.canMoveToNextStep()) {
      final message = params.onboarding!.getValidationMessage();
      return Left(ValidationFailure(message ?? 'Cannot complete current step'));
    }

    final updatedOnboarding = params.onboarding!.completeStep(params.step!);
    return Right(updatedOnboarding);
  }

  Future<Either<Failure, PartnerOnboarding>> _moveToStep(ManagePartnerOnboardingParams params) async {
    if (params.onboarding == null) {
      return const Left(ValidationFailure('Onboarding data is required'));
    }

    if (params.step == null) {
      return const Left(ValidationFailure('Target step is required'));
    }

    // Validate if can move to target step
    final targetStepNumber = params.step!.stepNumber;
    final currentStepNumber = params.onboarding!.currentStep.stepNumber;

    // Can only move forward if previous steps are completed
    if (targetStepNumber > currentStepNumber) {
      for (int i = 1; i < targetStepNumber; i++) {
        final step = OnboardingStep.fromInt(i);
        if (!params.onboarding!.isStepCompleted(step)) {
          return Left(ValidationFailure('Must complete step ${step.displayName} first'));
        }
      }
    }

    final updatedOnboarding = params.onboarding!.moveToStep(params.step!);
    return Right(updatedOnboarding);
  }

  Future<Either<Failure, PartnerOnboarding>> _completeOnboarding(ManagePartnerOnboardingParams params) async {
    if (params.onboarding == null) {
      return const Left(ValidationFailure('Onboarding data is required'));
    }

    if (params.partialProfile == null) {
      return const Left(ValidationFailure('Complete profile data is required'));
    }

    // Validate that all required steps are completed
    final requiredSteps = [
      OnboardingStep.personalInfo,
      OnboardingStep.services,
      OnboardingStep.workingHours,
      OnboardingStep.location,
      OnboardingStep.pricing,
    ];

    for (final step in requiredSteps) {
      if (!params.onboarding!.isStepCompleted(step)) {
        return Left(ValidationFailure('Step ${step.displayName} must be completed'));
      }
    }

    // Validate final profile
    final profile = params.partialProfile!;
    
    if (profile.name.trim().isEmpty) {
      return const Left(ValidationFailure('Partner name is required'));
    }

    if (profile.email.trim().isEmpty) {
      return const Left(ValidationFailure('Email is required'));
    }

    if (profile.phone.trim().isEmpty) {
      return const Left(ValidationFailure('Phone number is required'));
    }

    if (profile.services.isEmpty) {
      return const Left(ValidationFailure('At least one service is required'));
    }

    if (profile.workingHours.isEmpty) {
      return const Left(ValidationFailure('Working hours are required'));
    }

    if (profile.location == null) {
      return const Left(ValidationFailure('Location is required'));
    }

    if (profile.pricePerHour <= 0) {
      return const Left(ValidationFailure('Valid price per hour is required'));
    }

    // Create the partner profile
    final createResult = await repository.createPartner(profile);
    
    return createResult.fold(
      (failure) => Left(failure),
      (createdPartner) {
        final completedOnboarding = params.onboarding!
            .completeStep(OnboardingStep.verification)
            .moveToStep(OnboardingStep.completed);
        
        return Right(completedOnboarding);
      },
    );
  }
}

/// Enum for onboarding actions
enum OnboardingAction {
  start,
  updateStep,
  completeStep,
  moveToStep,
  complete,
}

/// Parameters for manage partner onboarding use case
class ManagePartnerOnboardingParams extends Equatable {
  final String uid;
  final OnboardingAction action;
  final PartnerOnboarding? onboarding;
  final OnboardingStep? step;
  final PartnerModel? partialProfile;

  const ManagePartnerOnboardingParams({
    required this.uid,
    required this.action,
    this.onboarding,
    this.step,
    this.partialProfile,
  });

  @override
  List<Object?> get props => [uid, action, onboarding, step, partialProfile];
}
