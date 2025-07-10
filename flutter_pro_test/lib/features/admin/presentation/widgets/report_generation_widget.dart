import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../domain/entities/report_config.dart';
import '../../data/models/report_config_model.dart';

/// Widget for generating and managing analytics reports
class ReportGenerationWidget extends StatefulWidget {
  final Function(ReportConfig)? onGenerateReport;
  final Function(String)? onDownloadReport;
  final List<GeneratedReport>? recentReports;

  const ReportGenerationWidget({
    super.key,
    this.onGenerateReport,
    this.onDownloadReport,
    this.recentReports,
  });

  @override
  State<ReportGenerationWidget> createState() => _ReportGenerationWidgetState();
}

class _ReportGenerationWidgetState extends State<ReportGenerationWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // Form controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Form state
  ReportType _selectedType = ReportType.overview;
  ReportFormat _selectedFormat = ReportFormat.pdf;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  List<String> _selectedMetrics = [];
  List<String> _selectedDimensions = [];
  List<ReportFilter> _filters = [];
  ReportSchedule? _schedule;
  List<String> _recipients = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeDefaultMetrics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _initializeDefaultMetrics() {
    _selectedMetrics = ReportMetrics.getMetricsForType(
      _selectedType,
    ).take(5).toList();
    _selectedDimensions = ReportDimensions.getDimensionsForType(
      _selectedType,
    ).take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(child: _buildTabContent()),
        ],
      ),
    );
  }

  /// Build widget header
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.border.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.assessment, color: AppColors.primary, size: 24.r),
          SizedBox(width: 12.w),
          Text(
            'Report Generation',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          _buildQuickActions(),
        ],
      ),
    );
  }

  /// Build quick action buttons
  Widget _buildQuickActions() {
    return Row(
      children: [
        _buildQuickActionButton(
          icon: Icons.schedule,
          label: 'Scheduled',
          onTap: () => _tabController.animateTo(1),
        ),
        SizedBox(width: 8.w),
        _buildQuickActionButton(
          icon: Icons.history,
          label: 'History',
          onTap: () => _tabController.animateTo(2),
        ),
      ],
    );
  }

  /// Build quick action button
  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16.r, color: AppColors.primary),
            SizedBox(width: 4.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build tab bar
  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.border.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppColors.primary,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorWeight: 3,
        labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
        ),
        tabs: const [
          Tab(text: 'Generate Report'),
          Tab(text: 'Scheduled Reports'),
          Tab(text: 'Report History'),
        ],
      ),
    );
  }

  /// Build tab content
  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildGenerateReportTab(),
        _buildScheduledReportsTab(),
        _buildReportHistoryTab(),
      ],
    );
  }

  /// Build generate report tab
  Widget _buildGenerateReportTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBasicInfoSection(),
          SizedBox(height: 24.h),
          _buildReportConfigSection(),
          SizedBox(height: 24.h),
          _buildMetricsSection(),
          SizedBox(height: 24.h),
          _buildFiltersSection(),
          SizedBox(height: 24.h),
          _buildScheduleSection(),
          SizedBox(height: 32.h),
          _buildGenerateButton(),
        ],
      ),
    );
  }

  /// Build basic info section
  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Basic Information'),
        SizedBox(height: 12.h),
        _buildTextField(
          controller: _nameController,
          label: 'Report Name',
          hint: 'Enter report name',
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          controller: _descriptionController,
          label: 'Description',
          hint: 'Enter report description',
          maxLines: 3,
        ),
      ],
    );
  }

  /// Build report config section
  Widget _buildReportConfigSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Report Configuration'),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _buildDropdown<ReportType>(
                label: 'Report Type',
                value: _selectedType,
                items: ReportType.values,
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                    _initializeDefaultMetrics();
                  });
                },
                itemBuilder: (type) => type.displayName,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildDropdown<ReportFormat>(
                label: 'Format',
                value: _selectedFormat,
                items: ReportFormat.values,
                onChanged: (value) {
                  setState(() {
                    _selectedFormat = value!;
                  });
                },
                itemBuilder: (format) => format.displayName,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: _buildDatePicker(
                label: 'Start Date',
                date: _startDate,
                onChanged: (date) {
                  setState(() {
                    _startDate = date;
                  });
                },
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildDatePicker(
                label: 'End Date',
                date: _endDate,
                onChanged: (date) {
                  setState(() {
                    _endDate = date;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build metrics section
  Widget _buildMetricsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Metrics & Dimensions'),
        SizedBox(height: 12.h),
        _buildMultiSelectChips(
          label: 'Metrics',
          selectedItems: _selectedMetrics,
          availableItems: ReportMetrics.getMetricsForType(_selectedType),
          onChanged: (items) {
            setState(() {
              _selectedMetrics = items;
            });
          },
        ),
        SizedBox(height: 16.h),
        _buildMultiSelectChips(
          label: 'Dimensions',
          selectedItems: _selectedDimensions,
          availableItems: ReportDimensions.getDimensionsForType(_selectedType),
          onChanged: (items) {
            setState(() {
              _selectedDimensions = items;
            });
          },
        ),
      ],
    );
  }

  /// Build filters section
  Widget _buildFiltersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildSectionTitle('Filters'),
            const Spacer(),
            TextButton.icon(
              onPressed: _addFilter,
              icon: const Icon(Icons.add),
              label: const Text('Add Filter'),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        if (_filters.isEmpty)
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.border.withOpacity(0.3)),
            ),
            child: Center(
              child: Text(
                'No filters added',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14.sp,
                ),
              ),
            ),
          )
        else
          ..._filters.asMap().entries.map((entry) {
            final index = entry.key;
            final filter = entry.value;
            return _buildFilterItem(filter, index);
          }),
      ],
    );
  }

  /// Build schedule section
  Widget _buildScheduleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildSectionTitle('Schedule (Optional)'),
            const Spacer(),
            Switch(
              value: _schedule != null,
              onChanged: (value) {
                setState(() {
                  if (value) {
                    _schedule = const ReportSchedule(
                      frequency: ScheduleFrequency.weekly,
                      timeOfDay: '09:00',
                      timezone: 'Asia/Ho_Chi_Minh',
                    );
                  } else {
                    _schedule = null;
                  }
                });
              },
            ),
          ],
        ),
        if (_schedule != null) ...[
          SizedBox(height: 12.h),
          _buildScheduleConfig(),
        ],
      ],
    );
  }

  /// Build generate button
  Widget _buildGenerateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _canGenerateReport() ? _generateReport : null,
        icon: const Icon(Icons.file_download),
        label: const Text('Generate Report'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      ),
    );
  }

  /// Build scheduled reports tab
  Widget _buildScheduledReportsTab() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          Text(
            'Scheduled Reports',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: Center(
              child: Text(
                'No scheduled reports configured',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build report history tab
  Widget _buildReportHistoryTab() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          Text(
            'Report History',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: widget.recentReports?.isNotEmpty == true
                ? _buildReportHistoryList()
                : Center(
                    child: Text(
                      'No reports generated yet',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  /// Build report history list
  Widget _buildReportHistoryList() {
    return ListView.separated(
      itemCount: widget.recentReports!.length,
      separatorBuilder: (context, index) =>
          Divider(color: AppColors.border.withOpacity(0.3)),
      itemBuilder: (context, index) {
        final report = widget.recentReports![index];
        return _buildReportHistoryItem(report);
      },
    );
  }

  /// Build report history item
  Widget _buildReportHistoryItem(GeneratedReport report) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _getStatusColor(report.status).withOpacity(0.1),
        child: Icon(
          _getStatusIcon(report.status),
          color: _getStatusColor(report.status),
          size: 20.r,
        ),
      ),
      title: Text(
        report.fileName,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Generated: ${_formatDate(report.generatedAt)}',
            style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
          ),
          Text(
            'Size: ${report.fileSizeFormatted}',
            style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
          ),
        ],
      ),
      trailing: report.isReady
          ? IconButton(
              onPressed: () => widget.onDownloadReport?.call(report.id),
              icon: Icon(Icons.download, color: AppColors.primary, size: 20.r),
            )
          : null,
    );
  }

  // Helper methods for building UI components
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: AppColors.border.withOpacity(0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    required String Function(T) itemBuilder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        DropdownButtonFormField<T>(
          value: value,
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(itemBuilder(item)),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: AppColors.border.withOpacity(0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime date,
    required ValueChanged<DateTime> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: () async {
            final selectedDate = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime.now().subtract(const Duration(days: 365)),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (selectedDate != null) {
              onChanged(selectedDate);
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _formatDate(date),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  size: 16.r,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMultiSelectChips({
    required String label,
    required List<String> selectedItems,
    required List<String> availableItems,
    required ValueChanged<List<String>> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: availableItems.map((item) {
            final isSelected = selectedItems.contains(item);
            return FilterChip(
              label: Text(item),
              selected: isSelected,
              onSelected: (selected) {
                final newItems = List<String>.from(selectedItems);
                if (selected) {
                  newItems.add(item);
                } else {
                  newItems.remove(item);
                }
                onChanged(newItems);
              },
              selectedColor: AppColors.primary.withOpacity(0.2),
              checkmarkColor: AppColors.primary,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFilterItem(ReportFilter filter, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${filter.field} ${filter.operator.symbol} ${filter.value}',
              style: TextStyle(fontSize: 14.sp, color: AppColors.textPrimary),
            ),
          ),
          IconButton(
            onPressed: () => _removeFilter(index),
            icon: Icon(Icons.close, size: 16.r, color: AppColors.error),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleConfig() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            'Schedule Configuration',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            _schedule!.scheduleDescription,
            style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  // Helper methods
  void _addFilter() {
    // Implementation for adding filters
    // This would open a dialog to configure filter parameters
  }

  void _removeFilter(int index) {
    setState(() {
      _filters.removeAt(index);
    });
  }

  bool _canGenerateReport() {
    return _nameController.text.isNotEmpty &&
        _selectedMetrics.isNotEmpty &&
        _startDate.isBefore(_endDate);
  }

  void _generateReport() {
    if (!_canGenerateReport()) return;

    final config = ReportConfig(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      description: _descriptionController.text,
      type: _selectedType,
      format: _selectedFormat,
      startDate: _startDate,
      endDate: _endDate,
      metrics: _selectedMetrics,
      dimensions: _selectedDimensions,
      filters: _filters,
      schedule: _schedule,
      recipients: _recipients,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      createdBy: 'current_user',
    );

    widget.onGenerateReport?.call(config);
  }

  Color _getStatusColor(ReportStatus status) {
    switch (status) {
      case ReportStatus.completed:
        return AppColors.success;
      case ReportStatus.generating:
        return AppColors.warning;
      case ReportStatus.failed:
        return AppColors.error;
      case ReportStatus.pending:
        return AppColors.info;
    }
  }

  IconData _getStatusIcon(ReportStatus status) {
    switch (status) {
      case ReportStatus.completed:
        return Icons.check_circle;
      case ReportStatus.generating:
        return Icons.hourglass_empty;
      case ReportStatus.failed:
        return Icons.error;
      case ReportStatus.pending:
        return Icons.schedule;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
