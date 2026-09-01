import 'dart:async';
import 'package:flutter/foundation.dart';

import 'package:basita1/core/models/chat_message.dart';
import 'package:basita1/core/models/chat_room.dart';
import 'package:basita1/core/network/api_client.dart';
import 'package:basita1/core/network/socket_service.dart';

/// Real backend: Node.js Chat module at http://basseeyta.duckdns.org
/// REST: POST /chat/rooms, GET /chat/rooms?userId=, GET/POST /chat/rooms/:id/messages
/// Realtime: Socket.io namespace `/chat` — `join_room`/`send_message` -> `new_message`/`receive_message`
///
/// This repository now provides **true realtime** via [SocketService].
/// - `watchMessages` — initial REST fetch + socket `new_message` pushes
/// - `watchUserChatRooms` — initial REST + socket `room_update` refresh
/// - `sendMessage` — socket emit first (low latency), REST fallback for persistence/offline
class ChatRepository {
  final ApiClient _api = ApiClient();
  final SocketService _socket = SocketService.instance;

  // ---------------------------------------------------------------------------
  // Static shared state — ensures multiple ChatRepository instances (per screen)
  // share the same socket and caches, avoiding duplicate listeners.
  // ---------------------------------------------------------------------------
  static final Map<String, List<ChatMessage>> _messageCache = {};
  static final Map<String, StreamController<List<ChatMessage>>> _messageControllers = {};
  static final Map<String, List<ChatRoom>> _roomCache = {};
  static final Map<String, StreamController<List<ChatRoom>>> _roomControllers = {};
  static bool _socketListenersAttached = false;
  static final Set<String> _listeningRooms = {};

  Map<String, dynamic> _normalizeRoom(Map<String, dynamic> j) => {
        'id': j['id'] ?? j['_id'] ?? '',
        'client_id': j['clientId'] ?? j['client_id'] ?? '',
        'technician_id': j['technicianId'] ?? j['technician_id'] ?? '',
        'request_id': j['requestId'] ?? j['request_id'],
        'service_type': j['serviceType'] ?? j['service_type'],
        'is_active': j['isActive'] ?? j['is_active'] ?? true,
        'created_at': j['createdAt'] ?? j['created_at'],
        'updated_at': j['updatedAt'] ?? j['updated_at'],
      };

