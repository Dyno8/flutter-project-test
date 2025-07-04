import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../domain/entities/service.dart';

class ServiceCard extends StatelessWidget {
  final Service service;
  final VoidCallback onTap;

  const ServiceCard({
    super.key,
    required this.service,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service Icon
              Container(
                width: 48.w,
                height: 48.h,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: service.iconUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: service.iconUrl,
                        width: 32.w,
                        height: 32.h,
                        placeholder: (context, url) => Icon(
                          Icons.medical_services,
                          size: 32.r,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        errorWidget: (context, url, error) => Icon(
                          Icons.medical_services,
                          size: 32.r,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      )
                    : Icon(
                        _getServiceIcon(service.category),
                        size: 32.r,
                        color: Theme.of(context).colorScheme.primary,
                      ),
              ),
              SizedBox(height: 12.h),
              
              // Service Name
              Text(
                service.name,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4.h),
              
              // Service Description
              Text(
                service.description,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const Spacer(),
              
              // Price and Duration
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    service.formattedPrice,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      service.formattedDuration,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getServiceIcon(String category) {
    switch (category.toLowerCase()) {
      case 'elder_care':
        return Icons.elderly;
      case 'child_care':
        return Icons.child_care;
      case 'pet_care':
        return Icons.pets;
      case 'housekeeping':
        return Icons.cleaning_services;
      case 'medical':
        return Icons.medical_services;
      case 'nursing':
        return Icons.local_hospital;
      default:
        return Icons.medical_services;
    }
  }
}
