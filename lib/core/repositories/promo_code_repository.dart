import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:basita1/core/models/promo_code.dart';

class PromoCodeRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<PromoCode?> validatePromoCode({
    required String code,
    required double orderAmount,
  }) async {
    try {
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
      if (promo.validFrom != null && now.isBefore(promo.validFrom!))
        return null;
      if (promo.validUntil != null && now.isAfter(promo.validUntil!))
        return null;
      if (promo.maxUses != null && promo.usedCount >= promo.maxUses!)
        return null;
      if (orderAmount < promo.minOrderAmount) return null;
      return promo;
    } catch (e) {
      // ignore: avoid_print
      print('[PromoCodeRepository.validatePromoCode] $e');
      rethrow;
    }
  }

  Future<void> applyPromoCode(String promoId) async {
    try {
      // RPC expects pid uuid (see supabase: increment_used_count)
      await _client.rpc('increment_used_count', params: {'pid': promoId});
    } catch (e) {
      // fallback for older param name
      try {
        await _client.rpc(
          'increment_used_count',
          params: {'promo_id': promoId},
        );
      } catch (e2) {
        // ignore: avoid_print
        print('[PromoCodeRepository.applyPromoCode] $e / $e2');
        rethrow;
      }
    }
  }
}
