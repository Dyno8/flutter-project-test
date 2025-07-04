import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/partner_model.dart';
import '../services/firebase_service.dart';
import 'base_repository.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/failures.dart';

class PartnerRepository extends BaseRepository<PartnerModel> {
  @override
  String get collectionName => AppConstants.partnersCollection;

  @override
  PartnerModel fromFirestore(DocumentSnapshot doc) {
    return PartnerModel.fromFirestore(doc);
  }

  @override
  Map<String, dynamic> toMap(PartnerModel model) {
    return model.toMap();
  }

  // Partner-specific methods
  Future<Either<Failure, PartnerModel>> createPartner(PartnerModel partner) async {
    try {
      // Use the partner's UID as the document ID
      await FirebaseService().setDocument(
        collectionName,
        partner.uid,
        partner.toMap(),
      );
      
      final doc = await FirebaseService().getDocument(collectionName, partner.uid);
      final createdPartner = fromFirestore(doc);
      return Right(createdPartner);
    } catch (e) {
      return Left(ServerFailure('Failed to create partner: $e'));
    }
  }

  Future<Either<Failure, PartnerModel>> updatePartner(PartnerModel partner) async {
    try {
      final updateData = partner.copyWith(updatedAt: DateTime.now()).toMap();
      await FirebaseService().setDocument(
        collectionName,
        partner.uid,
        updateData,
        merge: true,
      );
      
      final doc = await FirebaseService().getDocument(collectionName, partner.uid);
      final updatedPartner = fromFirestore(doc);
      return Right(updatedPartner);
    } catch (e) {
      return Left(ServerFailure('Failed to update partner: $e'));
    }
  }

  Future<Either<Failure, List<PartnerModel>>> getAvailablePartners({
    List<String>? services,
    GeoPoint? location,
    double? radiusKm,
    double? minRating,
    int limit = 20,
  }) async {
    try {
      Query<Map<String, dynamic>> query = FirebaseService()
          .firestore
          .collection(collectionName);

      // Filter by availability
      query = query.where('isAvailable', isEqualTo: true);

      // Filter by services if provided
      if (services != null && services.isNotEmpty) {
        query = query.where('services', arrayContainsAny: services);
      }

      // Filter by minimum rating if provided
      if (minRating != null) {
        query = query.where('rating', isGreaterThanOrEqualTo: minRating);
      }

      // Order by rating (descending) and limit results
      query = query.orderBy('rating', descending: true).limit(limit);

      final snapshot = await query.get();
      List<PartnerModel> partners = snapshot.docs
          .map((doc) => fromFirestore(doc))
          .toList();

      // Filter by location if provided (client-side filtering for geo queries)
      if (location != null && radiusKm != null) {
        partners = partners.where((partner) {
          final distance = _calculateDistance(
            location.latitude,
            location.longitude,
            partner.location.latitude,
            partner.location.longitude,
          );
          return distance <= radiusKm;
        }).toList();
      }

      return Right(partners);
    } catch (e) {
      return Left(ServerFailure('Failed to get available partners: $e'));
    }
  }

  Future<Either<Failure, List<PartnerModel>>> getPartnersByService(
    String serviceType, {
    int limit = 20,
  }) async {
    try {
      final query = where('services', serviceType)
          .where('isAvailable', true)
          .orderBy('rating', descending: true)
          .limit(limit);

      final snapshot = await query.get();
      final partners = snapshot.docs.map((doc) => fromFirestore(doc)).toList();
      return Right(partners);
    } catch (e) {
      return Left(ServerFailure('Failed to get partners by service: $e'));
    }
  }

  Future<Either<Failure, List<PartnerModel>>> getTopRatedPartners({
    int limit = 10,
  }) async {
    try {
      final query = where('isVerified', true)
          .orderBy('rating', descending: true)
          .orderBy('totalReviews', descending: true)
          .limit(limit);

      final snapshot = await query.get();
      final partners = snapshot.docs.map((doc) => fromFirestore(doc)).toList();
      return Right(partners);
    } catch (e) {
      return Left(ServerFailure('Failed to get top rated partners: $e'));
    }
  }

