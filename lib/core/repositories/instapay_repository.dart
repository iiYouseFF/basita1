import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:basita1/core/models/instapay_transaction.dart';

class InstaPayRepository {
  final SupabaseClient _client = Supabase.instance.client;

  static final Uri kInstaPayAppLink = Uri.parse('https://ipn.eg/');
  static const String kInstaPayAndroidPackage = 'com.egyptianbanks.instapay';

  String _generateVerificationCode() {
    final random = Random.secure();
    return List.generate(6, (_) => random.nextInt(10)).join();
  }

  Future<InstaPayTransaction> createTransaction({
    required String requestId,
    required String senderId,
    required String receiverId,
    required double amount,
    String? instapayCode,
  }) async {
    final verificationCode = _generateVerificationCode();
    final data = await _client
        .from('instapay_transactions')
        .insert({
          'request_id': requestId,
          'sender_id': senderId,
          'receiver_id': receiverId,
          'amount': amount,
          'instapay_code': instapayCode,
          'verification_code': verificationCode,
        })
        .select()
        .single();
    return InstaPayTransaction.fromJson(data);
  }

  Future<bool> verifyPayment({
    required String transactionId,
    required String code,
  }) async {
    final data = await _client
        .from('instapay_transactions')
        .select()
        .eq('id', transactionId)
        .eq('verification_code', code)
        .maybeSingle();

    if (data == null) return false;

    await _client
        .from('instapay_transactions')
        .update({
          'status': 'verified',
          'verified_at': DateTime.now().toIso8601String(),
        })
        .eq('id', transactionId);

    return true;
  }

  Future<List<InstaPayTransaction>> getUserTransactions(String userId) async {
    final data = await _client
        .from('instapay_transactions')
        .select()
        .or('sender_id.eq.$userId,receiver_id.eq.$userId')
        .order('created_at', ascending: false)
        .limit(100);
    return data.map((json) => InstaPayTransaction.fromJson(json)).toList();
  }

  Future<InstaPayTransaction?> getTransaction(String transactionId) async {
    final data = await _client
        .from('instapay_transactions')
        .select()
        .eq('id', transactionId)
        .maybeSingle();
    return data != null ? InstaPayTransaction.fromJson(data) : null;
  }
}
