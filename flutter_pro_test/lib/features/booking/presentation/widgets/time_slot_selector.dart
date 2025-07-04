import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../screens/datetime_selection_screen.dart';

class TimeSlotSelector extends StatelessWidget {
  final List<TimeSlotOption> timeSlots;
  final String? selectedTimeSlot;
  final Function(String timeSlot, double hours) onTimeSlotSelected;

  const TimeSlotSelector({
    super.key,
    required this.timeSlots,
    required this.selectedTimeSlot,
    required this.onTimeSlotSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Khung giờ phổ biến',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: timeSlots.map((option) {
            final isSelected = selectedTimeSlot == option.timeSlot;
            return GestureDetector(
              onTap: () => onTimeSlotSelected(option.timeSlot, option.hours),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey[300]!,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      option.timeSlot,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimary
                            : Colors.black87,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '${option.hours.toStringAsFixed(0)} giờ',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimary.withOpacity(0.8)
                            : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
