// Mocks generated by Mockito 5.4.6 from annotations
// in flutter_pro_test/test/core/analytics/business_metrics_validator_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i5;

import 'package:firebase_analytics/firebase_analytics.dart' as _i2;
import 'package:firebase_performance/firebase_performance.dart' as _i3;
import 'package:flutter_pro_test/core/analytics/business_analytics_service.dart'
    as _i4;
import 'package:flutter_pro_test/core/analytics/firebase_analytics_service.dart'
    as _i6;
import 'package:flutter_pro_test/core/monitoring/monitoring_service.dart'
    as _i7;
import 'package:flutter_pro_test/core/performance/performance_manager.dart'
    as _i8;
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

class _FakeFirebaseAnalytics_0 extends _i1.SmartFake
    implements _i2.FirebaseAnalytics {
  _FakeFirebaseAnalytics_0(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeFirebasePerformance_1 extends _i1.SmartFake
    implements _i3.FirebasePerformance {
  _FakeFirebasePerformance_1(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

/// A class which mocks [BusinessAnalyticsService].
///
/// See the documentation for Mockito's code generation for more information.
class MockBusinessAnalyticsService extends _i1.Mock
    implements _i4.BusinessAnalyticsService {
  MockBusinessAnalyticsService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  bool get isInitialized =>
      (super.noSuchMethod(Invocation.getter(#isInitialized), returnValue: false)
          as bool);

  @override
  _i5.Future<void> initialize({
    required _i6.FirebaseAnalyticsService? analyticsService,
    required _i7.MonitoringService? monitoringService,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#initialize, [], {
              #analyticsService: analyticsService,
              #monitoringService: monitoringService,
            }),
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);

  @override
  _i5.Future<void> setUser({
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
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);

  @override
  _i5.Future<void> trackScreenView({
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
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);

  @override
  _i5.Future<void> trackUserAction({
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
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);

  @override
  _i5.Future<void> trackFunnelStage({
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
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);

  @override
  _i5.Future<void> trackBusinessEvent({
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
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);

  @override
  _i5.Future<void> trackEngagement({
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
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);

  @override
  _i5.Future<void> trackError({
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
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);

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
  _i5.Future<void> dispose() =>
      (super.noSuchMethod(
            Invocation.method(#dispose, []),
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);
}

/// A class which mocks [FirebaseAnalyticsService].
///
/// See the documentation for Mockito's code generation for more information.
class MockFirebaseAnalyticsService extends _i1.Mock
    implements _i6.FirebaseAnalyticsService {
  MockFirebaseAnalyticsService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.FirebaseAnalytics get analytics =>
      (super.noSuchMethod(
            Invocation.getter(#analytics),
            returnValue: _FakeFirebaseAnalytics_0(
              this,
              Invocation.getter(#analytics),
            ),
          )
          as _i2.FirebaseAnalytics);

  @override
  _i3.FirebasePerformance get performance =>
      (super.noSuchMethod(
            Invocation.getter(#performance),
            returnValue: _FakeFirebasePerformance_1(
              this,
              Invocation.getter(#performance),
            ),
          )
          as _i3.FirebasePerformance);

  @override
  bool get isInitialized =>
      (super.noSuchMethod(Invocation.getter(#isInitialized), returnValue: false)
          as bool);

  @override
  _i5.Future<void> initialize() =>
      (super.noSuchMethod(
            Invocation.method(#initialize, []),
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);

  @override
  _i5.Future<void> setUserId(String? userId) =>
      (super.noSuchMethod(
            Invocation.method(#setUserId, [userId]),
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);

  @override
  _i5.Future<void> setUserType(String? userType) =>
      (super.noSuchMethod(
            Invocation.method(#setUserType, [userType]),
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);

  @override
  _i5.Future<void> logEvent(
    String? eventName, {
    Map<String, Object?>? parameters,
  }) =>
      (super.noSuchMethod(
            Invocation.method(
              #logEvent,
              [eventName],
              {#parameters: parameters},
            ),
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);

  @override
  _i5.Future<void> logScreenView({
    required String? screenName,
    String? screenClass,
    Map<String, Object?>? parameters,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#logScreenView, [], {
              #screenName: screenName,
              #screenClass: screenClass,
              #parameters: parameters,
            }),
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);

  @override
  _i5.Future<void> recordError(
    dynamic error,
    StackTrace? stackTrace, {
    Map<String, dynamic>? metadata,
    bool? fatal = false,
  }) =>
      (super.noSuchMethod(
            Invocation.method(
              #recordError,
              [error, stackTrace],
              {#metadata: metadata, #fatal: fatal},
            ),
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);

  @override
  _i5.Future<_i3.Trace?> startTrace(String? traceName) =>
      (super.noSuchMethod(
            Invocation.method(#startTrace, [traceName]),
            returnValue: _i5.Future<_i3.Trace?>.value(),
          )
          as _i5.Future<_i3.Trace?>);

  @override
  _i5.Future<void> stopTrace(String? traceName) =>
      (super.noSuchMethod(
            Invocation.method(#stopTrace, [traceName]),
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);

  @override
  _i5.Future<void> setTraceAttribute(
    String? traceName,
    String? attribute,
    String? value,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#setTraceAttribute, [
              traceName,
              attribute,
              value,
            ]),
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);

  @override
  _i5.Future<_i3.HttpMetric?> startHttpMetric(
    String? url,
    _i3.HttpMethod? httpMethod,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#startHttpMetric, [url, httpMethod]),
            returnValue: _i5.Future<_i3.HttpMetric?>.value(),
          )
          as _i5.Future<_i3.HttpMetric?>);

  @override
  _i5.Future<void> stopHttpMetric(
    String? url, {
    int? responseCode,
    int? requestPayloadSize,
    int? responsePayloadSize,
  }) =>
      (super.noSuchMethod(
            Invocation.method(
              #stopHttpMetric,
              [url],
              {
                #responseCode: responseCode,
                #requestPayloadSize: requestPayloadSize,
                #responsePayloadSize: responsePayloadSize,
              },
            ),
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);

  @override
  _i5.Future<void> dispose() =>
      (super.noSuchMethod(
            Invocation.method(#dispose, []),
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);
}

/// A class which mocks [MonitoringService].
///
/// See the documentation for Mockito's code generation for more information.
class MockMonitoringService extends _i1.Mock implements _i7.MonitoringService {
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
  _i5.Future<void> initialize({
    _i6.FirebaseAnalyticsService? analyticsService,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#initialize, [], {
              #analyticsService: analyticsService,
            }),
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);

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
  List<_i7.LogEntry> getRecentLogs({
    int? limit = 100,
    _i7.LogLevel? minLevel,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#getRecentLogs, [], {
              #limit: limit,
              #minLevel: minLevel,
            }),
            returnValue: <_i7.LogEntry>[],
          )
          as List<_i7.LogEntry>);

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
  _i5.Future<void> trackPerformanceMetric({
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
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);

  @override
  _i5.Future<void> trackError({
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
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);

  @override
  _i5.Future<void> trackUserAction({
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
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);

  @override
  _i5.Future<void> trackScreenView({
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
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);

  @override
  void dispose() => super.noSuchMethod(
    Invocation.method(#dispose, []),
    returnValueForMissingStub: null,
  );
}

/// A class which mocks [PerformanceManager].
///
/// See the documentation for Mockito's code generation for more information.
class MockPerformanceManager extends _i1.Mock
    implements _i8.PerformanceManager {
  MockPerformanceManager() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i5.Future<void> initialize() =>
      (super.noSuchMethod(
            Invocation.method(#initialize, []),
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);

  @override
  void cacheData(String? key, dynamic data, {Duration? expiration}) =>
      super.noSuchMethod(
        Invocation.method(#cacheData, [key, data], {#expiration: expiration}),
        returnValueForMissingStub: null,
      );

  @override
  T? getCachedData<T>(String? key) =>
      (super.noSuchMethod(Invocation.method(#getCachedData, [key])) as T?);

  @override
  bool isCached(String? key) =>
      (super.noSuchMethod(
            Invocation.method(#isCached, [key]),
            returnValue: false,
          )
          as bool);

  @override
  void clearCache(String? key) => super.noSuchMethod(
    Invocation.method(#clearCache, [key]),
    returnValueForMissingStub: null,
  );

  @override
  void clearAllCache() => super.noSuchMethod(
    Invocation.method(#clearAllCache, []),
    returnValueForMissingStub: null,
  );

  @override
  void recordEvent(
    String? name, {
    Duration? duration,
    Map<String, dynamic>? metadata,
  }) => super.noSuchMethod(
    Invocation.method(
      #recordEvent,
      [name],
      {#duration: duration, #metadata: metadata},
    ),
    returnValueForMissingStub: null,
  );

  @override
  Map<String, dynamic> getPerformanceStats() =>
      (super.noSuchMethod(
            Invocation.method(#getPerformanceStats, []),
            returnValue: <String, dynamic>{},
          )
          as Map<String, dynamic>);

  @override
  List<_i8.PerformanceEvent> getRecentEvents({int? limit = 50}) =>
      (super.noSuchMethod(
            Invocation.method(#getRecentEvents, [], {#limit: limit}),
            returnValue: <_i8.PerformanceEvent>[],
          )
          as List<_i8.PerformanceEvent>);

  @override
  void dispose() => super.noSuchMethod(
    Invocation.method(#dispose, []),
    returnValueForMissingStub: null,
  );
}
