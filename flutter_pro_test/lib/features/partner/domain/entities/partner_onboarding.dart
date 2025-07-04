import 'package:equatable/equatable.dart';

import '../../../../shared/models/partner_model.dart';

/// Enum for onboarding steps
enum OnboardingStep {
  personalInfo,
  services,
  workingHours,
  location,
  pricing,
  verification,
  completed;

  String get displayName {
    switch (this) {
      case OnboardingStep.personalInfo:
        return 'Thông tin cá nhân';
      case OnboardingStep.services:
        return 'Dịch vụ cung cấp';
      case OnboardingStep.workingHours:
        return 'Giờ làm việc';
      case OnboardingStep.location:
        return 'Địa điểm';
      case OnboardingStep.pricing:
        return 'Giá dịch vụ';
      case OnboardingStep.verification:
        return 'Xác thực';
      case OnboardingStep.completed:
        return 'Hoàn thành';
    }
  }

  String get description {
    switch (this) {
      case OnboardingStep.personalInfo:
        return 'Cung cấp thông tin cơ bản về bản thân';
      case OnboardingStep.services:
        return 'Chọn các dịch vụ bạn có thể cung cấp';
      case OnboardingStep.workingHours:
        return 'Thiết lập lịch làm việc của bạn';
      case OnboardingStep.location:
        return 'Xác định khu vực hoạt động';
      case OnboardingStep.pricing:
        return 'Đặt giá cho dịch vụ của bạn';
      case OnboardingStep.verification:
        return 'Xác thực danh tính và chứng chỉ';
      case OnboardingStep.completed:
        return 'Hồ sơ đã được hoàn thành';
    }
  }

  int get stepNumber {
    switch (this) {
      case OnboardingStep.personalInfo:
        return 1;
      case OnboardingStep.services:
        return 2;
      case OnboardingStep.workingHours:
        return 3;
      case OnboardingStep.location:
        return 4;
      case OnboardingStep.pricing:
        return 5;
      case OnboardingStep.verification:
        return 6;
      case OnboardingStep.completed:
        return 7;
    }
  }

  static OnboardingStep fromInt(int step) {
    switch (step) {
      case 1:
        return OnboardingStep.personalInfo;
      case 2:
        return OnboardingStep.services;
      case 3:
        return OnboardingStep.workingHours;
      case 4:
        return OnboardingStep.location;
      case 5:
        return OnboardingStep.pricing;
      case 6:
        return OnboardingStep.verification;
      case 7:
        return OnboardingStep.completed;
      default:
        return OnboardingStep.personalInfo;
    }
  }
}

/// Model representing partner onboarding progress
class PartnerOnboarding extends Equatable {
  final String uid;
  final OnboardingStep currentStep;
  final Map<OnboardingStep, bool> completedSteps;
  final PartnerModel? partialProfile;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const PartnerOnboarding({
    required this.uid,
    this.currentStep = OnboardingStep.personalInfo,
    this.completedSteps = const {},
    this.partialProfile,
    required this.createdAt,
    this.updatedAt,
  });

  /// Create a new onboarding process
  factory PartnerOnboarding.create(String uid) {
    return PartnerOnboarding(
      uid: uid,
      currentStep: OnboardingStep.personalInfo,
      completedSteps: {},
      createdAt: DateTime.now(),
    );
  }

  /// Get completion percentage
  double get completionPercentage {
    final totalSteps = OnboardingStep.values.length - 1; // Exclude completed step
    final completed = completedSteps.values.where((isCompleted) => isCompleted).length;
    return (completed / totalSteps) * 100;
  }

  /// Check if onboarding is complete
  bool get isComplete => currentStep == OnboardingStep.completed;

  /// Get next step
  OnboardingStep? get nextStep {
    if (isComplete) return null;
    
    final currentIndex = OnboardingStep.values.indexOf(currentStep);
    if (currentIndex < OnboardingStep.values.length - 1) {
      return OnboardingStep.values[currentIndex + 1];
    }
    return null;
  }

