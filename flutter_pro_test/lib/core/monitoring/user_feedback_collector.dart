import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../analytics/firebase_analytics_service.dart';
import 'monitoring_service.dart';
import 'ux_monitoring_service.dart';
import '../config/environment_config.dart';

/// Specialized service for collecting and analyzing user feedback
/// Provides mechanisms for in-app feedback, ratings, surveys, and sentiment analysis
class UserFeedbackCollector {
  static final UserFeedbackCollector _instance =
      UserFeedbackCollector._internal();
  factory UserFeedbackCollector() => _instance;
  UserFeedbackCollector._internal();

  // Dependencies
  late final UXMonitoringService _uxMonitoringService;
  late final FirebaseAnalyticsService _analyticsService;
  late final MonitoringService _monitoringService;
  SharedPreferences? _prefs;

  // State management
  bool _isInitialized = false;

  // Feedback storage
  final List<UserFeedback> _feedbackHistory = [];
  final Map<String, List<UserFeedback>> _feedbackByScreen = {};
  final Map<String, List<UserFeedback>> _feedbackByType = {};
  final Map<String, List<UserFeedback>> _feedbackByUser = {};

  // Feedback analytics
  final Map<String, double> _screenSatisfactionScores = {};
  final Map<String, int> _feedbackCounts = {};
  final Map<String, List<String>> _commonFeedbackPhrases = {};

  // Configuration
  static const int maxFeedbackHistory = 1000;
  static const Duration feedbackPromptInterval = Duration(days: 7);
  static const int minSessionsBeforePrompt = 3;

  // Feedback types
  static const String feedbackTypeGeneral = 'general';
  static const String feedbackTypeUsability = 'usability';
  static const String feedbackTypeFeature = 'feature';
  static const String feedbackTypeBug = 'bug';
  static const String feedbackTypePerformance = 'performance';
  static const String feedbackTypeSuggestion = 'suggestion';

  // Feedback prompts
  final Map<String, String> _feedbackPrompts = {
    feedbackTypeGeneral: 'How would you rate your overall experience?',
    feedbackTypeUsability: 'How easy was it to use this feature?',
    feedbackTypeFeature: 'How satisfied are you with this feature?',
    feedbackTypeBug: 'Did you encounter any issues or bugs?',
    feedbackTypePerformance: 'How would you rate the performance?',
    feedbackTypeSuggestion: 'Do you have any suggestions for improvement?',
  };

