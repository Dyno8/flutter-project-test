import 'package:flutter/foundation.dart';

/// Environment configuration manager for production readiness
class EnvironmentConfig {
  static const String _envKey = 'FLUTTER_ENV';
  static const String _defaultEnv = 'development';

  /// Current environment
  static String get environment =>
      const String.fromEnvironment(_envKey, defaultValue: _defaultEnv);

  /// Check if running in production
  static bool get isProduction => environment == 'production';

  /// Check if running in staging
  static bool get isStaging => environment == 'staging';

  /// Check if running in development
  static bool get isDevelopment => environment == 'development';

  /// Check if running in debug mode
  static bool get isDebug => kDebugMode;

  /// Check if running in release mode
  static bool get isRelease => kReleaseMode;

  /// Firebase configuration based on environment
  static FirebaseEnvironmentConfig get firebaseConfig {
    switch (environment) {
      case 'production':
        return FirebaseEnvironmentConfig.production();
      case 'staging':
        return FirebaseEnvironmentConfig.staging();
      default:
        return FirebaseEnvironmentConfig.development();
    }
  }

  /// API configuration based on environment
  static ApiEnvironmentConfig get apiConfig {
    switch (environment) {
      case 'production':
        return ApiEnvironmentConfig.production();
      case 'staging':
        return ApiEnvironmentConfig.staging();
      default:
        return ApiEnvironmentConfig.development();
    }
  }

  /// Security configuration based on environment
  static SecurityEnvironmentConfig get securityConfig {
    switch (environment) {
      case 'production':
        return SecurityEnvironmentConfig.production();
      case 'staging':
        return SecurityEnvironmentConfig.staging();
      default:
        return SecurityEnvironmentConfig.development();
    }
  }

  /// Performance configuration based on environment
  static PerformanceEnvironmentConfig get performanceConfig {
    switch (environment) {
      case 'production':
        return PerformanceEnvironmentConfig.production();
      case 'staging':
        return PerformanceEnvironmentConfig.staging();
      default:
        return PerformanceEnvironmentConfig.development();
    }
  }

  /// Analytics configuration based on environment
  static AnalyticsEnvironmentConfig get analyticsConfig {
    switch (environment) {
      case 'production':
        return AnalyticsEnvironmentConfig.production();
      case 'staging':
        return AnalyticsEnvironmentConfig.staging();
      default:
        return AnalyticsEnvironmentConfig.development();
    }
  }

  /// Logging configuration based on environment
  static LoggingEnvironmentConfig get loggingConfig {
    switch (environment) {
      case 'production':
        return LoggingEnvironmentConfig.production();
      case 'staging':
        return LoggingEnvironmentConfig.staging();
      default:
        return LoggingEnvironmentConfig.development();
    }
  }

  /// Get environment-specific app name
  static String get appName {
    switch (environment) {
      case 'production':
        return 'CareNow';
      case 'staging':
        return 'CareNow Staging';
      default:
        return 'CareNow Dev';
    }
  }

  /// Get environment-specific app version
  static String get appVersion {
    const version = String.fromEnvironment(
      'APP_VERSION',
      defaultValue: '1.0.0',
    );
    if (isProduction) return version;
    return '$version-${environment.toUpperCase()}';
  }

  /// Get environment-specific bundle identifier
  static String get bundleId {
    const baseId = 'com.carenow.app';
    switch (environment) {
      case 'production':
        return baseId;
      case 'staging':
        return '$baseId.staging';
      default:
        return '$baseId.dev';
    }
  }

  /// Validate environment configuration
  static bool validateConfiguration() {
    try {
      // Validate Firebase configuration
      final firebase = firebaseConfig;
      if (firebase.projectId.isEmpty || firebase.apiKey.isEmpty) {
        return false;
      }

      // Validate API configuration
      final api = apiConfig;
      if (api.baseUrl.isEmpty) {
        return false;
      }

      // Validate security configuration
      final security = securityConfig;
      if (security.encryptionEnabled && security.encryptionKey.isEmpty) {
        return false;
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Environment validation failed: $e');
      }
      return false;
    }
  }

  /// Print environment information (debug only)
  static void printEnvironmentInfo() {
    if (!kDebugMode) return;

    print('🌍 Environment Configuration:');
    print('  Environment: $environment');
    print('  App Name: $appName');
    print('  App Version: $appVersion');
    print('  Bundle ID: $bundleId');
    print('  Is Production: $isProduction');
    print('  Is Debug: $isDebug');
    print('  Firebase Project: ${firebaseConfig.projectId}');
    print('  API Base URL: ${apiConfig.baseUrl}');
    print('  Security Level: ${securityConfig.securityLevel}');
    print('  Performance Monitoring: ${performanceConfig.monitoringEnabled}');
    print('  Logging Level: ${loggingConfig.logLevel}');
  }
}

