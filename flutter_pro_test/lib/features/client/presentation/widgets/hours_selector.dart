import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Widget for selecting service duration in hours
class HoursSelector extends StatelessWidget {
  final double? selectedHours;
  final double serviceEstimatedDuration;
  final ValueChanged<double> onHoursSelected;

  const HoursSelector({
    super.key,
    required this.selectedHours,
    required this.serviceEstimatedDuration,
    required this.onHoursSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Recommended Duration
        _buildRecommendedDuration(context),
        
        SizedBox(height: 16.h),
        
        // Quick Hour Options
        _buildQuickHourOptions(context),
        
        SizedBox(height: 16.h),
        
        // Custom Hour Slider
        _buildCustomHourSlider(context),
      ],
    );
  }

  Widget _buildRecommendedDuration(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: Theme.of(context).colorScheme.primary,
            size: 16.r,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'Thời gian đề xuất: ${serviceEstimatedDuration.toStringAsFixed(1)} giờ',
              style: TextStyle(
                fontSize: 12.sp,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          if (selectedHours != serviceEstimatedDuration)
            TextButton(
              onPressed: () => onHoursSelected(serviceEstimatedDuration),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                minimumSize: Size.zero,
              ),
              child: Text(
                'Chọn',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickHourOptions(BuildContext context) {
    final quickOptions = _getQuickHourOptions();
    
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: quickOptions.map((hours) => _buildHourChip(context, hours)).toList(),
    );
  }

  Widget _buildHourChip(BuildContext context, double hours) {
    final isSelected = selectedHours == hours;
    final isRecommended = hours == serviceEstimatedDuration;

    return GestureDetector(
      onTap: () => onHoursSelected(hours),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : isRecommended
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : isRecommended
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
                    : Colors.transparent,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${hours.toStringAsFixed(hours == hours.toInt() ? 0 : 1)}h',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : isRecommended
                        ? Theme.of(context).colorScheme.onPrimaryContainer
                        : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            if (isRecommended) ...[
              SizedBox(width: 4.w),
              Icon(
                Icons.star,
                size: 12.r,
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCustomHourSlider(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tùy chỉnh thời gian',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        
        SizedBox(height: 8.h),
        
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '0.5h',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    selectedHours != null
                        ? '${selectedHours!.toStringAsFixed(1)}h'
                        : '--',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Text(
                    '8h',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Theme.of(context).colorScheme.primary,
                  inactiveTrackColor: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                  thumbColor: Theme.of(context).colorScheme.primary,
                  overlayColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  trackHeight: 4.h,
                ),
                child: Slider(
                  value: selectedHours ?? serviceEstimatedDuration,
                  min: 0.5,
                  max: 8.0,
                  divisions: 15, // 0.5 hour increments
                  onChanged: onHoursSelected,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<double> _getQuickHourOptions() {
    final options = <double>[1.0, 2.0, 3.0, 4.0, 6.0, 8.0];
    
    // Add the recommended duration if it's not already in the list
    if (!options.contains(serviceEstimatedDuration)) {
      options.add(serviceEstimatedDuration);
      options.sort();
    }
    
    return options;
  }
}
