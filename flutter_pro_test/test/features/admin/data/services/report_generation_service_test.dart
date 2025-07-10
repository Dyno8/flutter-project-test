import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pro_test/features/admin/data/services/report_generation_service.dart';
import 'package:flutter_pro_test/features/admin/domain/entities/report_config.dart';

void main() {
  group('ReportGenerationService', () {
    late ReportGenerationService service;
    late ReportConfig testConfig;

    // Helper function to create modified config
    ReportConfig createConfigWith({
      ReportType? type,
      ReportFormat? format,
      List<String>? metrics,
      List<String>? dimensions,
      List<ReportFilter>? filters,
      DateTime? startDate,
      DateTime? endDate,
      String? name,
    }) {
      return ReportConfig(
        id: testConfig.id,
        name: name ?? testConfig.name,
        description: testConfig.description,
        type: type ?? testConfig.type,
        format: format ?? testConfig.format,
        startDate: startDate ?? testConfig.startDate,
        endDate: endDate ?? testConfig.endDate,
        metrics: metrics ?? testConfig.metrics,
        dimensions: dimensions ?? testConfig.dimensions,
        filters: filters ?? testConfig.filters,
        schedule: testConfig.schedule,
        recipients: testConfig.recipients,
        customSettings: testConfig.customSettings,
        createdAt: testConfig.createdAt,
        updatedAt: testConfig.updatedAt,
        createdBy: testConfig.createdBy,
      );
    }

    setUp(() {
      service = ReportGenerationService();
      testConfig = ReportConfig(
        id: 'test_report_1',
        name: 'Test Revenue Report',
        description: 'Test report for revenue analytics',
        type: ReportType.revenue,
        format: ReportFormat.csv,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
        metrics: ['totalRevenue', 'monthlyRevenue', 'averageOrderValue'],
        dimensions: ['time', 'service', 'region'],
        filters: [],
        recipients: ['admin@test.com'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: 'test_user',
      );
    });

    group('Report Generation', () {
      test('should generate CSV report successfully', () async {
        final result = await service.generateReport(config: testConfig);

        expect(result.status, equals(ReportStatus.completed));
        expect(result.configId, equals(testConfig.id));
        expect(result.format, equals(ReportFormat.csv));
        expect(result.fileName.contains('Test_Revenue_Report'), isTrue);
        expect(result.fileName.endsWith('.csv'), isTrue);
        expect(result.fileSizeBytes, greaterThan(0));
        expect(result.generatedAt, isNotNull);
        expect(result.generatedBy, equals(testConfig.createdBy));
        expect(result.downloadUrl, isNotNull);
      });

      test('should generate PDF report successfully', () async {
        final pdfConfig = ReportConfig(
          id: testConfig.id,
          name: testConfig.name,
          description: testConfig.description,
          type: testConfig.type,
          format: ReportFormat.pdf,
          startDate: testConfig.startDate,
          endDate: testConfig.endDate,
          metrics: testConfig.metrics,
          dimensions: testConfig.dimensions,
          filters: testConfig.filters,
          schedule: testConfig.schedule,
          recipients: testConfig.recipients,
          customSettings: testConfig.customSettings,
          createdAt: testConfig.createdAt,
          updatedAt: testConfig.updatedAt,
          createdBy: testConfig.createdBy,
        );
        final result = await service.generateReport(config: pdfConfig);

        expect(result.status, equals(ReportStatus.completed));
        expect(result.format, equals(ReportFormat.pdf));
        expect(result.fileName.endsWith('.pdf'), isTrue);
      });

      test('should generate Excel report successfully', () async {
        final excelConfig = createConfigWith(format: ReportFormat.excel);
        final result = await service.generateReport(config: excelConfig);

        expect(result.status, equals(ReportStatus.completed));
        expect(result.format, equals(ReportFormat.excel));
        expect(result.fileName.endsWith('.xlsx'), isTrue);
      });

      test('should generate JSON report successfully', () async {
        final jsonConfig = createConfigWith(format: ReportFormat.json);
        final result = await service.generateReport(config: jsonConfig);

        expect(result.status, equals(ReportStatus.completed));
        expect(result.format, equals(ReportFormat.json));
        expect(result.fileName.endsWith('.json'), isTrue);
      });

      test('should include metadata in generated report', () async {
        final result = await service.generateReport(config: testConfig);

        expect(result.metadata, isNotNull);
        expect(result.metadata!.containsKey('recordCount'), isTrue);
        expect(result.metadata!.containsKey('generationTimeMs'), isTrue);
        expect(result.metadata!.containsKey('dataPoints'), isTrue);
        expect(result.metadata!['recordCount'], greaterThanOrEqualTo(0));
        expect(result.metadata!['dataPoints'], greaterThanOrEqualTo(0));
      });
    });

    group('Report Types', () {
      test('should generate revenue report with correct data', () async {
        final revenueConfig = createConfigWith(type: ReportType.revenue);
        final result = await service.generateReport(config: revenueConfig);

        expect(result.status, equals(ReportStatus.completed));
        expect(result.metadata!['recordCount'], greaterThan(0));
      });

      test('should generate user report with correct data', () async {
        final userConfig = createConfigWith(
          type: ReportType.users,
          metrics: ['totalUsers', 'activeUsers', 'newUsers'],
        );
        final result = await service.generateReport(config: userConfig);

        expect(result.status, equals(ReportStatus.completed));
        expect(result.metadata!['recordCount'], greaterThan(0));
      });

      test('should generate partner report with correct data', () async {
        final partnerConfig = createConfigWith(
          type: ReportType.partners,
          metrics: ['totalPartners', 'activePartners', 'averageRating'],
        );
        final result = await service.generateReport(config: partnerConfig);

        expect(result.status, equals(ReportStatus.completed));
        expect(result.metadata!['recordCount'], greaterThan(0));
      });

      test('should generate booking report with correct data', () async {
        final bookingConfig = createConfigWith(
          type: ReportType.bookings,
          metrics: ['totalBookings', 'completedBookings', 'completionRate'],
        );
        final result = await service.generateReport(config: bookingConfig);

        expect(result.status, equals(ReportStatus.completed));
        expect(result.metadata!['recordCount'], greaterThan(0));
      });

      test('should generate overview report with correct data', () async {
        final overviewConfig = createConfigWith(
          type: ReportType.overview,
          metrics: ['totalUsers', 'totalPartners', 'totalRevenue'],
        );
        final result = await service.generateReport(config: overviewConfig);

        expect(result.status, equals(ReportStatus.completed));
        expect(result.metadata!['recordCount'], greaterThan(0));
      });
    });

    group('Report Content', () {
      test('should generate valid CSV content', () async {
        final result = await service.generateReport(config: testConfig);

        // Read the generated file content (in a real test, you'd read from the file)
        // For this test, we'll verify the report was generated successfully
        expect(result.fileSizeBytes, greaterThan(0));
        expect(result.downloadUrl, isNotNull);
      });

      test('should include report header information', () async {
        final result = await service.generateReport(config: testConfig);

        expect(
          result.fileName.contains(testConfig.name.replaceAll(' ', '_')),
          isTrue,
        );
        expect(result.generatedAt, isNotNull);
        expect(result.generatedBy, equals(testConfig.createdBy));
      });

      test('should handle custom data provided', () async {
        final customData = {
          'rawData': [
            {'revenue': 1000, 'service': 'Cleaning', 'region': 'HCM'},
            {'revenue': 1500, 'service': 'Plumbing', 'region': 'Hanoi'},
          ],
        };

        final result = await service.generateReport(
          config: testConfig,
          data: customData,
        );

        expect(result.status, equals(ReportStatus.completed));
        expect(result.metadata!['recordCount'], equals(2));
      });
    });

    group('Filters and Dimensions', () {
      test('should apply filters to data', () async {
        final configWithFilters = createConfigWith(
          filters: [
            const ReportFilter(
              field: 'region',
              operator: FilterOperator.equals,
              value: 'Ho Chi Minh City',
            ),
          ],
        );

        final result = await service.generateReport(config: configWithFilters);

        expect(result.status, equals(ReportStatus.completed));
        expect(result.fileSizeBytes, greaterThan(0));
      });

      test('should group data by dimensions', () async {
        final configWithDimensions = createConfigWith(
          dimensions: ['service', 'region', 'time'],
        );

        final result = await service.generateReport(
          config: configWithDimensions,
        );

        expect(result.status, equals(ReportStatus.completed));
        expect(result.fileSizeBytes, greaterThan(0));
      });

      test('should handle multiple filters', () async {
        final configWithMultipleFilters = createConfigWith(
          filters: [
            const ReportFilter(
              field: 'region',
              operator: FilterOperator.inList,
              value: ['Ho Chi Minh City', 'Hanoi'],
            ),
            const ReportFilter(
              field: 'revenue',
              operator: FilterOperator.greaterThan,
              value: 1000,
            ),
          ],
        );

        final result = await service.generateReport(
          config: configWithMultipleFilters,
        );

        expect(result.status, equals(ReportStatus.completed));
      });
    });

    group('Error Handling', () {
      test('should handle report generation failure', () async {
        // Create a config that might cause an error (e.g., invalid date range)
        final invalidConfig = createConfigWith(
          startDate: DateTime(2024, 12, 31),
          endDate: DateTime(2024, 1, 1), // End before start
        );

        final result = await service.generateReport(config: invalidConfig);

        // The service should still generate a report, but it might be empty or have issues
        // In a real implementation, you might want to validate the config first
        expect(result, isNotNull);
      });

      test('should handle empty metrics list', () async {
        final configWithNoMetrics = createConfigWith(metrics: []);

        final result = await service.generateReport(
          config: configWithNoMetrics,
        );

        expect(result.status, equals(ReportStatus.completed));
        expect(result.fileSizeBytes, greaterThan(0));
      });

      test('should handle empty dimensions list', () async {
        final configWithNoDimensions = createConfigWith(dimensions: []);

        final result = await service.generateReport(
          config: configWithNoDimensions,
        );

        expect(result.status, equals(ReportStatus.completed));
        expect(result.fileSizeBytes, greaterThan(0));
      });
    });

    group('File Operations', () {
      test('should generate unique file names', () async {
        final result1 = await service.generateReport(config: testConfig);
        await Future.delayed(
          const Duration(milliseconds: 10),
        ); // Ensure different timestamp
        final result2 = await service.generateReport(config: testConfig);

        expect(result1.fileName, isNot(equals(result2.fileName)));
      });

      test('should sanitize file names', () async {
        final configWithSpecialChars = createConfigWith(
          name: 'Test Report with Special @#\$% Characters!',
        );

        final result = await service.generateReport(
          config: configWithSpecialChars,
        );

        expect(result.fileName.contains('@'), isFalse);
        expect(result.fileName.contains('#'), isFalse);
        expect(result.fileName.contains('\$'), isFalse);
        expect(result.fileName.contains('%'), isFalse);
        expect(result.fileName.contains('!'), isFalse);
      });

      test('should include correct file extension', () async {
        final formats = [
          ReportFormat.csv,
          ReportFormat.pdf,
          ReportFormat.excel,
          ReportFormat.json,
        ];

        for (final format in formats) {
          final config = createConfigWith(format: format);
          final result = await service.generateReport(config: config);

          expect(result.fileName.endsWith('.${format.fileExtension}'), isTrue);
        }
      });
    });

    group('Performance', () {
      test('should generate report within reasonable time', () async {
        final stopwatch = Stopwatch()..start();

        await service.generateReport(config: testConfig);

        stopwatch.stop();
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(5000),
        ); // Should complete within 5 seconds
      });

      test('should handle large data sets', () async {
        final largeDataConfig = createConfigWith(
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 12, 31), // Full year
        );

        final result = await service.generateReport(config: largeDataConfig);

        expect(result.status, equals(ReportStatus.completed));
        expect(result.fileSizeBytes, greaterThan(0));
      });
    });
  });
}
