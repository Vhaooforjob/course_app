import 'package:course_app/models/episodes.model.dart';

class Course {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final List<Episode> episodes;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.episodes,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    var episodesJson = json['episodes'] as List<dynamic>?;

    List<Episode> episodesList = episodesJson != null
        ? episodesJson.map((e) => Episode.fromJson(e)).toList()
        : [];

    return Course(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      imageUrl: json['image_url'],
      episodes: episodesList,
    );
  }
}
