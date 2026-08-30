import 'package:basita1/core/models/promo_code.dart';
import 'package:basita1/core/network/api_client.dart';

/// Real backend: GET /promo-codes/validate, POST /promo-codes/:id/apply
class PromoCodeRepository {
  final ApiClient _api = ApiClient();

  Future<PromoCode?> validatePromoCode({
    required String code,
    required double orderAmount,
  }) async {
    try {
      final res = await _api.get('/promo-codes/validate', query: {
        'code': code.toUpperCase().trim(),
        'amount': orderAmount,
      });
      final data = (res['data'] as Map<String, dynamic>?)?['promo'] ?? res['data'] ?? res;
      if (data is Map<String, dynamic> && data['code'] != null) return PromoCode.fromJson(data);
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> applyPromoCode(String promoId) async {
    await _api.post('/promo-codes/$promoId/apply', body: {});
  }
}
