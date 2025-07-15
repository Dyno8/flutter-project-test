import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/analytics/business_metrics_validator.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../../../shared/widgets/loading_widget.dart';

/// Widget for displaying business metrics validation results
class BusinessMetricsValidationWidget extends StatefulWidget {
  final BusinessMetricsValidator validator;

  const BusinessMetricsValidationWidget({
    super.key,
    required this.validator,
  });

  @override
  State<BusinessMetricsValidationWidget> createState() => _BusinessMetricsValidationWidgetState();
}

class _BusinessMetricsValidationWidgetState extends State<BusinessMetricsValidationWidget> {
  ValidationResult? _latestValidation;
  bool _isLoading = false;
  bool _isRunningValidation = false;

  @override
  void initState() {
    super.initState();
    _loadValidationData();
  }

  Future<void> _loadValidationData() async {
    setState(() => _isLoading = true);
    
    try {
      _latestValidation = widget.validator.getLatestValidation();
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to load validation data: $e');
    }
  }

  Future<void> _runManualValidation() async {
    if (_isRunningValidation) return;

    setState(() => _isRunningValidation = true);

    try {
      final result = await widget.validator.performManualValidation();
      setState(() {
        _latestValidation = result;
        _isRunningValidation = false;
      });

      _showSuccessSnackBar('Validation completed successfully');
    } catch (e) {
      setState(() => _isRunningValidation = false);
      _showErrorSnackBar('Validation failed: $e');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingWidget();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        SizedBox(height: 16.h),
        if (_latestValidation != null) ...[
          _buildValidationSummary(),
          SizedBox(height: 16.h),
          _buildValidationChecks(),
          SizedBox(height: 16.h),
          _buildRecommendations(),
        ] else
          _buildNoValidationData(),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Text(
          'Business Metrics Validation',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        ElevatedButton.icon(
          onPressed: _isRunningValidation ? null : _runManualValidation,
          icon: _isRunningValidation
              ? SizedBox(
                  width: 16.w,
                  height: 16.h,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(Icons.play_arrow, size: 18.sp),
          label: Text(_isRunningValidation ? 'Running...' : 'Run Validation'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildValidationSummary() {
    final validation = _latestValidation!;
    final statusColor = _getStatusColor(validation.status);

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  _getStatusIcon(validation.status),
                  color: statusColor,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overall Score: ${validation.overallScore.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Status: ${validation.status.name.toUpperCase()}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Validation ID',
                  validation.validationId.substring(0, 12) + '...',
                  Icons.fingerprint,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Duration',
                  '${validation.duration.inMilliseconds}ms',
                  Icons.timer,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Timestamp',
                  _formatTimestamp(validation.timestamp),
                  Icons.schedule,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Checks',
                  '${validation.checks.length}',
                  Icons.checklist,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: AppColors.textSecondary),
        SizedBox(width: 8.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildValidationChecks() {
    final validation = _latestValidation!;

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Validation Checks',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          ...validation.checks.entries.map((entry) => _buildCheckItem(entry.value)),
        ],
      ),
    );
  }

  Widget _buildCheckItem(ValidationCheck check) {
    final statusColor = check.passed ? AppColors.success : AppColors.error;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: statusColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                check.passed ? Icons.check_circle : Icons.error,
                color: statusColor,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  check.checkName,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  '${check.score.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          if (check.issues.isNotEmpty) ...[
            SizedBox(height: 8.h),
            ...check.issues.map((issue) => Padding(
              padding: EdgeInsets.only(left: 28.w, bottom: 4.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning,
                    color: AppColors.warning,
                    size: 14.sp,
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Text(
                      issue,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildRecommendations() {
    final validation = _latestValidation!;

    if (validation.recommendations.isEmpty) {
      return const SizedBox.shrink();
    }

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: AppColors.warning,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Recommendations',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ...validation.recommendations.map((recommendation) => Container(
            margin: EdgeInsets.only(bottom: 8.h),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.arrow_right,
                  color: AppColors.warning,
                  size: 16.sp,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    recommendation,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildNoValidationData() {
    return CustomCard(
      child: Column(
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 48.sp,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 16.h),
          Text(
            'No Validation Data',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Run your first validation to see metrics analysis',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          ElevatedButton.icon(
            onPressed: _runManualValidation,
            icon: Icon(Icons.play_arrow, size: 18.sp),
            label: const Text('Run First Validation'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(ValidationStatus status) {
    switch (status) {
      case ValidationStatus.passed:
        return AppColors.success;
      case ValidationStatus.warning:
        return AppColors.warning;
      case ValidationStatus.failed:
        return AppColors.error;
    }
  }

  IconData _getStatusIcon(ValidationStatus status) {
    switch (status) {
      case ValidationStatus.passed:
        return Icons.check_circle;
      case ValidationStatus.warning:
        return Icons.warning;
      case ValidationStatus.failed:
        return Icons.error;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}
