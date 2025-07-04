import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../core/constants/app_constants.dart';

class FirebaseService {
  // Singleton pattern
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Getters
  FirebaseAuth get auth => _auth;
  FirebaseFirestore get firestore => _firestore;
  FirebaseMessaging get messaging => _messaging;

  // Collection references
  CollectionReference get usersCollection => 
      _firestore.collection(AppConstants.usersCollection);
  
  CollectionReference get partnersCollection => 
      _firestore.collection(AppConstants.partnersCollection);
  
  CollectionReference get servicesCollection => 
      _firestore.collection(AppConstants.servicesCollection);
  
  CollectionReference get bookingsCollection => 
      _firestore.collection(AppConstants.bookingsCollection);
  
  CollectionReference get reviewsCollection => 
      _firestore.collection(AppConstants.reviewsCollection);

  // Current user
  User? get currentUser => _auth.currentUser;
  bool get isAuthenticated => _auth.currentUser != null;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Initialize Firebase services
  Future<void> initialize() async {
    // Request notification permissions
    await _requestNotificationPermissions();
    
    // Set up FCM token
    await _setupFCMToken();
  }

  // Request notification permissions
  Future<void> _requestNotificationPermissions() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');
  }

  // Setup FCM token
  Future<void> _setupFCMToken() async {
    try {
      String? token = await _messaging.getToken();
      if (token != null) {
        print('FCM Token: $token');
        // Save token to user document if authenticated
        if (isAuthenticated) {
          await _saveFCMToken(token);
        }
      }
    } catch (e) {
      print('Error getting FCM token: $e');
    }
  }

  // Save FCM token to user document
  Future<void> _saveFCMToken(String token) async {
    if (currentUser != null) {
      try {
        await usersCollection.doc(currentUser!.uid).update({
          'fcmToken': token,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        print('Error saving FCM token: $e');
      }
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Delete user account
  Future<void> deleteAccount() async {
    if (currentUser != null) {
      // Delete user data from Firestore
      await usersCollection.doc(currentUser!.uid).delete();
      
      // Delete Firebase Auth account
      await currentUser!.delete();
    }
  }

  // Batch operations helper
  WriteBatch batch() => _firestore.batch();

  // Transaction helper
  Future<T> runTransaction<T>(
    Future<T> Function(Transaction transaction) updateFunction,
  ) {
    return _firestore.runTransaction(updateFunction);
  }

  // Listen to document changes
  Stream<DocumentSnapshot<Map<String, dynamic>>> listenToDocument(
    String collection,
    String documentId,
  ) {
    return _firestore
        .collection(collection)
        .doc(documentId)
        .snapshots();
  }

  // Listen to collection changes
  Stream<QuerySnapshot<Map<String, dynamic>>> listenToCollection(
    String collection, {
    Query<Map<String, dynamic>>? query,
  }) {
    if (query != null) {
      return query.snapshots();
    }
    return _firestore.collection(collection).snapshots();
  }

  // Get document by ID
  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument(
    String collection,
    String documentId,
  ) {
    return _firestore.collection(collection).doc(documentId).get();
  }

  // Get collection with query
  Future<QuerySnapshot<Map<String, dynamic>>> getCollection(
    String collection, {
    Query<Map<String, dynamic>>? query,
  }) {
    if (query != null) {
      return query.get();
    }
    return _firestore.collection(collection).get();
  }

  // Add document
  Future<DocumentReference<Map<String, dynamic>>> addDocument(
    String collection,
    Map<String, dynamic> data,
  ) {
    return _firestore.collection(collection).add(data);
  }

  // Set document
  Future<void> setDocument(
    String collection,
    String documentId,
    Map<String, dynamic> data, {
    bool merge = false,
  }) {
    return _firestore
        .collection(collection)
        .doc(documentId)
        .set(data, SetOptions(merge: merge));
  }

  // Update document
  Future<void> updateDocument(
    String collection,
    String documentId,
    Map<String, dynamic> data,
  ) {
    return _firestore.collection(collection).doc(documentId).update(data);
  }

  // Delete document
  Future<void> deleteDocument(
    String collection,
    String documentId,
  ) {
    return _firestore.collection(collection).doc(documentId).delete();
  }

  // Server timestamp
  FieldValue get serverTimestamp => FieldValue.serverTimestamp();

  // Array union
  FieldValue arrayUnion(List<dynamic> elements) => FieldValue.arrayUnion(elements);

  // Array remove
  FieldValue arrayRemove(List<dynamic> elements) => FieldValue.arrayRemove(elements);

  // Increment
  FieldValue increment(num value) => FieldValue.increment(value);
}
