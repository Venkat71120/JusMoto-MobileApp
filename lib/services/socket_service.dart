import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../customization.dart';
import '../helper/constant_helper.dart';

/// Handles real-time communication via Socket.IO.
/// Default server URL is derived from [siteLink].
class SocketService with ChangeNotifier {
  IO.Socket? _socket;
  bool _isConnected = false;

  bool get isConnected => _isConnected;
  IO.Socket? get socket => _socket;

  /// Initializes the socket connection if not already connected.
  void initSocket() {
    if (_socket != null && _socket!.connected) return;

    final token = getToken;
    if (token.isEmpty) {
      debugPrint('⚠️ SocketService: No token found. Delaying connection.');
      return;
    }

    debugPrint('🔌 Connecting to Socket.IO at $siteLink...');

    _socket = IO.io(siteLink, IO.OptionBuilder()
      .setTransports(['websocket']) 
      .setExtraHeaders({'Authorization': 'Bearer $token'})
      .enableAutoConnect()
      .build());

    _socket!.onConnect((_) {
      _isConnected = true;
      notifyListeners();
      debugPrint('✅ Socket Connected');
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      notifyListeners();
      debugPrint('❌ Socket Disconnected');
    });

    _socket!.onConnectError((err) => debugPrint('⚠️ Socket Connect Error: $err'));
    _socket!.onError((err) => debugPrint('❌ Socket Error: $err'));
  }

  /// Subscribes to a specific channel and listens for events.
  void subscribe(String event, Function(dynamic) onData) {
    if (_socket == null) initSocket();
    _socket!.on(event, onData);
    debugPrint('📡 Subscribed to event: $event');
  }

  /// Unsubscribes from a specific event.
  void unsubscribe(String event) {
    _socket?.off(event);
    debugPrint('📴 Unsubscribed from event: $event');
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
    _isConnected = false;
    notifyListeners();
    debugPrint('🔌 Socket Manually Disconnected');
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
