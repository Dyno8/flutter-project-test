import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/job.dart';
import 'job_card.dart';

/// Job queue section widget for partner dashboard
class JobQueueSection extends StatefulWidget {
  final List<Job> pendingJobs;
  final List<Job> acceptedJobs;
  final Function(String jobId) onAcceptJob;
  final Function(String jobId, String reason) onRejectJob;
  final Function(String jobId) onStartJob;
  final Function(String jobId) onCompleteJob;

  const JobQueueSection({
    super.key,
    required this.pendingJobs,
    required this.acceptedJobs,
    required this.onAcceptJob,
    required this.onRejectJob,
    required this.onStartJob,
    required this.onCompleteJob,
  });

  @override
  State<JobQueueSection> createState() => _JobQueueSectionState();
}

class _JobQueueSectionState extends State<JobQueueSection>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Job Queue',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to full job queue screen
                },
                child: Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Tab bar
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(8.r),
              ),
              labelColor: Theme.of(context).colorScheme.onPrimary,
              unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
              labelStyle: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.pending_actions, size: 16),
                      SizedBox(width: 4.w),
                      Text('Pending (${widget.pendingJobs.length})'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.work, size: 16),
                      SizedBox(width: 4.w),
                      Text('Active (${widget.acceptedJobs.length})'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // Tab content
          SizedBox(
            height: 400.h, // Fixed height for the tab view
            child: TabBarView(
              controller: _tabController,
              children: [
                // Pending jobs tab
                _buildPendingJobsList(),
                // Active jobs tab
                _buildActiveJobsList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingJobsList() {
    if (widget.pendingJobs.isEmpty) {
      return _buildEmptyState(
        icon: Icons.inbox_outlined,
        title: 'No Pending Jobs',
        subtitle: 'New job requests will appear here',
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: widget.pendingJobs.length,
      itemBuilder: (context, index) {
        final job = widget.pendingJobs[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: JobCard(
            job: job,
            onAccept: () => widget.onAcceptJob(job.id),
            onReject: () => _showRejectDialog(context, job.id),
            showActions: true,
          ),
        );
      },
    );
  }

  Widget _buildActiveJobsList() {
    if (widget.acceptedJobs.isEmpty) {
      return _buildEmptyState(
        icon: Icons.work_outline,
        title: 'No Active Jobs',
        subtitle: 'Accepted jobs will appear here',
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: widget.acceptedJobs.length,
      itemBuilder: (context, index) {
        final job = widget.acceptedJobs[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: JobCard(
            job: job,
            onStart: job.canBeStarted ? () => widget.onStartJob(job.id) : null,
            onComplete: job.canBeCompleted ? () => widget.onCompleteJob(job.id) : null,
            showActions: true,
          ),
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64.w,
            color: Theme.of(context).colorScheme.outline,
          ),
          SizedBox(height: 16.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14.sp,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, String jobId) {
    final reasonController = TextEditingController();
    final reasons = [
      'Not available at this time',
      'Too far from my location',
      'Service not in my expertise',
      'Schedule conflict',
      'Other',
    ];
    String? selectedReason;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Reject Job'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Please select a reason for rejecting this job:'),
              SizedBox(height: 16.h),
              ...reasons.map((reason) => RadioListTile<String>(
                title: Text(reason),
                value: reason,
                groupValue: selectedReason,
                onChanged: (value) {
                  setState(() {
                    selectedReason = value;
                    if (value != 'Other') {
                      reasonController.text = value!;
                    } else {
                      reasonController.clear();
                    }
                  });
                },
                dense: true,
                contentPadding: EdgeInsets.zero,
              )),
              if (selectedReason == 'Other') ...[
                SizedBox(height: 8.h),
                TextField(
                  controller: reasonController,
                  decoration: const InputDecoration(
                    hintText: 'Please specify...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: selectedReason != null && reasonController.text.isNotEmpty
                  ? () {
                      Navigator.pop(context);
                      widget.onRejectJob(jobId, reasonController.text.trim());
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              child: const Text('Reject'),
            ),
          ],
        ),
      ),
    );
  }
}
