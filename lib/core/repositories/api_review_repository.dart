import '../models/api_misc.dart';
import '../services/api_client.dart';

class ReviewRepository {
  final ApiClient _api = ApiClient();

  Future<ApiReview> createReview({
    required String requestId,
    required String reviewerId,
    required String technicianId,
    required int rating,
    String? comment,
  }) async {
    final body = <String, dynamic>{
      'requestId': requestId,
      'reviewerId': reviewerId,
      'technicianId': technicianId,
      'rating': rating,
    };
    if (comment != null) body['comment'] = comment;
    
    final response = await _api.post('/reviews', body: body);
    return ApiReview.fromJson(_api.unwrapData(response));
  }

  Future<List<ApiReview>> getReviews({String? technicianId}) async {
    final queryParams = <String, String>{};
    if (technicianId != null) queryParams['technicianId'] = technicianId;
    
    final response = await _api.get(
      '/reviews',
      queryParams: queryParams.isNotEmpty ? queryParams : null,
      includeAuth: false,
    );
    final reviews = _api.unwrapList(response);
    return reviews.map((r) => ApiReview.fromJson(r)).toList();
  }

  Future<void> deleteReview(String reviewId) async {
    await _api.delete('/reviews/$reviewId');
  }
}
