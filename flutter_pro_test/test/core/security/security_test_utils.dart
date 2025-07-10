import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pro_test/core/security/security_manager.dart';

/// Security testing utilities and test cases
class SecurityTestUtils {
  static final SecurityManager _securityManager = SecurityManager();

  /// Test SQL injection patterns
  static void testSqlInjectionProtection() {
    group('SQL Injection Protection', () {
      final maliciousInputs = [
        "'; DROP TABLE users; --",
        "1' OR '1'='1",
        "admin'--",
        "' UNION SELECT * FROM users --",
        "1; DELETE FROM users WHERE 1=1; --",
        "' OR 1=1 /*",
        "1' AND (SELECT COUNT(*) FROM users) > 0 --",
      ];

      for (final input in maliciousInputs) {
        test('should detect SQL injection in: $input', () {
          expect(_securityManager.isInputSafe(input), isFalse);
        });
      }

      final safeInputs = [
        "john.doe@example.com",
        "Valid User Name",
        "123456",
        "Normal text input",
        "",
      ];

      for (final input in safeInputs) {
        test('should allow safe input: $input', () {
          expect(_securityManager.isInputSafe(input), isTrue);
        });
      }
    });
  }

  /// Test XSS protection
  static void testXssProtection() {
    group('XSS Protection', () {
      final xssInputs = [
        "<script>alert('XSS')</script>",
        "javascript:alert('XSS')",
        "<img src=x onerror=alert('XSS')>",
        "<svg onload=alert('XSS')>",
        "vbscript:msgbox('XSS')",
        "<iframe src=javascript:alert('XSS')></iframe>",
      ];

      for (final input in xssInputs) {
        test('should sanitize XSS input: $input', () {
          final sanitized = _securityManager.sanitizeInput(input);
          expect(sanitized, isNot(contains('<')));
          expect(sanitized, isNot(contains('>')));
          expect(sanitized, isNot(contains('javascript:')));
          expect(sanitized, isNot(contains('vbscript:')));
        });
      }
    });
  }

  /// Test password security requirements
  static void testPasswordSecurity() {
    group('Password Security', () {
      final weakPasswords = [
        "123456",
        "password",
        "abc123",
        "Password",
        "12345678",
        "PASSWORD123",
        "password123",
      ];

      for (final password in weakPasswords) {
        test('should reject weak password: $password', () {
          expect(_securityManager.isPasswordSecure(password), isFalse);
        });
      }

      final strongPasswords = [
        "MyStr0ng!Pass",
        "C0mpl3x@P4ssw0rd",
        "S3cur3#P@ssw0rd!",
        "Adm1n!2023@Secure",
      ];

      for (final password in strongPasswords) {
        test('should accept strong password: $password', () {
          expect(_securityManager.isPasswordSecure(password), isTrue);
        });
      }
    });
  }

  /// Test session management
  static void testSessionManagement() {
    group('Session Management', () {
      test('should generate unique session tokens', () {
        final token1 = _securityManager.generateSessionToken();
        final token2 = _securityManager.generateSessionToken();

        expect(token1, isNotEmpty);
        expect(token2, isNotEmpty);
        expect(token1, isNot(equals(token2)));
      });

      test('should validate current session token', () {
        final token = _securityManager.generateSessionToken();
        expect(_securityManager.validateSession(token), isTrue);
      });

      test('should reject invalid session token', () {
        expect(_securityManager.validateSession('invalid-token'), isFalse);
        expect(_securityManager.validateSession(null), isFalse);
        expect(_securityManager.validateSession(''), isFalse);
      });

      test('should invalidate session', () {
        final token = _securityManager.generateSessionToken();
        expect(_securityManager.validateSession(token), isTrue);

        _securityManager.invalidateSession();
        expect(_securityManager.validateSession(token), isFalse);
      });
    });
  }

  /// Test account lockout mechanism
  static void testAccountLockout() {
    group('Account Lockout', () {
      const testUser = 'test@example.com';

      setUp(() {
        _securityManager.clearFailedAttempts(testUser);
      });

      test('should not be locked initially', () {
        expect(_securityManager.isAccountLocked(testUser), isFalse);
      });

      test('should lock account after max failed attempts', () {
        // Record maximum failed attempts
        for (int i = 0; i < SecurityManager.maxFailedAttempts; i++) {
          _securityManager.recordFailedAttempt(testUser);
        }

        expect(_securityManager.isAccountLocked(testUser), isTrue);
      });

      test('should clear failed attempts on successful login', () {
        // Record some failed attempts
        for (int i = 0; i < 3; i++) {
          _securityManager.recordFailedAttempt(testUser);
        }

        _securityManager.clearFailedAttempts(testUser);
        expect(_securityManager.isAccountLocked(testUser), isFalse);
      });

      test('should return remaining lockout time', () {
        // Lock the account
        for (int i = 0; i < SecurityManager.maxFailedAttempts; i++) {
          _securityManager.recordFailedAttempt(testUser);
        }

        final remainingTime = _securityManager.getRemainingLockoutTime(
          testUser,
        );
        expect(remainingTime, greaterThan(0));
        expect(
          remainingTime,
          lessThanOrEqualTo(SecurityManager.lockoutDurationMinutes),
        );
      });
    });
  }

