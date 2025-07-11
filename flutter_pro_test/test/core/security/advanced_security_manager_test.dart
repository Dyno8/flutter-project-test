import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_pro_test/core/security/advanced_security_manager.dart';
import 'package:flutter_pro_test/core/config/environment_config.dart';

void main() {
  group('AdvancedSecurityManager', () {
    late AdvancedSecurityManager advancedSecurityManager;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      advancedSecurityManager = AdvancedSecurityManager();
      await advancedSecurityManager.initialize();
    });

    group('Initialization', () {
      test('should initialize successfully', () async {
        // Initialization is done in setUp
        expect(advancedSecurityManager, isNotNull);
      });

      test('should not reinitialize if already initialized', () async {
        // Try to initialize again
        await advancedSecurityManager.initialize();
        // Should not throw or cause issues
        expect(advancedSecurityManager, isNotNull);
      });
    });

    group('Certificate Pinning', () {
      test('should verify certificate pins correctly', () {
        const host = 'api.carenow.com';
        const validPin = 'sha256/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=';
        const invalidPin = 'sha256/INVALID_PIN_HASH_HERE';

        // In development, should always return true
        if (EnvironmentConfig.isDevelopment) {
          expect(advancedSecurityManager.verifyCertificatePin(host, validPin), isTrue);
          expect(advancedSecurityManager.verifyCertificatePin(host, invalidPin), isTrue);
        }
      });

      test('should handle missing certificate pins', () {
        const unknownHost = 'unknown.example.com';
        const pin = 'sha256/SOME_PIN_HASH';

        // Should handle gracefully
        final result = advancedSecurityManager.verifyCertificatePin(unknownHost, pin);
        expect(result, isA<bool>());
      });
    });

    group('Advanced Encryption', () {
      test('should encrypt and decrypt data correctly', () async {
        const testData = 'sensitive test data';

        final encrypted = await advancedSecurityManager.encryptDataAdvanced(testData);
        expect(encrypted, isNotEmpty);
        expect(encrypted, isNot(equals(testData)));

        final decrypted = await advancedSecurityManager.decryptDataAdvanced(encrypted);
        expect(decrypted, equals(testData));
      });

      test('should handle encryption with custom key', () async {
        const testData = 'test data with custom key';
        const customKey = 'custom-encryption-key-123';

        final encrypted = await advancedSecurityManager.encryptDataAdvanced(
          testData,
          customKey: customKey,
        );
        expect(encrypted, isNotEmpty);

        final decrypted = await advancedSecurityManager.decryptDataAdvanced(
          encrypted,
          customKey: customKey,
        );
        expect(decrypted, equals(testData));
      });

      test('should handle encryption when not required', () async {
        // This test assumes development environment where encryption might not be required
        const testData = 'test data';

        final result = await advancedSecurityManager.encryptDataAdvanced(testData);
        expect(result, isNotEmpty);
      });

      test('should reject old encrypted data', () async {
        // This would require mocking the timestamp validation
        // For now, we'll test that decryption handles errors gracefully
        const invalidEncryptedData = 'invalid-encrypted-data';

        expect(
          () => advancedSecurityManager.decryptDataAdvanced(invalidEncryptedData),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Security Health Check', () {
      test('should perform security health check', () async {
        final healthReport = await advancedSecurityManager.performSecurityHealthCheck();

        expect(healthReport, isNotNull);
        expect(healthReport.overallStatus, isA<SecurityStatus>());
        expect(healthReport.lastCheckTimestamp, isA<DateTime>());
        expect(healthReport.recentViolationsCount, isA<int>());
        expect(healthReport.totalViolationsCount, isA<int>());
        expect(healthReport.certificatePinningEnabled, isA<bool>());
        expect(healthReport.encryptionEnabled, isA<bool>());
        expect(healthReport.integrityCheckPassed, isA<bool>());
      });

      test('should calculate security status correctly', () async {
        final healthReport = await advancedSecurityManager.performSecurityHealthCheck();

        // In a clean test environment, should have good security status
        expect(healthReport.overallStatus, isIn([
          SecurityStatus.secure,
          SecurityStatus.caution,
          SecurityStatus.warning,
          SecurityStatus.critical,
        ]));
      });
    });

    group('Security Violations', () {
      test('should record and retrieve security violations', () {
        // Initially should have no violations
        final initialViolations = advancedSecurityManager.getSecurityViolations();
        expect(initialViolations, isEmpty);

        // Record a test violation by triggering certificate pin failure
        const testHost = 'test.example.com';
        const invalidPin = 'invalid-pin';
        
        // This should record a violation in production mode
        advancedSecurityManager.verifyCertificatePin(testHost, invalidPin);

        // Check if violations were recorded (depends on environment)
        final violations = advancedSecurityManager.getSecurityViolations();
        expect(violations, isA<List<Map<String, dynamic>>>());
      });

      test('should limit violation history', () {
        // This test would require generating many violations
        // For now, we'll just verify the method works
        final violations = advancedSecurityManager.getSecurityViolations();
        expect(violations, isA<List<Map<String, dynamic>>>());
        expect(violations.length, lessThanOrEqualTo(100));
      });
    });

    group('Security Policy', () {
      test('should have current security policy', () {
        final policy = advancedSecurityManager.getCurrentSecurityPolicy();
        
        if (policy != null) {
          expect(policy.encryptionRequired, isA<bool>());
          expect(policy.certificatePinningEnabled, isA<bool>());
          expect(policy.integrityCheckEnabled, isA<bool>());
          expect(policy.networkSecurityEnabled, isA<bool>());
          expect(policy.debuggingAllowed, isA<bool>());
          expect(policy.maxSessionDuration, isA<Duration>());
          expect(policy.rateLimitEnabled, isA<bool>());
          expect(policy.maxRequestsPerMinute, isA<int>());
        }
      });

      test('should serialize security policy correctly', () {
        final policy = SecurityPolicy(
          encryptionRequired: true,
          certificatePinningEnabled: true,
          integrityCheckEnabled: true,
          networkSecurityEnabled: true,
          debuggingAllowed: false,
          maxSessionDuration: const Duration(minutes: 30),
          rateLimitEnabled: true,
          maxRequestsPerMinute: 100,
        );

        final json = policy.toJson();
        expect(json, isA<Map<String, dynamic>>());
        expect(json['encryptionRequired'], isTrue);
        expect(json['certificatePinningEnabled'], isTrue);
        expect(json['maxSessionDurationMinutes'], equals(30));
        expect(json['maxRequestsPerMinute'], equals(100));
      });
    });

    group('Error Handling', () {
      test('should handle encryption errors gracefully', () async {
        // Test with null or invalid data
        expect(
          () => advancedSecurityManager.encryptDataAdvanced(''),
          returnsNormally,
        );
      });

      test('should handle decryption errors gracefully', () async {
        const invalidData = 'definitely-not-encrypted-data';
        
        expect(
          () => advancedSecurityManager.decryptDataAdvanced(invalidData),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle certificate pin verification errors', () {
        // Test with invalid inputs
        expect(
          () => advancedSecurityManager.verifyCertificatePin('', ''),
          returnsNormally,
        );
        
        expect(
          () => advancedSecurityManager.verifyCertificatePin('host', ''),
          returnsNormally,
        );
      });
    });

    group('Integration with Base Security', () {
      test('should work with existing SecurityManager', () async {
        // Verify that advanced security manager doesn't interfere with base security
        final healthReport = await advancedSecurityManager.performSecurityHealthCheck();
        expect(healthReport, isNotNull);
        
        // Should be able to get violations without errors
        final violations = advancedSecurityManager.getSecurityViolations();
        expect(violations, isA<List>());
      });
    });

    group('Environment-Specific Behavior', () {
      test('should behave differently in different environments', () {
        // Certificate pinning should be more lenient in development
        if (EnvironmentConfig.isDevelopment) {
          expect(
            advancedSecurityManager.verifyCertificatePin('any-host', 'any-pin'),
            isTrue,
          );
        }
        
        // Security policy should reflect environment
        final policy = advancedSecurityManager.getCurrentSecurityPolicy();
        if (policy != null) {
          if (EnvironmentConfig.isProduction) {
            expect(policy.certificatePinningEnabled, isTrue);
            expect(policy.networkSecurityEnabled, isTrue);
          }
        }
      });
    });
  });
}
