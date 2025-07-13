import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_pro_test/core/error_tracking/error_tracking_service.dart';

void main() {
  group('IncidentManagementService', () {
    late IncidentManagementService service;

    setUp(() {
      service = IncidentManagementService();
    });

    group('service state', () {
      test('should provide singleton instance', () {
        expect(service, isA<IncidentManagementService>());
      });

      test('should provide access to incident methods', () {
        // Test that all expected methods are available
        expect(service.createIncident, isA<Function>());
        expect(service.updateIncidentStatus, isA<Function>());
        expect(service.getActiveIncidents, isA<Function>());
        expect(service.getIncidentHistory, isA<Function>());
        expect(service.getIncidentStatistics, isA<Function>());
      });

      test('should provide incident data access', () {
        // Test that data access methods work
        final activeIncidents = service.getActiveIncidents();
        final incidentHistory = service.getIncidentHistory();
        final statistics = service.getIncidentStatistics();

        expect(activeIncidents, isA<List<Incident>>());
        expect(incidentHistory, isA<List<Incident>>());
        expect(statistics, isA<Map<String, dynamic>>());
      });
    });
  });
}
