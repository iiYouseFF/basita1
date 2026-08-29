import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:basita1/core/models/review.dart';

class ReviewRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Review>> getTechnicianReviews(String technicianId) async {
    final data = await _client
        .from('reviews')
        .select()
        .eq('technician_id', technicianId)
        .order('created_at', ascending: false);
    return data.map((json) => Review.fromJson(json)).toList();
  }

  Future<double> getTechnicianAverageRating(String technicianId) async {
    final data = await _client
        .from('reviews')
        .select('rating')
        .eq('technician_id', technicianId);
    if (data.isEmpty) return 0;
    final total = data.fold<int>(0, (sum, r) => sum + (r['rating'] as int));
    return total / data.length;
  }

  Future<void> createReview({
    required String requestId,
    required String reviewerId,
    required String technicianId,
    required int rating,
    String? comment,
  }) async {
    await _client.from('reviews').insert({
      'request_id': requestId,
      'reviewer_id': reviewerId,
      'technician_id': technicianId,
      'rating': rating,
      'comment': comment,
    });
  }

  Future<void> deleteReview(String reviewId) async {
    await _client.from('reviews').delete().eq('id', reviewId);
  }
}
