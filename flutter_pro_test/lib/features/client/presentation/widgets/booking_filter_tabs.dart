import 'package:flutter/material.dart';
import '../../../booking/domain/entities/booking.dart';

/// Data class for booking filter tabs
class BookingFilterTab {
  final String label;
  final BookingStatus? status;
  final IconData icon;

  const BookingFilterTab({
    required this.label,
    required this.status,
    required this.icon,
  });
}
