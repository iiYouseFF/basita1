import 'dart:math';
import 'package:basita1/core/models/instapay_transaction.dart';
import 'package:basita1/core/network/api_client.dart';

/// Real backend: POST /payments/instapay, POST /payments/instapay/:id/verify, GET /payments/instapay
class InstaPayRepository {
  final ApiClient _api = ApiClient();

  static final Uri kInstaPayAppLink = Uri.parse('https://ipn.eg/');
  static const String kInstaPayAndroidPackage = 'com.egyptianbanks.instapay';

  String _generateVerificationCode() {
    final random = Random.secure();
    return List.generate(6, (_) => random.nextInt(10)).join();
  }

  Map<String, dynamic> _normalize(Map<String, dynamic> j) => {
    'id': j['id'] ?? '',
    'request_id': j['requestId'] ?? j['request_id'] ?? '',
    'sender_id': j['senderId'] ?? j['sender_id'] ?? j['userId'] ?? '',
    'receiver_id':
        j['receiverId'] ?? j['receiver_id'] ?? j['technicianId'] ?? '',
    'amount': j['amount'] ?? 0,
    'currency': j['currency'] ?? 'EGP',
    'instapay_code': j['instapayCode'] ?? j['instapay_code'],
    'verification_code': j['verificationCode'] ?? j['verification_code'],
    'status': j['status'] ?? 'pending',
    'verified_at': j['verifiedAt'] ?? j['verified_at'],
    'created_at': j['createdAt'] ?? j['created_at'],
  };

  Future<InstaPayTransaction> createTransaction({
    required String requestId,
    required String senderId,
    required String receiverId,
    required double amount,
    String? instapayCode,
  }) async {
    final res = await _api.post(
      '/payments/instapay',
      body: {
        'requestId': requestId,
        'senderId': senderId,
        'receiverId': receiverId,
        'amount': amount,
        if (instapayCode != null) 'instapayCode': instapayCode,
      },
    );
    final data =
        (res['data'] as Map<String, dynamic>?)?['transaction'] ??
        res['data'] ??
        res;
    return InstaPayTransaction.fromJson(
      _normalize(Map<String, dynamic>.from(data as Map)),
    );
  }

  Future<bool> verifyPayment({
    required String transactionId,
    required String code,
  }) async {
    final res = await _api.post(
      '/payments/instapay/$transactionId/verify',
      body: {'code': code},
    );
    return res['success'] == true;
  }

  Future<List<InstaPayTransaction>> getUserTransactions(String userId) async {
    final res = await _api.get('/payments/instapay', query: {'userId': userId});
    final data = res['data'];
    final list = data is List
        ? data
        : (data is Map && data['transactions'] is List
              ? data['transactions']
              : []);
    return (list as List)
        .map(
          (e) => InstaPayTransaction.fromJson(
            _normalize(Map<String, dynamic>.from(e)),
          ),
        )
        .toList();
  }

  Future<InstaPayTransaction?> getTransaction(String transactionId) async {
    try {
      final res = await _api.get('/payments/instapay/$transactionId');
      final data = (res['data'] as Map<String, dynamic>?) ?? res;
      return InstaPayTransaction.fromJson(
        _normalize(Map<String, dynamic>.from(data)),
      );
    } catch (_) {
      return null;
    }
  }
}
