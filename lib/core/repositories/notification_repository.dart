import 'dart:async';
import 'package:basita1/core/models/app_notification.dart';
import 'package:basita1/core/network/api_client.dart';

/// Real backend: GET /notifications, POST /notifications, PATCH, etc.
/// Base: http://basseeyta.duckdns.org  (see api-docs.json)
class NotificationRepository {
  final ApiClient _api = ApiClient();

  Map<String, dynamic> _normalize(Map<String, dynamic> j) => {
        'id': j['id'] ?? '',
        'user_id': j['userId'] ?? j['user_id'] ?? '',
        'user_type': j['userType'] ?? j['user_type'] ?? 'user',
        'title': j['title'] ?? '',
        'body': j['body'] ?? '',
        'type': j['type'] ?? 'system',
        'data': j['data'] ?? {},
        'is_read': j['isRead'] ?? j['is_read'] ?? false,
        'created_at': j['createdAt'] ?? j['created_at'],
      };

  Future<List<AppNotification>> getNotifications({
    required String userId,
    bool unreadOnly = false,
    int limit = 50,
  }) async {
    final res = await _api.get('/notifications', query: {
      'userId': userId,
      if (unreadOnly) 'unreadOnly': 'true',
      'limit': limit,
    });
    final data = res['data'];
    final list = data is List ? data : (data is Map && data['notifications'] is List ? data['notifications'] : []);
    return (list as List).map((e) => AppNotification.fromJson(_normalize(Map<String, dynamic>.from(e)))).toList();
  }

  Stream<List<AppNotification>> watchNotifications(String userId) async* {
    yield await getNotifications(userId: userId);
  }

  Future<int> getUnreadCount(String userId) async {
    final res = await _api.get('/notifications/unread-count', query: {'userId': userId});
    final data = res['data'];
    if (data is Map && data['count'] != null) return (data['count'] as num).toInt();
    if (data is int) return data;
    return 0;
  }

  Future<void> markAsRead(String notificationId) async {
    await _api.patch('/notifications/$notificationId', body: {'isRead': true, 'is_read': true});
  }

  Future<void> markAllAsRead(String userId) async {
    await _api.post('/notifications/mark-all-read', body: {'userId': userId});
  }

  Future<void> insertNotification({
    required String userId,
    required String userType,
    required String title,
    required String body,
    String type = 'system',
    Map<String, dynamic> data = const {},
  }) async {
    await _api.post('/notifications', body: {
      'userId': userId,
      'userType': userType,
      'title': title,
      'body': body,
      'type': type,
      'data': data,
    });
  }
}
