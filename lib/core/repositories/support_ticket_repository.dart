import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:basita1/core/models/support_ticket.dart';

class SupportTicketRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<SupportTicket>> getUserTickets(String userId) async {
    final data = await _client
        .from('support_tickets')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return data.map((json) => SupportTicket.fromJson(json)).toList();
  }

  Future<SupportTicket?> getTicket(String ticketId) async {
    final data = await _client
        .from('support_tickets')
        .select()
        .eq('id', ticketId)
        .maybeSingle();
    return data != null ? SupportTicket.fromJson(data) : null;
  }

  Future<SupportTicket> createTicket({
    required String userId,
    required String userType,
    required String subject,
    required String description,
    String priority = 'medium',
  }) async {
    final data = await _client
        .from('support_tickets')
        .insert({
          'user_id': userId,
          'user_type': userType,
          'subject': subject,
          'description': description,
          'priority': priority,
        })
        .select()
        .single();
    return SupportTicket.fromJson(data);
  }

  Future<void> closeTicket(String ticketId) async {
    await _client
        .from('support_tickets')
        .update({'status': 'closed'}).eq('id', ticketId);
  }
}
