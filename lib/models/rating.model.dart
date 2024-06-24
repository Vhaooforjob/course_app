class Rating {
  String id;
  int score;
  String? review;
  DateTime? ratingDate;
  String courseId;
  String userId;

  Rating({
    required this.id,
    required this.score,
    this.review,
    required this.ratingDate,
    required this.courseId,
    required this.userId,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      id: json['_id'] as String,
      score: json['score'] is int ? json['score'] : int.parse(json['score']),
      review: json['review'] ?? '',
      ratingDate: json['rating_date'] != null
          ? DateTime.parse(json['rating_date'])
          : null,
      courseId: json['course_id'] is Map<String, dynamic>
          ? json['course_id']['_id']
          : json['course_id'],
      userId: json['user_id'] is Map<String, dynamic>
          ? json['user_id']['_id']
          : json['user_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'score': score,
      'review': review,
      'rating_date': ratingDate?.toIso8601String(),
      'course_id': courseId,
      'user_id': userId,
    };
  }
}