  Future<Either<Failure, void>> updatePartnerAvailability(
    String partnerId,
    bool isAvailable,
  ) async {
    try {
      await FirebaseService().updateDocument(collectionName, partnerId, {
        'isAvailable': isAvailable,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to update partner availability: $e'));
    }
  }

  Future<Either<Failure, void>> updatePartnerRating(
    String partnerId,
    double newRating,
    int newTotalReviews,
  ) async {
    try {
      await FirebaseService().updateDocument(collectionName, partnerId, {
        'rating': newRating,
        'totalReviews': newTotalReviews,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to update partner rating: $e'));
    }
  }

  Future<Either<Failure, void>> updatePartnerLocation(
    String partnerId,
    GeoPoint location,
    String address,
  ) async {
    try {
      await FirebaseService().updateDocument(collectionName, partnerId, {
        'location': location,
        'address': address,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to update partner location: $e'));
    }
  }

  Future<Either<Failure, List<PartnerModel>>> searchPartners(
    String searchTerm, {
    List<String>? services,
    double? minRating,
    int limit = 20,
  }) async {
    try {
      Query<Map<String, dynamic>> query = FirebaseService()
          .firestore
          .collection(collectionName);

      // Filter by services if provided
      if (services != null && services.isNotEmpty) {
        query = query.where('services', arrayContainsAny: services);
      }

      // Filter by minimum rating if provided
      if (minRating != null) {
        query = query.where('rating', isGreaterThanOrEqualTo: minRating);
      }

      // Basic name search (Firestore limitation)
      query = query
          .where('name', isGreaterThanOrEqualTo: searchTerm)
          .where('name', isLessThanOrEqualTo: '$searchTerm\uf8ff')
          .limit(limit);

      final snapshot = await query.get();
      final partners = snapshot.docs.map((doc) => fromFirestore(doc)).toList();
      return Right(partners);
    } catch (e) {
      return Left(ServerFailure('Failed to search partners: $e'));
    }
  }

  // Real-time listeners
  Stream<Either<Failure, List<PartnerModel>>> listenToAvailablePartners({
    List<String>? services,
    int limit = 20,
  }) {
    try {
      Query<Map<String, dynamic>> query = FirebaseService()
          .firestore
          .collection(collectionName);

      query = query.where('isAvailable', isEqualTo: true);

      if (services != null && services.isNotEmpty) {
        query = query.where('services', arrayContainsAny: services);
      }

      query = query.orderBy('rating', descending: true).limit(limit);

      return FirebaseService()
          .listenToCollection(collectionName, query: query)
          .map((snapshot) {
        final partners = snapshot.docs.map((doc) => fromFirestore(doc)).toList();
        return Right(partners);
      });
    } catch (e) {
      return Stream.value(Left(ServerFailure('Failed to listen to available partners: $e')));
    }
  }

  // Helper method to calculate distance between two points
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);
    
    final double a = 
        (dLat / 2).sin() * (dLat / 2).sin() +
        lat1.cos() * lat2.cos() * 
        (dLon / 2).sin() * (dLon / 2).sin();
    
    final double c = 2 * (a.sqrt()).asin();
    
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (3.14159265359 / 180);
  }

  // Validation methods
  bool isValidWorkingHours(Map<String, List<String>> workingHours) {
    const validDays = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    
    for (final day in workingHours.keys) {
      if (!validDays.contains(day.toLowerCase())) {
        return false;
      }
    }
    
    return true;
  }

  bool isValidPricePerHour(double price) {
    return price > 0 && price <= 1000; // Reasonable price range in thousands VND
  }

  bool isValidExperienceYears(int years) {
    return years >= 0 && years <= 50;
  }
}
