// Mocks generated by Mockito 5.4.6 from annotations
// in flutter_pro_test/test/core/analytics/user_behavior_tracking_service_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i3;

import 'package:flutter_pro_test/core/analytics/business_analytics_service.dart'
    as _i2;
import 'package:flutter_pro_test/core/analytics/firebase_analytics_service.dart'
    as _i4;
import 'package:flutter_pro_test/core/monitoring/monitoring_service.dart'
    as _i5;
import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: must_be_immutable
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

/// A class which mocks [BusinessAnalyticsService].
///
/// See the documentation for Mockito's code generation for more information.
class MockBusinessAnalyticsService extends _i1.Mock
    implements _i2.BusinessAnalyticsService {
  MockBusinessAnalyticsService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  bool get isInitialized =>
      (super.noSuchMethod(Invocation.getter(#isInitialized), returnValue: false)
          as bool);

  @override
  _i3.Future<void> initialize({
    required _i4.FirebaseAnalyticsService? analyticsService,
    required _i5.MonitoringService? monitoringService,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#initialize, [], {
              #analyticsService: analyticsService,
              #monitoringService: monitoringService,
            }),
            returnValue: _i3.Future<void>.value(),
            returnValueForMissingStub: _i3.Future<void>.value(),
          )
          as _i3.Future<void>);

  @override
  _i3.Future<void> setUser({
    required String? userId,
    required String? userType,
    Map<String, String>? userProperties,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#setUser, [], {
              #userId: userId,
              #userType: userType,
              #userProperties: userProperties,
            }),
            returnValue: _i3.Future<void>.value(),
            returnValueForMissingStub: _i3.Future<void>.value(),
          )
          as _i3.Future<void>);

  @override
  _i3.Future<void> trackScreenView({
    required String? screenName,
    String? screenClass,
    Map<String, Object?>? parameters,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#trackScreenView, [], {
              #screenName: screenName,
              #screenClass: screenClass,
              #parameters: parameters,
            }),
            returnValue: _i3.Future<void>.value(),
            returnValueForMissingStub: _i3.Future<void>.value(),
          )
          as _i3.Future<void>);

  @override
  _i3.Future<void> trackUserAction({
    required String? actionName,
    String? category,
    String? screenName,
    Map<String, Object?>? parameters,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#trackUserAction, [], {
              #actionName: actionName,
              #category: category,
              #screenName: screenName,
              #parameters: parameters,
            }),
            returnValue: _i3.Future<void>.value(),
            returnValueForMissingStub: _i3.Future<void>.value(),
          )
          as _i3.Future<void>);

  @override
  _i3.Future<void> trackFunnelStage({
    required String? funnelName,
    required String? stageName,
    Map<String, Object?>? parameters,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#trackFunnelStage, [], {
              #funnelName: funnelName,
              #stageName: stageName,
              #parameters: parameters,
            }),
            returnValue: _i3.Future<void>.value(),
            returnValueForMissingStub: _i3.Future<void>.value(),
          )
          as _i3.Future<void>);

  @override
  _i3.Future<void> trackBusinessEvent({
    required String? eventName,
    double? revenue,
    String? currency,
    Map<String, Object?>? parameters,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#trackBusinessEvent, [], {
              #eventName: eventName,
              #revenue: revenue,
              #currency: currency,
              #parameters: parameters,
            }),
            returnValue: _i3.Future<void>.value(),
            returnValueForMissingStub: _i3.Future<void>.value(),
          )
          as _i3.Future<void>);

  @override
  _i3.Future<void> trackEngagement({
    required String? engagementType,
    Duration? duration,
    int? count,
    Map<String, Object?>? parameters,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#trackEngagement, [], {
              #engagementType: engagementType,
              #duration: duration,
              #count: count,
              #parameters: parameters,
            }),
            returnValue: _i3.Future<void>.value(),
            returnValueForMissingStub: _i3.Future<void>.value(),
          )
          as _i3.Future<void>);

  @override
  _i3.Future<void> trackError({
    required String? errorType,
    required dynamic error,
    StackTrace? stackTrace,
    String? screenName,
    String? userAction,
    Map<String, dynamic>? metadata,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#trackError, [], {
              #errorType: errorType,
              #error: error,
              #stackTrace: stackTrace,
              #screenName: screenName,
              #userAction: userAction,
              #metadata: metadata,
            }),
            returnValue: _i3.Future<void>.value(),
            returnValueForMissingStub: _i3.Future<void>.value(),
          )
          as _i3.Future<void>);

  @override
  List<String> getUserJourney() =>
      (super.noSuchMethod(
            Invocation.method(#getUserJourney, []),
            returnValue: <String>[],
          )
          as List<String>);

  @override
  Map<String, int> getFeatureUsageStats() =>
      (super.noSuchMethod(
            Invocation.method(#getFeatureUsageStats, []),
            returnValue: <String, int>{},
          )
          as Map<String, int>);

  @override
  Map<String, dynamic> getSessionInfo() =>
      (super.noSuchMethod(
            Invocation.method(#getSessionInfo, []),
            returnValue: <String, dynamic>{},
          )
          as Map<String, dynamic>);

  @override
  _i3.Future<void> dispose() =>
      (super.noSuchMethod(
            Invocation.method(#dispose, []),
            returnValue: _i3.Future<void>.value(),
            returnValueForMissingStub: _i3.Future<void>.value(),
          )
          as _i3.Future<void>);
}

/// A class which mocks [MonitoringService].
///
/// See the documentation for Mockito's code generation for more information.
class MockMonitoringService extends _i1.Mock implements _i5.MonitoringService {
  MockMonitoringService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  bool get isAnalyticsEnabled =>
      (super.noSuchMethod(
            Invocation.getter(#isAnalyticsEnabled),
            returnValue: false,
          )
          as bool);

  @override
  _i3.Future<void> initialize({
    _i4.FirebaseAnalyticsService? analyticsService,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#initialize, [], {
              #analyticsService: analyticsService,
            }),
            returnValue: _i3.Future<void>.value(),
            returnValueForMissingStub: _i3.Future<void>.value(),
          )
          as _i3.Future<void>);

  @override
  void logDebug(String? message, {Map<String, dynamic>? metadata}) =>
      super.noSuchMethod(
        Invocation.method(#logDebug, [message], {#metadata: metadata}),
        returnValueForMissingStub: null,
      );

  @override
  void logInfo(String? message, {Map<String, dynamic>? metadata}) =>
      super.noSuchMethod(
        Invocation.method(#logInfo, [message], {#metadata: metadata}),
        returnValueForMissingStub: null,
      );

  @override
  void logWarning(String? message, {Map<String, dynamic>? metadata}) =>
      super.noSuchMethod(
        Invocation.method(#logWarning, [message], {#metadata: metadata}),
        returnValueForMissingStub: null,
      );

  @override
  void logError(
    String? message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) => super.noSuchMethod(
    Invocation.method(
      #logError,
      [message],
      {#error: error, #stackTrace: stackTrace, #metadata: metadata},
    ),
    returnValueForMissingStub: null,
  );

  @override
  void logCritical(
    String? message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) => super.noSuchMethod(
    Invocation.method(
      #logCritical,
      [message],
      {#error: error, #stackTrace: stackTrace, #metadata: metadata},
    ),
    returnValueForMissingStub: null,
  );

  @override
  List<_i5.LogEntry> getRecentLogs({
    int? limit = 100,
    _i5.LogLevel? minLevel,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#getRecentLogs, [], {
              #limit: limit,
              #minLevel: minLevel,
            }),
            returnValue: <_i5.LogEntry>[],
          )
          as List<_i5.LogEntry>);

  @override
  Map<String, dynamic> getErrorStats() =>
      (super.noSuchMethod(
            Invocation.method(#getErrorStats, []),
            returnValue: <String, dynamic>{},
          )
          as Map<String, dynamic>);

  @override
  Map<String, dynamic> getHealthStatus() =>
      (super.noSuchMethod(
            Invocation.method(#getHealthStatus, []),
            returnValue: <String, dynamic>{},
          )
          as Map<String, dynamic>);

  @override
  void clearLogs() => super.noSuchMethod(
    Invocation.method(#clearLogs, []),
    returnValueForMissingStub: null,
  );

  @override
  _i3.Future<void> trackPerformanceMetric({
    required String? metricName,
    required Duration? duration,
    Map<String, Object?>? additionalData,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#trackPerformanceMetric, [], {
              #metricName: metricName,
              #duration: duration,
              #additionalData: additionalData,
            }),
            returnValue: _i3.Future<void>.value(),
            returnValueForMissingStub: _i3.Future<void>.value(),
          )
          as _i3.Future<void>);

  @override
  _i3.Future<void> trackError({
    required String? errorType,
    required dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
    bool? fatal = false,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#trackError, [], {
              #errorType: errorType,
              #error: error,
              #stackTrace: stackTrace,
              #metadata: metadata,
              #fatal: fatal,
            }),
            returnValue: _i3.Future<void>.value(),
            returnValueForMissingStub: _i3.Future<void>.value(),
          )
          as _i3.Future<void>);

  @override
  _i3.Future<void> trackUserAction({
    required String? actionName,
    String? screenName,
    Map<String, Object?>? parameters,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#trackUserAction, [], {
              #actionName: actionName,
              #screenName: screenName,
              #parameters: parameters,
            }),
            returnValue: _i3.Future<void>.value(),
            returnValueForMissingStub: _i3.Future<void>.value(),
          )
          as _i3.Future<void>);

  @override
  _i3.Future<void> trackScreenView({
    required String? screenName,
    String? screenClass,
    Map<String, Object?>? parameters,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#trackScreenView, [], {
              #screenName: screenName,
              #screenClass: screenClass,
              #parameters: parameters,
            }),
            returnValue: _i3.Future<void>.value(),
            returnValueForMissingStub: _i3.Future<void>.value(),
          )
          as _i3.Future<void>);

  @override
  void dispose() => super.noSuchMethod(
    Invocation.method(#dispose, []),
    returnValueForMissingStub: null,
  );
}
