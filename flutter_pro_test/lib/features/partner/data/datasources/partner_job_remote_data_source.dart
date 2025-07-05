import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../shared/services/firebase_service.dart';
import '../models/job_model.dart';
import '../models/partner_earnings_model.dart';

/// Remote data source for partner job management
abstract class PartnerJobRemoteDataSource {
  // Job Management
  Future<List<JobModel>> getPendingJobs(String partnerId);
  Future<List<JobModel>> getAcceptedJobs(String partnerId);
  Future<List<JobModel>> getJobHistory(
    String partnerId, {
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 20,
  });
  Future<JobModel> getJobById(String jobId);
  Future<JobModel> acceptJob(String jobId, String partnerId);
  Future<JobModel> rejectJob(String jobId, String partnerId, String reason);
  Future<JobModel> startJob(String jobId, String partnerId);
  Future<JobModel> completeJob(String jobId, String partnerId);
  Future<JobModel> cancelJob(String jobId, String partnerId, String reason);

  // Real-time listeners
  Stream<List<JobModel>> listenToPendingJobs(String partnerId);
  Stream<List<JobModel>> listenToAcceptedJobs(String partnerId);
  Stream<JobModel> listenToJob(String jobId);
  Stream<List<JobModel>> listenToActiveJobs(String partnerId);

  // Earnings Management
  Future<PartnerEarningsModel> getPartnerEarnings(String partnerId);
  Future<PartnerEarningsModel> updatePartnerEarnings(String partnerId, double jobEarnings);
  Future<List<Map<String, dynamic>>> getEarningsByDateRange(
    String partnerId,
    DateTime startDate,
    DateTime endDate,
  );

  // Availability Management
  Future<PartnerAvailabilityModel> getPartnerAvailability(String partnerId);
  Future<PartnerAvailabilityModel> updateAvailabilityStatus(
    String partnerId,
    bool isAvailable,
    String? reason,
  );
  Future<PartnerAvailabilityModel> updateOnlineStatus(String partnerId, bool isOnline);
  Future<PartnerAvailabilityModel> updateWorkingHours(
    String partnerId,
    Map<String, List<String>> workingHours,
  );
  Future<PartnerAvailabilityModel> blockDates(String partnerId, List<String> dates);
  Future<PartnerAvailabilityModel> unblockDates(String partnerId, List<String> dates);
  Future<PartnerAvailabilityModel> setTemporaryUnavailability(
    String partnerId,
    DateTime unavailableUntil,
    String reason,
  );
  Future<PartnerAvailabilityModel> clearTemporaryUnavailability(String partnerId);

