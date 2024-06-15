import 'package:course_app/models/courses.model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../configs/configs.dart';

class ApiCourseServices {
  static Future<List<Course>> fetchCourses() async {
    final response = await http.get(Uri.parse(courses));
    print('fetch courses with: $courses');
    if (response.statusCode == 200) {
      List<Course> courses = [];
      List<dynamic> jsonResponse = json.decode(response.body);

      for (var item in jsonResponse) {
        courses.add(Course.fromJson(item));
      }

      return courses;
    } else {
      throw Exception('Failed to load courses');
    }
  }

  static Future<Course> fetchCourseById(String courseId) async {
    final response = await http.get(Uri.parse('${courses}$courseId'));
    print('fetch course with: $courses$courseId');
    if (response.statusCode == 200) {
      return Course.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load course');
    }
  }
}