/// Firebase environment-specific configuration
class FirebaseEnvironmentConfig {
  final String projectId;
  final String apiKey;
  final String authDomain;
  final String storageBucket;
  final String messagingSenderId;
  final String appId;
  final String measurementId;

  const FirebaseEnvironmentConfig({
    required this.projectId,
    required this.apiKey,
    required this.authDomain,
    required this.storageBucket,
    required this.messagingSenderId,
    required this.appId,
    required this.measurementId,
  });

  factory FirebaseEnvironmentConfig.production() {
    return FirebaseEnvironmentConfig(
      projectId: const String.fromEnvironment(
        'FIREBASE_PROJECT_ID_PROD',
        defaultValue: 'carenow-app-prod',
      ),
      apiKey: const String.fromEnvironment(
        'FIREBASE_API_KEY_PROD',
        defaultValue: 'your-production-api-key',
      ),
      authDomain: const String.fromEnvironment(
        'FIREBASE_AUTH_DOMAIN_PROD',
        defaultValue: 'carenow-app-prod.firebaseapp.com',
      ),
      storageBucket: const String.fromEnvironment(
        'FIREBASE_STORAGE_BUCKET_PROD',
        defaultValue: 'carenow-app-prod.appspot.com',
      ),
      messagingSenderId: const String.fromEnvironment(
        'FIREBASE_MESSAGING_SENDER_ID_PROD',
        defaultValue: 'your-messaging-sender-id',
      ),
      appId: const String.fromEnvironment(
        'FIREBASE_APP_ID_PROD',
        defaultValue: 'your-app-id',
      ),
      measurementId: const String.fromEnvironment(
        'FIREBASE_MEASUREMENT_ID_PROD',
        defaultValue: 'your-measurement-id',
      ),
    );
  }

  factory FirebaseEnvironmentConfig.staging() {
    return FirebaseEnvironmentConfig(
      projectId: const String.fromEnvironment(
        'FIREBASE_PROJECT_ID_STAGING',
        defaultValue: 'carenow-app-staging',
      ),
      apiKey: const String.fromEnvironment(
        'FIREBASE_API_KEY_STAGING',
        defaultValue: 'your-staging-api-key',
      ),
      authDomain: const String.fromEnvironment(
        'FIREBASE_AUTH_DOMAIN_STAGING',
        defaultValue: 'carenow-app-staging.firebaseapp.com',
      ),
      storageBucket: const String.fromEnvironment(
        'FIREBASE_STORAGE_BUCKET_STAGING',
        defaultValue: 'carenow-app-staging.appspot.com',
      ),
      messagingSenderId: const String.fromEnvironment(
        'FIREBASE_MESSAGING_SENDER_ID_STAGING',
        defaultValue: 'your-messaging-sender-id',
      ),
      appId: const String.fromEnvironment(
        'FIREBASE_APP_ID_STAGING',
        defaultValue: 'your-app-id',
      ),
      measurementId: const String.fromEnvironment(
        'FIREBASE_MEASUREMENT_ID_STAGING',
        defaultValue: 'your-measurement-id',
      ),
    );
  }

  factory FirebaseEnvironmentConfig.development() {
    return FirebaseEnvironmentConfig(
      projectId: const String.fromEnvironment(
        'FIREBASE_PROJECT_ID_DEV',
        defaultValue: 'carenow-app-dev',
      ),
      apiKey: const String.fromEnvironment(
        'FIREBASE_API_KEY_DEV',
        defaultValue: 'your-dev-api-key',
      ),
      authDomain: const String.fromEnvironment(
        'FIREBASE_AUTH_DOMAIN_DEV',
        defaultValue: 'carenow-app-dev.firebaseapp.com',
      ),
      storageBucket: const String.fromEnvironment(
        'FIREBASE_STORAGE_BUCKET_DEV',
        defaultValue: 'carenow-app-dev.appspot.com',
      ),
      messagingSenderId: const String.fromEnvironment(
        'FIREBASE_MESSAGING_SENDER_ID_DEV',
        defaultValue: 'your-messaging-sender-id',
      ),
      appId: const String.fromEnvironment(
        'FIREBASE_APP_ID_DEV',
        defaultValue: 'your-app-id',
      ),
      measurementId: const String.fromEnvironment(
        'FIREBASE_MEASUREMENT_ID_DEV',
        defaultValue: 'your-measurement-id',
      ),
    );
  }
}

