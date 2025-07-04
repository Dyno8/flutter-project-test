import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../shared/models/booking_model.dart';
import '../../domain/entities/booking.dart' as domain;

/// Mapper class to convert between BookingModel and Booking entity
class BookingMapper {
  /// Convert BookingModel to Booking entity
  static domain.Booking fromModel(BookingModel model) {
    return domain.Booking(
      id: model.id,
      userId: model.userId,
      partnerId: model.partnerId,
      serviceId: model.serviceId,
      serviceName: model.serviceName,
      scheduledDate: model.scheduledDate,
      timeSlot: model.timeSlot,
      hours: model.hours,
      totalPrice: model.totalPrice,
      status: domain.BookingStatus.fromString(model.status),
      paymentStatus: domain.PaymentStatus.fromString(model.paymentStatus),
      paymentMethod: model.paymentMethod,
      paymentTransactionId: model.paymentTransactionId,
      clientAddress: model.clientAddress,
      clientLatitude: model.clientLocation.latitude,
      clientLongitude: model.clientLocation.longitude,
      specialInstructions: model.specialInstructions,
      cancellationReason: model.cancellationReason,
      completedAt: model.completedAt,
      cancelledAt: model.cancelledAt,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  /// Convert Booking entity to BookingModel
  static BookingModel toModel(domain.Booking entity) {
    return BookingModel(
      id: entity.id,
      userId: entity.userId,
      partnerId: entity.partnerId,
      serviceId: entity.serviceId,
      serviceName: entity.serviceName,
      scheduledDate: entity.scheduledDate,
      timeSlot: entity.timeSlot,
      hours: entity.hours,
      totalPrice: entity.totalPrice,
      status: entity.status.toString().split('.').last,
      paymentStatus: entity.paymentStatus.toString().split('.').last,
      paymentMethod: entity.paymentMethod,
      paymentTransactionId: entity.paymentTransactionId,
      clientAddress: entity.clientAddress,
      clientLocation: GeoPoint(entity.clientLatitude, entity.clientLongitude),
      specialInstructions: entity.specialInstructions,
      cancellationReason: entity.cancellationReason,
      completedAt: entity.completedAt,
      cancelledAt: entity.cancelledAt,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
