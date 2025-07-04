class ValidationService {
  // Singleton pattern
  static final ValidationService _instance = ValidationService._internal();
  factory ValidationService() => _instance;
  ValidationService._internal();

  // Email validation
  bool isValidEmail(String email) {
    if (email.isEmpty) return false;
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email.trim());
  }

  // Vietnamese phone number validation
  bool isValidPhone(String phone) {
    if (phone.isEmpty) return false;
    final cleanPhone = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    return RegExp(r'^(\+84|84|0)(3|5|7|8|9)([0-9]{8})$').hasMatch(cleanPhone);
  }

  // Name validation
  bool isValidName(String name) {
    if (name.isEmpty) return false;
    final trimmedName = name.trim();
    return trimmedName.length >= 2 && 
           trimmedName.length <= 50 && 
           RegExp(r'^[a-zA-ZÀ-ỹ\s]+$').hasMatch(trimmedName);
  }

  // Password validation
  bool isValidPassword(String password) {
    if (password.isEmpty) return false;
    return password.length >= 6 && password.length <= 50;
  }

  // Address validation
  bool isValidAddress(String address) {
    if (address.isEmpty) return false;
    return address.trim().length >= 10 && address.trim().length <= 200;
  }

  // Price validation (in thousands VND)
  bool isValidPrice(double price) {
    return price > 0 && price <= 10000;
  }

  // Hours validation for booking
  bool isValidHours(double hours) {
    return hours >= 0.5 && hours <= 12.0;
  }

  // Rating validation
  bool isValidRating(double rating) {
    return rating >= 0.0 && rating <= 5.0;
  }

  // Experience years validation
  bool isValidExperienceYears(int years) {
    return years >= 0 && years <= 50;
  }

  // Gender validation
  bool isValidGender(String gender) {
    const validGenders = ['male', 'female', 'other'];
    return validGenders.contains(gender.toLowerCase());
  }

  // Service category validation
  bool isValidServiceCategory(String category) {
    const validCategories = [
      'elder_care',
      'pet_care', 
      'child_care',
      'housekeeping'
    ];
    return validCategories.contains(category);
  }

  // Booking status validation
  bool isValidBookingStatus(String status) {
    const validStatuses = [
      'pending',
      'confirmed',
      'in-progress',
      'completed',
      'cancelled'
    ];
    return validStatuses.contains(status);
  }

  // Payment status validation
  bool isValidPaymentStatus(String status) {
    const validStatuses = ['paid', 'unpaid'];
    return validStatuses.contains(status);
  }

  // Time slot validation (HH:MM format)
  bool isValidTimeSlot(String timeSlot) {
    if (timeSlot.isEmpty) return false;
    final regex = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');
    return regex.hasMatch(timeSlot);
  }

  // Date validation (not in the past)
  bool isValidFutureDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final inputDate = DateTime(date.year, date.month, date.day);
    return inputDate.isAfter(today) || inputDate.isAtSameMomentAs(today);
  }

  // Booking time validation (at least 2 hours in advance)
  bool isValidBookingTime(DateTime date, String timeSlot) {
    if (!isValidTimeSlot(timeSlot)) return false;
    
    final timeParts = timeSlot.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    
    final bookingDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      hour,
      minute,
    );
    
    final now = DateTime.now();
    return bookingDateTime.difference(now).inHours >= 2;
  }

  // Working hours validation
  bool isValidWorkingHours(Map<String, List<String>> workingHours) {
    const validDays = [
      'monday', 'tuesday', 'wednesday', 'thursday', 
      'friday', 'saturday', 'sunday'
    ];
    
    for (final day in workingHours.keys) {
      if (!validDays.contains(day.toLowerCase())) {
        return false;
      }
      
      for (final timeSlot in workingHours[day]!) {
        if (!isValidTimeSlot(timeSlot)) {
          return false;
        }
      }
    }
    
    return true;
  }

  // URL validation
  bool isValidUrl(String url) {
    if (url.isEmpty) return true; // Optional field
    return RegExp(r'^https?:\/\/.+').hasMatch(url);
  }

  // Comment validation
  bool isValidComment(String comment) {
    if (comment.isEmpty) return false;
    return comment.trim().length >= 5 && comment.trim().length <= 500;
  }

  // List validation helpers
  bool isValidStringList(List<String> list, {int maxLength = 10}) {
    if (list.isEmpty) return false;
    if (list.length > maxLength) return false;
    return list.every((item) => item.trim().isNotEmpty);
  }

  // Sanitization methods
  String sanitizeString(String input) {
    return input.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  String sanitizePhone(String phone) {
    return phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
  }

  String sanitizeEmail(String email) {
    return email.trim().toLowerCase();
  }

  List<String> sanitizeStringList(List<String> list) {
    return list
        .map((item) => sanitizeString(item))
        .where((item) => item.isNotEmpty)
        .toList();
  }

  // Validation result class
  ValidationResult validateUser({
    required String name,
    required String email,
    required String phone,
    required String address,
    String? password,
  }) {
    final errors = <String>[];

    if (!isValidName(name)) {
      errors.add('Tên không hợp lệ (2-50 ký tự, chỉ chữ cái)');
    }

    if (!isValidEmail(email)) {
      errors.add('Email không hợp lệ');
    }

    if (!isValidPhone(phone)) {
      errors.add('Số điện thoại không hợp lệ');
    }

    if (!isValidAddress(address)) {
      errors.add('Địa chỉ không hợp lệ (10-200 ký tự)');
    }

    if (password != null && !isValidPassword(password)) {
      errors.add('Mật khẩu phải có ít nhất 6 ký tự');
    }

    return ValidationResult(isValid: errors.isEmpty, errors: errors);
  }

  ValidationResult validateBooking({
    required DateTime scheduledDate,
    required String timeSlot,
    required double hours,
    required double totalPrice,
    required String clientAddress,
  }) {
    final errors = <String>[];

    if (!isValidFutureDate(scheduledDate)) {
      errors.add('Ngày đặt lịch phải là ngày hiện tại hoặc tương lai');
    }

    if (!isValidBookingTime(scheduledDate, timeSlot)) {
      errors.add('Thời gian đặt lịch phải trước ít nhất 2 giờ');
    }

    if (!isValidHours(hours)) {
      errors.add('Số giờ không hợp lệ (0.5-12 giờ)');
    }

    if (!isValidPrice(totalPrice)) {
      errors.add('Giá không hợp lệ');
    }

    if (!isValidAddress(clientAddress)) {
      errors.add('Địa chỉ khách hàng không hợp lệ');
    }

    return ValidationResult(isValid: errors.isEmpty, errors: errors);
  }

  ValidationResult validateReview({
    required double rating,
    required String comment,
    required List<String> tags,
  }) {
    final errors = <String>[];

    if (!isValidRating(rating)) {
      errors.add('Đánh giá phải từ 0-5 sao');
    }

    if (!isValidComment(comment)) {
      errors.add('Bình luận phải có 5-500 ký tự');
    }

    if (!isValidStringList(tags, maxLength: 5)) {
      errors.add('Tags không hợp lệ (tối đa 5 tags)');
    }

    return ValidationResult(isValid: errors.isEmpty, errors: errors);
  }
}

class ValidationResult {
  final bool isValid;
  final List<String> errors;

  const ValidationResult({
    required this.isValid,
    required this.errors,
  });

  String get errorMessage => errors.join('\n');
  String get firstError => errors.isNotEmpty ? errors.first : '';
}
