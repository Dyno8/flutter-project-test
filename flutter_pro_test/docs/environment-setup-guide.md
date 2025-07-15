# CareNow MVP - Environment Setup Guide

## Table of Contents
1. [Development Environment](#development-environment)
2. [Staging Environment](#staging-environment)
3. [Production Environment](#production-environment)
4. [Environment Variables](#environment-variables)
5. [Database Setup](#database-setup)
6. [Third-Party Services](#third-party-services)
7. [Security Configuration](#security-configuration)
8. [Monitoring Setup](#monitoring-setup)

## Development Environment

### Prerequisites
```bash
# Install Flutter SDK
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# Verify installation
flutter doctor

# Install Firebase CLI
npm install -g firebase-tools

# Install additional tools
npm install -g @angular/cli  # For admin dashboard (if needed)
```

### IDE Setup
**VS Code Extensions:**
- Flutter
- Dart
- Firebase
- GitLens
- Error Lens
- Bracket Pair Colorizer

**Android Studio Plugins:**
- Flutter
- Dart
- Firebase Services

### Project Setup
```bash
# Clone repository
git clone <repository-url>
cd flutter_pro_test

# Install dependencies
flutter pub get

# Run code generation
flutter packages pub run build_runner build

# Setup pre-commit hooks
git config core.hooksPath .githooks
chmod +x .githooks/pre-commit
```

### Development Configuration
```dart
// lib/core/config/dev_environment.dart
class DevEnvironment {
  static const String name = 'development';
  static const String baseUrl = 'http://localhost:3000';
  static const bool debugMode = true;
  static const bool enableLogging = true;
  static const bool enableAnalytics = false;
  static const bool enableCrashlytics = false;
  
  // Firebase configuration
  static const String firebaseProjectId = 'carenow-dev';
  static const String firebaseApiKey = 'dev-api-key';
  static const String firebaseAuthDomain = 'carenow-dev.firebaseapp.com';
  
  // Database configuration
  static const String databaseUrl = 'https://carenow-dev-default-rtdb.firebaseio.com';
  static const String firestoreUrl = 'https://firestore.googleapis.com/v1/projects/carenow-dev/databases/(default)/documents';
}
```

### Local Development Server
```bash
# Start development server
flutter run -d chrome --web-port 3000

# Hot reload enabled
# Debug mode enabled
# DevTools available at: http://localhost:9100
```

## Staging Environment

### Infrastructure Setup
```yaml
# docker-compose.staging.yml
version: '3.8'
services:
  carenow-staging:
    build:
      context: .
      dockerfile: Dockerfile.staging
    ports:
      - "8080:80"
    environment:
      - ENV=staging
      - FIREBASE_PROJECT_ID=carenow-staging
    volumes:
      - ./build/web:/usr/share/nginx/html
    restart: unless-stopped
```

### Staging Configuration
```dart
// lib/core/config/staging_environment.dart
class StagingEnvironment {
  static const String name = 'staging';
  static const String baseUrl = 'https://staging-api.carenow.com';
  static const bool debugMode = false;
  static const bool enableLogging = true;
  static const bool enableAnalytics = true;
  static const bool enableCrashlytics = true;
  
  // Firebase configuration
  static const String firebaseProjectId = 'carenow-staging';
  static const String firebaseApiKey = 'staging-api-key';
  static const String firebaseAuthDomain = 'carenow-staging.firebaseapp.com';
  
  // Performance monitoring
  static const bool enablePerformanceMonitoring = true;
  static const Duration performanceThreshold = Duration(seconds: 2);
}
```

### Staging Deployment
```bash
# Build for staging
flutter build web --dart-define=ENV=staging

# Deploy to staging
firebase use staging
firebase deploy --only hosting:staging

# Run staging tests
flutter test --dart-define=ENV=staging
```

## Production Environment

### Infrastructure Requirements
- **CPU**: 2+ cores
- **RAM**: 4GB minimum, 8GB recommended
- **Storage**: 20GB SSD
- **Network**: High-speed internet with low latency
- **SSL**: Valid SSL certificate
- **CDN**: Content Delivery Network for global access

### Production Configuration
```dart
// lib/core/config/prod_environment.dart
class ProdEnvironment {
  static const String name = 'production';
  static const String baseUrl = 'https://api.carenow.com';
  static const bool debugMode = false;
  static const bool enableLogging = false; // Only error logs
  static const bool enableAnalytics = true;
  static const bool enableCrashlytics = true;
  
  // Firebase configuration
  static const String firebaseProjectId = 'carenow-prod';
  static const String firebaseApiKey = 'prod-api-key';
  static const String firebaseAuthDomain = 'carenow.com';
  
  // Security configuration
  static const bool enableSecurityHeaders = true;
  static const bool enableCSP = true;
  static const bool enableHSTS = true;
  
  // Performance configuration
  static const bool enableCaching = true;
  static const bool enableCompression = true;
  static const bool enableMinification = true;
}
```

### Production Deployment
```bash
# Build for production
flutter build web --release --dart-define=ENV=production

# Optimize build
flutter build web --release --web-renderer html --dart-define=ENV=production

# Deploy to production
firebase use production
firebase deploy --only hosting:production

# Verify deployment
curl -I https://carenow.com
```

## Environment Variables

### Environment Variable Configuration
```bash
# .env.development
ENV=development
API_BASE_URL=http://localhost:3000
FIREBASE_PROJECT_ID=carenow-dev
FIREBASE_API_KEY=dev-api-key
ENABLE_ANALYTICS=false
ENABLE_CRASHLYTICS=false
DEBUG_MODE=true

# .env.staging
ENV=staging
API_BASE_URL=https://staging-api.carenow.com
FIREBASE_PROJECT_ID=carenow-staging
FIREBASE_API_KEY=staging-api-key
ENABLE_ANALYTICS=true
ENABLE_CRASHLYTICS=true
DEBUG_MODE=false

# .env.production
ENV=production
API_BASE_URL=https://api.carenow.com
FIREBASE_PROJECT_ID=carenow-prod
FIREBASE_API_KEY=prod-api-key
ENABLE_ANALYTICS=true
ENABLE_CRASHLYTICS=true
DEBUG_MODE=false
```

### Environment Variable Manager
```dart
// lib/core/config/env_manager.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvManager {
  static Future<void> load() async {
    const env = String.fromEnvironment('ENV', defaultValue: 'development');
    await dotenv.load(fileName: '.env.$env');
  }
  
  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? '';
  static String get firebaseProjectId => dotenv.env['FIREBASE_PROJECT_ID'] ?? '';
  static String get firebaseApiKey => dotenv.env['FIREBASE_API_KEY'] ?? '';
  static bool get enableAnalytics => dotenv.env['ENABLE_ANALYTICS'] == 'true';
  static bool get enableCrashlytics => dotenv.env['ENABLE_CRASHLYTICS'] == 'true';
  static bool get debugMode => dotenv.env['DEBUG_MODE'] == 'true';
}
```

## Database Setup

### Firestore Setup
```javascript
// firestore-setup.js
const admin = require('firebase-admin');
const serviceAccount = require('./service-account-key.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: 'https://carenow-prod-default-rtdb.firebaseio.com'
});

const db = admin.firestore();

// Create initial collections
async function setupDatabase() {
  // Create services collection
  await db.collection('services').doc('nursing').set({
    name: 'Nursing Care',
    description: 'Professional nursing services',
    category: 'healthcare',
    active: true,
    createdAt: admin.firestore.FieldValue.serverTimestamp()
  });
  
  // Create admin user
  await db.collection('users').doc('admin').set({
    email: 'admin@carenow.com',
    role: 'admin',
    permissions: ['read', 'write', 'admin'],
    createdAt: admin.firestore.FieldValue.serverTimestamp()
  });
  
  console.log('Database setup completed');
}

setupDatabase().catch(console.error);
```

### Database Indexes
```bash
# Create composite indexes
firebase firestore:indexes

# Index configuration in firestore.indexes.json
{
  "indexes": [
    {
      "collectionGroup": "bookings",
      "queryScope": "COLLECTION",
      "fields": [
        {"fieldPath": "status", "order": "ASCENDING"},
        {"fieldPath": "createdAt", "order": "DESCENDING"}
      ]
    }
  ]
}
```

## Third-Party Services

### Payment Integration
```dart
// lib/core/services/payment_config.dart
class PaymentConfig {
  // Stripe configuration
  static const String stripePublishableKey = 'pk_test_...';
  static const String stripeSecretKey = 'sk_test_...'; // Server-side only
  
  // VNPay configuration (for Vietnam)
  static const String vnpayMerchantId = 'your-merchant-id';
  static const String vnpaySecretKey = 'your-secret-key';
  static const String vnpayApiUrl = 'https://sandbox.vnpayment.vn/paymentv2/vpcpay.html';
  
  // MoMo configuration (for Vietnam)
  static const String momoPartnerCode = 'your-partner-code';
  static const String momoAccessKey = 'your-access-key';
  static const String momoSecretKey = 'your-secret-key';
}
```

### Notification Services
```dart
// lib/core/services/notification_config.dart
class NotificationConfig {
  // Firebase Cloud Messaging
  static const String fcmServerKey = 'your-fcm-server-key';
  static const String fcmSenderId = 'your-sender-id';
  
  // Push notification settings
  static const bool enablePushNotifications = true;
  static const bool enableEmailNotifications = true;
  static const bool enableSMSNotifications = true;
  
  // Notification channels
  static const List<String> notificationChannels = [
    'booking_updates',
    'payment_notifications',
    'system_alerts',
    'marketing_messages'
  ];
}
```

## Security Configuration

### SSL/TLS Configuration
```nginx
# nginx.conf for production
server {
    listen 443 ssl http2;
    server_name carenow.com www.carenow.com;
    
    ssl_certificate /path/to/certificate.crt;
    ssl_certificate_key /path/to/private.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512;
    
    # Security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Content-Type-Options nosniff;
    add_header X-Frame-Options DENY;
    add_header X-XSS-Protection "1; mode=block";
    
    location / {
        root /var/www/carenow;
        try_files $uri $uri/ /index.html;
    }
}
```

### API Security
```dart
// lib/core/security/api_security.dart
class ApiSecurity {
  // API rate limiting
  static const int maxRequestsPerMinute = 60;
  static const int maxRequestsPerHour = 1000;
  
  // Request validation
  static const bool enableRequestValidation = true;
  static const bool enableResponseValidation = true;
  
  // Authentication
  static const Duration tokenExpiry = Duration(hours: 24);
  static const Duration refreshTokenExpiry = Duration(days: 30);
  
  // CORS configuration
  static const List<String> allowedOrigins = [
    'https://carenow.com',
    'https://www.carenow.com',
    'https://admin.carenow.com'
  ];
}
```

## Monitoring Setup

### Application Monitoring
```dart
// lib/core/monitoring/monitoring_setup.dart
class MonitoringSetup {
  static Future<void> initialize() async {
    // Initialize Firebase Analytics
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
    
    // Initialize Crashlytics
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    
    // Initialize Performance Monitoring
    await FirebasePerformance.instance.setPerformanceCollectionEnabled(true);
    
    // Setup custom monitoring
    await _setupCustomMonitoring();
  }
  
  static Future<void> _setupCustomMonitoring() async {
    // Setup performance monitoring
    final performanceMonitoring = ProductionMonitoringService();
    await performanceMonitoring.initialize();
    
    // Setup security monitoring
    final securityMonitoring = SecurityMonitoringService();
    await securityMonitoring.initialize();
    
    // Setup business metrics monitoring
    final businessMetrics = BusinessMetricsValidator();
    await businessMetrics.initialize();
  }
}
```

### Health Check Endpoints
```dart
// lib/core/health/health_check.dart
class HealthCheckEndpoint {
  static Map<String, dynamic> getHealthStatus() {
    return {
      'status': 'healthy',
      'timestamp': DateTime.now().toIso8601String(),
      'version': '1.0.0',
      'environment': EnvironmentManager.environment,
      'services': {
        'firebase': _checkFirebaseHealth(),
        'database': _checkDatabaseHealth(),
        'api': _checkApiHealth(),
      }
    };
  }
  
  static String _checkFirebaseHealth() {
    // Check Firebase connection
    return 'healthy';
  }
  
  static String _checkDatabaseHealth() {
    // Check database connection
    return 'healthy';
  }
  
  static String _checkApiHealth() {
    // Check API endpoints
    return 'healthy';
  }
}
```

---

**Environment Management Best Practices:**

1. **Separation**: Keep environments completely separate
2. **Automation**: Automate environment setup and deployment
3. **Monitoring**: Monitor all environments continuously
4. **Security**: Apply security measures to all environments
5. **Documentation**: Document all environment configurations
6. **Testing**: Test in staging before production deployment

**Last Updated**: December 2024  
**Version**: 1.0.0
