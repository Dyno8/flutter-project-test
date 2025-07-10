import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/report_config.dart';
import '../repositories/analytics_repository.dart';

/// Use case for generating analytics reports
class GenerateReport implements UseCase<GeneratedReport, GenerateReportParams> {
  final AnalyticsRepository repository;

  GenerateReport(this.repository);

  @override
  Future<Either<Failure, GeneratedReport>> call(
    GenerateReportParams params,
  ) async {
    return await repository.generateReport(
      config: params.config,
      customData: params.customData,
    );
  }
}

/// Parameters for GenerateReport use case
class GenerateReportParams {
  final ReportConfig config;
  final Map<String, dynamic>? customData;

  const GenerateReportParams({required this.config, this.customData});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GenerateReportParams &&
          runtimeType == other.runtimeType &&
          config == other.config &&
          customData == other.customData;

  @override
  int get hashCode => config.hashCode ^ customData.hashCode;

  @override
  String toString() {
    return 'GenerateReportParams{config: $config, customData: $customData}';
  }
}

/// Use case for getting report configurations
class GetReportConfigs implements UseCase<List<ReportConfig>, NoParams> {
  final AnalyticsRepository repository;

  GetReportConfigs(this.repository);

  @override
  Future<Either<Failure, List<ReportConfig>>> call(NoParams params) async {
    return await repository.getReportConfigs();
  }
}

/// Use case for creating report configuration
class CreateReportConfig
    implements UseCase<ReportConfig, CreateReportConfigParams> {
  final AnalyticsRepository repository;

  CreateReportConfig(this.repository);

  @override
  Future<Either<Failure, ReportConfig>> call(
    CreateReportConfigParams params,
  ) async {
    return await repository.createReportConfig(
      name: params.name,
      description: params.description,
      type: params.type,
      format: params.format,
      startDate: params.startDate,
      endDate: params.endDate,
      metrics: params.metrics,
      dimensions: params.dimensions,
      filters: params.filters,
      schedule: params.schedule,
      recipients: params.recipients,
      customSettings: params.customSettings,
    );
  }
}

/// Parameters for CreateReportConfig use case
class CreateReportConfigParams {
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

  const CreateReportConfigParams({
    required this.name,
    required this.description,
    required this.type,
    required this.format,
    required this.startDate,
    required this.endDate,
    required this.metrics,
    required this.dimensions,
    this.filters = const [],
    this.schedule,
    this.recipients = const [],
    this.customSettings = const {},
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateReportConfigParams &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          description == other.description &&
          type == other.type &&
          format == other.format &&
          startDate == other.startDate &&
          endDate == other.endDate &&
          metrics == other.metrics &&
          dimensions == other.dimensions &&
          filters == other.filters &&
          schedule == other.schedule &&
          recipients == other.recipients &&
          customSettings == other.customSettings;

  @override
  int get hashCode =>
      name.hashCode ^
      description.hashCode ^
      type.hashCode ^
      format.hashCode ^
      startDate.hashCode ^
      endDate.hashCode ^
      metrics.hashCode ^
      dimensions.hashCode ^
      filters.hashCode ^
      schedule.hashCode ^
      recipients.hashCode ^
      customSettings.hashCode;

  @override
  String toString() {
    return 'CreateReportConfigParams{name: $name, description: $description, type: $type, format: $format, startDate: $startDate, endDate: $endDate, metrics: $metrics, dimensions: $dimensions, filters: $filters, schedule: $schedule, recipients: $recipients, customSettings: $customSettings}';
  }
}

/// Use case for updating report configuration
class UpdateReportConfig
    implements UseCase<ReportConfig, UpdateReportConfigParams> {
  final AnalyticsRepository repository;

  UpdateReportConfig(this.repository);

  @override
  Future<Either<Failure, ReportConfig>> call(
    UpdateReportConfigParams params,
  ) async {
    return await repository.updateReportConfig(
      id: params.id,
      name: params.name,
      description: params.description,
      type: params.type,
      format: params.format,
      startDate: params.startDate,
      endDate: params.endDate,
      metrics: params.metrics,
      dimensions: params.dimensions,
      filters: params.filters,
      schedule: params.schedule,
      recipients: params.recipients,
      customSettings: params.customSettings,
    );
  }
}

/// Parameters for UpdateReportConfig use case
class UpdateReportConfigParams {
  final String id;
  final String? name;
  final String? description;
  final ReportType? type;
  final ReportFormat? format;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String>? metrics;
  final List<String>? dimensions;
  final List<ReportFilter>? filters;
  final ReportSchedule? schedule;
  final List<String>? recipients;
  final Map<String, dynamic>? customSettings;

  const UpdateReportConfigParams({
    required this.id,
    this.name,
    this.description,
    this.type,
    this.format,
    this.startDate,
    this.endDate,
    this.metrics,
    this.dimensions,
    this.filters,
    this.schedule,
    this.recipients,
    this.customSettings,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateReportConfigParams &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          type == other.type &&
          format == other.format &&
          startDate == other.startDate &&
          endDate == other.endDate &&
          metrics == other.metrics &&
          dimensions == other.dimensions &&
          filters == other.filters &&
          schedule == other.schedule &&
          recipients == other.recipients &&
          customSettings == other.customSettings;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      description.hashCode ^
      type.hashCode ^
      format.hashCode ^
      startDate.hashCode ^
      endDate.hashCode ^
      metrics.hashCode ^
      dimensions.hashCode ^
      filters.hashCode ^
      schedule.hashCode ^
      recipients.hashCode ^
      customSettings.hashCode;

  @override
  String toString() {
    return 'UpdateReportConfigParams{id: $id, name: $name, description: $description, type: $type, format: $format, startDate: $startDate, endDate: $endDate, metrics: $metrics, dimensions: $dimensions, filters: $filters, schedule: $schedule, recipients: $recipients, customSettings: $customSettings}';
  }
}

/// Use case for deleting report configuration
class DeleteReportConfig implements UseCase<void, DeleteReportConfigParams> {
  final AnalyticsRepository repository;

  DeleteReportConfig(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteReportConfigParams params) async {
    return await repository.deleteReportConfig(params.id);
  }
}

/// Parameters for DeleteReportConfig use case
class DeleteReportConfigParams {
  final String id;

  const DeleteReportConfigParams({required this.id});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeleteReportConfigParams &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'DeleteReportConfigParams{id: $id}';
  }
}

/// Use case for getting generated reports
class GetGeneratedReports
    implements UseCase<List<GeneratedReport>, GetGeneratedReportsParams> {
  final AnalyticsRepository repository;

  GetGeneratedReports(this.repository);

  @override
  Future<Either<Failure, List<GeneratedReport>>> call(
    GetGeneratedReportsParams params,
  ) async {
    return await repository.getGeneratedReports(
      configId: params.configId,
      limit: params.limit,
      offset: params.offset,
    );
  }
}

/// Parameters for GetGeneratedReports use case
class GetGeneratedReportsParams {
  final String? configId;
  final int limit;
  final int offset;

  const GetGeneratedReportsParams({
    this.configId,
    this.limit = 20,
    this.offset = 0,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GetGeneratedReportsParams &&
          runtimeType == other.runtimeType &&
          configId == other.configId &&
          limit == other.limit &&
          offset == other.offset;

  @override
  int get hashCode => configId.hashCode ^ limit.hashCode ^ offset.hashCode;

  @override
  String toString() {
    return 'GetGeneratedReportsParams{configId: $configId, limit: $limit, offset: $offset}';
  }
}
