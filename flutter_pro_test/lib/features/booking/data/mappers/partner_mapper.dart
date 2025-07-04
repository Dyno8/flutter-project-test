import '../../../../shared/models/partner_model.dart';
import '../../domain/entities/partner.dart';

/// Mapper class to convert between PartnerModel and Partner entity
class PartnerMapper {
  /// Convert PartnerModel to Partner entity
  static Partner fromModel(PartnerModel model) {
    return Partner(
      uid: model.uid,
      name: model.name,
      phone: model.phone,
      email: model.email,
      gender: model.gender,
      services: model.services,
      workingHours: model.workingHours,
      rating: model.rating,
      totalReviews: model.totalReviews,
      latitude: model.location.latitude,
      longitude: model.location.longitude,
      address: model.address,
      bio: model.bio,
      profileImageUrl: model.profileImageUrl,
      certifications: model.certifications,
      experienceYears: model.experienceYears,
      pricePerHour: model.pricePerHour,
      isAvailable: model.isAvailable,
      isVerified: model.isVerified,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      fcmToken: model.fcmToken,
    );
  }

  /// Convert Partner entity to PartnerModel
  static PartnerModel toModel(Partner entity) {
    return PartnerModel(
      uid: entity.uid,
      name: entity.name,
      phone: entity.phone,
      email: entity.email,
      gender: entity.gender,
      services: entity.services,
      workingHours: entity.workingHours,
      rating: entity.rating,
      totalReviews: entity.totalReviews,
      location: GeoPoint(entity.latitude, entity.longitude),
      address: entity.address,
      bio: entity.bio,
      profileImageUrl: entity.profileImageUrl,
      certifications: entity.certifications,
      experienceYears: entity.experienceYears,
      pricePerHour: entity.pricePerHour,
      isAvailable: entity.isAvailable,
      isVerified: entity.isVerified,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      fcmToken: entity.fcmToken,
    );
  }
}
