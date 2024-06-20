import 'dart:convert';
import 'package:course_app/configs/configs.dart';
import 'package:course_app/models/fav.model.dart';
import 'package:http/http.dart' as http;

class FavoriteService {
  // // Get all favorites
  // static Future<List<Favorite>> getAllFavorites() async {
  //   final url = Uri.parse(fav);

  //   final response = await http.get(url);

  //   if (response.statusCode == 200) {
  //     List<dynamic> data = jsonDecode(response.body);
  //     return data.map((item) => Favorite.fromJson(item)).toList();
  //   } else {
  //     throw Exception('Failed to load favorites');
  //   }
  // }

  // static Future<Favorite> getFavoriteById(String id) async {
  //   final url = Uri.parse(fav + id);

  //   final response = await http.get(url);

  //   if (response.statusCode == 200) {
  //     return Favorite.fromJson(jsonDecode(response.body));
  //   } else {
  //     throw Exception('Failed to load favorite');
  //   }
  // }

  static Future<List<Favorite>> getFavoritesByUserId(String userId) async {
    final url = Uri.parse('${fav}user/$userId');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Favorite.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load user favorites');
    }
  }

  static Future<List<Favorite>> getFavoritesByCourseId(String courseId) async {
    final url = Uri.parse('${fav}course/$courseId');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Favorite.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load course favorites');
    }
  }

  static Future<void> addFavorite(String userId, String courseId) async {
    final url = Uri.parse(fav);

    Map<String, dynamic> requestBody = {
      "user_id": userId,
      "course_id": courseId
    };
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(requestBody),
    );
    print('Add favorite completed: ${url.toString()}');
    if (response.statusCode != 201) {
      throw Exception('Failed to add favorite');
    }
  }

  static Future<void> deleteFavorite(String id) async {
    final response = await http.delete(Uri.parse('$fav$id'));
    print('delete fav completed: $fav$id');
    if (response.statusCode != 200) {
      throw Exception('Failed to delete favorite');
    }
  }
}
