import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import '../../domain/entities/report_config.dart';

/// Service for generating reports in various formats
class ReportGenerationService {
  static const String _reportsDirectory = 'reports';

  /// Generate report based on configuration
  Future<GeneratedReport> generateReport({
    required ReportConfig config,
    Map<String, dynamic>? data,
  }) async {
    try {
      final reportData = await _collectReportData(config, data);
      final content = await _generateReportContent(config, reportData);
      final file = await _saveReportFile(config, content);

      return GeneratedReport(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        configId: config.id,
        fileName: _generateFileName(config),
        format: config.format,
        fileSizeBytes: content.length,
        generatedAt: DateTime.now(),
        generatedBy: config.createdBy,
        status: ReportStatus.completed,
        downloadUrl: file.path,
        metadata: {
          'recordCount': reportData['recordCount'] ?? 0,
          'generationTimeMs': DateTime.now().millisecondsSinceEpoch,
          'dataPoints': reportData['dataPoints'] ?? 0,
        },
      );
    } catch (e) {
      return GeneratedReport(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        configId: config.id,
        fileName: _generateFileName(config),
        format: config.format,
        fileSizeBytes: 0,
        generatedAt: DateTime.now(),
        generatedBy: config.createdBy,
        status: ReportStatus.failed,
        errorMessage: e.toString(),
      );
    }
  }

  /// Collect data for report generation
  Future<Map<String, dynamic>> _collectReportData(
    ReportConfig config,
    Map<String, dynamic>? providedData,
  ) async {
    final data = <String, dynamic>{};

    // Use provided data or generate mock data
    if (providedData != null) {
      data.addAll(providedData);
    } else {
      data.addAll(await _generateMockData(config));
    }

    // Apply filters
    if (config.filters.isNotEmpty) {
      data['filteredData'] = _applyFilters(data, config.filters);
    }

    // Calculate metrics
    data['calculatedMetrics'] = _calculateMetrics(data, config.metrics);

    // Group by dimensions
    if (config.dimensions.isNotEmpty) {
      data['groupedData'] = _groupByDimensions(data, config.dimensions);
    }

    return data;
  }

  /// Generate report content based on format
  Future<Uint8List> _generateReportContent(
    ReportConfig config,
    Map<String, dynamic> data,
  ) async {
    switch (config.format) {
      case ReportFormat.pdf:
        return await _generatePdfReport(config, data);
      case ReportFormat.csv:
        return await _generateCsvReport(config, data);
      case ReportFormat.excel:
        return await _generateExcelReport(config, data);
      case ReportFormat.json:
        return await _generateJsonReport(config, data);
    }
  }

  /// Generate PDF report
  Future<Uint8List> _generatePdfReport(
    ReportConfig config,
    Map<String, dynamic> data,
  ) async {
    // For now, return a simple text-based PDF content
    // In a real implementation, you would use a PDF library like pdf or printing
    final content = _generateTextReport(config, data);
    return Uint8List.fromList(utf8.encode(content));
  }

  /// Generate CSV report
  Future<Uint8List> _generateCsvReport(
    ReportConfig config,
    Map<String, dynamic> data,
  ) async {
    final buffer = StringBuffer();

    // Add header
    buffer.writeln('CareNow Analytics Report');
    buffer.writeln('Report: ${config.name}');
    buffer.writeln('Generated: ${DateTime.now().toIso8601String()}');
    buffer.writeln(
      'Period: ${config.startDate.toIso8601String()} to ${config.endDate.toIso8601String()}',
    );
    buffer.writeln('');

    // Add metrics data
    buffer.writeln('Metrics');
    buffer.writeln('Metric,Value');

    final metrics = data['calculatedMetrics'] as Map<String, dynamic>? ?? {};
    for (final entry in metrics.entries) {
      buffer.writeln('${entry.key},${entry.value}');
    }

    buffer.writeln('');

    // Add dimensional data if available
    if (data['groupedData'] != null) {
      buffer.writeln('Dimensional Analysis');
      final groupedData = data['groupedData'] as Map<String, dynamic>;

      for (final dimension in config.dimensions) {
        if (groupedData.containsKey(dimension)) {
          buffer.writeln('');
          buffer.writeln('$dimension Analysis');
          buffer.writeln('$dimension,Count,Value');

          final dimensionData = groupedData[dimension] as Map<String, dynamic>;
          for (final entry in dimensionData.entries) {
            final value = entry.value as Map<String, dynamic>;
            buffer.writeln('${entry.key},${value['count']},${value['total']}');
          }
        }
      }
    }

    return Uint8List.fromList(utf8.encode(buffer.toString()));
  }

