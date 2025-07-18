// Production-ready Firebase configuration with environment support
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Production-ready [FirebaseOptions] with environment-based configuration
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: String.fromEnvironment(
      'FIREBASE_WEB_API_KEY',
      defaultValue: 'your-web-api-key-here',
    ),
    appId: String.fromEnvironment(
      'FIREBASE_WEB_APP_ID',
      defaultValue: '1:133710469637:web:03e765bcb9d10180d09a6c',
    ),
    messagingSenderId: String.fromEnvironment(
      'FIREBASE_MESSAGING_SENDER_ID',
      defaultValue: '133710469637',
    ),
    projectId: String.fromEnvironment(
      'FIREBASE_PROJECT_ID',
      defaultValue: 'carenow-app-2024',
    ),
    authDomain: String.fromEnvironment(
      'FIREBASE_AUTH_DOMAIN',
      defaultValue: 'carenow-app-2024.firebaseapp.com',
    ),
    storageBucket: String.fromEnvironment(
      'FIREBASE_STORAGE_BUCKET',
      defaultValue: 'carenow-app-2024.firebasestorage.app',
    ),
    databaseURL: String.fromEnvironment(
      'FIREBASE_DATABASE_URL',
      defaultValue: 'https://carenow-app-2024-default-rtdb.firebaseio.com/',
    ),
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: String.fromEnvironment(
      'FIREBASE_ANDROID_API_KEY',
      defaultValue: 'your-android-api-key-here',
    ),
    appId: String.fromEnvironment(
      'FIREBASE_ANDROID_APP_ID',
      defaultValue: '1:133710469637:android:5eb0a6e4f88cec8bd09a6c',
    ),
    messagingSenderId: String.fromEnvironment(
      'FIREBASE_MESSAGING_SENDER_ID',
      defaultValue: '133710469637',
    ),
    projectId: String.fromEnvironment(
      'FIREBASE_PROJECT_ID',
      defaultValue: 'carenow-app-2024',
    ),
    storageBucket: String.fromEnvironment(
      'FIREBASE_STORAGE_BUCKET',
      defaultValue: 'carenow-app-2024.firebasestorage.app',
    ),
    databaseURL: String.fromEnvironment(
      'FIREBASE_DATABASE_URL',
      defaultValue: 'https://carenow-app-2024-default-rtdb.firebaseio.com/',
    ),
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: String.fromEnvironment(
      'FIREBASE_IOS_API_KEY',
      defaultValue: 'your-ios-api-key-here',
    ),
    appId: String.fromEnvironment(
      'FIREBASE_IOS_APP_ID',
      defaultValue: '1:133710469637:ios:cecb666ccd35c6edd09a6c',
    ),
    messagingSenderId: String.fromEnvironment(
      'FIREBASE_MESSAGING_SENDER_ID',
      defaultValue: '133710469637',
    ),
    projectId: String.fromEnvironment(
      'FIREBASE_PROJECT_ID',
      defaultValue: 'carenow-app-2024',
    ),
    storageBucket: String.fromEnvironment(
      'FIREBASE_STORAGE_BUCKET',
      defaultValue: 'carenow-app-2024.firebasestorage.app',
    ),
    iosBundleId: String.fromEnvironment(
      'FIREBASE_IOS_BUNDLE_ID',
      defaultValue: 'com.example.flutterProTest',
    ),
    databaseURL: String.fromEnvironment(
      'FIREBASE_DATABASE_URL',
      defaultValue: 'https://carenow-app-2024-default-rtdb.firebaseio.com/',
    ),
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: String.fromEnvironment(
      'FIREBASE_IOS_API_KEY',
      defaultValue: 'your-ios-api-key-here',
    ),
    appId: String.fromEnvironment(
      'FIREBASE_IOS_APP_ID',
      defaultValue: '1:133710469637:ios:cecb666ccd35c6edd09a6c',
    ),
    messagingSenderId: String.fromEnvironment(
      'FIREBASE_MESSAGING_SENDER_ID',
      defaultValue: '133710469637',
    ),
    projectId: String.fromEnvironment(
      'FIREBASE_PROJECT_ID',
      defaultValue: 'carenow-app-2024',
    ),
    storageBucket: String.fromEnvironment(
      'FIREBASE_STORAGE_BUCKET',
      defaultValue: 'carenow-app-2024.firebasestorage.app',
    ),
    iosBundleId: String.fromEnvironment(
      'FIREBASE_IOS_BUNDLE_ID',
      defaultValue: 'com.example.flutterProTest',
    ),
    databaseURL: String.fromEnvironment(
      'FIREBASE_DATABASE_URL',
      defaultValue: 'https://carenow-app-2024-default-rtdb.firebaseio.com/',
    ),
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: String.fromEnvironment(
      'FIREBASE_WEB_API_KEY',
      defaultValue: 'your-web-api-key-here',
    ),
    appId: String.fromEnvironment(
      'FIREBASE_WINDOWS_APP_ID',
      defaultValue: '1:133710469637:web:dce0da2cf3cab9cad09a6c',
    ),
    messagingSenderId: String.fromEnvironment(
      'FIREBASE_MESSAGING_SENDER_ID',
      defaultValue: '133710469637',
    ),
    projectId: String.fromEnvironment(
      'FIREBASE_PROJECT_ID',
      defaultValue: 'carenow-app-2024',
    ),
    authDomain: String.fromEnvironment(
      'FIREBASE_AUTH_DOMAIN',
      defaultValue: 'carenow-app-2024.firebaseapp.com',
    ),
    storageBucket: String.fromEnvironment(
      'FIREBASE_STORAGE_BUCKET',
      defaultValue: 'carenow-app-2024.firebasestorage.app',
    ),
    databaseURL: String.fromEnvironment(
      'FIREBASE_DATABASE_URL',
      defaultValue: 'https://carenow-app-2024-default-rtdb.firebaseio.com/',
    ),
  );
}
