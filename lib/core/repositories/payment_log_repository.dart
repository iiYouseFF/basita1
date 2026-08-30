import 'package:basita1/core/models/payment_log.dart';
import 'package:basita1/core/network/api_client.dart';

/// Real backend: POST /payments, GET /payments, etc. at http://basseeyta.duckdns.org
class PaymentLogRepository {
  final ApiClient _api = ApiClient();

  Future<PaymentLog> logPayment({
    required String userId,
    required double amount,
    required String paymentMethod,
    String? requestId,
    String? technicianId,
  }) async {
    final res = await _api.post('/payments', body: {
      'userId': userId,
      if (requestId != null) 'requestId': requestId,
      if (technicianId != null) 'technicianId': technicianId,
      'amount': amount,
      'paymentMethod': paymentMethod,
    });
    final data = (res['data'] as Map<String, dynamic>?)?['payment'] ??
        (res['data'] as Map<String, dynamic>?)?['paymentLog'] ??
        res['data'] ?? res;
    if (data is Map<String, dynamic>) return PaymentLog.fromJson(_normalize(data));
    return PaymentLog(
      id: 'mock_${DateTime.now().millisecondsSinceEpoch}',
      firebaseUserId: userId,
      firebaseRequestId: requestId,
      technicianId: technicianId,
      amount: amount,
      paymentMethod: paymentMethod,
      status: 'completed',
      createdAt: DateTime.now(),
    );
  }

  Map<String, dynamic> _normalize(Map<String, dynamic> j) => {
        'id': j['id'] ?? '',
        'firebase_user_id': j['userId'] ?? j['user_id'] ?? j['firebase_user_id'] ?? '',
        'firebase_request_id': j['requestId'] ?? j['request_id'] ?? j['firebase_request_id'] ?? '',
        'technician_id': j['technicianId'] ?? j['technician_id'] ?? '',
        'amount': j['amount'] ?? 0,
        'currency': j['currency'] ?? 'EGP',
        'payment_method': j['paymentMethod'] ?? j['payment_method'] ?? 'card',
        'status': j['status'] ?? 'completed',
        'created_at': j['createdAt'] ?? j['created_at'],
      };

  Future<List<PaymentLog>> getUserPayments(String userId) async {
    final res = await _api.get('/payments', query: {'userId': userId});
    final data = res['data'];
    final list = data is List ? data : (data is Map && data['payments'] is List ? data['payments'] : []);
    return (list as List).map((e) => PaymentLog.fromJson(_normalize(Map<String, dynamic>.from(e)))).toList();
  }

  Future<List<PaymentLog>> getTechnicianPayments(String technicianId) async {
    final res = await _api.get('/payments', query: {'technicianId': technicianId});
    final data = res['data'];
    final list = data is List ? data : (data is Map && data['payments'] is List ? data['payments'] : []);
    return (list as List).map((e) => PaymentLog.fromJson(_normalize(Map<String, dynamic>.from(e)))).toList();
  }

  Future<void> updatePaymentStatus({
    required String paymentId,
    required String status,
  }) async {
    await _api.patch('/payments/$paymentId', body: {'status': status});
  }
}
