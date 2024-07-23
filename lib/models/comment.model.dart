class Comment {
  String? id;
  String? review;
  String episodeId;
  String userId;
  DateTime? ratingDate;

  Comment({
    this.id,
    this.review,
    required this.episodeId,
    required this.userId,
    this.ratingDate,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['_id'] as String,
      review: json['review'] as String? ?? 'No review',
      episodeId: json['episode_id'] is Map<String, dynamic>
          ? json['episode_id']['_id']
          : json['episode_id'],
      userId: json['user_id'] is Map<String, dynamic>
          ? json['user_id']['_id']
          : json['user_id'],
      ratingDate: json['rating_date'] != null
          ? DateTime.parse(json['rating_date'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'review': review,
      'episode_id': episodeId,
      'user_id': userId,
      'rating_date': ratingDate?.toIso8601String(),
    };
  }
}
