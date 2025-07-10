import 'package:equatable/equatable.dart';

/// Report configuration entity for customizable analytics reports
class ReportConfig extends Equatable {
  final String id;
  final String name;
  final String description;
  final ReportType type;
  final ReportFormat format;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> metrics;
  final List<String> dimensions;
  final List<ReportFilter> filters;
  final ReportSchedule? schedule;
  final List<String> recipients;
  final Map<String, dynamic> customSettings;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;

  const ReportConfig({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.format,
    required this.startDate,
    required this.endDate,
    required this.metrics,
    required this.dimensions,
    required this.filters,
    this.schedule,
    required this.recipients,
    this.customSettings = const {},
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
  });

  /// Check if report is scheduled
  bool get isScheduled => schedule != null;

  /// Get report period in days
  int get periodInDays => endDate.difference(startDate).inDays;

  /// Check if report includes specific metric
  bool includesMetric(String metric) => metrics.contains(metric);

  /// Check if report includes specific dimension
  bool includesDimension(String dimension) => dimensions.contains(dimension);

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        type,
        format,
        startDate,
        endDate,
        metrics,
        dimensions,
        filters,
        schedule,
        recipients,
        customSettings,
        createdAt,
        updatedAt,
        createdBy,
      ];
}

/// Report types available in the system
enum ReportType {
  overview,
  revenue,
  bookings,
  users,
  partners,
  performance,
  custom;

  String get displayName {
    switch (this) {
      case ReportType.overview:
        return 'Overview Report';
      case ReportType.revenue:
        return 'Revenue Report';
      case ReportType.bookings:
        return 'Bookings Report';
      case ReportType.users:
        return 'Users Report';
      case ReportType.partners:
        return 'Partners Report';
      case ReportType.performance:
        return 'Performance Report';
      case ReportType.custom:
        return 'Custom Report';
    }
  }

  String get description {
    switch (this) {
      case ReportType.overview:
        return 'Comprehensive overview of all key metrics';
      case ReportType.revenue:
        return 'Detailed revenue and financial analytics';
      case ReportType.bookings:
        return 'Booking trends and service analytics';
      case ReportType.users:
        return 'User behavior and engagement metrics';
      case ReportType.partners:
        return 'Partner performance and quality metrics';
      case ReportType.performance:
        return 'System performance and operational metrics';
      case ReportType.custom:
        return 'Customizable report with selected metrics';
    }
  }
}

/// Report output formats
enum ReportFormat {
  pdf,
  csv,
  excel,
  json;

  String get displayName {
    switch (this) {
      case ReportFormat.pdf:
        return 'PDF Document';
      case ReportFormat.csv:
        return 'CSV File';
      case ReportFormat.excel:
        return 'Excel Spreadsheet';
      case ReportFormat.json:
        return 'JSON Data';
    }
  }

  String get fileExtension {
    switch (this) {
      case ReportFormat.pdf:
        return '.pdf';
      case ReportFormat.csv:
        return '.csv';
      case ReportFormat.excel:
        return '.xlsx';
      case ReportFormat.json:
        return '.json';
    }
  }

  String get mimeType {
    switch (this) {
      case ReportFormat.pdf:
        return 'application/pdf';
      case ReportFormat.csv:
        return 'text/csv';
      case ReportFormat.excel:
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case ReportFormat.json:
        return 'application/json';
    }
  }
}

/// Report filter for data filtering
class ReportFilter extends Equatable {
  final String field;
  final FilterOperator operator;
  final dynamic value;
  final String? displayName;

  const ReportFilter({
    required this.field,
    required this.operator,
    required this.value,
    this.displayName,
  });

  String get filterDisplayName => displayName ?? field;

  @override
  List<Object?> get props => [
        field,
        operator,
        value,
        displayName,
      ];
}

/// Filter operators for report filtering
enum FilterOperator {
  equals,
  notEquals,
  greaterThan,
  lessThan,
  greaterThanOrEqual,
  lessThanOrEqual,
  contains,
  notContains,
  startsWith,
  endsWith,
  inList,
  notInList,
  between;

  String get displayName {
    switch (this) {
      case FilterOperator.equals:
        return 'Equals';
      case FilterOperator.notEquals:
        return 'Not Equals';
      case FilterOperator.greaterThan:
        return 'Greater Than';
      case FilterOperator.lessThan:
        return 'Less Than';
      case FilterOperator.greaterThanOrEqual:
        return 'Greater Than or Equal';
      case FilterOperator.lessThanOrEqual:
        return 'Less Than or Equal';
      case FilterOperator.contains:
        return 'Contains';
      case FilterOperator.notContains:
        return 'Does Not Contain';
      case FilterOperator.startsWith:
        return 'Starts With';
      case FilterOperator.endsWith:
        return 'Ends With';
      case FilterOperator.inList:
        return 'In List';
      case FilterOperator.notInList:
        return 'Not In List';
      case FilterOperator.between:
        return 'Between';
    }
  }

