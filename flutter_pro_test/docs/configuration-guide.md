# CareNow MVP - Configuration Guide

## Table of Contents
1. [Environment Configuration](#environment-configuration)
2. [Firebase Configuration](#firebase-configuration)
3. [Security Configuration](#security-configuration)
4. [Performance Configuration](#performance-configuration)
5. [Monitoring Configuration](#monitoring-configuration)
6. [Feature Flags](#feature-flags)
7. [Localization Configuration](#localization-configuration)

## Environment Configuration

### Development Environment
```dart
// lib/core/config/dev_config.dart
class DevConfig {
  static const String environment = 'development';
  static const String appName = 'CareNow Dev';
  static const String apiBaseUrl = 'https://dev-api.carenow.com';
  static const bool enableDebugMode = true;
  static const bool enableAnalytics = false;
  static const bool enableCrashlytics = false;
  static const int apiTimeoutSeconds = 30;
}
```

### Staging Environment
```dart
// lib/core/config/staging_config.dart
class StagingConfig {
  static const String environment = 'staging';
  static const String appName = 'CareNow Staging';
  static const String apiBaseUrl = 'https://staging-api.carenow.com';
  static const bool enableDebugMode = false;
  static const bool enableAnalytics = true;
  static const bool enableCrashlytics = true;
  static const int apiTimeoutSeconds = 15;
}
```

### Production Environment
```dart
// lib/core/config/prod_config.dart
class ProdConfig {
  static const String environment = 'production';
  static const String appName = 'CareNow';
  static const String apiBaseUrl = 'https://api.carenow.com';
  static const bool enableDebugMode = false;
  static const bool enableAnalytics = true;
  static const bool enableCrashlytics = true;
  static const int apiTimeoutSeconds = 10;
}
```

### Environment Manager
```dart
// lib/core/config/environment_manager.dart
import 'dev_config.dart';
import 'staging_config.dart';
import 'prod_config.dart';

class EnvironmentManager {
  static const String _environment = String.fromEnvironment('ENV', defaultValue: 'development');
  
  static String get environment => _environment;
  static String get appName => _getConfig().appName;
  static String get apiBaseUrl => _getConfig().apiBaseUrl;
  static bool get enableDebugMode => _getConfig().enableDebugMode;
  static bool get enableAnalytics => _getConfig().enableAnalytics;
  static bool get enableCrashlytics => _getConfig().enableCrashlytics;
  static int get apiTimeoutSeconds => _getConfig().apiTimeoutSeconds;
  
  static dynamic _getConfig() {
    switch (_environment) {
      case 'production':
        return ProdConfig;
      case 'staging':
        return StagingConfig;
      default:
        return DevConfig;
    }
  }
}
```

## Firebase Configuration

### Firebase Options Configuration
```dart
// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
        throw UnsupportedError('DefaultFirebaseOptions have not been configured for windows');
      case TargetPlatform.linux:
        throw UnsupportedError('DefaultFirebaseOptions have not been configured for linux');
      default:
        throw UnsupportedError('DefaultFirebaseOptions are not supported for this platform.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'your-web-api-key',
    appId: 'your-web-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: 'your-project-id',
    authDomain: 'your-project.firebaseapp.com',
    storageBucket: 'your-project.appspot.com',
    measurementId: 'your-measurement-id',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'your-android-api-key',
    appId: 'your-android-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: 'your-project-id',
    storageBucket: 'your-project.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'your-ios-api-key',
    appId: 'your-ios-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: 'your-project-id',
    storageBucket: 'your-project.appspot.com',
    iosBundleId: 'com.carenow.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'your-macos-api-key',
    appId: 'your-macos-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: 'your-project-id',
    storageBucket: 'your-project.appspot.com',
    iosBundleId: 'com.carenow.app',
  );
}
```

### Firestore Configuration
```javascript
// firestore.rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User data access
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      allow read: if request.auth != null && request.auth.token.admin == true;
    }
    
    // Booking data access
    match /bookings/{bookingId} {
      allow read, write: if request.auth != null && 
        (request.auth.uid == resource.data.clientId || 
         request.auth.uid == resource.data.partnerId ||
         request.auth.token.admin == true);
    }
    
    // Partner data access
    match /partners/{partnerId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        (request.auth.uid == partnerId || request.auth.token.admin == true);
    }
    
    // Admin data access
    match /admin/{document=**} {
      allow read, write: if request.auth != null && request.auth.token.admin == true;
    }
    
    // Public data (read-only)
    match /services/{serviceId} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.token.admin == true;
    }
  }
}
```

### Firebase Indexes
```json
{
  "indexes": [
    {
      "collectionGroup": "bookings",
      "queryScope": "COLLECTION",
      "fields": [
        {"fieldPath": "clientId", "order": "ASCENDING"},
        {"fieldPath": "createdAt", "order": "DESCENDING"}
      ]
    },
    {
      "collectionGroup": "bookings",
      "queryScope": "COLLECTION",
      "fields": [
        {"fieldPath": "partnerId", "order": "ASCENDING"},
        {"fieldPath": "status", "order": "ASCENDING"},
        {"fieldPath": "scheduledDate", "order": "ASCENDING"}
      ]
    },
    {
      "collectionGroup": "partners",
      "queryScope": "COLLECTION",
      "fields": [
        {"fieldPath": "isActive", "order": "ASCENDING"},
        {"fieldPath": "serviceType", "order": "ASCENDING"},
        {"fieldPath": "rating", "order": "DESCENDING"}
      ]
    }
  ],
  "fieldOverrides": []
}
```

## Security Configuration

### Authentication Configuration
```dart
// lib/core/auth/auth_config.dart
class AuthConfig {
  // Password requirements
  static const int minPasswordLength = 8;
  static const bool requireUppercase = true;
  static const bool requireLowercase = true;
  static const bool requireNumbers = true;
  static const bool requireSpecialChars = true;
  
  // Session configuration
  static const Duration sessionTimeout = Duration(hours: 24);
  static const Duration refreshTokenExpiry = Duration(days: 30);
  
  // Multi-factor authentication
  static const bool enableMFA = true;
  static const List<String> allowedMFAMethods = ['sms', 'email'];
  
  // OAuth providers
  static const List<String> enabledProviders = ['google', 'facebook'];
  
  // Security headers
  static const Map<String, String> securityHeaders = {
    'X-Content-Type-Options': 'nosniff',
    'X-Frame-Options': 'DENY',
    'X-XSS-Protection': '1; mode=block',
    'Strict-Transport-Security': 'max-age=31536000; includeSubDomains',
    'Content-Security-Policy': "default-src 'self'; script-src 'self' 'unsafe-inline'",
  };
}
```

### API Security Configuration
```dart
// lib/core/network/api_config.dart
class ApiConfig {
  // Rate limiting
  static const int maxRequestsPerMinute = 60;
  static const int maxRequestsPerHour = 1000;
  
  // Request timeout
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
  
  // Retry configuration
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 1);
  
  // SSL/TLS configuration
  static const bool enableCertificatePinning = true;
  static const List<String> pinnedCertificates = [
    'sha256/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=',
  ];
}
```

## Performance Configuration

### Performance Monitoring
```dart
// lib/core/performance/performance_config.dart
class PerformanceConfig {
  // Performance thresholds
  static const Duration maxLoadTime = Duration(seconds: 3);
  static const Duration maxApiResponseTime = Duration(milliseconds: 500);
  static const int maxMemoryUsageMB = 512;
  static const double maxCpuUsagePercent = 80.0;
  
  // Monitoring intervals
  static const Duration performanceCheckInterval = Duration(seconds: 30);
  static const Duration memoryCheckInterval = Duration(minutes: 1);
  static const Duration networkCheckInterval = Duration(seconds: 10);
  
  // Caching configuration
  static const Duration cacheExpiry = Duration(hours: 1);
  static const int maxCacheSize = 100; // MB
  static const bool enableImageCaching = true;
  static const bool enableApiCaching = true;
  
  // Bundle optimization
  static const bool enableCodeSplitting = true;
  static const bool enableTreeShaking = true;
  static const bool enableMinification = true;
}
```

### Image Optimization
```dart
// lib/core/assets/image_config.dart
class ImageConfig {
  // Image compression
  static const int jpegQuality = 85;
  static const int pngCompressionLevel = 6;
  static const bool enableWebP = true;
  
  // Image sizes
  static const Map<String, Size> imageSizes = {
    'thumbnail': Size(150, 150),
    'small': Size(300, 300),
    'medium': Size(600, 600),
    'large': Size(1200, 1200),
  };
  
  // Lazy loading
  static const bool enableLazyLoading = true;
  static const double lazyLoadingThreshold = 200.0;
}
```

## Monitoring Configuration

### Analytics Configuration
```dart
// lib/core/analytics/analytics_config.dart
class AnalyticsConfig {
  // Event tracking
  static const bool trackUserEvents = true;
  static const bool trackPerformanceEvents = true;
  static const bool trackErrorEvents = true;
  static const bool trackBusinessEvents = true;
  
  // Data collection
  static const bool enableUserProperties = true;
  static const bool enableCustomDimensions = true;
  static const bool enableEcommerce = true;
  
  // Privacy settings
  static const bool anonymizeIPs = true;
  static const bool respectDoNotTrack = true;
  static const Duration dataRetentionPeriod = Duration(days: 365);
  
  // Sampling rates
  static const double eventSamplingRate = 1.0; // 100%
  static const double performanceSamplingRate = 0.1; // 10%
  static const double errorSamplingRate = 1.0; // 100%
}
```

### Crashlytics Configuration
```dart
// lib/core/crashlytics/crashlytics_config.dart
class CrashlyticsConfig {
  // Error reporting
  static const bool enableAutomaticReporting = true;
  static const bool enableCustomKeys = true;
  static const bool enableUserIdentifiers = true;
  
  // Data collection
  static const bool collectUserEmails = false; // Privacy compliance
  static const bool collectUserNames = false; // Privacy compliance
  static const bool collectDeviceInfo = true;
  static const bool collectAppInfo = true;
  
  // Filtering
  static const List<String> ignoredExceptions = [
    'SocketException',
    'TimeoutException',
  ];
  
  // Limits
  static const int maxCustomKeys = 64;
  static const int maxCustomKeyLength = 1024;
  static const int maxLogSize = 65536;
}
```

## Feature Flags

### Feature Flag Configuration
```dart
// lib/core/features/feature_flags.dart
class FeatureFlags {
  // Core features
  static const bool enableBookingSystem = true;
  static const bool enablePaymentIntegration = true;
  static const bool enablePartnerDashboard = true;
  static const bool enableAdminDashboard = true;
  
  // Advanced features
  static const bool enableRealTimeTracking = true;
  static const bool enableNotifications = true;
  static const bool enableAnalytics = true;
  static const bool enableAdvancedSecurity = true;
  
  // Experimental features
  static const bool enableAIRecommendations = false;
  static const bool enableVideoConsultation = false;
  static const bool enableMultiLanguage = true;
  
  // Regional features
  static const bool enableVietnameseLocalization = true;
  static const bool enableLocalPaymentMethods = true;
  static const bool enableLocalCompliance = true;
}
```

## Localization Configuration

### Supported Locales
```dart
// lib/core/localization/locale_config.dart
class LocaleConfig {
  static const List<Locale> supportedLocales = [
    Locale('en', 'US'), // English (US)
    Locale('vi', 'VN'), // Vietnamese (Vietnam)
  ];
  
  static const Locale defaultLocale = Locale('vi', 'VN');
  static const Locale fallbackLocale = Locale('en', 'US');
  
  // Date and time formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  
  // Currency settings
  static const String defaultCurrency = 'VND';
  static const String currencySymbol = '₫';
  static const int currencyDecimalPlaces = 0;
  
  // Number formats
  static const String numberFormat = '#,##0';
  static const String percentFormat = '#,##0.0%';
}
```

### Localization Files Structure
```
lib/
  l10n/
    app_en.arb          # English translations
    app_vi.arb          # Vietnamese translations
    app_localizations.dart
```

---

**Configuration Management Best Practices:**

1. **Environment Separation**: Keep configurations separate for each environment
2. **Security**: Never commit sensitive data to version control
3. **Validation**: Validate all configuration values at startup
4. **Documentation**: Document all configuration options
5. **Monitoring**: Monitor configuration changes in production
6. **Backup**: Maintain backups of production configurations

**Last Updated**: December 2024  
**Version**: 1.0.0