  /// Test data encryption
  static void testDataEncryption() {
    group('Data Encryption', () {
      test('should encrypt and decrypt data correctly', () {
        const originalData = 'Sensitive information';

        final encrypted = _securityManager.encryptData(originalData);
        expect(encrypted, isNotEmpty);
        expect(encrypted, isNot(equals(originalData)));

        final decrypted = _securityManager.decryptData(encrypted);
        expect(decrypted, equals(originalData));
      });

      test('should handle empty data', () {
        const originalData = '';

        final encrypted = _securityManager.encryptData(originalData);
        final decrypted = _securityManager.decryptData(encrypted);
        expect(decrypted, equals(originalData));
      });

      test('should generate unique salts', () {
        final salt1 = _securityManager.generateSalt();
        final salt2 = _securityManager.generateSalt();

        expect(salt1, isNotEmpty);
        expect(salt2, isNotEmpty);
        expect(salt1, isNot(equals(salt2)));
      });

      test('should hash passwords with salt', () {
        const password = 'testPassword123';
        final salt = _securityManager.generateSalt();

        final hash1 = _securityManager.hashPassword(password, salt);
        final hash2 = _securityManager.hashPassword(password, salt);

        expect(hash1, equals(hash2)); // Same password + salt = same hash
        expect(hash1, isNotEmpty);
        expect(hash1, isNot(equals(password)));
      });
    });
  }

  /// Test rate limiting
  static void testRateLimiting() {
    group('Rate Limiting', () {
      const endpoint = 'test_endpoint';

      test('should allow requests within limit', () {
        for (int i = 0; i < 5; i++) {
          expect(
            _securityManager.isRateLimited(endpoint, maxRequests: 10),
            isFalse,
          );
        }
      });

      test('should block requests exceeding limit', () {
        // Make requests up to the limit
        for (int i = 0; i < 10; i++) {
          _securityManager.isRateLimited(endpoint, maxRequests: 10);
        }

        // Next request should be rate limited
        expect(
          _securityManager.isRateLimited(endpoint, maxRequests: 10),
          isTrue,
        );
      });
    });
  }

  /// Test security logging
  static void testSecurityLogging() {
    group('Security Logging', () {
      test('should log security events', () {
        _securityManager.logSecurityEvent(
          eventType: 'test_event',
          description: 'Test security event',
          metadata: {'test': 'data'},
        );

        final logs = _securityManager.getSecurityLogs();
        expect(logs, isNotEmpty);

        final lastLog = logs.last;
        expect(lastLog['type'], equals('test_event'));
        expect(lastLog['description'], equals('Test security event'));
        expect(lastLog['metadata']['test'], equals('data'));
      });

      test('should maintain log size limit', () {
        // Generate many logs
        for (int i = 0; i < 150; i++) {
          _securityManager.logSecurityEvent(
            eventType: 'bulk_test',
            description: 'Bulk test event $i',
          );
        }

        final logs = _securityManager.getSecurityLogs();
        expect(logs.length, lessThanOrEqualTo(100)); // Should be limited
      });
    });
  }

  /// Test secure random generation
  static void testSecureRandomGeneration() {
    group('Secure Random Generation', () {
      test('should generate random strings of specified length', () {
        final random1 = _securityManager.generateSecureRandomString(16);
        final random2 = _securityManager.generateSecureRandomString(16);

        expect(random1.length, equals(16));
        expect(random2.length, equals(16));
        expect(random1, isNot(equals(random2)));
      });

      test('should generate different lengths correctly', () {
        final short = _securityManager.generateSecureRandomString(8);
        final long = _securityManager.generateSecureRandomString(32);

        expect(short.length, equals(8));
        expect(long.length, equals(32));
      });
    });
  }

  /// Run all security tests
  static void runAllSecurityTests() {
    group('Security Manager Tests', () {
      testSqlInjectionProtection();
      testXssProtection();
      testPasswordSecurity();
      testSessionManagement();
      testAccountLockout();
      testDataEncryption();
      testRateLimiting();
      testSecurityLogging();
      testSecureRandomGeneration();
    });
  }
}
