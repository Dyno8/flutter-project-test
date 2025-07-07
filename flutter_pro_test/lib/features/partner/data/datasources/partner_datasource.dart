import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/models/partner_model.dart';

/// Abstract interface for partner data source
abstract class PartnerDataSource {
  Future<Either<Failure, PartnerModel>> getPartner(String uid);
  Future<Either<Failure, PartnerModel>> createPartner(PartnerModel partner);
  Future<Either<Failure, PartnerModel>> updatePartner(PartnerModel partner);
  Future<Either<Failure, void>> deletePartner(String uid);
  Future<Either<Failure, List<PartnerModel>>> getPartnersByService(
    String serviceId,
  );
  Future<Either<Failure, List<PartnerModel>>> searchPartners({
    String? query,
    List<String>? services,
    String? city,
    String? district,
    double? minRating,
    double? maxPrice,
    bool? isVerified,
    bool? isAvailable,
  });
  Stream<Either<Failure, PartnerModel>> watchPartner(String uid);
  Stream<Either<Failure, List<PartnerModel>>> watchPartnersByCriteria({
    List<String>? services,
    String? city,
    bool? isAvailable,
  });
}

/// Implementation of partner data source using Firebase
class FirebasePartnerDataSource implements PartnerDataSource {
  final FirebaseFirestore _firestore;

  FirebasePartnerDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  static const String _collection = 'partners';

