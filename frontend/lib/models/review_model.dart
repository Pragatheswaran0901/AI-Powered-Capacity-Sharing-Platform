class ReviewModel {
  final String id;
  final String bookingId;
  final String reviewerId;
  final String? reviewerName;
  final String revieweeId;
  final int rating;
  final String? reviewText;
  final String createdAt;

  ReviewModel({
    required this.id,
    required this.bookingId,
    required this.reviewerId,
    this.reviewerName,
    required this.revieweeId,
    required this.rating,
    this.reviewText,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] ?? '',
      bookingId: json['booking_id'] ?? '',
      reviewerId: json['reviewer_id'] ?? '',
      reviewerName: json['reviewer_name'],
      revieweeId: json['reviewee_id'] ?? '',
      rating: json['rating'] ?? 5,
      reviewText: json['review_text'],
      createdAt: json['created_at'] ?? '',
    );
  }
}
