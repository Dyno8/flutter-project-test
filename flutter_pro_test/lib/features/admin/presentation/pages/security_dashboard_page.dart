import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/security/security_manager.dart';
import '../../../../core/security/advanced_security_manager.dart';
import '../../../../core/security/security_compliance_manager.dart';
import '../../../../core/security/security_monitoring_service.dart';
import '../../../../core/monitoring/monitoring_service.dart';
import '../../../../core/performance/performance_manager.dart';
import '../../../../core/analytics/firebase_analytics_service.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../../../shared/widgets/loading_widget.dart';

class SecurityDashboardPage extends StatefulWidget {
  const SecurityDashboardPage({super.key});

  @override
  State<SecurityDashboardPage> createState() => _SecurityDashboardPageState();
}

class _SecurityDashboardPageState extends State<SecurityDashboardPage> {
  final SecurityManager _securityManager = SecurityManager();
  final AdvancedSecurityManager _advancedSecurityManager =
      AdvancedSecurityManager();
  final SecurityComplianceManager _complianceManager =
      SecurityComplianceManager();
  final SecurityMonitoringService _securityMonitoringService =
      SecurityMonitoringService();
  final MonitoringService _monitoringService = MonitoringService();
  final PerformanceManager _performanceManager = PerformanceManager();
  final FirebaseAnalyticsService _analyticsService = FirebaseAnalyticsService();

  bool _isLoading = true;
  Map<String, dynamic> _securityLogs = {};
  Map<String, dynamic> _healthStatus = {};
  Map<String, dynamic> _performanceStats = {};
  Map<String, dynamic> _errorStats = {};
  SecurityHealthReport? _securityHealthReport;
  List<Map<String, dynamic>> _securityViolations = [];
  SecurityAuditReport? _latestAuditReport;
  List<Map<String, dynamic>> _securityAlerts = [];
  List<Map<String, dynamic>> _securityIncidents = [];
  Map<String, dynamic>? _complianceStatus;

  @override
  void initState() {
    super.initState();
    _loadSecurityData();
  }