  @override
  Future<Either<Failure, PartnerModel>> getPartner(String uid) async {
    try {
      final doc = await _firestore.collection(_collection).doc(uid).get();

      if (!doc.exists) {
        return const Left(DataFailure('Partner not found'));
      }

      final partner = PartnerModel.fromFirestore(doc);
      return Right(partner);
    } on FirebaseException catch (e) {
      return Left(DataFailure('Failed to get partner: ${e.message}'));
    } catch (e) {
      return Left(DataFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, PartnerModel>> createPartner(
    PartnerModel partner,
  ) async {
    try {
      final docRef = _firestore.collection(_collection).doc(partner.uid);

      // Check if partner already exists
      final existingDoc = await docRef.get();
      if (existingDoc.exists) {
        return const Left(DataFailure('Partner already exists'));
      }

      await docRef.set(partner.toMap());

      // Get the created partner
      final createdDoc = await docRef.get();
      final createdPartner = PartnerModel.fromFirestore(createdDoc);

      return Right(createdPartner);
    } on FirebaseException catch (e) {
      return Left(DataFailure('Failed to create partner: ${e.message}'));
    } catch (e) {
      return Left(DataFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, PartnerModel>> updatePartner(
    PartnerModel partner,
  ) async {
    try {
      final docRef = _firestore.collection(_collection).doc(partner.uid);

      // Check if partner exists
      final existingDoc = await docRef.get();
      if (!existingDoc.exists) {
        return const Left(DataFailure('Partner not found'));
      }

      await docRef.update(partner.toMap());

      // Get the updated partner
      final updatedDoc = await docRef.get();
      final updatedPartner = PartnerModel.fromFirestore(updatedDoc);

      return Right(updatedPartner);
    } on FirebaseException catch (e) {
      return Left(DataFailure('Failed to update partner: ${e.message}'));
    } catch (e) {
      return Left(DataFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deletePartner(String uid) async {
    try {
      await _firestore.collection(_collection).doc(uid).delete();
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(DataFailure('Failed to delete partner: ${e.message}'));
    } catch (e) {
      return Left(DataFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<PartnerModel>>> getPartnersByService(
    String serviceId,
  ) async {
    try {
      final query = await _firestore
          .collection(_collection)
          .where('services', arrayContains: serviceId)
          .where('isAvailable', isEqualTo: true)
          .get();

      final partners = query.docs
          .map((doc) => PartnerModel.fromFirestore(doc))
          .toList();

      return Right(partners);
    } on FirebaseException catch (e) {
      return Left(
        DataFailure('Failed to get partners by service: ${e.message}'),
      );
    } catch (e) {
      return Left(DataFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<PartnerModel>>> searchPartners({
    String? query,
    List<String>? services,
    String? city,
    String? district,
    double? minRating,
    double? maxPrice,
    bool? isVerified,
    bool? isAvailable,
  }) async {
    try {
      Query<Map<String, dynamic>> firestoreQuery = _firestore.collection(
        _collection,
      );

      // Add availability filter (default to available only)
      if (isAvailable ?? true) {
        firestoreQuery = firestoreQuery.where('isAvailable', isEqualTo: true);
      }

      // Add verification filter
      if (isVerified != null) {
        firestoreQuery = firestoreQuery.where(
          'isVerified',
          isEqualTo: isVerified,
        );
      }

      // Add city filter
      if (city != null && city.isNotEmpty) {
        firestoreQuery = firestoreQuery.where('location.city', isEqualTo: city);
      }

      // Add district filter
      if (district != null && district.isNotEmpty) {
        firestoreQuery = firestoreQuery.where(
          'location.district',
          isEqualTo: district,
        );
      }

      // Add minimum rating filter
      if (minRating != null) {
        firestoreQuery = firestoreQuery.where(
          'rating',
          isGreaterThanOrEqualTo: minRating,
        );
      }

      // Add maximum price filter
      if (maxPrice != null) {
        firestoreQuery = firestoreQuery.where(
          'pricePerHour',
          isLessThanOrEqualTo: maxPrice,
        );
      }

      final querySnapshot = await firestoreQuery.get();

      List<PartnerModel> partners = querySnapshot.docs
          .map((doc) => PartnerModel.fromFirestore(doc))
          .toList();

      // Filter by services (client-side filtering for array contains any)
      if (services != null && services.isNotEmpty) {
        partners = partners.where((partner) {
          return services.any((service) => partner.services.contains(service));
        }).toList();
      }

      // Filter by name/bio query (client-side filtering)
      if (query != null && query.isNotEmpty) {
        partners = partners.where((partner) {
          return partner.name.toLowerCase().contains(query.toLowerCase()) ||
              (partner.bio?.toLowerCase().contains(query.toLowerCase()) ??
                  false);
        }).toList();
      }

      // Sort by rating (highest first)
      partners.sort((a, b) => b.rating.compareTo(a.rating));

      return Right(partners);
    } on FirebaseException catch (e) {
      return Left(DataFailure('Failed to search partners: ${e.message}'));
    } catch (e) {
      return Left(DataFailure('Unexpected error: $e'));
    }
  }

  @override
  Stream<Either<Failure, PartnerModel>> watchPartner(String uid) {
    try {
      return _firestore
          .collection(_collection)
          .doc(uid)
          .snapshots()
          .map<Either<Failure, PartnerModel>>((doc) {
            try {
              if (!doc.exists) {
                return const Left(DataFailure('Partner not found'));
              }

              final partner = PartnerModel.fromFirestore(doc);
              return Right(partner);
            } catch (e) {
              return Left(DataFailure('Failed to parse partner: $e'));
            }
          });
    } catch (e) {
      return Stream.value(
        Left(DataFailure('Failed to create partner stream: $e')),
      );
    }
  }

  @override
  Stream<Either<Failure, List<PartnerModel>>> watchPartnersByCriteria({
    List<String>? services,
    String? city,
    bool? isAvailable,
  }) {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection(_collection);

      // Add availability filter
      if (isAvailable ?? true) {
        query = query.where('isAvailable', isEqualTo: true);
      }

      // Add city filter
      if (city != null && city.isNotEmpty) {
        query = query.where('location.city', isEqualTo: city);
      }

      return query.snapshots().map<Either<Failure, List<PartnerModel>>>((
        snapshot,
      ) {
        try {
          List<PartnerModel> partners = snapshot.docs
              .map((doc) => PartnerModel.fromFirestore(doc))
              .toList();

          // Filter by services (client-side)
          if (services != null && services.isNotEmpty) {
            partners = partners.where((partner) {
              return services.any(
                (service) => partner.services.contains(service),
              );
            }).toList();
          }

          // Sort by rating
          partners.sort((a, b) => b.rating.compareTo(a.rating));

          return Right(partners);
        } catch (e) {
          return Left(DataFailure('Failed to parse partners: $e'));
        }
      });
    } catch (e) {
      return Stream.value(
        Left(DataFailure('Failed to create partners stream: $e')),
      );
    }
  }
}
