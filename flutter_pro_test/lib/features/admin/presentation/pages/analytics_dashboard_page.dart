import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/analytics/business_analytics_service.dart';
import '../../../../core/analytics/firebase_analytics_service.dart';
import '../../../../core/monitoring/monitoring_service.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../widgets/charts/chart_theme.dart';

/// Comprehensive real-time analytics dashboard for admin users
class AnalyticsDashboardPage extends StatefulWidget {
  const AnalyticsDashboardPage({super.key});

  @override
  State<AnalyticsDashboardPage> createState() => _AnalyticsDashboardPageState();
}

class _AnalyticsDashboardPageState extends State<AnalyticsDashboardPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late BusinessAnalyticsService _businessAnalytics;
  late FirebaseAnalyticsService _firebaseAnalytics;
  late MonitoringService _monitoringService;

  // Real-time data
  Map<String, dynamic> _realtimeMetrics = {};
  Map<String, dynamic> _performanceStats = {};
  Map<String, dynamic> _userBehaviorData = {};
  Map<String, dynamic> _businessMetrics = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeServices();
    _loadAnalyticsData();
    _startRealtimeUpdates();
  }

  void _initializeServices() {
    _businessAnalytics = di.sl<BusinessAnalyticsService>();
    _firebaseAnalytics = di.sl<FirebaseAnalyticsService>();
    _monitoringService = di.sl<MonitoringService>();
  }

  Future<void> _loadAnalyticsData() async {
    setState(() => _isLoading = true);

    try {
      // Load business analytics data
      _businessMetrics = _businessAnalytics.getSessionInfo();
      _userBehaviorData = di.sl<UserBehaviorTrackingService>().getBehaviorSummary();

      // Load performance data
      _performanceStats = _monitoringService.getHealthStatus();

      // Load real-time metrics (mock data for demonstration)
      _realtimeMetrics = await _generateRealtimeMetrics();

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to load analytics data: $e');
    }
  }

  Future<Map<String, dynamic>> _generateRealtimeMetrics() async {
    // In a real implementation, this would fetch from Firebase Analytics
    return {
      'active_users': 1247,
      'total_sessions': 3456,
      'avg_session_duration': 8.5,
      'bounce_rate': 0.23,
      'conversion_rate': 0.045,
      'revenue_today': 12450.75,
      'bookings_today': 89,
      'error_rate': 0.012,
      'app_crashes': 3,
      'performance_score': 94.2,
    };
  }

  void _startRealtimeUpdates() {
    // Update metrics every 30 seconds
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        _loadAnalyticsData();
        _startRealtimeUpdates();
      }
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.people), text: 'Users'),
            Tab(icon: Icon(Icons.speed), text: 'Performance'),
            Tab(icon: Icon(Icons.business), text: 'Business'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalyticsData,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportAnalyticsData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildUsersTab(),
                _buildPerformanceTab(),
                _buildBusinessTab(),
              ],
            ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMetricsGrid(),
          const SizedBox(height: 24),
          _buildRealtimeChart(),
          const SizedBox(height: 24),
          _buildQuickInsights(),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid() {
    final metrics = [
      MetricCard(
        title: 'Active Users',
        value: _realtimeMetrics['active_users']?.toString() ?? '0',
        icon: Icons.people,
        color: Colors.blue,
        trend: '+12.5%',
      ),
      MetricCard(
        title: 'Total Sessions',
        value: _realtimeMetrics['total_sessions']?.toString() ?? '0',
        icon: Icons.timeline,
        color: Colors.green,
        trend: '+8.3%',
      ),
      MetricCard(
        title: 'Revenue Today',
        value: '\$${_realtimeMetrics['revenue_today']?.toStringAsFixed(2) ?? '0.00'}',
        icon: Icons.attach_money,
        color: Colors.orange,
        trend: '+15.7%',
      ),
      MetricCard(
        title: 'Error Rate',
        value: '${((_realtimeMetrics['error_rate'] ?? 0) * 100).toStringAsFixed(2)}%',
        icon: Icons.error_outline,
        color: Colors.red,
        trend: '-2.1%',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: metrics.length,
      itemBuilder: (context, index) => metrics[index],
    );
  }

  Widget _buildRealtimeChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Real-time Activity',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: const FlTitlesData(show: true),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _generateChartData(),
                      isCurved: true,
                      color: Theme.of(context).primaryColor,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _generateChartData() {
    // Generate sample real-time data points
    return List.generate(24, (index) {
      return FlSpot(
        index.toDouble(),
        50 + (index * 2) + (index % 3 * 10),
      );
    });
  }

  Widget _buildQuickInsights() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Insights',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInsightItem(
              'Peak Usage',
              'Most active time is 2-4 PM with 45% of daily traffic',
              Icons.schedule,
              Colors.blue,
            ),
            _buildInsightItem(
              'Top Feature',
              'Booking system accounts for 67% of user interactions',
              Icons.star,
              Colors.orange,
            ),
            _buildInsightItem(
              'Performance',
              'App performance improved by 23% this week',
              Icons.trending_up,
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(String title, String description, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildUserMetricsCard(),
          const SizedBox(height: 16),
          _buildUserBehaviorChart(),
          const SizedBox(height: 16),
          _buildUserSegmentationCard(),
        ],
      ),
    );
  }

  Widget _buildUserMetricsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'User Metrics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total Users',
                    '12,847',
                    Icons.people,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'New Users',
                    '1,234',
                    Icons.person_add,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Retention Rate',
                    '78.5%',
                    Icons.repeat,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Avg Session',
                    '8.5 min',
                    Icons.timer,
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
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
          Text(
            title,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUserBehaviorChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'User Behavior Patterns',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: _generateUserBehaviorData(),
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _generateUserBehaviorData() {
    return [
      PieChartSectionData(
        value: 40,
        title: 'Booking',
        color: Colors.blue,
        radius: 60,
      ),
      PieChartSectionData(
        value: 25,
        title: 'Browse',
        color: Colors.green,
        radius: 60,
      ),
      PieChartSectionData(
        value: 20,
        title: 'Profile',
        color: Colors.orange,
        radius: 60,
      ),
      PieChartSectionData(
        value: 15,
        title: 'Other',
        color: Colors.grey,
        radius: 60,
      ),
    ];
  }

  Widget _buildUserSegmentationCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'User Segmentation',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildSegmentItem('New Users', 0.3, Colors.green),
            _buildSegmentItem('Regular Users', 0.5, Colors.blue),
            _buildSegmentItem('Power Users', 0.2, Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentItem(String label, double percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label),
              Text('${(percentage * 100).toInt()}%'),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildPerformanceMetricsCard(),
          const SizedBox(height: 16),
          _buildErrorTrackingCard(),
          const SizedBox(height: 16),
          _buildSystemHealthCard(),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetricsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Performance Metrics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildPerformanceItem('App Load Time', '2.3s', 0.8, Colors.green),
            _buildPerformanceItem('API Response', '450ms', 0.9, Colors.blue),
            _buildPerformanceItem('Memory Usage', '67%', 0.67, Colors.orange),
            _buildPerformanceItem('CPU Usage', '23%', 0.23, Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceItem(String label, String value, double progress, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label),
              Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorTrackingCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Error Tracking',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildErrorItem('App Crashes', '3', Colors.red),
            _buildErrorItem('Network Errors', '12', Colors.orange),
            _buildErrorItem('Validation Errors', '45', Colors.yellow),
            _buildErrorItem('Auth Errors', '2', Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorItem(String type, String count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(type),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemHealthCard() {
    final healthStatus = _performanceStats['status'] ?? 'unknown';
    final healthColor = healthStatus == 'healthy' ? Colors.green : Colors.red;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'System Health',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: healthColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    healthStatus.toUpperCase(),
                    style: TextStyle(
                      color: healthColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Last updated: ${DateTime.now().toString().substring(0, 19)}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildRevenueCard(),
          const SizedBox(height: 16),
          _buildBookingMetricsCard(),
          const SizedBox(height: 16),
          _buildConversionFunnelCard(),
        ],
      ),
    );
  }

  Widget _buildRevenueCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Revenue Analytics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildRevenueItem('Today', '\$12,450', Colors.green),
                ),
                Expanded(
                  child: _buildRevenueItem('This Week', '\$87,320', Colors.blue),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildRevenueItem('This Month', '\$345,670', Colors.orange),
                ),
                Expanded(
                  child: _buildRevenueItem('This Year', '\$2,456,890', Colors.purple),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueItem(String period, String amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            amount,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            period,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingMetricsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Booking Metrics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildBookingItem('Total Bookings', '1,247', Icons.calendar_today),
            _buildBookingItem('Completed', '1,156', Icons.check_circle),
            _buildBookingItem('Cancelled', '67', Icons.cancel),
            _buildBookingItem('Pending', '24', Icons.schedule),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingItem(String label, String count, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Text(
            count,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildConversionFunnelCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Conversion Funnel',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildFunnelStep('App Opens', 10000, 1.0),
            _buildFunnelStep('Service Browse', 7500, 0.75),
            _buildFunnelStep('Booking Started', 3200, 0.32),
            _buildFunnelStep('Payment', 2800, 0.28),
            _buildFunnelStep('Completed', 2650, 0.265),
          ],
        ),
      ),
    );
  }

  Widget _buildFunnelStep(String step, int count, double percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(step),
              Text('$count (${(percentage * 100).toInt()}%)'),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportAnalyticsData() async {
    // Show export options dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Analytics Data'),
        content: const Text('Choose export format:'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _exportToPDF();
            },
            child: const Text('PDF'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _exportToCSV();
            },
            child: const Text('CSV'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportToPDF() async {
    // Implementation for PDF export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exporting to PDF...')),
    );
  }

  Future<void> _exportToCSV() async {
    // Implementation for CSV export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exporting to CSV...')),
    );
  }
}

/// Metric card widget for displaying key metrics
class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String trend;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.trend,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const Spacer(),
                Text(
                  trend,
                  style: TextStyle(
                    color: trend.startsWith('+') ? Colors.green : Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
