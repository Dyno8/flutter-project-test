import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Simple test app to demonstrate Partner Dashboard features
void main() {
  runApp(const PartnerDashboardTestApp());
}

class PartnerDashboardTestApp extends StatelessWidget {
  const PartnerDashboardTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Partner Dashboard Test',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          home: const TestPartnerDashboard(),
        );
      },
    );
  }
}

class TestPartnerDashboard extends StatefulWidget {
  const TestPartnerDashboard({super.key});

  @override
  State<TestPartnerDashboard> createState() => _TestPartnerDashboardState();
}

class _TestPartnerDashboardState extends State<TestPartnerDashboard> {
  bool isAvailable = true;
  bool isOnline = true;
  int pendingJobs = 3;
  int activeJobs = 2;
  double todayEarnings = 250.0;
  double totalEarnings = 15000.0;
  double rating = 4.8;

  // Mock job data
  final List<MockJob> mockPendingJobs = [
    MockJob(
      id: '1',
      serviceName: 'House Cleaning',
      clientName: 'John Doe',
      earnings: '80k VND',
      time: '09:00 AM',
      address: '123 Main St, District 1',
      isUrgent: true,
    ),
    MockJob(
      id: '2',
      serviceName: 'Plumbing Repair',
      clientName: 'Jane Smith',
      earnings: '120k VND',
      time: '02:00 PM',
      address: '456 Oak Ave, District 3',
      isUrgent: false,
    ),
    MockJob(
      id: '3',
      serviceName: 'Electrical Work',
      clientName: 'Mike Johnson',
      earnings: '150k VND',
      time: '04:30 PM',
      address: '789 Pine St, District 7',
      isUrgent: false,
    ),
  ];

