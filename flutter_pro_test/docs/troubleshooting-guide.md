# CareNow MVP - Troubleshooting Guide

## Table of Contents
1. [Common Issues](#common-issues)
2. [Application Issues](#application-issues)
3. [Firebase Issues](#firebase-issues)
4. [Performance Issues](#performance-issues)
5. [Security Issues](#security-issues)
6. [Deployment Issues](#deployment-issues)
7. [Database Issues](#database-issues)
8. [Monitoring Issues](#monitoring-issues)

## Common Issues

### Issue: Application Won't Load
**Symptoms:**
- White screen on app launch
- Loading spinner never disappears
- Console errors in browser

**Diagnosis:**
```bash
# Check browser console
# Open DevTools (F12) > Console tab

# Check network requests
# DevTools > Network tab > Look for failed requests

# Check service worker
# DevTools > Application > Service Workers
```

**Solutions:**
1. **Clear Browser Cache**
   ```bash
   # Hard refresh
   Ctrl+Shift+R (Windows/Linux)
   Cmd+Shift+R (Mac)
   
   # Clear cache manually
   DevTools > Application > Storage > Clear storage
   ```

2. **Check Firebase Configuration**
   ```dart
   // Verify firebase_options.dart
   static const FirebaseOptions web = FirebaseOptions(
     apiKey: 'your-api-key',
     appId: 'your-app-id',
     // ... other config
   );
   ```

3. **Rebuild Application**
   ```bash
   flutter clean
   flutter pub get
   flutter build web --release
   ```

### Issue: Authentication Failures
**Symptoms:**
- Login button not responding
- "Authentication failed" errors
- Redirect loops after login

**Diagnosis:**
```bash
# Check Firebase Auth status
firebase auth:export users.json --project your-project-id

# Check browser console for auth errors
# Look for CORS or network errors
```

**Solutions:**
1. **Verify Firebase Auth Configuration**
   ```javascript
   // Check authorized domains in Firebase Console
   // Authentication > Settings > Authorized domains
   ```

2. **Clear Authentication State**
   ```dart
   await FirebaseAuth.instance.signOut();
   await FirebaseAuth.instance.currentUser?.reload();
   ```

3. **Check CORS Settings**
   ```bash
   # Update CORS configuration
   gsutil cors set cors.json gs://your-bucket-name
   ```

### Issue: Database Connection Errors
**Symptoms:**
- "Permission denied" errors
- Data not loading
- Write operations failing

**Diagnosis:**
```bash
# Check Firestore rules
firebase firestore:rules:get

# Test database connection
node scripts/test-db-connection.js
```

**Solutions:**
1. **Verify Firestore Rules**
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /{document=**} {
         allow read, write: if request.auth != null;
       }
     }
   }
   ```

2. **Check User Authentication**
   ```dart
   final user = FirebaseAuth.instance.currentUser;
   if (user == null) {
     // Redirect to login
   }
   ```

## Application Issues

### Flutter Web Specific Issues

**Issue: Hot Reload Not Working**
```bash
# Restart with clean cache
flutter clean
flutter pub get
flutter run -d chrome --web-port 3000
```

**Issue: Build Failures**
```bash
# Check for dependency conflicts
flutter pub deps
flutter pub upgrade

# Clear build cache
flutter clean
rm -rf build/
flutter build web --release
```

**Issue: Responsive Design Problems**
```dart
// Use MediaQuery for responsive design
Widget build(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  
  if (screenWidth < 600) {
    return MobileLayout();
  } else if (screenWidth < 1200) {
    return TabletLayout();
  } else {
    return DesktopLayout();
  }
}
```

### State Management Issues

**Issue: BLoC State Not Updating**
```dart
// Ensure proper event emission
class BookingBloc extends Bloc<BookingEvent, BookingState> {
  @override
  Stream<BookingState> mapEventToState(BookingEvent event) async* {
    if (event is LoadBookings) {
      yield BookingLoading();
      try {
        final bookings = await repository.getBookings();
        yield BookingLoaded(bookings);
      } catch (e) {
        yield BookingError(e.toString());
      }
    }
  }
}
```

**Issue: Memory Leaks**
```dart
// Proper disposal of resources
class _MyWidgetState extends State<MyWidget> {
  StreamSubscription? _subscription;
  
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
```

## Firebase Issues

### Authentication Issues

**Issue: User Not Persisting After Refresh**
```dart
// Check auth state persistence
FirebaseAuth.instance.authStateChanges().listen((User? user) {
  if (user == null) {
    // User is signed out
    Navigator.pushReplacementNamed(context, '/login');
  } else {
    // User is signed in
    Navigator.pushReplacementNamed(context, '/dashboard');
  }
});
```

**Issue: Email Verification Not Working**
```dart
// Send verification email
final user = FirebaseAuth.instance.currentUser;
if (user != null && !user.emailVerified) {
  await user.sendEmailVerification();
}
```

### Firestore Issues

**Issue: Data Not Syncing**
```dart
// Enable offline persistence
await FirebaseFirestore.instance.enablePersistence();

// Check network connectivity
final connectivity = await Connectivity().checkConnectivity();
if (connectivity == ConnectivityResult.none) {
  // Handle offline state
}
```

**Issue: Query Performance Problems**
```dart
// Use proper indexing
final query = FirebaseFirestore.instance
    .collection('bookings')
    .where('userId', isEqualTo: userId)
    .where('status', isEqualTo: 'active')
    .orderBy('createdAt', descending: true)
    .limit(20);
```

### Hosting Issues

**Issue: 404 Errors on Refresh**
```json
// Update firebase.json
{
  "hosting": {
    "public": "build/web",
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ]
  }
}
```

**Issue: Slow Loading Times**
```json
// Add caching headers
{
  "hosting": {
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
  }
}
```

## Performance Issues

### Slow Loading Times

**Diagnosis:**
```bash
# Run Lighthouse audit
lighthouse https://carenow.com --output html

# Check bundle size
flutter build web --analyze-size

# Monitor network requests
# DevTools > Network > Check for large files
```

**Solutions:**
1. **Optimize Images**
   ```bash
   # Convert to WebP format
   cwebp input.png -q 80 -o output.webp
   
   # Use responsive images
   <img src="image-small.webp" 
        srcset="image-small.webp 300w, image-large.webp 800w"
        sizes="(max-width: 600px) 300px, 800px">
   ```

2. **Code Splitting**
   ```dart
   // Lazy load routes
   final router = GoRouter(
     routes: [
       GoRoute(
         path: '/admin',
         builder: (context, state) => const AdminDashboard(),
         routes: [
           GoRoute(
             path: '/monitoring',
             builder: (context, state) => const MonitoringDashboard(),
           ),
         ],
       ),
     ],
   );
   ```

3. **Optimize Bundle Size**
   ```bash
   # Build with tree shaking
   flutter build web --tree-shake-icons
   
   # Analyze bundle
   flutter build web --analyze-size
   ```

### Memory Issues

**Diagnosis:**
```bash
# Monitor memory usage
# DevTools > Performance > Memory tab

# Check for memory leaks
# DevTools > Memory > Take heap snapshot
```

**Solutions:**
```dart
// Proper image disposal
class ImageWidget extends StatefulWidget {
  @override
  _ImageWidgetState createState() => _ImageWidgetState();
}

class _ImageWidgetState extends State<ImageWidget> {
  late ImageProvider _imageProvider;
  
  @override
  void dispose() {
    _imageProvider.evict();
    super.dispose();
  }
}
```

## Security Issues

### Authentication Bypass

**Symptoms:**
- Unauthorized access to protected routes
- Admin features accessible to regular users

**Solutions:**
```dart
// Implement proper route guards
class AuthGuard {
  static bool canAccess(String route, User? user) {
    if (user == null) return false;
    
    switch (route) {
      case '/admin':
        return user.customClaims?['admin'] == true;
      case '/partner':
        return user.customClaims?['partner'] == true;
      default:
        return true;
    }
  }
}
```

### Data Exposure

**Symptoms:**
- Sensitive data visible in browser DevTools
- API responses containing private information

**Solutions:**
```dart
// Sanitize data before sending to client
class UserModel {
  final String id;
  final String email;
  // Don't include sensitive fields like password hash
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      // Only include safe fields
    };
  }
}
```

### CORS Issues

**Symptoms:**
- API requests blocked by browser
- "Access-Control-Allow-Origin" errors

**Solutions:**
```javascript
// Configure CORS in Firebase Functions
const cors = require('cors')({
  origin: ['https://carenow.com', 'https://www.carenow.com'],
  credentials: true,
});

exports.api = functions.https.onRequest((req, res) => {
  cors(req, res, () => {
    // Your API logic here
  });
});
```

## Deployment Issues

### Build Failures

**Issue: Compilation Errors**
```bash
# Check for syntax errors
flutter analyze

# Fix dependency conflicts
flutter pub deps
flutter pub upgrade --major-versions

# Clean and rebuild
flutter clean
flutter pub get
flutter build web --release
```

**Issue: Environment Configuration**
```bash
# Set environment variables
export ENV=production
export FIREBASE_PROJECT_ID=carenow-prod

# Build with environment
flutter build web --dart-define=ENV=production
```

### Firebase Deployment Issues

**Issue: Deployment Fails**
```bash
# Check Firebase login
firebase login --reauth

# Verify project selection
firebase use production

# Check deployment status
firebase deploy --only hosting --debug
```

**Issue: Functions Not Updating**
```bash
# Force function redeployment
firebase deploy --only functions --force

# Check function logs
firebase functions:log
```

## Database Issues

### Query Performance

**Issue: Slow Queries**
```dart
// Add proper indexes
// Create composite index for complex queries
final query = FirebaseFirestore.instance
    .collection('bookings')
    .where('status', isEqualTo: 'active')
    .where('partnerId', isEqualTo: partnerId)
    .orderBy('scheduledDate');
```

**Issue: Read/Write Limits**
```dart
// Implement pagination
Query query = FirebaseFirestore.instance
    .collection('bookings')
    .orderBy('createdAt', descending: true)
    .limit(20);

if (lastDocument != null) {
  query = query.startAfterDocument(lastDocument);
}
```

### Data Consistency

**Issue: Stale Data**
```dart
// Force fresh data
final snapshot = await FirebaseFirestore.instance
    .collection('bookings')
    .doc(bookingId)
    .get(const GetOptions(source: Source.server));
```

**Issue: Concurrent Updates**
```dart
// Use transactions for atomic updates
await FirebaseFirestore.instance.runTransaction((transaction) async {
  final bookingRef = FirebaseFirestore.instance
      .collection('bookings')
      .doc(bookingId);
  
  final snapshot = await transaction.get(bookingRef);
  final currentStatus = snapshot.data()?['status'];
  
  if (currentStatus == 'pending') {
    transaction.update(bookingRef, {'status': 'confirmed'});
  }
});
```

## Monitoring Issues

### Dashboard Not Loading

**Issue: Monitoring Dashboard Blank**
```bash
# Check service initialization
# Verify all monitoring services are properly initialized

# Check browser console for errors
# DevTools > Console

# Verify API endpoints
curl -X GET https://carenow.com/api/monitoring/health
```

**Solutions:**
```dart
// Ensure proper service initialization
class MonitoringService {
  static Future<void> initialize() async {
    try {
      await ProductionMonitoringService().initialize();
      await SecurityMonitoringService().initialize();
      await BusinessMetricsValidator().initialize();
    } catch (e) {
      print('Monitoring initialization failed: $e');
      // Implement fallback monitoring
    }
  }
}
```

### Metrics Not Updating

**Issue: Real-time Data Not Refreshing**
```dart
// Check timer configuration
Timer.periodic(const Duration(seconds: 30), (timer) {
  if (mounted && _isRealTimeEnabled) {
    _loadAllMonitoringData();
  }
});
```

**Issue: Alert System Not Working**
```dart
// Verify alert configuration
class AlertingSystem {
  Future<void> checkAlerts() async {
    try {
      final incidents = await getActiveIncidents();
      for (final incident in incidents) {
        await _processAlert(incident);
      }
    } catch (e) {
      print('Alert processing failed: $e');
    }
  }
}
```

---

**Troubleshooting Best Practices:**

1. **Systematic Approach**: Follow a logical troubleshooting process
2. **Documentation**: Document all issues and solutions
3. **Monitoring**: Use monitoring tools to identify issues early
4. **Testing**: Test solutions in staging before production
5. **Communication**: Keep stakeholders informed during troubleshooting

**Emergency Support:**
- **Technical Support**: support@carenow.com
- **Emergency Hotline**: +84-xxx-xxx-xxx
- **Documentation**: https://docs.carenow.com

**Last Updated**: December 2024  
**Version**: 1.0.0
