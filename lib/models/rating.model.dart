class Rating {
  String id;
  int score;
  String? review;
  DateTime ratingDate;
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
      id: json['_id'],
      score: json['score'],
      review: json['review'] ?? '',
      ratingDate: DateTime.parse(json['rating_date']),
      courseId: json['course_id']['_id'],
      userId: json['user_id']['_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'score': score,
      'review': review,
      'rating_date': ratingDate.toIso8601String(),
      'course_id': courseId,
      'user_id': userId,
    };
  }
}
