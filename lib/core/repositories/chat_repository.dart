import 'dart:async';
import 'package:basita1/core/models/chat_message.dart';
import 'package:basita1/core/models/chat_room.dart';
import 'package:basita1/core/network/api_client.dart';

/// Real backend: Node.js Chat module at http://basseeyta.duckdns.org
/// POST /chat/rooms, GET /chat/rooms?userId=, GET/POST /chat/rooms/:id/messages
/// Also Socket.io namespaces: /chat (join_room, send_message)
class ChatRepository {
  final ApiClient _api = ApiClient();

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
    if (data is Map<String, dynamic>)
      return ChatRoom.fromJson(_normalizeRoom(data));
    return null;
  }

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
    'id': j['id'] ?? '',
    'room_id': j['roomId'] ?? j['room_id'] ?? '',
    'sender_id': j['senderId'] ?? j['sender_id'] ?? '',
    'sender_type': j['senderType'] ?? j['sender_type'] ?? 'user',
    'message': j['message'] ?? j['text'] ?? '',
    'is_read': j['isRead'] ?? j['is_read'] ?? false,
    'created_at': j['createdAt'] ?? j['created_at'],
  };

  Future<List<ChatRoom>> getUserChatRooms(String userId) async {
    final res = await _api.get('/chat/rooms', query: {'userId': userId});
    final data = res['data'];
    final list = data is List
        ? data
        : (data is Map && data['rooms'] is List ? data['rooms'] : []);
    return (list as List)
        .map(
          (e) =>
              ChatRoom.fromJson(_normalizeRoom(Map<String, dynamic>.from(e))),
        )
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
        .map(
          (e) =>
              ChatMessage.fromJson(_normalizeMsg(Map<String, dynamic>.from(e))),
        )
        .toList();
  }

  // For now, realtime via polling + Socket.io will be added later.
  // Keeping Stream as single-value for compatibility; UI can poll or use socket.
  Stream<List<ChatMessage>> watchMessages(String roomId) async* {
    yield await getMessages(roomId);
  }

  Stream<List<ChatRoom>> watchUserChatRooms(String userId) async* {
    yield await getUserChatRooms(userId);
  }

  Future<void> sendMessage({
    required String roomId,
    required String senderId,
    required String senderType,
    required String message,
  }) async {
    await _api.post(
      '/chat/rooms/$roomId/messages',
      body: {
        'senderId': senderId,
        'senderType': senderType,
        'message': message,
      },
    );
  }

  Future<void> markAsRead(String roomId, String currentUserId) async {
    await _api.patch(
      '/chat/rooms/$roomId/read',
      body: {'userId': currentUserId},
    );
  }

  Future<int> getUnreadCount(String roomId, String currentUserId) async {
    final res = await _api.get(
      '/chat/rooms/$roomId/unread',
      query: {'userId': currentUserId},
    );
    final data = res['data'];
    if (data is Map && data['count'] != null)
      return (data['count'] as num).toInt();
    if (data is int) return data;
    return 0;
  }
}
