import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:basita1/core/models/payment_log.dart';

class PaymentLogRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<PaymentLog> logPayment({
    required String userId,
    required double amount,
    required String paymentMethod,
    String? requestId,
    String? technicianId,
  }) async {
    final data = await _client
        .from('payment_logs')
        .insert({
          'firebase_user_id': userId,
          'firebase_request_id': requestId,
          'technician_id': technicianId,
          'amount': amount,
          'payment_method': paymentMethod,
          'status': 'completed',
        })
        .select()
        .single();
    return PaymentLog.fromJson(data);
  }

  Future<List<PaymentLog>> getUserPayments(String userId) async {
    final data = await _client
        .from('payment_logs')
        .select()
        .eq('firebase_user_id', userId)
        .order('created_at', ascending: false)
        .limit(100);
    return data.map((json) => PaymentLog.fromJson(json)).toList();
  }

  Future<List<PaymentLog>> getTechnicianPayments(String technicianId) async {
    final data = await _client
        .from('payment_logs')
        .select()
        .eq('technician_id', technicianId)
        .order('created_at', ascending: false)
        .limit(100);
    return data.map((json) => PaymentLog.fromJson(json)).toList();
  }

  Future<void> updatePaymentStatus({
    required String paymentId,
    required String status,
  }) async {
    await _client
        .from('payment_logs')
        .update({'status': status})
        .eq('id', paymentId);
  }
}
