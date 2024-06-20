import 'package:course_app/models/episodes.model.dart';

class Course {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final List<Episode> episodes;
  final DateTime creationDate;
  //type 'String' is not a subtype of type 'Map<String, dynamic>
  // Changed from Map<String, dynamic> to dynamic
  final dynamic userId;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.episodes,
    required this.creationDate,
    required this.userId,
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
      creationDate: DateTime.parse(json['creation_date']),
      userId: json['user_id'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'episodes': episodes.map((e) => e.toJson()).toList(),
      'creation_date': creationDate.toIso8601String(),
      'user_id': userId,
    };
  }
}
