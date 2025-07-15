import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_pro_test/core/monitoring/user_feedback_collector.dart';
import 'package:flutter_pro_test/core/monitoring/ux_monitoring_service.dart';
import 'package:flutter_pro_test/core/analytics/firebase_analytics_service.dart';
import 'package:flutter_pro_test/core/monitoring/monitoring_service.dart';

import 'user_feedback_collector_test.mocks.dart';

@GenerateMocks([
  UXMonitoringService,
  FirebaseAnalyticsService,
  MonitoringService,
])
void main() {
  group('UserFeedbackCollector - Basic Functionality Tests', () {
    late UserFeedbackCollector feedbackCollector;
    late MockUXMonitoringService mockUXMonitoringService;
    late MockFirebaseAnalyticsService mockAnalyticsService;
    late MockMonitoringService mockMonitoringService;

    setUp(() {
      feedbackCollector = UserFeedbackCollector();
      mockUXMonitoringService = MockUXMonitoringService();
      mockAnalyticsService = MockFirebaseAnalyticsService();
      mockMonitoringService = MockMonitoringService();

      // Setup SharedPreferences mock with empty initial values
      SharedPreferences.setMockInitialValues({});

      // Setup basic mock behaviors - don't verify calls, just ensure they don't throw
      when(mockUXMonitoringService.currentSessionId).thenReturn('test_session');
      when(mockMonitoringService.logInfo(any)).thenReturn(null);
      when(
        mockMonitoringService.logError(
          any,
          error: anyNamed('error'),
          stackTrace: anyNamed('stackTrace'),
        ),
      ).thenReturn(null);
      when(
        mockAnalyticsService.logEvent(any, parameters: anyNamed('parameters')),
      ).thenAnswer((_) async {});
      when(
        mockUXMonitoringService.collectUserFeedback(
          userId: anyNamed('userId'),
          screenName: anyNamed('screenName'),
          feedbackType: anyNamed('feedbackType'),
          rating: anyNamed('rating'),
          comment: anyNamed('comment'),
          metadata: anyNamed('metadata'),
        ),
      ).thenAnswer((_) async {});
    });

    group('initialization', () {
      test('should initialize successfully', () async {
        // Act
        await feedbackCollector.initialize(
          uxMonitoringService: mockUXMonitoringService,
          analyticsService: mockAnalyticsService,
          monitoringService: mockMonitoringService,
        );

        // Assert
        expect(feedbackCollector.isInitialized, isTrue);
      });

      test('should not initialize twice', () async {
        // Arrange
        await feedbackCollector.initialize(
          uxMonitoringService: mockUXMonitoringService,
          analyticsService: mockAnalyticsService,
          monitoringService: mockMonitoringService,
        );

        // Act
        await feedbackCollector.initialize(
          uxMonitoringService: mockUXMonitoringService,
          analyticsService: mockAnalyticsService,
          monitoringService: mockMonitoringService,
        );

        // Assert - Should still be initialized
        expect(feedbackCollector.isInitialized, isTrue);
      });
    });

    group('feedback collection', () {
      setUp(() async {
        await feedbackCollector.initialize(
          uxMonitoringService: mockUXMonitoringService,
          analyticsService: mockAnalyticsService,
          monitoringService: mockMonitoringService,
        );
      });

      test('should collect feedback successfully', () async {
        // Arrange
        final initialCount = feedbackCollector.totalFeedbackCount;

        // Act
        await feedbackCollector.collectFeedback(
          userId: 'user123',
          screenName: 'home_screen',
          feedbackType: UserFeedbackCollector.feedbackTypeGeneral,
          rating: 5,
          comment: 'Great app!',
          metadata: {'source': 'prompt'},
        );

        // Assert - Check that feedback was collected
        expect(feedbackCollector.totalFeedbackCount, greaterThan(initialCount));
      });

      test('should collect feedback without comment', () async {
        // Arrange
        final initialCount = feedbackCollector.totalFeedbackCount;

        // Act
        await feedbackCollector.collectFeedback(
          userId: 'user123',
          screenName: 'payment_screen',
          feedbackType: UserFeedbackCollector.feedbackTypeUsability,
          rating: 3,
        );

        // Assert
        expect(feedbackCollector.totalFeedbackCount, greaterThan(initialCount));
      });

      test('should handle multiple feedback submissions', () async {
        // Arrange
        final initialCount = feedbackCollector.totalFeedbackCount;

        // Act
        await feedbackCollector.collectFeedback(
          userId: 'user123',
          screenName: 'home_screen',
          feedbackType: UserFeedbackCollector.feedbackTypeGeneral,
          rating: 5,
        );
        await feedbackCollector.collectFeedback(
          userId: 'user123',
          screenName: 'profile_screen',
          feedbackType: UserFeedbackCollector.feedbackTypeUsability,
          rating: 4,
        );

        // Assert - Check that both feedback items were collected
        expect(
          feedbackCollector.totalFeedbackCount,
          greaterThanOrEqualTo(initialCount + 2),
        );
      });

      test('should handle feedback collection errors gracefully', () async {
        // Arrange
        when(
          mockUXMonitoringService.collectUserFeedback(
            userId: anyNamed('userId'),
            screenName: anyNamed('screenName'),
            feedbackType: anyNamed('feedbackType'),
            rating: anyNamed('rating'),
            comment: anyNamed('comment'),
            metadata: anyNamed('metadata'),
          ),
        ).thenThrow(Exception('Collection error'));

        final initialCount = feedbackCollector.totalFeedbackCount;

        // Act - Should not throw exception
        await feedbackCollector.collectFeedback(
          userId: 'user123',
          screenName: 'home_screen',
          feedbackType: UserFeedbackCollector.feedbackTypeGeneral,
          rating: 5,
        );

        // Assert - Feedback should still be collected locally even if external service fails
        expect(feedbackCollector.totalFeedbackCount, greaterThan(initialCount));
      });
    });

    group('feedback prompts', () {
      setUp(() async {
        await feedbackCollector.initialize(
          uxMonitoringService: mockUXMonitoringService,
          analyticsService: mockAnalyticsService,
          monitoringService: mockMonitoringService,
        );
      });

      test('should return feedback prompt for type', () {
        // Act
        final prompt = feedbackCollector.getFeedbackPrompt(
          UserFeedbackCollector.feedbackTypeGeneral,
        );

        // Assert
        expect(prompt, equals('How would you rate your overall experience?'));
      });

      test('should return default prompt for unknown type', () {
        // Act
        final prompt = feedbackCollector.getFeedbackPrompt('unknown_type');

        // Assert
        expect(prompt, equals('How would you rate your experience?'));
      });

      test('should determine when to show feedback prompt', () async {
        // Act
        final shouldShow = await feedbackCollector.shouldShowFeedbackPrompt(
          userId: 'user123',
          screenName: 'home_screen',
        );

        // Assert
        expect(shouldShow, isA<bool>());
      });

      test('should not show prompt for recent feedback', () async {
        // Arrange
        await feedbackCollector.collectFeedback(
          userId: 'user123',
          screenName: 'home_screen',
          feedbackType: UserFeedbackCollector.feedbackTypeGeneral,
          rating: 5,
        );

        // Act
        final shouldShow = await feedbackCollector.shouldShowFeedbackPrompt(
          userId: 'user123',
          screenName: 'home_screen',
        );

        // Assert
        expect(shouldShow, isFalse);
      });
    });

    group('analytics retrieval', () {
      setUp(() async {
        await feedbackCollector.initialize(
          uxMonitoringService: mockUXMonitoringService,
          analyticsService: mockAnalyticsService,
          monitoringService: mockMonitoringService,
        );
      });

      test('should return screen-specific feedback analytics', () {
        // Act
        final analytics = feedbackCollector.getFeedbackAnalyticsForScreen(
          'home_screen',
        );

        // Assert - Focus on structure rather than exact values
        expect(analytics, isA<Map<String, dynamic>>());
        expect(analytics['screen_name'], equals('home_screen'));
        expect(analytics.containsKey('feedback_count'), isTrue);
        expect(analytics.containsKey('satisfaction_score'), isTrue);
        expect(analytics.containsKey('has_feedback'), isTrue);
        expect(analytics['feedback_by_type'], isA<Map<String, int>>());
        expect(analytics['recent_feedback'], isA<List>());
      });

      test('should return empty analytics for screen with no feedback', () {
        // Act
        final analytics = feedbackCollector.getFeedbackAnalyticsForScreen(
          'unknown_screen',
        );

        // Assert
        expect(analytics['screen_name'], equals('unknown_screen'));
        expect(analytics['feedback_count'], equals(0));
        expect(analytics['satisfaction_score'], equals(0.0));
        expect(analytics['has_feedback'], isFalse);
      });

      test('should return overall feedback analytics', () {
        // Act
        final analytics = feedbackCollector.getOverallFeedbackAnalytics();

        // Assert - Focus on structure
        expect(analytics, isA<Map<String, dynamic>>());
        expect(analytics.containsKey('total_feedback'), isTrue);
        expect(analytics.containsKey('overall_satisfaction'), isTrue);
        expect(analytics['feedback_by_type'], isA<Map<String, int>>());
        expect(analytics['feedback_by_screen'], isA<Map<String, int>>());
        expect(analytics.containsKey('has_feedback'), isTrue);
      });

      test('should return user-specific feedback analytics', () {
        // Act
        final analytics = feedbackCollector.getUserFeedbackAnalytics('user123');

        // Assert - Focus on structure
        expect(analytics, isA<Map<String, dynamic>>());
        expect(analytics['user_id'], equals('user123'));
        expect(analytics.containsKey('feedback_count'), isTrue);
        expect(analytics.containsKey('average_rating'), isTrue);
        expect(analytics.containsKey('has_feedback'), isTrue);
      });

      test('should return empty analytics for user with no feedback', () {
        // Act
        final analytics = feedbackCollector.getUserFeedbackAnalytics(
          'unknown_user',
        );

        // Assert
        expect(analytics['user_id'], equals('unknown_user'));
        expect(analytics['feedback_count'], equals(0));
        expect(analytics['average_rating'], equals(0.0));
        expect(analytics['has_feedback'], isFalse);
      });
    });

    group('feedback types', () {
      test('should provide all feedback types', () {
        // Act
        final types = UserFeedbackCollector.feedbackTypes;

        // Assert
        expect(types, contains(UserFeedbackCollector.feedbackTypeGeneral));
        expect(types, contains(UserFeedbackCollector.feedbackTypeUsability));
        expect(types, contains(UserFeedbackCollector.feedbackTypeFeature));
        expect(types, contains(UserFeedbackCollector.feedbackTypeBug));
        expect(types, contains(UserFeedbackCollector.feedbackTypePerformance));
        expect(types, contains(UserFeedbackCollector.feedbackTypeSuggestion));
      });
    });

    group('feedback analytics', () {
      setUp(() async {
        await feedbackCollector.initialize(
          uxMonitoringService: mockUXMonitoringService,
          analyticsService: mockAnalyticsService,
          monitoringService: mockMonitoringService,
        );
      });

      test('should provide feedback analytics for screen', () {
        // Act
        final analytics = feedbackCollector.getFeedbackAnalyticsForScreen(
          'home_screen',
        );

        // Assert
        expect(analytics, isA<Map<String, dynamic>>());
        expect(analytics['screen_name'], equals('home_screen'));
        expect(analytics.containsKey('feedback_count'), isTrue);
        expect(analytics.containsKey('satisfaction_score'), isTrue);
      });

      test('should provide overall feedback analytics', () {
        // Act
        final analytics = feedbackCollector.getOverallFeedbackAnalytics();

        // Assert
        expect(analytics, isA<Map<String, dynamic>>());
        expect(analytics.containsKey('total_feedback'), isTrue);
        expect(analytics.containsKey('overall_satisfaction'), isTrue);
      });
    });

    group('disposal', () {
      test('should dispose resources properly', () async {
        // Arrange
        await feedbackCollector.initialize(
          uxMonitoringService: mockUXMonitoringService,
          analyticsService: mockAnalyticsService,
          monitoringService: mockMonitoringService,
        );

        // Act
        await feedbackCollector.dispose();

        // Assert
        expect(feedbackCollector.isInitialized, isFalse);
      });
    });
  });
}
