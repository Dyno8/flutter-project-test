import '../../../../shared/models/service_model.dart';
import '../../domain/entities/service.dart';

/// Mapper class to convert between ServiceModel and Service entity
class ServiceMapper {
  /// Convert ServiceModel to Service entity
  static Service fromModel(ServiceModel model) {
    return Service(
      id: model.id,
      name: model.name,
      description: model.description,
      category: model.category,
      iconUrl: model.iconUrl,
      basePrice: model.basePrice,
      durationMinutes: model.durationMinutes,
      requirements: model.requirements,
      benefits: model.benefits,
      isActive: model.isActive,
      sortOrder: model.sortOrder,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  /// Convert Service entity to ServiceModel
  static ServiceModel toModel(Service entity) {
    return ServiceModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      category: entity.category,
      iconUrl: entity.iconUrl,
      basePrice: entity.basePrice,
      durationMinutes: entity.durationMinutes,
      requirements: entity.requirements,
      benefits: entity.benefits,
      isActive: entity.isActive,
      sortOrder: entity.sortOrder,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