  String get symbol {
    switch (this) {
      case FilterOperator.equals:
        return '=';
      case FilterOperator.notEquals:
        return '≠';
      case FilterOperator.greaterThan:
        return '>';
      case FilterOperator.lessThan:
        return '<';
      case FilterOperator.greaterThanOrEqual:
        return '≥';
      case FilterOperator.lessThanOrEqual:
        return '≤';
      case FilterOperator.contains:
        return '⊃';
      case FilterOperator.notContains:
        return '⊅';
      case FilterOperator.startsWith:
        return '⊃*';
      case FilterOperator.endsWith:
        return '*⊃';
      case FilterOperator.inList:
        return '∈';
      case FilterOperator.notInList:
        return '∉';
      case FilterOperator.between:
        return '⟷';
    }
  }
}

/// Report scheduling configuration
class ReportSchedule extends Equatable {
  final ScheduleFrequency frequency;
  final int interval;
  final List<int> daysOfWeek;
  final int dayOfMonth;
  final String timeOfDay;
  final String timezone;
  final DateTime? nextRunDate;
  final DateTime? lastRunDate;
  final bool isActive;

  const ReportSchedule({
    required this.frequency,
    this.interval = 1,
    this.daysOfWeek = const [],
    this.dayOfMonth = 1,
    required this.timeOfDay,
    required this.timezone,
    this.nextRunDate,
    this.lastRunDate,
    this.isActive = true,
  });

  String get scheduleDescription {
    switch (frequency) {
      case ScheduleFrequency.daily:
        return interval == 1 
            ? 'Daily at $timeOfDay'
            : 'Every $interval days at $timeOfDay';
      case ScheduleFrequency.weekly:
        final dayNames = daysOfWeek.map((day) => _getDayName(day)).join(', ');
        return 'Weekly on $dayNames at $timeOfDay';
      case ScheduleFrequency.monthly:
        return 'Monthly on day $dayOfMonth at $timeOfDay';
      case ScheduleFrequency.quarterly:
        return 'Quarterly on day $dayOfMonth at $timeOfDay';
      case ScheduleFrequency.yearly:
        return 'Yearly on day $dayOfMonth at $timeOfDay';
    }
  }

  String _getDayName(int day) {
    const dayNames = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 
      'Friday', 'Saturday', 'Sunday'
    ];
    return dayNames[day - 1];
  }

  @override
  List<Object?> get props => [
        frequency,
        interval,
        daysOfWeek,
        dayOfMonth,
        timeOfDay,
        timezone,
        nextRunDate,
        lastRunDate,
        isActive,
      ];
}

/// Schedule frequency options
enum ScheduleFrequency {
  daily,
  weekly,
  monthly,
  quarterly,
  yearly;

  String get displayName {
    switch (this) {
      case ScheduleFrequency.daily:
        return 'Daily';
      case ScheduleFrequency.weekly:
        return 'Weekly';
      case ScheduleFrequency.monthly:
        return 'Monthly';
      case ScheduleFrequency.quarterly:
        return 'Quarterly';
      case ScheduleFrequency.yearly:
        return 'Yearly';
    }
  }
}

/// Generated report metadata
class GeneratedReport extends Equatable {
  final String id;
  final String configId;
  final String fileName;
  final ReportFormat format;
  final int fileSizeBytes;
  final DateTime generatedAt;
  final String generatedBy;
  final ReportStatus status;
  final String? downloadUrl;
  final String? errorMessage;
  final Map<String, dynamic> metadata;

  const GeneratedReport({
    required this.id,
    required this.configId,
    required this.fileName,
    required this.format,
    required this.fileSizeBytes,
    required this.generatedAt,
    required this.generatedBy,
    required this.status,
    this.downloadUrl,
    this.errorMessage,
    this.metadata = const {},
  });

  String get fileSizeFormatted {
    if (fileSizeBytes < 1024) return '$fileSizeBytes B';
    if (fileSizeBytes < 1024 * 1024) return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  bool get isReady => status == ReportStatus.completed && downloadUrl != null;
  bool get hasFailed => status == ReportStatus.failed;

  @override
  List<Object?> get props => [
        id,
        configId,
        fileName,
        format,
        fileSizeBytes,
        generatedAt,
        generatedBy,
        status,
        downloadUrl,
        errorMessage,
        metadata,
      ];
}

/// Report generation status
enum ReportStatus {
  pending,
  generating,
  completed,
  failed;

  String get displayName {
    switch (this) {
      case ReportStatus.pending:
        return 'Pending';
      case ReportStatus.generating:
        return 'Generating';
      case ReportStatus.completed:
        return 'Completed';
      case ReportStatus.failed:
        return 'Failed';
    }
  }
}