  Map<String, dynamic> _normalizeMsg(Map<String, dynamic> j) => {
        'id': j['id'] ?? j['_id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        'room_id': j['roomId'] ?? j['room_id'] ?? j['room'] ?? '',
        'sender_id': j['senderId'] ?? j['sender_id'] ?? j['sender'] ?? '',
        'sender_type': j['senderType'] ?? j['sender_type'] ?? j['sender'] ?? 'user',
        'message': j['message'] ?? j['text'] ?? j['content'] ?? '',
        'is_read': j['isRead'] ?? j['is_read'] ?? j['read'] ?? false,
        'created_at': j['createdAt'] ?? j['created_at'] ?? j['timestamp'] ?? DateTime.now().toIso8601String(),
      };

  // ---------------------------------------------------------------------------
  // Socket wiring — attached once globally
  // ---------------------------------------------------------------------------
  void _ensureSocketListeners() {
    if (_socketListenersAttached) return;
    _socketListenersAttached = true;

    // Ensure connection
    _socket.connectChat();

    // Listen for new messages on all known events
    void handleMessage(dynamic data) {
      try {
        final normalized = _extractMessage(data);
        if (normalized == null) return;
        final roomId = normalized['room_id'] as String;
        if (roomId.isEmpty) return;

        final msg = ChatMessage.fromJson(normalized);
        // Update cache
        final cache = _messageCache[roomId] ?? [];
        // Dedupe by id
        if (cache.any((m) => m.id == msg.id && msg.id.isNotEmpty)) return;
        // Insert sorted by createdAt (oldest first); if no timestamp, append
        cache.add(msg);
        // Sort if timestamps available
        cache.sort((a, b) {
          if (a.createdAt == null || b.createdAt == null) return 0;
          return a.createdAt!.compareTo(b.createdAt!);
        });
        _messageCache[roomId] = cache;
        _messageControllers[roomId]?.add(List.unmodifiable(cache));

        // Also optimistically refresh room list (last message preview)
        // Trigger a soft refresh of rooms if we have any room controllers
        // (room list will be re-fetched on next event or via polling fallback)
        if (kDebugMode) debugPrint('[ChatRepo] socket new_message room=$roomId msg=${msg.message}');
      } catch (e) {
        if (kDebugMode) debugPrint('[ChatRepo] handleMessage error $e data=$data');
      }
    }

    _socket.onNewMessage(handleMessage);

    // Room updates — refresh all room lists
    void handleRoomUpdate(dynamic data) {
      if (kDebugMode) debugPrint('[ChatRepo] room_update $data');
      // Invalidate all room caches and re-fetch for each active controller
      for (final entry in _roomControllers.entries) {
        final userId = entry.key;
        getUserChatRooms(userId).then((rooms) {
          _roomCache[userId] = rooms;
          if (!entry.value.isClosed) entry.value.add(List.unmodifiable(rooms));
        }).catchError((e) {
          if (kDebugMode) debugPrint('[ChatRepo] room refresh failed $e');
        });
      }
    }

    _socket.onRoomUpdate(handleRoomUpdate);

    // Connection state — on reconnect, re-join rooms
    _socket.connectionStream.listen((connected) {
      if (connected) {
        for (final roomId in _listeningRooms.toList()) {
          _socket.joinRoom(roomId);
        }
      }
    });
  }

  Map<String, dynamic>? _extractMessage(dynamic data) {
    if (data == null) return null;
    // Cases:
    // 1) direct message object
    // 2) {message: {...}} or {data: {...}} or {msg: {...}}
    // 3) wrapped in list
    if (data is Map<String, dynamic>) {
      if (data.containsKey('message') && data['message'] is Map) {
        return _normalizeMsg(Map<String, dynamic>.from(data['message']));
      }
      if (data.containsKey('data') && data['data'] is Map) {
        return _normalizeMsg(Map<String, dynamic>.from(data['data']));
      }
      if (data.containsKey('msg') && data['msg'] is Map) {
        return _normalizeMsg(Map<String, dynamic>.from(data['msg']));
      }
      // Check if it looks like a message itself
      if (data.containsKey('message') && data['message'] is String) {
        return _normalizeMsg(data);
      }
      // Fallback: treat whole map as message if it has room/message fields
      if (data.containsKey('roomId') || data.containsKey('room_id') || data.containsKey('text')) {
        return _normalizeMsg(data);
      }
    }
    if (data is Map) {
      return _normalizeMsg(Map<String, dynamic>.from(data));
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // REST helpers (unchanged)
  // ---------------------------------------------------------------------------
  Future<ChatRoom?> getOrCreateRoom({
    required String clientId,
    required String technicianId,
    String? requestId,
    String? serviceType,
  }) async {
    final res = await _api.post(
      '/chat/rooms',
      body: {
        'clientId': clientId,
        'technicianId': technicianId,
        if (requestId != null) 'requestId': requestId,
        if (serviceType != null) 'serviceType': serviceType,
      },
    );
    final data =
        (res['data'] as Map<String, dynamic>?)?['room'] ?? res['data'] ?? res;
    if (data is Map<String, dynamic>) return ChatRoom.fromJson(_normalizeRoom(data));
    return null;
  }

  Future<List<ChatRoom>> getUserChatRooms(String userId) async {
    final res = await _api.get('/chat/rooms', query: {'userId': userId});
    final data = res['data'];
    final list = data is List
        ? data
        : (data is Map && data['rooms'] is List ? data['rooms'] : []);
    return (list as List)
        .map((e) => ChatRoom.fromJson(_normalizeRoom(Map<String, dynamic>.from(e))))
        .toList();
  }

  Future<List<ChatMessage>> getMessages(String roomId, {int limit = 50}) async {
    final res = await _api.get(
      '/chat/rooms/$roomId/messages',
      query: {'limit': limit},
    );
    final data = res['data'];
    final list = data is List
        ? data
        : (data is Map && data['messages'] is List ? data['messages'] : []);
    return (list as List)
        .map((e) => ChatMessage.fromJson(_normalizeMsg(Map<String, dynamic>.from(e))))
        .toList();
  }

  // ---------------------------------------------------------------------------
  // Realtime streams — now socket-backed with REST fallback
  // ---------------------------------------------------------------------------
  /// Realtime stream of messages for a room.
  /// - Emits cached REST result immediately
  /// - Joins socket room and pushes `new_message` events
  /// - Falls back to polling every 7s if socket disconnected
  Stream<List<ChatMessage>> watchMessages(String roomId) {
    if (roomId.isEmpty) return Stream.value([]);
    _ensureSocketListeners();
    _listeningRooms.add(roomId);

    final controller = _messageControllers.putIfAbsent(
      roomId,
      () => StreamController<List<ChatMessage>>.broadcast(
        onCancel: () {
          // Keep cache but stop listening if no listeners? For now keep joined
        },
      ),
    );

    // Initial fetch (if not already cached)
    if (!_messageCache.containsKey(roomId)) {
      getMessages(roomId).then((msgs) {
        // Sort oldest first
        msgs.sort((a, b) {
          if (a.createdAt == null || b.createdAt == null) return 0;
          return a.createdAt!.compareTo(b.createdAt!);
        });
        _messageCache[roomId] = msgs;
        if (!controller.isClosed) controller.add(List.unmodifiable(msgs));
      }).catchError((e) {
        if (kDebugMode) debugPrint('[ChatRepo] getMessages failed $e');
        if (!controller.isClosed) controller.add(const []);
      });
    } else {
      // Emit cached value on next microtask so new listener gets current state
      Future.microtask(() {
        if (!controller.isClosed) {
          controller.add(List.unmodifiable(_messageCache[roomId]!));
        }
      });
    }

    // Ensure socket connected and joined
    _socket.connectChat().then((_) => _socket.joinRoom(roomId));

    // Fallback polling if socket not connected within 2s — poll every 7s
    Timer? pollTimer;
    void startPolling() {
      pollTimer?.cancel();
      pollTimer = Timer.periodic(const Duration(seconds: 7), (_) async {
        if (_socket.isChatConnected) {
          pollTimer?.cancel();
          return;
        }
        try {
          final fresh = await getMessages(roomId);
          fresh.sort((a, b) {
            if (a.createdAt == null || b.createdAt == null) return 0;
            return a.createdAt!.compareTo(b.createdAt!);
          });
          // Only emit if differs
          final cached = _messageCache[roomId] ?? [];
          if (fresh.length != cached.length ||
              (fresh.isNotEmpty && cached.isNotEmpty && fresh.last.id != cached.last.id)) {
            _messageCache[roomId] = fresh;
            if (!controller.isClosed) controller.add(List.unmodifiable(fresh));
          }
        } catch (_) {}
      });
    }

    if (!_socket.isChatConnected) {
      Future.delayed(const Duration(seconds: 2), () {
        if (!_socket.isChatConnected && !controller.isClosed) {
          startPolling();
        }
      });
    }

    // Cleanup polling when stream is cancelled (best-effort)
    controller.onCancel = () {
      pollTimer?.cancel();
    };

    return controller.stream;
  }

  /// Realtime stream of user's chat rooms.
  Stream<List<ChatRoom>> watchUserChatRooms(String userId) {
    if (userId.isEmpty) return Stream.value([]);
    _ensureSocketListeners();

    final controller = _roomControllers.putIfAbsent(
      userId,
      () => StreamController<List<ChatRoom>>.broadcast(),
    );

    if (!_roomCache.containsKey(userId)) {
      getUserChatRooms(userId).then((rooms) {
        _roomCache[userId] = rooms;
        if (!controller.isClosed) controller.add(List.unmodifiable(rooms));
      }).catchError((e) {
        if (kDebugMode) debugPrint('[ChatRepo] getUserChatRooms failed $e');
        if (!controller.isClosed) controller.add(const []);
      });
    } else {
      Future.microtask(() {
        if (!controller.isClosed) controller.add(List.unmodifiable(_roomCache[userId]!));
      });
    }

    // Ensure socket connected for room updates
    _socket.connectChat();

    // Fallback polling if socket not connected
    Timer? pollTimer;
    pollTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      if (_socket.isChatConnected) {
        pollTimer?.cancel();
        return;
      }
      try {
        final fresh = await getUserChatRooms(userId);
        final cached = _roomCache[userId] ?? [];
        if (fresh.length != cached.length ||
            (fresh.isNotEmpty && cached.isNotEmpty && fresh.first.id != cached.first.id)) {
          _roomCache[userId] = fresh;
          if (!controller.isClosed) controller.add(List.unmodifiable(fresh));
        }
      } catch (_) {}
    });
    // Cancel polling once connected
    _socket.connectionStream.listen((connected) {
      if (connected) pollTimer?.cancel();
    });

    return controller.stream;
  }

  /// Send a message — tries socket first for low latency, falls back to REST.
  /// Optimistically updates local cache so UI feels instant.
  Future<void> sendMessage({
    required String roomId,
    required String senderId,
    required String senderType,
    required String message,
  }) async {
    if (message.trim().isEmpty) return;

    // Optimistic local update
    final optimistic = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      roomId: roomId,
      senderId: senderId,
      senderType: senderType,
      message: message,
      isRead: false,
      createdAt: DateTime.now(),
    );
    final cache = _messageCache[roomId] ?? [];
    cache.add(optimistic);
    _messageCache[roomId] = cache;
    _messageControllers[roomId]?.add(List.unmodifiable(cache));

    // Try socket emit — if connected, server will broadcast authoritative message
    final emitted = _socket.sendMessage(
      roomId: roomId,
      senderId: senderId,
      senderType: senderType,
      message: message,
    );

    if (emitted) {
      // Socket emitted — still do REST in background for persistence guarantee
      // (some backends persist on socket event, some only on REST; do both)
      try {
        await _api.post(
          '/chat/rooms/$roomId/messages',
          body: {
            'senderId': senderId,
            'senderType': senderType,
            'message': message,
          },
        );
      } catch (e) {
        if (kDebugMode) debugPrint('[ChatRepo] REST sendMessage fallback failed (socket already emitted) $e');
      }
      return;
    }

    // Socket not connected — fallback to REST (authoritative)
    try {
      await _api.post(
        '/chat/rooms/$roomId/messages',
        body: {
          'senderId': senderId,
          'senderType': senderType,
          'message': message,
        },
      );
      // Refresh from server to get canonical id/timestamp
      final fresh = await getMessages(roomId);
      fresh.sort((a, b) {
        if (a.createdAt == null || b.createdAt == null) return 0;
        return a.createdAt!.compareTo(b.createdAt!);
      });
      _messageCache[roomId] = fresh;
      _messageControllers[roomId]?.add(List.unmodifiable(fresh));
    } catch (e) {
      // Rollback optimistic on hard failure
      _messageCache[roomId]?.removeWhere((m) => m.id == optimistic.id);
      _messageControllers[roomId]?.add(List.unmodifiable(_messageCache[roomId] ?? []));
      rethrow;
    }
  }

