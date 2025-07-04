import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../shared/models/partner_model.dart';
import '../../../../shared/services/firebase_service.dart';
import '../../../../core/constants/app_constants.dart';

/// Remote data source for partner operations using Firebase
abstract class PartnerRemoteDataSource {
  Future<List<PartnerModel>> getAvailablePartners(
    String serviceId,
    DateTime date,
    String timeSlot, {
    double? clientLatitude,
    double? clientLongitude,
    double maxDistance = 50.0,
  });
  Future<PartnerModel> getPartnerById(String partnerId);
  Future<List<PartnerModel>> getPartnersByService(String serviceId);
  Future<List<PartnerModel>> searchPartners(
    String query, {
    String? serviceId,
    double? clientLatitude,
    double? clientLongitude,
  });
  Future<Map<String, List<String>>> getPartnerAvailability(
    String partnerId,
    DateTime startDate,
    DateTime endDate,
  );
  Stream<List<PartnerModel>> listenToAvailablePartners(
    String serviceId,
    DateTime date,
    String timeSlot,
  );
}

class PartnerRemoteDataSourceImpl implements PartnerRemoteDataSource {
  final FirebaseService _firebaseService;

  PartnerRemoteDataSourceImpl(this._firebaseService);

  @override
  Future<List<PartnerModel>> getAvailablePartners(
    String serviceId,
    DateTime date,
    String timeSlot, {
    double? clientLatitude,
    double? clientLongitude,
    double maxDistance = 50.0,
  }) async {
    try {
      final query = _firebaseService.collection(AppConstants.partnersCollection)
          .where('services', arrayContains: serviceId)
          .where('isAvailable', isEqualTo: true)
          .where('isVerified', isEqualTo: true);

      final snapshot = await query.get();
      var partners = snapshot.docs.map((doc) => PartnerModel.fromFirestore(doc)).toList();

      // Filter by availability (simplified - in production, you'd have more complex scheduling logic)
      final dayOfWeek = _getDayOfWeek(date);
      partners = partners.where((partner) {
        final daySchedule = partner.workingHours[dayOfWeek];
        return daySchedule != null && daySchedule.isNotEmpty;
      }).toList();

      // Filter by distance if client location is provided
      if (clientLatitude != null && clientLongitude != null) {
        partners = partners.where((partner) {
          final distance = _calculateDistance(
            clientLatitude,
            clientLongitude,
            partner.location.latitude,
            partner.location.longitude,
          );
          return distance <= maxDistance;
        }).toList();

        // Sort by distance
        partners.sort((a, b) {
          final distanceA = _calculateDistance(
            clientLatitude,
            clientLongitude,
            a.location.latitude,
            a.location.longitude,
          );
          final distanceB = _calculateDistance(
            clientLatitude,
            clientLongitude,
            b.location.latitude,
            b.location.longitude,
          );
          return distanceA.compareTo(distanceB);
        });
      } else {
        // Sort by rating if no location provided
        partners.sort((a, b) => b.rating.compareTo(a.rating));
      }

      return partners;
    } catch (e) {
      throw Exception('Failed to get available partners: $e');
    }
  }

  @override
  Future<PartnerModel> getPartnerById(String partnerId) async {
    try {
      final doc = await _firebaseService.getDocument(
        AppConstants.partnersCollection,
        partnerId,
      );
      return PartnerModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get partner: $e');
    }
  }

  @override
  Future<List<PartnerModel>> getPartnersByService(String serviceId) async {
    try {
      final query = _firebaseService.collection(AppConstants.partnersCollection)
          .where('services', arrayContains: serviceId)
          .where('isVerified', isEqualTo: true)
          .orderBy('rating', descending: true);

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => PartnerModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get partners by service: $e');
    }
  }

  @override
  Future<List<PartnerModel>> searchPartners(
    String query, {
    String? serviceId,
    double? clientLatitude,
    double? clientLongitude,
  }) async {
    try {
      Query<Map<String, dynamic>> firestoreQuery = _firebaseService.collection(AppConstants.partnersCollection)
          .where('isVerified', isEqualTo: true);

      if (serviceId != null) {
        firestoreQuery = firestoreQuery.where('services', arrayContains: serviceId);
      }

      final snapshot = await firestoreQuery.get();
      var partners = snapshot.docs
          .map((doc) => PartnerModel.fromFirestore(doc))
          .where((partner) =>
              partner.name.toLowerCase().contains(query.toLowerCase()) ||
              partner.bio.toLowerCase().contains(query.toLowerCase()))
          .toList();

      // Sort by distance if location provided, otherwise by rating
      if (clientLatitude != null && clientLongitude != null) {
        partners.sort((a, b) {
          final distanceA = _calculateDistance(
            clientLatitude,
            clientLongitude,
            a.location.latitude,
            a.location.longitude,
          );
          final distanceB = _calculateDistance(
            clientLatitude,
            clientLongitude,
            b.location.latitude,
            b.location.longitude,
          );
          return distanceA.compareTo(distanceB);
        });
      } else {
        partners.sort((a, b) => b.rating.compareTo(a.rating));
      }

      return partners;
    } catch (e) {
      throw Exception('Failed to search partners: $e');
    }
  }

  @override
  Future<Map<String, List<String>>> getPartnerAvailability(
    String partnerId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final partner = await getPartnerById(partnerId);
      
      // In a real app, you'd check against actual bookings and availability
      // For now, return the partner's working hours
      return partner.workingHours;
    } catch (e) {
      throw Exception('Failed to get partner availability: $e');
    }
  }

  @override
  Stream<List<PartnerModel>> listenToAvailablePartners(
    String serviceId,
    DateTime date,
    String timeSlot,
  ) {
    try {
      return _firebaseService.collection(AppConstants.partnersCollection)
          .where('services', arrayContains: serviceId)
          .where('isAvailable', isEqualTo: true)
          .where('isVerified', isEqualTo: true)
          .snapshots()
          .map((snapshot) {
        var partners = snapshot.docs.map((doc) => PartnerModel.fromFirestore(doc)).toList();
        
        // Filter by availability
        final dayOfWeek = _getDayOfWeek(date);
        partners = partners.where((partner) {
          final daySchedule = partner.workingHours[dayOfWeek];
          return daySchedule != null && daySchedule.isNotEmpty;
        }).toList();

        return partners;
      });
    } catch (e) {
      throw Exception('Failed to listen to available partners: $e');
    }
  }

  // Helper methods
  String _getDayOfWeek(DateTime date) {
    const days = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'];
    return days[date.weekday % 7];
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    // Simplified distance calculation - in production, use a proper geolocation library
    final latDiff = (lat1 - lat2).abs();
    final lonDiff = (lon1 - lon2).abs();
    return (latDiff + lonDiff) * 111; // Rough km conversion
  }
}
