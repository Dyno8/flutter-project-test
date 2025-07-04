import 'package:equatable/equatable.dart';

/// Domain entity for service
class Service extends Equatable {
  final String id;
  final String name;
  final String description;
  final String category;
  final String iconUrl;
  final double basePrice;
  final int durationMinutes;
  final List<String> requirements;
  final List<String> benefits;
  final bool isActive;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Service({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.iconUrl,
    required this.basePrice,
    required this.durationMinutes,
    required this.requirements,
    required this.benefits,
    required this.isActive,
    required this.sortOrder,
    required this.createdAt,
    this.updatedAt,
  });

  // Helper methods
  String get formattedPrice => '${basePrice.toStringAsFixed(0)}k VND/giờ';
  String get formattedDuration => '$durationMinutes phút';

  // Calculate total price for given hours
  double calculatePrice(double hours) {
    return basePrice * hours;
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        category,
        iconUrl,
        basePrice,
        durationMinutes,
        requirements,
        benefits,
        isActive,
        sortOrder,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'Service(id: $id, name: $name, category: $category, basePrice: $basePrice)';
  }
}
