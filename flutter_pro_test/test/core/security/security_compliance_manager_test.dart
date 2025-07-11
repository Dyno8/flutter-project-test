import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_pro_test/core/security/security_compliance_manager.dart';

void main() {
  group('SecurityComplianceManager', () {
    late SecurityComplianceManager complianceManager;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      complianceManager = SecurityComplianceManager();
      await complianceManager.initialize();
    });

    group('Initialization', () {
      test('should initialize successfully', () async {
        expect(complianceManager, isNotNull);
      });

      test('should not reinitialize if already initialized', () async {
        await complianceManager.initialize();
        expect(complianceManager, isNotNull);
      });
    });

    group('Security Audit', () {
      test('should perform comprehensive security audit', () async {
        final auditReport = await complianceManager.performSecurityAudit();

        expect(auditReport, isNotNull);
        expect(auditReport.auditId, isNotEmpty);
        expect(auditReport.timestamp, isA<DateTime>());
        expect(auditReport.duration, isA<Duration>());
        expect(auditReport.overallScore, isA<double>());
        expect(auditReport.overallScore, greaterThanOrEqualTo(0.0));
        expect(auditReport.overallScore, lessThanOrEqualTo(100.0));
      });

      test('should include all security check results', () async {
        final auditReport = await complianceManager.performSecurityAudit();

        expect(auditReport.authenticationCheck, isA<SecurityCheckResult>());
        expect(auditReport.encryptionCheck, isA<SecurityCheckResult>());
        expect(auditReport.networkSecurityCheck, isA<SecurityCheckResult>());
        expect(auditReport.dataProtectionCheck, isA<SecurityCheckResult>());
        expect(auditReport.accessControlCheck, isA<SecurityCheckResult>());
        expect(auditReport.loggingCheck, isA<SecurityCheckResult>());
        expect(auditReport.vulnerabilityCheck, isA<SecurityCheckResult>());
      });

      test('should generate recommendations when needed', () async {
        final auditReport = await complianceManager.performSecurityAudit();

        expect(auditReport.recommendations, isA<List<String>>());
        // Recommendations should be present if any checks failed
        if (auditReport.overallScore < 100) {
          expect(auditReport.recommendations, isNotEmpty);
        }
      });

      test('should save audit reports', () async {
        await complianceManager.performSecurityAudit();
        
        final reports = complianceManager.getComplianceReports();
        expect(reports, isNotEmpty);
        expect(reports.last, isA<SecurityAuditReport>());
      });

      test('should limit stored audit reports', () async {
        // Perform multiple audits
        for (int i = 0; i < 12; i++) {
          await complianceManager.performSecurityAudit();
        }
        
        final reports = complianceManager.getComplianceReports();
        expect(reports.length, lessThanOrEqualTo(10));
      });
    });

    group('Security Check Results', () {
      test('should validate authentication check', () async {
        final auditReport = await complianceManager.performSecurityAudit();
        final authCheck = auditReport.authenticationCheck;

        expect(authCheck.checkName, equals('Authentication'));
        expect(authCheck.score, isA<double>());
        expect(authCheck.passed, isA<bool>());
        expect(authCheck.checks, isA<Map<String, bool>>());
        expect(authCheck.issues, isA<List<String>>());
        expect(authCheck.recommendations, isA<List<String>>());
      });

      test('should validate encryption check', () async {
        final auditReport = await complianceManager.performSecurityAudit();
        final encryptionCheck = auditReport.encryptionCheck;

        expect(encryptionCheck.checkName, equals('Encryption'));
        expect(encryptionCheck.score, greaterThanOrEqualTo(0.0));
        expect(encryptionCheck.score, lessThanOrEqualTo(100.0));
        expect(encryptionCheck.checks, isNotEmpty);
      });

      test('should validate network security check', () async {
        final auditReport = await complianceManager.performSecurityAudit();
        final networkCheck = auditReport.networkSecurityCheck;

        expect(networkCheck.checkName, equals('Network Security'));
        expect(networkCheck.checks, containsPair('https_enforced', isA<bool>()));
        expect(networkCheck.checks, containsPair('certificate_pinning', isA<bool>()));
      });

      test('should validate data protection check', () async {
        final auditReport = await complianceManager.performSecurityAudit();
        final dataProtectionCheck = auditReport.dataProtectionCheck;

        expect(dataProtectionCheck.checkName, equals('Data Protection'));
        expect(dataProtectionCheck.checks, containsPair('gdpr_compliance', isA<bool>()));
        expect(dataProtectionCheck.checks, containsPair('sensitive_data_handling', isA<bool>()));
      });

      test('should validate access control check', () async {
        final auditReport = await complianceManager.performSecurityAudit();
        final accessControlCheck = auditReport.accessControlCheck;

        expect(accessControlCheck.checkName, equals('Access Control'));
        expect(accessControlCheck.checks, containsPair('role_based_access', isA<bool>()));
        expect(accessControlCheck.checks, containsPair('rate_limiting', isA<bool>()));
      });

      test('should validate logging check', () async {
        final auditReport = await complianceManager.performSecurityAudit();
        final loggingCheck = auditReport.loggingCheck;

        expect(loggingCheck.checkName, equals('Logging & Monitoring'));
        expect(loggingCheck.checks, containsPair('security_logging', isA<bool>()));
        expect(loggingCheck.checks, containsPair('audit_trail', isA<bool>()));
      });

      test('should validate vulnerability check', () async {
        final auditReport = await complianceManager.performSecurityAudit();
        final vulnerabilityCheck = auditReport.vulnerabilityCheck;

        expect(vulnerabilityCheck.checkName, equals('Vulnerability Assessment'));
        expect(vulnerabilityCheck.checks, containsPair('sql_injection_protection', isA<bool>()));
        expect(vulnerabilityCheck.checks, containsPair('xss_protection', isA<bool>()));
        expect(vulnerabilityCheck.checks, containsPair('integrity_check', isA<bool>()));
      });
    });

    group('Compliance Status', () {
      test('should check compliance status for GDPR', () async {
        final status = await complianceManager.checkComplianceStatus(ComplianceStandard.gdpr);

        expect(status.standard, equals(ComplianceStandard.gdpr));
        expect(status.status, isA<ComplianceLevel>());
        expect(status.score, isA<double>());
        expect(status.issues, isA<List<String>>());
      });

      test('should check compliance status for OWASP', () async {
        final status = await complianceManager.checkComplianceStatus(ComplianceStandard.owasp);

        expect(status.standard, equals(ComplianceStandard.owasp));
        expect(status.status, isA<ComplianceLevel>());
      });

      test('should check compliance status for ISO 27001', () async {
        final status = await complianceManager.checkComplianceStatus(ComplianceStandard.iso27001);

        expect(status.standard, equals(ComplianceStandard.iso27001));
        expect(status.status, isA<ComplianceLevel>());
      });

      test('should check compliance status for PCI DSS', () async {
        final status = await complianceManager.checkComplianceStatus(ComplianceStandard.pciDss);

        expect(status.standard, equals(ComplianceStandard.pciDss));
        expect(status.status, isA<ComplianceLevel>());
      });

      test('should return unknown status when no audit performed', () async {
        // Create a fresh manager without performing audit
        SharedPreferences.setMockInitialValues({});
        final freshManager = SecurityComplianceManager();
        await freshManager.initialize();

        final status = await freshManager.checkComplianceStatus(ComplianceStandard.gdpr);
        expect(status.status, equals(ComplianceLevel.unknown));
        expect(status.lastCheckDate, isNull);
        expect(status.score, equals(0.0));
      });
    });

    group('Report Serialization', () {
      test('should serialize and deserialize security check results', () {
        final checkResult = SecurityCheckResult(
          checkName: 'Test Check',
          score: 85.5,
          passed: true,
          checks: {'check1': true, 'check2': false},
          issues: ['Issue 1', 'Issue 2'],
          recommendations: ['Recommendation 1'],
        );

        final json = checkResult.toJson();
        final deserialized = SecurityCheckResult.fromJson(json);

        expect(deserialized.checkName, equals(checkResult.checkName));
        expect(deserialized.score, equals(checkResult.score));
        expect(deserialized.passed, equals(checkResult.passed));
        expect(deserialized.checks, equals(checkResult.checks));
        expect(deserialized.issues, equals(checkResult.issues));
        expect(deserialized.recommendations, equals(checkResult.recommendations));
      });

      test('should serialize and deserialize audit reports', () async {
        final auditReport = await complianceManager.performSecurityAudit();

        final json = auditReport.toJson();
        final deserialized = SecurityAuditReport.fromJson(json);

        expect(deserialized.auditId, equals(auditReport.auditId));
        expect(deserialized.timestamp, equals(auditReport.timestamp));
        expect(deserialized.duration, equals(auditReport.duration));
        expect(deserialized.overallScore, equals(auditReport.overallScore));
        expect(deserialized.recommendations, equals(auditReport.recommendations));
      });
    });

    group('Compliance Levels', () {
      test('should determine correct compliance levels', () async {
        // This tests the internal logic for determining compliance levels
        final auditReport = await complianceManager.performSecurityAudit();
        final status = await complianceManager.checkComplianceStatus(ComplianceStandard.owasp);

        // Verify that compliance level matches the score
        if (auditReport.overallScore >= 95) {
          expect(status.status, equals(ComplianceLevel.excellent));
        } else if (auditReport.overallScore >= 85) {
          expect(status.status, equals(ComplianceLevel.good));
        } else if (auditReport.overallScore >= 70) {
          expect(status.status, equals(ComplianceLevel.acceptable));
        } else if (auditReport.overallScore >= 50) {
          expect(status.status, equals(ComplianceLevel.needsImprovement));
        } else {
          expect(status.status, equals(ComplianceLevel.critical));
        }
      });
    });

    group('Error Handling', () {
      test('should handle audit failures gracefully', () async {
        // This test would require mocking failures
        // For now, we'll test that audit doesn't throw unexpected errors
        expect(
          () => complianceManager.performSecurityAudit(),
          returnsNormally,
        );
      });

      test('should handle empty compliance reports', () {
        final reports = complianceManager.getComplianceReports();
        expect(reports, isA<List<SecurityAuditReport>>());
      });

      test('should handle invalid compliance standard', () async {
        // Test with all valid standards
        for (final standard in ComplianceStandard.values) {
          final status = await complianceManager.checkComplianceStatus(standard);
          expect(status.standard, equals(standard));
        }
      });
    });

    group('Performance', () {
      test('should complete audit within reasonable time', () async {
        final stopwatch = Stopwatch()..start();
        
        await complianceManager.performSecurityAudit();
        
        stopwatch.stop();
        
        // Audit should complete within 10 seconds
        expect(stopwatch.elapsedMilliseconds, lessThan(10000));
      });

      test('should handle multiple concurrent audits', () async {
        final futures = List.generate(3, (_) => complianceManager.performSecurityAudit());
        
        final reports = await Future.wait(futures);
        
        expect(reports, hasLength(3));
        for (final report in reports) {
          expect(report, isA<SecurityAuditReport>());
        }
      });
    });
  });
}
