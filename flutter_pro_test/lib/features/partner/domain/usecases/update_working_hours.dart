import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/partner_repository.dart';

/// Use case for updating partner working hours
class UpdateWorkingHours implements UseCase<void, UpdateWorkingHoursParams> {
  final PartnerRepository repository;

  const UpdateWorkingHours(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateWorkingHoursParams params) async {
    // Validate partner ID
    if (params.uid.trim().isEmpty) {
      return const Left(ValidationFailure('Partner ID cannot be empty'));
    }

    // Validate working hours
    if (params.workingHours.isEmpty) {
      return const Left(ValidationFailure('Working hours cannot be empty'));
    }

    // Validate each day's working hours
    for (final entry in params.workingHours.entries) {
      final day = entry.key.toLowerCase();
      final hours = entry.value;

      // Validate day name
      if (!_isValidDay(day)) {
        return Left(ValidationFailure('Invalid day: $day'));
      }

      // Allow empty hours for days off
      if (hours.isEmpty) {
        continue;
      }

      // Validate number of time slots
      if (hours.length > 12) {
        return Left(ValidationFailure('Too many time slots for $day (max 12)'));
      }

      // Validate each time slot
      for (final timeSlot in hours) {
        if (!_isValidTimeSlot(timeSlot)) {
          return Left(ValidationFailure('Invalid time slot format: $timeSlot'));
        }
      }

      // Check for overlapping time slots
      if (_hasOverlappingSlots(hours)) {
        return Left(ValidationFailure('Overlapping time slots found for $day'));
      }

      // Validate total working hours per day (max 12 hours)
      final totalHours = _calculateTotalHours(hours);
      if (totalHours > 12) {
        return Left(ValidationFailure('Total working hours for $day cannot exceed 12 hours'));
      }
    }

    // Validate total working days (at least 1 day)
    final workingDays = params.workingHours.values.where((hours) => hours.isNotEmpty).length;
    if (workingDays == 0) {
      return const Left(ValidationFailure('Partner must work at least one day per week'));
    }

    return await repository.updateWorkingHours(params.uid, params.workingHours);
  }

  bool _isValidDay(String day) {
    const validDays = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    return validDays.contains(day.toLowerCase());
  }

  bool _isValidTimeSlot(String timeSlot) {
    // Validate time slot format like "08:00-09:00" or "14:00-16:00"
    final regex = RegExp(r'^([0-1]?[0-9]|2[0-3]):([0-5][0-9])-([0-1]?[0-9]|2[0-3]):([0-5][0-9])$');
    final match = regex.firstMatch(timeSlot);
    
    if (match == null) return false;

    // Parse start and end times
    final startHour = int.parse(match.group(1)!);
    final startMinute = int.parse(match.group(2)!);
    final endHour = int.parse(match.group(3)!);
    final endMinute = int.parse(match.group(4)!);

    // Create DateTime objects for comparison
    final startTime = DateTime(2023, 1, 1, startHour, startMinute);
    final endTime = DateTime(2023, 1, 1, endHour, endMinute);

    // End time must be after start time
    if (!endTime.isAfter(startTime)) {
      return false;
    }

    // Minimum slot duration is 30 minutes
    final duration = endTime.difference(startTime);
    if (duration.inMinutes < 30) {
      return false;
    }

    // Maximum slot duration is 4 hours
    if (duration.inHours > 4) {
      return false;
    }

    return true;
  }

  bool _hasOverlappingSlots(List<String> timeSlots) {
    if (timeSlots.length <= 1) return false;

    // Parse all time slots
    final slots = timeSlots.map((slot) {
      final parts = slot.split('-');
      final start = _parseTime(parts[0]);
      final end = _parseTime(parts[1]);
      return {'start': start, 'end': end};
    }).toList();

    // Sort by start time
    slots.sort((a, b) => a['start']!.compareTo(b['start']!));

    // Check for overlaps
    for (int i = 0; i < slots.length - 1; i++) {
      if (slots[i]['end']!.isAfter(slots[i + 1]['start']!)) {
        return true;
      }
    }

    return false;
  }

  DateTime _parseTime(String time) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return DateTime(2023, 1, 1, hour, minute);
  }

  double _calculateTotalHours(List<String> timeSlots) {
    double totalMinutes = 0;

    for (final slot in timeSlots) {
      final parts = slot.split('-');
      final start = _parseTime(parts[0]);
      final end = _parseTime(parts[1]);
      totalMinutes += end.difference(start).inMinutes;
    }

    return totalMinutes / 60;
  }
}

/// Parameters for update working hours use case
class UpdateWorkingHoursParams extends Equatable {
  final String uid;
  final Map<String, List<String>> workingHours;

  const UpdateWorkingHoursParams({
    required this.uid,
    required this.workingHours,
  });

  @override
  List<Object> get props => [uid, workingHours];
}
