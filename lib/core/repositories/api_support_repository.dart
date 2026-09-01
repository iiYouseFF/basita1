import '../models/api_misc.dart';
import '../services/api_client.dart';

class SupportRepository {
  final ApiClient _api = ApiClient();

  Future<ApiSupportTicket> createTicket({
    required String userId,
    required String userType,
    required String subject,
    required String description,
    String? priority,
  }) async {
    final body = <String, dynamic>{
      'userId': userId,
      'userType': userType,
      'subject': subject,
      'description': description,
    };
    if (priority != null) body['priority'] = priority;
    
    final response = await _api.post('/support-tickets', body: body);
    return ApiSupportTicket.fromJson(_api.unwrapData(response));
  }

  Future<List<ApiSupportTicket>> getTickets(String userId) async {
    final response = await _api.get(
      '/support-tickets',
      queryParams: {'userId': userId},
    );
    final tickets = _api.unwrapList(response);
    return tickets.map((t) => ApiSupportTicket.fromJson(t)).toList();
  }

  Future<ApiSupportTicket> getTicketById(String ticketId) async {
    final response = await _api.get('/support-tickets/$ticketId');
    return ApiSupportTicket.fromJson(_api.unwrapData(response));
  }

  Future<ApiSupportTicket> updateTicket(
    String ticketId, {
    String? status,
    String? adminReply,
  }) async {
    final body = <String, dynamic>{};
    if (status != null) body['status'] = status;
    if (adminReply != null) body['adminReply'] = adminReply;
    
    final response = await _api.patch('/support-tickets/$ticketId', body: body);
    return ApiSupportTicket.fromJson(_api.unwrapData(response));
  }
}
