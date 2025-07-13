import 'dart:math' as math;

/// Utility class for generating mock data for testing analytics and monitoring services
class MockDataGenerators {
  static final _random = math.Random();

  // Sample data pools
  static const _eventNames = [
    'user_login',
    'booking_created',
    'payment_processed',
    'service_completed',
    'user_logout',
    'profile_updated',
    'notification_sent',
    'error_occurred',
  ];

  static const _userIds = [
    'user_001',
    'user_002',
    'user_003',
    'user_004',
    'user_005',
  ];

  static const _screenNames = [
    'home_screen',
    'booking_screen',
    'profile_screen',
    'payment_screen',
    'services_screen',
  ];

  static const _errorTypes = [
    'network_error',
    'validation_error',
    'database_error',
    'ui_error',
    'performance_error',
  ];

  /// Generate a random analytics event
  static Map<String, dynamic> generateAnalyticsEvent({
    String? eventName,
    String? userId,
    DateTime? timestamp,
    Map<String, dynamic>? customParameters,
  }) {
    return {
      'name': eventName ?? _randomElement(_eventNames),
      'timestamp': timestamp ?? _randomDateTime(),
      'userId': userId ?? _randomElement(_userIds),
      'sessionId': 'session_${_random.nextInt(1000)}',
      'parameters': {
        'screen_name': _randomElement(_screenNames),
        'app_version': '1.0.${_random.nextInt(10)}',
        'platform': _random.nextBool() ? 'android' : 'ios',
        'duration_ms': _random.nextInt(5000),
        ...?customParameters,
      },
    };
  }

  /// Generate a batch of analytics events
  static List<Map<String, dynamic>> generateAnalyticsEventBatch({
    int count = 10,
    DateTime? startTime,
    Duration? timeSpan,
  }) {
    final events = <Map<String, dynamic>>[];
    final baseTime =
        startTime ?? DateTime.now().subtract(const Duration(hours: 24));
    final span = timeSpan ?? const Duration(hours: 24);

    for (int i = 0; i < count; i++) {
      final eventTime = baseTime.add(
        Duration(milliseconds: (span.inMilliseconds * i / count).round()),
      );
      events.add(generateAnalyticsEvent(timestamp: eventTime));
    }

    return events;
  }

  /// Generate a random user behavior event
  static Map<String, dynamic> generateUserBehaviorEvent({
    String? userId,
    String? action,
    DateTime? timestamp,
  }) {
    return {
      'userId': userId ?? _randomElement(_userIds),
      'action':
          action ?? _randomElement(['tap', 'scroll', 'swipe', 'long_press']),
      'screen': _randomElement(_screenNames),
      'timestamp': timestamp ?? _randomDateTime(),
      'metadata': {
        'x_coordinate': _random.nextInt(400),
        'y_coordinate': _random.nextInt(800),
        'element_id': 'element_${_random.nextInt(100)}',
        'session_duration': _random.nextInt(3600),
      },
    };
  }

  /// Generate business metrics data
  static Map<String, dynamic> generateBusinessMetrics({
    DateTime? date,
    double? revenue,
    int? bookings,
  }) {
    return {
      'date': date ?? DateTime.now(),
      'totalRevenue': revenue ?? (_random.nextDouble() * 10000),
      'totalBookings': bookings ?? _random.nextInt(100),
      'activeUsers': _random.nextInt(500),
      'conversionRate': _random.nextDouble() * 0.1,
      'averageOrderValue': _random.nextDouble() * 200 + 50,
      'customerSatisfactionScore': _random.nextDouble() * 2 + 3, // 3-5 range
      'metadata': {
        'top_service': 'cleaning',
        'peak_hour': '${_random.nextInt(24)}:00',
        'platform_split': {
          'android': _random.nextDouble(),
          'ios': _random.nextDouble(),
        },
      },
    };
  }

  /// Generate performance metrics
  static Map<String, dynamic> generatePerformanceMetric({
    String? name,
    double? value,
    DateTime? timestamp,
  }) {
    return {
      'name':
          name ??
          _randomElement([
            'app_startup_time',
            'api_response_time',
            'memory_usage',
            'cpu_usage',
            'battery_usage',
          ]),
      'value': value ?? (_random.nextDouble() * 1000),
      'timestamp': timestamp ?? _randomDateTime(),
      'unit': _randomElement(['ms', 'mb', '%', 'bytes']),
      'metadata': {
        'device_model': _randomElement([
          'iPhone 12',
          'Samsung Galaxy S21',
          'Pixel 5',
        ]),
        'os_version': _randomElement(['iOS 15.0', 'Android 11', 'Android 12']),
        'app_version': '1.0.${_random.nextInt(10)}',
      },
    };
  }

  /// Generate log entries for monitoring
  static Map<String, dynamic> generateLogEntry({
    String? level,
    String? message,
    DateTime? timestamp,
  }) {
    return {
      'level':
          level ?? _randomElement(['info', 'warning', 'error', 'critical']),
      'message': message ?? 'Test log message ${_random.nextInt(1000)}',
      'timestamp': timestamp ?? _randomDateTime(),
      'metadata': {
        'source': _randomElement(['api', 'ui', 'database', 'cache']),
        'thread_id': _random.nextInt(10),
        'request_id': 'req_${_random.nextInt(10000)}',
      },
    };
  }