/// API environment-specific configuration
class ApiEnvironmentConfig {
  final String baseUrl;
  final Duration timeout;
  final int maxRetries;
  final bool enableLogging;

  const ApiEnvironmentConfig({
    required this.baseUrl,
    required this.timeout,
    required this.maxRetries,
    required this.enableLogging,
  });

  factory ApiEnvironmentConfig.production() {
    return ApiEnvironmentConfig(
      baseUrl: const String.fromEnvironment(
        'API_BASE_URL_PROD',
        defaultValue: 'https://api.carenow.com',
      ),
      timeout: const Duration(seconds: 30),
      maxRetries: 3,
      enableLogging: false,
    );
  }

  factory ApiEnvironmentConfig.staging() {
    return ApiEnvironmentConfig(
      baseUrl: const String.fromEnvironment(
        'API_BASE_URL_STAGING',
        defaultValue: 'https://staging-api.carenow.com',
      ),
      timeout: const Duration(seconds: 45),
      maxRetries: 5,
      enableLogging: true,
    );
  }

  factory ApiEnvironmentConfig.development() {
    return ApiEnvironmentConfig(
      baseUrl: const String.fromEnvironment(
        'API_BASE_URL_DEV',
        defaultValue: 'https://dev-api.carenow.com',
      ),
      timeout: const Duration(seconds: 60),
      maxRetries: 5,
      enableLogging: true,
    );
  }
}

/// Security environment-specific configuration
class SecurityEnvironmentConfig {
  final String securityLevel;
  final bool encryptionEnabled;
  final String encryptionKey;
  final bool sessionTimeoutEnabled;
  final Duration sessionTimeout;
  final bool rateLimitingEnabled;
  final int maxRequestsPerMinute;

  const SecurityEnvironmentConfig({
    required this.securityLevel,
    required this.encryptionEnabled,
    required this.encryptionKey,
    required this.sessionTimeoutEnabled,
    required this.sessionTimeout,
    required this.rateLimitingEnabled,
    required this.maxRequestsPerMinute,
  });

  factory SecurityEnvironmentConfig.production() {
    return SecurityEnvironmentConfig(
      securityLevel: 'HIGH',
      encryptionEnabled: true,
      encryptionKey: const String.fromEnvironment(
        'ENCRYPTION_KEY_PROD',
        defaultValue: 'your-production-encryption-key',
      ),
      sessionTimeoutEnabled: true,
      sessionTimeout: const Duration(minutes: 30),
      rateLimitingEnabled: true,
      maxRequestsPerMinute: 100,
    );
  }

  factory SecurityEnvironmentConfig.staging() {
    return SecurityEnvironmentConfig(
      securityLevel: 'MEDIUM',
      encryptionEnabled: true,
      encryptionKey: const String.fromEnvironment(
        'ENCRYPTION_KEY_STAGING',
        defaultValue: 'your-staging-encryption-key',
      ),
      sessionTimeoutEnabled: true,
      sessionTimeout: const Duration(hours: 1),
      rateLimitingEnabled: true,
      maxRequestsPerMinute: 200,
    );
  }

  factory SecurityEnvironmentConfig.development() {
    return SecurityEnvironmentConfig(
      securityLevel: 'LOW',
      encryptionEnabled: false,
      encryptionKey: const String.fromEnvironment(
        'ENCRYPTION_KEY_DEV',
        defaultValue: 'dev-encryption-key',
      ),
      sessionTimeoutEnabled: false,
      sessionTimeout: const Duration(hours: 8),
      rateLimitingEnabled: false,
      maxRequestsPerMinute: 1000,
    );
  }
}

/// Performance environment-specific configuration
class PerformanceEnvironmentConfig {
  final bool monitoringEnabled;
  final bool cachingEnabled;
  final int cacheSize;
  final Duration cacheExpiration;
  final bool analyticsEnabled;
  final bool crashReportingEnabled;
  final bool performanceMonitoringEnabled;

  const PerformanceEnvironmentConfig({
    required this.monitoringEnabled,
    required this.cachingEnabled,
    required this.cacheSize,
    required this.cacheExpiration,
    required this.analyticsEnabled,
    required this.crashReportingEnabled,
    required this.performanceMonitoringEnabled,
  });

  factory PerformanceEnvironmentConfig.production() {
    return const PerformanceEnvironmentConfig(
      monitoringEnabled: true,
      cachingEnabled: true,
      cacheSize: 200,
      cacheExpiration: Duration(minutes: 60),
      analyticsEnabled: true,
      crashReportingEnabled: true,
      performanceMonitoringEnabled: true,
    );
  }

