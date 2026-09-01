import '../models/api_offer.dart';
import '../services/api_client.dart';

class OfferRepository {
  final ApiClient _api = ApiClient();

  Future<ApiOffer> createOffer({
    required String requestId,
    required double price,
    String? technicianId,
    String? message,
  }) async {
    final body = <String, dynamic>{
      'requestId': requestId,
      'price': price,
    };
    if (technicianId != null) body['technicianId'] = technicianId;
    if (message != null) body['message'] = message;
    
    final response = await _api.post('/service-requests/$requestId/offers', body: body);
    return ApiOffer.fromJson(_api.unwrapData(response));
  }

  Future<List<ApiOffer>> getOffers(String requestId) async {
    final response = await _api.get('/service-requests/$requestId/offers');
    final offers = _api.unwrapList(response);
    return offers.map((o) => ApiOffer.fromJson(o)).toList();
  }

  Future<ApiOffer> updateOfferStatus(String offerId, String status) async {
    final response = await _api.patch(
      '/offers/$offerId',
      body: {'status': status},
    );
    return ApiOffer.fromJson(_api.unwrapData(response));
  }

  Future<ApiOffer> acceptOffer(String offerId) async {
    return updateOfferStatus(offerId, 'accepted');
  }

  Future<ApiOffer> rejectOffer(String offerId) async {
    return updateOfferStatus(offerId, 'rejected');
  }
}