  Future<void> _loadSecurityData() async {
    setState(() => _isLoading = true);

    try {
      await _securityManager.initialize();
      await _advancedSecurityManager.initialize();
      await _complianceManager.initialize();
      await _analyticsService.initialize();
      await _securityMonitoringService.initialize(
        analyticsService: _analyticsService,
      );
      await _monitoringService.initialize();
      await _performanceManager.initialize();

      final securityLogs = _securityManager.getSecurityLogs();
      final healthStatus = _monitoringService.getHealthStatus();
      final performanceStats = _performanceManager.getPerformanceStats();
      final errorStats = _monitoringService.getErrorStats();

      // Load advanced security features
      _securityHealthReport = await _advancedSecurityManager
          .performSecurityHealthCheck();
      _securityViolations = _advancedSecurityManager.getSecurityViolations();

      // Load latest compliance audit report
      final complianceReports = _complianceManager.getComplianceReports();
      if (complianceReports.isNotEmpty) {
        _latestAuditReport = complianceReports.last;
      }

      // Load security monitoring data
      _securityAlerts = await _securityMonitoringService.getSecurityAlerts();
      _securityIncidents = await _securityMonitoringService
          .getSecurityIncidents();
      _complianceStatus = await _securityMonitoringService
          .getComplianceStatus();

      setState(() {
        _securityLogs = {
          'total': securityLogs.length,
          'recent': securityLogs.take(10).toList(),
        };
        _healthStatus = healthStatus;
        _performanceStats = performanceStats;
        _errorStats = errorStats;
        _isLoading = false;
      });
    } catch (e) {
      _monitoringService.logError('Failed to load security data', error: e);
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Dashboard'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSecurityData,
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget()
          : RefreshIndicator(
              onRefresh: _loadSecurityData,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSystemHealthSection(),
                    SizedBox(height: 16.h),
                    _buildSecurityMetricsSection(),
                    SizedBox(height: 16.h),
                    _buildPerformanceSection(),
                    SizedBox(height: 16.h),
                    _buildSecurityLogsSection(),
                    SizedBox(height: 16.h),
                    _buildSecurityActionsSection(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSystemHealthSection() {
    final status = _healthStatus['status'] ?? 'unknown';
    final checks = _healthStatus['checks'] as Map<String, dynamic>? ?? {};

    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case 'healthy':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'warning':
        statusColor = Colors.orange;
        statusIcon = Icons.warning;
        break;
      case 'error':
        statusColor = Colors.red;
        statusIcon = Icons.error;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(statusIcon, color: statusColor, size: 24.sp),
              SizedBox(width: 8.w),
              Text(
                'System Health',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: statusColor),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ...checks.entries.map(
            (entry) => _buildHealthCheckItem(entry.key, entry.value),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthCheckItem(String checkName, dynamic checkData) {
    final data = checkData as Map<String, dynamic>? ?? {};
    final hasError = data.containsKey('error');
    final hasWarning = data.containsKey('warning');

    Color statusColor = Colors.green;
    IconData statusIcon = Icons.check_circle_outline;

    if (hasError) {
      statusColor = Colors.red;
      statusIcon = Icons.error_outline;
    } else if (hasWarning) {
      statusColor = Colors.orange;
      statusIcon = Icons.warning_outlined;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 16.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              checkName.replaceAll('_', ' ').toUpperCase(),
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
          if (data.isNotEmpty)
            Text(
              _formatCheckData(data),
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
            ),
        ],
      ),
    );
  }

  String _formatCheckData(Map<String, dynamic> data) {
    if (data.containsKey('error')) {
      return 'Error';
    } else if (data.containsKey('warning')) {
      return 'Warning';
    } else if (data.containsKey('usage_mb')) {
      return '${data['usage_mb']}MB';
    } else if (data.containsKey('errors_per_minute')) {
      return '${data['errors_per_minute']}/min';
    }
    return 'OK';
  }

  Widget _buildSecurityMetricsSection() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Security Metrics',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Security Events',
                  '${_securityLogs['total'] ?? 0}',
                  Icons.security,
                  Colors.blue,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildMetricCard(
                  'Total Errors',
                  '${_errorStats['total_errors'] ?? 0}',
                  Icons.error_outline,
                  Colors.red,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Error Rate',
                  '${(_errorStats['error_rate_per_minute'] ?? 0).toStringAsFixed(1)}/min',
                  Icons.trending_up,
                  Colors.orange,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildMetricCard(
                  'Recent Errors',
                  '${_errorStats['recent_errors_1h'] ?? 0}',
                  Icons.access_time,
                  Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceSection() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Metrics',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Cache Size',
                  '${_performanceStats['cache_size'] ?? 0}',
                  Icons.storage,
                  Colors.green,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildMetricCard(
                  'Hit Rate',
                  '${((_performanceStats['cache_hit_rate'] ?? 0) * 100).toStringAsFixed(1)}%',
                  Icons.speed,
                  Colors.teal,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Memory Usage',
                  '${((_performanceStats['memory_usage_bytes'] ?? 0) / 1024).toStringAsFixed(1)}KB',
                  Icons.memory,
                  Colors.indigo,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildMetricCard(
                  'Total Events',
                  '${_performanceStats['total_events'] ?? 0}',
                  Icons.event,
                  Colors.cyan,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityLogsSection() {
    final recentLogs = _securityLogs['recent'] as List? ?? [];

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Recent Security Events',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  // Navigate to full security logs
                },
                child: const Text('View All'),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          if (recentLogs.isEmpty)
            Center(
              child: Text(
                'No recent security events',
                style: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
              ),
            )
          else
            ...recentLogs.take(5).map((log) => _buildSecurityLogItem(log)),
        ],
      ),
    );
  }

  Widget _buildSecurityLogItem(Map<String, dynamic> log) {
    final type = log['type'] ?? 'unknown';
    final description = log['description'] ?? 'No description';
    final timestamp = log['timestamp'] ?? '';

    IconData icon;
    Color color;

    switch (type) {
      case 'login_success':
        icon = Icons.login;
        color = Colors.green;
        break;
      case 'login_failed':
        icon = Icons.login;
        color = Colors.red;
        break;
      case 'account_locked':
        icon = Icons.lock;
        color = Colors.red;
        break;
      case 'malicious_input_detected':
        icon = Icons.security;
        color = Colors.orange;
        break;
      case 'rate_limit_exceeded':
        icon = Icons.speed;
        color = Colors.orange;
        break;
      default:
        icon = Icons.info;
        color = Colors.blue;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: color, size: 16.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _formatTimestamp(timestamp),
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inDays < 1) {
        return '${difference.inHours}h ago';
      } else {
        return '${difference.inDays}d ago';
      }
    } catch (e) {
      return timestamp;
    }
  }

  Widget _buildSecurityActionsSection() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Security Actions',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _clearSecurityLogs(),
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Clear Logs'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _clearCache(),
                  icon: const Icon(Icons.cached),
                  label: const Text('Clear Cache'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _runSecurityScan(),
              icon: const Icon(Icons.security),
              label: const Text('Run Security Scan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _clearSecurityLogs() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Security Logs'),
        content: const Text(
          'Are you sure you want to clear all security logs? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _monitoringService.clearLogs();
              Navigator.pop(context);
              _loadSecurityData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Security logs cleared')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _clearCache() {
    _performanceManager.clearAllCache();
    _loadSecurityData();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Cache cleared')));
  }

  void _runSecurityScan() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Security Scan'),
        content: const Text('Running comprehensive security scan...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );

    // Log security scan event
    _securityManager.logSecurityEvent(
      eventType: 'security_scan',
      description: 'Manual security scan initiated',
      metadata: {'initiated_by': 'admin'},
    );
  }
}
