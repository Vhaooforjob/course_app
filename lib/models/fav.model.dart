import 'package:course_app/models/courses.model.dart';

class Favorite {
  final String id;
  final String userId;
  final Course course;

  Favorite({
    required this.id,
    required this.userId,
    required this.course,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['_id'],
      userId: json['user_id']['_id'],
      course: Course.fromJson(json['course_id']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user_id': userId,
      'course_id': course.toJson(),
    };
  }
}
