import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import 'package:basita1/core/network/api_config.dart';
import 'package:basita1/core/session/auth_session.dart';

/// Singleton Socket.io service for realtime features.
///
/// Backed by Node.js at `http://basseeyta.duckdns.org` (see `docs/backend-prd.html` §15).
/// Namespaces:
///   - `/chat` — `join_room` / `leave_room` / `send_message` -> `new_message`/`receive_message`/`message`
///   - `/notifications` / `/requests` — reserved for future use.
///
/// Usage:
/// ```dart
/// await SocketService.instance.connectChat();
/// SocketService.instance.joinRoom(roomId);
/// SocketService.instance.onNewMessage((msg) { ... });
/// SocketService.instance.sendMessage(roomId: id, senderId: uid, senderType: 'user', message: text);
/// ```
class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();
  static SocketService get instance => _instance;

  io.Socket? _chatSocket;
  bool _isConnecting = false;
  final Set<String> _joinedRooms = {};

  // Connection state broadcast
  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();
  Stream<bool> get connectionStream => _connectionController.stream;

  bool get isChatConnected => _chatSocket?.connected ?? false;
  io.Socket? get chatSocket => _chatSocket;
  Set<String> get joinedRooms => Set.unmodifiable(_joinedRooms);

  /// Build socket auth payload from [AuthSession].
  Map<String, dynamic> _authPayload() {
    final token = AuthSession.instance.token;
    if (token == null || token.isEmpty) return {};
    return {'token': token};
  }

  Map<String, String> _extraHeaders() {
    final headers = AuthSession.instance.authHeader;
    return Map<String, String>.from(headers);
  }

  String get _chatNamespaceUrl {
    final base = ApiConfig.baseUrl.endsWith('/')
        ? ApiConfig.baseUrl.substring(0, ApiConfig.baseUrl.length - 1)
        : ApiConfig.baseUrl;
    return '$base/chat';
  }

  /// Connect (or reconnect) the `/chat` namespace.
  /// Safe to call multiple times — deduped via [_isConnecting].
  Future<void> connectChat() async {
    if (isChatConnected) return;
    if (_isConnecting) return;
    _isConnecting = true;

    // If socket exists but disconnected, just reconnect.
    if (_chatSocket != null && _chatSocket!.disconnected) {
      if (kDebugMode) debugPrint('[Socket] reconnecting chat...');
      _chatSocket!.auth = _authPayload();
      _chatSocket!.connect();
      _isConnecting = false;
      return;
    }

    // Dispose old instance if any
    _chatSocket?.dispose();

    final url = _chatNamespaceUrl;
    if (kDebugMode) debugPrint('[Socket] connecting to $url auth=${_authPayload().isNotEmpty}');

    _chatSocket = io.io(
      url,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(10)
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(5000)
          .setTimeout(20000)
          .setAuth(_authPayload())
          .setExtraHeaders(_extraHeaders())
          .build(),
    );

    _attachChatListeners(_chatSocket!);
    _chatSocket!.connect();
    _isConnecting = false;
  }

  void _attachChatListeners(io.Socket socket) {
    socket.onConnect((_) {
      if (kDebugMode) debugPrint('[Socket] chat connected id=${socket.id}');
      _connectionController.add(true);
      // Re-join previously joined rooms after reconnect
      for (final roomId in _joinedRooms.toList()) {
        if (kDebugMode) debugPrint('[Socket] re-joining room $roomId');
        socket.emit('join_room', {'roomId': roomId});
        socket.emit('joinRoom', {'roomId': roomId}); // alias
      }
    });

    socket.onDisconnect((_) {
      if (kDebugMode) debugPrint('[Socket] chat disconnected');
      _connectionController.add(false);
    });

    socket.onConnectError((err) {
      if (kDebugMode) debugPrint('[Socket] connect_error $err');
      _connectionController.add(false);
    });

    socket.onError((err) {
      if (kDebugMode) debugPrint('[Socket] error $err');
    });

    socket.onReconnect((_) {
      if (kDebugMode) debugPrint('[Socket] reconnected');
      _connectionController.add(true);
    });
  }

  /// Join a chat room. Idempotent — tracks [_joinedRooms].
  void joinRoom(String roomId) {
    if (roomId.isEmpty) return;
    _joinedRooms.add(roomId);
    if (!isChatConnected) {
      // Will join on connect
      connectChat();
      return;
    }
    if (kDebugMode) debugPrint('[Socket] join_room $roomId');
    // Server may expect snake_case or camelCase — emit both for compat
    _chatSocket!.emit('join_room', {'roomId': roomId});
    _chatSocket!.emit('joinRoom', {'roomId': roomId});
    // Some backends use `join_room` with string payload
    _chatSocket!.emit('join_room', roomId);
  }

  /// Leave a chat room.
  void leaveRoom(String roomId) {
    if (roomId.isEmpty) return;
    _joinedRooms.remove(roomId);
    if (!isChatConnected) return;
    if (kDebugMode) debugPrint('[Socket] leave_room $roomId');
    _chatSocket!.emit('leave_room', {'roomId': roomId});
    _chatSocket!.emit('leaveRoom', {'roomId': roomId});
    _chatSocket!.emit('leave_room', roomId);
  }

  /// Send a chat message via socket.
  /// Backend should persist and broadcast `new_message` to room.
  /// Returns true if emitted, false if socket not connected (caller should fallback to REST).
  bool sendMessage({
    required String roomId,
    required String senderId,
    required String senderType, // 'user' | 'technician' | 'admin'
    required String message,
    Map<String, dynamic>? extra,
  }) {
    if (roomId.isEmpty || message.trim().isEmpty) return false;
    if (!isChatConnected) return false;

    final payload = {
      'roomId': roomId,
      'room_id': roomId,
      'senderId': senderId,
      'sender_id': senderId,
      'senderType': senderType,
      'sender_type': senderType,
      'message': message,
      'text': message,
      if (extra != null) ...extra,
    };

    if (kDebugMode) debugPrint('[Socket] send_message $payload');
    // Emit canonical event; server may listen to `send_message` or `message`
    _chatSocket!.emit('send_message', payload);
    _chatSocket!.emit('sendMessage', payload);
    _chatSocket!.emit('message', payload);
    return true;
  }

  /// Listen for new messages. Handles multiple server event names for compat.
  /// Callback receives raw map — caller should normalize via `_normalizeMsg`.
  void onNewMessage(void Function(dynamic data) handler) {
    if (_chatSocket == null) return;
    const events = ['new_message', 'receive_message', 'message', 'chat:message', 'send_message'];
    for (final e in events) {
      _chatSocket!.on(e, handler);
    }
  }

  /// Listen for room list updates (optional).
  void onRoomUpdate(void Function(dynamic data) handler) {
    if (_chatSocket == null) return;
    const events = ['room_update', 'rooms_update', 'new_room', 'chat:room'];
    for (final e in events) {
      _chatSocket!.on(e, handler);
    }
  }

  /// Typing indicator — emit.
  void emitTyping({required String roomId, required String userId, required bool isTyping}) {
    if (!isChatConnected) return;
    _chatSocket!.emit('typing', {
      'roomId': roomId,
      'userId': userId,
      'isTyping': isTyping,
    });
  }

  void onTyping(void Function(dynamic data) handler) {
    _chatSocket?.on('typing', handler);
  }

  /// Remove a listener for an event.
  void off(String event, [void Function(dynamic)? handler]) {
    if (handler != null) {
      _chatSocket?.off(event, handler);
    } else {
      _chatSocket?.off(event);
    }
  }

  /// Remove all chat listeners for a specific handler (used on dispose).
  void offNewMessage(void Function(dynamic) handler) {
    const events = ['new_message', 'receive_message', 'message', 'chat:message', 'send_message'];
    for (final e in events) {
      _chatSocket?.off(e, handler);
    }
  }

  /// Disconnect and dispose the chat socket.
  void disconnectChat() {
    if (kDebugMode) debugPrint('[Socket] disconnecting chat');
    _joinedRooms.clear();
    _chatSocket?.disconnect();
    // Keep instance for reconnect; don't dispose unless explicit
  }

  /// Fully dispose (call on app logout/exit).
  void dispose() {
    _joinedRooms.clear();
    _chatSocket?.dispose();
    _chatSocket = null;
    _connectionController.close();
  }

  /// Update auth (call after login/token refresh) — reconnects with new token.
  Future<void> updateAuth() async {
    if (_chatSocket == null) return;
    final token = AuthSession.instance.token;
    if (kDebugMode) debugPrint('[Socket] updateAuth token=${token != null && token.isNotEmpty}');
    _chatSocket!.auth = _authPayload();
    // Force reconnect to apply new auth
    if (isChatConnected) {
      _chatSocket!.disconnect();
      await Future.delayed(const Duration(milliseconds: 200));
      _chatSocket!.connect();
    }
  }
}
