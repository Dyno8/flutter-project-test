import 'dart:async';
import 'package:flutter/material.dart';

import '../../../../core/monitoring/production_monitoring_service.dart';
import '../../../../core/monitoring/alerting_system.dart' as alerting;
import '../../../../core/monitoring/health_check_endpoint.dart';
import '../../../../core/monitoring/ux_monitoring_integration.dart';
import '../../../../core/config/environment_config.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../widgets/admin_app_bar.dart';

/// Monitoring dashboard page for production monitoring and alerting
class MonitoringDashboardPage extends StatefulWidget {
  const MonitoringDashboardPage({super.key});

  @override
  State<MonitoringDashboardPage> createState() =>
      _MonitoringDashboardPageState();
}

class _MonitoringDashboardPageState extends State<MonitoringDashboardPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final ProductionMonitoringService _productionMonitoring =
      ProductionMonitoringService();
  final alerting.AlertingSystem _alertingSystem = alerting.AlertingSystem();
  final HealthCheckEndpoint _healthCheckEndpoint = HealthCheckEndpoint();
  final UXMonitoringIntegration _uxMonitoring = UXMonitoringIntegration();

  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _currentHealthStatus;
  List<alerting.AlertIncident> _activeIncidents = [];
  List<Map<String, dynamic>> _healthHistory = [];
  Map<String, dynamic>? _uxAnalytics;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadMonitoringData();

    // Set up periodic refresh
    Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        _loadMonitoringData();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMonitoringData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Load current health status
      _currentHealthStatus = _productionMonitoring.getCurrentHealthStatus();

      // Load active incidents
      _activeIncidents = _alertingSystem.getActiveIncidents();

      // Load health history
      _healthHistory = _productionMonitoring.getHealthCheckHistory(limit: 20);

      // Load UX analytics if available
      if (_uxMonitoring.isInitialized) {
        _uxAnalytics = _uxMonitoring.getComprehensiveUXAnalytics();
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AdminAppBar(title: 'Production Monitoring'),
      body: _isLoading
          ? const LoadingWidget()
          : _error != null
          ? CustomErrorWidget(message: _error!, onRetry: _loadMonitoringData)
          : Column(
              children: [
                _buildStatusOverview(),
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabs: const [
                    Tab(
                      text: 'Health Status',
                      icon: Icon(Icons.health_and_safety),
                    ),
                    Tab(text: 'Active Alerts', icon: Icon(Icons.warning)),
                    Tab(text: 'Performance', icon: Icon(Icons.speed)),
                    Tab(text: 'UX Monitoring', icon: Icon(Icons.analytics)),
                    Tab(text: 'System Info', icon: Icon(Icons.info)),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildHealthStatusTab(),
                      _buildActiveAlertsTab(),
                      _buildPerformanceTab(),
                      _buildUXMonitoringTab(),
                      _buildSystemInfoTab(),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadMonitoringData,
        tooltip: 'Refresh Monitoring Data',
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildStatusOverview() {
    final status = _currentHealthStatus?['status'] as String? ?? 'unknown';
    final statusColor = _getStatusColor(status);
    final statusIcon = _getStatusIcon(status);

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        border: Border.all(color: statusColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'System Status: ${status.toUpperCase()}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Environment: ${EnvironmentConfig.environment}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  'Last Updated: ${DateTime.now().toString().substring(0, 19)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Active Alerts: ${_activeIncidents.length}',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                'Critical: ${_activeIncidents.where((i) => i.severity == alerting.AlertSeverity.critical).length}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHealthStatusTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildHealthCheckCard(),
        const SizedBox(height: 16),
        _buildHealthHistoryCard(),
      ],
    );
  }

  Widget _buildHealthCheckCard() {
    final checks =
        _currentHealthStatus?['checks'] as Map<String, dynamic>? ?? {};

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Health Checks',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            ...checks.entries.map(
              (entry) => _buildHealthCheckItem(
                entry.key,
                entry.value as Map<String, dynamic>,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthCheckItem(
    String checkName,
    Map<String, dynamic> checkData,
  ) {
    final status = checkData['status'] as String? ?? 'unknown';
    final statusColor = _getStatusColor(status);
    final statusIcon = _getStatusIcon(status);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  checkName.replaceAll('_', ' ').toUpperCase(),
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (checkData.containsKey('message'))
                  Text(
                    checkData['message'].toString(),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
          Text(
            status.toUpperCase(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthHistoryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Health Check History (Last 20)',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: _healthHistory.length,
                itemBuilder: (context, index) {
                  final healthCheck = _healthHistory[index];
                  final status =
                      healthCheck['overall_status'] as String? ?? 'unknown';
                  final timestamp = DateTime.parse(
                    healthCheck['timestamp'] as String,
                  );

                  return ListTile(
                    leading: Icon(
                      _getStatusIcon(status),
                      color: _getStatusColor(status),
                      size: 16,
                    ),
                    title: Text(status.toUpperCase()),
                    subtitle: Text(timestamp.toString().substring(0, 19)),
                    dense: true,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveAlertsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Active Incidents (${_activeIncidents.length})',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                if (_activeIncidents.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('No active incidents'),
                    ),
                  )
                else
                  ..._activeIncidents.map(
                    (incident) => _buildIncidentCard(incident),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIncidentCard(alerting.AlertIncident incident) {
    final severityColor = _getSeverityColor(incident.severity);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning, color: severityColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    incident.ruleName,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Chip(
                  label: Text(
                    incident.severity.toString().split('.').last.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  backgroundColor: severityColor,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(incident.description),
            const SizedBox(height: 8),
            Text(
              'Created: ${incident.createdAt.toString().substring(0, 19)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceTab() {
    return const Center(
      child: Text('Performance metrics will be displayed here'),
    );
  }

  Widget _buildUXMonitoringTab() {
    if (!_uxMonitoring.isInitialized) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'UX Monitoring Not Initialized',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'UX monitoring services are not currently active',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // UX Monitoring Status Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.analytics, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      'UX Monitoring Status',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildUXStatusGrid(),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Session Analytics Card
        if (_uxAnalytics != null && _uxAnalytics!['session_analytics'] != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Session Analytics',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  _buildSessionAnalyticsGrid(),
                ],
              ),
            ),
          ),
        const SizedBox(height: 16),

        // Engagement Metrics Card
        if (_uxAnalytics != null && _uxAnalytics!['engagement_metrics'] != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'User Engagement Metrics',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  _buildEngagementMetricsGrid(),
                ],
              ),
            ),
          ),
        const SizedBox(height: 16),

        // Feedback Analytics Card
        if (_uxAnalytics != null && _uxAnalytics!['feedback_analytics'] != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'User Feedback Analytics',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  _buildFeedbackAnalyticsGrid(),
                ],
              ),
            ),
          ),
        const SizedBox(height: 16),

        // Error Impact Analytics Card
        if (_uxAnalytics != null &&
            _uxAnalytics!['error_impact_analytics'] != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Error Impact Analytics',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  _buildErrorImpactAnalyticsGrid(),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSystemInfoTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'System Information',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                _buildInfoRow('Environment', EnvironmentConfig.environment),
                _buildInfoRow('Version', EnvironmentConfig.appVersion),
                _buildInfoRow(
                  'Production Mode',
                  EnvironmentConfig.isProduction.toString(),
                ),
                _buildInfoRow(
                  'Debug Mode',
                  EnvironmentConfig.isDebug.toString(),
                ),
                _buildInfoRow(
                  'Monitoring Active',
                  _productionMonitoring.isMonitoringActive.toString(),
                ),
                _buildInfoRow(
                  'Alerting Active',
                  _alertingSystem.isInitialized.toString(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Text(
              '$label:',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Text(value),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'healthy':
        return Colors.green;
      case 'warning':
        return Colors.orange;
      case 'critical':
      case 'error':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'healthy':
        return Icons.check_circle;
      case 'warning':
        return Icons.warning;
      case 'critical':
      case 'error':
        return Icons.error;
      default:
        return Icons.help;
    }
  }

  Color _getSeverityColor(alerting.AlertSeverity severity) {
    switch (severity) {
      case alerting.AlertSeverity.low:
        return Colors.blue;
      case alerting.AlertSeverity.medium:
        return Colors.orange;
      case alerting.AlertSeverity.high:
        return Colors.red;
      case alerting.AlertSeverity.critical:
        return Colors.red.shade900;
    }
  }

  Widget _buildUXStatusGrid() {
    final serviceStatus = _uxMonitoring.getServiceStatus();

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 3,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildStatusCard(
          'UX Monitoring',
          serviceStatus['initialized'] == true ? 'Active' : 'Inactive',
          serviceStatus['initialized'] == true ? Colors.green : Colors.red,
        ),
        _buildStatusCard(
          'Session Tracking',
          serviceStatus['services']['session_tracker'] == true
              ? 'Active'
              : 'Inactive',
          serviceStatus['services']['session_tracker'] == true
              ? Colors.green
              : Colors.red,
        ),
        _buildStatusCard(
          'Feedback Collection',
          serviceStatus['services']['feedback_collector'] == true
              ? 'Active'
              : 'Inactive',
          serviceStatus['services']['feedback_collector'] == true
              ? Colors.green
              : Colors.red,
        ),
        _buildStatusCard(
          'Error Impact Analysis',
          serviceStatus['services']['error_impact_analyzer'] == true
              ? 'Active'
              : 'Inactive',
          serviceStatus['services']['error_impact_analyzer'] == true
              ? Colors.green
              : Colors.red,
        ),
      ],
    );
  }

  Widget _buildSessionAnalyticsGrid() {
    final sessionAnalytics =
        _uxAnalytics!['session_analytics'] as Map<String, dynamic>;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildMetricCard(
          'Session Active',
          sessionAnalytics['active']?.toString() ?? 'No',
          Icons.play_circle,
          sessionAnalytics['active'] == true ? Colors.green : Colors.grey,
        ),
        _buildMetricCard(
          'Duration',
          '${sessionAnalytics['duration_seconds'] ?? 0}s',
          Icons.timer,
          Colors.blue,
        ),
        _buildMetricCard(
          'Screens Visited',
          '${sessionAnalytics['screens_visited'] ?? 0}',
          Icons.screen_share,
          Colors.orange,
        ),
        _buildMetricCard(
          'Interactions',
          '${sessionAnalytics['total_interactions'] ?? 0}',
          Icons.touch_app,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildEngagementMetricsGrid() {
    final engagementMetrics =
        _uxAnalytics!['engagement_metrics'] as Map<String, dynamic>;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildMetricCard(
          'Engagement Rate',
          '${(engagementMetrics['engagement_rate'] ?? 0.0).toStringAsFixed(1)}%',
          Icons.trending_up,
          Colors.green,
        ),
        _buildMetricCard(
          'Bounce Rate',
          '${(engagementMetrics['bounce_rate'] ?? 0.0).toStringAsFixed(1)}%',
          Icons.trending_down,
          Colors.red,
        ),
        _buildMetricCard(
          'Session Depth',
          '${engagementMetrics['session_depth'] ?? 0}',
          Icons.layers,
          Colors.blue,
        ),
        _buildMetricCard(
          'Total Taps',
          '${engagementMetrics['total_taps'] ?? 0}',
          Icons.touch_app,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildFeedbackAnalyticsGrid() {
    final feedbackAnalytics =
        _uxAnalytics!['feedback_analytics'] as Map<String, dynamic>;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildMetricCard(
          'Total Feedback',
          '${feedbackAnalytics['total_feedback'] ?? 0}',
          Icons.feedback,
          Colors.blue,
        ),
        _buildMetricCard(
          'Satisfaction',
          '${(feedbackAnalytics['overall_satisfaction'] ?? 0.0).toStringAsFixed(1)}/5',
          Icons.star,
          Colors.amber,
        ),
      ],
    );
  }

  Widget _buildErrorImpactAnalyticsGrid() {
    final errorAnalytics =
        _uxAnalytics!['error_impact_analytics'] as Map<String, dynamic>;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildMetricCard(
          'Total Errors',
          '${errorAnalytics['total_errors'] ?? 0}',
          Icons.error,
          Colors.red,
        ),
        _buildMetricCard(
          'Abandonment Rate',
          '${(errorAnalytics['overall_abandonment_rate'] ?? 0.0).toStringAsFixed(1)}%',
          Icons.exit_to_app,
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildStatusCard(String title, String status, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: const TextStyle(fontSize: 12)),
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
