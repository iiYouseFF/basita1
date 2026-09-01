import '../models/api_payment.dart';
import '../services/api_client.dart';

class PaymentRepository {
  final ApiClient _api = ApiClient();

  Future<ApiPaymentCard> createPaymentCard({
    required String userId,
    required String cardLast4,
    String? cardHolder,
    String? expiryDate,
    String? cardType,
    bool? isDefault,
    String? token,
  }) async {
    final body = <String, dynamic>{
      'userId': userId,
      'cardLast4': cardLast4,
    };
    if (cardHolder != null) body['cardHolder'] = cardHolder;
    if (expiryDate != null) body['expiryDate'] = expiryDate;
    if (cardType != null) body['cardType'] = cardType;
    if (isDefault != null) body['isDefault'] = isDefault;
    if (token != null) body['token'] = token;
    
    final response = await _api.post('/payment-cards', body: body);
    return ApiPaymentCard.fromJson(_api.unwrapData(response));
  }

  Future<List<ApiPaymentCard>> getPaymentCards(String userId) async {
    final response = await _api.get(
      '/payment-cards',
      queryParams: {'userId': userId},
    );
    final cards = _api.unwrapList(response);
    return cards.map((c) => ApiPaymentCard.fromJson(c)).toList();
  }

  Future<void> deletePaymentCard(String cardId) async {
    await _api.delete('/payment-cards/$cardId');
  }

  Future<ApiPaymentCard> setDefaultCard(String cardId) async {
    final response = await _api.patch(
      '/payment-cards/$cardId',
      body: {'isDefault': true},
    );
    return ApiPaymentCard.fromJson(_api.unwrapData(response));
  }

  Future<ApiPayment> createPayment({
    required String userId,
    required String requestId,
    required String technicianId,
    required double amount,
    required String paymentMethod,
    String? promoCode,
    String? serviceName,
  }) async {
    final body = <String, dynamic>{
      'userId': userId,
      'requestId': requestId,
      'technicianId': technicianId,
      'amount': amount,
      'paymentMethod': paymentMethod,
    };
    if (promoCode != null) body['promoCode'] = promoCode;
    if (serviceName != null) body['serviceName'] = serviceName;
    
    final response = await _api.post('/payments', body: body);
    return ApiPayment.fromJson(_api.unwrapData(response));
  }

  Future<List<ApiPayment>> getPayments({String? userId, String? technicianId}) async {
    final queryParams = <String, String>{};
    if (userId != null) queryParams['userId'] = userId;
    if (technicianId != null) queryParams['technicianId'] = technicianId;
    
    final response = await _api.get(
      '/payments',
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );
    final payments = _api.unwrapList(response);
    return payments.map((p) => ApiPayment.fromJson(p)).toList();
  }

  Future<ApiInstapayTransaction> createInstapayPayment({
    String? userId,
    String? technicianId,
    String? requestId,
    required double amount,
  }) async {
    final body = <String, dynamic>{
      'amount': amount,
    };
    if (userId != null) body['userId'] = userId;
    if (technicianId != null) body['technicianId'] = technicianId;
    if (requestId != null) body['requestId'] = requestId;
    
    final response = await _api.post('/payments/instapay', body: body);
    return ApiInstapayTransaction.fromJson(_api.unwrapData(response));
  }

  Future<ApiInstapayTransaction> verifyInstapayPayment(
    String transactionId, {
    required String code,
  }) async {
    final response = await _api.post(
      '/payments/instapay/$transactionId/verify',
      body: {'code': code},
    );
    return ApiInstapayTransaction.fromJson(_api.unwrapData(response));
  }

  Future<List<ApiInstapayTransaction>> getInstapayTransactions(String userId) async {
    final response = await _api.get(
      '/payments/instapay',
      queryParams: {'userId': userId},
    );
    final transactions = _api.unwrapList(response);
    return transactions.map((t) => ApiInstapayTransaction.fromJson(t)).toList();
  }

  Future<Map<String, dynamic>> validatePromoCode({
    required String code,
    required double amount,
  }) async {
    final response = await _api.get(
      '/promo-codes/validate',
      queryParams: {'code': code, 'amount': amount.toString()},
      includeAuth: false,
    );
    return _api.unwrapData(response);
  }

  Future<void> applyPromoCode(String promoId) async {
    await _api.post('/promo-codes/$promoId/apply');
  }
}
