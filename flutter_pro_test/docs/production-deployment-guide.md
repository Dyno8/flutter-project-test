# CareNow MVP - Production Deployment Guide

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Environment Setup](#environment-setup)
4. [Firebase Configuration](#firebase-configuration)
5. [Build Configuration](#build-configuration)
6. [Deployment Process](#deployment-process)
7. [Post-Deployment Verification](#post-deployment-verification)
8. [Monitoring & Maintenance](#monitoring--maintenance)
9. [Troubleshooting](#troubleshooting)

## Overview

This guide provides comprehensive instructions for deploying the CareNow MVP Flutter application to production. The application is designed for the Vietnamese healthcare services market and includes comprehensive monitoring, security, and performance optimization features.

### Architecture Overview

- **Frontend**: Flutter Web Application
- **Backend**: Firebase Services (Auth, Firestore, Analytics, Crashlytics, Hosting)
- **Monitoring**: Unified monitoring dashboard with real-time analytics
- **Security**: Advanced security monitoring and compliance validation
- **Performance**: Performance validation with SLA monitoring

## Prerequisites

### System Requirements

- **Flutter SDK**: 3.16.0 or higher
- **Dart SDK**: 3.2.0 or higher
- **Node.js**: 18.0 or higher (for Firebase CLI)
- **Git**: Latest version
- **Web Browser**: Chrome, Firefox, Safari, or Edge (latest versions)

### Development Tools

```bash
# Install Flutter
flutter --version

# Install Firebase CLI
npm install -g firebase-tools

# Verify installations
firebase --version
dart --version
```

### Access Requirements

- Firebase project with admin access
- Domain name (optional, for custom hosting)
- SSL certificate (handled by Firebase Hosting)

## Environment Setup

### 1. Clone Repository

```bash
git clone <repository-url>
cd flutter_pro_test
```

### 2. Install Dependencies

```bash
# Install Flutter dependencies
flutter pub get

# Verify no issues
flutter doctor
```

### 3. Environment Configuration

Create environment-specific configuration files:

```dart
// lib/core/config/environment_config.dart
class EnvironmentConfig {
  static const String environment = 'production';
  static const String appVersion = '1.0.0';
  static const String apiBaseUrl = 'https://your-api-domain.com';

  // Feature flags
  static const bool enableAnalytics = true;
  static const bool enableCrashlytics = true;
  static const bool enablePerformanceMonitoring = true;
}
```

## Firebase Configuration

### 1. Firebase Project Setup

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create new project or select existing project
3. Enable required services:
   - Authentication
   - Cloud Firestore
   - Analytics
   - Crashlytics
   - Hosting

### 2. Web App Configuration

```bash
# Initialize Firebase in project
firebase init

# Select services:
# - Hosting
# - Firestore
# - Functions (if needed)
```

### 3. Firebase Configuration Files

Ensure these files are properly configured:

```javascript
// firebase.json
{
  "hosting": {
    "public": "build/web",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ],
    "headers": [
      {
        "source": "**/*.@(js|css)",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "max-age=31536000"
          }
        ]
      }
    ]
  },
  "firestore": {
    "rules": "firestore.rules",
    "indexes": "firestore.indexes.json"
  }
}
```

### 4. Security Rules

Update Firestore security rules for production:

```javascript
// firestore.rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Bookings security
    match /bookings/{bookingId} {
      allow read, write: if request.auth != null &&
        (request.auth.uid == resource.data.clientId ||
         request.auth.uid == resource.data.partnerId);
    }

    // Admin access
    match /admin/{document=**} {
      allow read, write: if request.auth != null &&
        request.auth.token.admin == true;
    }
  }
}
```

## Build Configuration

### 1. Production Build

```bash
# Clean previous builds
flutter clean
flutter pub get

# Build for web production
flutter build web --release --web-renderer html

# Verify build output
ls -la build/web/
```

### 2. Build Optimization

Configure `web/index.html` for production:

```html
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8" />
    <meta content="IE=Edge" http-equiv="X-UA-Compatible" />
    <meta name="description" content="CareNow - Healthcare Services Platform" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <meta name="apple-mobile-web-app-status-bar-style" content="black" />
    <meta name="apple-mobile-web-app-title" content="CareNow" />
    <meta name="msapplication-TileColor" content="#2F3BA2" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />

    <!-- SEO Meta Tags -->
    <meta property="og:title" content="CareNow - Healthcare Services" />
    <meta
      property="og:description"
      content="Professional healthcare services platform"
    />
    <meta property="og:type" content="website" />

    <title>CareNow - Healthcare Services</title>
    <link rel="manifest" href="manifest.json" />

    <!-- Favicon -->
    <link rel="icon" type="image/png" href="favicon.png" />
    <link rel="apple-touch-icon" href="icons/Icon-192.png" />
  </head>
  <body>
    <script src="main.dart.js" type="application/javascript"></script>
  </body>
</html>
```

### 3. Performance Optimization

Add to `web/index.html`:

```html
<!-- Preload critical resources -->
<link rel="preload" href="main.dart.js" as="script" />
<link
  rel="preload"
  href="assets/fonts/Roboto-Regular.ttf"
  as="font"
  type="font/ttf"
  crossorigin
/>

<!-- Service Worker for caching -->
<script>
  if ("serviceWorker" in navigator) {
    window.addEventListener("flutter-first-frame", function () {
      navigator.serviceWorker.register("flutter_service_worker.js");
    });
  }
</script>
```

## Deployment Process

### 1. Pre-Deployment Checklist

- [ ] All tests passing (`flutter test`)
- [ ] No compilation errors (`flutter analyze`)
- [ ] Environment variables configured
- [ ] Firebase services enabled
- [ ] Security rules updated
- [ ] Performance optimizations applied
- [ ] Monitoring dashboard functional

### 2. Build and Deploy

```bash
# Step 1: Build production version
flutter build web --release

# Step 2: Deploy to Firebase Hosting
firebase deploy --only hosting

# Step 3: Deploy Firestore rules and indexes
firebase deploy --only firestore

# Step 4: Verify deployment
firebase hosting:channel:open live
```

### 3. Custom Domain (Optional)

```bash
# Add custom domain
firebase hosting:sites:create your-domain-name
firebase target:apply hosting production your-domain-name

# Update firebase.json
{
  "hosting": {
    "target": "production",
    "public": "build/web",
    // ... rest of config
  }
}

# Deploy to custom domain
firebase deploy --only hosting:production
```

## Post-Deployment Verification

### 1. Functional Testing

- [ ] User registration and login
- [ ] Booking creation and management
- [ ] Partner dashboard functionality
- [ ] Payment processing (mock)
- [ ] Admin dashboard access
- [ ] Monitoring dashboard operational

### 2. Performance Testing

```bash
# Run Lighthouse audit
npx lighthouse https://your-domain.com --output html --output-path ./lighthouse-report.html

# Check Core Web Vitals:
# - First Contentful Paint (FCP) < 1.8s
# - Largest Contentful Paint (LCP) < 2.5s
# - Cumulative Layout Shift (CLS) < 0.1
# - First Input Delay (FID) < 100ms
```

### 3. Security Verification

- [ ] HTTPS enabled
- [ ] Security headers configured
- [ ] Authentication working
- [ ] Authorization rules enforced
- [ ] No sensitive data exposed

### 4. Monitoring Verification

- [ ] Analytics tracking events
- [ ] Crashlytics reporting errors
- [ ] Performance monitoring active
- [ ] Security monitoring operational
- [ ] Business metrics validation running

## Monitoring & Maintenance

### 1. Monitoring Dashboard Access

Access the unified monitoring dashboard at:

```
https://your-domain.com/admin/monitoring
```

### 2. Key Metrics to Monitor

- **System Health**: Overall system status
- **Performance**: Response times, load times, memory usage
- **Security**: Security alerts, compliance status
- **Business**: User engagement, conversion rates
- **Errors**: Error rates, crash reports

### 3. Alerting Configuration

Configure alerts for:

- System downtime
- High error rates (>5%)
- Performance degradation
- Security incidents
- Business metric anomalies

### 4. Regular Maintenance Tasks

- **Daily**: Check monitoring dashboard
- **Weekly**: Review performance metrics
- **Monthly**: Security audit and updates
- **Quarterly**: Dependency updates and security patches

## Troubleshooting

### Common Issues

#### 1. Build Failures

```bash
# Clear cache and rebuild
flutter clean
flutter pub get
flutter build web --release
```

#### 2. Firebase Deployment Issues

```bash
# Check Firebase login
firebase login --reauth

# Verify project selection
firebase use --add

# Check hosting configuration
firebase hosting:channel:list
```

#### 3. Performance Issues

- Check network requests in browser DevTools
- Verify service worker caching
- Optimize images and assets
- Review bundle size

#### 4. Authentication Issues

- Verify Firebase Auth configuration
- Check security rules
- Validate JWT tokens
- Review CORS settings

### Support Contacts

- **Technical Support**: tech-support@carenow.com
- **Emergency**: emergency@carenow.com
- **Documentation**: docs@carenow.com

---

## Related Documentation

- [Configuration Guide](configuration-guide.md) - Detailed configuration instructions
- [Environment Setup Guide](environment-setup-guide.md) - Environment-specific setup procedures
- [Operational Runbook](operational-runbook.md) - Daily operations and maintenance procedures
- [Troubleshooting Guide](troubleshooting-guide.md) - Common issues and solutions

## Quick Reference

### Essential Commands

```bash
# Build and deploy
flutter build web --release
firebase deploy --only hosting

# Health check
curl -s https://carenow.com/health

# Monitor logs
firebase functions:log --only monitoring

# Emergency rollback
firebase hosting:channel:deploy previous-version
```

### Important URLs

- **Production App**: https://carenow.com
- **Admin Dashboard**: https://carenow.com/admin
- **Monitoring Dashboard**: https://carenow.com/admin/monitoring
- **Firebase Console**: https://console.firebase.google.com
- **Documentation**: https://docs.carenow.com

---

**Last Updated**: December 2024
**Version**: 1.0.0
**Environment**: Production