  Future<void> markAsRead(String roomId, String currentUserId) async {
    // Optimistically mark cached messages as read
    final cache = _messageCache[roomId];
    if (cache != null) {
      for (var i = 0; i < cache.length; i++) {
        if (cache[i].senderId != currentUserId && !cache[i].isRead) {
          cache[i] = ChatMessage(
            id: cache[i].id,
            roomId: cache[i].roomId,
            senderId: cache[i].senderId,
            senderType: cache[i].senderType,
            message: cache[i].message,
            isRead: true,
            createdAt: cache[i].createdAt,
          );
        }
      }
      _messageControllers[roomId]?.add(List.unmodifiable(cache));
    }

    try {
      await _api.patch(
        '/chat/rooms/$roomId/read',
        body: {'userId': currentUserId},
      );
      // Also emit via socket if connected
      if (_socket.isChatConnected) {
        _socket.chatSocket?.emit('mark_read', {'roomId': roomId, 'userId': currentUserId});
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[ChatRepo] markAsRead failed $e');
    }
  }

  Future<int> getUnreadCount(String roomId, String currentUserId) async {
    final res = await _api.get(
      '/chat/rooms/$roomId/unread',
      query: {'userId': currentUserId},
    );
    final data = res['data'];
    if (data is Map && data['count'] != null) return (data['count'] as num).toInt();
    if (data is int) return data;
    return 0;
  }

  /// Call when leaving a chat screen — leaves socket room.
  void leaveRoom(String roomId) {
    _socket.leaveRoom(roomId);
    _listeningRooms.remove(roomId);
  }

  /// Dispose a specific room's controller (call on app exit).
  void disposeRoom(String roomId) {
    _messageControllers[roomId]?.close();
    _messageControllers.remove(roomId);
    _messageCache.remove(roomId);
    _listeningRooms.remove(roomId);
    _socket.leaveRoom(roomId);
  }

  /// Global dispose — call on logout.
  void dispose() {
    for (final c in _messageControllers.values) {
      c.close();
    }
    _messageControllers.clear();
    _messageCache.clear();
    for (final c in _roomControllers.values) {
      c.close();
    }
    _roomControllers.clear();
    _roomCache.clear();
    _listeningRooms.clear();
  }
}