  // Statistics
  Future<Map<String, dynamic>> getJobStatistics(
    String partnerId, {
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<Map<String, dynamic>> getPerformanceMetrics(String partnerId);

  // Notifications
  Future<void> markJobNotificationAsRead(String partnerId, String jobId);
  Future<int> getUnreadNotificationsCount(String partnerId);
}

/// Implementation of PartnerJobRemoteDataSource
class PartnerJobRemoteDataSourceImpl implements PartnerJobRemoteDataSource {
  final FirebaseService _firebaseService;

  PartnerJobRemoteDataSourceImpl({required FirebaseService firebaseService})
      : _firebaseService = firebaseService;

  static const String _jobsCollection = 'partner_jobs';
  static const String _earningsCollection = 'partner_earnings';
  static const String _availabilityCollection = 'partner_availability';
  static const String _notificationsCollection = 'partner_notifications';

  @override
  Future<List<JobModel>> getPendingJobs(String partnerId) async {
    try {
      final query = _firebaseService.firestore
          .collection(_jobsCollection)
          .where('partnerId', isEqualTo: partnerId)
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true);

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => JobModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException('Failed to get pending jobs: $e');
    }
  }

  @override
  Future<List<JobModel>> getAcceptedJobs(String partnerId) async {
    try {
      final query = _firebaseService.firestore
          .collection(_jobsCollection)
          .where('partnerId', isEqualTo: partnerId)
          .where('status', whereIn: ['accepted', 'inProgress'])
          .orderBy('scheduledDate', descending: false);

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => JobModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException('Failed to get accepted jobs: $e');
    }
  }

  @override
  Future<List<JobModel>> getJobHistory(
    String partnerId, {
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 20,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firebaseService.firestore
          .collection(_jobsCollection)
          .where('partnerId', isEqualTo: partnerId);

      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      if (startDate != null) {
        query = query.where('scheduledDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('scheduledDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      query = query.orderBy('scheduledDate', descending: true).limit(limit);

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => JobModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException('Failed to get job history: $e');
    }
  }

  @override
  Future<JobModel> getJobById(String jobId) async {
    try {
      final doc = await _firebaseService.getDocument(_jobsCollection, jobId);
      return JobModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException('Failed to get job: $e');
    }
  }

  @override
  Future<JobModel> acceptJob(String jobId, String partnerId) async {
    try {
      final updateData = {
        'status': 'accepted',
        'acceptedAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      };

      await _firebaseService.updateDocument(_jobsCollection, jobId, updateData);
      
      // Also update the corresponding booking status
      await _updateBookingStatus(jobId, 'confirmed');
      
      final doc = await _firebaseService.getDocument(_jobsCollection, jobId);
      return JobModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException('Failed to accept job: $e');
    }
  }

  @override
  Future<JobModel> rejectJob(String jobId, String partnerId, String reason) async {
    try {
      final updateData = {
        'status': 'rejected',
        'rejectionReason': reason,
        'rejectedAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      };

      await _firebaseService.updateDocument(_jobsCollection, jobId, updateData);
      
      // Also update the corresponding booking status
      await _updateBookingStatus(jobId, 'rejected');
      
      final doc = await _firebaseService.getDocument(_jobsCollection, jobId);
      return JobModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException('Failed to reject job: $e');
    }
  }

  @override
  Future<JobModel> startJob(String jobId, String partnerId) async {
    try {
      final updateData = {
        'status': 'inProgress',
        'startedAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      };

      await _firebaseService.updateDocument(_jobsCollection, jobId, updateData);
      
      // Also update the corresponding booking status
      await _updateBookingStatus(jobId, 'inProgress');
      
      final doc = await _firebaseService.getDocument(_jobsCollection, jobId);
      return JobModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException('Failed to start job: $e');
    }
  }

  @override
  Future<JobModel> completeJob(String jobId, String partnerId) async {
    try {
      final updateData = {
        'status': 'completed',
        'completedAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      };

      await _firebaseService.updateDocument(_jobsCollection, jobId, updateData);
      
      // Also update the corresponding booking status
      await _updateBookingStatus(jobId, 'completed');
      
      // Update partner earnings
      final job = await getJobById(jobId);
      await updatePartnerEarnings(partnerId, job.partnerEarnings);
      
      final doc = await _firebaseService.getDocument(_jobsCollection, jobId);
      return JobModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException('Failed to complete job: $e');
    }
  }

  @override
  Future<JobModel> cancelJob(String jobId, String partnerId, String reason) async {
    try {
      final updateData = {
        'status': 'cancelled',
        'rejectionReason': reason,
        'cancelledAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      };

      await _firebaseService.updateDocument(_jobsCollection, jobId, updateData);
      
      // Also update the corresponding booking status
      await _updateBookingStatus(jobId, 'cancelled');
      
      final doc = await _firebaseService.getDocument(_jobsCollection, jobId);
      return JobModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException('Failed to cancel job: $e');
    }
  }

  // Helper method to update booking status
  Future<void> _updateBookingStatus(String jobId, String status) async {
    try {
      // Get the job to find the booking ID
      final jobDoc = await _firebaseService.getDocument(_jobsCollection, jobId);
      final job = JobModel.fromFirestore(jobDoc);
      
      // Update the booking status
      await _firebaseService.updateDocument('bookings', job.bookingId, {
        'status': status,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      // Log error but don't throw to avoid breaking the job update
      print('Failed to update booking status: $e');
    }
  }

  @override
  Stream<List<JobModel>> listenToPendingJobs(String partnerId) {
    try {
      return _firebaseService.firestore
          .collection(_jobsCollection)
          .where('partnerId', isEqualTo: partnerId)
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => JobModel.fromFirestore(doc)).toList());
    } catch (e) {
      throw ServerException('Failed to listen to pending jobs: $e');
    }
  }

  @override
  Stream<List<JobModel>> listenToAcceptedJobs(String partnerId) {
    try {
      return _firebaseService.firestore
          .collection(_jobsCollection)
          .where('partnerId', isEqualTo: partnerId)
          .where('status', whereIn: ['accepted', 'inProgress'])
          .orderBy('scheduledDate', descending: false)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => JobModel.fromFirestore(doc)).toList());
    } catch (e) {
      throw ServerException('Failed to listen to accepted jobs: $e');
    }
  }

  @override
  Stream<JobModel> listenToJob(String jobId) {
    try {
      return _firebaseService.firestore
          .collection(_jobsCollection)
          .doc(jobId)
          .snapshots()
          .map((doc) => JobModel.fromFirestore(doc));
    } catch (e) {
      throw ServerException('Failed to listen to job: $e');
    }
  }

  @override
  Stream<List<JobModel>> listenToActiveJobs(String partnerId) {
    try {
      return _firebaseService.firestore
          .collection(_jobsCollection)
          .where('partnerId', isEqualTo: partnerId)
          .where('status', whereIn: ['pending', 'accepted', 'inProgress'])
          .orderBy('scheduledDate', descending: false)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => JobModel.fromFirestore(doc)).toList());
    } catch (e) {
      throw ServerException('Failed to listen to active jobs: $e');
    }
  }

  @override
  Future<PartnerEarningsModel> getPartnerEarnings(String partnerId) async {
    try {
      final doc = await _firebaseService.getDocument(_earningsCollection, partnerId);
      return PartnerEarningsModel.fromFirestore(doc);
    } catch (e) {
      // If earnings document doesn't exist, create a default one
      final defaultEarnings = PartnerEarningsModel(
        id: partnerId,
        partnerId: partnerId,
        totalEarnings: 0,
        todayEarnings: 0,
        weekEarnings: 0,
        monthEarnings: 0,
        totalJobs: 0,
        todayJobs: 0,
        weekJobs: 0,
        monthJobs: 0,
        averageRating: 0,
        totalReviews: 0,
        platformFeeRate: 0.15,
        lastUpdated: DateTime.now(),
      );
      
      await _firebaseService.setDocument(_earningsCollection, partnerId, defaultEarnings.toMap());
      return defaultEarnings;
    }
  }

  @override
  Future<PartnerEarningsModel> updatePartnerEarnings(String partnerId, double jobEarnings) async {
    try {
      final earnings = await getPartnerEarnings(partnerId);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      // Calculate new earnings
      final newTotalEarnings = earnings.totalEarnings + jobEarnings;
      final newTotalJobs = earnings.totalJobs + 1;
      
      // Update today's earnings if it's the same day
      double newTodayEarnings = earnings.todayEarnings;
      int newTodayJobs = earnings.todayJobs;
      
      if (earnings.lastUpdated.day == today.day &&
          earnings.lastUpdated.month == today.month &&
          earnings.lastUpdated.year == today.year) {
        newTodayEarnings += jobEarnings;
        newTodayJobs += 1;
      } else {
        newTodayEarnings = jobEarnings;
        newTodayJobs = 1;
      }
      
      final updateData = {
        'totalEarnings': newTotalEarnings,
        'todayEarnings': newTodayEarnings,
        'totalJobs': newTotalJobs,
        'todayJobs': newTodayJobs,
        'lastUpdated': Timestamp.fromDate(now),
      };
      
      await _firebaseService.updateDocument(_earningsCollection, partnerId, updateData);
      
      final doc = await _firebaseService.getDocument(_earningsCollection, partnerId);
      return PartnerEarningsModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException('Failed to update partner earnings: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getEarningsByDateRange(
    String partnerId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final query = _firebaseService.firestore
          .collection(_jobsCollection)
          .where('partnerId', isEqualTo: partnerId)
          .where('status', isEqualTo: 'completed')
          .where('completedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('completedAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('completedAt', descending: false);

      final snapshot = await query.get();
      final jobs = snapshot.docs.map((doc) => JobModel.fromFirestore(doc)).toList();
      
      // Group by date
      final Map<String, Map<String, dynamic>> dailyEarnings = {};
      
      for (final job in jobs) {
        if (job.completedAt != null) {
          final dateKey = '${job.completedAt!.year}-${job.completedAt!.month.toString().padLeft(2, '0')}-${job.completedAt!.day.toString().padLeft(2, '0')}';
          
          if (!dailyEarnings.containsKey(dateKey)) {
            dailyEarnings[dateKey] = {
              'date': job.completedAt!,
              'earnings': 0.0,
              'jobsCompleted': 0,
              'hoursWorked': 0.0,
            };
          }
          
          dailyEarnings[dateKey]!['earnings'] += job.partnerEarnings;
          dailyEarnings[dateKey]!['jobsCompleted'] += 1;
          dailyEarnings[dateKey]!['hoursWorked'] += job.hours;
        }
      }
      
      return dailyEarnings.values.toList();
    } catch (e) {
      throw ServerException('Failed to get earnings by date range: $e');
    }
  }

  @override
  Future<PartnerAvailabilityModel> getPartnerAvailability(String partnerId) async {
    try {
      final doc = await _firebaseService.getDocument(_availabilityCollection, partnerId);
      return PartnerAvailabilityModel.fromFirestore(doc);
    } catch (e) {
      // If availability document doesn't exist, create a default one
      final defaultAvailability = PartnerAvailabilityModel(
        partnerId: partnerId,
        isAvailable: true,
        isOnline: false,
        workingHours: {
          'monday': ['09:00', '17:00'],
          'tuesday': ['09:00', '17:00'],
          'wednesday': ['09:00', '17:00'],
          'thursday': ['09:00', '17:00'],
          'friday': ['09:00', '17:00'],
          'saturday': ['09:00', '17:00'],
          'sunday': ['09:00', '17:00'],
        },
        lastUpdated: DateTime.now(),
      );
      
      await _firebaseService.setDocument(_availabilityCollection, partnerId, defaultAvailability.toMap());
      return defaultAvailability;
    }
  }

  @override
  Future<PartnerAvailabilityModel> updateAvailabilityStatus(
    String partnerId,
    bool isAvailable,
    String? reason,
  ) async {
    try {
      final updateData = {
        'isAvailable': isAvailable,
        'unavailabilityReason': reason,
        'lastUpdated': Timestamp.now(),
      };
      
      await _firebaseService.updateDocument(_availabilityCollection, partnerId, updateData);
      
      final doc = await _firebaseService.getDocument(_availabilityCollection, partnerId);
      return PartnerAvailabilityModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException('Failed to update availability status: $e');
    }
  }

  @override
  Future<PartnerAvailabilityModel> updateOnlineStatus(String partnerId, bool isOnline) async {
    try {
      final updateData = {
        'isOnline': isOnline,
        'lastSeen': Timestamp.now(),
        'lastUpdated': Timestamp.now(),
      };
      
      await _firebaseService.updateDocument(_availabilityCollection, partnerId, updateData);
      
      final doc = await _firebaseService.getDocument(_availabilityCollection, partnerId);
      return PartnerAvailabilityModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException('Failed to update online status: $e');
    }
  }

  @override
  Future<PartnerAvailabilityModel> updateWorkingHours(
    String partnerId,
    Map<String, List<String>> workingHours,
  ) async {
    try {
      final updateData = {
        'workingHours': workingHours,
        'lastUpdated': Timestamp.now(),
      };
      
      await _firebaseService.updateDocument(_availabilityCollection, partnerId, updateData);
      
      final doc = await _firebaseService.getDocument(_availabilityCollection, partnerId);
      return PartnerAvailabilityModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException('Failed to update working hours: $e');
    }
  }

  @override
  Future<PartnerAvailabilityModel> blockDates(String partnerId, List<String> dates) async {
    try {
      final availability = await getPartnerAvailability(partnerId);
      final newBlockedDates = [...availability.blockedDates, ...dates].toSet().toList();
      
      final updateData = {
        'blockedDates': newBlockedDates,
        'lastUpdated': Timestamp.now(),
      };
      
      await _firebaseService.updateDocument(_availabilityCollection, partnerId, updateData);
      
      final doc = await _firebaseService.getDocument(_availabilityCollection, partnerId);
      return PartnerAvailabilityModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException('Failed to block dates: $e');
    }
  }

  @override
  Future<PartnerAvailabilityModel> unblockDates(String partnerId, List<String> dates) async {
    try {
      final availability = await getPartnerAvailability(partnerId);
      final newBlockedDates = availability.blockedDates.where((date) => !dates.contains(date)).toList();
      
      final updateData = {
        'blockedDates': newBlockedDates,
        'lastUpdated': Timestamp.now(),
      };
      
      await _firebaseService.updateDocument(_availabilityCollection, partnerId, updateData);
      
      final doc = await _firebaseService.getDocument(_availabilityCollection, partnerId);
      return PartnerAvailabilityModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException('Failed to unblock dates: $e');
    }
  }

  @override
  Future<PartnerAvailabilityModel> setTemporaryUnavailability(
    String partnerId,
    DateTime unavailableUntil,
    String reason,
  ) async {
    try {
      final updateData = {
        'isAvailable': false,
        'unavailableUntil': Timestamp.fromDate(unavailableUntil),
        'unavailabilityReason': reason,
        'lastUpdated': Timestamp.now(),
      };
      
      await _firebaseService.updateDocument(_availabilityCollection, partnerId, updateData);
      
      final doc = await _firebaseService.getDocument(_availabilityCollection, partnerId);
      return PartnerAvailabilityModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException('Failed to set temporary unavailability: $e');
    }
  }

  @override
  Future<PartnerAvailabilityModel> clearTemporaryUnavailability(String partnerId) async {
    try {
      final updateData = {
        'isAvailable': true,
        'unavailableUntil': null,
        'unavailabilityReason': null,
        'lastUpdated': Timestamp.now(),
      };
      
      await _firebaseService.updateDocument(_availabilityCollection, partnerId, updateData);
      
      final doc = await _firebaseService.getDocument(_availabilityCollection, partnerId);
      return PartnerAvailabilityModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException('Failed to clear temporary unavailability: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getJobStatistics(
    String partnerId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firebaseService.firestore
          .collection(_jobsCollection)
          .where('partnerId', isEqualTo: partnerId);

      if (startDate != null) {
        query = query.where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      final snapshot = await query.get();
      final jobs = snapshot.docs.map((doc) => JobModel.fromFirestore(doc)).toList();

      final stats = {
        'totalJobs': jobs.length,
        'pendingJobs': jobs.where((job) => job.status == 'pending').length,
        'acceptedJobs': jobs.where((job) => job.status == 'accepted').length,
        'completedJobs': jobs.where((job) => job.status == 'completed').length,
        'rejectedJobs': jobs.where((job) => job.status == 'rejected').length,
        'cancelledJobs': jobs.where((job) => job.status == 'cancelled').length,
        'totalEarnings': jobs.where((job) => job.status == 'completed').fold(0.0, (sum, job) => sum + job.partnerEarnings),
        'totalHours': jobs.where((job) => job.status == 'completed').fold(0.0, (sum, job) => sum + job.hours),
        'acceptanceRate': jobs.isNotEmpty ? (jobs.where((job) => job.status != 'rejected').length / jobs.length) * 100 : 0.0,
        'completionRate': jobs.where((job) => job.status == 'accepted' || job.status == 'completed').isNotEmpty 
            ? (jobs.where((job) => job.status == 'completed').length / jobs.where((job) => job.status == 'accepted' || job.status == 'completed').length) * 100 
            : 0.0,
      };

      return stats;
    } catch (e) {
      throw ServerException('Failed to get job statistics: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getPerformanceMetrics(String partnerId) async {
    try {
      final earnings = await getPartnerEarnings(partnerId);
      final stats = await getJobStatistics(partnerId);
      
      return {
        'totalEarnings': earnings.totalEarnings,
        'averageRating': earnings.averageRating,
        'totalReviews': earnings.totalReviews,
        'totalJobs': earnings.totalJobs,
        'acceptanceRate': stats['acceptanceRate'],
        'completionRate': stats['completionRate'],
        'averageEarningsPerJob': earnings.averageEarningsPerJob,
        'weeklyGrowth': earnings.weeklyGrowth,
      };
    } catch (e) {
      throw ServerException('Failed to get performance metrics: $e');
    }
  }

  @override
  Future<void> markJobNotificationAsRead(String partnerId, String jobId) async {
    try {
      final notificationId = '${partnerId}_$jobId';
      await _firebaseService.updateDocument(_notificationsCollection, notificationId, {
        'isRead': true,
        'readAt': Timestamp.now(),
      });
    } catch (e) {
      throw ServerException('Failed to mark notification as read: $e');
    }
  }

  @override
  Future<int> getUnreadNotificationsCount(String partnerId) async {
    try {
      final query = _firebaseService.firestore
          .collection(_notificationsCollection)
          .where('partnerId', isEqualTo: partnerId)
          .where('isRead', isEqualTo: false);

      final snapshot = await query.get();
      return snapshot.docs.length;
    } catch (e) {
      throw ServerException('Failed to get unread notifications count: $e');
    }
  }
}
