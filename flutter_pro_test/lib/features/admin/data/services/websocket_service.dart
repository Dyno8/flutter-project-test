import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

/// WebSocket service for real-time communication
class WebSocketService {
  static const String _baseUrl = 'ws://localhost:8080'; // Replace with actual WebSocket server
  
  WebSocketChannel? _channel;
  StreamController<Map<String, dynamic>>? _messageController;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  
  bool _isConnected = false;
  bool _shouldReconnect = true;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _reconnectDelay = Duration(seconds: 5);
  static const Duration _heartbeatInterval = Duration(seconds: 30);

  /// Get connection status
  bool get isConnected => _isConnected;

  /// Get message stream
  Stream<Map<String, dynamic>> get messageStream {
    _messageController ??= StreamController<Map<String, dynamic>>.broadcast();
    return _messageController!.stream;
  }

  /// Connect to WebSocket server
  Future<void> connect({String? endpoint}) async {
    if (_isConnected) return;

    try {
      final uri = Uri.parse(endpoint ?? '$_baseUrl/admin-analytics');
      _channel = IOWebSocketChannel.connect(uri);
      
      _isConnected = true;
      _reconnectAttempts = 0;
      
      print('WebSocket connected to: $uri');
      
      // Listen to messages
      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnection,
      );
      
      // Start heartbeat
      _startHeartbeat();
      
      // Send authentication message
      _sendAuthMessage();
      
    } catch (e) {
      print('WebSocket connection failed: $e');
      _handleConnectionFailure();
    }
  }

  /// Disconnect from WebSocket server
  void disconnect() {
    _shouldReconnect = false;
    _cleanup();
  }

  /// Send message to server
  void sendMessage(Map<String, dynamic> message) {
    if (!_isConnected || _channel == null) {
      print('WebSocket not connected. Cannot send message.');
      return;
    }

    try {
      final jsonMessage = jsonEncode(message);
      _channel!.sink.add(jsonMessage);
      print('WebSocket message sent: $jsonMessage');
    } catch (e) {
      print('Failed to send WebSocket message: $e');
    }
  }

  /// Subscribe to specific analytics events
  void subscribeToAnalytics(List<String> eventTypes) {
    sendMessage({
      'type': 'subscribe',
      'events': eventTypes,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Unsubscribe from analytics events
  void unsubscribeFromAnalytics(List<String> eventTypes) {
    sendMessage({
      'type': 'unsubscribe',
      'events': eventTypes,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Request real-time data
  void requestRealtimeData(String dataType) {
    sendMessage({
      'type': 'request_data',
      'dataType': dataType,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Handle incoming messages
  void _handleMessage(dynamic message) {
    try {
      final Map<String, dynamic> data = jsonDecode(message as String);
      
      // Handle different message types
      switch (data['type']) {
        case 'analytics_update':
          _handleAnalyticsUpdate(data);
          break;
        case 'system_event':
          _handleSystemEvent(data);
          break;
        case 'heartbeat_response':
          _handleHeartbeatResponse(data);
          break;
        case 'auth_response':
          _handleAuthResponse(data);
          break;
        case 'error':
          _handleServerError(data);
          break;
        default:
          print('Unknown message type: ${data['type']}');
      }
      
      // Broadcast message to listeners
      _messageController?.add(data);
      
    } catch (e) {
      print('Failed to parse WebSocket message: $e');
    }
  }

  /// Handle analytics update
  void _handleAnalyticsUpdate(Map<String, dynamic> data) {
    print('Analytics update received: ${data['dataType']}');
    // Process analytics data and update relevant streams
  }

  /// Handle system event
  void _handleSystemEvent(Map<String, dynamic> data) {
    print('System event received: ${data['event']}');
    // Process system events (new booking, user registration, etc.)
  }

  /// Handle heartbeat response
  void _handleHeartbeatResponse(Map<String, dynamic> data) {
    print('Heartbeat response received');
    // Connection is alive
  }

  /// Handle authentication response
  void _handleAuthResponse(Map<String, dynamic> data) {
    if (data['status'] == 'success') {
      print('WebSocket authentication successful');
      // Subscribe to default analytics events
      subscribeToAnalytics([
        'booking_created',
        'booking_completed',
        'user_registered',
        'partner_status_changed',
        'revenue_updated',
        'system_metrics_updated',
      ]);
    } else {
      print('WebSocket authentication failed: ${data['message']}');
    }
  }

  /// Handle server error
  void _handleServerError(Map<String, dynamic> data) {
    print('WebSocket server error: ${data['message']}');
  }

  /// Handle connection error
  void _handleError(error) {
    print('WebSocket error: $error');
    _handleConnectionFailure();
  }

  /// Handle disconnection
  void _handleDisconnection() {
    print('WebSocket disconnected');
    _isConnected = false;
    _stopHeartbeat();
    
    if (_shouldReconnect) {
      _scheduleReconnect();
    }
  }

  /// Handle connection failure
  void _handleConnectionFailure() {
    _isConnected = false;
    _stopHeartbeat();
    
    if (_shouldReconnect && _reconnectAttempts < _maxReconnectAttempts) {
      _scheduleReconnect();
    } else {
      print('Max reconnection attempts reached. Giving up.');
    }
  }

  /// Schedule reconnection attempt
  void _scheduleReconnect() {
    _reconnectAttempts++;
    print('Scheduling reconnection attempt $_reconnectAttempts in ${_reconnectDelay.inSeconds} seconds');
    
    _reconnectTimer = Timer(_reconnectDelay, () {
      if (_shouldReconnect) {
        connect();
      }
    });
  }

  /// Start heartbeat timer
  void _startHeartbeat() {
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (timer) {
      if (_isConnected) {
        sendMessage({
          'type': 'heartbeat',
          'timestamp': DateTime.now().toIso8601String(),
        });
      }
    });
  }

  /// Stop heartbeat timer
  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  /// Send authentication message
  void _sendAuthMessage() {
    sendMessage({
      'type': 'auth',
      'token': 'admin_token', // Replace with actual auth token
      'role': 'admin',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Cleanup resources
  void _cleanup() {
    _isConnected = false;
    _stopHeartbeat();
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    
    _channel?.sink.close();
    _channel = null;
    
    _messageController?.close();
    _messageController = null;
  }

  /// Dispose of all resources
  void dispose() {
    disconnect();
  }
}

/// WebSocket message types
class WebSocketMessageType {
  static const String analyticsUpdate = 'analytics_update';
  static const String systemEvent = 'system_event';
  static const String heartbeat = 'heartbeat';
  static const String heartbeatResponse = 'heartbeat_response';
  static const String auth = 'auth';
  static const String authResponse = 'auth_response';
  static const String subscribe = 'subscribe';
  static const String unsubscribe = 'unsubscribe';
  static const String requestData = 'request_data';
  static const String error = 'error';
}

/// WebSocket event types for analytics
class AnalyticsEventType {
  static const String bookingCreated = 'booking_created';
  static const String bookingCompleted = 'booking_completed';
  static const String bookingCancelled = 'booking_cancelled';
  static const String userRegistered = 'user_registered';
  static const String partnerStatusChanged = 'partner_status_changed';
  static const String revenueUpdated = 'revenue_updated';
  static const String systemMetricsUpdated = 'system_metrics_updated';
  static const String paymentProcessed = 'payment_processed';
  static const String ratingSubmitted = 'rating_submitted';
  static const String supportTicketCreated = 'support_ticket_created';
}

/// WebSocket data types for requests
class DataRequestType {
  static const String systemMetrics = 'system_metrics';
  static const String bookingAnalytics = 'booking_analytics';
  static const String revenueData = 'revenue_data';
  static const String userMetrics = 'user_metrics';
  static const String partnerMetrics = 'partner_metrics';
  static const String realtimeStats = 'realtime_stats';
}