  /// Initialize user feedback collector
  Future<void> initialize({
    required UXMonitoringService uxMonitoringService,
    required FirebaseAnalyticsService analyticsService,
    required MonitoringService monitoringService,
  }) async {
    if (_isInitialized) return;

    try {
      _uxMonitoringService = uxMonitoringService;
      _analyticsService = analyticsService;
      _monitoringService = monitoringService;
      _prefs = await SharedPreferences.getInstance();

      // Load persisted feedback
      await _loadPersistedFeedback();

      _isInitialized = true;

      _monitoringService.logInfo(
        'UserFeedbackCollector initialized successfully',
      );
    } catch (e, stackTrace) {
      _monitoringService.logError(
        'Failed to initialize UserFeedbackCollector',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Collect user feedback
  Future<void> collectFeedback({
    required String userId,
    required String screenName,
    required String feedbackType,
    required int rating,
    String? comment,
    Map<String, dynamic>? metadata,
  }) async {
    if (!_isInitialized) {
      _monitoringService.logError('UserFeedbackCollector not initialized');
      return;
    }

    try {
      final feedback = UserFeedback(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sessionId: _uxMonitoringService.currentSessionId ?? 'unknown',
        userId: userId,
        screenName: screenName,
        feedbackType: feedbackType,
        rating: rating,
        comment: comment,
        timestamp: DateTime.now(),
        metadata: metadata ?? {},
      );

      // Add to feedback collections
      _feedbackHistory.add(feedback);
      _feedbackByScreen.putIfAbsent(screenName, () => []).add(feedback);
      _feedbackByType.putIfAbsent(feedbackType, () => []).add(feedback);
      _feedbackByUser.putIfAbsent(userId, () => []).add(feedback);

      // Keep history size manageable
      while (_feedbackHistory.length > maxFeedbackHistory) {
        final oldFeedback = _feedbackHistory.removeAt(0);
        _removeFromCollections(oldFeedback);
      }

      // Update satisfaction scores
      _updateSatisfactionScore(screenName, rating);
      _updateFeedbackCounts(feedbackType);

      // Analyze comment for common phrases
      if (comment != null && comment.isNotEmpty) {
        _analyzeComment(screenName, comment);
      }

      // Save feedback
      await _saveFeedbackData();

      // Track to UX monitoring
      await _uxMonitoringService.collectUserFeedback(
        userId: userId,
        screenName: screenName,
        feedbackType: feedbackType,
        rating: rating,
        comment: comment,
        metadata: metadata,
      );

      // Track to Firebase Analytics
      await _analyticsService.logEvent(
        'user_feedback_submitted',
        parameters: {
          'user_id': userId,
          'screen_name': screenName,
          'feedback_type': feedbackType,
          'rating': rating,
          'has_comment': comment != null && comment.isNotEmpty,
          'timestamp': DateTime.now().toIso8601String(),
          ...?metadata,
        },
      );

      _monitoringService.logInfo(
        'User feedback collected: $feedbackType ($rating/5) on $screenName',
      );
    } catch (e, stackTrace) {
      _monitoringService.logError(
        'Failed to collect user feedback',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Check if feedback prompt should be shown
  Future<bool> shouldShowFeedbackPrompt({
    required String userId,
    required String screenName,
  }) async {
    if (!_isInitialized) return false;

    try {
      // Check if user has recently given feedback
      final lastFeedbackTime = await _getLastFeedbackTime(userId, screenName);
      if (lastFeedbackTime != null) {
        final timeSinceLastFeedback = DateTime.now().difference(
          lastFeedbackTime,
        );
        if (timeSinceLastFeedback < feedbackPromptInterval) {
          return false;
        }
      }

      // Check if user has completed minimum sessions
      final sessionCount = await _getUserSessionCount(userId);
      if (sessionCount < minSessionsBeforePrompt) {
        return false;
      }

      // Check if screen has low satisfaction score or needs more feedback
      final screenFeedback = _feedbackByScreen[screenName] ?? [];
      if (screenFeedback.length < 5) {
        return true; // Need more feedback for this screen
      }

      final satisfactionScore = _screenSatisfactionScores[screenName] ?? 0.0;
      if (satisfactionScore < 3.0) {
        return true; // Low satisfaction score, need more feedback
      }

      // Random prompt based on usage (simplified)
      final random = DateTime.now().millisecondsSinceEpoch % 10;
      return random < 2; // 20% chance
    } catch (e) {
      _monitoringService.logError(
        'Failed to check if feedback prompt should be shown',
        error: e,
      );
      return false;
    }
  }

  /// Get feedback prompt for specific type
  String getFeedbackPrompt(String feedbackType) {
    return _feedbackPrompts[feedbackType] ??
        'How would you rate your experience?';
  }

  /// Get feedback analytics for a screen
  Map<String, dynamic> getFeedbackAnalyticsForScreen(String screenName) {
    final screenFeedback = _feedbackByScreen[screenName] ?? [];

    if (screenFeedback.isEmpty) {
      return {
        'screen_name': screenName,
        'feedback_count': 0,
        'satisfaction_score': 0.0,
        'has_feedback': false,
      };
    }

    // Calculate analytics
    final totalFeedback = screenFeedback.length;
    final averageRating =
        screenFeedback.map((f) => f.rating).reduce((a, b) => a + b) /
        totalFeedback;

    final feedbackByType = <String, int>{};
    for (final feedback in screenFeedback) {
      feedbackByType[feedback.feedbackType] =
          (feedbackByType[feedback.feedbackType] ?? 0) + 1;
    }

    final recentFeedback = screenFeedback
        .take(5)
        .map((f) => f.toMap())
        .toList();

    return {
      'screen_name': screenName,
      'feedback_count': totalFeedback,
      'satisfaction_score': averageRating,
      'feedback_by_type': feedbackByType,
      'recent_feedback': recentFeedback,
      'common_phrases': _commonFeedbackPhrases[screenName] ?? [],
      'has_feedback': true,
    };
  }

  /// Get overall feedback analytics
  Map<String, dynamic> getOverallFeedbackAnalytics() {
    if (_feedbackHistory.isEmpty) {
      return {
        'total_feedback': 0,
        'overall_satisfaction': 0.0,
        'feedback_by_type': <String, int>{},
        'feedback_by_screen': <String, int>{},
        'has_feedback': false,
      };
    }

    // Calculate overall analytics
    final totalFeedback = _feedbackHistory.length;
    final overallSatisfaction =
        _feedbackHistory.map((f) => f.rating).reduce((a, b) => a + b) /
        totalFeedback;

    final feedbackByType = <String, int>{};
    final feedbackByScreen = <String, int>{};

    for (final feedback in _feedbackHistory) {
      feedbackByType[feedback.feedbackType] =
          (feedbackByType[feedback.feedbackType] ?? 0) + 1;
      feedbackByScreen[feedback.screenName] =
          (feedbackByScreen[feedback.screenName] ?? 0) + 1;
    }

    // Get top issues and suggestions (used in analytics methods)

    return {
      'total_feedback': totalFeedback,
      'overall_satisfaction': overallSatisfaction,
      'feedback_by_type': feedbackByType,
      'feedback_by_screen': feedbackByScreen,
      'satisfaction_scores': _screenSatisfactionScores,
      'top_issues': _getTopIssues(),
      'top_suggestions': _getTopSuggestions(),
      'recent_feedback': _feedbackHistory
          .take(10)
          .map((f) => f.toMap())
          .toList(),
      'has_feedback': true,
    };
  }

  /// Get user-specific feedback analytics
  Map<String, dynamic> getUserFeedbackAnalytics(String userId) {
    final userFeedback = _feedbackByUser[userId] ?? [];

    if (userFeedback.isEmpty) {
      return {
        'user_id': userId,
        'feedback_count': 0,
        'average_rating': 0.0,
        'has_feedback': false,
      };
    }

    final totalFeedback = userFeedback.length;
    final averageRating =
        userFeedback.map((f) => f.rating).reduce((a, b) => a + b) /
        totalFeedback;

    final feedbackByType = <String, int>{};
    final feedbackByScreen = <String, int>{};

    for (final feedback in userFeedback) {
      feedbackByType[feedback.feedbackType] =
          (feedbackByType[feedback.feedbackType] ?? 0) + 1;
      feedbackByScreen[feedback.screenName] =
          (feedbackByScreen[feedback.screenName] ?? 0) + 1;
    }

    return {
      'user_id': userId,
      'feedback_count': totalFeedback,
      'average_rating': averageRating,
      'feedback_by_type': feedbackByType,
      'feedback_by_screen': feedbackByScreen,
      'recent_feedback': userFeedback.take(5).map((f) => f.toMap()).toList(),
      'has_feedback': true,
    };
  }

  /// Update satisfaction score for a screen
  void _updateSatisfactionScore(String screenName, int rating) {
    final currentScore = _screenSatisfactionScores[screenName] ?? 0.0;
    final currentCount = _feedbackByScreen[screenName]?.length ?? 1;

    // Calculate weighted average
    final newScore =
        ((currentScore * (currentCount - 1)) + rating) / currentCount;
    _screenSatisfactionScores[screenName] = newScore;
  }

  /// Update feedback counts
  void _updateFeedbackCounts(String feedbackType) {
    _feedbackCounts[feedbackType] = (_feedbackCounts[feedbackType] ?? 0) + 1;
  }

  /// Analyze comment for common phrases (simplified)
  void _analyzeComment(String screenName, String comment) {
    final words = comment.toLowerCase().split(' ');
    final phrases = _commonFeedbackPhrases.putIfAbsent(screenName, () => []);

    // Simple phrase extraction (look for 2-3 word combinations)
    for (int i = 0; i < words.length - 1; i++) {
      final phrase = '${words[i]} ${words[i + 1]}';
      if (phrase.length > 5 && !phrases.contains(phrase)) {
        phrases.add(phrase);
      }
    }

    // Keep only top 10 phrases per screen
    if (phrases.length > 10) {
      phrases.removeRange(0, phrases.length - 10);
    }
  }

  /// Remove feedback from collections when cleaning up old data
  void _removeFromCollections(UserFeedback feedback) {
    _feedbackByScreen[feedback.screenName]?.remove(feedback);
    _feedbackByType[feedback.feedbackType]?.remove(feedback);
    _feedbackByUser[feedback.userId]?.remove(feedback);
  }

  /// Get last feedback time for user and screen
  Future<DateTime?> _getLastFeedbackTime(
    String userId,
    String screenName,
  ) async {
    final userFeedback = _feedbackByUser[userId] ?? [];
    final screenFeedback = userFeedback
        .where((f) => f.screenName == screenName)
        .toList();

    if (screenFeedback.isEmpty) return null;

    screenFeedback.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return screenFeedback.first.timestamp;
  }

  /// Get user session count (simplified - would integrate with session tracker)
  Future<int> _getUserSessionCount(String userId) async {
    // This would integrate with UserSessionTracker in a real implementation
    // For now, return a mock value based on feedback history
    final userFeedback = _feedbackByUser[userId] ?? [];
    return userFeedback.length + 5; // Mock session count
  }

  /// Get top issues from bug reports
  List<Map<String, dynamic>> _getTopIssues() {
    final bugReports = _feedbackByType[feedbackTypeBug] ?? [];
    final issueMap = <String, int>{};

    for (final feedback in bugReports) {
      if (feedback.comment != null && feedback.comment!.isNotEmpty) {
        final key = feedback.comment!.toLowerCase();
        issueMap[key] = (issueMap[key] ?? 0) + 1;
      }
    }

    final sortedIssues = issueMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedIssues
        .take(5)
        .map((entry) => {'issue': entry.key, 'count': entry.value})
        .toList();
  }

  /// Get top suggestions
  List<Map<String, dynamic>> _getTopSuggestions() {
    final suggestions = _feedbackByType[feedbackTypeSuggestion] ?? [];
    final suggestionMap = <String, int>{};

    for (final feedback in suggestions) {
      if (feedback.comment != null && feedback.comment!.isNotEmpty) {
        final key = feedback.comment!.toLowerCase();
        suggestionMap[key] = (suggestionMap[key] ?? 0) + 1;
      }
    }

    final sortedSuggestions = suggestionMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedSuggestions
        .take(5)
        .map((entry) => {'suggestion': entry.key, 'count': entry.value})
        .toList();
  }

  /// Load persisted feedback data
  Future<void> _loadPersistedFeedback() async {
    try {
      final feedbackJson = _prefs?.getString('user_feedback_history');
      if (feedbackJson != null) {
        final feedbackList = jsonDecode(feedbackJson) as List;
        _feedbackHistory.clear();

        for (final item in feedbackList) {
          final feedback = UserFeedback(
            id: item['id'],
            sessionId: item['sessionId'],
            userId: item['userId'],
            screenName: item['screenName'],
            feedbackType: item['feedbackType'],
            rating: item['rating'],
            comment: item['comment'],
            timestamp: DateTime.parse(item['timestamp']),
            metadata: Map<String, dynamic>.from(item['metadata']),
          );

          _feedbackHistory.add(feedback);
          _feedbackByScreen
              .putIfAbsent(feedback.screenName, () => [])
              .add(feedback);
          _feedbackByType
              .putIfAbsent(feedback.feedbackType, () => [])
              .add(feedback);
          _feedbackByUser.putIfAbsent(feedback.userId, () => []).add(feedback);
        }
      }

      // Load satisfaction scores
      final scoresJson = _prefs?.getString('screen_satisfaction_scores');
      if (scoresJson != null) {
        final scoresData = jsonDecode(scoresJson) as Map<String, dynamic>;
        _screenSatisfactionScores.clear();
        scoresData.forEach((key, value) {
          _screenSatisfactionScores[key] = value as double;
        });
      }

      _monitoringService.logInfo('User feedback data loaded successfully');
    } catch (e, stackTrace) {
      _monitoringService.logError(
        'Failed to load persisted feedback data',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Save feedback data to SharedPreferences
  Future<void> _saveFeedbackData() async {
    try {
      // Save feedback history
      final feedbackJson = jsonEncode(
        _feedbackHistory.map((f) => f.toMap()).toList(),
      );
      await _prefs?.setString('user_feedback_history', feedbackJson);

      // Save satisfaction scores
      final scoresJson = jsonEncode(_screenSatisfactionScores);
      await _prefs?.setString('screen_satisfaction_scores', scoresJson);
    } catch (e) {
      _monitoringService.logError('Failed to save feedback data', error: e);
    }
  }

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;

  /// Get total feedback count
  int get totalFeedbackCount => _feedbackHistory.length;

  /// Get feedback types
  static List<String> get feedbackTypes => [
    feedbackTypeGeneral,
    feedbackTypeUsability,
    feedbackTypeFeature,
    feedbackTypeBug,
    feedbackTypePerformance,
    feedbackTypeSuggestion,
  ];

  /// Dispose resources
  Future<void> dispose() async {
    await _saveFeedbackData();
    _isInitialized = false;
  }
}
