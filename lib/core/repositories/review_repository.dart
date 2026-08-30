import 'package:basita1/core/models/review.dart';
import 'package:basita1/core/network/api_client.dart';

/// Real backend: POST /reviews, GET /reviews?technicianId=, DELETE /reviews/:id
class ReviewRepository {
  final ApiClient _api = ApiClient();

  Map<String, dynamic> _normalize(Map<String, dynamic> j) => {
        'id': j['id'] ?? '',
        'request_id': j['requestId'] ?? j['request_id'] ?? '',
        'reviewer_id': j['reviewerId'] ?? j['reviewer_id'] ?? '',
        'technician_id': j['technicianId'] ?? j['technician_id'] ?? '',
        'rating': j['rating'] ?? 0,
        'comment': j['comment'],
        'created_at': j['createdAt'] ?? j['created_at'],
      };

  Future<List<Review>> getTechnicianReviews(String technicianId) async {
    final res = await _api.get('/reviews', query: {'technicianId': technicianId});
    final data = (res['data'] as Map<String, dynamic>?)?['reviews'] ?? res['data'] ?? res;
    final list = data is List ? data : (data is Map && data['data'] is List ? data['data'] : []);
    final raw = data is Map && data['reviews'] is List ? data['reviews'] : (data is List ? data : []);
    final arr = (res['data'] is List ? res['data'] : (res['data'] is Map ? (res['data']['reviews'] ?? res['data']['data'] ?? []) : [])) as List;
    // Simpler: try both shapes
    final actual = (res['data'] is List ? res['data'] : (res['data'] is Map ? (res['data']['reviews'] ?? res['data']) : []));
    // Fallback to parsing correctly
    final list2 = actual is List ? actual : [];
    return (list2 as List).map((e) => Review.fromJson(_normalize(Map<String, dynamic>.from(e)))).toList();
  }

  Future<double> getTechnicianAverageRating(String technicianId) async {
    final res = await _api.get('/reviews', query: {'technicianId': technicianId});
    final data = res['data'];
    if (data is Map && data['avg'] != null) return (data['avg'] as num).toDouble();
    if (data is Map && data['average'] != null) return (data['average'] as num).toDouble();
    return 0;
  }

  Future<void> createReview({
    required String requestId,
    required String reviewerId,
    required String technicianId,
    required int rating,
    String? comment,
  }) async {
    await _api.post('/reviews', body: {
      'requestId': requestId,
      'reviewerId': reviewerId,
      'technicianId': technicianId,
      'rating': rating,
      if (comment != null) 'comment': comment,
    });
  }

  Future<void> deleteReview(String reviewId) async {
    await _api.delete('/reviews/$reviewId');
  }
}
