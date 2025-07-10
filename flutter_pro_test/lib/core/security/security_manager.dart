import 'dart:convert';
import 'dart:math' as math;
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../errors/exceptions.dart';

/// Comprehensive security manager for the CareNow application
class SecurityManager {
  static final SecurityManager _instance = SecurityManager._internal();
  factory SecurityManager() => _instance;
  SecurityManager._internal();

  static const String _sessionTokenKey = 'session_token';
  static const String _lastActivityKey = 'last_activity';
  static const String _failedAttemptsKey = 'failed_attempts';
  static const String _lockoutTimeKey = 'lockout_time';
  static const String _encryptionKeyKey = 'encryption_key';

  // Security configuration
  static const int maxFailedAttempts = 5;
  static const int lockoutDurationMinutes = 15;
  static const int sessionTimeoutMinutes = 30;
  static const int maxSessionDurationHours = 8;

  SharedPreferences? _prefs;
  String? _currentSessionToken;
  DateTime? _lastActivity;

  /// Initialize security manager
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _currentSessionToken = _prefs?.getString(_sessionTokenKey);
    final lastActivityMs = _prefs?.getInt(_lastActivityKey);
    if (lastActivityMs != null) {
      _lastActivity = DateTime.fromMillisecondsSinceEpoch(lastActivityMs);
    }
  }

  /// Generate secure session token
  String generateSessionToken() {
    final random = math.Random.secure();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    final token = base64Url.encode(bytes);
    _currentSessionToken = token;
    _updateLastActivity();
    _saveSessionData();
    return token;
  }

  /// Validate session token and check timeout
  bool validateSession(String? token) {
    if (token == null || token != _currentSessionToken) {
      return false;
    }

    if (_lastActivity == null) {
      return false;
    }

    final now = DateTime.now();
    final timeSinceLastActivity = now.difference(_lastActivity!);

    // Check session timeout
    if (timeSinceLastActivity.inMinutes > sessionTimeoutMinutes) {
      invalidateSession();
      return false;
    }

    // Check maximum session duration
    final sessionStart = _getSessionStartTime();
    if (sessionStart != null) {
      final sessionDuration = now.difference(sessionStart);
      if (sessionDuration.inHours > maxSessionDurationHours) {
        invalidateSession();
        return false;
      }
    }

    _updateLastActivity();
    return true;
  }

  /// Update last activity timestamp
  void _updateLastActivity() {
    _lastActivity = DateTime.now();
    _prefs?.setInt(_lastActivityKey, _lastActivity!.millisecondsSinceEpoch);
  }

  /// Save session data securely
  void _saveSessionData() {
    if (_currentSessionToken != null) {
      _prefs?.setString(_sessionTokenKey, _currentSessionToken!);
    }
  }

  /// Get session start time
  DateTime? _getSessionStartTime() {
    final startTimeMs = _prefs?.getInt('session_start_time');
    return startTimeMs != null
        ? DateTime.fromMillisecondsSinceEpoch(startTimeMs)
        : null;
  }

  /// Invalidate current session
  void invalidateSession() {
    _currentSessionToken = null;
    _lastActivity = null;
    _prefs?.remove(_sessionTokenKey);
    _prefs?.remove(_lastActivityKey);
    _prefs?.remove('session_start_time');
  }

  /// Check if account is locked due to failed attempts
  bool isAccountLocked(String identifier) {
    final lockoutTime = _prefs?.getInt('${_lockoutTimeKey}_$identifier');
    if (lockoutTime == null) return false;

    final lockoutDateTime = DateTime.fromMillisecondsSinceEpoch(lockoutTime);
    final now = DateTime.now();

    if (now.difference(lockoutDateTime).inMinutes < lockoutDurationMinutes) {
      return true;
    }

    // Lockout period expired, reset failed attempts
    _prefs?.remove('${_failedAttemptsKey}_$identifier');
    _prefs?.remove('${_lockoutTimeKey}_$identifier');
    return false;
  }

  /// Record failed login attempt
  void recordFailedAttempt(String identifier) {
    final currentAttempts =
        _prefs?.getInt('${_failedAttemptsKey}_$identifier') ?? 0;
    final newAttempts = currentAttempts + 1;

    _prefs?.setInt('${_failedAttemptsKey}_$identifier', newAttempts);

    if (newAttempts >= maxFailedAttempts) {
      _prefs?.setInt(
        '${_lockoutTimeKey}_$identifier',
        DateTime.now().millisecondsSinceEpoch,
      );
    }
  }

  /// Clear failed attempts on successful login
  void clearFailedAttempts(String identifier) {
    _prefs?.remove('${_failedAttemptsKey}_$identifier');
    _prefs?.remove('${_lockoutTimeKey}_$identifier');
  }

  /// Get remaining lockout time in minutes
  int getRemainingLockoutTime(String identifier) {
    final lockoutTime = _prefs?.getInt('${_lockoutTimeKey}_$identifier');
    if (lockoutTime == null) return 0;

    final lockoutDateTime = DateTime.fromMillisecondsSinceEpoch(lockoutTime);
    final now = DateTime.now();
    final elapsed = now.difference(lockoutDateTime).inMinutes;

    return math.max(0, lockoutDurationMinutes - elapsed);
  }

  /// Hash password securely
  String hashPassword(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Generate salt for password hashing
  String generateSalt() {
    final random = math.Random.secure();
    final bytes = List<int>.generate(16, (i) => random.nextInt(256));
    return base64Url.encode(bytes);
  }

  /// Encrypt sensitive data
  String encryptData(String data) {
    // Simple XOR encryption for demonstration
    // In production, use proper encryption libraries
    final key = _getOrCreateEncryptionKey();
    final dataBytes = utf8.encode(data);
    final keyBytes = utf8.encode(key);

    final encrypted = <int>[];
    for (int i = 0; i < dataBytes.length; i++) {
      encrypted.add(dataBytes[i] ^ keyBytes[i % keyBytes.length]);
    }

    return base64.encode(encrypted);
  }

  /// Decrypt sensitive data
  String decryptData(String encryptedData) {
    try {
      final key = _getOrCreateEncryptionKey();
      final encryptedBytes = base64.decode(encryptedData);
      final keyBytes = utf8.encode(key);

      final decrypted = <int>[];
      for (int i = 0; i < encryptedBytes.length; i++) {
        decrypted.add(encryptedBytes[i] ^ keyBytes[i % keyBytes.length]);
      }

      return utf8.decode(decrypted);
    } catch (e) {
      throw const SecurityException('Failed to decrypt data');
    }
  }

  /// Get or create encryption key
  String _getOrCreateEncryptionKey() {
    String? key = _prefs?.getString(_encryptionKeyKey);
    if (key == null) {
      key = generateSalt(); // Reuse salt generation for key
      _prefs?.setString(_encryptionKeyKey, key);
    }
    return key;
  }

  /// Validate input for SQL injection and XSS attacks
  bool isInputSafe(String input) {
    if (input.isEmpty) return true;

    // Check for SQL injection patterns
    final sqlPatterns = [
      r"('|(\\')|(;|\\;)|(--|\\/\\*)|(\\||\\|\\|))",
      r"(select|insert|update|delete|drop|create|alter|exec|execute)",
      r"(union|join|where|having|group by|order by)",
      r"(script|javascript|vbscript|onload|onerror|onclick)",
    ];

    final lowerInput = input.toLowerCase();
    for (final pattern in sqlPatterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(lowerInput)) {
        return false;
      }
    }

    return true;
  }

  /// Sanitize input string
  String sanitizeInput(String input) {
    if (input.isEmpty) return input;

    return input
        .replaceAll(RegExp(r'<[^>]*>'), '') // Remove HTML tags
        .replaceAll('<', '')
        .replaceAll('>', '')
        .replaceAll('"', '')
        .replaceAll("'", '')
        .replaceAll(RegExp(r'javascript:', caseSensitive: false), '')
        .replaceAll(RegExp(r'vbscript:', caseSensitive: false), '')
        .trim();
  }

  /// Generate secure random string
  String generateSecureRandomString(int length) {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = math.Random.secure();
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  /// Check if password meets security requirements
  bool isPasswordSecure(String password) {
    if (password.length < 8) return false;

    // Check for at least one uppercase letter
    if (!RegExp(r'[A-Z]').hasMatch(password)) return false;

    // Check for at least one lowercase letter
    if (!RegExp(r'[a-z]').hasMatch(password)) return false;

    // Check for at least one digit
    if (!RegExp(r'[0-9]').hasMatch(password)) return false;

    // Check for at least one special character
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) return false;

    return true;
  }

  /// Rate limiting for API calls
  bool isRateLimited(
    String endpoint, {
    int maxRequests = 10,
    int windowMinutes = 1,
  }) {
    final key = 'rate_limit_$endpoint';
    final now = DateTime.now();
    final windowStart = now.subtract(Duration(minutes: windowMinutes));

    // Get existing requests
    final requestsJson = _prefs?.getString(key);
    List<DateTime> requests = [];

    if (requestsJson != null) {
      try {
        final requestsList = jsonDecode(requestsJson) as List;
        requests = requestsList
            .map((timestamp) => DateTime.fromMillisecondsSinceEpoch(timestamp))
            .where((time) => time.isAfter(windowStart))
            .toList();
      } catch (e) {
        // Invalid data, reset
        requests = [];
      }
    }

    // Check if rate limited
    if (requests.length >= maxRequests) {
      return true;
    }

    // Add current request
    requests.add(now);
    final updatedJson = jsonEncode(
      requests.map((time) => time.millisecondsSinceEpoch).toList(),
    );
    _prefs?.setString(key, updatedJson);

    return false;
  }

  /// Log security event
  void logSecurityEvent({
    required String eventType,
    required String description,
    Map<String, dynamic>? metadata,
  }) {
    final event = {
      'timestamp': DateTime.now().toIso8601String(),
      'type': eventType,
      'description': description,
      'metadata': metadata ?? {},
    };

    if (kDebugMode) {
      print('🔐 Security Event: ${jsonEncode(event)}');
    }

    // In production, send to logging service
    _saveSecurityLog(event);
  }

  /// Save security log locally
  void _saveSecurityLog(Map<String, dynamic> event) {
    const maxLogs = 100;
    final logsJson = _prefs?.getString('security_logs');
    List<dynamic> logs = [];

    if (logsJson != null) {
      try {
        logs = jsonDecode(logsJson) as List;
      } catch (e) {
        logs = [];
      }
    }

    logs.add(event);

    // Keep only recent logs
    if (logs.length > maxLogs) {
      logs = logs.sublist(logs.length - maxLogs);
    }

    _prefs?.setString('security_logs', jsonEncode(logs));
  }

  /// Get security logs
  List<Map<String, dynamic>> getSecurityLogs() {
    final logsJson = _prefs?.getString('security_logs');
    if (logsJson == null) return [];

    try {
      final logs = jsonDecode(logsJson) as List;
      return logs.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  /// Clear all security data
  void clearSecurityData() {
    _prefs?.remove(_sessionTokenKey);
    _prefs?.remove(_lastActivityKey);
    _prefs?.remove(_encryptionKeyKey);
    _prefs?.remove('security_logs');

    // Clear all failed attempts and lockouts
    final keys = _prefs?.getKeys() ?? <String>{};
    for (final key in keys) {
      if (key.startsWith(_failedAttemptsKey) ||
          key.startsWith(_lockoutTimeKey)) {
        _prefs?.remove(key);
      }
    }

    _currentSessionToken = null;
    _lastActivity = null;
  }
}
