import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Helper class for setting up Firebase in tests
class FirebaseTestHelper {
  static bool _initialized = false;

  /// Initialize Firebase for testing
  static Future<void> initializeFirebase() async {
    if (_initialized) return;

    TestWidgetsFlutterBinding.ensureInitialized();

    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});

    // Mock Firebase Core
    const MethodChannel(
      'plugins.flutter.io/firebase_core',
    ).setMockMethodCallHandler((methodCall) async {
      if (methodCall.method == 'Firebase#initializeCore') {
        return [
          {
            'name': '[DEFAULT]',
            'options': {
              'apiKey': 'fake-api-key',
              'appId': 'fake-app-id',
              'messagingSenderId': 'fake-sender-id',
              'projectId': 'fake-project-id',
            },
            'pluginConstants': {},
          },
        ];
      }
      if (methodCall.method == 'Firebase#initializeApp') {
        return {
          'name': methodCall.arguments['appName'],
          'options': methodCall.arguments['options'],
          'pluginConstants': {},
        };
      }
      return null;
    });

    // Mock Firebase Analytics
    const MethodChannel(
      'plugins.flutter.io/firebase_analytics',
    ).setMockMethodCallHandler((methodCall) async {
      return null;
    });

    // Mock Firebase Crashlytics
    const MethodChannel(
      'plugins.flutter.io/firebase_crashlytics',
    ).setMockMethodCallHandler((methodCall) async {
      return null;
    });

    // Mock Firebase Performance
    const MethodChannel(
      'plugins.flutter.io/firebase_performance',
    ).setMockMethodCallHandler((methodCall) async {
      if (methodCall.method == 'FirebasePerformance#newTrace') {
        return {'handle': 1};
      }
      if (methodCall.method == 'FirebasePerformance#newHttpMetric') {
        return {'handle': 1};
      }
      return null;
    });

    // Mock Firebase Messaging
    const MethodChannel(
      'plugins.flutter.io/firebase_messaging',
    ).setMockMethodCallHandler((methodCall) async {
      if (methodCall.method == 'Messaging#getToken') {
        return 'fake-fcm-token';
      }
      return null;
    });

    try {
      await Firebase.initializeApp();
      _initialized = true;
    } catch (e) {
      // Firebase already initialized or mock setup issue
      _initialized = true;
    }
  }

  /// Clean up Firebase mocks
  static void cleanup() {
    const MethodChannel(
      'plugins.flutter.io/firebase_core',
    ).setMockMethodCallHandler(null);
    const MethodChannel(
      'plugins.flutter.io/firebase_analytics',
    ).setMockMethodCallHandler(null);
    const MethodChannel(
      'plugins.flutter.io/firebase_crashlytics',
    ).setMockMethodCallHandler(null);
    const MethodChannel(
      'plugins.flutter.io/firebase_performance',
    ).setMockMethodCallHandler(null);
    const MethodChannel(
      'plugins.flutter.io/firebase_messaging',
    ).setMockMethodCallHandler(null);
  }
}
