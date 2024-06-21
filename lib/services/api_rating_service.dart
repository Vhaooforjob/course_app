import 'dart:convert';
import 'package:course_app/configs/configs.dart';
import 'package:course_app/models/rating.model.dart';
import 'package:http/http.dart' as http;

class ApiRatingServices {
  // static Future<List<Rating>> getAllRatings() async {
  //   final response = await http.get(Uri.parse(rating));
  //   if (response.statusCode == 200) {
  //     List jsonResponse = json.decode(response.body);
  //     return jsonResponse.map((rating) => Rating.fromJson(rating)).toList();
  //   } else {
  //     throw Exception('Failed to load ratings');
  //   }
  // }

  // static Future<Rating> getRatingById(String id) async {
  //   final response = await http.get(Uri.parse('$rating$id'));
  //   if (response.statusCode == 200) {
  //     return Rating.fromJson(json.decode(response.body));
  //   } else {
  //     throw Exception('Failed to load rating');
  //   }
  // }

  static Future<List<Rating>> getRatingsByUserId(String userId) async {
    final response = await http.get(Uri.parse('$rating/user/$userId'));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((rating) => Rating.fromJson(rating)).toList();
    } else {
      throw Exception('Failed to load ratings');
    }
  }

  static Future<List<Rating>> getRatingsByCourseId(String courseId) async {
    final response = await http.get(Uri.parse('$rating/course/$courseId'));
    print('fetch rating course: ${rating}course/$courseId');
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((rating) => Rating.fromJson(rating)).toList();
    } else {
      throw Exception('Failed to load ratings');
    }
  }

  static Future<Rating> createRating(Rating rate) async {
    final response = await http.post(
      Uri.parse(rating),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(rate.toJson()),
    );

    if (response.statusCode == 201) {
      return Rating.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create rating');
    }
  }

  static Future<Rating> updateRating(String id, Rating rating) async {
    final response = await http.put(
      Uri.parse('$rating$id'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(rating.toJson()),
    );

    if (response.statusCode == 200) {
      return Rating.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update rating');
    }
  }

  static Future<void> deleteRating(String id) async {
    final response = await http.delete(Uri.parse('$rating$id'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete rating');
    }
  }
}
