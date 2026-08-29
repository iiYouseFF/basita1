import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:basita1/core/models/promo_code.dart';

class PromoCodeRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<PromoCode?> validatePromoCode({
    required String code,
    required double orderAmount,
  }) async {
    final data = await _client
        .from('promo_codes')
        .select()
        .eq('code', code.toUpperCase().trim())
        .eq('is_active', true)
        .limit(1)
        .maybeSingle();

    if (data == null) return null;

    final promo = PromoCode.fromJson(data);
    final now = DateTime.now();

    if (promo.validFrom != null && now.isBefore(promo.validFrom!)) return null;
    if (promo.validUntil != null && now.isAfter(promo.validUntil!)) return null;
    if (promo.maxUses != null && promo.usedCount >= promo.maxUses!) return null;
    if (orderAmount < promo.minOrderAmount) return null;

    return promo;
  }

  Future<void> applyPromoCode(String promoId) async {
    await _client.rpc('increment_used_count', params: {'promo_id': promoId});
  }
}
