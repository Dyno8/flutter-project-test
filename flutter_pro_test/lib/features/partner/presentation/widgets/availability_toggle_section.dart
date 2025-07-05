import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/partner_earnings.dart';

/// Availability toggle section widget
class AvailabilityToggleSection extends StatelessWidget {
  final PartnerAvailability availability;
  final Function(bool isAvailable, String? reason) onToggle;
  final Function(Map<String, List<String>> workingHours) onUpdateWorkingHours;

  const AvailabilityToggleSection({
    super.key,
    required this.availability,
    required this.onToggle,
    required this.onUpdateWorkingHours,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Availability',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              TextButton.icon(
                onPressed: () => _showWorkingHoursDialog(context),
                icon: const Icon(Icons.schedule, size: 16),
                label: const Text('Hours'),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                // Main availability toggle
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: availability.isCurrentlyAvailable
                            ? Colors.green.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        availability.isCurrentlyAvailable
                            ? Icons.check_circle
                            : Icons.pause_circle,
                        color: availability.isCurrentlyAvailable
                            ? Colors.green
                            : Colors.grey,
                        size: 24.w,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            availability.isCurrentlyAvailable
                                ? 'Available for Jobs'
                                : 'Currently Unavailable',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          if (!availability.isCurrentlyAvailable &&
                              availability.unavailabilityReason != null)
                            Text(
                              availability.unavailabilityReason!,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          Text(
                            availability.lastSeenText,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: availability.isAvailable,
                      onChanged: (value) {
                        if (value) {
                          onToggle(true, null);
                        } else {
                          _showUnavailabilityDialog(context);
                        }
                      },
                      activeColor: Colors.green,
                    ),
                  ],
                ),

                // Temporary unavailability info
                if (availability.unavailableUntil != null) ...[
                  SizedBox(height: 16.h),
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 16.w,
                          color: Colors.orange,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            'Unavailable until ${_formatDateTime(availability.unavailableUntil!)}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Clear temporary unavailability
                            onToggle(true, null);
                          },
                          child: Text(
                            'Clear',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Quick availability actions
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showQuickUnavailabilityOptions(context),
                        icon: const Icon(Icons.pause, size: 16),
                        label: const Text('Quick Break'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange,
                          side: const BorderSide(color: Colors.orange),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showWorkingHoursDialog(context),
                        icon: const Icon(Icons.schedule, size: 16),
                        label: const Text('Set Hours'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showUnavailabilityDialog(BuildContext context) {
    final reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Unavailable'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for being unavailable:'),
            SizedBox(height: 16.h),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'e.g., Taking a break, Personal time',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onToggle(false, reasonController.text.trim());
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showQuickUnavailabilityOptions(BuildContext context) {
    final options = [
      {'title': '15 minutes', 'minutes': 15},
      {'title': '30 minutes', 'minutes': 30},
      {'title': '1 hour', 'minutes': 60},
      {'title': '2 hours', 'minutes': 120},
      {'title': 'Custom', 'minutes': -1},
    ];

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Break',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            ...options.map((option) => ListTile(
              title: Text(option['title'] as String),
              onTap: () {
                Navigator.pop(context);
                if (option['minutes'] == -1) {
                  _showCustomUnavailabilityDialog(context);
                } else {
                  final unavailableUntil = DateTime.now().add(
                    Duration(minutes: option['minutes'] as int),
                  );
                  // Set temporary unavailability
                  onToggle(false, 'Taking a ${option['title']} break');
                }
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showCustomUnavailabilityDialog(BuildContext context) {
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();
    final reasonController = TextEditingController(text: 'Custom break');

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Custom Unavailability'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.h),
              ListTile(
                title: const Text('Date'),
                subtitle: Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  if (date != null) {
                    setState(() => selectedDate = date);
                  }
                },
              ),
              ListTile(
                title: const Text('Time'),
                subtitle: Text(selectedTime.format(context)),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: selectedTime,
                  );
                  if (time != null) {
                    setState(() => selectedTime = time);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                final unavailableUntil = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  selectedTime.hour,
                  selectedTime.minute,
                );
                onToggle(false, reasonController.text.trim());
              },
              child: const Text('Set'),
            ),
          ],
        ),
      ),
    );
  }

  void _showWorkingHoursDialog(BuildContext context) {
    final workingHours = Map<String, List<String>>.from(availability.workingHours);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Working Hours'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Set your working hours for each day:'),
              SizedBox(height: 16.h),
              // Working hours editor would go here
              // This is a simplified version
              const Text('Working hours editor coming soon...'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onUpdateWorkingHours(workingHours);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
