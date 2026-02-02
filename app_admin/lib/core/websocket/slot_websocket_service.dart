import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

/// WebSocket configuration
class WebSocketConfig {
  // Direct to booking-service WebSocket (bypass gateway for WebSocket)
  static const String wsUrl = 'http://localhost:8082/ws/booking';
  
  // Topics
  static const String topicAdminPendingSlots = '/topic/admin/pending-slots';
}

/// Slot notification from WebSocket
class SlotNotification {
  final String type;
  final String message;
  final Map<String, dynamic>? slot;

  SlotNotification({
    required this.type,
    required this.message,
    this.slot,
  });

  factory SlotNotification.fromJson(Map<String, dynamic> json) {
    return SlotNotification(
      type: json['type'] ?? '',
      message: json['message'] ?? '',
      slot: json['slot'] as Map<String, dynamic>?,
    );
  }
}

/// WebSocket Service for real-time updates
class SlotWebSocketService {
  StompClient? _client;
  bool _isConnected = false;
  
  final _notificationController = StreamController<SlotNotification>.broadcast();
  Stream<SlotNotification> get notifications => _notificationController.stream;

  bool get isConnected => _isConnected;

  /// Connect to WebSocket server
  void connect() {
    if (_client != null && _isConnected) {
      return;
    }

    _client = StompClient(
      config: StompConfig.sockJS(
        url: WebSocketConfig.wsUrl,
        onConnect: _onConnect,
        onDisconnect: _onDisconnect,
        onWebSocketError: (error) => print('WebSocket Error: $error'),
        onStompError: (frame) => print('STOMP Error: ${frame.body}'),
        reconnectDelay: const Duration(seconds: 5),
      ),
    );

    _client!.activate();
  }

  void _onConnect(StompFrame frame) {
    _isConnected = true;
    print('WebSocket connected to booking-service');

    // Subscribe to admin pending slots topic
    _client!.subscribe(
      destination: WebSocketConfig.topicAdminPendingSlots,
      callback: (frame) {
        if (frame.body != null) {
          try {
            final json = jsonDecode(frame.body!);
            final notification = SlotNotification.fromJson(json);
            _notificationController.add(notification);
            print('Received notification: ${notification.type} - ${notification.message}');
          } catch (e) {
            print('Error parsing notification: $e');
          }
        }
      },
    );
  }

  void _onDisconnect(StompFrame frame) {
    _isConnected = false;
    print('WebSocket disconnected');
  }

  /// Disconnect from WebSocket server
  void disconnect() {
    _client?.deactivate();
    _client = null;
    _isConnected = false;
  }

  /// Dispose resources
  void dispose() {
    disconnect();
    _notificationController.close();
  }
}

/// Provider for SlotWebSocketService
final slotWebSocketServiceProvider = Provider<SlotWebSocketService>((ref) {
  final service = SlotWebSocketService();
  
  ref.onDispose(() {
    service.dispose();
  });
  
  return service;
});

/// Stream provider for slot notifications
final slotNotificationsProvider = StreamProvider<SlotNotification>((ref) {
  final service = ref.watch(slotWebSocketServiceProvider);
  
  // Connect when first accessed
  if (!service.isConnected) {
    service.connect();
  }
  
  return service.notifications;
});
