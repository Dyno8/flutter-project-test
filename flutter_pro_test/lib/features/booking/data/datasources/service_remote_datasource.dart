import '../../../../shared/models/service_model.dart';
import '../../../../shared/services/firebase_service.dart';
import '../../../../core/constants/app_constants.dart';

/// Remote data source for service operations using Firebase
abstract class ServiceRemoteDataSource {
  Future<List<ServiceModel>> getActiveServices();
  Future<ServiceModel> getServiceById(String serviceId);
  Future<List<ServiceModel>> getServicesByCategory(String category);
  Future<List<ServiceModel>> searchServices(String query);
  Stream<List<ServiceModel>> listenToActiveServices();
}

class ServiceRemoteDataSourceImpl implements ServiceRemoteDataSource {
  final FirebaseService _firebaseService;

  ServiceRemoteDataSourceImpl(this._firebaseService);

  @override
  Future<List<ServiceModel>> getActiveServices() async {
    try {
      final query = _firebaseService
          .collection(AppConstants.servicesCollection)
          .where('isActive', isEqualTo: true)
          .orderBy('sortOrder');

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => ServiceModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get active services: $e');
    }
  }

  @override
  Future<ServiceModel> getServiceById(String serviceId) async {
    try {
      final doc = await _firebaseService.getDocument(
        AppConstants.servicesCollection,
        serviceId,
      );
      return ServiceModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get service: $e');
    }
  }

  @override
  Future<List<ServiceModel>> getServicesByCategory(String category) async {
    try {
      final query = _firebaseService
          .collection(AppConstants.servicesCollection)
          .where('category', isEqualTo: category)
          .where('isActive', isEqualTo: true)
          .orderBy('sortOrder');

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => ServiceModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get services by category: $e');
    }
  }

  @override
  Future<List<ServiceModel>> searchServices(String query) async {
    try {
      // Simple text search - in production, you might want to use Algolia or similar
      final snapshot = await _firebaseService
          .collection(AppConstants.servicesCollection)
          .where('isActive', isEqualTo: true)
          .get();

      final services = snapshot.docs
          .map((doc) => ServiceModel.fromFirestore(doc))
          .where(
            (service) =>
                service.name.toLowerCase().contains(query.toLowerCase()) ||
                service.description.toLowerCase().contains(
                  query.toLowerCase(),
                ) ||
                service.category.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();

      return services;
    } catch (e) {
      throw Exception('Failed to search services: $e');
    }
  }

  @override
  Stream<List<ServiceModel>> listenToActiveServices() {
    try {
      return _firebaseService
          .collection(AppConstants.servicesCollection)
          .where('isActive', isEqualTo: true)
          .orderBy('sortOrder')
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => ServiceModel.fromFirestore(doc))
                .toList(),
          );
    } catch (e) {
      throw Exception('Failed to listen to active services: $e');
    }
  }
}
