import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ServiceModel extends Equatable {
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

  const ServiceModel({
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

  // Factory constructor from Firestore document
  factory ServiceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ServiceModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      iconUrl: data['iconUrl'] ?? '',
      basePrice: (data['basePrice'] ?? 0.0).toDouble(),
      durationMinutes: data['durationMinutes'] ?? 60,
      requirements: List<String>.from(data['requirements'] ?? []),
      benefits: List<String>.from(data['benefits'] ?? []),
      isActive: data['isActive'] ?? true,
      sortOrder: data['sortOrder'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  // Factory constructor from Map
  factory ServiceModel.fromMap(Map<String, dynamic> map) {
    return ServiceModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      iconUrl: map['iconUrl'] ?? '',
      basePrice: (map['basePrice'] ?? 0.0).toDouble(),
      durationMinutes: map['durationMinutes'] ?? 60,
      requirements: List<String>.from(map['requirements'] ?? []),
      benefits: List<String>.from(map['benefits'] ?? []),
      isActive: map['isActive'] ?? true,
      sortOrder: map['sortOrder'] ?? 0,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] is Timestamp
                ? (map['updatedAt'] as Timestamp).toDate()
                : DateTime.parse(map['updatedAt']))
          : null,
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'iconUrl': iconUrl,
      'basePrice': basePrice,
      'durationMinutes': durationMinutes,
      'requirements': requirements,
      'benefits': benefits,
      'isActive': isActive,
      'sortOrder': sortOrder,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  // Convert to JSON for API calls
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'iconUrl': iconUrl,
      'basePrice': basePrice,
      'durationMinutes': durationMinutes,
      'requirements': requirements,
      'benefits': benefits,
      'isActive': isActive,
      'sortOrder': sortOrder,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Create copy with updated fields
  ServiceModel copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? iconUrl,
    double? basePrice,
    int? durationMinutes,
    List<String>? requirements,
    List<String>? benefits,
    bool? isActive,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      iconUrl: iconUrl ?? this.iconUrl,
      basePrice: basePrice ?? this.basePrice,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      requirements: requirements ?? this.requirements,
      benefits: benefits ?? this.benefits,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
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
    return 'ServiceModel(id: $id, name: $name, category: $category, basePrice: $basePrice)';
  }

  // Helper methods
  String get formattedPrice => '${basePrice.toStringAsFixed(0)}k VND/giờ';
  String get formattedDuration => '$durationMinutes phút';

  // Calculate total price for given hours
  double calculatePrice(double hours) {
    return basePrice * hours;
  }

  // Get formatted total price
  String getFormattedTotalPrice(double hours) {
    final total = calculatePrice(hours);
    return '${total.toStringAsFixed(0)}k VND';
  }
}

// Predefined service categories
class ServiceCategory {
  static const String elderCare = 'elder_care';
  static const String petCare = 'pet_care';
  static const String childCare = 'child_care';
  static const String housekeeping = 'housekeeping';

  static const Map<String, String> categoryNames = {
    elderCare: 'Chăm sóc người cao tuổi',
    petCare: 'Chăm sóc thú cưng',
    childCare: 'Chăm sóc trẻ em',
    housekeeping: 'Dọn dẹp nhà cửa',
  };

  static String getCategoryName(String category) {
    return categoryNames[category] ?? category;
  }

  static List<String> getAllCategories() {
    return categoryNames.keys.toList();
  }
}
