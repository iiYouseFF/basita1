import '../models/api_misc.dart';
import '../services/api_client.dart';

class NotificationRepository {
  final ApiClient _api = ApiClient();

  Future<List<ApiNotification>> getNotifications({
    String? userId,
    bool? unreadOnly,
    int? limit,
  }) async {
    final queryParams = <String, String>{};
    if (userId != null) queryParams['userId'] = userId;
    if (unreadOnly != null) queryParams['unreadOnly'] = unreadOnly.toString();
    if (limit != null) queryParams['limit'] = limit.toString();
    
    final response = await _api.get(
      '/notifications',
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );
    final notifications = _api.unwrapList(response);
    return notifications.map((n) => ApiNotification.fromJson(n)).toList();
  }

  Future<ApiNotification> createNotification({
    required String userId,
    required String userType,
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    final bodyPayload = <String, dynamic>{
      'userId': userId,
      'userType': userType,
      'title': title,
      'body': body,
      'type': type,
    };
    if (data != null) bodyPayload['data'] = data;
    
    final response = await _api.post('/notifications', body: bodyPayload);
    return ApiNotification.fromJson(_api.unwrapData(response));
  }

  Future<void> markAsRead(String notificationId) async {
    await _api.patch(
      '/notifications/$notificationId',
      body: {'isRead': true},
    );
  }

  Future<void> markAllAsRead(String userId) async {
    await _api.post(
      '/notifications/mark-all-read',
      body: {'userId': userId},
    );
  }

  Future<int> getUnreadCount(String userId) async {
    final response = await _api.get(
      '/notifications/unread-count',
      queryParams: {'userId': userId},
    );
    final data = _api.unwrapData(response);
    return data['count'] ?? 0;
  }

  Future<void> sendPushNotification({
    String? userId,
    String? userType,
    required String title,
    required String body,
    String? type,
    Map<String, dynamic>? data,
    String? topic,
    String? token,
  }) async {
    final bodyPayload = <String, dynamic>{
      'title': title,
      'body': body,
    };
    if (userId != null) bodyPayload['userId'] = userId;
    if (userType != null) bodyPayload['userType'] = userType;
    if (type != null) bodyPayload['type'] = type;
    if (data != null) bodyPayload['data'] = data;
    if (topic != null) bodyPayload['topic'] = topic;
    if (token != null) bodyPayload['token'] = token;
    
    await _api.post('/push/send', body: bodyPayload);
  }
}
