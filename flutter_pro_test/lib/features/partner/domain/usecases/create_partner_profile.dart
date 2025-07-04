import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../shared/models/partner_model.dart';
import '../repositories/partner_repository.dart';

/// Use case for creating partner profile
class CreatePartnerProfile implements UseCase<PartnerModel, CreatePartnerProfileParams> {
  final PartnerRepository repository;

  const CreatePartnerProfile(this.repository);

  @override
  Future<Either<Failure, PartnerModel>> call(CreatePartnerProfileParams params) async {
    // Validate required fields
    if (params.partner.uid.trim().isEmpty) {
      return const Left(ValidationFailure('Partner ID cannot be empty'));
    }

    if (params.partner.name.trim().isEmpty) {
      return const Left(ValidationFailure('Partner name cannot be empty'));
    }

    if (params.partner.email.trim().isEmpty) {
      return const Left(ValidationFailure('Email cannot be empty'));
    }

    if (params.partner.phone.trim().isEmpty) {
      return const Left(ValidationFailure('Phone number cannot be empty'));
    }

    // Validate email format
    if (!_isValidEmail(params.partner.email)) {
      return const Left(ValidationFailure('Invalid email format'));
    }

    // Validate phone number
    if (!_isValidVietnamesePhone(params.partner.phone)) {
      return const Left(ValidationFailure('Invalid Vietnamese phone number format'));
    }

    // Validate name length
    if (params.partner.name.trim().length < 2) {
      return const Left(ValidationFailure('Partner name must be at least 2 characters'));
    }

    // Validate price per hour
    if (params.partner.pricePerHour < 0) {
      return const Left(ValidationFailure('Price per hour cannot be negative'));
    }

    if (params.partner.pricePerHour > 1000000) {
      return const Left(ValidationFailure('Price per hour cannot exceed 1,000,000 VND'));
    }

    // Validate experience years
    if (params.partner.experienceYears < 0) {
      return const Left(ValidationFailure('Experience years cannot be negative'));
    }

    if (params.partner.experienceYears > 50) {
      return const Left(ValidationFailure('Experience years cannot exceed 50'));
    }

    // Validate bio length if provided
    if (params.partner.bio != null && params.partner.bio!.length > 500) {
      return const Left(ValidationFailure('Bio cannot exceed 500 characters'));
    }

    // Validate services list
    if (params.partner.services.isEmpty) {
      return const Left(ValidationFailure('Partner must provide at least one service'));
    }

    if (params.partner.services.length > 10) {
      return const Left(ValidationFailure('Partner cannot provide more than 10 services'));
    }

    // Validate working hours
    if (params.partner.workingHours.isEmpty) {
      return const Left(ValidationFailure('Partner must set working hours for at least one day'));
    }

    // Validate each day's working hours
    for (final entry in params.partner.workingHours.entries) {
      final day = entry.key.toLowerCase();
      final hours = entry.value;

      if (!_isValidDay(day)) {
        return Left(ValidationFailure('Invalid day: $day'));
      }

      if (hours.isEmpty) {
        continue; // Allow empty hours for days off
      }

      if (hours.length > 12) {
        return Left(ValidationFailure('Too many time slots for $day (max 12)'));
      }

      // Validate time slot format
      for (final timeSlot in hours) {
        if (!_isValidTimeSlot(timeSlot)) {
          return Left(ValidationFailure('Invalid time slot format: $timeSlot'));
        }
      }
    }

    return await repository.createPartner(params.partner);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidVietnamesePhone(String phone) {
    return RegExp(r'^(\+84|84|0)(3|5|7|8|9)([0-9]{8})$').hasMatch(phone);
  }

  bool _isValidDay(String day) {
    const validDays = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    return validDays.contains(day.toLowerCase());
  }

  bool _isValidTimeSlot(String timeSlot) {
    // Validate time slot format like "08:00-09:00" or "14:00-16:00"
    return RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]-([0-1]?[0-9]|2[0-3]):[0-5][0-9]$').hasMatch(timeSlot);
  }
}

/// Parameters for create partner profile use case
class CreatePartnerProfileParams extends Equatable {
  final PartnerModel partner;

  const CreatePartnerProfileParams({required this.partner});

  @override
  List<Object> get props => [partner];
}
