import 'package:http/http.dart' as http;
import 'dart:convert';
import '../configs/configs.dart';

class APISearchServices {
  static Future<Map<String, dynamic>> searchQuery(String query) async {
    final response = await http.get(Uri.parse('$search$query'));
    print('search with: $search$query');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load search results');
    }
  }

  static Future<List<dynamic>> searchUsersQuery(String query) async {
    final response = await http.get(Uri.parse('$searchU$query'));
    print('search with: $searchU$query');
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('Failed to load search results');
    }
  }

  static Future<List<dynamic>> searchCoursesQuery(String query) async {
    final response = await http.get(Uri.parse('$searchC$query'));
    print('search with: $searchC$query');
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('Failed to load search results');
    }
  }
}
