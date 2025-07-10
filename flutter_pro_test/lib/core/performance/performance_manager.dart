import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Performance monitoring and optimization manager
class PerformanceManager {
  static final PerformanceManager _instance = PerformanceManager._internal();
  factory PerformanceManager() => _instance;
  PerformanceManager._internal();

  final Map<String, dynamic> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  final Map<String, List<int>> _performanceMetrics = {};
  final Queue<PerformanceEvent> _eventQueue = Queue<PerformanceEvent>();
  
  SharedPreferences? _prefs;
  Timer? _metricsTimer;
  
  // Configuration
  static const int maxCacheSize = 100;
  static const int cacheExpirationMinutes = 30;
  static const int maxEventQueueSize = 1000;
  static const int metricsCollectionIntervalSeconds = 60;

  /// Initialize performance manager
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _loadCachedMetrics();
    _startMetricsCollection();
  }

  /// Start collecting performance metrics
  void _startMetricsCollection() {
    _metricsTimer?.cancel();
    _metricsTimer = Timer.periodic(
      const Duration(seconds: metricsCollectionIntervalSeconds),
      (_) => _collectMetrics(),
    );
  }

  /// Collect current performance metrics
  void _collectMetrics() {
    final now = DateTime.now();
    final memoryUsage = _getMemoryUsage();
    final cacheHitRate = _getCacheHitRate();
    
    _recordMetric('memory_usage', memoryUsage);
    _recordMetric('cache_hit_rate', (cacheHitRate * 100).round());
    _recordMetric('cache_size', _cache.length);
    _recordMetric('event_queue_size', _eventQueue.length);
    
    // Save metrics periodically
    _saveMetrics();
  }

  /// Get estimated memory usage
  int _getMemoryUsage() {
    // Simplified memory estimation based on cache size
    int totalSize = 0;
    for (final value in _cache.values) {
      if (value is String) {
        totalSize += value.length * 2; // UTF-16 encoding
      } else if (value is List) {
        totalSize += value.length * 8; // Estimate 8 bytes per item
      } else if (value is Map) {
        totalSize += value.length * 16; // Estimate 16 bytes per entry
      } else {
        totalSize += 8; // Default size
      }
    }
    return totalSize;
  }

  /// Calculate cache hit rate
  double _getCacheHitRate() {
    final hits = _getMetricValue('cache_hits') ?? 0;
    final misses = _getMetricValue('cache_misses') ?? 0;
    final total = hits + misses;
    return total > 0 ? hits / total : 0.0;
  }

  /// Record a performance metric
  void _recordMetric(String key, int value) {
    _performanceMetrics.putIfAbsent(key, () => <int>[]);
    final metrics = _performanceMetrics[key]!;
    metrics.add(value);
    
    // Keep only recent metrics (last 100 values)
    if (metrics.length > 100) {
      metrics.removeAt(0);
    }
  }

  /// Get latest metric value
  int? _getMetricValue(String key) {
    final metrics = _performanceMetrics[key];
    return metrics?.isNotEmpty == true ? metrics!.last : null;
  }

  /// Cache data with expiration
  void cacheData(String key, dynamic data, {Duration? expiration}) {
    // Clean cache if it's getting too large
    if (_cache.length >= maxCacheSize) {
      _cleanExpiredCache();
      if (_cache.length >= maxCacheSize) {
        _evictOldestCacheEntry();
      }
    }
    
    _cache[key] = data;
    _cacheTimestamps[key] = DateTime.now();
    
    if (kDebugMode) {
      print('📦 Cached data for key: $key');
    }
  }

  /// Get cached data
  T? getCachedData<T>(String key) {
    if (!_cache.containsKey(key)) {
      _recordMetric('cache_misses', (_getMetricValue('cache_misses') ?? 0) + 1);
      return null;
    }
    
    final timestamp = _cacheTimestamps[key];
    if (timestamp == null) {
      _cache.remove(key);
      _cacheTimestamps.remove(key);
      _recordMetric('cache_misses', (_getMetricValue('cache_misses') ?? 0) + 1);
      return null;
    }
    
    final now = DateTime.now();
    final age = now.difference(timestamp);
    
    if (age.inMinutes > cacheExpirationMinutes) {
      _cache.remove(key);
      _cacheTimestamps.remove(key);
      _recordMetric('cache_misses', (_getMetricValue('cache_misses') ?? 0) + 1);
      return null;
    }
    
    _recordMetric('cache_hits', (_getMetricValue('cache_hits') ?? 0) + 1);
    return _cache[key] as T?;
  }

  /// Check if data is cached and valid
  bool isCached(String key) {
    return getCachedData(key) != null;
  }

  /// Clear specific cache entry
  void clearCache(String key) {
    _cache.remove(key);
    _cacheTimestamps.remove(key);
  }

  /// Clear all cache
  void clearAllCache() {
    _cache.clear();
    _cacheTimestamps.clear();
  }

  /// Clean expired cache entries
  void _cleanExpiredCache() {
    final now = DateTime.now();
    final expiredKeys = <String>[];
    
    for (final entry in _cacheTimestamps.entries) {
      final age = now.difference(entry.value);
      if (age.inMinutes > cacheExpirationMinutes) {
        expiredKeys.add(entry.key);
      }
    }
    
    for (final key in expiredKeys) {
      _cache.remove(key);
      _cacheTimestamps.remove(key);
    }
    
    if (expiredKeys.isNotEmpty && kDebugMode) {
      print('🧹 Cleaned ${expiredKeys.length} expired cache entries');
    }
  }

  /// Evict oldest cache entry
  void _evictOldestCacheEntry() {
    if (_cacheTimestamps.isEmpty) return;
    
    String? oldestKey;
    DateTime? oldestTime;
    
    for (final entry in _cacheTimestamps.entries) {
      if (oldestTime == null || entry.value.isBefore(oldestTime)) {
        oldestKey = entry.key;
        oldestTime = entry.value;
      }
    }
    
    if (oldestKey != null) {
      _cache.remove(oldestKey);
      _cacheTimestamps.remove(oldestKey);
      
      if (kDebugMode) {
        print('🗑️ Evicted oldest cache entry: $oldestKey');
      }
    }
  }

  /// Record performance event
  void recordEvent(String name, {
    Duration? duration,
    Map<String, dynamic>? metadata,
  }) {
    final event = PerformanceEvent(
      name: name,
      timestamp: DateTime.now(),
      duration: duration,
      metadata: metadata ?? {},
    );
    
    _eventQueue.add(event);
    
    // Keep queue size manageable
    while (_eventQueue.length > maxEventQueueSize) {
      _eventQueue.removeFirst();
    }
    
    if (kDebugMode) {
      print('⚡ Performance event: $name ${duration != null ? '(${duration.inMilliseconds}ms)' : ''}');
    }
  }

  /// Get performance statistics
  Map<String, dynamic> getPerformanceStats() {
    final stats = <String, dynamic>{};
    
    // Cache statistics
    stats['cache_size'] = _cache.length;
    stats['cache_hit_rate'] = _getCacheHitRate();
    stats['memory_usage_bytes'] = _getMemoryUsage();
    
    // Event statistics
    stats['total_events'] = _eventQueue.length;
    
    // Metric averages
    for (final entry in _performanceMetrics.entries) {
      if (entry.value.isNotEmpty) {
        final average = entry.value.reduce((a, b) => a + b) / entry.value.length;
        stats['avg_${entry.key}'] = average.round();
      }
    }
    
    return stats;
  }

  /// Get recent performance events
  List<PerformanceEvent> getRecentEvents({int limit = 50}) {
    final events = _eventQueue.toList();
    events.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return events.take(limit).toList();
  }

  /// Save metrics to persistent storage
  void _saveMetrics() {
    try {
      final metricsJson = jsonEncode(_performanceMetrics);
      _prefs?.setString('performance_metrics', metricsJson);
    } catch (e) {
      if (kDebugMode) {
        print('Failed to save performance metrics: $e');
      }
    }
  }

  /// Load cached metrics from persistent storage
  void _loadCachedMetrics() {
    try {
      final metricsJson = _prefs?.getString('performance_metrics');
      if (metricsJson != null) {
        final decoded = jsonDecode(metricsJson) as Map<String, dynamic>;
        for (final entry in decoded.entries) {
          _performanceMetrics[entry.key] = List<int>.from(entry.value);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to load cached metrics: $e');
      }
    }
  }

  /// Dispose resources
  void dispose() {
    _metricsTimer?.cancel();
    _saveMetrics();
  }
}

/// Performance event data class
class PerformanceEvent {
  final String name;
  final DateTime timestamp;
  final Duration? duration;
  final Map<String, dynamic> metadata;

  const PerformanceEvent({
    required this.name,
    required this.timestamp,
    this.duration,
    required this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'timestamp': timestamp.toIso8601String(),
    'duration_ms': duration?.inMilliseconds,
    'metadata': metadata,
  };
}