  /// Generate Excel report
  Future<Uint8List> _generateExcelReport(
    ReportConfig config,
    Map<String, dynamic> data,
  ) async {
    // For now, return CSV format
    // In a real implementation, you would use a library like excel
    return await _generateCsvReport(config, data);
  }

  /// Generate JSON report
  Future<Uint8List> _generateJsonReport(
    ReportConfig config,
    Map<String, dynamic> data,
  ) async {
    final reportJson = {
      'report': {
        'config': {
          'name': config.name,
          'description': config.description,
          'type': config.type.name,
          'format': config.format.name,
          'startDate': config.startDate.toIso8601String(),
          'endDate': config.endDate.toIso8601String(),
          'metrics': config.metrics,
          'dimensions': config.dimensions,
        },
        'data': data,
        'generatedAt': DateTime.now().toIso8601String(),
      },
    };

    return Uint8List.fromList(utf8.encode(jsonEncode(reportJson)));
  }

  /// Generate text-based report content
  String _generateTextReport(ReportConfig config, Map<String, dynamic> data) {
    final buffer = StringBuffer();

    buffer.writeln('CareNow Analytics Report');
    buffer.writeln('=' * 50);
    buffer.writeln('Report Name: ${config.name}');
    buffer.writeln('Description: ${config.description}');
    buffer.writeln('Type: ${config.type.displayName}');
    buffer.writeln(
      'Period: ${_formatDate(config.startDate)} to ${_formatDate(config.endDate)}',
    );
    buffer.writeln('Generated: ${_formatDate(DateTime.now())}');
    buffer.writeln('');

    // Add metrics
    buffer.writeln('Key Metrics');
    buffer.writeln('-' * 20);
    final metrics = data['calculatedMetrics'] as Map<String, dynamic>? ?? {};
    for (final entry in metrics.entries) {
      buffer.writeln('${entry.key}: ${_formatValue(entry.value)}');
    }
    buffer.writeln('');

    // Add dimensional analysis
    if (data['groupedData'] != null) {
      buffer.writeln('Dimensional Analysis');
      buffer.writeln('-' * 30);
      final groupedData = data['groupedData'] as Map<String, dynamic>;

      for (final dimension in config.dimensions) {
        if (groupedData.containsKey(dimension)) {
          buffer.writeln('');
          buffer.writeln('By $dimension:');
          final dimensionData = groupedData[dimension] as Map<String, dynamic>;
          for (final entry in dimensionData.entries) {
            final value = entry.value as Map<String, dynamic>;
            buffer.writeln(
              '  ${entry.key}: ${value['count']} items, ${_formatValue(value['total'])} total',
            );
          }
        }
      }
    }

    return buffer.toString();
  }

  /// Save report file to local storage
  Future<File> _saveReportFile(ReportConfig config, Uint8List content) async {
    final directory = await getApplicationDocumentsDirectory();
    final reportsDir = Directory('${directory.path}/$_reportsDirectory');

    if (!await reportsDir.exists()) {
      await reportsDir.create(recursive: true);
    }

    final fileName = _generateFileName(config);
    final file = File('${reportsDir.path}/$fileName');

    return await file.writeAsBytes(content);
  }

