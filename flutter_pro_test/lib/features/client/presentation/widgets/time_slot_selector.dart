import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Widget for selecting time slots
class TimeSlotSelector extends StatelessWidget {
  final String? selectedTimeSlot;
  final ValueChanged<String> onTimeSlotSelected;

  const TimeSlotSelector({
    super.key,
    required this.selectedTimeSlot,
    required this.onTimeSlotSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Morning Slots
        _buildTimeSlotSection(
          context,
          'Buổi sáng',
          _morningSlots,
          Icons.wb_sunny,
          Colors.orange,
        ),
        
        SizedBox(height: 16.h),
        
        // Afternoon Slots
        _buildTimeSlotSection(
          context,
          'Buổi chiều',
          _afternoonSlots,
          Icons.wb_sunny_outlined,
          Colors.amber,
        ),
        
        SizedBox(height: 16.h),
        
        // Evening Slots
        _buildTimeSlotSection(
          context,
          'Buổi tối',
          _eveningSlots,
          Icons.nights_stay,
          Colors.indigo,
        ),
      ],
    );
  }

  Widget _buildTimeSlotSection(
    BuildContext context,
    String title,
    List<TimeSlot> slots,
    IconData icon,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 16.r,
            ),
            SizedBox(width: 8.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        
        SizedBox(height: 8.h),
        
        // Time Slots Grid
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: slots.map((slot) => _buildTimeSlotChip(context, slot)).toList(),
        ),
      ],
    );
  }

  Widget _buildTimeSlotChip(BuildContext context, TimeSlot slot) {
    final isSelected = selectedTimeSlot == slot.value;
    final isAvailable = slot.isAvailable;

    return GestureDetector(
      onTap: isAvailable ? () => onTimeSlotSelected(slot.value) : null,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : isAvailable
                  ? Theme.of(context).colorScheme.surfaceVariant
                  : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : isAvailable
                    ? Colors.transparent
                    : Theme.of(context).colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          slot.label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimary
                : isAvailable
                    ? Theme.of(context).colorScheme.onSurfaceVariant
                    : Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
        ),
      ),
    );
  }

  // Predefined time slots
  static final List<TimeSlot> _morningSlots = [
    TimeSlot('06:00-08:00', '6:00 - 8:00', true),
    TimeSlot('08:00-10:00', '8:00 - 10:00', true),
    TimeSlot('10:00-12:00', '10:00 - 12:00', true),
  ];

  static final List<TimeSlot> _afternoonSlots = [
    TimeSlot('12:00-14:00', '12:00 - 14:00', true),
    TimeSlot('14:00-16:00', '14:00 - 16:00', true),
    TimeSlot('16:00-18:00', '16:00 - 18:00', true),
  ];

  static final List<TimeSlot> _eveningSlots = [
    TimeSlot('18:00-20:00', '18:00 - 20:00', true),
    TimeSlot('20:00-22:00', '20:00 - 22:00', true),
    TimeSlot('22:00-24:00', '22:00 - 24:00', false), // Not available by default
  ];
}

/// Time slot data class
class TimeSlot {
  final String value;
  final String label;
  final bool isAvailable;

  const TimeSlot(this.value, this.label, this.isAvailable);
}
