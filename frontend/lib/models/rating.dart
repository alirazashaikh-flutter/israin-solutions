class Rating {
  final String id;
  final String inquiryId;
  final int rating;
  final String? review;

  Rating({
    required this.id,
    required this.inquiryId,
    required this.rating,
    this.review,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      id: json['_id'] ?? '',
      inquiryId: json['inquiry_id'] is Map
          ? json['inquiry_id']['_id']
          : json['inquiry_id'] ?? '',
      rating: json['rating'] ?? 0,
      review: json['review'],
    );
  }
}
