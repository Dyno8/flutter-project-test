import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../booking/domain/entities/service.dart';

/// Card widget for displaying a service
class ServiceCard extends StatelessWidget {
  final Service service;
  final VoidCallback onTap;

  const ServiceCard({super.key, required this.service, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Service Icon
                  Container(
                    width: 48.w,
                    height: 48.h,
                    decoration: BoxDecoration(
                      color: _getServiceColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      _getServiceIcon(),
                      color: _getServiceColor(),
                      size: 24.r,
                    ),
                  ),
                  SizedBox(width: 12.w),

                  // Service Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.name,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          service.category,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Price
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${service.basePrice.toStringAsFixed(0)}đ',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      Text(
                        '/giờ',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 12.h),

              // Description
              Text(
                service.description,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.8),
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              SizedBox(height: 12.h),

              // Service Features
              Row(
                children: [
                  // Duration
                  _buildFeatureChip(
                    context,
                    Icons.access_time,
                    '${(service.durationMinutes / 60).toStringAsFixed(1)}h',
                  ),
                  SizedBox(width: 8.w),

                  // Service Type
                  _buildFeatureChip(
                    context,
                    Icons.verified,
                    'Đã xác minh',
                    color: Colors.blue,
                  ),
                  SizedBox(width: 8.w),

                  // Availability
                  _buildFeatureChip(
                    context,
                    Icons.check_circle,
                    'Có sẵn',
                    color: Colors.green,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureChip(
    BuildContext context,
    IconData icon,
    String label, {
    Color? color,
  }) {
    final chipColor = color ?? Theme.of(context).colorScheme.primary;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.r, color: chipColor),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: chipColor,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getServiceIcon() {
    switch (service.category.toLowerCase()) {
      case 'elder_care':
      case 'chăm sóc người già':
        return Icons.elderly;
      case 'child_care':
      case 'chăm sóc trẻ em':
        return Icons.child_care;
      case 'pet_care':
      case 'chăm sóc thú cưng':
        return Icons.pets;
      case 'house_cleaning':
      case 'dọn dẹp nhà cửa':
        return Icons.cleaning_services;
      case 'medical_care':
      case 'chăm sóc y tế':
        return Icons.medical_services;
      default:
        return Icons.home_repair_service;
    }
  }

  Color _getServiceColor() {
    switch (service.category.toLowerCase()) {
      case 'elder_care':
      case 'chăm sóc người già':
        return Colors.blue;
      case 'child_care':
      case 'chăm sóc trẻ em':
        return Colors.pink;
      case 'pet_care':
      case 'chăm sóc thú cưng':
        return Colors.orange;
      case 'house_cleaning':
      case 'dọn dẹp nhà cửa':
        return Colors.green;
      case 'medical_care':
      case 'chăm sóc y tế':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
