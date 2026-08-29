import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:basita1/core/models/support_ticket.dart';

class SupportTicketRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<SupportTicket>> getUserTickets(String userId) async {
    try {
      final data = await _client
          .from('support_tickets')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return data.map((json) => SupportTicket.fromJson(json)).toList();
    } catch (e) {
      // ignore: avoid_print
      print('[SupportTicketRepository.getUserTickets] $e');
      rethrow;
    }
  }

  Future<SupportTicket?> getTicket(String ticketId) async {
    try {
      final data = await _client
          .from('support_tickets')
          .select()
          .eq('id', ticketId)
          .maybeSingle();
      return data != null ? SupportTicket.fromJson(data) : null;
    } catch (e) {
      // ignore: avoid_print
      print('[SupportTicketRepository.getTicket] $e');
      rethrow;
    }
  }

  Future<SupportTicket> createTicket({
    required String userId,
    required String userType,
    required String subject,
    required String description,
    String priority = 'medium',
  }) async {
    try {
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
    } catch (e) {
      // ignore: avoid_print
      print('[SupportTicketRepository.createTicket] $e');
      rethrow;
    }
  }

  Future<void> closeTicket(String ticketId) async {
    try {
      await _client
          .from('support_tickets')
          .update({'status': 'closed'})
          .eq('id', ticketId);
    } catch (e) {
      // ignore: avoid_print
      print('[SupportTicketRepository.closeTicket] $e');
      rethrow;
    }
  }
}