  /// Generate file name for report
  String _generateFileName(ReportConfig config) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final sanitizedName = config.name
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(' ', '_');
    return '${sanitizedName}_$timestamp.${config.format.fileExtension}';
  }

  /// Generate mock data for testing
  Future<Map<String, dynamic>> _generateMockData(ReportConfig config) async {
    final data = <String, dynamic>{};

    switch (config.type) {
      case ReportType.revenue:
        data.addAll(_generateMockRevenueData(config));
        break;
      case ReportType.users:
        data.addAll(_generateMockUserData(config));
        break;
      case ReportType.partners:
        data.addAll(_generateMockPartnerData(config));
        break;
      case ReportType.bookings:
        data.addAll(_generateMockBookingData(config));
        break;
      case ReportType.overview:
      case ReportType.performance:
      case ReportType.custom:
        data.addAll(_generateMockOverviewData(config));
        break;
    }

    data['recordCount'] = data['rawData']?.length ?? 0;
    data['dataPoints'] = config.metrics.length * (data['recordCount'] as int);

    return data;
  }

  /// Generate mock revenue data
  Map<String, dynamic> _generateMockRevenueData(ReportConfig config) {
    final days = config.endDate.difference(config.startDate).inDays;
    final rawData = <Map<String, dynamic>>[];

    for (int i = 0; i < days; i++) {
      final date = config.startDate.add(Duration(days: i));
      rawData.add({
        'date': date.toIso8601String(),
        'revenue': 1000 + (i * 50) + (i % 7 * 200),
        'transactions': 20 + (i % 10),
        'service': [
          'Home Cleaning',
          'Plumbing',
          'Electrical',
          'Gardening',
        ][i % 4],
        'region': ['Ho Chi Minh City', 'Hanoi', 'Da Nang'][i % 3],
      });
    }

    return {'rawData': rawData};
  }

  /// Generate mock user data
  Map<String, dynamic> _generateMockUserData(ReportConfig config) {
    final days = config.endDate.difference(config.startDate).inDays;
    final rawData = <Map<String, dynamic>>[];

    for (int i = 0; i < days; i++) {
      final date = config.startDate.add(Duration(days: i));
      rawData.add({
        'date': date.toIso8601String(),
        'newUsers': 10 + (i % 5),
        'activeUsers': 100 + (i * 2),
        'sessions': 150 + (i * 3),
        'region': ['Ho Chi Minh City', 'Hanoi', 'Da Nang'][i % 3],
        'ageGroup': ['18-25', '26-35', '36-45', '46+'][i % 4],
      });
    }

    return {'rawData': rawData};
  }

  /// Generate mock partner data
  Map<String, dynamic> _generateMockPartnerData(ReportConfig config) {
    final rawData = <Map<String, dynamic>>[];

    for (int i = 0; i < 50; i++) {
      rawData.add({
        'partnerId': 'partner_$i',
        'name': 'Partner $i',
        'rating': 3.5 + (i % 15) * 0.1,
        'completedJobs': 10 + (i * 2),
        'earnings': 500 + (i * 100),
        'service': [
          'Home Cleaning',
          'Plumbing',
          'Electrical',
          'Gardening',
        ][i % 4],
        'region': ['Ho Chi Minh City', 'Hanoi', 'Da Nang'][i % 3],
        'joinDate': DateTime.now()
            .subtract(Duration(days: i * 10))
            .toIso8601String(),
      });
    }

    return {'rawData': rawData};
  }

  /// Generate mock booking data
  Map<String, dynamic> _generateMockBookingData(ReportConfig config) {
    final days = config.endDate.difference(config.startDate).inDays;
    final rawData = <Map<String, dynamic>>[];

    for (int i = 0; i < days * 5; i++) {
      final date = config.startDate.add(Duration(days: i ~/ 5));
      rawData.add({
        'bookingId': 'booking_$i',
        'date': date.toIso8601String(),
        'status': ['completed', 'cancelled', 'in_progress'][i % 3],
        'value': 50 + (i % 20) * 10,
        'service': [
          'Home Cleaning',
          'Plumbing',
          'Electrical',
          'Gardening',
        ][i % 4],
        'region': ['Ho Chi Minh City', 'Hanoi', 'Da Nang'][i % 3],
        'duration': 60 + (i % 10) * 30,
      });
    }

    return {'rawData': rawData};
  }

  /// Generate mock overview data
  Map<String, dynamic> _generateMockOverviewData(ReportConfig config) {
    return {
      'rawData': [
        {'metric': 'totalUsers', 'value': 12450},
        {'metric': 'totalPartners', 'value': 1250},
        {'metric': 'totalBookings', 'value': 8920},
        {'metric': 'totalRevenue', 'value': 125000},
        {'metric': 'averageRating', 'value': 4.3},
        {'metric': 'completionRate', 'value': 87.5},
      ],
    };
  }

  /// Apply filters to data
  Map<String, dynamic> _applyFilters(
    Map<String, dynamic> data,
    List<ReportFilter> filters,
  ) {
    final rawData = data['rawData'] as List<Map<String, dynamic>>? ?? [];
    var filteredData = rawData;

    for (final filter in filters) {
      filteredData = filteredData.where((item) {
        final value = item[filter.field];
        return _matchesFilter(value, filter);
      }).toList();
    }

    return {'rawData': filteredData};
  }

  /// Check if value matches filter
  bool _matchesFilter(dynamic value, ReportFilter filter) {
    switch (filter.operator) {
      case FilterOperator.equals:
        return value == filter.value;
      case FilterOperator.notEquals:
        return value != filter.value;
      case FilterOperator.greaterThan:
        return (value as num) > (filter.value as num);
      case FilterOperator.lessThan:
        return (value as num) < (filter.value as num);
      case FilterOperator.greaterThanOrEqual:
        return (value as num) >= (filter.value as num);
      case FilterOperator.lessThanOrEqual:
        return (value as num) <= (filter.value as num);
      case FilterOperator.contains:
        return value.toString().contains(filter.value.toString());
      case FilterOperator.notContains:
        return !value.toString().contains(filter.value.toString());
      case FilterOperator.startsWith:
        return value.toString().startsWith(filter.value.toString());
      case FilterOperator.endsWith:
        return value.toString().endsWith(filter.value.toString());
      case FilterOperator.inList:
        return (filter.value as List).contains(value);
      case FilterOperator.notInList:
        return !(filter.value as List).contains(value);
      case FilterOperator.between:
        final range = filter.value as List;
        if (range.length != 2) return false;
        final numValue = value as num;
        final min = range[0] as num;
        final max = range[1] as num;
        return numValue >= min && numValue <= max;
    }
  }

  /// Calculate metrics from data
  Map<String, dynamic> _calculateMetrics(
    Map<String, dynamic> data,
    List<String> metrics,
  ) {
    final rawData = data['rawData'] as List<Map<String, dynamic>>? ?? [];
    final calculatedMetrics = <String, dynamic>{};

    for (final metric in metrics) {
      calculatedMetrics[metric] = _calculateMetric(rawData, metric);
    }

    return calculatedMetrics;
  }

  /// Calculate individual metric
  dynamic _calculateMetric(List<Map<String, dynamic>> data, String metric) {
    if (data.isEmpty) return 0;

    switch (metric) {
      case 'totalRevenue':
        return data.fold<double>(
          0,
          (sum, item) => sum + ((item['revenue'] as num?)?.toDouble() ?? 0),
        );
      case 'totalUsers':
        return data.fold<int>(
          0,
          (sum, item) => sum + ((item['newUsers'] as int?) ?? 0),
        );
      case 'totalBookings':
        return data.length;
      case 'averageRating':
        final ratings = data
            .map((item) => (item['rating'] as num?)?.toDouble() ?? 0)
            .where((r) => r > 0);
        return ratings.isNotEmpty
            ? ratings.reduce((a, b) => a + b) / ratings.length
            : 0;
      case 'completionRate':
        final completed = data
            .where((item) => item['status'] == 'completed')
            .length;
        return data.isNotEmpty ? (completed / data.length) * 100 : 0;
      default:
        return data.length;
    }
  }

  /// Group data by dimensions
  Map<String, dynamic> _groupByDimensions(
    Map<String, dynamic> data,
    List<String> dimensions,
  ) {
    final rawData = data['rawData'] as List<Map<String, dynamic>>? ?? [];
    final groupedData = <String, dynamic>{};

    for (final dimension in dimensions) {
      groupedData[dimension] = _groupByDimension(rawData, dimension);
    }

    return groupedData;
  }

  /// Group data by single dimension
  Map<String, dynamic> _groupByDimension(
    List<Map<String, dynamic>> data,
    String dimension,
  ) {
    final grouped = <String, Map<String, dynamic>>{};

    for (final item in data) {
      final key = item[dimension]?.toString() ?? 'Unknown';
      if (!grouped.containsKey(key)) {
        grouped[key] = {'count': 0, 'total': 0.0};
      }

      grouped[key]!['count'] = (grouped[key]!['count'] as int) + 1;
      final value = (item['revenue'] ?? item['value'] ?? 1) as num;
      grouped[key]!['total'] =
          (grouped[key]!['total'] as double) + value.toDouble();
    }

    return grouped;
  }

  /// Format date for display
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Format value for display
  String _formatValue(dynamic value) {
    if (value is double) {
      return value.toStringAsFixed(2);
    }
    return value.toString();
  }
}
