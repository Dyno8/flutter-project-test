import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_pro_test/core/security/security_manager.dart';
import 'security_test_utils.dart';

void main() {
  group('SecurityManager', () {
    late SecurityManager securityManager;

    setUpAll(() async {
      // Initialize SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
      securityManager = SecurityManager();
      await securityManager.initialize();
    });

    tearDown(() async {
      // Clean up after each test
      securityManager.clearSecurityData();
    });

    // Run all security tests from SecurityTestUtils
    SecurityTestUtils.runAllSecurityTests();

    group('Integration Tests', () {
      test('should handle complete authentication flow', () async {
        const userEmail = 'test@example.com';
        const password = 'TestPass123!';

        // Check password strength
        expect(securityManager.isPasswordSecure(password), isTrue);

        // Generate salt and hash password
        final salt = securityManager.generateSalt();
        final hashedPassword = securityManager.hashPassword(password, salt);

        expect(hashedPassword, isNotEmpty);
        expect(hashedPassword, isNot(equals(password)));

        // Generate session token
        final sessionToken = securityManager.generateSessionToken();
        expect(sessionToken, isNotEmpty);

        // Validate session
        expect(securityManager.validateSession(sessionToken), isTrue);

        // Check account is not locked
        expect(securityManager.isAccountLocked(userEmail), isFalse);

        // Log security event
        securityManager.logSecurityEvent(
          eventType: 'login_success',
          description: 'User logged in successfully',
          metadata: {'user': userEmail},
        );

        final logs = securityManager.getSecurityLogs();
        expect(logs, isNotEmpty);
        expect(logs.last['type'], equals('login_success'));
      });

      test('should handle failed authentication attempts', () {
        const userEmail = 'attacker@example.com';

        // Simulate multiple failed attempts
        for (int i = 0; i < SecurityManager.maxFailedAttempts - 1; i++) {
          securityManager.recordFailedAttempt(userEmail);
          expect(securityManager.isAccountLocked(userEmail), isFalse);
        }

        // One more attempt should lock the account
        securityManager.recordFailedAttempt(userEmail);
        expect(securityManager.isAccountLocked(userEmail), isTrue);

        // Check remaining lockout time
        final remainingTime = securityManager.getRemainingLockoutTime(
          userEmail,
        );
        expect(remainingTime, greaterThan(0));

        // Log security event
        securityManager.logSecurityEvent(
          eventType: 'account_locked',
          description: 'Account locked due to failed attempts',
          metadata: {
            'user': userEmail,
            'attempts': SecurityManager.maxFailedAttempts,
          },
        );
      });

      test('should protect against malicious input', () {
        final maliciousInputs = [
          "'; DROP TABLE users; --",
          "<script>alert('XSS')</script>",
          "javascript:alert('hack')",
          "1' OR '1'='1",
          "<img src=x onerror=alert('XSS')>",
        ];

        for (final input in maliciousInputs) {
          // Check input safety
          expect(securityManager.isInputSafe(input), isFalse);

          // Sanitize input
          final sanitized = securityManager.sanitizeInput(input);
          expect(sanitized, isNot(contains('<script>')));
          expect(sanitized, isNot(contains('javascript:')));
          expect(sanitized, isNot(contains("'")));

          // Log security event
          securityManager.logSecurityEvent(
            eventType: 'malicious_input_detected',
            description: 'Malicious input detected and sanitized',
            metadata: {'original': input, 'sanitized': sanitized},
          );
        }
      });

      test('should handle rate limiting correctly', () {
        const endpoint = 'api/login';
        const maxRequests = 5;

        // Make requests within limit
        for (int i = 0; i < maxRequests; i++) {
          expect(
            securityManager.isRateLimited(endpoint, maxRequests: maxRequests),
            isFalse,
          );
        }

        // Next request should be rate limited
        expect(
          securityManager.isRateLimited(endpoint, maxRequests: maxRequests),
          isTrue,
        );

        // Log rate limiting event
        securityManager.logSecurityEvent(
          eventType: 'rate_limit_exceeded',
          description: 'Rate limit exceeded for endpoint',
          metadata: {'endpoint': endpoint, 'max_requests': maxRequests},
        );
      });

      test('should encrypt and decrypt sensitive data', () {
        final sensitiveData = [
          'Credit Card: 1234-5678-9012-3456',
          'SSN: 123-45-6789',
          'API Key: sk_test_1234567890abcdef',
          'Password: MySecretPassword123!',
        ];

        for (final data in sensitiveData) {
          // Encrypt data
          final encrypted = securityManager.encryptData(data);
          expect(encrypted, isNotEmpty);
          expect(encrypted, isNot(equals(data)));

          // Decrypt data
          final decrypted = securityManager.decryptData(encrypted);
          expect(decrypted, equals(data));

          // Log encryption event
          securityManager.logSecurityEvent(
            eventType: 'data_encrypted',
            description: 'Sensitive data encrypted',
            metadata: {'data_type': 'sensitive'},
          );
        }
      });

      test('should maintain security logs properly', () {
        // Generate various security events
        final events = [
          {'type': 'login_attempt', 'description': 'User login attempt'},
          {'type': 'password_change', 'description': 'Password changed'},
          {'type': 'session_expired', 'description': 'Session expired'},
          {
            'type': 'suspicious_activity',
            'description': 'Suspicious activity detected',
          },
          {'type': 'data_access', 'description': 'Sensitive data accessed'},
        ];

        for (final event in events) {
          securityManager.logSecurityEvent(
            eventType: event['type']!,
            description: event['description']!,
            metadata: {'timestamp': DateTime.now().toIso8601String()},
          );
        }

        final logs = securityManager.getSecurityLogs();
        expect(logs.length, equals(events.length));

        // Check log structure
        for (final log in logs) {
          expect(log, containsPair('type', isA<String>()));
          expect(log, containsPair('description', isA<String>()));
          expect(log, containsPair('timestamp', isA<String>()));
          expect(log, containsPair('metadata', isA<Map>()));
        }
      });

      test('should generate secure random values', () {
        final lengths = [8, 16, 32, 64];

        for (final length in lengths) {
          final random1 = securityManager.generateSecureRandomString(length);
          final random2 = securityManager.generateSecureRandomString(length);

          expect(random1.length, equals(length));
          expect(random2.length, equals(length));
          expect(random1, isNot(equals(random2)));

          // Check character set (alphanumeric)
          expect(RegExp(r'^[A-Za-z0-9]+$').hasMatch(random1), isTrue);
          expect(RegExp(r'^[A-Za-z0-9]+$').hasMatch(random2), isTrue);
        }
      });

      test('should clear security data completely', () {
        // Set up some security data
        final token = securityManager.generateSessionToken();
        securityManager.recordFailedAttempt('test@example.com');
        securityManager.logSecurityEvent(
          eventType: 'test',
          description: 'Test event',
        );

        // Verify data exists
        expect(securityManager.validateSession(token), isTrue);
        expect(securityManager.getSecurityLogs(), isNotEmpty);

        // Clear all data
        securityManager.clearSecurityData();

        // Verify data is cleared
        expect(securityManager.validateSession(token), isFalse);
        expect(securityManager.isAccountLocked('test@example.com'), isFalse);
        // Note: Security logs are not cleared by clearSecurityData
      });
    });
  });
}
