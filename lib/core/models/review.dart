class Review {
  final String id;
  final String requestId;
  final String reviewerId;
  final String technicianId;
  final int rating;
  final String? comment;
  final DateTime? createdAt;

  Review({
    required this.id,
    required this.requestId,
    required this.reviewerId,
    required this.technicianId,
    required this.rating,
    this.comment,
    this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? '',
      requestId: json['request_id'] ?? '',
      reviewerId: json['reviewer_id'] ?? '',
      technicianId: json['technician_id'] ?? '',
      rating: json['rating'] ?? 0,
      comment: json['comment'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'request_id': requestId,
      'reviewer_id': reviewerId,
      'technician_id': technicianId,
      'rating': rating,
      'comment': comment,
    };
  }
}
