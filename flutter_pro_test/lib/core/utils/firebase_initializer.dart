import 'package:firebase_core/firebase_core.dart';
import '../config/environment_config.dart';
import '../../firebase_options.dart';

/// Utility class for safe Firebase initialization
class FirebaseInitializer {
  /// Safely initialize Firebase, checking if it's already initialized
  ///
  /// This prevents the "duplicate-app" error that occurs when Firebase
  /// is initialized multiple times in the same app session.
  ///
  /// Returns true if Firebase was initialized, false if it was already initialized.
  static Future<bool> initializeSafely() async {
    try {
      // Check if Firebase is already initialized
      final app = Firebase.app();
      // If we get here, Firebase is already initialized
      if (EnvironmentConfig.isDebug) {
        print(
          '🔥 Firebase already initialized by ${app.name} app, skipping manual initialization...',
        );
        print('🔥 Firebase project: ${app.options.projectId}');
      }
      return false; // Already initialized
    } catch (e) {
      // Firebase is not initialized, so initialize it
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        if (EnvironmentConfig.isDebug) {
          print('🔥 Firebase initialized for the first time');
        }
        return true; // Newly initialized
      } catch (initError) {
        // Handle the case where Firebase gets initialized between our check and initialization
        if (initError.toString().contains('duplicate-app')) {
          if (EnvironmentConfig.isDebug) {
            print(
              '🔥 Firebase was initialized by another process during our initialization attempt',
            );
          }
          return false; // Already initialized by another process
        }
        // Re-throw other errors
        rethrow;
      }
    }
  }

  /// Check if Firebase is already initialized without initializing it
  static bool isInitialized() {
    try {
      Firebase.app();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get the current Firebase app instance safely
  static FirebaseApp? getCurrentApp() {
    try {
      return Firebase.app();
    } catch (e) {
      return null;
    }
  }

  /// Initialize Firebase with custom options
  static Future<bool> initializeWithOptions(FirebaseOptions options) async {
    try {
      Firebase.app();
      if (EnvironmentConfig.isDebug) {
        print(
          '🔥 Firebase already initialized, skipping custom initialization...',
        );
      }
      return false;
    } catch (e) {
      await Firebase.initializeApp(options: options);
      if (EnvironmentConfig.isDebug) {
        print('🔥 Firebase initialized with custom options');
      }
      return true;
    }
  }
}
