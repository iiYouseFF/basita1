import '../models/api_chat.dart';
import '../services/api_client.dart';

class ApiChatRepository {
  final ApiClient _api = ApiClient();

  Future<ApiChatRoom> createRoom({
    required String clientId,
    required String technicianId,
    required String requestId,
    String? serviceType,
  }) async {
    final body = <String, dynamic>{
      'clientId': clientId,
      'technicianId': technicianId,
      'requestId': requestId,
    };
    if (serviceType != null) body['serviceType'] = serviceType;
    
    final response = await _api.post('/chat/rooms', body: body);
    return ApiChatRoom.fromJson(_api.unwrapData(response));
  }

  Future<List<ApiChatRoom>> getRooms({String? userId}) async {
    final queryParams = <String, String>{};
    if (userId != null) queryParams['userId'] = userId;
    
    final response = await _api.get(
      '/chat/rooms',
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );
    final rooms = _api.unwrapList(response);
    return rooms.map((r) => ApiChatRoom.fromJson(r)).toList();
  }

  Future<List<ApiChatMessage>> getMessages(String roomId, {int limit = 50}) async {
    final response = await _api.get(
      '/chat/rooms/$roomId/messages',
      queryParams: {'limit': limit.toString()},
    );
    final messages = _api.unwrapList(response);
    return messages.map((m) => ApiChatMessage.fromJson(m)).toList();
  }

  Future<ApiChatMessage> sendMessage({
    required String roomId,
    required String senderId,
    required String senderType,
    required String message,
  }) async {
    final response = await _api.post(
      '/chat/rooms/$roomId/messages',
      body: {
        'senderId': senderId,
        'senderType': senderType,
        'message': message,
      },
    );
    return ApiChatMessage.fromJson(_api.unwrapData(response));
  }

  Future<void> markAsRead(String roomId, String userId) async {
    await _api.patch(
      '/chat/rooms/$roomId/read',
      body: {'userId': userId},
    );
  }

  Future<int> getUnreadCount(String roomId, String userId) async {
    final response = await _api.get(
      '/chat/rooms/$roomId/unread',
      queryParams: {'userId': userId},
    );
    final data = _api.unwrapData(response);
    return data['count'] ?? 0;
  }
}