  final List<MockJob> mockActiveJobs = [
    MockJob(
      id: '4',
      serviceName: 'Garden Maintenance',
      clientName: 'Sarah Wilson',
      earnings: '100k VND',
      time: '10:00 AM',
      address: '321 Elm St, District 2',
      isUrgent: false,
      status: 'In Progress',
    ),
    MockJob(
      id: '5',
      serviceName: 'AC Repair',
      clientName: 'David Brown',
      earnings: '200k VND',
      time: '01:00 PM',
      address: '654 Maple Ave, District 5',
      isUrgent: false,
      status: 'Accepted',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 120.h,
            floating: false,
            pinned: true,
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Partner Dashboard',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Notifications clicked')),
                      );
                    },
                  ),
                  if (pendingJobs > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 16.w,
                          minHeight: 16.h,
                        ),
                        child: Text(
                          '$pendingJobs',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),

          // Dashboard Content
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Header Section
                _buildHeaderSection(),

                // Quick Stats
                _buildQuickStats(),

                // Availability Toggle
                _buildAvailabilitySection(),

                // Job Queue
                _buildJobQueueSection(),

                // Earnings Overview
                _buildEarningsSection(),

                SizedBox(height: 100.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.primaryContainer.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back!',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  Text(
                    'Ready to help clients today?',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Theme.of(
                        context,
                      ).colorScheme.onPrimaryContainer.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: isOnline
                      ? Colors.green.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isOnline ? Colors.green : Colors.grey,
                    width: 1.w,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8.w,
                      height: 8.h,
                      decoration: BoxDecoration(
                        color: isOnline ? Colors.green : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      isOnline ? 'Online' : 'Offline',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: isOnline ? Colors.green : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(
                  isAvailable ? Icons.check_circle : Icons.pause_circle,
                  color: isAvailable ? Colors.green : Colors.orange,
                  size: 24.w,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAvailable
                            ? 'Available for Jobs'
                            : 'Currently Unavailable',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        isOnline ? 'Online now' : 'Last seen 5 minutes ago',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isAvailable,
                  onChanged: (value) {
                    setState(() {
                      isAvailable = value;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          value
                              ? 'You are now available'
                              : 'You are now unavailable',
                        ),
                        backgroundColor: value ? Colors.green : Colors.orange,
                      ),
                    );
                  },
                  activeColor: Colors.green,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Pending',
              '$pendingJobs',
              'jobs',
              Colors.orange,
              Icons.pending_actions,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildStatCard(
              'Active',
              '$activeJobs',
              'jobs',
              Colors.blue,
              Icons.work,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildStatCard(
              'Today',
              '${todayEarnings.toInt()}k',
              'VND',
              Colors.green,
              Icons.monetization_on,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildStatCard(
              'Rating',
              rating.toString(),
              'stars',
              Colors.amber,
              Icons.star,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String subtitle,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 20.w, color: color),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 10.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilitySection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Availability Controls',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      isOnline = !isOnline;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isOnline
                              ? 'You are now online'
                              : 'You are now offline',
                        ),
                      ),
                    );
                  },
                  icon: Icon(isOnline ? Icons.pause : Icons.play_arrow),
                  label: Text(isOnline ? 'Go Offline' : 'Go Online'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isOnline ? Colors.orange : Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Working hours settings opened'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.schedule),
                  label: const Text('Set Hours'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJobQueueSection() {
    return DefaultTabController(
      length: 2,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  Text(
                    'Job Queue',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            TabBar(
              tabs: [
                Tab(text: 'Pending (${mockPendingJobs.length})'),
                Tab(text: 'Active (${mockActiveJobs.length})'),
              ],
            ),
            SizedBox(
              height: 300.h,
              child: TabBarView(
                children: [
                  _buildJobList(mockPendingJobs, true),
                  _buildJobList(mockActiveJobs, false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobList(List<MockJob> jobs, bool isPending) {
    if (jobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isPending ? Icons.inbox_outlined : Icons.work_outline,
              size: 48.w,
              color: Colors.grey,
            ),
            SizedBox(height: 16.h),
            Text(
              isPending ? 'No pending jobs' : 'No active jobs',
              style: TextStyle(fontSize: 16.sp, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        final job = jobs[index];
        return _buildJobCard(job, isPending);
      },
    );
  }

  Widget _buildJobCard(MockJob job, bool isPending) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (job.isUrgent)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      'URGENT',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ),
                if (!job.isUrgent) const SizedBox(),
                Text(
                  job.earnings,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              job.serviceName,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
            Text(
              job.clientName,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(Icons.schedule, size: 16.w, color: Colors.grey),
                SizedBox(width: 4.w),
                Text(job.time, style: TextStyle(fontSize: 12.sp)),
                SizedBox(width: 16.w),
                Icon(Icons.location_on, size: 16.w, color: Colors.grey),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    job.address,
                    style: TextStyle(fontSize: 12.sp),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (job.status != null) ...[
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: job.status == 'In Progress'
                      ? Colors.green.withOpacity(0.1)
                      : Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  job.status!,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: job.status == 'In Progress'
                        ? Colors.green
                        : Colors.blue,
                  ),
                ),
              ),
            ],
            SizedBox(height: 12.h),
            if (isPending)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          mockPendingJobs.remove(job);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Rejected ${job.serviceName} job'),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      child: const Text('Reject'),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          mockPendingJobs.remove(job);
                          mockActiveJobs.add(job.copyWith(status: 'Accepted'));
                          activeJobs++;
                          pendingJobs--;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Accepted ${job.serviceName} job'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Accept'),
                    ),
                  ),
                ],
              )
            else if (job.status == 'Accepted')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      final index = mockActiveJobs.indexOf(job);
                      mockActiveJobs[index] = job.copyWith(
                        status: 'In Progress',
                      );
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Started ${job.serviceName} job')),
                    );
                  },
                  child: const Text('Start Job'),
                ),
              )
            else if (job.status == 'In Progress')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      mockActiveJobs.remove(job);
                      activeJobs--;
                      todayEarnings += double.parse(
                        job.earnings.replaceAll(RegExp(r'[^0-9]'), ''),
                      );
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Completed ${job.serviceName} job'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Complete Job'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Earnings Overview',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Detailed earnings view opened'),
                    ),
                  );
                },
                child: Text(
                  'View Details',
                  style: TextStyle(color: Colors.white.withOpacity(0.8)),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Earnings',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  Text(
                    '${totalEarnings.toInt()}k VND',
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.account_balance_wallet,
                size: 32.w,
                color: Colors.white.withOpacity(0.8),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: _buildEarningsCard(
                  'Today',
                  '${todayEarnings.toInt()}k VND',
                  '2 jobs',
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildEarningsCard('This Week', '1.2M VND', '8 jobs'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsCard(String title, String amount, String jobs) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            amount,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            jobs,
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

// Mock Job class for testing
class MockJob {
  final String id;
  final String serviceName;
  final String clientName;
  final String earnings;
  final String time;
  final String address;
  final bool isUrgent;
  final String? status;

  MockJob({
    required this.id,
    required this.serviceName,
    required this.clientName,
    required this.earnings,
    required this.time,
    required this.address,
    this.isUrgent = false,
    this.status,
  });

  MockJob copyWith({
    String? id,
    String? serviceName,
    String? clientName,
    String? earnings,
    String? time,
    String? address,
    bool? isUrgent,
    String? status,
  }) {
    return MockJob(
      id: id ?? this.id,
      serviceName: serviceName ?? this.serviceName,
      clientName: clientName ?? this.clientName,
      earnings: earnings ?? this.earnings,
      time: time ?? this.time,
      address: address ?? this.address,
      isUrgent: isUrgent ?? this.isUrgent,
      status: status ?? this.status,
    );
  }
}