  factory PerformanceEnvironmentConfig.staging() {
    return const PerformanceEnvironmentConfig(
      monitoringEnabled: true,
      cachingEnabled: true,
      cacheSize: 100,
      cacheExpiration: Duration(minutes: 30),
      analyticsEnabled: true,
      crashReportingEnabled: true,
      performanceMonitoringEnabled: true,
    );
  }

  factory PerformanceEnvironmentConfig.development() {
    return const PerformanceEnvironmentConfig(
      monitoringEnabled: false,
      cachingEnabled: true,
      cacheSize: 50,
      cacheExpiration: Duration(minutes: 15),
      analyticsEnabled: false,
      crashReportingEnabled: false,
      performanceMonitoringEnabled: false,
    );
  }
}

/// Logging environment-specific configuration
class LoggingEnvironmentConfig {
  final String logLevel;
  final bool enableConsoleLogging;
  final bool enableFileLogging;
  final bool enableRemoteLogging;
  final int maxLogFiles;
  final int maxLogFileSize;

  const LoggingEnvironmentConfig({
    required this.logLevel,
    required this.enableConsoleLogging,
    required this.enableFileLogging,
    required this.enableRemoteLogging,
    required this.maxLogFiles,
    required this.maxLogFileSize,
  });

  factory LoggingEnvironmentConfig.production() {
    return const LoggingEnvironmentConfig(
      logLevel: 'ERROR',
      enableConsoleLogging: false,
      enableFileLogging: true,
      enableRemoteLogging: true,
      maxLogFiles: 10,
      maxLogFileSize: 10 * 1024 * 1024, // 10MB
    );
  }

  factory LoggingEnvironmentConfig.staging() {
    return const LoggingEnvironmentConfig(
      logLevel: 'WARNING',
      enableConsoleLogging: true,
      enableFileLogging: true,
      enableRemoteLogging: true,
      maxLogFiles: 5,
      maxLogFileSize: 5 * 1024 * 1024, // 5MB
    );
  }

  factory LoggingEnvironmentConfig.development() {
    return const LoggingEnvironmentConfig(
      logLevel: 'DEBUG',
      enableConsoleLogging: true,
      enableFileLogging: false,
      enableRemoteLogging: false,
      maxLogFiles: 3,
      maxLogFileSize: 1 * 1024 * 1024, // 1MB
    );
  }
}

/// Analytics environment-specific configuration
class AnalyticsEnvironmentConfig {
  final bool analyticsEnabled;
  final bool crashReportingEnabled;
  final bool performanceMonitoringEnabled;
  final bool userTrackingEnabled;
  final bool customEventTrackingEnabled;
  final Duration sessionTimeout;
  final int maxEventsPerSession;
  final bool debugLoggingEnabled;

  const AnalyticsEnvironmentConfig({
    required this.analyticsEnabled,
    required this.crashReportingEnabled,
    required this.performanceMonitoringEnabled,
    required this.userTrackingEnabled,
    required this.customEventTrackingEnabled,
    required this.sessionTimeout,
    required this.maxEventsPerSession,
    required this.debugLoggingEnabled,
  });

  factory AnalyticsEnvironmentConfig.production() {
    return const AnalyticsEnvironmentConfig(
      analyticsEnabled: true,
      crashReportingEnabled: true,
      performanceMonitoringEnabled: true,
      userTrackingEnabled: true,
      customEventTrackingEnabled: true,
      sessionTimeout: Duration(minutes: 30),
      maxEventsPerSession: 500,
      debugLoggingEnabled: false,
    );
  }

  factory AnalyticsEnvironmentConfig.staging() {
    return const AnalyticsEnvironmentConfig(
      analyticsEnabled: true,
      crashReportingEnabled: true,
      performanceMonitoringEnabled: true,
      userTrackingEnabled: true,
      customEventTrackingEnabled: true,
      sessionTimeout: Duration(minutes: 60),
      maxEventsPerSession: 1000,
      debugLoggingEnabled: true,
    );
  }

  factory AnalyticsEnvironmentConfig.development() {
    return const AnalyticsEnvironmentConfig(
      analyticsEnabled: false,
      crashReportingEnabled: false,
      performanceMonitoringEnabled: false,
      userTrackingEnabled: false,
      customEventTrackingEnabled: true,
      sessionTimeout: Duration(hours: 2),
      maxEventsPerSession: 100,
      debugLoggingEnabled: true,
    );
  }
}
