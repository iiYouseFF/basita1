import 'package:basita1/core/models/support_ticket.dart';
import 'package:basita1/core/network/api_client.dart';

/// Real backend: POST/GET /support-tickets, PATCH /support-tickets/:id
class SupportTicketRepository {
  final ApiClient _api = ApiClient();

  Map<String, dynamic> _normalize(Map<String, dynamic> j) => {
        'id': j['id'] ?? '',
        'user_id': j['userId'] ?? j['user_id'] ?? '',
        'user_type': j['userType'] ?? j['user_type'] ?? 'user',
        'subject': j['subject'] ?? '',
        'description': j['description'] ?? '',
        'status': j['status'] ?? 'open',
        'priority': j['priority'] ?? 'medium',
        'admin_reply': j['adminReply'] ?? j['admin_reply'],
        'created_at': j['createdAt'] ?? j['created_at'],
        'updated_at': j['updatedAt'] ?? j['updated_at'],
      };

  Future<List<SupportTicket>> getUserTickets(String userId) async {
    final res = await _api.get('/support-tickets', query: {'userId': userId});
    final data = res['data'];
    final list = data is List ? data : (data is Map && data['tickets'] is List ? data['tickets'] : []);
    return (list as List).map((e) => SupportTicket.fromJson(_normalize(Map<String, dynamic>.from(e)))).toList();
  }

  Future<SupportTicket?> getTicket(String ticketId) async {
    try {
      final res = await _api.get('/support-tickets/$ticketId');
      final data = (res['data'] as Map<String, dynamic>?) ?? res;
      return SupportTicket.fromJson(_normalize(Map<String, dynamic>.from(data)));
    } catch (_) {
      return null;
    }
  }

  Future<SupportTicket> createTicket({
    required String userId,
    required String userType,
    required String subject,
    required String description,
    String priority = 'medium',
  }) async {
    final res = await _api.post('/support-tickets', body: {
      'userId': userId,
      'userType': userType,
      'subject': subject,
      'description': description,
      'priority': priority,
    });
    final data = (res['data'] as Map<String, dynamic>?)?['ticket'] ?? res['data'] ?? res;
    return SupportTicket.fromJson(_normalize(Map<String, dynamic>.from(data as Map)));
  }

  Future<void> closeTicket(String ticketId) async {
    await _api.patch('/support-tickets/$ticketId', body: {'status': 'closed'});
  }
}
