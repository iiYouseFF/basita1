import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:basita1/core/models/app_notification.dart';

class NotificationRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<AppNotification>> getNotifications({
    required String userId,
    bool unreadOnly = false,
    int limit = 50,
  }) async {
    var query = _client
        .from('notifications')
        .select()
        .eq('user_id', userId);

    if (unreadOnly) {
      query = query.eq('is_read', false);
    }

    final data = await query
        .order('created_at', ascending: false)
        .limit(limit);
    return data.map((json) => AppNotification.fromJson(json)).toList();
  }

  Stream<List<AppNotification>> watchNotifications(String userId) {
    return _client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(50)
        .map((data) => data.map((json) => AppNotification.fromJson(json)).toList());
  }

  Future<int> getUnreadCount(String userId) async {
    final data = await _client
        .from('notifications')
        .select('id')
        .eq('user_id', userId)
        .eq('is_read', false);
    return data.length;
  }

  Future<void> markAsRead(String notificationId) async {
    await _client
        .from('notifications')
        .update({'is_read': true})
        .eq('id', notificationId);
  }

  Future<void> markAllAsRead(String userId) async {
    await _client
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', userId)
        .eq('is_read', false);
  }

  Future<void> insertNotification({
    required String userId,
    required String userType,
    required String title,
    required String body,
    String type = 'system',
    Map<String, dynamic> data = const {},
  }) async {
    await _client.from('notifications').insert({
      'user_id': userId,
      'user_type': userType,
      'title': title,
      'body': body,
      'type': type,
      'data': data,
    });
  }
}