  /// Generate error incidents
  static Map<String, dynamic> generateErrorIncident({
    String? errorType,
    String? errorMessage,
    DateTime? timestamp,
  }) {
    return {
      'id': 'incident_${DateTime.now().millisecondsSinceEpoch}',
      'errorType': errorType ?? _randomElement(_errorTypes),
      'errorMessage':
          errorMessage ?? 'Test error message ${_random.nextInt(1000)}',
      'timestamp': timestamp ?? _randomDateTime(),
      'severity': _randomElement(['low', 'medium', 'high', 'critical']),
      'stackTrace':
          'Stack trace line 1\nStack trace line 2\nStack trace line 3',
      'userId': _randomElement(_userIds),
      'screenName': _randomElement(_screenNames),
      'metadata': {
        'error_code': _random.nextInt(1000),
        'retry_count': _random.nextInt(5),
        'network_status': _random.nextBool() ? 'connected' : 'disconnected',
      },
    };
  }

  /// Generate load test data for performance testing
  static Map<String, dynamic> generateLoadTestData({
    int eventCount = 1000,
    int userCount = 100,
    Duration timeSpan = const Duration(hours: 1),
  }) {
    final events = <Map<String, dynamic>>[];
    final userBehaviors = <Map<String, dynamic>>[];
    final performanceMetrics = <Map<String, dynamic>>[];
    final logEntries = <Map<String, dynamic>>[];
    final errorIncidents = <Map<String, dynamic>>[];

    final startTime = DateTime.now().subtract(timeSpan);

    // Generate events distributed over time
    for (int i = 0; i < eventCount; i++) {
      final eventTime = startTime.add(
        Duration(
          milliseconds: (timeSpan.inMilliseconds * i / eventCount).round(),
        ),
      );

      events.add(generateAnalyticsEvent(timestamp: eventTime));

      if (i % 5 == 0) {
        userBehaviors.add(generateUserBehaviorEvent(timestamp: eventTime));
      }

      if (i % 10 == 0) {
        performanceMetrics.add(generatePerformanceMetric(timestamp: eventTime));
      }

      if (i % 20 == 0) {
        logEntries.add(generateLogEntry(timestamp: eventTime));
      }

      if (i % 100 == 0) {
        errorIncidents.add(generateErrorIncident(timestamp: eventTime));
      }
    }

    return {
      'events': events,
      'user_behaviors': userBehaviors,
      'performance_metrics': performanceMetrics,
      'log_entries': logEntries,
      'error_incidents': errorIncidents,
      'metadata': {
        'generated_at': DateTime.now(),
        'event_count': eventCount,
        'user_count': userCount,
        'time_span_hours': timeSpan.inHours,
      },
    };
  }

  /// Generate realistic user journey data
  static List<Map<String, dynamic>> generateUserJourney({
    String? userId,
    int stepCount = 10,
  }) {
    final journey = <Map<String, dynamic>>[];
    final user = userId ?? _randomElement(_userIds);
    var currentTime = DateTime.now().subtract(const Duration(minutes: 30));

    // Typical user journey: login -> browse -> book -> pay -> complete
    final journeySteps = [
      {'action': 'login', 'screen': 'login_screen'},
      {'action': 'tap', 'screen': 'home_screen'},
      {'action': 'scroll', 'screen': 'services_screen'},
      {'action': 'tap', 'screen': 'service_detail_screen'},
      {'action': 'tap', 'screen': 'booking_screen'},
      {'action': 'input', 'screen': 'booking_form_screen'},
      {'action': 'tap', 'screen': 'payment_screen'},
      {'action': 'input', 'screen': 'payment_form_screen'},
      {'action': 'tap', 'screen': 'confirmation_screen'},
      {'action': 'logout', 'screen': 'profile_screen'},
    ];

    for (int i = 0; i < math.min(stepCount, journeySteps.length); i++) {
      final step = journeySteps[i];
      journey.add({
        'userId': user,
        'action': step['action']!,
        'screen': step['screen']!,
        'timestamp': currentTime,
        'metadata': {
          'journey_step': i + 1,
          'total_steps': stepCount,
          'session_id':
              'session_${user}_${DateTime.now().millisecondsSinceEpoch}',
        },
      });

      // Add realistic time gaps between actions
      currentTime = currentTime.add(
        Duration(seconds: _random.nextInt(60) + 10),
      );
    }

    return journey;
  }

  // Helper methods
  static T _randomElement<T>(List<T> list) {
    return list[_random.nextInt(list.length)];
  }

  static DateTime _randomDateTime() {
    final now = DateTime.now();
    final daysAgo = _random.nextInt(30);
    final hoursAgo = _random.nextInt(24);
    final minutesAgo = _random.nextInt(60);

    return now.subtract(
      Duration(days: daysAgo, hours: hoursAgo, minutes: minutesAgo),
    );
  }
}