  /// Get previous step
  OnboardingStep? get previousStep {
    final currentIndex = OnboardingStep.values.indexOf(currentStep);
    if (currentIndex > 0) {
      return OnboardingStep.values[currentIndex - 1];
    }
    return null;
  }

  /// Check if a step is completed
  bool isStepCompleted(OnboardingStep step) {
    return completedSteps[step] ?? false;
  }

  /// Get remaining steps
  List<OnboardingStep> get remainingSteps {
    return OnboardingStep.values
        .where((step) => 
            step != OnboardingStep.completed && 
            !isStepCompleted(step))
        .toList();
  }

  /// Mark step as completed and move to next
  PartnerOnboarding completeStep(OnboardingStep step) {
    final newCompletedSteps = Map<OnboardingStep, bool>.from(completedSteps);
    newCompletedSteps[step] = true;

    // Determine next step
    OnboardingStep newCurrentStep = currentStep;
    if (step == currentStep) {
      final next = nextStep;
      if (next != null) {
        newCurrentStep = next;
      } else {
        newCurrentStep = OnboardingStep.completed;
      }
    }

    return copyWith(
      currentStep: newCurrentStep,
      completedSteps: newCompletedSteps,
      updatedAt: DateTime.now(),
    );
  }

  /// Update partial profile
  PartnerOnboarding updatePartialProfile(PartnerModel profile) {
    return copyWith(
      partialProfile: profile,
      updatedAt: DateTime.now(),
    );
  }

  /// Move to specific step
  PartnerOnboarding moveToStep(OnboardingStep step) {
    return copyWith(
      currentStep: step,
      updatedAt: DateTime.now(),
    );
  }

  /// Validate if can move to next step
  bool canMoveToNextStep() {
    switch (currentStep) {
      case OnboardingStep.personalInfo:
        return partialProfile != null &&
               partialProfile!.name.isNotEmpty &&
               partialProfile!.email.isNotEmpty &&
               partialProfile!.phone.isNotEmpty;
      
      case OnboardingStep.services:
        return partialProfile != null &&
               partialProfile!.services.isNotEmpty;
      
      case OnboardingStep.workingHours:
        return partialProfile != null &&
               partialProfile!.workingHours.isNotEmpty;
      
      case OnboardingStep.location:
        return partialProfile != null &&
               partialProfile!.location != null;
      
      case OnboardingStep.pricing:
        return partialProfile != null &&
               partialProfile!.pricePerHour > 0;
      
      case OnboardingStep.verification:
        return true; // Can always proceed from verification
      
      case OnboardingStep.completed:
        return false; // Already completed
    }
  }

  /// Get validation message for current step
  String? getValidationMessage() {
    if (canMoveToNextStep()) return null;

    switch (currentStep) {
      case OnboardingStep.personalInfo:
        return 'Vui lòng điền đầy đủ thông tin cá nhân';
      case OnboardingStep.services:
        return 'Vui lòng chọn ít nhất một dịch vụ';
      case OnboardingStep.workingHours:
        return 'Vui lòng thiết lập giờ làm việc';
      case OnboardingStep.location:
        return 'Vui lòng cung cấp thông tin địa điểm';
      case OnboardingStep.pricing:
        return 'Vui lòng đặt giá dịch vụ';
      case OnboardingStep.verification:
      case OnboardingStep.completed:
        return null;
    }
  }

  /// Create a copy with updated fields
  PartnerOnboarding copyWith({
    String? uid,
    OnboardingStep? currentStep,
    Map<OnboardingStep, bool>? completedSteps,
    PartnerModel? partialProfile,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PartnerOnboarding(
      uid: uid ?? this.uid,
      currentStep: currentStep ?? this.currentStep,
      completedSteps: completedSteps ?? this.completedSteps,
      partialProfile: partialProfile ?? this.partialProfile,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        uid,
        currentStep,
        completedSteps,
        partialProfile,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'PartnerOnboarding(uid: $uid, currentStep: $currentStep, completion: ${completionPercentage.toStringAsFixed(1)}%)';
  }
}
