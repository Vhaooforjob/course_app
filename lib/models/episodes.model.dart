class Episode {
  final String id;
  final String title;
  final String imageUrl;
  final String videoUrl;
  final int duration;

  Episode({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.videoUrl,
    required this.duration,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['_id'],
      title: json['title'],
      imageUrl: json['image_url'],
      videoUrl: json['video_url'],
      duration: json['duration'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
    };
  }
}
