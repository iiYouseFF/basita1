import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:basita1/core/models/chat_message.dart';
import 'package:basita1/core/models/chat_room.dart';

class ChatRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<ChatRoom?> getOrCreateRoom({
    required String clientId,
    required String technicianId,
    String? requestId,
    String? serviceType,
  }) async {
    // 1. إن كان الطلب قام بإنشاء غرفة سابقة (placeholder بتقنية فارغة)،
    //    نستخدم نفس الغرفة ونحدّث بيانات الفني بدلاً من إنشاء غرفة مكررة.
    if (requestId != null && requestId.isNotEmpty) {
      final byRequest = await _client
          .from('chat_rooms')
          .select()
          .eq('request_id', requestId)
          .eq('is_active', true)
          .maybeSingle();

      if (byRequest != null) {
        await _client
            .from('chat_rooms')
            .update({'technician_id': technicianId})
            .eq('id', byRequest['id']);
        if (serviceType != null && serviceType != byRequest['service_type']) {
          await _client
              .from('chat_rooms')
              .update({'service_type': serviceType})
              .eq('id', byRequest['id']);
        }
        final updated = await _client
            .from('chat_rooms')
            .select()
            .eq('id', byRequest['id'])
            .single();
        return ChatRoom.fromJson(updated);
      }
    }

    final existing = await _client
        .from('chat_rooms')
        .select()
        .eq('client_id', clientId)
        .eq('technician_id', technicianId)
        .eq('is_active', true)
        .maybeSingle();

    if (existing != null) return ChatRoom.fromJson(existing);

    final data = await _client
        .from('chat_rooms')
        .insert({
          'client_id': clientId,
          'technician_id': technicianId,
          'request_id': requestId,
          'service_type': serviceType,
        })
        .select()
        .single();
    return ChatRoom.fromJson(data);
  }

  Future<List<ChatRoom>> getUserChatRooms(String userId) async {
    final data = await _client
        .from('chat_rooms')
        .select()
        .or('client_id.eq.$userId,technician_id.eq.$userId')
        .eq('is_active', true)
        .order('updated_at', ascending: false);
    return data.map((json) => ChatRoom.fromJson(json)).toList();
  }

  Future<List<ChatMessage>> getMessages(String roomId, {int limit = 50}) async {
    final data = await _client
        .from('chat_messages')
        .select()
        .eq('room_id', roomId)
        .order('created_at', ascending: false)
        .limit(limit);
    return data.map((json) => ChatMessage.fromJson(json)).toList();
  }

  Stream<List<ChatMessage>> watchMessages(String roomId) {
    return _client
        .from('chat_messages')
        .stream(primaryKey: ['id'])
        .eq('room_id', roomId)
        .order('created_at', ascending: false)
        .map((data) => data.map((json) => ChatMessage.fromJson(json)).toList());
  }

  Stream<List<ChatRoom>> watchUserChatRooms(String userId) {
    return _client
        .from('chat_rooms')
        .stream(primaryKey: ['id'])
        .order('updated_at', ascending: false)
        .map(
          (data) => data
              .where(
                (json) =>
                    json['client_id'] == userId ||
                    json['technician_id'] == userId,
              )
              .map((json) => ChatRoom.fromJson(json))
              .toList(),
        );
  }

  Future<void> sendMessage({
    required String roomId,
    required String senderId,
    required String senderType,
    required String message,
  }) async {
    await _client.from('chat_messages').insert({
      'room_id': roomId,
      'sender_id': senderId,
      'sender_type': senderType,
      'message': message,
    });

    await _client
        .from('chat_rooms')
        .update({'updated_at': DateTime.now().toIso8601String()})
        .eq('id', roomId);
  }

  Future<void> markAsRead(String roomId, String currentUserId) async {
    await _client
        .from('chat_messages')
        .update({'is_read': true})
        .eq('room_id', roomId)
        .neq('sender_id', currentUserId)
        .eq('is_read', false);
  }

  Future<int> getUnreadCount(String roomId, String currentUserId) async {
    final data = await _client
        .from('chat_messages')
        .select('id')
        .eq('room_id', roomId)
        .neq('sender_id', currentUserId)
        .eq('is_read', false);
    return data.length;
  }
}
