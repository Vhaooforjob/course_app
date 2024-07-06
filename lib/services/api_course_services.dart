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
    final response = await http.get(Uri.parse('$courses$courseId'));
    print('fetch course with id: $courses$courseId');
    if (response.statusCode == 200) {
      return Course.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load course');
    }
  }

  static Future<List<Course>> fetchCoursesByUserId(String userId) async {
    final response = await http.get(Uri.parse('${courses}user/$userId'));
    print('fetch courses with userId: ${courses}user/$userId');
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      List<Course> courses = [];
      List<dynamic> coursesJson = jsonResponse['course'];

      for (var item in coursesJson) {
        courses.add(Course.fromJson(item));
      }

      return courses;
    } else {
      throw Exception('Failed to load courses');
    }
  }

  static Future<List<Course>> fetchLatestCourses({int limit = 5}) async {
    final response =
        await http.get(Uri.parse('$courses?limit=$limit&sort=-creation_date'));
    print('Fetch latest courses: $courses?limit=$limit&sort=-creation_date');

    if (response.statusCode == 200) {
      List<Course> courses = [];
      List<dynamic> jsonResponse = json.decode(response.body);

      for (var item in jsonResponse) {
        courses.add(Course.fromJson(item));
      }
      courses.sort((a, b) => b.creationDate.compareTo(a.creationDate));
      return courses.take(limit).toList();
    } else {
      throw Exception('Failed to load latest courses');
    }
  }

  static Future<List<Course>> getCoursesByCategory(String categoryId) async {
    final url = Uri.parse('${courses}category/$categoryId');
    final response = await http.get(url);
    print('Fetch courses by category: $url');

    if (response.statusCode == 200) {
      dynamic jsonResponse = json.decode(response.body);
      if (jsonResponse is List) {
        List<Course> courses = [];
        for (var item in jsonResponse) {
          courses.add(Course.fromJson(item));
        }
        return courses;
      } else if (jsonResponse is Map<String, dynamic> &&
          jsonResponse.containsKey('course')) {
        List<Course> courses = [];
        List<dynamic> coursesJson = jsonResponse['course'];
        for (var item in coursesJson) {
          courses.add(Course.fromJson(item));
        }
        return courses;
      } else {
        throw Exception('Unexpected response format');
      }
    } else {
      throw Exception('Failed to load courses by category');
    }
  }
}
